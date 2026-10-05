-- calculator_fsm.vhd : FSM kalkulator gaya MOORE, 2-process style + datapath
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity calculator_fsm is
  Port ( clk, rst : in  STD_LOGIC;
         sw       : in  STD_LOGIC_VECTOR(15 downto 0);
         pulse_u, pulse_d, pulse_c : in STD_LOGIC;
         display_data : out STD_LOGIC_VECTOR(15 downto 0) );
end calculator_fsm;

architecture Behavioral of calculator_fsm is
  type calc_state is (S_WAIT_A, S_WAIT_B, S_READY, S_COMPUTE, S_SHOW);
  signal state, next_state : calc_state := S_WAIT_A;

  signal reg_a, reg_b : STD_LOGIC_VECTOR(7 downto 0)  := (others => '0');
  signal reg_op       : STD_LOGIC_VECTOR(1 downto 0)  := "00";
  signal reg_res      : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
  signal alu_y        : STD_LOGIC_VECTOR(15 downto 0);
  signal ld_a, ld_b, ld_op, calc_en, show : STD_LOGIC;
begin
  U_ALU : entity work.alu8
          port map (a => reg_a, b => reg_b, op => reg_op, y => alu_y);

  -- PROCESS 1 (sinkron): register state
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then state <= S_WAIT_A;
      else              state <= next_state;
      end if;
    end if;
  end process;

  -- PROCESS 2 (kombinasional): next_state + output (Moore: output hanya dari state)
  process(state, pulse_u, pulse_d, pulse_c)
  begin
    next_state <= state;
    ld_a <= '0'; ld_b <= '0'; ld_op <= '0'; calc_en <= '0'; show <= '0';
    case state is
      when S_WAIT_A  => ld_a <= '1';
                        if pulse_u = '1' then next_state <= S_WAIT_B; end if;
      when S_WAIT_B  => ld_b <= '1';
                        if pulse_d = '1' then next_state <= S_READY; end if;
      when S_READY   => ld_op <= '1';
                        if pulse_c = '1' then next_state <= S_COMPUTE; end if;
      when S_COMPUTE => calc_en <= '1';
                        next_state <= S_SHOW;
      when S_SHOW    => show <= '1';
                        if pulse_c = '1' then next_state <= S_WAIT_A; end if;
    end case;
  end process;

  -- Datapath (register data)
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then                      -- reset juga mengosongkan register data
        reg_a <= (others => '0');  reg_b <= (others => '0');
        reg_op <= "00";            reg_res <= (others => '0');
      else
        if ld_a = '1'    then reg_a   <= sw(7 downto 0);   end if;
        if ld_b = '1'    then reg_b   <= sw(7 downto 0);   end if;
        if ld_op = '1'   then reg_op  <= sw(15 downto 14); end if;
        if calc_en = '1' then reg_res <= alu_y;            end if;
      end if;
    end if;
  end process;

  -- Mode desimal: tampilkan SATU operand (0..255) saat input, hasil saat S_COMPUTE/S_SHOW
  display_data <= (x"00" & reg_a) when state = S_WAIT_A else
                  (x"00" & reg_b) when (state = S_WAIT_B or state = S_READY) else
                  reg_res;
end Behavioral;