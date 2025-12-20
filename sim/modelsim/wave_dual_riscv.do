#==============================================================================
# wave_dual_riscv.do
# Wave Configuration for Dual RISC-V System Simulation
# 
# This file configures the waveform display in ModelSim for debugging
# the dual RISC-V system with AXI interconnect and 4 slaves.
#==============================================================================

onerror {resume}
quietly WaveActivateNextPane {} 0

#==============================================================================
# Top-level Signals
#==============================================================================
add wave -noupdate -divider -height 30 "Clock and Reset"
add wave -noupdate -format Logic /dual_riscv_system_tb/ACLK
add wave -noupdate -format Logic /dual_riscv_system_tb/ARESETN
add wave -noupdate -format Literal -radix unsigned /dual_riscv_system_tb/cycle_count

#==============================================================================
# UART Interface
#==============================================================================
add wave -noupdate -divider -height 30 "UART Output"
add wave -noupdate -format Logic /dual_riscv_system_tb/uart_tx_valid
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/uart_tx_byte
add wave -noupdate -format Literal -radix ascii /dual_riscv_system_tb/uart_tx_byte
add wave -noupdate -format Literal -radix unsigned /dual_riscv_system_tb/uart_char_count

#==============================================================================
# GPIO Interface
#==============================================================================
add wave -noupdate -divider -height 30 "GPIO"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/gpio_in
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/gpio_out

#==============================================================================
# SPI Interface
#==============================================================================
add wave -noupdate -divider -height 30 "SPI"
add wave -noupdate -format Logic /dual_riscv_system_tb/spi_cs_n
add wave -noupdate -format Logic /dual_riscv_system_tb/spi_sclk
add wave -noupdate -format Logic /dual_riscv_system_tb/spi_mosi
add wave -noupdate -format Logic /dual_riscv_system_tb/spi_miso
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/spi_shift_reg
add wave -noupdate -format Literal -radix unsigned /dual_riscv_system_tb/spi_bit_count

#==============================================================================
# SERV Core 0 - Wishbone Buses
#==============================================================================
add wave -noupdate -divider -height 30 "SERV Core 0 - Instruction Bus"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_ibus_adr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/u_serv0/wb_ibus_cyc
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_ibus_rdt
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/u_serv0/wb_ibus_ack

add wave -noupdate -divider -height 20 "SERV Core 0 - Data Bus"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_dbus_adr
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_dbus_dat
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_dbus_sel
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/u_serv0/wb_dbus_we
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/u_serv0/wb_dbus_cyc
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_serv0/wb_dbus_rdt
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/u_serv0/wb_dbus_ack

#==============================================================================
# SERV Core 0 - AXI Master Interface (after adapter)
#==============================================================================
add wave -noupdate -divider -height 30 "SERV Core 0 - AXI Master (Combined)"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_awaddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_awvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_awready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_wdata
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_wstrb
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_wvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_wready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_bresp
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_bvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_bready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_araddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_arvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_arready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_rdata
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv0_axi_rresp
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_rvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv0_axi_rready

#==============================================================================
# SERV Core 1 - AXI Master Interface
#==============================================================================
add wave -noupdate -divider -height 30 "SERV Core 1 - AXI Master (Combined)"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv1_axi_araddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv1_axi_arvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv1_axi_arready
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/serv1_axi_rdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv1_axi_rvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/serv1_axi_rready

#==============================================================================
# AXI Interconnect - Slave 0 (RAM)
#==============================================================================
add wave -noupdate -divider -height 30 "AXI Slave 0 - RAM"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S0_awaddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_awvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_awready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S0_wdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_wvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_wready

add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_bvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_bready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S0_araddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_arvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_arready

add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S0_rdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_rvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S0_rready

#==============================================================================
# AXI Interconnect - Slave 1 (GPIO)
#==============================================================================
add wave -noupdate -divider -height 30 "AXI Slave 1 - GPIO"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S1_awaddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S1_awvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S1_awready
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S1_wdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S1_wvalid

#==============================================================================
# AXI Interconnect - Slave 2 (UART)
#==============================================================================
add wave -noupdate -divider -height 30 "AXI Slave 2 - UART"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S2_awaddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S2_awvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S2_awready
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S2_wdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S2_wvalid

#==============================================================================
# AXI Interconnect - Slave 3 (SPI)
#==============================================================================
add wave -noupdate -divider -height 30 "AXI Slave 3 - SPI"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S3_awaddr
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S3_awvalid
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S3_awready
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/S3_wdata
add wave -noupdate -format Logic /dual_riscv_system_tb/dut/S3_wvalid

#==============================================================================
# RAM Contents (first few words)
#==============================================================================
add wave -noupdate -divider -height 30 "RAM Contents"
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_sram/mem(0)
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_sram/mem(1)
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_sram/mem(2)
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_sram/mem(3)
add wave -noupdate -format Literal -radix hexadecimal /dual_riscv_system_tb/dut/u_sram/mem(4)

#==============================================================================
# Wave Window Configuration
#==============================================================================
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1000 ns}

