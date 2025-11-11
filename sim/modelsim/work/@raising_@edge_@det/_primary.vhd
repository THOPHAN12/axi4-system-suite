library verilog;
use verilog.vl_types.all;
entity Raising_Edge_Det is
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Test_Singal     : in     vl_logic;
        Raisung         : out    vl_logic
    );
end Raising_Edge_Det;
