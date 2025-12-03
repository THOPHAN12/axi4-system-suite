//=============================================================================
// example_configs.sv
// 
// Ví dụ cấu hình các mode arbitration khác nhau cho axi_rr_interconnect_2x4
//=============================================================================

`timescale 1ns/1ps

// =============================================================================
// Example 1: FIXED PRIORITY (Master 0 > Master 1)
// Use case: Master 0 là real-time CPU, Master 1 là DMA controller
// =============================================================================
module example_fixed_priority (
    input  logic        ACLK,
    input  logic        ARESETN,
    // Master 0 - High priority CPU
    // ... master 0 ports
    // Master 1 - Low priority DMA
    // ... master 1 ports
    // Slaves
    // ... slave ports
);

    axi_rr_interconnect_2x4 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ARBITRATION_MODE("FIXED")  // Master 0 always wins
    ) u_xbar_fixed (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 connections (high priority)
        .M0_AWQOS(4'b0000),    // Not used in FIXED mode
        .M0_ARQOS(4'b0000),    // Not used in FIXED mode
        // ... rest of M0 signals
        
        // Master 1 connections (low priority)
        .M1_AWQOS(4'b0000),    // Not used in FIXED mode
        .M1_ARQOS(4'b0000),    // Not used in FIXED mode
        // ... rest of M1 signals
        
        // Slave connections
        // ...
    );

endmodule


// =============================================================================
// Example 2: ROUND-ROBIN (Fair arbitration)
// Use case: Dual-core SMP system với 2 CPUs có độ quan trọng ngang nhau
// =============================================================================
module example_round_robin (
    input  logic        ACLK,
    input  logic        ARESETN,
    // Master 0 - CPU Core 0
    // ... master 0 ports
    // Master 1 - CPU Core 1
    // ... master 1 ports
    // Slaves
    // ... slave ports
);

    axi_rr_interconnect_2x4 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ARBITRATION_MODE("ROUND_ROBIN")  // Fair alternating
    ) u_xbar_rr (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 connections
        .M0_AWQOS(4'b0000),    // Not used in RR mode
        .M0_ARQOS(4'b0000),    // Not used in RR mode
        // ... rest of M0 signals
        
        // Master 1 connections
        .M1_AWQOS(4'b0000),    // Not used in RR mode
        .M1_ARQOS(4'b0000),    // Not used in RR mode
        // ... rest of M1 signals
        
        // Slave connections
        // ...
    );

endmodule


// =============================================================================
// Example 3: QoS-BASED (Dynamic priority)
// Use case: Video streaming + File transfer system
// =============================================================================
module example_qos_priority (
    input  logic        ACLK,
    input  logic        ARESETN,
    
    // Master 0 - Video streaming controller
    input  logic [31:0] m0_awaddr,
    input  logic [2:0]  m0_awprot,
    input  logic        m0_awvalid,
    output logic        m0_awready,
    input  logic [31:0] m0_wdata,
    input  logic [3:0]  m0_wstrb,
    input  logic        m0_wvalid,
    output logic        m0_wready,
    output logic [1:0]  m0_bresp,
    output logic        m0_bvalid,
    input  logic        m0_bready,
    input  logic [31:0] m0_araddr,
    input  logic [2:0]  m0_arprot,
    input  logic        m0_arvalid,
    output logic        m0_arready,
    output logic [31:0] m0_rdata,
    output logic [1:0]  m0_rresp,
    output logic        m0_rvalid,
    output logic        m0_rlast,
    input  logic        m0_rready,
    
    // Master 1 - File transfer controller
    input  logic [31:0] m1_awaddr,
    input  logic [2:0]  m1_awprot,
    input  logic        m1_awvalid,
    output logic        m1_awready,
    input  logic [31:0] m1_wdata,
    input  logic [3:0]  m1_wstrb,
    input  logic        m1_wvalid,
    output logic        m1_wready,
    output logic [1:0]  m1_bresp,
    output logic        m1_bvalid,
    input  logic        m1_bready,
    input  logic [31:0] m1_araddr,
    input  logic [2:0]  m1_arprot,
    input  logic        m1_arvalid,
    output logic        m1_arready,
    output logic [31:0] m1_rdata,
    output logic [1:0]  m1_rresp,
    output logic        m1_rvalid,
    output logic        m1_rlast,
    input  logic        m1_rready,
    
    // Slave 0-3 ports
    output logic [31:0] s0_awaddr,
    output logic [2:0]  s0_awprot,
    output logic        s0_awvalid,
    input  logic        s0_awready,
    output logic [31:0] s0_wdata,
    output logic [3:0]  s0_wstrb,
    output logic        s0_wvalid,
    input  logic        s0_wready,
    input  logic [1:0]  s0_bresp,
    input  logic        s0_bvalid,
    output logic        s0_bready,
    output logic [31:0] s0_araddr,
    output logic [2:0]  s0_arprot,
    output logic        s0_arvalid,
    input  logic        s0_arready,
    input  logic [31:0] s0_rdata,
    input  logic [1:0]  s0_rresp,
    input  logic        s0_rvalid,
    input  logic        s0_rlast,
    output logic        s0_rready
    // ... S1, S2, S3 similar
);

    // QoS Configuration
    localparam logic [3:0] VIDEO_QOS_HIGH    = 4'd12;  // High priority for video
    localparam logic [3:0] FILE_XFER_QOS_LOW = 4'd2;   // Low priority for file transfer

    axi_rr_interconnect_2x4 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ARBITRATION_MODE("QOS")  // QoS-based dynamic priority
    ) u_xbar_qos (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 - Video (HIGH QoS)
        .M0_AWADDR(m0_awaddr),
        .M0_AWPROT(m0_awprot),
        .M0_AWQOS(VIDEO_QOS_HIGH),     // High priority writes
        .M0_AWVALID(m0_awvalid),
        .M0_AWREADY(m0_awready),
        .M0_WDATA(m0_wdata),
        .M0_WSTRB(m0_wstrb),
        .M0_WVALID(m0_wvalid),
        .M0_WREADY(m0_wready),
        .M0_BRESP(m0_bresp),
        .M0_BVALID(m0_bvalid),
        .M0_BREADY(m0_bready),
        .M0_ARADDR(m0_araddr),
        .M0_ARPROT(m0_arprot),
        .M0_ARQOS(VIDEO_QOS_HIGH),     // High priority reads
        .M0_ARVALID(m0_arvalid),
        .M0_ARREADY(m0_arready),
        .M0_RDATA(m0_rdata),
        .M0_RRESP(m0_rresp),
        .M0_RVALID(m0_rvalid),
        .M0_RLAST(m0_rlast),
        .M0_RREADY(m0_rready),
        
        // Master 1 - File Transfer (LOW QoS)
        .M1_AWADDR(m1_awaddr),
        .M1_AWPROT(m1_awprot),
        .M1_AWQOS(FILE_XFER_QOS_LOW),  // Low priority writes
        .M1_AWVALID(m1_awvalid),
        .M1_AWREADY(m1_awready),
        .M1_WDATA(m1_wdata),
        .M1_WSTRB(m1_wstrb),
        .M1_WVALID(m1_wvalid),
        .M1_WREADY(m1_wready),
        .M1_BRESP(m1_bresp),
        .M1_BVALID(m1_bvalid),
        .M1_BREADY(m1_bready),
        .M1_ARADDR(m1_araddr),
        .M1_ARPROT(m1_arprot),
        .M1_ARQOS(FILE_XFER_QOS_LOW),  // Low priority reads
        .M1_ARVALID(m1_arvalid),
        .M1_ARREADY(m1_arready),
        .M1_RDATA(m1_rdata),
        .M1_RRESP(m1_rresp),
        .M1_RVALID(m1_rvalid),
        .M1_RLAST(m1_rlast),
        .M1_RREADY(m1_rready),
        
        // Slave 0
        .S0_AWADDR(s0_awaddr),
        .S0_AWPROT(s0_awprot),
        .S0_AWVALID(s0_awvalid),
        .S0_AWREADY(s0_awready),
        .S0_WDATA(s0_wdata),
        .S0_WSTRB(s0_wstrb),
        .S0_WVALID(s0_wvalid),
        .S0_WREADY(s0_wready),
        .S0_BRESP(s0_bresp),
        .S0_BVALID(s0_bvalid),
        .S0_BREADY(s0_bready),
        .S0_ARADDR(s0_araddr),
        .S0_ARPROT(s0_arprot),
        .S0_ARVALID(s0_arvalid),
        .S0_ARREADY(s0_arready),
        .S0_RDATA(s0_rdata),
        .S0_RRESP(s0_rresp),
        .S0_RVALID(s0_rvalid),
        .S0_RLAST(s0_rlast),
        .S0_RREADY(s0_rready)
        
        // S1, S2, S3 similar...
    );

endmodule


// =============================================================================
// Example 4: QoS with runtime-configurable priority
// Use case: System with software-controlled QoS settings
// =============================================================================
module example_qos_configurable (
    input  logic        ACLK,
    input  logic        ARESETN,
    
    // Software-controlled QoS values (from CSR registers)
    input  logic [3:0]  m0_qos_config,  // Runtime configurable
    input  logic [3:0]  m1_qos_config,  // Runtime configurable
    
    // Master/Slave ports...
    // (same as previous example)
);

    axi_rr_interconnect_2x4 #(
        .ADDR_WIDTH(32),
        .DATA_WIDTH(32),
        .ARBITRATION_MODE("QOS")
    ) u_xbar_qos_cfg (
        .ACLK(ACLK),
        .ARESETN(ARESETN),
        
        // Master 0 with runtime-configurable QoS
        .M0_AWQOS(m0_qos_config),   // Software can change this
        .M0_ARQOS(m0_qos_config),   // Software can change this
        // ... rest of signals
        
        // Master 1 with runtime-configurable QoS
        .M1_AWQOS(m1_qos_config),   // Software can change this
        .M1_ARQOS(m1_qos_config),   // Software can change this
        // ... rest of signals
        
        // Slaves...
    );

    // Example: Software writes to CSR register to control QoS
    // 0x1000_0000 : Master 0 QoS register
    // 0x1000_0004 : Master 1 QoS register
    //
    // write(0x1000_0000, 15);  // Set M0 to highest priority
    // write(0x1000_0004, 1);   // Set M1 to lowest priority

endmodule


// =============================================================================
// QoS Priority Table - Recommended values
// =============================================================================
/*
    QoS Value | Priority Level | Use Case Example
    ----------|----------------|------------------------------------------
    15 (0xF)  | Critical       | Safety-critical control, interrupt handling
    12-14     | Very High      | Real-time video/audio streaming
    8-11      | High           | Interactive UI, user input
    4-7       | Normal         | Normal application traffic
    2-3       | Low            | Background tasks, logging
    0-1       | Best Effort    | Bulk data transfer, debug traffic
*/

