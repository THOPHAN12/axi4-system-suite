library verilog;
use verilog.vl_types.all;
entity Write_Resp_Channel_Arb is
    generic(
        Num_Of_Masters  : integer := 2;
        Masters_Id_Size : vl_notype;
        Num_Of_Slaves   : integer := 4;
        Slaves_Id_Size  : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        Channel_Granted : in     vl_logic;
        M00_AXI_BID     : in     vl_logic_vector;
        M00_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M00_AXI_bvalid  : in     vl_logic;
        M01_AXI_BID     : in     vl_logic_vector;
        M01_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M01_AXI_bvalid  : in     vl_logic;
        M02_AXI_BID     : in     vl_logic_vector;
        M02_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M02_AXI_bvalid  : in     vl_logic;
        M03_AXI_BID     : in     vl_logic_vector;
        M03_AXI_bresp   : in     vl_logic_vector(1 downto 0);
        M03_AXI_bvalid  : in     vl_logic;
        Channel_Request : out    vl_logic;
        Selected_Slave  : out    vl_logic_vector;
        Sel_Resp_ID     : out    vl_logic_vector;
        Sel_Write_Resp  : out    vl_logic_vector(1 downto 0);
        Sel_Valid       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Num_Of_Masters : constant is 1;
    attribute mti_svvh_generic_type of Masters_Id_Size : constant is 3;
    attribute mti_svvh_generic_type of Num_Of_Slaves : constant is 1;
    attribute mti_svvh_generic_type of Slaves_Id_Size : constant is 3;
end Write_Resp_Channel_Arb;
