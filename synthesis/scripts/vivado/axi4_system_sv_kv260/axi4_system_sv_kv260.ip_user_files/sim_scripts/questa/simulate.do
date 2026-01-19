onbreak {quit -f}
onerror {quit -f}

vsim  -lib xil_defaultlib comprehensive_system_tb_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {comprehensive_system_tb.udo}

run 1000ns

quit -force
