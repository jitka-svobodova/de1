
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_controller is
  generic (
    clk_hz      : integer := 100_000_000;
    i2c_hz      : integer := 100_000;

    -- Maximum number of write payload bytes (excluding address byte)
    MAX_WBYTES  : integer := 8;

    -- Maximum number of read bytes
    MAX_RBYTES  : integer := 8;

    -- Optional SDA output delay relative to SCL in ns
    sda_delay_ns : integer := 400
  );
  port (
    clk : in std_logic;
    rst : in std_logic;

    scl : out std_logic := 'Z';
    sda : inout std_logic := 'Z';

    -- One "transaction frame" input:
    -- Byte0: ADDR_W (R/W=0)
    -- Byte1..Byte(wr_wbytes): write payload
    -- Byte(wr_wbytes+1): ADDR_R (R/W=1) if wr_rbytes>0
    wr_tdata  : in  std_logic_vector((MAX_WBYTES+2)*8-1 downto 0);
    wr_wbytes : in  unsigned(7 downto 0); -- 0..MAX_WBYTES
    wr_rbytes : in  unsigned(7 downto 0); -- 0..MAX_RBYTES
    wr_tvalid : in  std_logic;
    wr_tready : out std_logic;

    -- Read data output: first received byte at MSB
    rd_tdata  : out std_logic_vector(MAX_RBYTES*8-1 downto 0);
    rd_tvalid : out std_logic;
    rd_tready : in  std_logic;

    -- Pulsed on every observed NACK (address or data)
    nack : out std_logic
  );
end i2c_controller;

architecture rtl of i2c_controller is

  --------------------------------------------------------------------------
  -- Helpers
  --------------------------------------------------------------------------
  function max_int(a, b : integer) return integer is
  begin
    if a > b then return a; else return b; end if;
  end function;

  function to_sl(x : std_logic) return std_logic is
  begin
    if x = '0' then return '0'; else return '1'; end if;
  end function;

  -- Extract byte i from a big-endian byte vector.
  -- i=0 returns the first byte to send on the bus (MSB byte).
  function get_be_byte(v : std_logic_vector; i : integer) return std_logic_vector is
    constant BYTES : integer := v'length / 8;
    variable hi : integer;
    variable lo : integer;
  begin
    hi := v'left - (i*8);
    lo := hi - 7;
    return v(hi downto lo);
  end function;
  
    -- SDA delay function
    function get_sda_delay(raw : integer) return integer is
    begin
        if raw < 2 then
            return 1;
        else
            return raw - 1;
        end if;
    end function;
  --------------------------------------------------------------------------
  -- Open-drain intents: '0' drive low, '1' release (Z)
  --------------------------------------------------------------------------
  signal scl_i : std_logic := '1';
  signal sda_i : std_logic := '1';

  --------------------------------------------------------------------------
  -- Timing: half-period ticks
  --------------------------------------------------------------------------
  constant cycles_per_half_scl_raw : integer := (clk_hz + i2c_hz) / (2 * i2c_hz);
  constant cycles_per_half_scl     : integer := max_int(1, cycles_per_half_scl_raw);
  constant clk_cnt_max             : integer := cycles_per_half_scl - 1;
  signal clk_cnt : integer range 0 to clk_cnt_max := 0;

  --------------------------------------------------------------------------
  -- SDA delay using time arithmetic (no real)
  --------------------------------------------------------------------------
  constant clk_period     : time := 1 sec / clk_hz;
  constant sda_delay_time : time := sda_delay_ns * 1 ns;
  constant sda_delay_cycles_raw : integer := (sda_delay_time + clk_period/2) / clk_period;
