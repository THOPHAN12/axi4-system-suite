library verilog;
use verilog.vl_types.all;
entity Mux_4x1 is
    generic(
        width           : integer := 31
    );
    port(
        in0             : in     vl_logic_vector;
        in1             : in     vl_logic_vector;
        in2             : in     vl_logic_vector;
        in3             : in     vl_logic_vector;
        sel             : in     vl_logic_vector(1 downto 0);
        \out\           : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end Mux_4x1;
