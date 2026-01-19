################################################################################
# AXI Interconnect Constraints File
# Target: Xilinx KV260 (Kria Vision AI Starter Kit)
# Device: xczu5ev-sfvc784-1-e (Zynq UltraScale+)
# Clock Domain: Single clock domain (ACLK)
# Typical AXI Clock: 100MHz - 200MHz
################################################################################

################################################################################
# Clock Constraints
################################################################################

# Primary AXI Clock - 100MHz (10ns period)
# This is a common frequency for AXI4 interfaces on KV260
# Adjust if your system uses a different frequency:
#   - 150MHz: -period 6.667
#   - 200MHz: -period 5.000
#   - 250MHz: -period 4.000
create_clock -period 10.000 -name ACLK [get_ports ACLK]

# Clock uncertainty (jitter + skew)
# Typical values for KV260:
#   - Setup uncertainty: 0.5ns (includes clock jitter and skew)
#   - Hold uncertainty: 0.2ns
set_clock_uncertainty -setup 0.5 [get_clocks ACLK]
set_clock_uncertainty -hold 0.2 [get_clocks ACLK]

# Clock latency (if clock comes from external source or PS)
# For PL-only designs, these may not be needed
# Uncomment if clock comes from PS or external source:
# set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ACLK]
# set_input_delay -clock ACLK -max 1.0 [get_ports ACLK]
# set_input_delay -clock ACLK -min 0.5 [get_ports ACLK]

################################################################################
# Reset Constraints
################################################################################

# Async reset - ARESETN (active low)
# Set as false path since it's asynchronous reset
# Use get_cells instead of all_registers to avoid critical warning
set_false_path -from [get_ports ARESETN]

# Reset recovery and removal time
# These constraints help ensure proper reset timing
# The design should have reset synchronizers for proper operation
# Commented out to avoid warnings - reset timing handled by synchronizers
# set_max_delay -from [get_ports ARESETN] -to [all_registers] -datapath_only 10.0
# set_min_delay -from [get_ports ARESETN] -to [all_registers] -datapath_only 0.0

################################################################################
# Input/Output Delays
################################################################################

# These delays are for external masters/slaves
# If masters/slaves are in the same FPGA (PL), these may not be needed
# Adjust based on your system timing requirements

# Master 0 Input Delays (if external)
# Address and Control signals
set_input_delay -clock ACLK -max 2.0 [get_ports M0_AWADDR*]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_AWADDR*]
set_input_delay -clock ACLK -max 2.0 [get_ports M0_ARADDR*]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_ARADDR*]

# Data signals
set_input_delay -clock ACLK -max 2.0 [get_ports M0_WDATA*]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_WDATA*]

# Control signals
set_input_delay -clock ACLK -max 2.0 [get_ports M0_AWVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_AWVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M0_ARVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_ARVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M0_WVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_WVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M0_BREADY]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_BREADY]
set_input_delay -clock ACLK -max 2.0 [get_ports M0_RREADY]
set_input_delay -clock ACLK -min 0.5 [get_ports M0_RREADY]

# Master 1 Input Delays (if external)
set_input_delay -clock ACLK -max 2.0 [get_ports M1_AWADDR*]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_AWADDR*]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_ARADDR*]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_ARADDR*]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_WDATA*]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_WDATA*]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_AWVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_AWVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_ARVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_ARVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_WVALID]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_WVALID]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_BREADY]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_BREADY]
set_input_delay -clock ACLK -max 2.0 [get_ports M1_RREADY]
set_input_delay -clock ACLK -min 0.5 [get_ports M1_RREADY]

# Slave Output Delays (if external)
# Slave 0
set_output_delay -clock ACLK -max 2.0 [get_ports S0_AWADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_AWADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_ARADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_ARADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_WDATA*]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_WDATA*]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_AWVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_AWVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_ARVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_ARVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_WVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_WVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_BREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_BREADY]
set_output_delay -clock ACLK -max 2.0 [get_ports S0_RREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S0_RREADY]

# Slave 1, 2, 3 (similar constraints)
set_output_delay -clock ACLK -max 2.0 [get_ports S1_AWADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_AWADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_ARADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_ARADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_WDATA*]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_WDATA*]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_AWVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_AWVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_ARVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_ARVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_WVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_WVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_BREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_BREADY]
set_output_delay -clock ACLK -max 2.0 [get_ports S1_RREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S1_RREADY]

