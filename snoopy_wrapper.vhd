library IEEE;
use IEEE.STD_Logic_1164.all;
use IEEE.STD_Logic_arith.all;
use IEEE.STD_Logic_unsigned.all;
use Work.snoopy_types.all;
entity snoopy is


generic(C_OPB_AWIDTH: INTEGER := 32;
C_OPB_DWIDTH: INTEGER := 32;
NUM_COUNTERS: INTEGER := 2; --Max of 10, Min of 1
C_BASEADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FFE0";
C_HIGHADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FFFF";
RESET_ADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FFE4";
INSTR_LOWERBND0: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND0: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND1: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND1: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND2: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND2: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND3: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND3: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND4: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND4: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND5: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND5: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND6: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND6: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND7: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND7: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND8: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND8: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND9: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND9: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND10: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND10: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND11: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND11: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND12: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND12: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND13: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND13: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND14: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND14: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154";
INSTR_LOWERBND15: STD_LOGIC_VECTOR(0 to 31) := X"0080_0140";
INSTR_UPPERBND15: STD_LOGIC_VECTOR(0 to 31) := X"0080_0154"
);
port( OPB_Clk: in STD_LOGIC;
OPB_Rst: in STD_LOGIC;
OPB_ABus: in STD_LOGIC_VECTOR(0 to C_OPB_AWIDTH-1);
OPB_BE: in STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH/8 -1);
OPB_DBus: in STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
OPB_RNW: in STD_LOGIC;
OPB_select: in STD_LOGIC;
OPB_seqAddr: in STD_LOGIC;
snoopy_DBus: out STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
snoopy_errAck: out STD_LOGIC;
snoopy_retry: out STD_LOGIC;
snoopy_toutSup: out STD_LOGIC;
snoopy_xferAck: out STD_LOGIC;
PC_EX: in STD_LOGIC_VECTOR(0 to 31);
valid_instr: in STD_LOGIC);
end entity snoopy;
architecture behaviour of snoopy is
signal int_data_val: cntrArray(0 to NUM_COUNTERS-1);
signal int_snoopy_DBus: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
signal instr_lowerbnds: cntrArray(0 to 15);
signal instr_upperbnds: cntrArray(0 to 15);
signal rd_xferAck: STD_LOGIC;
signal wr_xferAck: STD_LOGIC;
signal int_snoopy_xferAck: STD_LOGIC;
signal reset: STD_LOGIC;
signal cntr_fx_sel: STD_LOGIC_VECTOR(0 to 1);
COMPONENT var_instr_cntrs IS
GENERIC(C_OPB_AWIDTH: INTEGER := 32;
C_OPB_DWIDTH: INTEGER := 32;
NUM_COUNTERS: INTEGER := NUM_COUNTERS --Max of 10, Min of 1
);
PORT(clk: in STD_LOGIC;
reset: in STD_LOGIC;
instr_lowerbnds: in cntrArray(0 to NUM_COUNTERS-1);
instr_upperbnds: in cntrArray(0 to NUM_COUNTERS-1);
cntrs: out cntrArray(0 to NUM_COUNTERS-1);
cntr_fx_sel: in STD_LOGIC_VECTOR(0 to 1);
PC_EX: in STD_LOGIC_VECTOR(0 to 31);
valid_instr: in STD_LOGIC);
END COMPONENT var_instr_cntrs;
COMPONENT opb_output IS
GENERIC(C_OPB_AWIDTH: INTEGER := C_OPB_AWIDTH;
C_OPB_DWIDTH: INTEGER := C_OPB_DWIDTH;
NUM_COUNTERS: INTEGER := NUM_COUNTERS; --Max of 10, Min of 1
RESET_ADDR: STD_LOGIC_VECTOR(0 to 31) := RESET_ADDR;
C_BASEADDR: STD_LOGIC_VECTOR(0 to 31) := C_BASEADDR;
C_HIGHADDR: STD_LOGIC_VECTOR(0 to 31) := C_HIGHADDR
);
PORT( OPB_ABus: in STD_LOGIC_VECTOR(0 to C_OPB_AWIDTH-1);
OPB_Clk: in STD_LOGIC;
OPB_RNW: in STD_LOGIC;
OPB_select: in STD_LOGIC;
cntrs: in cntrArray(0 to NUM_COUNTERS-1);
snoopy_DBus: out STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
reset: out STD_LOGIC;
snoopy_xferAck: out STD_LOGIC);
END COMPONENT opb_output;
begin
instr_lowerbnds(0) <= INSTR_LOWERBND0;
instr_upperbnds(0) <= INSTR_UPPERBND0;
instr_lowerbnds(1) <= INSTR_LOWERBND1;
instr_upperbnds(1) <= INSTR_UPPERBND1;
instr_lowerbnds(2) <= INSTR_LOWERBND2;
instr_upperbnds(2) <= INSTR_UPPERBND2;
instr_lowerbnds(3) <= INSTR_LOWERBND3;
instr_upperbnds(3) <= INSTR_UPPERBND3;
instr_lowerbnds(4) <= INSTR_LOWERBND4;
instr_upperbnds(4) <= INSTR_UPPERBND4;
instr_lowerbnds(5) <= INSTR_LOWERBND5;
instr_upperbnds(5) <= INSTR_UPPERBND5;
instr_lowerbnds(6) <= INSTR_LOWERBND6;
instr_upperbnds(6) <= INSTR_UPPERBND6;
instr_lowerbnds(7) <= INSTR_LOWERBND7;
instr_upperbnds(7) <= INSTR_UPPERBND7;
instr_lowerbnds(8) <= INSTR_LOWERBND8;
instr_upperbnds(8) <= INSTR_UPPERBND8;
instr_lowerbnds(9) <= INSTR_LOWERBND9;
instr_upperbnds(9) <= INSTR_UPPERBND9;
instr_lowerbnds(10) <= INSTR_LOWERBND10;
instr_upperbnds(10) <= INSTR_UPPERBND10;
instr_lowerbnds(11) <= INSTR_LOWERBND11;
instr_upperbnds(11) <= INSTR_UPPERBND11;
instr_lowerbnds(12) <= INSTR_LOWERBND12;
instr_upperbnds(12) <= INSTR_UPPERBND12;
instr_lowerbnds(13) <= INSTR_LOWERBND13;
instr_upperbnds(13) <= INSTR_UPPERBND13;
instr_lowerbnds(14) <= INSTR_LOWERBND14;
instr_upperbnds(14) <= INSTR_UPPERBND14;
instr_lowerbnds(15) <= INSTR_LOWERBND15;
instr_upperbnds(15) <= INSTR_UPPERBND15;
cntr_fx_sel <= OPB_ABus(C_OPB_AWIDTH-4 to C_OPB_AWIDTH-3);
--Instantiates the proper number of counters and attaches them to the PC_EX bus
--looking for valid instructions that are in the specified range for each counter
V0: var_instr_cntrs port map ( OPB_Clk, reset, instr_lowerbnds(0 to NUM_COUNTERS-1),
instr_upperbnds(0 to NUM_COUNTERS-1),
int_data_val, cntr_fx_sel, PC_EX, valid_instr);
--Attaches the counters via a mux to the OPB bus. Outputs the proper counter values
--when a valid address is read by the Master and Resets the counters when the Master
--writes to the reset address
O0: opb_output port map (OPB_ABus, OPB_Clk, OPB_RNW, OPB_select, int_data_val,
int_snoopy_DBus, reset, int_snoopy_xferAck);
snoopy_errAck <= '0';
snoopy_retry <= '0';
snoopy_toutSup <= '0';

snoopy_DBus <= int_snoopy_DBus;
snoopy_xferAck <= int_snoopy_xferAck;
end architecture behaviour;
----------------------------------------------------------------------------