--  constant sda_delay_len : integer := (1 when sda_delay_cycles_raw < 2 else sda_delay_cycles_raw - 1);

    
    -- Samotná deklarace konstanty
    constant sda_delay_len : integer := get_sda_delay(sda_delay_cycles_raw);

  signal sda_delay       : std_logic_vector(sda_delay_len-1 downto 0) := (others => '1');
  signal sda_drv_delayed : std_logic := '1';

  --------------------------------------------------------------------------
  -- Latched frame and parameters
  --------------------------------------------------------------------------
  signal frame_reg : std_logic_vector((MAX_WBYTES+2)*8-1 downto 0) := (others => '0');
  signal wlen_reg  : unsigned(7 downto 0) := (others => '0');
  signal rlen_reg  : unsigned(7 downto 0) := (others => '0');

  -- Derived counts
  signal tx_total_bytes : integer range 0 to (MAX_WBYTES+2) := 0;  -- bytes to transmit (addrW + payload + optional addrR)
  signal tx_index       : integer range 0 to (MAX_WBYTES+1) := 0;  -- which TX byte currently sending

  signal rx_total_bytes : integer range 0 to MAX_RBYTES := 0;
  signal rx_index       : integer range 0 to MAX_RBYTES := 0;

  --------------------------------------------------------------------------
  -- Byte/bit TX/RX engines
  --------------------------------------------------------------------------
  signal shreg_tx : std_logic_vector(7 downto 0) := (others => '0');
  signal shreg_rx : std_logic_vector(7 downto 0) := (others => '0');

  signal bit_cnt  : integer range 0 to 8 := 0; -- 0..7 bits, 8=ACK phase
  signal ack_wait : std_logic := '0';
  signal ack_sent : std_logic := '0';

  --------------------------------------------------------------------------
  -- Start/Stop sequencing
  --------------------------------------------------------------------------
  type state_t is (
    IDLE,
    START_A, START_B,
    SEND_BYTE,
    SAMPLE_ACK,
    RESTART_A, RESTART_B,
    RX_BYTE,
    RX_ACKBIT,
    STOP_A, STOP_B,
    DONE
  );
  signal state : state_t := IDLE;

  signal need_restart : std_logic := '0'; -- 1 when rlen>0 (we will send addrR after restart)