set_output_delay -clock ACLK -max 2.0 [get_ports S2_AWADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_AWADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_ARADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_ARADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_WDATA*]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_WDATA*]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_AWVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_AWVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_ARVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_ARVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_WVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_WVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_BREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_BREADY]
set_output_delay -clock ACLK -max 2.0 [get_ports S2_RREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S2_RREADY]

set_output_delay -clock ACLK -max 2.0 [get_ports S3_AWADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_AWADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_ARADDR*]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_ARADDR*]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_WDATA*]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_WDATA*]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_AWVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_AWVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_ARVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_ARVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_WVALID]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_WVALID]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_BREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_BREADY]
set_output_delay -clock ACLK -max 2.0 [get_ports S3_RREADY]
set_output_delay -clock ACLK -min 0.5 [get_ports S3_RREADY]

################################################################################
# Timing Exceptions (Optional - only if needed)
################################################################################

# AXI handshake signals are typically handled by the protocol
# Only add false paths if you have timing violations
# Uncomment these if you encounter timing issues:

# Write Address Channel - typically don't need false paths
# set_false_path -from [get_ports M0_AWVALID] -to [get_ports M0_AWREADY]
# set_false_path -from [get_ports M1_AWVALID] -to [get_ports M1_AWREADY]

# Write Data Channel
# set_false_path -from [get_ports M0_WVALID] -to [get_ports M0_WREADY]
# set_false_path -from [get_ports M1_WVALID] -to [get_ports M1_WREADY]

# Write Response Channel
# set_false_path -from [get_ports M0_BVALID] -to [get_ports M0_BREADY]
# set_false_path -from [get_ports M1_BVALID] -to [get_ports M1_BREADY]

# Read Address Channel
# set_false_path -from [get_ports M0_ARVALID] -to [get_ports M0_ARREADY]
# set_false_path -from [get_ports M1_ARVALID] -to [get_ports M1_ARREADY]

# Read Data Channel
# set_false_path -from [get_ports M0_RVALID] -to [get_ports M0_RREADY]
# set_false_path -from [get_ports M1_RVALID] -to [get_ports M1_RREADY]

################################################################################
# Max Delay / Min Delay (Optional - for specific timing requirements)
################################################################################

# Maximum delay from master to slave (if you have specific requirements)
# Example: Maximum delay from M0 to S0
# set_max_delay -from [get_ports M0_AWADDR*] -to [get_ports S0_AWADDR*] 8.0

################################################################################
# Power Optimization (Optional)
################################################################################

# Enable clock gating if available
# set_property CLOCK_GATING_CHECK TRUE [current_design]

################################################################################
# Physical Constraints (Optional - for pin assignment if needed)
################################################################################

# If you need to assign specific pins on KV260, uncomment and set:
# set_property PACKAGE_PIN <pin_name> [get_ports ACLK]
# set_property PACKAGE_PIN <pin_name> [get_ports ARESETN]
# set_property IOSTANDARD LVCMOS33 [get_ports ACLK]
# set_property IOSTANDARD LVCMOS33 [get_ports ARESETN]

# Note: For KV260, if using PS (Processing System), pins are typically
# assigned automatically through the block design. For PL-only designs,
# you may need to assign pins manually.

################################################################################
# Notes for KV260
################################################################################
# 1. Clock Frequency:
#    - Default: 100MHz (10ns period) - suitable for most AXI4 applications
#    - KV260 PS typically provides clocks: 50MHz, 100MHz, 150MHz, 200MHz
#    - Adjust -period value if using different frequency:
#      * 150MHz: -period 6.667
#      * 200MHz: -period 5.000
#
# 2. Input/Output Delays:
#    - Current values (2.0ns max, 0.5ns min) are conservative
#    - Adjust based on your actual system timing
#    - If masters/slaves are in PL (same FPGA), you may comment out I/O delays
#
# 3. Reset:
#    - ARESETN is async reset - false paths are set
#    - Ensure your design has proper reset synchronizers
#
# 4. For PS Integration:
#    - If connecting to PS AXI interfaces, use Xilinx AXI Interconnect IP
#    - Clock will come from PS - adjust constraints accordingly
#
# 5. Timing Closure:
#    - Run synthesis and implementation
#    - Check timing reports
#    - Adjust constraints if needed based on timing violations
#
################################################################################

