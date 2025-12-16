# Quick test simulation script
set ROOT_DIR [file normalize [file join [pwd] .. .. ..]]
set HEX_FILE [file normalize [file join $ROOT_DIR "verification" "programs" "dual_core_test.hex"]]

cd [file dirname [info script]]

# Start simulation
vsim -voptargs=+acc work.dual_riscv_system_tb -G RAM_INIT_HEX=$HEX_FILE -t 1ps

# Run for 5us
run 5000ns

# Exit
quit -f


