-- debounce.vhd : penyaring bouncing tombol (versi referensi Jobsheet 5)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity debounce is
  generic ( CNT_MAX : integer := 1_000_000 );  -- 10 ms pada 100 MHz
  Port ( clk     : in  STD_LOGIC;
         btn_in  : in  STD_LOGIC;
         btn_out : out STD_LOGIC );
end debounce;

architecture Behavioral of debounce is
  signal sync0, sync1, stable : STD_LOGIC := '0';
  signal cnt : integer range 0 to CNT_MAX := 0;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      sync0 <= btn_in;      -- sinkronisasi 2 flip-flop
      sync1 <= sync0;
      if sync1 /= stable then
        if cnt = CNT_MAX then
          stable <= sync1;
          cnt <= 0;
        else
          cnt <= cnt + 1;
        end if;
      else
        cnt <= 0;
      end if;
    end if;
  end process;
  btn_out <= stable;
end Behavioral;