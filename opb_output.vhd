library IEEE;
use IEEE.STD_Logic_1164.all;
use Work.snoopy_types.all;
entity opb_output is
generic(C_OPB_AWIDTH: INTEGER := 32;
C_OPB_DWIDTH: INTEGER := 32;
NUM_COUNTERS: INTEGER := 2; --Max of 10, Min of 1
RESET_ADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FFE4";
C_BASEADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FF00";
C_HIGHADDR: STD_LOGIC_VECTOR(0 to 31) := X"FFFF_FFFF"
);
port( OPB_ABus: in STD_LOGIC_VECTOR(0 to C_OPB_AWIDTH-1);
OPB_Clk: in STD_LOGIC;
OPB_RNW: in STD_LOGIC;
OPB_select: in STD_LOGIC;
cntrs: in cntrArray(0 to NUM_COUNTERS-1);
snoopy_DBus: out STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
reset: out STD_LOGIC;
snoopy_xferAck: out STD_LOGIC);

end entity opb_output;
architecture behaviour of opb_output is
signal valid_hi_reset_bits: STD_LOGIC;
signal valid_reset_control: STD_LOGIC;
signal valid_read_control: STD_LOGIC;
signal valid_lo_addr_bits: STD_LOGIC;
signal valid_hi_addr_bits: STD_LOGIC;
signal sel_bits: STD_LOGIC_VECTOR(0 to 3);
signal mux3_out: cntrArray(0 to 7);
signal mux2_out: cntrArray(0 to 3);
signal mux1_out: cntrArray(0 to 1);
signal mux0_out: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
signal mux_out: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
signal int_snoopy_xferAck: STD_LOGIC;
signal int_reset: STD_LOGIC;
signal int_snoopy_DBus: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1);
signal lowerbnd: STD_LOGIC_VECTOR(0 to C_OPB_AWIDTH-1):= C_BASEADDR;
signal upperbnd: STD_LOGIC_VECTOR(0 to C_OPB_AWIDTH-1):= C_HIGHADDR;
signal gnd_bus: STD_LOGIC_VECTOR(0 to C_OPB_DWIDTH-1):= X"0000_0000";
COMPONENT mux IS
PORT( in_0 : in STD_LOGIC_VECTOR(0 to 31);
in_1 : in STD_LOGIC_VECTOR(0 to 31);
sel_bit : in STD_LOGIC;
out_val : out STD_LOGIC_VECTOR(0 to 31));
END COMPONENT mux;
COMPONENT valid_opb_addr IS
generic( NUM_MSBS : INTEGER := 24);
port( addr : in STD_LOGIC_VECTOR(0 TO 31);
lowerbnd : in STD_LOGIC_VECTOR(0 to 31);
upperbnd : in STD_LOGIC_VECTOR(0 to 31);
valid_addr : in STD_LOGIC;
enable : out STD_LOGIC);
END COMPONENT valid_opb_addr;
begin
--Assumptions (for now):
--valid addresses occur every 8 bytes to allow for 64 bit counters
--I've hard-wired a 16 to 1 mux architecture (not the most efficient)
--xferAck isn't guaranteed to be high for only one clk cycle
OE0: valid_opb_addr port map (OPB_ABus, lowerbnd, upperbnd, OPB_select,
valid_hi_addr_bits);
valid_lo_addr_bits <= '1' WHEN OPB_ABus(C_OPB_AWIDTH-2 to C_OPB_AWIDTH-1) = "00"
ELSE '0';
valid_hi_reset_bits <= '1' WHEN ((valid_hi_addr_bits = '1') and
(OPB_ABus(C_OPB_AWIDTH-8 to C_OPB_AWIDTH-3) = RESET_ADDR(24 to 29)) )
ELSE '0';
--OPB_select is included in the determination of valid_hi_addr_bits
valid_reset_control <= valid_lo_addr_bits and valid_hi_reset_bits and (not(OPB_RNW));
valid_read_control <= valid_lo_addr_bits and valid_hi_addr_bits and OPB_RNW;
sel_bits <= OPB_ABus(C_OPB_AWIDTH-8 to C_OPB_AWIDTH-5);
--HOW DO I GENERATE XFERACK AND VALID HI BITS FOR READ?
G3: IF (NUM_COUNTERS>1) GENERATE
G3A: FOR i in 0 to ((NUM_COUNTERS/2)-1) GENERATE
M3: mux port map (cntrs(2*i), cntrs((2*i)+1), sel_bits(3), mux3_out(i));
END GENERATE;
END GENERATE;

G3_0: IF (NUM_COUNTERS mod 2=0) GENERATE -- even
G3_0A: FOR i in (NUM_COUNTERS/2) to 7 GENERATE
M3_0: mux port map(gnd_bus, gnd_bus, sel_bits(3), mux3_out(i));
END GENERATE;
END GENERATE;
G3_1: IF (NUM_COUNTERS mod 2=1) GENERATE -- odd
M3_1: mux port map(cntrs(NUM_COUNTERS-1), gnd_bus, sel_bits(3),
mux3_out(NUM_COUNTERS/2));
G3_1A: FOR i in (NUM_COUNTERS/2)+1 to 7 GENERATE
M3_1A: mux port map(gnd_bus, gnd_bus, sel_bits(3), mux3_out(i));
END GENERATE;
END GENERATE;
G2: FOR i in 0 to 3 GENERATE
M2: mux port map(mux3_out(2*i), mux3_out((2*i)+1), sel_bits(2), mux2_out(i));
END GENERATE;
G1: FOR i in 0 to 1 GENERATE
M1: mux port map(mux2_out(2*i), mux2_out((2*i)+1), sel_bits(1), mux1_out(i));
END GENERATE;
G0: mux port map(mux1_out(0), mux1_out(1), sel_bits(0), mux0_out);
MOUT: mux port map(gnd_bus, mux0_out, valid_read_control, mux_out);
----Process for xmd output:
process(OPB_Clk)
begin
if( rising_edge(OPB_Clk) ) then
if ( valid_read_control = '1' ) then
int_reset <= '0';
int_snoopy_DBus <= mux_out;
int_snoopy_xferAck <= '1';
elsif ( valid_reset_control = '1' ) then
int_reset <= '1';
int_snoopy_DBus <= gnd_bus;
int_snoopy_xferAck <= '1';
else
int_reset <= '0';
int_snoopy_DBus <= gnd_bus;
int_snoopy_xferAck <= '0';
end if;
else
int_reset <= int_reset;
int_snoopy_DBus <= int_snoopy_DBus;
int_snoopy_xferAck <= int_snoopy_xferAck;
end if;
end process;
reset <= int_reset;
snoopy_Dbus <= int_snoopy_DBus;
snoopy_xferAck <= int_snoopy_xferAck;
end architecture behaviour;