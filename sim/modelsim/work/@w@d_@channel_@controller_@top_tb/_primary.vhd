library verilog;
use verilog.vl_types.all;
entity WD_Channel_Controller_Top_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        Slaves_Num      : integer := 2;
        Slaves_ID_Size  : vl_notype;
        Address_width   : integer := 32;
        S00_Write_data_bus_width: integer := 32;
        S01_Write_data_bus_width: integer := 32;
        M00_Write_data_bus_width: integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of Slaves_ID_Size : constant is 3;
    attribute mti_svvh_generic_type of Address_width : constant is 1;
    attribute mti_svvh_generic_type of S00_Write_data_bus_width : constant is 1;
    attribute mti_svvh_generic_type of S01_Write_data_bus_width : constant is 1;
    attribute mti_svvh_generic_type of M00_Write_data_bus_width : constant is 1;
end WD_Channel_Controller_Top_tb;
