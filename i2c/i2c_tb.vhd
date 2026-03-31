library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_i2c_controller is
end entity;

architecture sim of tb_i2c_controller is

  ---------------------------------------------------------------------------
  -- Match DUT generics used in this testbench
  ---------------------------------------------------------------------------
  constant CLK_HZ       : integer := 100_000_000;
  constant I2C_HZ       : integer := 100_000;
  constant MAX_WBYTES   : integer := 8;
  constant MAX_RBYTES   : integer := 8;
  constant SDA_DELAY_NS : integer := 400;

  constant TOTAL_BYTES  : integer := (MAX_WBYTES + 2); -- Byte0..Byte(MAX_WBYTES+1)

  ---------------------------------------------------------------------------
  -- Clock / Reset
  ---------------------------------------------------------------------------
  signal clk : std_logic := '0';
  signal rst : std_logic := '1';

  ---------------------------------------------------------------------------
  -- I2C bus with pull-ups (open-drain style)
  ---------------------------------------------------------------------------
  signal scl_bus : std_logic := 'H';
  signal sda_bus : std_logic := 'H';

  -- DUT ports
  signal dut_scl : std_logic;

  ---------------------------------------------------------------------------
  -- DUT streaming-like interface
  ---------------------------------------------------------------------------
  signal wr_tdata  : std_logic_vector((MAX_WBYTES+2)*8-1 downto 0) := (others => '0');
  signal wr_wbytes : unsigned(7 downto 0) := (others => '0');
  signal wr_rbytes : unsigned(7 downto 0) := (others => '0');
  signal wr_tvalid : std_logic := '0';
  signal wr_tready : std_logic;

  signal rd_tdata  : std_logic_vector(MAX_RBYTES*8-1 downto 0);
  signal rd_tvalid : std_logic;
  signal rd_tready : std_logic := '1';

  signal nack      : std_logic;

  ---------------------------------------------------------------------------
  -- Helper: set/get byte in a MSB-first packed vector (Byte0 at MSB)
  ---------------------------------------------------------------------------
  function set_byte_msb_first(
    vec       : std_logic_vector;
    byte_idx  : natural; -- 0..TOTAL_BYTES-1
    b         : std_logic_vector(7 downto 0)
  ) return std_logic_vector is
    variable v : std_logic_vector(vec'range) := vec;
    variable hi : integer;
    variable lo : integer;
  begin
    -- Place Byte0 at MSB side:
    -- byte_idx=0 -> top 8 bits, byte_idx=TOTAL_BYTES-1 -> bottom 8 bits
    hi := vec'left - integer(byte_idx)*8;
    lo := hi - 7;
    v(hi downto lo) := b;
    return v;
  end function;

  function get_byte_msb_first(
    vec      : std_logic_vector;
    byte_idx : natural
  ) return std_logic_vector is
    variable hi : integer;
    variable lo : integer;
  begin
    hi := vec'left - integer(byte_idx)*8;
    lo := hi - 7;
    return vec(hi downto lo);
  end function;

  ---------------------------------------------------------------------------
  -- Convenience: build a frame initialized to 0x00
  ---------------------------------------------------------------------------
  function blank_frame return std_logic_vector is
    variable v : std_logic_vector((MAX_WBYTES+2)*8-1 downto 0) := (others => '0');
  begin
    return v;
  end function;

begin

  ---------------------------------------------------------------------------
  -- Clock generation: 100 MHz
  ---------------------------------------------------------------------------
  clk <= not clk after 5 ns;

  ---------------------------------------------------------------------------
  -- Simple pull-ups on bus lines:
  -- Keep a constant weak-high driver on each line.
  -- Any '0' from DUT or target will dominate via std_logic resolution.
  ---------------------------------------------------------------------------
  scl_bus <= 'H';
  sda_bus <= 'H';

  ---------------------------------------------------------------------------
  -- DUT drives SCL (open-drain style per your port default 'Z')
  ---------------------------------------------------------------------------
  scl_bus <= dut_scl;

  ---------------------------------------------------------------------------
  -- Instantiate DUT
  ---------------------------------------------------------------------------
  u_dut : entity work.i2c_controller
    generic map (
      clk_hz       => CLK_HZ,
      i2c_hz        => I2C_HZ,
      MAX_WBYTES    => MAX_WBYTES,
      MAX_RBYTES    => MAX_RBYTES,
      sda_delay_ns  => SDA_DELAY_NS
    )
    port map (
      clk => clk,
      rst => rst,

      scl => dut_scl,
      sda => sda_bus,

      wr_tdata  => wr_tdata,
      wr_wbytes => wr_wbytes,
      wr_rbytes => wr_rbytes,
      wr_tvalid => wr_tvalid,
      wr_tready => wr_tready,

      rd_tdata  => rd_tdata,
      rd_tvalid => rd_tvalid,
      rd_tready => rd_tready,

      nack => nack
    );

  ---------------------------------------------------------------------------
  -- Instantiate the simple I2C target model (address 0x50)
  ---------------------------------------------------------------------------
  u_target : entity work.i2c_target_model
    generic map (
      G_ADDR_7BIT => "1010000", -- 0x50
      G_MEM_BYTES => 256
    )
    port map (
      scl => scl_bus,
      sda => sda_bus
    );

  ---------------------------------------------------------------------------
  -- Stimulus process
  ---------------------------------------------------------------------------
  p_stim : process
    variable frame : std_logic_vector((MAX_WBYTES+2)*8-1 downto 0);
    variable b0, b1 : std_logic_vector(7 downto 0);

    -- I2C 7-bit address 0x50 => ADDR_W=0xA0, ADDR_R=0xA1
    constant ADDR_W : std_logic_vector(7 downto 0) := x"A0";
    constant ADDR_R : std_logic_vector(7 downto 0) := x"A1";

    procedure send_transaction(
      constant f      : in std_logic_vector((MAX_WBYTES+2)*8-1 downto 0);
      constant wbytes : in natural;
      constant rbytes : in natural
    ) is
    begin
      wr_tdata  <= f;
      wr_wbytes <= to_unsigned(wbytes, wr_wbytes'length);
      wr_rbytes <= to_unsigned(rbytes, wr_rbytes'length);

      wr_tvalid <= '1';
      -- Wait until DUT accepts the frame
      wait until rising_edge(clk);
      while wr_tready = '0' loop
        wait until rising_edge(clk);
      end loop;
      -- accepted on this cycle
      wr_tvalid <= '0';

      -- Wait for completion: if rbytes>0 then rd_tvalid should pulse
      if rbytes > 0 then
        -- wait for rd_tvalid
        while rd_tvalid = '0' loop
          wait until rising_edge(clk);
        end loop;

        -- rd_tdata: first byte at MSB
        b0 := rd_tdata(MAX_RBYTES*8-1 downto MAX_RBYTES*8-8);
        b1 := rd_tdata(MAX_RBYTES*8-9 downto MAX_RBYTES*8-16);

        report "READ done. First byte (MSB) = 0x" &
               to_hstring(b0) & ", second byte = 0x" & to_hstring(b1);
      end if;

      -- basic nack monitor
      if nack = '1' then
        report "NACK observed during transaction!" severity warning;
      end if;

      -- small gap
      for i in 0 to 200 loop
        wait until rising_edge(clk);
      end loop;
    end procedure;

  begin
    -------------------------------------------------------------------------
    -- Reset
    -------------------------------------------------------------------------
    rst <= '1';
    wr_tvalid <= '0';
    rd_tready <= '1';
    for i in 0 to 20 loop
      wait until rising_edge(clk);
    end loop;
    rst <= '0';

    for i in 0 to 20 loop
      wait until rising_edge(clk);
    end loop;

    -------------------------------------------------------------------------
    -- Transaction 1: WRITE
    --  - Byte0: ADDR_W (0xA0)
    --  - Byte1: reg pointer (0x10)
    --  - Byte2: data (0x12)
    --  - Byte3: data (0x34)
    -- wbytes = 3 (pointer + 2 data), rbytes = 0
    -------------------------------------------------------------------------
    frame := blank_frame;
    frame := set_byte_msb_first(frame, 0, ADDR_W);
    frame := set_byte_msb_first(frame, 1, x"10"); -- reg pointer
    frame := set_byte_msb_first(frame, 2, x"12");
    frame := set_byte_msb_first(frame, 3, x"34");

    report "Sending WRITE: ptr=0x10, data=0x12 0x34";
    send_transaction(frame, wbytes => 3, rbytes => 0);

    -------------------------------------------------------------------------
    -- Transaction 2: Combined WRITE(pointer) + READ(2 bytes)
    --  - Byte0: ADDR_W (0xA0)
    --  - Byte1: reg pointer (0x10)
    --  - Byte2: ADDR_R (0xA1)  (DUT should issue repeated START internally)
    -- wbytes = 1 (pointer only), rbytes = 2
    -------------------------------------------------------------------------
    frame := blank_frame;
    frame := set_byte_msb_first(frame, 0, ADDR_W);
    frame := set_byte_msb_first(frame, 1, x"10"); -- reg pointer
    frame := set_byte_msb_first(frame, 2, ADDR_R);

    report "Sending WRITE(ptr) + READ(2): expect 0x12 0x34";
    send_transaction(frame, wbytes => 1, rbytes => 2);

    -------------------------------------------------------------------------
    -- Done
    -------------------------------------------------------------------------
    report "TB finished." severity note;
    wait for 1 us;
    assert false report "End of simulation" severity failure;
  end process;

end architecture;
