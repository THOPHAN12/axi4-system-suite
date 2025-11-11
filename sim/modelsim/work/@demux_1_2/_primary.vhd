library verilog;
use verilog.vl_types.all;
entity Demux_1_2 is
    generic(
        Data_Width      : integer := 1
    );
    port(
        Selection_Line  : in     vl_logic;
        Input_1         : in     vl_logic_vector;
        Output_1        : out    vl_logic_vector;
        Output_2        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Data_Width : constant is 1;
end Demux_1_2;
