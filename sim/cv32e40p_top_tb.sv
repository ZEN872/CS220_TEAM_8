`timescale 1ns/1ps

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

  // Clock generation
  always #5 clk = ~clk;

  // Waveform dump
  initial begin
    $dumpfile("cv32e40p_top_tb.vcd");
    $dumpvars(0, cv32e40p_top_tb);
  end

  // Task: Reset
  task reset_core();
    rst_n = 0;
    #20 rst_n = 1;
  endtask

  // Task: Simulate instruction fetch
  task simulate_instr_fetch();
    instr_gnt = 1;
    instr_rvalid = 1;
    instr_rdata = 32'h00000013; // NOP
    #10;
    instr_gnt = 0;
    instr_rvalid = 0;
  endtask

  // Task: Simulate data access
  task simulate_data_access();
    data_gnt = 1;
    data_rvalid = 1;
    data_rdata = 32'hDEADBEEF;
    #10;
    data_gnt = 0;
    data_rvalid = 0;
  endtask

  // Task: Trigger interrupt
  task trigger_irq();
    irq[IRQ_TIMER] = 1;
    #20;
    irq[IRQ_TIMER] = 0;
  endtask

  // Task: Debug interaction
  task send_debug_req();
    debug_req = 1;
    #10;
    debug_req = 0;
  endtask

  // Test routine
  initial begin
    $display("Starting cv32e40p_top testbench...");

    // Initialize signals
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

    debug_req = 0;
    irq = 32'd0;

    #5;

    // Apply reset
    reset_core();

    // Post-reset delay
    #20;
    en = 1;
    pulp_clock_en = 1;
    fetch_enable = 1;

    // Instruction fetch phase
    simulate_instr_fetch();

    // Data access phase
    #20;
    simulate_data_access();

    // Interrupt trigger
    #20;
    trigger_irq();

    // Debug request
    #20;
    send_debug_req();

    // Simple output assertions
    #20;
    assert(debug_running || debug_halted)
      else $fatal("Core neither running nor halted after debug interaction.");

    #100;
    $display("Test completed.");
    $finish;
  end

endmodule
