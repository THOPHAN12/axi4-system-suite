#==============================================================================
# create_kv260_block_design.tcl
# Create Vivado Block Design for KV260 - 2M.4S System
# Target: Xilinx Kria KV260 Vision AI Starter Kit
# Device: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
# Purpose: Create Block Design with Zynq PS + AXI Interconnect (2M × 4S)
#
# Usage: In Vivado TCL Console:
#   source create_kv260_block_design.tcl
#==============================================================================

puts "============================================================================"
puts "Create KV260 Block Design - 2M.4S System"
puts "============================================================================"
puts ""

# Get script directory and calculate paths
# Handle paths with spaces properly
if {[info script] != ""} {
    set SCRIPT_DIR [file dirname [file normalize [info script]]]
} else {
    # Fallback: use current directory
    set SCRIPT_DIR [pwd]
}
set PROJECT_ROOT [file normalize [file join $SCRIPT_DIR ".." ".." ".."]]

# Verify PROJECT_ROOT exists
if {![file exists $PROJECT_ROOT]} {
    puts "ERROR: Cannot determine project root!"
    puts "Script directory: $SCRIPT_DIR"
    puts "Calculated root: $PROJECT_ROOT"
    return
}

set PROJECT_NAME "kv260_2m4s_block_design"
set PROJECT_DIR [file normalize [file join $SCRIPT_DIR $PROJECT_NAME]]
set SV_BASE [file normalize [file join $PROJECT_ROOT "SystemVerilog"]]
set AXI_INTERCONNECT_DIR [file normalize [file join $SV_BASE "axi_interconnect"]]

puts "Script directory: $SCRIPT_DIR"
puts "Project root: $PROJECT_ROOT"
puts "Project directory: $PROJECT_DIR"
puts "SystemVerilog base: $SV_BASE"
puts "AXI Interconnect dir: $AXI_INTERCONNECT_DIR"
puts ""

#==============================================================================
# Step 1: Check/Create Vivado Project
#==============================================================================
puts "============================================================================"
puts "Step 1: Checking for Existing Project"
puts "============================================================================"

# Check if project is already open
set use_existing_project 0
if {![catch {current_project} err]} {
    set current_proj_name [current_project]
    set current_proj_dir [get_property DIRECTORY [current_project]]
    puts "Current project found: $current_proj_name"
    puts "Project directory: $current_proj_dir"
    puts ""
    puts "Using existing project - Block Design will be added to this project"
    puts ""
    set use_existing_project 1
} else {
    puts "No project currently open"
    puts "Creating new project..."
    puts ""
    
    # Remove existing project directory if exists
    if {[file exists $PROJECT_DIR]} {
        puts "Removing existing project directory..."
        file delete -force $PROJECT_DIR
    }
    
    # Create new project
    # Use file normalize to handle paths with spaces
    set PROJECT_DIR_NORM [file normalize $PROJECT_DIR]
    create_project $PROJECT_NAME $PROJECT_DIR_NORM -part xczu5ev-sfvc784-1-e -force
    
    puts "Project created: $PROJECT_NAME"
    puts "Target device: xczu5ev-sfvc784-1-e (KV260)"
    puts ""
}

# Set project properties (works for both existing and new project)
set_property target_language Verilog [current_project]
set_property default_lib xil_defaultlib [current_project]

#==============================================================================
# Step 2: Create Block Design
#==============================================================================
puts "============================================================================"
puts "Step 2: Creating Block Design"
puts "============================================================================"

# Create block design
set bd_name "design_1"

# Check if block design already exists
set current_proj_dir [get_property DIRECTORY [current_project]]
set current_proj_name [current_project]
set bd_file [file normalize [file join $current_proj_dir "${current_proj_name}.srcs" "sources_1" "bd" $bd_name "${bd_name}.bd"]]

if {[file exists $bd_file]} {
    puts "WARNING: Block Design '$bd_name' already exists!"
    puts "Opening existing block design..."
    # Use list to handle paths with spaces properly
    open_bd_design [list $bd_file]
    puts "Block Design opened: $bd_name"
} else {
    create_bd_design $bd_name
    puts "Block Design created: $bd_name"
}
puts ""

#==============================================================================
# Step 3: Add Zynq UltraScale+ Processing System
#==============================================================================
puts "============================================================================"
puts "Step 3: Adding Zynq UltraScale+ Processing System"
puts "============================================================================"

# Check if Zynq PS already exists in block design
set zynq_ps_exists [llength [get_bd_cells -quiet zynq_ultra_ps_e_0]]

