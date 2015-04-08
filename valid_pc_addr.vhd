library IEEE;
use IEEE.STD_Logic_1164.all;
use IEEE.STD_Logic_arith.all;
use IEEE.STD_Logic_signed.all;
entity valid_pc_addr is
generic(NUM_MSBS : INTEGER := 24);
port( pc_ex : in STD_LOGIC_VECTOR(0 TO 31);
lowerbnd : in STD_LOGIC_VECTOR(0 to 31);
upperbnd : in STD_LOGIC_VECTOR(0 to 31);
clk : in STD_LOGIC;
reset : in STD_LOGIC;
enable : out STD_LOGIC);
end valid_pc_addr;
architecture behaviour of valid_pc_addr is
signal met_lowerbnd: STD_LOGIC;
signal met_upperbnd: STD_LOGIC;
signal base_sub: STD_LOGIC_VECTOR(0 to NUM_MSBS-1);
signal high_sub: STD_LOGIC_VECTOR(0 to NUM_MSBS-1);
COMPONENT flipflop IS
PORT( clk : IN STD_LOGIC;
reset : IN STD_LOGIC;
reset_val: IN STD_LOGIC;
d : IN STD_LOGIC;
q : OUT STD_LOGIC);
END COMPONENT flipflop;
begin
--in range = equal or greater than
base_sub <= pc_ex(0 TO NUM_MSBS-1) - lowerbnd(0 TO NUM_MSBS-1);
high_sub <= upperbnd(0 TO NUM_MSBS-1) - pc_ex(0 TO NUM_MSBS-1);
ff0: flipflop port map (clk, reset, '1', base_sub(0), met_lowerbnd);
ff1: flipflop port map (clk, reset, '1', high_sub(0), met_upperbnd);
--the address is guaranteed to be valid due to the latching of the pc_ex,
--this determines if it is in range for a counter (stalls will also be
--caught as the latched value only changes when there is a valid address
--in the pc_ex
enable <= met_lowerbnd nor met_upperbnd; --if either is 1, disable
end behaviour;