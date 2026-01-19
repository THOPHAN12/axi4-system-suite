library verilog;
use verilog.vl_types.all;
entity Demux_1_2_tb is
    generic(
        WIDTH_1         : integer := 1;
        WIDTH_2         : integer := 2;
        WIDTH_32        : integer := 32
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of WIDTH_1 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_2 : constant is 1;
    attribute mti_svvh_generic_type of WIDTH_32 : constant is 1;
end Demux_1_2_tb;
