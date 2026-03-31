library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2c_target_model is
  generic (
    G_ADDR_7BIT : std_logic_vector(6 downto 0) := "1010000"; -- e.g. 0x50
    G_MEM_BYTES : natural := 256
  );
  port (
    scl : in    std_logic;   -- from bus
    sda : inout std_logic    -- open-drain bus
  );
end entity;

architecture tb_model of i2c_target_model is

  type t_mem is array (0 to G_MEM_BYTES-1) of std_logic_vector(7 downto 0);
  signal mem : t_mem := (others => (others => '0'));

  -- open-drain SDA drive: '1' pulls low, '0' releases
  signal sda_drive_low : std_logic := '0';

  -- previous sampled values for START/STOP detection
  signal sda_q : std_logic := '1';
  signal scl_q : std_logic := '1';

  type t_state is (
    IDLE,
    ADDR_SHIFT,   -- shifting in address byte
    ACK_ADDR,     -- drive ACK/NACK for address
    RX_SHIFT,     -- shifting in write data byte
    ACK_RX,       -- drive ACK after receiving a data byte
    TX_SHIFT,     -- shifting out read data byte
    WAIT_MACK     -- wait for master ACK/NACK after TX byte
  );
  signal state : t_state := IDLE;

  signal bit_cnt  : integer range 0 to 7 := 7;
  signal shreg    : std_logic_vector(7 downto 0) := (others => '0');

  signal addr_ok  : boolean := false;
  signal rw       : std_logic := '0'; -- 0=write, 1=read

  signal reg_ptr  : unsigned(7 downto 0) := (others => '0');
  signal first_byte_is_ptr : boolean := true;

  function is_high(x : std_logic) return boolean is
  begin
    return (x = '1') or (x = 'H');
  end function;

begin

  -- open-drain connection
  sda <= '0' when sda_drive_low = '1' else 'Z';

  -----------------------------------------------------------------------------
  -- START/STOP detection (asynchronous watching of bus)
  -----------------------------------------------------------------------------
  process(scl, sda)
    variable v_addr : std_logic_vector(6 downto 0);
  begin
    if is_high(scl) then
      -- START: SDA falling while SCL high
      if is_high(sda_q) and (sda = '0') then
        state <= ADDR_SHIFT;
        bit_cnt <= 7;
        addr_ok <= false;
        rw <= '0';
        first_byte_is_ptr <= true;
        sda_drive_low <= '0'; -- release SDA
      end if;

      -- STOP: SDA rising while SCL high
      if (sda_q = '0') and is_high(sda) then
        state <= IDLE;
        sda_drive_low <= '0';
      end if;
    end if;

    sda_q <= sda;
    scl_q <= scl;
--  end process;

  -----------------------------------------------------------------------------
  -- Main I2C bit engine:
  -- - sample on rising SCL
  -- - drive ACK/data on falling SCL
  -----------------------------------------------------------------------------
--  process
--    variable v_addr : std_logic_vector(6 downto 0);
--  begin
--    wait until scl'event;

    ---------------------------------------------------------------------------
    -- Rising edge: sample incoming bits (address/write data, or master ACK/NACK)
    ---------------------------------------------------------------------------
    if scl = '1' then
      case state is
        when ADDR_SHIFT =>
          shreg(bit_cnt) <= sda;
          if bit_cnt = 0 then
            -- address byte complete: [7:1]=addr, [0]=rw
            v_addr := shreg(7 downto 1);
            rw <= shreg(0);
            addr_ok <= (v_addr = G_ADDR_7BIT);
            state <= ACK_ADDR;
            bit_cnt <= 7;
          else
            bit_cnt <= bit_cnt - 1;
          end if;

        when RX_SHIFT =>
          shreg(bit_cnt) <= sda;
          if bit_cnt = 0 then
            state <= ACK_RX;
            bit_cnt <= 7;
          else
            bit_cnt <= bit_cnt - 1;
          end if;

        when WAIT_MACK =>
          -- master drives ACK/NACK after a TX byte
          -- ACK = 0 continue, NACK = 1 stop reading
          if sda = '0' then
            state <= TX_SHIFT; -- continue with next byte
            bit_cnt <= 7;
            -- preload next byte to send (already incremented reg_ptr below)
            shreg <= mem(to_integer(reg_ptr));
          else
            -- NACK -> done; wait for STOP or repeated START
            state <= IDLE;
          end if;

        when others =>
          null;
      end case;

    ---------------------------------------------------------------------------
    -- Falling edge: drive ACK bit or drive TX data bits
    ---------------------------------------------------------------------------
    elsif scl = '0' then
      case state is
        when ACK_ADDR =>
          if addr_ok then
            sda_drive_low <= '1';  -- ACK
          else
            sda_drive_low <= '0';  -- NACK by releasing
          end if;

          if addr_ok then
            if rw = '0' then
              state <= RX_SHIFT;
              sda_drive_low <= '0'; -- release for data bits
            else
              -- read transaction: start transmitting mem at current reg_ptr
              shreg <= mem(to_integer(reg_ptr));
              state <= TX_SHIFT;
              sda_drive_low <= '0';
            end if;
          else
            state <= IDLE;
          end if;

        when ACK_RX =>
          -- ACK write data bytes if addressed
          if addr_ok then
            sda_drive_low <= '1';
          else
            sda_drive_low <= '0';
          end if;

          -- commit received byte
          if addr_ok then
            if first_byte_is_ptr then
              reg_ptr <= unsigned(shreg); -- register pointer
              first_byte_is_ptr <= false;
            else
              mem(to_integer(reg_ptr)) <= shreg;
              reg_ptr <= reg_ptr + 1;
            end if;
          end if;

          -- continue receiving next byte
          state <= RX_SHIFT;
          sda_drive_low <= '0'; -- release for next byte bits

        when RX_SHIFT =>
          -- target releases SDA while master writes
          sda_drive_low <= '0';

        when TX_SHIFT =>
          -- target drives data bits
          if shreg(bit_cnt) = '0' then
            sda_drive_low <= '1';
          else
            sda_drive_low <= '0';
          end if;

          if bit_cnt = 0 then
            -- finished sending byte; next is master ACK/NACK
            state <= WAIT_MACK;
            sda_drive_low <= '0'; -- release so master can drive ACK/NACK
            reg_ptr <= reg_ptr + 1; -- auto-increment for next byte
          else
            bit_cnt <= bit_cnt - 1;
          end if;

        when IDLE =>
          sda_drive_low <= '0';

        when others =>
          null;
      end case;
    end if;
  end process;

end architecture;
