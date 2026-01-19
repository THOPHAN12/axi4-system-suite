library verilog;
use verilog.vl_types.all;
entity axi_simple_slave_model_comprehensive is
    generic(
        ADDR_BASE       : integer := 0;
        ADDR_MASK       : vl_logic_vector(31 downto 0) := (Hi1, Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0)
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        AWADDR          : in     vl_logic_vector(31 downto 0);
        AWLEN           : in     vl_logic_vector(7 downto 0);
        AWSIZE          : in     vl_logic_vector(2 downto 0);
        AWBURST         : in     vl_logic_vector(1 downto 0);
        AWVALID         : in     vl_logic;
        AWREADY         : out    vl_logic;
        WDATA           : in     vl_logic_vector(31 downto 0);
        WSTRB           : in     vl_logic_vector(3 downto 0);
        WLAST           : in     vl_logic;
        WVALID          : in     vl_logic;
        WREADY          : out    vl_logic;
        BRESP           : out    vl_logic_vector(1 downto 0);
        BVALID          : out    vl_logic;
        BREADY          : in     vl_logic;
        ARADDR          : in     vl_logic_vector(31 downto 0);
        ARLEN           : in     vl_logic_vector(7 downto 0);
        ARSIZE          : in     vl_logic_vector(2 downto 0);
        ARBURST         : in     vl_logic_vector(1 downto 0);
        ARVALID         : in     vl_logic;
        ARREADY         : out    vl_logic;
        RDATA           : out    vl_logic_vector(31 downto 0);
        RRESP           : out    vl_logic_vector(1 downto 0);
        RLAST           : out    vl_logic;
        RVALID          : out    vl_logic;
        RREADY          : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_BASE : constant is 1;
    attribute mti_svvh_generic_type of ADDR_MASK : constant is 1;
end axi_simple_slave_model_comprehensive;
