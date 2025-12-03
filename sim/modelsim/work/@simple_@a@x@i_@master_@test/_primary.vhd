library verilog;
use verilog.vl_types.all;
entity Simple_AXI_Master_Test is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        ID_WIDTH        : integer := 4
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        start           : in     vl_logic;
        base_address    : in     vl_logic_vector;
        busy            : out    vl_logic;
        done            : out    vl_logic;
        M_AXI_awaddr    : out    vl_logic_vector;
        M_AXI_awlen     : out    vl_logic_vector(7 downto 0);
        M_AXI_awsize    : out    vl_logic_vector(2 downto 0);
        M_AXI_awburst   : out    vl_logic_vector(1 downto 0);
        M_AXI_awlock    : out    vl_logic_vector(1 downto 0);
        M_AXI_awcache   : out    vl_logic_vector(3 downto 0);
        M_AXI_awprot    : out    vl_logic_vector(2 downto 0);
        M_AXI_awregion  : out    vl_logic_vector(3 downto 0);
        M_AXI_awqos     : out    vl_logic_vector(3 downto 0);
        M_AXI_awvalid   : out    vl_logic;
        M_AXI_awready   : in     vl_logic;
        M_AXI_wdata     : out    vl_logic_vector;
        M_AXI_wstrb     : out    vl_logic_vector;
        M_AXI_wlast     : out    vl_logic;
        M_AXI_wvalid    : out    vl_logic;
        M_AXI_wready    : in     vl_logic;
        M_AXI_bresp     : in     vl_logic_vector(1 downto 0);
        M_AXI_bvalid    : in     vl_logic;
        M_AXI_bready    : out    vl_logic;
        M_AXI_araddr    : out    vl_logic_vector;
        M_AXI_arlen     : out    vl_logic_vector(7 downto 0);
        M_AXI_arsize    : out    vl_logic_vector(2 downto 0);
        M_AXI_arburst   : out    vl_logic_vector(1 downto 0);
        M_AXI_arlock    : out    vl_logic_vector(1 downto 0);
        M_AXI_arcache   : out    vl_logic_vector(3 downto 0);
        M_AXI_arprot    : out    vl_logic_vector(2 downto 0);
        M_AXI_arregion  : out    vl_logic_vector(3 downto 0);
        M_AXI_arqos     : out    vl_logic_vector(3 downto 0);
        M_AXI_arvalid   : out    vl_logic;
        M_AXI_arready   : in     vl_logic;
        M_AXI_rdata     : in     vl_logic_vector;
        M_AXI_rresp     : in     vl_logic_vector(1 downto 0);
        M_AXI_rlast     : in     vl_logic;
        M_AXI_rvalid    : in     vl_logic;
        M_AXI_rready    : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of ID_WIDTH : constant is 1;
end Simple_AXI_Master_Test;