if {$zynq_ps_exists > 0} {
    puts "Zynq PS IP already exists in block design"
    puts "Using existing instance: zynq_ultra_ps_e_0"
} else {
    # Add Zynq PS IP
    create_bd_cell -type ip -vlnv xilinx.com:ip:zynq_ultra_ps_e:3.5 zynq_ultra_ps_e_0
    puts "Zynq PS IP added"
}

puts ""

# Configure Zynq PS (only if newly created)
if {$zynq_ps_exists == 0} {
    puts "Configuring Zynq PS..."
    set_property -dict [list \
        CONFIG.PSU__USE__M_AXI_GP0 {1} \
        CONFIG.PSU__USE__M_AXI_GP1 {1} \
        CONFIG.PSU__USE__M_AXI_GP2 {0} \
        CONFIG.PSU__USE__S_AXI_GP0 {0} \
        CONFIG.PSU__USE__S_AXI_GP1 {0} \
        CONFIG.PSU__USE__S_AXI_GP2 {0} \
        CONFIG.PSU__USE__S_AXI_GP3 {0} \
        CONFIG.PSU__USE__S_AXI_GP4 {0} \
        CONFIG.PSU__USE__S_AXI_GP5 {0} \
        CONFIG.PSU__USE__S_AXI_GP6 {0} \
        CONFIG.PSU__USE__FIXED_IO {1} \
        CONFIG.PSU__FPGA_PL0_ENABLE {1} \
        CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ {100} \
        CONFIG.PSU__FPGA_PL1_ENABLE {0} \
        CONFIG.PSU__FPGA_PL2_ENABLE {0} \
        CONFIG.PSU__FPGA_PL3_ENABLE {0} \
    ] [get_bd_cells zynq_ultra_ps_e_0]
    
    puts "Zynq PS configured:"
    puts "  - M_AXI_GP0 enabled (Master 0)"
    puts "  - M_AXI_GP1 enabled (Master 1)"
    puts "  - PL0_REF_CLK: 100 MHz"
    puts "  - FCLK_RESET0_N enabled"
} else {
    puts "Zynq PS already configured (using existing configuration)"
}
puts ""

#==============================================================================
# Step 4: Add AXI Interconnect RTL Files to Project
#==============================================================================
puts "============================================================================"
puts "Step 4: Adding AXI Interconnect RTL Files"
puts "============================================================================"

# Check if files already added (to avoid duplicates)
set files_already_added 0
set top_file_check [file normalize [file join $AXI_INTERCONNECT_DIR "core" "AXI_Interconnect.sv"]]
# Use list to handle paths with spaces, check in current fileset
if {[llength [get_files -quiet [list $top_file_check]]] > 0} {
    puts "AXI Interconnect files already exist in project"
    puts "Skipping file addition to avoid duplicates"
    set files_already_added 1
}

if {!$files_already_added} {
    # Add all AXI Interconnect SystemVerilog files to sources_1
    set axi_files [list \
    [file join $AXI_INTERCONNECT_DIR "utils" "Faling_Edge_Detc.sv"] \
    [file join $AXI_INTERCONNECT_DIR "utils" "Raising_Edge_Det.sv"] \
    [file join $AXI_INTERCONNECT_DIR "buffers" "Queue.sv"] \
    [file join $AXI_INTERCONNECT_DIR "buffers" "Resp_Queue.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "AW_HandShake_Checker.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "WD_HandShake.sv"] \
    [file join $AXI_INTERCONNECT_DIR "handshake" "WR_HandShake.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_fixed_priority.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_round_robin.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "arbiter_qos_based.sv"] \
    [file join $AXI_INTERCONNECT_DIR "arbitration" "algorithms" "read_arbiter.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_2x1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_2x1_en.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "Mux_4x1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "AW_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "BReady_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "mux" "WD_MUX_2_1.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x2.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x2_en.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1x4.sv"] \
    [file join $AXI_INTERCONNECT_DIR "datapath" "demux" "Demux_1_2.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Addr_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Read_Addr_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Resp_Channel_Dec.sv"] \
    [file join $AXI_INTERCONNECT_DIR "decoders" "Write_Resp_Channel_Arb.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "read" "Controller.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "read" "AR_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "AW_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "WD_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "channel_controllers" "write" "BR_Channel_Controller_Top.sv"] \
    [file join $AXI_INTERCONNECT_DIR "core" "AXI_Interconnect_Full.sv"] \
    [file join $AXI_INTERCONNECT_DIR "core" "AXI_Interconnect.sv"] \
]

    set files_added 0
    foreach file $axi_files {
        set full_path [file normalize $file]
        if {[file exists $full_path]} {
            # Check if file already exists in project (use list to handle paths with spaces)
            set existing_files [get_files -quiet [list $full_path]]
            if {[llength $existing_files] == 0} {
                # Use list to handle paths with spaces properly
                add_files -fileset sources_1 -norecurse [list $full_path]
                # Use list when getting files to handle paths with spaces
                set file_obj [get_files -quiet [list $full_path]]
                if {[llength $file_obj] > 0} {
                    set_property file_type {SystemVerilog} $file_obj
                }
                incr files_added
                puts "  Added: [file tail $full_path]"
            } else {
                puts "  Skipped (already exists): [file tail $full_path]"
            }
        } else {
            puts "  WARNING: File not found: $full_path"
        }
    }

    puts ""
    puts "Added $files_added AXI Interconnect files"
    puts ""
    
    # Update compile order
    update_compile_order -fileset sources_1
    
    puts "Compile order updated"
    puts ""
} else {
    puts "Using existing AXI Interconnect files in project"
    puts ""
}

