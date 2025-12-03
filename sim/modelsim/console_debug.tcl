# console_debug.tcl - Console debug with value checking

vsim work.dual_riscv_axi_system_tb

# Run for a bit
run 1us

# Check key signals
puts "\n========================================="
puts "Signal Values at 1us"
puts "=========================================\n"

# Check reset
set aresetn [examine /dual_riscv_axi_system_tb/ARESETN]
puts "TB ARESETN: $aresetn"

set serv_rst [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/i_rst]
puts "SERV i_rst: $serv_rst (should be 0 after reset)"

# Check SERV outputs
set ibus_cyc [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_cyc]
puts "SERV ibus_cyc: $ibus_cyc (should be 1 if fetching instructions)"

set ibus_adr [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_serv_core/o_ibus_adr]
puts "SERV ibus_adr: $ibus_adr"

# Check WB to AXI converter
set wb_cyc [examine /dual_riscv_axi_system_tb/dut/u_serv0/u_wb2axi_inst/wb_cyc]
puts "WB2AXI wb_cyc: $wb_cyc"

# Check AXI interface
set m0_arvalid [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arvalid]
puts "Master 0 arvalid: $m0_arvalid (should go high when requesting)"

set m0_arready [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_arready]
puts "Master 0 arready: $m0_arready"

set m0_araddr [examine /dual_riscv_axi_system_tb/dut/u_serv0/M0_AXI_araddr]
puts "Master 0 araddr: $m0_araddr"

# Check interconnect
set ic_arvalid [examine /dual_riscv_axi_system_tb/dut/interconnect/M0_AXI_arvalid]
puts "Interconnect M0 arvalid: $ic_arvalid"

# Check RAM
set ram_arvalid [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arvalid]
puts "RAM arvalid: $ram_arvalid"

set ram_arready [examine /dual_riscv_axi_system_tb/dut/ram_slave/S_AXI_arready]
puts "RAM arready: $ram_arready"

# Check RAM content at address 0
puts "\n========================================="
puts "RAM Content Check"
puts "=========================================\n"

# Check first few memory locations
for {set i 0} {$i < 8} {incr i} {
    set mem_val [examine -radix hex /dual_riscv_axi_system_tb/dut/ram_slave/mem($i)]
    puts "mem\[$i\] = $mem_val"
}

puts "\nDone!"
quit

