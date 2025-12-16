# ============================================================================
# ModelSim TCL Script - Set Include Directories for Project Files
# ============================================================================
# This script sets include directories for files that need them in the project
# Run this from ModelSim GUI: source set_project_incdirs.tcl
# ============================================================================

puts "============================================================================"
puts "Setting Include Directories for Project Files"
puts "============================================================================"

# Get script directory and set base paths
set SCRIPT_DIR [file dirname [file normalize [info script]]]
set ROOT_DIR [file normalize [file join $SCRIPT_DIR .. .. ..]]
set SRC_BASE [file normalize [file join $ROOT_DIR "src"]]

# Calculate relative paths from project directory
set PROJECT_DIR $SCRIPT_DIR
set REL_SRC [file normalize [file join $PROJECT_DIR .. .. .. src]]
set REL_CORES [file normalize [file join $PROJECT_DIR .. .. .. src cores]]
set REL_SERV_RTL [file normalize [file join $PROJECT_DIR .. .. .. src cores serv rtl]]
set REL_AXI_CORE [file normalize [file join $PROJECT_DIR .. .. .. src axi_interconnect rtl core]]
set REL_BRIDGE [file normalize [file join $PROJECT_DIR .. .. .. src axi_bridge]]
set REL_SYSTEMS [file normalize [file join $PROJECT_DIR .. .. .. src systems]]
set REL_PERIPH [file normalize [file join $PROJECT_DIR .. .. .. src peripherals axi_lite]]

# Convert to relative paths from project directory
set rel_src [file join .. .. .. src]
set rel_cores [file join .. .. .. src cores]
set rel_serv_rtl [file join .. .. .. src cores serv rtl]
set rel_axi_core [file join .. .. .. src axi_interconnect rtl core]
set rel_bridge [file join .. .. .. src axi_bridge]
set rel_systems [file join .. .. .. src systems]
set rel_periph [file join .. .. .. src peripherals axi_lite]

puts "Setting include directories for files that need them..."
puts ""

# Files that need include directories
set files_with_incdirs [list \
    "serv_axi_wrapper.v" \
    "dual_axi_shell.v" \
    "dual_pipeline_serv_axi_system_aggregators.v" \
    "dual_serv_axi_system.v" \
]

# Build include directories string for vlog_options
# Format: +incdir+../../src +incdir+../../src/cores ...
set incdirs_options "+incdir+$rel_src +incdir+$rel_cores +incdir+$rel_serv_rtl +incdir+$rel_axi_core +incdir+$rel_bridge +incdir+$rel_systems +incdir+$rel_periph"

puts "Include directories to set:"
puts "  +incdir+$rel_src"
puts "  +incdir+$rel_cores"
puts "  +incdir+$rel_serv_rtl"
puts "  +incdir+$rel_axi_core"
puts "  +incdir+$rel_bridge"
puts "  +incdir+$rel_systems"
puts "  +incdir+$rel_periph"
puts ""

# Note: ModelSim project file doesn't easily support setting include directories per-file
# through TCL. The best approach is to:
# 1. Set include directories in Project Settings -> Verilog tab
# 2. Or use compile scripts with +incdir+ flags

puts "============================================================================"
puts "NOTE: ModelSim project files don't support per-file include directories easily."
puts ""
puts "To set include directories for GUI compilation:"
puts "1. Go to Project -> Project Settings"
puts "2. Select Verilog tab"
puts "3. Add these to 'Include directories' field:"
puts "   $rel_src"
puts "   $rel_cores"
puts "   $rel_serv_rtl"
puts "   $rel_axi_core"
puts "   $rel_bridge"
puts "   $rel_systems"
puts "   $rel_periph"
puts ""
puts "OR use the compile script: source compile_all_with_incdirs.tcl"
puts "============================================================================"



