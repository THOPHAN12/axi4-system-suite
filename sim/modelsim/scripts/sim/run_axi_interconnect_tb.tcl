#######################################################################
# run_axi_interconnect_tb.tcl
#
# Compile all SystemVerilog sources for the AXI interconnect testbenches
# and run a selected top-level TB inside ModelSim/Questa.
# Usage examples:
#   vsim -c -do "source run_axi_interconnect_tb.tcl"
#   TB_TOP=Write_Arbiter_tb SIM_TIME=\"20 us\" vsim -c -do "source run_axi_interconnect_tb.tcl"
#######################################################################

# ---------------------------------------------------------------------
# Locate project root (script sits in sim/modelsim/scripts/sim)
# ---------------------------------------------------------------------
set script_file [info script]
if {$script_file eq ""} {
    set script_dir [pwd]
} else {
    set script_dir [file dirname [file normalize $script_file]]
}

set project_root [file normalize [file join $script_dir .. .. .. ..]]
if {![file exists $project_root]} {
    puts "ERROR: Project root not found: $project_root"
    quit -code 1
}

set tb_root   [file normalize [file join $project_root "tb" "interconnect_tb" "SystemVerilog_tb"]]
set file_list [file join $tb_root "tb_filelist.f"]

if {![file exists $file_list]} {
    puts "ERROR: File list not found: $file_list"
    quit -code 1
}

puts "Project root         : $project_root"
puts "SystemVerilog TB dir : $tb_root"
puts "File list            : $file_list"
puts ""

# ---------------------------------------------------------------------
# Work library setup
# ---------------------------------------------------------------------
catch {vdel -lib work -all}
vlib work
vmap work work

# ---------------------------------------------------------------------
# Compile using the SystemVerilog file list
# ---------------------------------------------------------------------
puts "==============================================================="
puts "Compiling SystemVerilog testbench sources ..."
puts "==============================================================="

# Build a temporary filelist with absolute paths so compilation works
set tmp_filelist [file normalize [file join $script_dir "tmp_axi_filelist.f"]]
set fin  [open $file_list r]
set fout [open $tmp_filelist w]
while {[gets $fin line] >= 0} {
    set trimmed [string trim $line]
    if {$trimmed eq ""} {
        puts $fout ""
        continue
    }
    if {[string match "#*" $trimmed]} {
        puts $fout $line
        continue
    }
    if {[string match "+incdir+*" $trimmed]} {
        set rel [string range $trimmed 8 end]
        if {[file pathtype $rel] eq "relative"} {
            set abs_path [file normalize [file join $tb_root $rel]]
        } else {
            set abs_path $rel
        }
        puts $fout "+incdir+$abs_path"
        continue
    }
    if {[file pathtype $trimmed] eq "relative"} {
        set abs_path [file normalize [file join $tb_root $trimmed]]
        puts $fout $abs_path
    } else {
        puts $fout $line
    }
}
close $fin
close $fout

if {[catch {vlog +acc -sv -work work -f $tmp_filelist} compile_err]} {
    puts "ERROR during compilation:"
    puts $compile_err
    file delete -force $tmp_filelist
    quit -code 1
}
file delete -force $tmp_filelist

# ---------------------------------------------------------------------
# Determine which top-level TB to simulate
# ---------------------------------------------------------------------
set default_tb "AXI_Interconnect_tb"
if {[info exists ::env(TB_TOP)] && $::env(TB_TOP) ne ""} {
    set top_tb $::env(TB_TOP)
} else {
    set top_tb $default_tb
}

if {[string match "work.*" $top_tb]} {
    set sim_target $top_tb
} else {
    set sim_target "work.$top_tb"
}

set run_cmd "-all"
if {[info exists ::env(SIM_TIME)] && $::env(SIM_TIME) ne ""} {
    set run_cmd $::env(SIM_TIME)
}

puts "==============================================================="
puts "Starting simulation:"
puts "  Top module : $sim_target"
puts "  Run cmd    : $run_cmd"
puts "==============================================================="

if {[catch {vsim -c $sim_target -do "run $run_cmd; quit -f"} sim_err]} {
    puts "ERROR during simulation:"
    puts $sim_err
    quit -code 1
}

