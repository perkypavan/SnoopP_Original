library ieee;
use ieee.std_logic_1164.all;
--Entity Declaration:
entity mux is
--GENERIC(bus_width: INTEGER := 32);
PORT( in_0: in STD_LOGIC_VECTOR(0 to 31);
in_1: in STD_LOGIC_VECTOR(0 to 31);
sel_bit: in STD_LOGIC;
out_val: out STD_LOGIC_VECTOR(0 to 31));
end entity mux;
--Architecture Description:
architecture behaviour of mux is
begin
out_val <= in_0 WHEN sel_bit = '0' ELSE in_1;
end behaviour;