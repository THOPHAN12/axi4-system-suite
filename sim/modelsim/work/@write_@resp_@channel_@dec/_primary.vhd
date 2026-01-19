library verilog;
use verilog.vl_types.all;
entity Write_Resp_Channel_Dec is
    generic(
        Num_Of_Masters  : integer := 4;
        Master_ID_Width : vl_notype;
        M1_ID           : integer := 0;
        M2_ID           : integer := 1;
        M3_ID           : integer := 2;
        M4_ID           : integer := 3
    );
    port(
        Sel_Resp_ID     : in     vl_logic_vector;
        Sel_Write_Resp  : in     vl_logic_vector(1 downto 0);
        Sel_Valid       : in     vl_logic;
        S01_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S01_AXI_bvalid  : out    vl_logic;
        S00_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S00_AXI_bvalid  : out    vl_logic;
        S02_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S02_AXI_bvalid  : out    vl_logic;
        S03_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S03_AXI_bvalid  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Num_Of_Masters : constant is 1;
    attribute mti_svvh_generic_type of Master_ID_Width : constant is 3;
    attribute mti_svvh_generic_type of M1_ID : constant is 1;
    attribute mti_svvh_generic_type of M2_ID : constant is 1;
    attribute mti_svvh_generic_type of M3_ID : constant is 1;
    attribute mti_svvh_generic_type of M4_ID : constant is 1;
end Write_Resp_Channel_Dec;