begin

  --------------------------------------------------------------------------
  -- Open-drain outputs
  --------------------------------------------------------------------------
  scl <= '0' when scl_i = '0' else 'Z';
  sda <= '0' when sda_drv_delayed = '0' else 'Z';

  --------------------------------------------------------------------------
  -- SDA delay pipeline
  --------------------------------------------------------------------------
  SDA_DELAY_PROC : process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sda_delay       <= (others => '1');
        sda_drv_delayed <= '1';
      else
        if sda_delay_len = 1 then
          sda_delay(0) <= sda_i;
        else
          sda_delay <= sda_i & sda_delay(sda_delay'high downto 1);
        end if;
        sda_drv_delayed <= sda_delay(0);
      end if;
    end if;
  end process;

  --------------------------------------------------------------------------
  -- Main FSM with half-tick clocking and edge detection
  --------------------------------------------------------------------------
  FSM_PROC : process(clk)
    variable tick_now : boolean;
    variable scl_prev : std_logic;
    variable scl_new  : std_logic;
    variable rise_now : boolean;
    variable fall_now : boolean;
    variable cur_byte : std_logic_vector(7 downto 0);
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= IDLE;
        wr_tready <= '0';
        rd_tvalid <= '0';
        rd_tdata  <= (others => '0');
        nack <= '0';

        scl_i <= '1';
        sda_i <= '1';
        clk_cnt <= 0;

        frame_reg <= (others => '0');
        wlen_reg <= (others => '0');
        rlen_reg <= (others => '0');
        need_restart <= '0';

        tx_total_bytes <= 0;
        tx_index <= 0;
        rx_total_bytes <= 0;
        rx_index <= 0;

        shreg_tx <= (others => '0');
        shreg_rx <= (others => '0');
        bit_cnt <= 0;
        ack_wait <= '0';
        ack_sent <= '0';

      else
        --------------------------------------------------------------------
        -- defaults
        --------------------------------------------------------------------
        nack <= '0'; -- pulse
        wr_tready <= '0';

        if rd_tvalid = '1' and rd_tready = '1' then
          rd_tvalid <= '0';
        end if;

        --------------------------------------------------------------------
        -- Half-tick engine: only meaningful in states where SCL toggles
        -- In other states we keep SCL high and reset clk_cnt.
        --------------------------------------------------------------------
        scl_prev := scl_i;
        tick_now := (clk_cnt = clk_cnt_max);

        -- Default: no edge
        rise_now := false;
        fall_now := false;
        scl_new  := scl_prev;

        -- Decide SCL behavior by state:
        -- SEND_BYTE/SAMPLE_ACK/RX_BYTE/RX_ACKBIT => toggle
        -- START/RESTART/STOP => keep high but advance on tick
        -- IDLE/DONE => keep high, no ticking
        if state = SEND_BYTE or state = SAMPLE_ACK or state = RX_BYTE or state = RX_ACKBIT then
          -- toggle SCL on tick
          if tick_now then
            clk_cnt <= 0;
            scl_new := not scl_prev;
            scl_i   <= scl_new;
          else
            clk_cnt <= clk_cnt + 1;
          end if;

          rise_now := tick_now and (scl_prev = '0') and (scl_new = '1');
          fall_now := tick_now and (scl_prev = '1') and (scl_new = '0');

        elsif state = START_A or state = START_B or state = RESTART_A or state = RESTART_B or
              state = STOP_A  or state = STOP_B then
          -- keep SCL high; just count ticks to pace SDA transitions
          scl_i <= '1';
          if tick_now then
            clk_cnt <= 0;
          else
            clk_cnt <= clk_cnt + 1;
          end if;

        else
          -- IDLE / DONE: calm bus and do not tick
          scl_i   <= '1';
          clk_cnt <= 0;
        end if;

        --------------------------------------------------------------------
        -- FSM
        --------------------------------------------------------------------
        case state is

          when IDLE =>
            -- Calm bus
            scl_i <= '1';
            sda_i <= '1';
            rd_tvalid <= '0';
            wr_tready <= '1';

            if wr_tvalid = '1' then
              -- Latch frame and lengths
              frame_reg <= wr_tdata;
              wlen_reg  <= wr_wbytes;
              rlen_reg  <= wr_rbytes;

              -- Decide if we need repeated start + addrR
              if wr_rbytes /= 0 then
                need_restart <= '1';
              else
                need_restart <= '0';
              end if;

              -- Prepare counters
              -- TX bytes:
              -- Always send Byte0 = ADDR_W.
              -- Then wlen bytes of payload (Byte1..Byte(wlen))
              -- If rlen>0 => also send Byte(wlen+1) = ADDR_R after RESTART.
              tx_index <= 0;

              -- tx_total_bytes = 1 + wlen + (need_restart ? 1 : 0)
              if wr_rbytes /= 0 then
                tx_total_bytes <= 1 + to_integer(wr_wbytes) + 1;
              else
                tx_total_bytes <= 1 + to_integer(wr_wbytes);
              end if;

              rx_total_bytes <= to_integer(wr_rbytes);
              rx_index <= 0;
              rd_tdata <= (others => '0');

              -- START sequence
              state <= START_A;
            end if;

          ------------------------------------------------------------------
          -- START: SDA falls while SCL high
          -- START_A: ensure SDA high for one tick, START_B: drive SDA low
          ------------------------------------------------------------------
          when START_A =>
            sda_i <= '1';
            if tick_now then
              state <= START_B;
            end if;

          when START_B =>
            sda_i <= '0';
            if tick_now then
              -- Load first TX byte (ADDR_W)
              cur_byte := get_be_byte(frame_reg, tx_index);
              shreg_tx <= cur_byte;
              bit_cnt  <= 0;
              ack_wait <= '0';
              -- Start with SCL low so first toggle produces rising edge
              scl_i <= '0';
              state <= SEND_BYTE;
            end if;

          ------------------------------------------------------------------
          -- SEND_BYTE: put data bits on SDA at SCL falling edges
          -- Sample bits at rising edges handled implicitly by slave
          ------------------------------------------------------------------
          when SEND_BYTE =>
            -- On falling edge: update SDA with next bit
            if fall_now then
              if bit_cnt < 8 then
                sda_i <= shreg_tx(7);
                shreg_tx <= shreg_tx(6 downto 0) & '0';
                bit_cnt <= bit_cnt + 1;
              else
                -- After 8 bits, release SDA for ACK bit
                sda_i <= '1';
                state <= SAMPLE_ACK;
              end if;
            end if;

          ------------------------------------------------------------------
          -- SAMPLE_ACK: sample ACK at rising edge of 9th clock
          ------------------------------------------------------------------
          when SAMPLE_ACK =>
            if rise_now then
              -- ACK is SDA low, NACK is SDA high
              if to_sl(sda) = '1' then
                nack <= '1'; -- pulse but continue
              end if;

              -- Byte finished. Decide next step.
              bit_cnt <= 0;

              if (tx_index + 1) < tx_total_bytes then
                -- If next byte is the read address and we need restart, do RESTART
                -- The read address byte index is (1 + wlen_reg)
                if (need_restart = '1') and ((tx_index + 1) = (1 + to_integer(wlen_reg))) then
                  tx_index <= tx_index + 1;
                  state <= RESTART_A;
                else
                  tx_index <= tx_index + 1;
                  -- load next byte immediately
                  cur_byte := get_be_byte(frame_reg, tx_index + 1);
                  shreg_tx <= cur_byte;
                  bit_cnt  <= 0;
                  -- Keep SCL low to restart bit clocking cleanly
                  scl_i <= '0';
                  state <= SEND_BYTE;
                end if;
              else
                -- TX phase done
                if rx_total_bytes > 0 then
                  -- Start RX phase (SCL low, SDA released)
                  scl_i <= '0';
                  sda_i <= '1';
                  shreg_rx <= (others => '0');
                  bit_cnt <= 0;
                  ack_sent <= '0';
                  state <= RX_BYTE;
                else
                  state <= STOP_A;
                end if;
              end if;
            end if;

          ------------------------------------------------------------------
          -- REPEATED START: SDA high->low while SCL high (no STOP)
          ------------------------------------------------------------------
          when RESTART_A =>
            -- Ensure SDA released high with SCL high
            scl_i <= '1';
            sda_i <= '1';
            if tick_now then
              state <= RESTART_B;
            end if;

          when RESTART_B =>
            scl_i <= '1';
            sda_i <= '0';
            if tick_now then
              -- load addrR byte (already advanced tx_index in SAMPLE_ACK)
              cur_byte := get_be_byte(frame_reg, tx_index);
              shreg_tx <= cur_byte;
              bit_cnt  <= 0;
              ack_wait <= '0';
              scl_i <= '0';
              state <= SEND_BYTE;
            end if;

          ------------------------------------------------------------------
          -- RX_BYTE: sample SDA bits on SCL rising edges (8 bits)
          ------------------------------------------------------------------
          when RX_BYTE =>
            -- Release SDA so slave can drive it
            sda_i <= '1';

            if rise_now then
              if bit_cnt < 8 then
                shreg_rx <= shreg_rx(6 downto 0) & to_sl(sda);
                bit_cnt  <= bit_cnt + 1;
              else
                -- 8 bits captured, next is ACK/NACK bit from master
                state <= RX_ACKBIT;
              end if;
            end if;

          ------------------------------------------------------------------
          -- RX_ACKBIT: drive ACK for all but last byte, NACK for last byte
          -- Drive at falling edge before ACK clock high.
          ------------------------------------------------------------------
          when RX_ACKBIT =>
            if fall_now then
              -- Decide ACK/NACK for this byte:
              -- if this is the last byte (rx_index = rx_total_bytes-1) => NACK ('1' i.e. release)
              if rx_index = (rx_total_bytes - 1) then
                sda_i <= '1'; -- NACK
              else
                sda_i <= '0'; -- ACK
              end if;

              -- Store received byte into rd_tdata (big-endian packing)
              -- First received byte goes to MSB.
              rd_tdata((MAX_RBYTES*8-1) - rx_index*8 downto (MAX_RBYTES*8-8) - rx_index*8) <= shreg_rx;

              -- Prepare for next
              if rx_index = (rx_total_bytes - 1) then
                -- last byte done => STOP next
                state <= STOP_A;
              else
                rx_index <= rx_index + 1;
                shreg_rx <= (others => '0');
                bit_cnt  <= 0;
                sda_i <= '1'; -- release again
                state <= RX_BYTE;
              end if;
            end if;

          ------------------------------------------------------------------
          -- STOP: SDA rises while SCL high
          ------------------------------------------------------------------
          when STOP_A =>
            scl_i <= '1';
            sda_i <= '0';
            if tick_now then
              state <= STOP_B;
            end if;

          when STOP_B =>
            scl_i <= '1';
            sda_i <= '1';
            if tick_now then
              -- transaction complete
              if rx_total_bytes > 0 then
                rd_tvalid <= '1';
              end if;
              state <= DONE;
            end if;

          ------------------------------------------------------------------
          -- DONE: wait for rd_tready if read transaction, then return IDLE
          ------------------------------------------------------------------
          when DONE =>
            scl_i <= '1';
            sda_i <= '1';
            wr_tready <= '0';

            if rx_total_bytes = 0 then
              state <= IDLE;
            else
              if rd_tvalid = '1' and rd_tready = '1' then
                rd_tvalid <= '0';
                state <= IDLE;
              end if;
            end if;

        end case;

      end if;
    end if;
  end process;

end architecture;
