library IEEE;
use IEEE.STD_Logic_1164.all;
use IEEE.STD_Logic_arith.all;
use IEEE.STD_Logic_unsigned.all;
entity clk_cntr is
port(clk: in STD_LOGIC;
reset: in STD_LOGIC;
enable: in STD_LOGIC;
sel_bits: in STD_LOGIC_VECTOR(0 to 1); --enable different
cnt: out STD_LOGIC_VECTOR(0 TO 31));
end entity clk_cntr;
architecture behaviour of clk_cntr is
constant cntrsize : INTEGER := 46; --46 bits
signal int_cnt : STD_LOGIC_VECTOR(0 TO cntrsize-1);
begin
process(clk, reset)
begin
if (reset = '1') then
int_cnt <= (OTHERS => '0');
elsif ( (rising_edge(clk)) and (enable = '1') ) then
int_cnt <= int_cnt + '1';
else
int_cnt <= int_cnt;
end if;
end process;
--***REMEMBER THE "000...000" TERM SIZE IS DETERMINED BY THE CNTRSIZE***
cnt <= (("000000000000000000") & int_cnt(0 to cntrsize-33))
WHEN sel_bits = "00" ELSE
int_cnt(cntrsize-32 to cntrsize-1) WHEN sel_bits = "01"
ELSE (OTHERS=> '0');
end architecture behaviour;
----------------------------------------------------------------------------