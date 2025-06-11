// Copyright 2024 Dolphin Design
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the "License");
// you may not use this file except in compliance with the License, or,
// at your option, the Apache License version 2.0.
// You may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/////////////////////////////////////////////////////////////////////////////
//                                                                         //
// Contributors: Pascal Gouedo, Dolphin Design <pascal.gouedo@dolphin.fr>  //
//                                                                         //
// Description:  Top level module of CV32E40P instantiating the Core and   //
//               an optional CVFPU with its clock gating cell.             //
//               [AVFS Optimization Added: Dynamic Frequency Scaling for    //
//                the FPU clock via an AVFS controller and clock divider.] //
//                                                                         //
/////////////////////////////////////////////////////////////////////////////

module cv32e40p_top #(
    parameter COREV_PULP = 0, // PULP ISA Extension (incl. custom CSRs and hardware loop, excl. cv.elw)
    parameter COREV_CLUSTER = 0,  // PULP Cluster interface (incl. cv.elw)
    parameter FPU = 0,  // Floating Point Unit (interfaced via APU interface)
    parameter FPU_ADDMUL_LAT = 0,  // Floating-Point ADDition/MULtiplication computing lane pipeline registers number
    parameter FPU_OTHERS_LAT = 0,  // Floating-Point COMParison/CONVersion computing lanes pipeline registers number
    parameter ZFINX = 0,  // Float-in-General Purpose registers
    parameter NUM_MHPMCOUNTERS = 1
) (
    // Clock and Reset
    input logic clk_i,
    input logic rst_ni,

    input logic pulp_clock_en_i,  // PULP clock enable (only used if COREV_CLUSTER = 1)
    input logic scan_cg_en_i,  // Enable all clock gates for testing

    // Core ID, Cluster ID, debug mode halt address and boot address are considered more or less static
    input logic [31:0] boot_addr_i,
    input logic [31:0] mtvec_addr_i,
    input logic [31:0] dm_halt_addr_i,
    input logic [31:0] hart_id_i,
    input logic [31:0] dm_exception_addr_i,

    // Instruction memory interface
    output logic        instr_req_o,
    input  logic        instr_gnt_i,
    input  logic        instr_rvalid_i,
    output logic [31:0] instr_addr_o,
    input  logic [31:0] instr_rdata_i,

    // Data memory interface
    output logic        data_req_o,
    input  logic        data_gnt_i,
    input  logic        data_rvalid_i,
    output logic        data_we_o,
    output logic [ 3:0] data_be_o,
    output logic [31:0] data_addr_o,
    output logic [31:0] data_wdata_o,
    input  logic [31:0] data_rdata_i,

    // Interrupt inputs
    input  logic [31:0] irq_i,  // CLINT interrupts + CLINT extension interrupts
    output logic        irq_ack_o,
    output logic [ 4:0] irq_id_o,

    // Debug Interface
    input  logic debug_req_i,
    output logic debug_havereset_o,
    output logic debug_running_o,
    output logic debug_halted_o,

    // CPU Control Signals
    input  logic fetch_enable_i,
    output logic core_sleep_o
);

  import cv32e40p_apu_core_pkg::*;

  // Core to FPU signals
  logic                              apu_busy;
  logic                              apu_req;
  logic [   APU_NARGS_CPU-1:0][31:0]  apu_operands;
  logic [     APU_WOP_CPU-1:0]        apu_op;
  logic [APU_NDSFLAGS_CPU-1:0]        apu_flags;

  // FPU to Core signals
  logic                              apu_gnt;
  logic                              apu_rvalid;
  logic [31:0]                       apu_rdata;
  logic [APU_NUSFLAGS_CPU-1:0]        apu_rflags;

  // Signals for AVFS optimization (new additions)
  logic [3:0]  avfs_freq_sel;  // Frequency selection output from the AVFS controller
  logic        avfs_activity;  // Derived activity signal for dynamic frequency scaling
  logic        avfs_clk;       // AVFS-controlled clock output (after clock divider)

  // APB interface signals for AVFS, tied off in this example (can be driven externally if needed)
  logic        avfs_apb_sel = 1'b0;
  logic        avfs_apb_we  = 1'b0;
  logic [7:0]  avfs_apb_addr = 8'd0;
  logic [31:0] avfs_apb_wdata = 32'd0;
  // (avfs_apb_rdata is not used here)

  // Generate AVFS activity signal:
  // Here, we derive activity from FPU request or busy signals.
  assign avfs_activity = apu_req | apu_busy;

  //------------------------------------------------------------------------
  // Instantiate the Core as before
  //------------------------------------------------------------------------
  cv32e40p_core #(
      .COREV_PULP      (COREV_PULP),
      .COREV_CLUSTER   (COREV_CLUSTER),
      .FPU             (FPU),
      .FPU_ADDMUL_LAT  (FPU_ADDMUL_LAT),
      .FPU_OTHERS_LAT  (FPU_OTHERS_LAT),
      .ZFINX           (ZFINX),
      .NUM_MHPMCOUNTERS(NUM_MHPMCOUNTERS)
  ) core_i (
      .clk_i (clk_i),
      .rst_ni(rst_ni),

      .pulp_clock_en_i(pulp_clock_en_i),
      .scan_cg_en_i   (scan_cg_en_i),

      .boot_addr_i        (boot_addr_i),
      .mtvec_addr_i       (mtvec_addr_i),
      .dm_halt_addr_i     (dm_halt_addr_i),
      .hart_id_i          (hart_id_i),
      .dm_exception_addr_i(dm_exception_addr_i),

      .instr_req_o   (instr_req_o),
      .instr_gnt_i   (instr_gnt_i),
      .instr_rvalid_i(instr_rvalid_i),
      .instr_addr_o  (instr_addr_o),
      .instr_rdata_i (instr_rdata_i),

      .data_req_o   (data_req_o),
      .data_gnt_i   (data_gnt_i),
      .data_rvalid_i(data_rvalid_i),
      .data_we_o    (data_we_o),
      .data_be_o    (data_be_o),
      .data_addr_o  (data_addr_o),
      .data_wdata_o (data_wdata_o),
      .data_rdata_i (data_rdata_i),

      .apu_busy_o    (apu_busy),
      .apu_req_o     (apu_req),
      .apu_gnt_i     (apu_gnt),
      .apu_operands_o(apu_operands),
      .apu_op_o      (apu_op),
      .apu_flags_o   (apu_flags),
      .apu_rvalid_i  (apu_rvalid),
      .apu_result_i  (apu_rdata),
      .apu_flags_i   (apu_rflags),

      .irq_i    (irq_i),
      .irq_ack_o(irq_ack_o),
      .irq_id_o (irq_id_o),

      .debug_req_i      (debug_req_i),
      .debug_havereset_o(debug_havereset_o),
      .debug_running_o  (debug_running_o),
      .debug_halted_o   (debug_halted_o),

      .fetch_enable_i(fetch_enable_i),
      .core_sleep_o  (core_sleep_o)
  );

  //------------------------------------------------------------------------
  // AVFS Optimization Integration:
  // The AVFS controller monitors the FPU activity (derived from apu_req and apu_busy)
  // and produces a freq_sel output. This controls the clock divider to generate a
  // dynamic clock for the FPU. This replaces the original clock gate used for the FPU.
  //------------------------------------------------------------------------

  // Instantiate AVFS Controller
  avfs_controller u_avfs (
      .clk        (clk_i),
      .rst_n      (rst_ni),
      .activity   (avfs_activity),
      .freq_sel   (avfs_freq_sel),
      .apb_sel    (avfs_apb_sel),
      .apb_we     (avfs_apb_we),
      .apb_addr   (avfs_apb_addr),
      .apb_wdata  (avfs_apb_wdata),
      .apb_rdata  ()  // Not used in this integration
  );

  // Instantiate Clock Divider driven by the AVFS controller's frequency selection
  clock_divider u_clk_divider (
      .clk_in   (clk_i),
      .rst_n    (rst_ni),
      .div_ctrl (avfs_freq_sel),  // The selected divider value
      .clk_out  (avfs_clk)
  );

  //------------------------------------------------------------------------
  // FPU Integration with AVFS:
  // If FPU is enabled, use AVFS-controlled clock (avfs_clk) instead of the original gated clock.
  // This provides dynamic frequency scaling of the FPU domain.
  //------------------------------------------------------------------------
  generate
    if (FPU) begin : fpu_gen
      // AVFS now drives the FPU clock.
      cv32e40p_fp_wrapper #(
          .FPU_ADDMUL_LAT(FPU_ADDMUL_LAT),
          .FPU_OTHERS_LAT(FPU_OTHERS_LAT)
      ) fp_wrapper_i (
          .clk_i         (avfs_clk),  // Use the AVFS dynamic clock
          .rst_ni        (rst_ni),
          .apu_req_i     (apu_req),
          .apu_gnt_o     (apu_gnt),
          .apu_operands_i(apu_operands),
          .apu_op_i      (apu_op),
          .apu_flags_i   (apu_flags),
          .apu_rvalid_o  (apu_rvalid),
          .apu_rdata_o   (apu_rdata),
          .apu_rflags_o  (apu_rflags)
      );
    end else begin : no_fpu_gen
      // Drive FPU output signals to 0 if FPU is disabled.
      assign apu_gnt    = '0;
      assign apu_rvalid = '0;
      assign apu_rdata  = '0;
      assign apu_rflags = '0;
    end
  endgenerate

endmodule
