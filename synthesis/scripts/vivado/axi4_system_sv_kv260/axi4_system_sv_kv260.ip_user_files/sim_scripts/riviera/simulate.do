transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

asim +access +r +m+comprehensive_system_tb  -L xil_defaultlib -L xilinx_vip -L xilinx_vip -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.comprehensive_system_tb xil_defaultlib.glbl

do {comprehensive_system_tb.udo}

run 1000ns

endsim

quit -force
