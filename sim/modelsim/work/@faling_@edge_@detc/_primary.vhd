library verilog;
use verilog.vl_types.all;
entity Faling_Edge_Detc is
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Test_Singal     : in     vl_logic;
        Falling         : out    vl_logic
    );
end Faling_Edge_Detc;
