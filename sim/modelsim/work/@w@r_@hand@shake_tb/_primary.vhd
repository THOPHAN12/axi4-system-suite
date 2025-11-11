library verilog;
use verilog.vl_types.all;
entity WR_HandShake_tb is
    generic(
        CLK_PERIOD      : integer := 10
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
end WR_HandShake_tb;
