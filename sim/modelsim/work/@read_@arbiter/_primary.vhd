library verilog;
use verilog.vl_types.all;
entity Read_Arbiter is
    generic(
        Masters_Num     : integer := 2;
        Masters_ID_Size : vl_notype
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        S00_AXI_arvalid : in     vl_logic;
        S00_AXI_arqos   : in     vl_logic_vector(3 downto 0);
        S01_AXI_arvalid : in     vl_logic;
        S01_AXI_arqos   : in     vl_logic_vector(3 downto 0);
        Channel_Granted : in     vl_logic;
        Token           : in     vl_logic;
        Channel_Request : out    vl_logic;
        Selected_Master : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Masters_Num : constant is 1;
    attribute mti_svvh_generic_type of Masters_ID_Size : constant is 3;
end Read_Arbiter;
