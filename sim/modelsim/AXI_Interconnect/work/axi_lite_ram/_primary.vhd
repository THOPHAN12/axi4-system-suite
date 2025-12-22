library verilog;
use verilog.vl_types.all;
entity axi_lite_ram is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        MEM_WORDS       : integer := 1024;
        INIT_HEX        : string  := ""
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        S_AXI_awaddr    : in     vl_logic_vector;
        S_AXI_awprot    : in     vl_logic_vector(2 downto 0);
        S_AXI_awvalid   : in     vl_logic;
        S_AXI_awready   : out    vl_logic;
        S_AXI_wdata     : in     vl_logic_vector;
        S_AXI_wstrb     : in     vl_logic_vector;
        S_AXI_wvalid    : in     vl_logic;
        S_AXI_wready    : out    vl_logic;
        S_AXI_bresp     : out    vl_logic_vector(1 downto 0);
        S_AXI_bvalid    : out    vl_logic;
        S_AXI_bready    : in     vl_logic;
        S_AXI_araddr    : in     vl_logic_vector;
        S_AXI_arprot    : in     vl_logic_vector(2 downto 0);
        S_AXI_arvalid   : in     vl_logic;
        S_AXI_arready   : out    vl_logic;
        S_AXI_rdata     : out    vl_logic_vector;
        S_AXI_rresp     : out    vl_logic_vector(1 downto 0);
        S_AXI_rvalid    : out    vl_logic;
        S_AXI_rlast     : out    vl_logic;
        S_AXI_rready    : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 2;
    attribute mti_svvh_generic_type of MEM_WORDS : constant is 2;
    attribute mti_svvh_generic_type of INIT_HEX : constant is 1;
end axi_lite_ram;
