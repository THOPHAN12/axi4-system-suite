# ==============================================================================
# Compile Quartus Project - Full Compilation Flow
# ==============================================================================
# Description: Runs full compilation flow for AXI Interconnect System
# Usage: quartus_sh -t compile_project.tcl
#        OR: quartus_sh --flow compile AXI_Interconnect_System
# ==============================================================================

set project_name "AXI_Interconnect_System"

# Path configuration
set script_dir [file normalize [file dirname [info script]]]
set project_root [file normalize [file join $script_dir .. .. ..]]
set project_dir [file join $project_root "synthesis" "quartus"]

puts "\n===================================================================="
puts "Compiling Quartus Project"
puts "===================================================================="
puts "Project: $project_name"
puts "Directory: $project_dir"
puts "====================================================================\n"

cd $project_dir

# ==============================================================================
# COMPILATION FLOW
# ==============================================================================

puts "\n[1/5] Analysis & Synthesis..."
puts "--------------------------------------------------------------------"
if {[catch {exec quartus_map $project_name} result]} {
    puts "✗ Analysis & Synthesis FAILED"
    puts $result
    exit 1
} else {
    puts "✓ Analysis & Synthesis completed"
}

puts "\n[2/5] Fitter (Place & Route)..."
puts "--------------------------------------------------------------------"
if {[catch {exec quartus_fit $project_name} result]} {
    puts "✗ Fitter FAILED"
    puts $result
    exit 1
} else {
    puts "✓ Fitter completed"
}

puts "\n[3/5] Assembler (Generate Programming File)..."
puts "--------------------------------------------------------------------"
if {[catch {exec quartus_asm $project_name} result]} {
    puts "✗ Assembler FAILED"
    puts $result
    exit 1
} else {
    puts "✓ Assembler completed"
}

puts "\n[4/5] TimeQuest Timing Analyzer..."
puts "--------------------------------------------------------------------"
if {[catch {exec quartus_sta $project_name} result]} {
    puts "⚠ Timing Analysis had warnings (check report)"
    puts $result
} else {
    puts "✓ Timing Analysis completed"
}

puts "\n[5/5] Generating Reports..."
puts "--------------------------------------------------------------------"

# ==============================================================================
# EXTRACT KEY INFORMATION FROM REPORTS
# ==============================================================================

set flow_report [file join $project_dir "output_files" "${project_name}.flow.rpt"]
set fit_report [file join $project_dir "output_files" "${project_name}.fit.summary"]
set sta_report [file join $project_dir "output_files" "${project_name}.sta.summary"]

puts "\n===================================================================="
puts "COMPILATION SUMMARY"
puts "===================================================================="

# Read and display fit summary
if {[file exists $fit_report]} {
    set fp [open $fit_report r]
    set fit_content [read $fp]
    close $fp
    
    # Extract key metrics
    if {[regexp {Total logic elements\s*:\s*([0-9,]+)} $fit_content match logic_elements]} {
        puts "Logic Elements: $logic_elements"
    }
    if {[regexp {Total registers\s*:\s*([0-9,]+)} $fit_content match registers]} {
        puts "Registers: $registers"
    }
    if {[regexp {Total memory bits\s*:\s*([0-9,]+)} $fit_content match memory]} {
        puts "Memory Bits: $memory"
    }
    if {[regexp {Total multiplier.*:\s*([0-9,]+)} $fit_content match mult]} {
        puts "Multipliers: $mult"
    }
}

# Read and display timing summary
if {[file exists $sta_report]} {
    set fp [open $sta_report r]
    set sta_content [read $fp]
    close $fp
    
    puts "\nTiming:"
    if {[regexp {Fmax\s*:\s*([\d.]+)\s*MHz} $sta_content match fmax]} {
        puts "  Fmax: $fmax MHz"
    }
    if {[regexp {Setup\s*:\s*([\d.]+)\s*ns} $sta_content match setup]} {
        puts "  Setup: $setup ns"
    }
    if {[regexp {Hold\s*:\s*([\d.]+)\s*ns} $sta_content match hold]} {
        puts "  Hold: $hold ns"
    }
}

puts "\n===================================================================="
puts "Output Files:"
puts "  Programming File (SOF): output_files/${project_name}.sof"
puts "  Programming File (POF): output_files/${project_name}.pof (if generated)"
puts "  Reports: output_files/*.rpt"
puts "===================================================================="

puts "\n✓ Compilation completed successfully!"
puts "\nNext steps:"
puts "  1. Review reports in output_files/ directory"
puts "  2. Program FPGA: quartus_pgm -c USB-Blaster -m jtag -o \"p;output_files/${project_name}.sof\""
puts "  3. Check timing report for timing violations"
puts "====================================================================\n"

exit 0

