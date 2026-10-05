-- bin2bcd.vhd : biner 14-bit (0..9999) -> 4 digit BCD, algoritma double dabble (kombinasional)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bin2bcd is
  Port ( bin : in  STD_LOGIC_VECTOR(13 downto 0);
         bcd : out STD_LOGIC_VECTOR(15 downto 0) );  -- [ribuan][ratusan][puluhan][satuan]
end bin2bcd;

architecture Behavioral of bin2bcd is
begin
  process(bin)
    variable z : STD_LOGIC_VECTOR(29 downto 0);
  begin
    z := (others => '0');
    z(13 downto 0) := bin;
    for i in 0 to 13 loop
      for j in 0 to 3 loop
        if unsigned(z(17 + 4*j downto 14 + 4*j)) > 4 then
          z(17 + 4*j downto 14 + 4*j) :=
            STD_LOGIC_VECTOR(unsigned(z(17 + 4*j downto 14 + 4*j)) + 3);
        end if;
      end loop;
      z := z(28 downto 0) & '0';
    end loop;
    bcd <= z(29 downto 14);
  end process;
end Behavioral;