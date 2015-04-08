library IEEE;
use IEEE.STD_Logic_1164.all;
use IEEE.STD_Logic_arith.all;
use IEEE.STD_Logic_signed.all;
entity valid_opb_addr is
generic(NUM_MSBS : INTEGER := 24);
port( addr : in STD_LOGIC_VECTOR(0 TO 31);
lowerbnd : in STD_LOGIC_VECTOR(0 to 31);
upperbnd : in STD_LOGIC_VECTOR(0 to 31);
valid_addr : in STD_LOGIC;
enable : out STD_LOGIC);
end valid_opb_addr;
architecture behaviour of valid_opb_addr is
signal met_lowerbnd: STD_LOGIC;
signal met_upperbnd: STD_LOGIC;
signal base_sub: STD_LOGIC_VECTOR(0 to NUM_MSBS-1);
signal high_sub: STD_LOGIC_VECTOR(0 to NUM_MSBS-1);
signal in_range: STD_LOGIC;
begin
--in range = equal or greater than
base_sub <= addr(0 TO NUM_MSBS-1) - lowerbnd(0 TO NUM_MSBS-1);
high_sub <= upperbnd(0 TO NUM_MSBS-1) - addr(0 TO NUM_MSBS-1);
met_lowerbnd <= base_sub(0); --+ve means MSB is 0
met_upperbnd <= high_sub(0); --+ve means MSB is 0
in_range <= met_lowerbnd nor met_upperbnd; --if either is 1, disable
enable <= in_range and valid_addr;
end behaviour;