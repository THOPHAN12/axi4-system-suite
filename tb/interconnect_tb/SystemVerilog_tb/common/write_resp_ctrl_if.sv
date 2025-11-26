`timescale 1ns/1ps

interface write_resp_ctrl_if #(
    parameter int NUM_MASTERS = 2,
    parameter int NUM_SLAVES  = 2,
    parameter int BID_W       = $clog2(NUM_MASTERS)
) (
    input logic clk
);

    logic reset_n;

    // Master response channels (outputs from DUT)
    logic [NUM_MASTERS-1:0][1:0] s_bresp;
    logic [NUM_MASTERS-1:0]      s_bvalid;
    logic [NUM_MASTERS-1:0]      s_bready;

    // Slave response channels (inputs to DUT)
    logic [NUM_SLAVES-1:0][BID_W-1:0] m_bid;
    logic [NUM_SLAVES-1:0][1:0]       m_bresp;
    logic [NUM_SLAVES-1:0]            m_bvalid;
    logic [NUM_SLAVES-1:0]            m_bready;

    // Control/status
    logic [BID_W-1:0] Write_Data_Master;
    logic             Write_Data_Finsh;
    logic [3:0]       Rem;
    logic [3:0]       Num_Of_Compl_Bursts;
    logic             Is_Master_Part_Of_Split;
    logic             Load_The_Original_Signals;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output s_bready;
        input  s_bresp, s_bvalid;
        output m_bid, m_bresp, m_bvalid;
        input  m_bready;
        output Write_Data_Master, Write_Data_Finsh, Rem,
               Num_Of_Compl_Bursts, Is_Master_Part_Of_Split,
               Load_The_Original_Signals;
    endclocking

endinterface

