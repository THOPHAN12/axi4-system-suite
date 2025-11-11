library verilog;
use verilog.vl_types.all;
entity WD_HandShake is
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Valid_Signal    : in     vl_logic;
        Ready_Signal    : in     vl_logic;
        Last_Data       : in     vl_logic;
        HandShake_En    : in     vl_logic;
        HandShake_Done  : out    vl_logic
    );
end WD_HandShake;
