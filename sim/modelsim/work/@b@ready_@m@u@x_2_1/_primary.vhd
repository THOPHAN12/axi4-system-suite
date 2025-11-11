library verilog;
use verilog.vl_types.all;
entity BReady_MUX_2_1 is
    port(
        Selected_Slave  : in     vl_logic;
        S00_AXI_bready  : in     vl_logic;
        S01_AXI_bready  : in     vl_logic;
        Sele_S_AXI_bready: out    vl_logic
    );
end BReady_MUX_2_1;
