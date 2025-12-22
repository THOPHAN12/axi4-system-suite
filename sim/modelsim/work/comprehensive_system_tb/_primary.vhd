library verilog;
use verilog.vl_types.all;
entity comprehensive_system_tb is
    generic(
        CLK_PERIOD      : integer := 10;
        ARBITRATION_MODE: integer := 1;
        S0_BASE         : integer := 0;
        S0_END          : integer := 536870911;
        S1_BASE         : integer := 1073741824;
        S1_END          : integer := 1610612735;
        S2_BASE         : vl_logic_vector(31 downto 0) := (Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        S2_END          : vl_logic_vector(31 downto 0) := (Hi1, Hi0, Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1);
        S3_BASE         : vl_logic_vector(31 downto 0) := (Hi1, Hi1, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0);
        S3_END          : vl_logic_vector(31 downto 0) := (Hi1, Hi1, Hi0, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of CLK_PERIOD : constant is 1;
    attribute mti_svvh_generic_type of ARBITRATION_MODE : constant is 1;
    attribute mti_svvh_generic_type of S0_BASE : constant is 1;
    attribute mti_svvh_generic_type of S0_END : constant is 1;
    attribute mti_svvh_generic_type of S1_BASE : constant is 1;
    attribute mti_svvh_generic_type of S1_END : constant is 1;
    attribute mti_svvh_generic_type of S2_BASE : constant is 1;
    attribute mti_svvh_generic_type of S2_END : constant is 1;
    attribute mti_svvh_generic_type of S3_BASE : constant is 1;
    attribute mti_svvh_generic_type of S3_END : constant is 1;
end comprehensive_system_tb;