#==============================================================================
# Step 5: Create AXI Interconnect Instance in Block Design
#==============================================================================
puts "============================================================================"
puts "Step 5: Creating AXI Interconnect Instance in Block Design"
puts "============================================================================"

# Check if AXI Interconnect already exists in block design
set axi_ic_exists [llength [get_bd_cells -quiet axi_interconnect_0]]

if {$axi_ic_exists > 0} {
    puts "AXI Interconnect instance already exists in block design"
    puts "Using existing instance: axi_interconnect_0"
} else {
    # Create AXI Interconnect module instance from RTL
    # Note: This requires the module to be compiled first
    # We'll use create_bd_cell with module reference
    create_bd_cell -type module -reference AXI_Interconnect axi_interconnect_0
    
    # Set arbitration mode parameter (1 = ROUND_ROBIN)
    set_property CONFIG.ARBITRATION_MODE {1} [get_bd_cells axi_interconnect_0]
    
    puts "AXI Interconnect instance created: axi_interconnect_0"
    puts "  Arbitration Mode: ROUND_ROBIN (1)"
}
puts ""

#==============================================================================
# Step 6: Add AXI SmartConnect IPs (for protocol conversion if needed)
#==============================================================================
puts "============================================================================"
puts "Step 6: Adding AXI SmartConnect IPs"
puts "============================================================================"

# Check if SmartConnect IPs already exist
set sc0_exists [llength [get_bd_cells -quiet smartconnect_0]]
set sc1_exists [llength [get_bd_cells -quiet smartconnect_1]]

if {$sc0_exists > 0} {
    puts "SmartConnect_0 already exists"
} else {
    # Add AXI SmartConnect for Master 0 (PS -> Interconnect)
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0
    set_property -dict [list \
        CONFIG.NUM_SI {1} \
        CONFIG.NUM_MI {1} \
    ] [get_bd_cells smartconnect_0]
    puts "SmartConnect_0 added"
}

if {$sc1_exists > 0} {
    puts "SmartConnect_1 already exists"
} else {
    # Add AXI SmartConnect for Master 1 (PS -> Interconnect)
    create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_1
    set_property -dict [list \
        CONFIG.NUM_SI {1} \
        CONFIG.NUM_MI {1} \
    ] [get_bd_cells smartconnect_1]
    puts "SmartConnect_1 added"
}

puts "AXI SmartConnect IPs ready (for protocol conversion)"
puts ""

#==============================================================================
# Step 7: Connect Clock and Reset
#==============================================================================
puts "============================================================================"
puts "Step 7: Connecting Clock and Reset"
puts "============================================================================"

# Create clock port
create_bd_port -dir I -type clk pl_clk0
set_property CONFIG.FREQ_HZ 100000000 [get_bd_ports pl_clk0]

# Create reset port
create_bd_port -dir I -type rst pl_resetn0
set_property CONFIG.POLARITY ACTIVE_LOW [get_bd_ports pl_resetn0]

# Connect clock from Zynq PS
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_ports pl_clk0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins smartconnect_0/aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins smartconnect_1/aclk]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_clk0] [get_bd_pins axi_interconnect_0/ACLK]

