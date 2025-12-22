library verilog;
use verilog.vl_types.all;
entity AW_MUX_2_1 is
    generic(
        Address_width   : integer := 32;
        S_Aw_len        : integer := 8
    );
    port(
        Selected_Slave  : in     vl_logic;
        S00_AXI_awaddr  : in     vl_logic_vector;
        S00_AXI_awlen   : in     vl_logic_vector;
        S00_AXI_awsize  : in     vl_logic_vector(2 downto 0);
        S00_AXI_awburst : in     vl_logic_vector(1 downto 0);
        S00_AXI_awlock  : in     vl_logic_vector(1 downto 0);
        S00_AXI_awcache : in     vl_logic_vector(3 downto 0);
        S00_AXI_awprot  : in     vl_logic_vector(2 downto 0);
        S00_AXI_awqos   : in     vl_logic_vector(3 downto 0);
        S00_AXI_awvalid : in     vl_logic;
        S01_AXI_awaddr  : in     vl_logic_vector;
        S01_AXI_awlen   : in     vl_logic_vector;
        S01_AXI_awsize  : in     vl_logic_vector(2 downto 0);
        S01_AXI_awburst : in     vl_logic_vector(1 downto 0);
        S01_AXI_awlock  : in     vl_logic_vector(1 downto 0);
        S01_AXI_awcache : in     vl_logic_vector(3 downto 0);
        S01_AXI_awprot  : in     vl_logic_vector(2 downto 0);
        S01_AXI_awqos   : in     vl_logic_vector(3 downto 0);
        S01_AXI_awvalid : in     vl_logic;
        Sel_S_AXI_awaddr: out    vl_logic_vector;
        Sel_S_AXI_awlen : out    vl_logic_vector;
        Sel_S_AXI_awsize: out    vl_logic_vector(2 downto 0);
        Sel_S_AXI_awburst: out    vl_logic_vector(1 downto 0);
        Sel_S_AXI_awlock: out    vl_logic_vector(1 downto 0);
        Sel_S_AXI_awcache: out    vl_logic_vector(3 downto 0);
        Sel_S_AXI_awprot: out    vl_logic_vector(2 downto 0);
        Sel_S_AXI_awqos : out    vl_logic_vector(3 downto 0);
        Sel_S_AXI_awvalid: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Address_width : constant is 1;
    attribute mti_svvh_generic_type of S_Aw_len : constant is 1;
end AW_MUX_2_1;
