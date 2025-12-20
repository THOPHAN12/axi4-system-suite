#==============================================================================
# run_arbitration_monitor.tcl
# Monitor AXI arbitration patterns
#==============================================================================

set SCRIPT_DIR [file dirname [file normalize [info script]]]
set PROJECT_DIR $SCRIPT_DIR
set ROOT_DIR_TMP [file join $SCRIPT_DIR .. .. ..]
set ROOT_DIR [file normalize $ROOT_DIR_TMP]

set VERIF_BASE [file normalize [file join $ROOT_DIR "verification"]]
set TB_FILE [file normalize [file join $VERIF_BASE "testbenches" "system_tb" "arbitration_monitor_tb.v"]]
set HEX_FILE [file normalize [file join $VERIF_BASE "programs" "arbitration_test_simple.hex"]]

puts "============================================================================"
puts "AXI Arbitration Monitor"
puts "============================================================================"
puts "Testbench: $TB_FILE"
puts "Test program: $HEX_FILE"
puts ""

cd $PROJECT_DIR

if {![file exists [file join $PROJECT_DIR "work"]]} {
    puts "Compiling design..."
    source [file join $PROJECT_DIR "compile_dual_riscv_files.tcl"]
}

puts "Compiling testbench..."
vlog -work work [string map {\\ /} $TB_FILE]

catch {quit -sim}

puts "Starting simulation..."
vsim -voptargs=+acc work.arbitration_monitor_tb -G RAM_INIT_HEX=[string map {\\ /} $HEX_FILE] -t 1ps

puts "Running simulation..."
puts "============================================================================"
puts ""

run -all

puts ""
puts "============================================================================"
puts "Simulation completed!"
puts "============================================================================"

quit -sim

