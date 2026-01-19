library verilog;
use verilog.vl_types.all;
entity BR_Channel_Controller_Top is
    generic(
        Slaves_Num      : integer := 2;
        Slaves_ID_Size  : vl_notype;
        AXI4_Aw_len     : integer := 8;
        Resp_ID_width   : integer := 2;
        Num_Of_Masters  : integer := 2;
        Num_Of_Slaves   : integer := 2;
        Master_ID_Width : vl_notype;
        M1_ID           : integer := 0;
        M2_ID           : integer := 1
    );
    port(
        Write_Data_Master: in     vl_logic_vector;
        Write_Data_Finsh: in     vl_logic;
        \Rem\           : in     vl_logic_vector;
        Num_Of_Compl_Bursts: in     vl_logic_vector;
        Is_Master_Part_Of_Split: in     vl_logic;
        Load_The_Original_Signals: in     vl_logic;
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        S01_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S01_AXI_bvalid  : out    vl_logic;
        S01_AXI_bready  : in     vl_logic;
        S00_AXI_bresp   : out    vl_logic_vector(1 downto 0);
        S00_AXI_bvalid  : out    vl_logic;
        S00_AXI_bready  : in     vl_logic;
        M00_AXI_BID     : in     vl_logic_vector;
        M00_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M00_AXI_bvalid  : in     vl_logic;
        M00_AXI_bready  : out    vl_logic;
        M01_AXI_BID     : in     vl_logic_vector;
        M01_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M01_AXI_bvalid  : in     vl_logic;
        M01_AXI_bready  : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
    attribute mti_svvh_generic_type of AXI4_Aw_len : constant is 1;
    attribute mti_svvh_generic_type of Resp_ID_width : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Masters : constant is 1;
    attribute mti_svvh_generic_type of Num_Of_Slaves : constant is 1;
    attribute mti_svvh_generic_type of Master_ID_Width : constant is 3;
    attribute mti_svvh_generic_type of M1_ID : constant is 1;
    attribute mti_svvh_generic_type of M2_ID : constant is 1;
end BR_Channel_Controller_Top;
