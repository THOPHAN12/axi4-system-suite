library verilog;
use verilog.vl_types.all;
entity ALU_Core is
    generic(
        DATA_WIDTH      : integer := 32
    );
    port(
        opcode          : in     vl_logic_vector(3 downto 0);
        operand_a       : in     vl_logic_vector;
        operand_b       : in     vl_logic_vector;
        result          : out    vl_logic_vector;
        zero_flag       : out    vl_logic;
        carry_flag      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end ALU_Core;
