library verilog;
use verilog.vl_types.all;
entity CPU_ALU_Master_tb is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
end CPU_ALU_Master_tb;
