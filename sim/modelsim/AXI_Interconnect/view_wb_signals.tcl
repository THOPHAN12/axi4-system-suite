# TCL script to view Wishbone signals in waveform
# Usage: vsim -view vsim.wlf -do "source view_wb_signals.tcl"

# Add Wishbone signals for M0
add wave -divider "M0 Wishbone Signals"
add wave -radix hex /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/wb_adr
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/wb_cyc
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/wb_ack
add wave -radix hex /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/wb_rdt
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/i_cnt_done
add wave -radix hex /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/addr_latch
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/pending_data_valid
add wave -radix hex /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/pending_data

# Add AXI signals for M0
add wave -divider "M0 AXI Signals"
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_arvalid
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_arready
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rvalid
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rready
add wave -radix hex /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/M_AXI_rdata

# Add state machine for M0
add wave -divider "M0 State Machine"
add wave -radix unsigned /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/state
add wave -radix unsigned /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/next_state
add wave -radix binary /dual_riscv_system_tb/dut/u_serv0/u_wb2axi_inst/addr_captured

# Add Wishbone signals for M1
add wave -divider "M1 Wishbone Signals"
add wave -radix hex /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/wb_adr
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/wb_cyc
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/wb_ack
add wave -radix hex /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/wb_rdt
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/i_cnt_done
add wave -radix hex /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/addr_latch
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/pending_data_valid
add wave -radix hex /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/pending_data

# Add AXI signals for M1
add wave -divider "M1 AXI Signals"
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/M_AXI_arvalid
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/M_AXI_arready
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/M_AXI_rvalid
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/M_AXI_rready
add wave -radix hex /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/M_AXI_rdata

# Add state machine for M1
add wave -divider "M1 State Machine"
add wave -radix unsigned /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/state
add wave -radix unsigned /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/next_state
add wave -radix binary /dual_riscv_system_tb/dut/u_serv1/u_wb2axi_inst/addr_captured

# Add clock and reset
add wave -divider "Clock and Reset"
add wave -radix binary /dual_riscv_system_tb/ACLK
add wave -radix binary /dual_riscv_system_tb/ARESETN

# Zoom to first 1000ns to see initial transactions
wave zoom range 0ns 1000ns

puts "Waveform signals added. Use 'wave zoom full' to see entire simulation."




