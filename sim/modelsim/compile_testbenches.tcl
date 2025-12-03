# File: compile_testbenches.tcl
# Compile all individual module testbenches

puts "=========================================="
puts "Compiling Individual Module Testbenches"
puts "=========================================="

set compiled 0
set failed 0

# Utils testbenches
puts "\n\[1\] Compiling Utils Testbenches..."
set utils_tbs [list \
    "../../tb/utils_tb/edge_detectors/Raising_Edge_Det_tb.v" \
    "../../tb/utils_tb/edge_detectors/Faling_Edge_Detc_tb.v" \
    "../../tb/utils_tb/mux_demux/Mux_2x1_tb.v" \
    "../../tb/utils_tb/mux_demux/Demux_1_2_tb.v" \
    "../../tb/utils_tb/mux_demux/Demux_1x2_tb.v" \
    "../../tb/utils_tb/mux_demux/Mux_2x1_en_tb.v" \
    "../../tb/utils_tb/mux_demux/Demux_1x2_en_tb.v" \
    "../../tb/utils_tb/mux_demux/BReady_MUX_2_1_tb.v" \
]

foreach tb $utils_tbs {
    if {[catch {vlog $tb} result]} {
        puts "ERROR: $tb"
        incr failed
    } else {
        incr compiled
    }
}

# Interconnect testbenches
puts "\n\[2\] Compiling Interconnect Testbenches..."
set interconnect_tbs [list \
    "../../tb/interconnect_tb/Verilog_tb/buffers/Queue_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/buffers/Resp_Queue_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/arbitration/Write_Arbiter_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/arbitration/Write_Arbiter_RR_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/arbitration/Qos_Arbiter_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/decoders/Write_Addr_Channel_Dec_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/decoders/Write_Resp_Channel_Dec_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/handshake/AW_HandShake_Checker_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/handshake/WD_HandShake_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/handshake/WR_HandShake_tb.v" \
]

foreach tb $interconnect_tbs {
    if {[catch {vlog $tb} result]} {
        puts "ERROR: $tb"
        incr failed
    } else {
        incr compiled
    }
}

# Datapath testbenches
puts "\n\[3\] Compiling Datapath Testbenches..."
set datapath_tbs [list \
    "../../tb/interconnect_tb/Verilog_tb/datapath/mux/AW_MUX_2_1_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/datapath/mux/WD_MUX_2_1_tb.v" \
]

foreach tb $datapath_tbs {
    if {[catch {vlog $tb} result]} {
        puts "ERROR: $tb"
        incr failed
    } else {
        incr compiled
    }
}

# Channel Controllers
puts "\n\[4\] Compiling Channel Controller Testbenches..."
set ctrl_tbs [list \
    "../../tb/interconnect_tb/Verilog_tb/channel_controllers/write/AW_Channel_Controller_Top_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/channel_controllers/write/WD_Channel_Controller_Top_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/channel_controllers/write/BR_Channel_Controller_Top_tb.v" \
    "../../tb/interconnect_tb/Verilog_tb/channel_controllers/read/Controller_tb.v" \
]

foreach tb $ctrl_tbs {
    if {[catch {vlog $tb} result]} {
        puts "ERROR: $tb"
        incr failed
    } else {
        incr compiled
    }
}

# Full interconnect test
puts "\n\[5\] Compiling Full Interconnect Testbench..."
if {[catch {vlog ../../tb/interconnect_tb/Verilog_tb/AXI_Interconnect_tb.v} result]} {
    puts "ERROR: AXI_Interconnect_tb.v"
    incr failed
} else {
    incr compiled
}

puts "\n=========================================="
puts "Testbench Compilation Summary"
puts "=========================================="
puts "Compiled: $compiled testbenches"
puts "Failed:   $failed testbenches"
puts "=========================================="

if {$failed == 0} {
    puts "ALL TESTBENCHES COMPILED SUCCESSFULLY!"
} else {
    puts "Some testbenches failed to compile"
}

