-- tb_calculator_fsm.vhd : testbench (menguji FSM langsung, tanpa debounce)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_calculator_fsm is
end tb_calculator_fsm;

architecture sim of tb_calculator_fsm is
  signal clk  : STD_LOGIC := '0';
  signal rst  : STD_LOGIC := '1';
  signal sw   : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal pu, pd, pc : STD_LOGIC := '0';
  signal disp : STD_LOGIC_VECTOR(15 downto 0);
begin
  UUT : entity work.calculator_fsm
        port map (clk => clk, rst => rst, sw => sw,
                  pulse_u => pu, pulse_d => pd, pulse_c => pc,
                  display_data => disp);

  clk <= not clk after 5 ns;  -- 100 MHz

  stim : process
    procedure tap(signal p : out STD_LOGIC) is
    begin
      p <= '1'; wait for 10 ns;
      p <= '0'; wait for 30 ns;
    end procedure;
  begin
    wait for 100 ns;  rst <= '0';  wait for 20 ns;

    -- TAMBAH: 0x2A + 0x13 = 0x003D
    sw <= x"002A"; tap(pu);
    sw <= x"0013"; tap(pd);
    tap(pc);
    assert disp = x"003D" report "ERR tambah" severity error;
    tap(pc);

    -- KURANG: 0x13 - 0x2A = 0xFFE9
    sw <= x"4013"; tap(pu);
    sw <= x"402A"; tap(pd);
    tap(pc);
    assert disp = x"FFE9" report "ERR kurang" severity error;
    tap(pc);

    -- KALI: 0x0A * 0x0B = 0x006E
    sw <= x"800A"; tap(pu);
    sw <= x"800B"; tap(pd);
    tap(pc);
    assert disp = x"006E" report "ERR kali" severity error;
    tap(pc);

    -- BAGI: 0x64 / 0x07 = 0x000E
    sw <= x"C064"; tap(pu);
    sw <= x"C007"; tap(pd);
    tap(pc);
    assert disp = x"000E" report "ERR bagi" severity error;
    tap(pc);

    -- BAGI NOL -> 0xEEEE
    sw <= x"C064"; tap(pu);
    sw <= x"C000"; tap(pd);
    tap(pc);
    assert disp = x"EEEE" report "ERR bagi nol" severity error;

    -- RESET: layar harus 0000 setelah reset (switch operand = 0)
    sw <= x"0000";
    rst <= '1'; wait for 20 ns;
    rst <= '0'; wait for 20 ns;
    assert disp = x"0000" report "ERR reset" severity error;

    report "Simulasi selesai" severity note;
    wait;
  end process;
end sim;