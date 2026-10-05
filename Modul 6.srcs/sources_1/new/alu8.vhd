-- alu8.vhd : ALU 8-bit, hasil 16-bit. op: 00=tambah 01=kurang 10=kali 11=bagi
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu8 is
  Port ( a, b : in  STD_LOGIC_VECTOR(7 downto 0);
         op   : in  STD_LOGIC_VECTOR(1 downto 0);
         y    : out STD_LOGIC_VECTOR(15 downto 0) );
end alu8;

architecture Behavioral of alu8 is
begin
  process(a, b, op)
    variable ua, ub : unsigned(7 downto 0);
  begin
    ua := unsigned(a);
    ub := unsigned(b);
    case op is
      when "00" => y <= std_logic_vector(resize(ua, 16) + resize(ub, 16));
      when "01" => y <= std_logic_vector(resize(ua, 16) - resize(ub, 16)); -- negatif tampil FFxx
      when "10" => y <= std_logic_vector(ua * ub);
      when others =>
        if ub = 0 then
          y <= x"EEEE";                                   -- penanda bagi-nol
        else
          y <= std_logic_vector(resize(ua / ub, 16));
        end if;
    end case;
  end process;
end Behavioral;