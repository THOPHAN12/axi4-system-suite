# ============================================================================
# TCL Script de chay simulation SERV AXI System trong ModelSim
# ============================================================================
# Script nay se:
# 1. Kiem tra xem da compile chua (neu chua thi bao loi)
# 2. Load top-level module
# 3. Add waves
# 4. Run simulation
# ============================================================================

# Load top-level module
# Neu module chua compile, vsim se bao loi
puts "\n============================================================================"
puts "Loading simulation..."
puts "============================================================================"
puts "Note: Neu co loi 'Could not find', vui long chay compile truoc:"
puts "  source compile_and_sim.tcl"
puts "============================================================================\n"

vsim -t ps work.serv_axi_system_tb -voptargs=+acc

# Add waves - Top level
add wave -radix hex /serv_axi_system_tb/ACLK
add wave -radix hex /serv_axi_system_tb/ARESETN
add wave -radix hex /serv_axi_system_tb/i_timer_irq

# Add waves - Instruction Memory Interface
add wave -radix hex /serv_axi_system_tb/M00_AXI_araddr
add wave -radix hex /serv_axi_system_tb/M00_AXI_arvalid
add wave -radix hex /serv_axi_system_tb/M00_AXI_arready
add wave -radix hex /serv_axi_system_tb/M00_AXI_rdata
add wave -radix hex /serv_axi_system_tb/M00_AXI_rvalid
add wave -radix hex /serv_axi_system_tb/M00_AXI_rready

# Add waves - Data Memory Interface
add wave -radix hex /serv_axi_system_tb/M01_AXI_awaddr
add wave -radix hex /serv_axi_system_tb/M01_AXI_awvalid
add wave -radix hex /serv_axi_system_tb/M01_AXI_awready
add wave -radix hex /serv_axi_system_tb/M01_AXI_wdata
add wave -radix hex /serv_axi_system_tb/M01_AXI_wvalid
add wave -radix hex /serv_axi_system_tb/M01_AXI_wready
add wave -radix hex /serv_axi_system_tb/M01_AXI_araddr
add wave -radix hex /serv_axi_system_tb/M01_AXI_arvalid
add wave -radix hex /serv_axi_system_tb/M01_AXI_arready
add wave -radix hex /serv_axi_system_tb/M01_AXI_rdata
add wave -radix hex /serv_axi_system_tb/M01_AXI_rvalid
add wave -radix hex /serv_axi_system_tb/M01_AXI_rready

# Add waves - SERV Wrapper (Processor)
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_ibus_adr
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_ibus_cyc
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_ibus_rdt
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_ibus_ack
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_dbus_adr
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_dbus_cyc
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_dbus_dat
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_dbus_rdt
add wave -radix hex /serv_axi_system_tb/u_dut/u_serv_wrapper/wb_dbus_ack

# Add waves - AXI Interconnect (optional, can be expanded)
# add wave -radix hex /serv_axi_system_tb/u_dut/u_axi_interconnect/*

# Run simulation
run -all

# ============================================================================
# Huong dan phan tich ket qua:
# ============================================================================
# 1. Kiem tra Memory Load:
#    - Tim dong "INFO: Loaded memory from file"
#    - Kiem tra "Memory[0] = 0x00500093" (addi x1, x0, 5)
#    - Kiem tra "Memory[1] = 0x00A00113" (addi x2, x0, 10)
#
# 2. Kiem tra Instruction Fetch:
#    - PC co the bat dau tu 0x0 hoac bit-serial format (0x20006000...)
#    - Sau khi fix address mapping, address phai la 0x0, 0x4, 0x8, 0xc...
#    - Instructions phai la 0x00500093, 0x00A00113, 0x002081B3...
#
# 3. Kiem tra AXI Interconnect:
#    - Address routing: M00_AXI_araddr phai route den Instruction Memory
#    - Data routing: M00_AXI_rdata phai tra ve instructions dung
#
# 4. Kiem tra Processor:
#    - PC phai increment dung
#    - Instructions phai duoc decode va execute
# ============================================================================

