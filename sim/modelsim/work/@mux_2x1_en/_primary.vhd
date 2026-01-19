library verilog;
use verilog.vl_types.all;
entity Mux_2x1_en is
    generic(
        width           : integer := 31
    );
    port(
        in1             : in     vl_logic_vector;
        in2             : in     vl_logic_vector;
        sel             : in     vl_logic;
        enable          : in     vl_logic;
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end Mux_2x1_en;
