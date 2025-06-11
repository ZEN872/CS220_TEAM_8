#-------------------------------------------
# Synthesis Script for cv32e40p_top
#-------------------------------------------

# Set environment and design variables
set HOME "/home/cegrad/imaga008/CS220_TEAM_8"
set DESIGN_NAME "cv32e40p_top"
set DESIGN_RTL_DIR "${HOME}/rtl"
set REPORT_DIR "${HOME}/syn/Baseline/rvt_reports"

#------------------------------------------------------------
# Set library search paths
#------------------------------------------------------------
set_app_var target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"
set_app_var link_path      "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_ccs/saed32rvt_tt0p78v25c.db"

# Power grid settings
set dc_allow_rtl_pg true
set mw_logic1_net "VDD"
set mw_logic0_net "VSS"

#------------------------------------------------------------
# Update Search Path to Include fpnew_pkg.sv Location
#------------------------------------------------------------
set search_path [list \
    "${DESIGN_RTL_DIR}/include"
    "${DESIGN_RTL_DIR}/../bhv"
    "${DESIGN_RTL_DIR}/../bhv/include"
    "${DESIGN_RTL_DIR}/../sva"
    "${DESIGN_RTL_DIR}/vendor/pulp_platform_common_cells/include"]

#------------------------------------------------------------
# Read RTL Files (in dependency order)
#------------------------------------------------------------

read_sverilog ${DESIGN_RTL_DIR}/include/cv32e40p_apu_core_pkg.sv
read_sverilog ${DESIGN_RTL_DIR}/include/cv32e40p_fpu_pkg.sv
read_sverilog ${DESIGN_RTL_DIR}/include/cv32e40p_pkg.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_if_stage.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_cs_registers.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_register_file_ff.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_load_store_unit.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_id_stage.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_aligner.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_decoder.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_compressed_decoder.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_fifo.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_prefetch_buffer.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_hwloop_regs.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_mult.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_int_controller.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_ex_stage.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_alu_div.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_alu.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_ff_one.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_popcnt.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_apu_disp.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_controller.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_obi_interface.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_prefetch_controller.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_sleep_unit.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_core.sv

read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_common_cells/src/cf_math_pkg.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_common_cells/src/rr_arb_tree.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_common_cells/src/lzc.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_pkg.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/clk/rtl/gated_clk_cell.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ctrl.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_ff1.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_pack_single.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_prepare.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_round_single.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_special.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_srt_single.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fdsu/rtl/pa_fdsu_top.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_dp.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_frbus.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/vendor/opene906/E906_RTL_FACTORY/gen_rtl/fpu/rtl/pa_fpu_src_type.v
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_divsqrt_th_32.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_classifier.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_rounding.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_cast_multi.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_fma_multi.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_noncomp.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_opgroup_fmt_slice.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_opgroup_multifmt_slice.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_opgroup_block.sv
read_sverilog ${DESIGN_RTL_DIR}/vendor/pulp_platform_fpnew/src/fpnew_top.sv
read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_fp_wrapper.sv

read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_top.sv 
#read_sverilog ${DESIGN_RTL_DIR}/cv32e40p_top_moded.sv


#read_sverilog ${DESIGN_RTL_DIR}/../bhv/cv32e40p_sim_clock_gate.sv
#read_sverilog ${DESIGN_RTL_DIR}/../bhv/include/cv32e40p_tracer_pkg.sv
#read_sverilog ${DESIGN_RTL_DIR}/../bhv/cv32e40p_tb_wrapper.sv

#------------------------------------------------------------
# Elaborate and Link Design
#------------------------------------------------------------
elaborate cv32e40p_top
link

#------------------------------------------------------------
# Check for Unresolved References
#------------------------------------------------------------
report_unresolved

#------------------------------------------------------------
# Clock and Timing Constraints
#------------------------------------------------------------
create_clock -name "clk_i" -period 2 -waveform {0 1} [get_ports "clk_i"]
set_dont_touch_network [get_clocks "clk_i"]

# Apply constraints only if ports exist
if {[llength [get_ports "en_i"]] > 0} {
    set_input_delay 0.1 -max -rise -clock clk_i [get_ports {en_i}]
    set_input_delay 0.1 -max -fall -clock clk_i [get_ports {en_i}]
}

if {[llength [get_ports "scan_cg_en_i"]] > 0} {
    set_input_delay 0.1 -max -rise -clock clk_i [get_ports {scan_cg_en_i}]
    set_input_delay 0.1 -max -fall -clock clk_i [get_ports {scan_cg_en_i}]
}

if {[llength [get_ports "clk_o"]] > 0} {
    set_output_delay 0.1 -max -rise -clock clk_i [get_ports {clk_o}]
    set_output_delay 0.1 -max -fall -clock clk_i [get_ports {clk_o}]
}

if {[llength [get_ports "clk_pg"]] > 0} {
    set_output_delay 0.1 -max -rise -clock clk_i [get_ports {clk_pg}]
    set_output_delay 0.1 -max -fall -clock clk_i [get_ports {clk_pg}]
}

# Clock uncertainty
set_clock_uncertainty 0.2 -setup [get_clocks clk_i]
set_clock_uncertainty 0.2 -hold  [get_clocks clk_i]

# Design constraints
set_max_fanout 100 [get_designs *]
set_fix_multiple_port_nets -all -buffer_constants

#------------------------------------------------------------
# Synthesis Process
#------------------------------------------------------------
check_design
compile_ultra -incremental
change_names -rules sverilog -hierarchy

#------------------------------------------------------------
# Write Synthesized Netlist and Constraints
#------------------------------------------------------------
write -format ddc     -output "${DESIGN_NAME}_synthesized.ddc"
write -format verilog -output "${DESIGN_NAME}_synthesized.v"
write_sdc -nosplit    "${DESIGN_NAME}_const.sdc"

#------------------------------------------------------------
# Report Generation
#------------------------------------------------------------
report_timing > "${REPORT_DIR}/${DESIGN_NAME}_timing_reports.log"
report_area   > "${REPORT_DIR}/${DESIGN_NAME}_area_reports.log"
report_power  > "${REPORT_DIR}/${DESIGN_NAME}_power_reports.log"

exit
