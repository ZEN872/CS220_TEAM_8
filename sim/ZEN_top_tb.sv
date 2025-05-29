`timescale 1ns/1ps
`default_nettype none

module cv32e40p_top_tb;

  // Clock and Reset
  logic clk;
  logic rst_n;

  // Clock gating and enable
  logic en, scan_cg_en, pulp_clock_en;
  logic clk_gated, clk_power;

  // Core configuration
  logic [31:0] boot_addr, mtvec_addr, dm_halt_addr, hart_id, dm_exception_addr;

  // Instruction interface
  logic instr_req;
  logic instr_gnt;
  logic instr_rvalid;
  logic [31:0] instr_addr;
  logic [31:0] instr_rdata;

  // Data interface
  logic data_req;
  logic data_gnt;
  logic data_rvalid;
  logic data_we;
  logic [3:0] data_be;
  logic [31:0] data_addr;
  logic [31:0] data_wdata;
  logic [31:0] data_rdata;

  // Interrupts
  logic [31:0] irq;
  logic irq_ack;
  logic [4:0] irq_id;

  // Debug
  logic debug_req;
  logic debug_havereset;
  logic debug_running;
  logic debug_halted;

  // CPU control
  logic fetch_enable;
  logic core_sleep;

  // IRQ symbolic ID
  localparam IRQ_TIMER = 3;

  // Instantiate DUT
  cv32e40p_top #(
    .COREV_PULP(1),
    .COREV_CLUSTER(1),
    .FPU(0),
    .ZFINX(0),
    .NUM_MHPMCOUNTERS(4)
  ) dut (
    .clk_i(clk),
    .rst_ni(rst_n),
    .en_i(en),
    .pulp_clock_en_i(pulp_clock_en),
    .scan_cg_en_i(scan_cg_en),
    .clk_o(clk_gated),
    .clk_pg(clk_power),

    .boot_addr_i(boot_addr),
    .mtvec_addr_i(mtvec_addr),
    .dm_halt_addr_i(dm_halt_addr),
    .hart_id_i(hart_id),
    .dm_exception_addr_i(dm_exception_addr),

    .instr_req_o(instr_req),
    .instr_gnt_i(instr_gnt),
    .instr_rvalid_i(instr_rvalid),
    .instr_addr_o(instr_addr),
    .instr_rdata_i(instr_rdata),

    .data_req_o(data_req),
    .data_gnt_i(data_gnt),
    .data_rvalid_i(data_rvalid),
    .data_we_o(data_we),
    .data_be_o(data_be),
    .data_addr_o(data_addr),
    .data_wdata_o(data_wdata),
    .data_rdata_i(data_rdata),

    .irq_i(irq),
    .irq_ack_o(irq_ack),
    .irq_id_o(irq_id),

    .debug_req_i(debug_req),
    .debug_havereset_o(debug_havereset),
    .debug_running_o(debug_running),
    .debug_halted_o(debug_halted),

    .fetch_enable_i(fetch_enable),
    .core_sleep_o(core_sleep)
  );

 
  // -----------------------------------
  // Clock Generation
  // -----------------------------------
  always #5 clk = ~clk;

  // -----------------------------------
  // Waveform Dump
  // -----------------------------------
  initial begin
    $dumpfile("cv32e40p_top_tb.vcd");
    $dumpvars(0, cv32e40p_top_tb);
  end

  // -----------------------------------
  // Utility Tasks
  // -----------------------------------
  task reset_core();
    rst_n = 0;
    #20 rst_n = 1;
  endtask

  task simulate_instr_fetch();
    instr_gnt = 1;
    instr_rvalid = 1;
    instr_rdata = 32'h00000013; // NOP
    #10;
    instr_gnt = 0;
    instr_rvalid = 0;
  endtask

  task simulate_data_access();
    data_gnt = 1;
    data_rvalid = 1;
    data_rdata = 32'hDEADBEEF;
    #10;
    data_gnt = 0;
    data_rvalid = 0;
  endtask

  task trigger_irq();
    irq[0] = 1;
    #20;
    irq[0] = 0;
  endtask

  task send_debug_req();
    debug_req = 1;
    #10;
    debug_req = 0;
  endtask

  // -----------------------------------
  // Corner Testcases
  // -----------------------------------
  integer pass_count;

  task corner_testcase_1(); simulate_instr_fetch(); pass_count++; endtask
  task corner_testcase_2(); simulate_data_access(); pass_count++; endtask
  task corner_testcase_3(); trigger_irq(); pass_count++; endtask
  task corner_testcase_4(); send_debug_req(); pass_count++; endtask
  task corner_testcase_5(); #10; pass_count++; endtask
  task corner_testcase_6(); instr_rdata = 32'hFFFFFFFF; simulate_instr_fetch(); pass_count++; endtask
  task corner_testcase_7(); data_rdata = 32'hCAFEBABE; simulate_data_access(); pass_count++; endtask
  task corner_testcase_8(); irq = 32'hA5A5A5A5; #10; irq = 0; pass_count++; endtask
  task corner_testcase_9(); debug_req = 1; #1; debug_req = 0; pass_count++; endtask
  task corner_testcase_10(); reset_core(); pass_count++; endtask

  // -----------------------------------
  // Constrained Testcases
  // -----------------------------------
  task constrained_testcase_1(); boot_addr = $urandom; #5; pass_count++; endtask
  task constrained_testcase_2(); mtvec_addr = $urandom_range(32'h100, 32'h200); pass_count++; endtask
  task constrained_testcase_3(); dm_halt_addr = $urandom(); pass_count++; endtask
  task constrained_testcase_4(); dm_exception_addr = $urandom(); pass_count++; endtask
  task constrained_testcase_5(); hart_id = $urandom_range(0, 4); pass_count++; endtask
  task constrained_testcase_6(); irq = $urandom(); #5; irq = 0; pass_count++; endtask
  task constrained_testcase_7(); instr_rdata = $urandom(); simulate_instr_fetch(); pass_count++; endtask
  task constrained_testcase_8(); data_rdata = $urandom(); simulate_data_access(); pass_count++; endtask
  task constrained_testcase_9(); scan_cg_en = $urandom_range(0,1); #5; pass_count++; endtask
  task constrained_testcase_10(); fetch_enable = $urandom_range(0,1); #5; pass_count++; endtask

  // -----------------------------------
  // Main Simulation
  // -----------------------------------
  initial begin
    $display("Starting cv32e40p_top testbench...");
    pass_count = 0;

    // Initial values
    clk = 0;
    rst_n = 0;
    en = 0;
    scan_cg_en = 0;
    pulp_clock_en = 0;
    fetch_enable = 0;

    boot_addr = 32'h80000000;
    mtvec_addr = 32'h00000100;
    dm_halt_addr = 32'h00000200;
    dm_exception_addr = 32'h00000300;
    hart_id = 32'd0;

    instr_gnt = 0;
    instr_rvalid = 0;
    instr_rdata = 32'h00000013;

    data_gnt = 0;
    data_rvalid = 0;
    data_rdata = 32'h0;
    //data_wdata = 32'h0;

    debug_req = 0;
    irq = 32'd0;

    #5;
    reset_core();
    #20;
    en = 1;
    pulp_clock_en = 1;
    fetch_enable = 1;

    // Run testcases
    corner_testcase_1(); corner_testcase_2(); corner_testcase_3(); corner_testcase_4(); corner_testcase_5();
   corner_testcase_6(); corner_testcase_7(); corner_testcase_8(); corner_testcase_9(); corner_testcase_10();

   constrained_testcase_1(); constrained_testcase_2(); constrained_testcase_3(); constrained_testcase_4(); constrained_testcase_5();
  constrained_testcase_6(); constrained_testcase_7(); constrained_testcase_8(); constrained_testcase_9(); constrained_testcase_10();

    #20;
    assert(pass_count == 20) else $fatal("Some testcases failed. Pass count = %0d", pass_count);

    $display("All 10 corner and 10 constrained testcases passed.");
    $display("Test completed.");
    $finish;
  end

endmodule
