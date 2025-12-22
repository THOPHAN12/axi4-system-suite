library verilog;
use verilog.vl_types.all;
entity Demux_1x2_en is
    generic(
        width           : integer := 31
    );
    port(
        \in\            : in     vl_logic_vector;
        \select\        : in     vl_logic;
        enable          : in     vl_logic;
        out1            : out    vl_logic_vector;
        out2            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end Demux_1x2_en;
