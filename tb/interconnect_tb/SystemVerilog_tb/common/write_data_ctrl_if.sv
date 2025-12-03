`timescale 1ns/1ps

interface write_data_ctrl_if #(
    parameter int NUM_MASTERS = 2,
    parameter int DATA_W      = 32,
    parameter int ID_W        = 1
) (
    input logic clk
);

    localparam int WSTRB_W = DATA_W / 8;

    logic reset_n;

    // Master write data channels
    logic [NUM_MASTERS-1:0][DATA_W-1:0] s_wdata;
    logic [NUM_MASTERS-1:0][WSTRB_W-1:0] s_wstrb;
    logic [NUM_MASTERS-1:0]              s_wlast;
    logic [NUM_MASTERS-1:0]              s_wvalid;
    logic [NUM_MASTERS-1:0]              s_wready;

    // Slave aggregated write data channel
    logic [DATA_W-1:0]  m_wdata;
    logic [WSTRB_W-1:0] m_wstrb;
    logic               m_wlast;
    logic               m_wvalid;
    logic               m_wready;

    // Control/status
    logic [ID_W-1:0] AW_Selected_Slave;
    logic            AW_Access_Grant;
    logic [ID_W-1:0] Write_Data_Master;
    logic            Write_Data_Finsh;
    logic            Queue_Is_Full;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output s_wdata, s_wstrb, s_wlast, s_wvalid;
        input  s_wready;
        input  m_wdata, m_wstrb, m_wlast, m_wvalid;
        output m_wready;
        output AW_Selected_Slave, AW_Access_Grant;
        input  Write_Data_Master, Write_Data_Finsh, Queue_Is_Full;
    endclocking

endinterface

