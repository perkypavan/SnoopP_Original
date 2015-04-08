LIBRARY ieee;
USE ieee.std_logic_1164.all;
--Entity Declaration:
entity reg is
port( clk : in STD_LOGIC;
reset : in STD_LOGIC;
enable : in STD_LOGIC;
d : in STD_LOGIC;
q : out STD_LOGIC);
end reg;
--Architecture Description:
architecture Behaviour OF reg IS
signal int_q : STD_LOGIC;
begin
process(clk, reset)
begin
if (reset = '1') then
int_q <= '0';
elsif ((rising_edge(clk)) and (enable = '1')) then
int_q <= d;
else
int_q <= int_q;
end if;
END PROCESS;
q <= int_q;
END Behaviour;