# Connect reset from Zynq PS
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_ports pl_resetn0]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins smartconnect_0/aresetn]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins smartconnect_1/aresetn]
connect_bd_net [get_bd_pins zynq_ultra_ps_e_0/pl_resetn0] [get_bd_pins axi_interconnect_0/ARESETN]

puts "Clock and Reset connected:"
puts "  - pl_clk0 (100 MHz) -> All components"
puts "  - pl_resetn0 -> All components"
puts ""

#==============================================================================
# Step 8: Connect AXI Buses
#==============================================================================
puts "============================================================================"
puts "Step 8: Connecting AXI Buses"
puts "============================================================================"

# Connect Master 0: PS -> SmartConnect -> AXI Interconnect
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM0_FPD] [get_bd_intf_pins smartconnect_0/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_interconnect_0/M0_AXI]

# Connect Master 1: PS -> SmartConnect -> AXI Interconnect  
connect_bd_intf_net [get_bd_intf_pins zynq_ultra_ps_e_0/M_AXI_HPM1_FPD] [get_bd_intf_pins smartconnect_1/S00_AXI]
connect_bd_intf_net [get_bd_intf_pins smartconnect_1/M00_AXI] [get_bd_intf_pins axi_interconnect_0/M1_AXI]

puts "AXI Buses connected:"
puts "  - M_AXI_HPM0_FPD -> SmartConnect_0 -> AXI_Interconnect M0"
puts "  - M_AXI_HPM1_FPD -> SmartConnect_1 -> AXI_Interconnect M1"
puts ""

# Note: Slave connections - we'll create external ports for now
# These can be connected to IP peripherals later
puts "Creating external ports for 4 slaves..."

# Slave 0 (RAM) - AXI4 Full
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axi_rtl:1.0 S0_AXI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S0_AXI] [get_bd_intf_ports S0_AXI]

# Slave 1 (GPIO) - AXI4-Lite  
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axi_rtl:1.0 S1_AXI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S1_AXI] [get_bd_intf_ports S1_AXI]

# Slave 2 (UART) - AXI4-Lite
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axi_rtl:1.0 S2_AXI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S2_AXI] [get_bd_intf_ports S2_AXI]

# Slave 3 (SPI) - AXI4-Lite
create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axi_rtl:1.0 S3_AXI
connect_bd_intf_net [get_bd_intf_pins axi_interconnect_0/S3_AXI] [get_bd_intf_ports S3_AXI]

puts "External ports created for 4 slaves"
puts "  Note: These can be connected to AXI IP peripherals (BRAM, GPIO, UART, SPI) later"
puts ""

#==============================================================================
# Step 9: Set Address Map
#==============================================================================
puts "============================================================================"
puts "Step 9: Setting Address Map"
puts "============================================================================"

# Assign address ranges for the 4 slaves
# Note: This will be done in Address Editor after validation
puts "Address Map (to be set in Address Editor):"
puts "  - S0 (RAM):     0x0000_0000 - 0x1FFF_FFFF"
puts "  - S1 (GPIO):    0x4000_0000 - 0x5FFF_FFFF"
puts "  - S2 (UART):    0x8000_0000 - 0x9FFF_FFFF"
puts "  - S3 (SPI):     0xC000_0000 - 0xDFFF_FFFF"
puts ""

#==============================================================================
# Step 10: Validate Block Design
#==============================================================================
puts "============================================================================"
puts "Step 10: Validating Block Design"
puts "============================================================================"

# Validate the block design
validate_bd_design

puts "Block Design validation completed"
puts ""

#==============================================================================
# Step 11: Save Block Design
#==============================================================================
puts "============================================================================"
puts "Step 11: Saving Block Design"
puts "============================================================================"

save_bd_design

puts "Block Design saved"
puts ""

#==============================================================================
# Step 12: Generate Block Design
#==============================================================================
puts "============================================================================"
puts "Step 12: Generating Block Design"
puts "============================================================================"

# Generate block design
generate_target all [get_files $bd_name.bd]

puts "Block Design generation completed"
puts ""

#==============================================================================
# Step 13: Create HDL Wrapper
#==============================================================================
puts "============================================================================"
puts "Step 13: Creating HDL Wrapper"
puts "============================================================================"

# Make wrapper
make_wrapper -files [get_files $bd_name.bd] -top

# Get current project name and directory for wrapper path
set current_proj_name [current_project]
set current_proj_dir [get_property DIRECTORY [current_project]]
set wrapper_path [file normalize [file join $current_proj_dir "${current_proj_name}.srcs" "sources_1" "bd" $bd_name "hdl" "${bd_name}_wrapper.v"]]

