

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package snoopy_types is

constant cntrsize : integer := 32;
type cntrArray is array (natural range <>) of std_logic_vector(0 to cntrsize-1);

end snoopy_types;


