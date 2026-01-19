library verilog;
use verilog.vl_types.all;
entity WR_HandShake is
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Valid_Signal    : in     vl_logic;
        Ready_Signal    : in     vl_logic;
        HandShake_En    : in     vl_logic;
        HandShake_Done  : out    vl_logic
    );
end WR_HandShake;