if {[file exists $wrapper_path]} {
    # Use list to handle paths with spaces properly
    add_files -norecurse [list $wrapper_path]
    update_compile_order -fileset sources_1
} else {
    puts "WARNING: Wrapper file not found at expected path: $wrapper_path"
    puts "You may need to create wrapper manually"
}

# Set wrapper as top
set_property top ${bd_name}_wrapper [current_fileset]

puts "HDL Wrapper created and set as top: ${bd_name}_wrapper"
puts ""

#==============================================================================
# Step 14: Add Constraints
#==============================================================================
puts "============================================================================"
puts "Step 14: Adding Constraints"
puts "============================================================================"

set constraints_file [file normalize [file join $PROJECT_ROOT "synthesis" "constraints" "axi_interconnect.xdc"]]
if {[file exists $constraints_file]} {
    # Use list to handle paths with spaces properly
    add_files -fileset constrs_1 -norecurse [list $constraints_file]
    puts "Constraints file added: [file tail $constraints_file]"
} else {
    puts "WARNING: Constraints file not found: $constraints_file"
}

puts ""

#==============================================================================
# Summary
#==============================================================================
puts "============================================================================"
puts "Block Design Creation Complete!"
puts "============================================================================"
puts ""
if {$use_existing_project} {
    puts "Summary:"
    puts "  - Project: [current_project] (existing project)"
    puts "  - Block Design: $bd_name"
    puts "  - Zynq PS: Configured with 2 AXI Masters (HPM0, HPM1)"
    puts "  - Clock: 100 MHz (pl_clk0)"
    puts "  - AXI Interconnect: 2M × 4S"
    puts "  - Top Module: ${bd_name}_wrapper"
} else {
    puts "Summary:"
    puts "  - Project: $PROJECT_NAME (newly created)"
    puts "  - Block Design: $bd_name"
    puts "  - Zynq PS: Configured with 2 AXI Masters (HPM0, HPM1)"
    puts "  - Clock: 100 MHz (pl_clk0)"
    puts "  - AXI Interconnect: 2M × 4S"
    puts "  - Top Module: ${bd_name}_wrapper"
}
puts ""
puts "Next Steps (IMPORTANT - Manual Completion Required):"
puts ""
puts "1. Open Block Design:"
puts "   - Flow Navigator -> IP Integrator -> Open Block Design"
puts "   - Or double-click design_1.bd in Sources window"
puts ""
puts "2. Complete AXI Connections (CRITICAL):"
puts "   - Connect SmartConnect_0/M00_AXI -> AXI_Interconnect M0 signals"
puts "     (You may need to use individual signal connections)"
puts "   - Connect SmartConnect_1/M00_AXI -> AXI_Interconnect M1 signals"
puts "   - Create external ports for S0, S1, S2, S3"
puts "   - Or connect directly to AXI IP peripherals"
puts ""
puts "3. Add Peripherals (Optional but Recommended):"
puts "   - Add AXI BRAM Controller for S0 (RAM)"
puts "   - Add AXI GPIO for S1"
puts "   - Add AXI UART Lite for S2"
puts "   - Add AXI Quad SPI for S3"
puts ""
puts "4. Set Address Map:"
puts "   - Open Address Editor tab"
puts "   - Set address ranges:"
puts "     * S0: 0x0000_0000 - 0x1FFF_FFFF"
puts "     * S1: 0x4000_0000 - 0x5FFF_FFFF"
puts "     * S2: 0x8000_0000 - 0x9FFF_FFFF"
puts "     * S3: 0xC000_0000 - 0xDFFF_FFFF"
puts ""
puts "5. Validate Block Design:"
puts "   - Click Validate Design (F6)"
puts "   - Fix any errors or warnings"
puts ""
puts "6. Regenerate Block Design:"
puts "   - Right-click -> Regenerate Block Design"
puts ""
puts "7. Generate Output Products:"
puts "   - Right-click -> Generate Output Products"
puts ""
puts "8. Create HDL Wrapper (if not done):"
puts "   - Right-click -> Create HDL Wrapper"
puts ""
puts "9. Run Synthesis and Implementation:"
puts "   - Flow Navigator -> Synthesis -> Run Synthesis"
puts "   - Flow Navigator -> Implementation -> Run Implementation"
puts "   - Flow Navigator -> Program and Debug -> Generate Bitstream"
puts ""
puts "============================================================================"
puts ""
puts "For detailed instructions, see: README_BLOCK_DESIGN.md"
puts ""

