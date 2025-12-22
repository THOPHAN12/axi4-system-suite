library verilog;
use verilog.vl_types.all;
entity AW_HandShake_Checker is
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Valid_Signal    : in     vl_logic;
        Ready_Signal    : in     vl_logic;
        Channel_Request : in     vl_logic;
        HandShake_Done  : out    vl_logic
    );
end AW_HandShake_Checker;
