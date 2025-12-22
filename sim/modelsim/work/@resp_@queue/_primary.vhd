library verilog;
use verilog.vl_types.all;
entity Resp_Queue is
    generic(
        Slaves_Num      : integer := 2;
        ID_Size         : vl_notype
    );
    port(
        ACLK            : in     vl_logic;
        ARESETN         : in     vl_logic;
        Slave_ID        : in     vl_logic_vector;
        AW_Access_Grant : in     vl_logic;
        Write_Data_Finsh: in     vl_logic;
        Queue_Is_Full   : out    vl_logic;
        Write_Data_HandShake_En_Pulse: out    vl_logic;
        Write_Data_Master: out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Slaves_Num : constant is 1;
    attribute mti_svvh_generic_type of ID_Size : constant is 3;
end Resp_Queue;
