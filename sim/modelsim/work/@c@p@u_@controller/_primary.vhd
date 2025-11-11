library verilog;
use verilog.vl_types.all;
entity CPU_Controller is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        start           : in     vl_logic;
        busy            : out    vl_logic;
        done            : out    vl_logic;
        alu_opcode      : out    vl_logic_vector(3 downto 0);
        alu_operand_a   : out    vl_logic_vector;
        alu_operand_b   : out    vl_logic_vector;
        alu_result      : in     vl_logic_vector;
        alu_zero_flag   : in     vl_logic;
        alu_carry_flag  : in     vl_logic;
        read_req        : out    vl_logic;
        read_addr       : out    vl_logic_vector;
        read_ready      : in     vl_logic;
        read_valid      : in     vl_logic;
        read_data       : in     vl_logic_vector;
        read_done       : in     vl_logic;
        write_req       : out    vl_logic;
        write_addr      : out    vl_logic_vector;
        write_data      : out    vl_logic_vector;
        write_ready     : in     vl_logic;
        write_data_ready: in     vl_logic;
        write_done      : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end CPU_Controller;
