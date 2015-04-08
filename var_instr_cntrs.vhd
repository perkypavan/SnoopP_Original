library IEEE;
use IEEE.STD_Logic_1164.all;
use IEEE.STD_Logic_arith.all;
use IEEE.STD_Logic_unsigned.all;
use Work.snoopy_types.all;
entity var_instr_cntrs is
generic(C_OPB_AWIDTH: INTEGER := 32;
C_OPB_DWIDTH: INTEGER := 32;
NUM_COUNTERS: INTEGER := 2 --Max of 10, Min of 1
);
port( clk: in STD_LOGIC;
reset: in STD_LOGIC;
instr_lowerbnds: in cntrArray(0 to NUM_COUNTERS-1);
instr_upperbnds: in cntrArray(0 to NUM_COUNTERS-1);
cntrs: out cntrArray(0 to NUM_COUNTERS-1);
cntr_fx_sel: in STD_LOGIC_VECTOR(0 to 1);
PC_EX: in STD_LOGIC_VECTOR(0 to 31);
valid_instr: in STD_LOGIC);
end entity var_instr_cntrs;
architecture behaviour of var_instr_cntrs is
signal int_data_val: cntrArray(0 to NUM_COUNTERS-1);
signal int_snoopy_DBus: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
signal enable: STD_LOGIC_VECTOR(0 to NUM_COUNTERS-1);
signal int_pc_ex: STD_LOGIC_VECTOR(0 to 31);
COMPONENT clk_cntr IS
PORT(
clk : in STD_LOGIC;
reset : in STD_LOGIC;
enable : in STD_LOGIC;
sel_bits: in STD_LOGIC_VECTOR(0 to 1); --enable different
cnt : out STD_LOGIC_VECTOR(0 TO 31));
END COMPONENT clk_cntr;
COMPONENT valid_pc_addr IS
GENERIC( NUM_MSBS : INTEGER := 30);
PORT( pc_ex : in STD_LOGIC_VECTOR(0 TO 31);
lowerbnd : in STD_LOGIC_VECTOR(0 TO 31);
upperbnd : in STD_LOGIC_VECTOR(0 TO 31);
clk : in STD_LOGIC;
reset : in STD_LOGIC;
enable : out STD_LOGIC);
END COMPONENT valid_pc_addr;
COMPONENT reg IS
PORT( clk : IN STD_LOGIC;
reset : IN STD_LOGIC;
enable : IN STD_LOGIC;
d : IN STD_LOGIC;
q : OUT STD_LOGIC);
END COMPONENT reg;
begin
--latch each 'valid' PC_EX:
gen0: FOR i IN 0 TO 31 GENERATE
regs: reg port map (clk, reset, valid_instr, pc_ex(i), int_pc_ex(i));
end generate;
GEN1: FOR i in 0 to (NUM_COUNTERS-1) GENERATE
enc: valid_pc_addr port map (int_pc_ex, instr_lowerbnds(i), instr_upperbnds(i),
clk, reset, enable(i));
cnt: clk_cntr port map (clk, reset, enable(i), cntr_fx_sel,
int_data_val(i));
END GENERATE;
cntrs <= int_data_val;
end architecture behaviour;