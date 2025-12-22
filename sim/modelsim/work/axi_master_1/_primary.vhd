library verilog;
use verilog.vl_types.all;
entity axi_master_1 is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        SLAVE0_BASE     : integer := 0;
        SLAVE1_BASE     : integer := 1073741824
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        start           : in     vl_logic;
        m0_completed    : in     vl_logic;
        completed       : out    vl_logic;
        busy            : out    vl_logic;
        M_AXI_araddr    : out    vl_logic_vector;
        M_AXI_arprot    : out    vl_logic_vector(2 downto 0);
        M_AXI_arvalid   : out    vl_logic;
        M_AXI_arready   : in     vl_logic;
        M_AXI_rdata     : in     vl_logic_vector;
        M_AXI_rresp     : in     vl_logic_vector(1 downto 0);
        M_AXI_rvalid    : in     vl_logic;
        M_AXI_rready    : out    vl_logic;
        M_AXI_awaddr    : out    vl_logic_vector;
        M_AXI_awprot    : out    vl_logic_vector(2 downto 0);
        M_AXI_awvalid   : out    vl_logic;
        M_AXI_awready   : in     vl_logic;
        M_AXI_wdata     : out    vl_logic_vector;
        M_AXI_wstrb     : out    vl_logic_vector;
        M_AXI_wvalid    : out    vl_logic;
        M_AXI_wready    : in     vl_logic;
        M_AXI_bresp     : in     vl_logic_vector(1 downto 0);
        M_AXI_bvalid    : in     vl_logic;
        M_AXI_bready    : out    vl_logic;
        address_offset  : out    vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of SLAVE0_BASE : constant is 1;
    attribute mti_svvh_generic_type of SLAVE1_BASE : constant is 1;
end axi_master_1;
