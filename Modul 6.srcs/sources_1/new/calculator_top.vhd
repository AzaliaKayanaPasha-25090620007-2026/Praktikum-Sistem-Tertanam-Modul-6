-- calculator_top.vhd : top-level (debounce + edge detect + FSM + seven segment)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity calculator_top is
  Port ( clk  : in  STD_LOGIC;
         sw   : in  STD_LOGIC_VECTOR(15 downto 0);
         btnU, btnD, btnC, btnR : in STD_LOGIC;
         seg  : out STD_LOGIC_VECTOR(6 downto 0);
         an   : out STD_LOGIC_VECTOR(3 downto 0);
         dp   : out STD_LOGIC );
end calculator_top;

architecture Structural of calculator_top is
  signal db_u, db_d, db_c, rst_s : STD_LOGIC;
  signal pu, pd, pc : STD_LOGIC;
  signal disp     : STD_LOGIC_VECTOR(15 downto 0);
  signal bcd_s    : STD_LOGIC_VECTOR(15 downto 0);
  signal disp_dec : STD_LOGIC_VECTOR(15 downto 0);
begin
  U_DB_U : entity work.debounce port map (clk => clk, btn_in => btnU, btn_out => db_u);
  U_DB_D : entity work.debounce port map (clk => clk, btn_in => btnD, btn_out => db_d);
  U_DB_C : entity work.debounce port map (clk => clk, btn_in => btnC, btn_out => db_c);
  U_DB_R : entity work.debounce port map (clk => clk, btn_in => btnR, btn_out => rst_s);

  U_ED_U : entity work.edge_detect port map (clk => clk, sig_in => db_u, pulse => pu);
  U_ED_D : entity work.edge_detect port map (clk => clk, sig_in => db_d, pulse => pd);
  U_ED_C : entity work.edge_detect port map (clk => clk, sig_in => db_c, pulse => pc);

  U_FSM : entity work.calculator_fsm
          port map (clk => clk, rst => rst_s, sw => sw,
                    pulse_u => pu, pulse_d => pd, pulse_c => pc,
                    display_data => disp);

  U_BCD : entity work.bin2bcd
          port map (bin => disp(13 downto 0), bcd => bcd_s);

  -- Bagi-nol tetap EEEE; nilai > 9999 (termasuk hasil negatif) ditandai FFFF
  disp_dec <= x"EEEE" when disp = x"EEEE" else
              x"FFFF" when unsigned(disp) > 9999 else
              bcd_s;

  U_SSD : entity work.seven_seg_driver
          port map (clk => clk, data => disp_dec, seg => seg, an => an, dp => dp);
end Structural;