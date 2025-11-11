library verilog;
use verilog.vl_types.all;
entity alu_master_system_tb is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        CLK_PERIOD      : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end alu_master_system_tb;
