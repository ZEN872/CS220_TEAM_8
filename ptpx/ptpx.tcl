#------------------------------------------------------------
# Power Analysis Script for cv32e40p_top
#------------------------------------------------------------

#------------------------------------------------------------
# Power Analysis Setup
#------------------------------------------------------------
set power_enable_analysis true
set power_analysis_mode time_based
set power_enable_dynamic true
set power_enable_static true

#------------------------------------------------------------
# Define Environment Paths
#------------------------------------------------------------
set HOME "/home/cegrad/imaga008"
set DESIGN_NAME "cv32e40p_top"
set SYN_DIR "$HOME/CS220_TEAM_8/syn"
set REPORT_DIR "$SYN_DIR/rvt_reports"
set VCD_FILE "$HOME/CS220_TEAM_8/sim/cv32e40p_top_tb.vcd"

#------------------------------------------------------------
# Library and Search Paths
#------------------------------------------------------------
set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"
set link_library [list "*" $target_library]
set search_path [list "$SYN_DIR" "$HOME/CORE_ONLY_RTL/sim" "."]

# Read the standard cell library
read_db $target_library

#------------------------------------------------------------
# Read Synthesized Netlist and Constraints
#------------------------------------------------------------
read_verilog "$SYN_DIR/${DESIGN_NAME}_synthesized.v"
read_sdc "$SYN_DIR/${DESIGN_NAME}_const.sdc"

# Set the top-level design
current_design $DESIGN_NAME

#------------------------------------------------------------
# Read Switching Activity File (VCD)
#------------------------------------------------------------
# NOTE: Update the strip_path to match the testbench hierarchy (UUT instantiation)
# Example: strip path of testbench/uut if cv32e40p_top is instantiated as 'uut'
read_vcd -strip_path testbench/uut $VCD_FILE

#------------------------------------------------------------
# Clock Creation (Optional: If not fully constrained in SDC)
#------------------------------------------------------------
if { [llength [get_clocks clk_i -quiet]] == 0 } {
    create_clock -name clk_i -period 2 [get_ports clk_i]
}

#------------------------------------------------------------
# Perform Power Analysis
#------------------------------------------------------------
update_power

#------------------------------------------------------------
# Generate Power Reports
#------------------------------------------------------------
report_power -nosplit -hierarchy -verbose > "$REPORT_DIR/${DESIGN_NAME}_total_power.log"
report_power -nosplit -cell -verbose > "$REPORT_DIR/${DESIGN_NAME}_cell_power.log"
report_switching_activity -list_not_annotated > "$REPORT_DIR/${DESIGN_NAME}_unannotated_power.log"

#------------------------------------------------------------
# Exit
#------------------------------------------------------------
exit
