library verilog;
use verilog.vl_types.all;
entity Demux_1x4 is
    generic(
        width           : integer := 0
    );
    port(
        \in\            : in     vl_logic_vector;
        sel             : in     vl_logic_vector(1 downto 0);
        out0            : out    vl_logic_vector;
        out1            : out    vl_logic_vector;
        out2            : out    vl_logic_vector;
        out3            : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of width : constant is 1;
end Demux_1x4;
