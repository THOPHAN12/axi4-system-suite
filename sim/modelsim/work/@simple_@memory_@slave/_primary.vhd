library verilog;
use verilog.vl_types.all;
entity Simple_Memory_Slave is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        MEM_SIZE        : integer := 256
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        S_AXI_awaddr    : in     vl_logic_vector;
        S_AXI_awlen     : in     vl_logic_vector(7 downto 0);
        S_AXI_awsize    : in     vl_logic_vector(2 downto 0);
        S_AXI_awburst   : in     vl_logic_vector(1 downto 0);
        S_AXI_awlock    : in     vl_logic_vector(1 downto 0);
        S_AXI_awcache   : in     vl_logic_vector(3 downto 0);
        S_AXI_awprot    : in     vl_logic_vector(2 downto 0);
        S_AXI_awregion  : in     vl_logic_vector(3 downto 0);
        S_AXI_awqos     : in     vl_logic_vector(3 downto 0);
        S_AXI_awvalid   : in     vl_logic;
        S_AXI_awready   : out    vl_logic;
        S_AXI_wdata     : in     vl_logic_vector;
        S_AXI_wstrb     : in     vl_logic_vector;
        S_AXI_wlast     : in     vl_logic;
        S_AXI_wvalid    : in     vl_logic;
        S_AXI_wready    : out    vl_logic;
        S_AXI_bresp     : out    vl_logic_vector(1 downto 0);
        S_AXI_bvalid    : out    vl_logic;
        S_AXI_bready    : in     vl_logic;
        S_AXI_araddr    : in     vl_logic_vector;
        S_AXI_arlen     : in     vl_logic_vector(7 downto 0);
        S_AXI_arsize    : in     vl_logic_vector(2 downto 0);
        S_AXI_arburst   : in     vl_logic_vector(1 downto 0);
        S_AXI_arlock    : in     vl_logic_vector(1 downto 0);
        S_AXI_arcache   : in     vl_logic_vector(3 downto 0);
        S_AXI_arprot    : in     vl_logic_vector(2 downto 0);
        S_AXI_arregion  : in     vl_logic_vector(3 downto 0);
        S_AXI_arqos     : in     vl_logic_vector(3 downto 0);
        S_AXI_arvalid   : in     vl_logic;
        S_AXI_arready   : out    vl_logic;
        S_AXI_rdata     : out    vl_logic_vector;
        S_AXI_rresp     : out    vl_logic_vector(1 downto 0);
        S_AXI_rlast     : out    vl_logic;
        S_AXI_rvalid    : out    vl_logic;
        S_AXI_rready    : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_SIZE : constant is 1;
end Simple_Memory_Slave;
