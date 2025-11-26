puts "==============================================="
puts "Running dual_riscv_axi_system_tb (ModelSim)"
puts "==============================================="

set root "D:/AXI"
set workdir "$root/sim/modelsim/work"

if {[file exists $workdir]} {
    file delete -force $workdir
}
vlib $workdir
vmap work $workdir

set serv_core_files {
    serv_state.v
    serv_immdec.v
    serv_compdec.v
    serv_decode.v
    serv_alu.v
    serv_ctrl.v
    serv_csr.v
    serv_bufreg.v
    serv_bufreg2.v
    serv_aligner.v
    serv_mem_if.v
    serv_rf_if.v
    serv_rf_ram_if.v
    serv_rf_ram.v
    serv_rf_top.v
    serv_top.v
}

foreach file $serv_core_files {
    vlog +acc "$root/src/cores/serv/rtl/$file"
}

set compile_list {
    src/wrapper/converters/wb2axi_read.v
    src/wrapper/converters/wb2axi_write.v
    src/wrapper/converters/serv_axi_wrapper.v
    src/wrapper/converters/serv_axi_dualbus_adapter.v
    src/peripherals/axi_lite/axi_lite_ram.v
    src/peripherals/axi_lite/axi_lite_gpio.v
    src/peripherals/axi_lite/axi_lite_uart.v
    src/peripherals/axi_lite/axi_lite_spi.v
    src/axi_interconnect/rtl/arbitration/axi_rr_interconnect_2x4.v
    src/wrapper/systems/dual_riscv_axi_system.v
    tb/wrapper_tb/testbenches/dual_master/dual_riscv_axi_system_tb.sv
}

foreach relpath $compile_list {
    set fullpath "$root/$relpath"
    vlog +acc $fullpath
}

vsim -c work.dual_riscv_axi_system_tb \
    -do "run 5000 us; quit -f"

