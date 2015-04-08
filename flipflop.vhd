LIBRARY ieee;
USE ieee.std_logic_1164.all;
--Entity Declaration:
entity flipflop is
port( clk : in STD_LOGIC;
reset : in STD_LOGIC;
reset_val : in STD_LOGIC;
d : in STD_LOGIC;
q : out STD_LOGIC);
end flipflop;
--Architecture Description:
architecture Behaviour OF flipflop IS
signal int_q : STD_LOGIC;
begin
process(clk, reset)
begin
if (reset = '1') then
int_q <= reset_val;

elsif (rising_edge(clk)) then
int_q <= d;
else
int_q <= int_q;
end if;
END PROCESS;
q <= int_q;
END Behaviour;