library verilog;
use verilog.vl_types.all;
entity WD_MUX_2_1 is
    generic(
        S_Write_data_bus_width: integer := 32;
        S_Write_data_bytes_num: vl_notype
    );
    port(
        Selected_Slave  : in     vl_logic;
        S00_AXI_wdata   : in     vl_logic_vector;
        S00_AXI_wstrb   : in     vl_logic_vector;
        S00_AXI_wlast   : in     vl_logic;
        S00_AXI_wvalid  : in     vl_logic;
        S01_AXI_wdata   : in     vl_logic_vector;
        S01_AXI_wstrb   : in     vl_logic_vector;
        S01_AXI_wlast   : in     vl_logic;
        S01_AXI_wvalid  : in     vl_logic;
        Sel_S_AXI_wdata : out    vl_logic_vector;
        Sel_S_AXI_wstrb : out    vl_logic_vector;
        Sel_S_AXI_wlast : out    vl_logic;
        Sel_S_AXI_wvalid: out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of S_Write_data_bus_width : constant is 1;
    attribute mti_svvh_generic_type of S_Write_data_bytes_num : constant is 3;
end WD_MUX_2_1;
