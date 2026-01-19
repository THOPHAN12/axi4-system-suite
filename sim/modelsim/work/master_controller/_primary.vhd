library verilog;
use verilog.vl_types.all;
entity master_controller is
    generic(
        NUM_MASTERS     : integer := 2
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        m0_start        : out    vl_logic;
        m0_busy         : in     vl_logic;
        m0_completed    : in     vl_logic;
        m1_start        : out    vl_logic;
        m1_busy         : in     vl_logic;
        m1_completed    : in     vl_logic;
        all_idle        : out    vl_logic;
        any_busy        : out    vl_logic;
        all_completed   : out    vl_logic;
        controller_state: out    vl_logic_vector(1 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of NUM_MASTERS : constant is 1;
end master_controller;
