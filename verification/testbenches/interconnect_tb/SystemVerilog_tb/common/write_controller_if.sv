`timescale 1ns/1ps

interface write_controller_if #(
    parameter int NUM_MASTERS = 2,
    parameter int NUM_SLAVES  = 2,
    parameter int ADDR_W      = 32,
    parameter int LEN_W       = 8,
    parameter int ID_W        = $clog2(NUM_SLAVES)
) (
    input  logic clk
);

    logic reset_n;

    // Master inputs (simplified AW channel set)
    logic [NUM_MASTERS-1:0][ADDR_W-1:0] s_awaddr;
    logic [NUM_MASTERS-1:0][LEN_W-1:0]  s_awlen;
    logic [NUM_MASTERS-1:0][2:0]        s_awsize;
    logic [NUM_MASTERS-1:0][1:0]        s_awburst;
    logic [NUM_MASTERS-1:0][3:0]        s_awqos;
    logic [NUM_MASTERS-1:0]             s_awvalid;
    logic [NUM_MASTERS-1:0]             s_awready;

    // Slave outputs
    logic [NUM_SLAVES-1:0][ADDR_W-1:0]  m_awaddr;
    logic [NUM_SLAVES-1:0][LEN_W-1:0]   m_awlen;
    logic [NUM_SLAVES-1:0][2:0]         m_awsize;
    logic [NUM_SLAVES-1:0][1:0]         m_awburst;
    logic [NUM_SLAVES-1:0][3:0]         m_awqos;
    logic [NUM_SLAVES-1:0]              m_awvalid;
    logic [NUM_SLAVES-1:0]              m_awready;

    // Control/status
    logic                      AW_Access_Grant;
    logic [ID_W-1:0]           AW_Selected_Slave;
    logic                      Queue_Is_Full;
    logic                      Token;
    logic [3:0]                Rem;
    logic [3:0]                Num_Of_Compl_Bursts;
    logic                      Load_The_Original_Signals;

    clocking cb @(posedge clk);
        default input #1step output #1step;
        output s_awaddr, s_awlen, s_awsize, s_awburst, s_awqos, s_awvalid;
        input  s_awready;
        input  m_awaddr, m_awlen, m_awsize, m_awburst, m_awqos, m_awvalid;
        output m_awready;
        output Queue_Is_Full;
        input  AW_Access_Grant, AW_Selected_Slave, Token;
        input  Rem, Num_Of_Compl_Bursts, Load_The_Original_Signals;
    endclocking

endinterface

