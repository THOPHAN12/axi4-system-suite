library verilog;
use verilog.vl_types.all;
entity WD_MUX_2_1_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Write_data_bus_width: integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Write_data_bus_width : constant is 1;
end WD_MUX_2_1_tb;
