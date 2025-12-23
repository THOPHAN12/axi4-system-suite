// Read_Addr_Channel_Dec_General.sv - General read address decoder for N slaves

`timescale 1ns/1ps

module Read_Addr_Channel_Dec_General #(
    parameter int unsigned Address_width   = 32,
    parameter int unsigned AXI4_AR_len     = 8,
    parameter int unsigned Num_Of_Slaves   = 4,
    parameter int unsigned Base_Addr_Width = (Num_Of_Slaves > 1) ? $clog2(Num_Of_Slaves) : 1
) (
    // Selected master (after arbitration)
    input  logic [Address_width-1:0]   araddr,
    input  logic [AXI4_AR_len-1:0]     arlen,
    input  logic [2:0]                 arsize,
    input  logic [1:0]                 arburst,
    input  logic [1:0]                 arlock,
    input  logic [3:0]                 arcache,
    input  logic [2:0]                 arprot,
    input  logic [3:0]                 arqos,
    input  logic [3:0]                 arregion,
    input  logic                       arvalid,

    // Per-slave AR channel outputs
    output logic [Num_Of_Slaves-1:0]                 S_arvalid,
    output logic [Num_Of_Slaves-1:0][Address_width-1:0] S_araddr,
    output logic [Num_Of_Slaves-1:0][AXI4_AR_len-1:0]   S_arlen,
    output logic [Num_Of_Slaves-1:0][2:0]               S_arsize,
    output logic [Num_Of_Slaves-1:0][1:0]               S_arburst,
    output logic [Num_Of_Slaves-1:0][1:0]               S_arlock,
    output logic [Num_Of_Slaves-1:0][3:0]               S_arcache,
    output logic [Num_Of_Slaves-1:0][2:0]               S_arprot,
    output logic [Num_Of_Slaves-1:0][3:0]               S_arqos,
    output logic [Num_Of_Slaves-1:0][3:0]               S_arregion,

    // One-hot enables per slave
    output logic [Num_Of_Slaves-1:0] Q_Enables
);

    // Base address index from MSBs
    logic [Base_Addr_Width-1:0] base_idx;

    assign base_idx = araddr[Address_width-1 -: Base_Addr_Width];

    always_comb begin
        // Defaults
        S_arvalid  = '0;
        S_araddr   = '{default: '0};
        S_arlen    = '{default: '0};
        S_arsize   = '{default: 3'd0};
        S_arburst  = '{default: 2'd0};
        S_arlock   = '{default: 2'd0};
        S_arcache  = '{default: 4'd0};
        S_arprot   = '{default: 3'd0};
        S_arqos    = '{default: 4'd0};
        S_arregion = '{default: 4'd0};
        Q_Enables  = '0;

        if (arvalid) begin
            if (base_idx < Num_Of_Slaves[Base_Addr_Width-1:0]) begin
                int idx = base_idx;

                S_arvalid[idx]  = 1'b1;
                S_araddr[idx]   = araddr;
                S_arlen[idx]    = arlen;
                S_arsize[idx]   = arsize;
                S_arburst[idx]  = arburst;
                S_arlock[idx]   = arlock;
                S_arcache[idx]  = arcache;
                S_arprot[idx]   = arprot;
                S_arqos[idx]    = arqos;
                S_arregion[idx] = arregion;

                Q_Enables[idx]  = 1'b1;
            end
        end
    end

endmodule




















