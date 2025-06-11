# Enable power analysis in PrimeTime
set power_enable_analysis TRUE

set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"
set link_library [list {*} "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"]

read_db $target_library

# Read GCD netlist
read_verilog "../../syn/Opt_2/cv32e40p_top_synthesized.v"

#read_sdc "$../syn/cv32e40p_top_const.sdc"

# Set top-level design
current_design cv32e40p_top

# Create 500 MHz clock
create_clock -period 2 -name clk [find port clk]

# Load VCD for switching activity
   
read_vcd -strip_path  cv32e40p_top/dut "../../sim/Opt2s/cv32e40p_top_tb.vcd"


update_power

# Save power reports
report_power -nosplit -verbose > total_power.log
report_power -cell -verbose > cell_power.log
report_switching_activity -list_not_annotated > unannotated.log
