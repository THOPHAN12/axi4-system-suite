library verilog;
use verilog.vl_types.all;
entity Write_Arbiter_RR is
    generic(
        Slaves_Num      : integer := 2;
        Slaves_ID_Size  : vl_notype
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        S00_AXI_awvalid : in     vl_logic;
        S01_AXI_awvalid : in     vl_logic;
        Channel_Granted : in     vl_logic;
        Channel_Request : out    vl_logic;
        Selected_Slave  : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
end Write_Arbiter_RR;
