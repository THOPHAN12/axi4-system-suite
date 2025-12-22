library verilog;
use verilog.vl_types.all;
entity busy_test_tb is
    generic(
        ADDR_WIDTH      : integer := 32;
        DATA_WIDTH      : integer := 32;
        MEM_WORDS       : integer := 1024;
        CLK_PERIOD      : integer := 10;
        SLAVE0_BASE     : integer := 0;
        SLAVE1_BASE     : integer := 1073741824
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ADDR_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of DATA_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of MEM_WORDS : constant is 1;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of SLAVE0_BASE : constant is 1;
    attribute mti_svvh_generic_type of SLAVE1_BASE : constant is 1;
end busy_test_tb;
