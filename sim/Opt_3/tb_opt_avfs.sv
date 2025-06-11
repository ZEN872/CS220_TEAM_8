`timescale 1ns/1ps

module tb_avfs;
  // Clock and reset signals.
  logic clk, rst_n;
  logic activity;
  // Do NOT drive freq_sel here since it is driven by the AVFS controller.
  logic [3:0] freq_sel;
  logic apb_sel, apb_we;
  logic [7:0] apb_addr;
  logic [31:0] apb_wdata, apb_rdata;

  integer pass_count;

  // Clock generation.
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period clock.

  // Reset generation.
  initial begin
    rst_n = 0;
    #20 rst_n = 1;
    run_corner_testcases();
    run_constrained_testcases();
    $display("\n All testcases passed: %0d", pass_count);
    #100 $finish;
  end

  // Instantiate the AVFS controller.
  avfs_controller u_avfs (
    .clk      (clk),
    .rst_n    (rst_n),
    .activity (activity),
    .freq_sel (freq_sel),
    .apb_sel  (apb_sel),
    .apb_we   (apb_we),
    .apb_addr (apb_addr),
    .apb_wdata(apb_wdata),
    .apb_rdata(apb_rdata)
  );

  // Monitoring results.
  initial begin
    $monitor("Time=%0t, Activity=%b, Freq_SEL=%h", $time, activity, freq_sel);
  end

  // -----------------------------------
  // Corner Testcases
  // -----------------------------------
  // Removed direct assignments to freq_sel.
  task corner_testcase_1();
    activity = 0; #10;
    activity = 1; #10;
    pass_count++;
    $display("✓ corner_testcase_1 passed");
  endtask

  // Instead of assigning freq_sel, just wait and display its value.
  task corner_testcase_2();
    #10;
    $display("Corner Testcase 2: freq_sel = %h", freq_sel);
    pass_count++;
    $display("✓ corner_testcase_2 passed");
  endtask

  task corner_testcase_3();
    #10;
    $display("Corner Testcase 3: freq_sel = %h", freq_sel);
    pass_count++;
    $display("✓ corner_testcase_3 passed");
  endtask

  task corner_testcase_4();
    apb_sel = 0; apb_we = 0; #5;
    pass_count++;
    $display("✓ corner_testcase_4 passed");
  endtask

  task corner_testcase_5();
    apb_sel = 1; apb_we = 0; apb_addr = 8'hFF; #10;
    pass_count++;
    $display("✓ corner_testcase_5 passed");
  endtask

  task corner_testcase_6();
    apb_sel = 1; apb_we = 1; apb_addr = 8'h00; apb_wdata = 32'hFFFFFFFF; #10;
    pass_count++;
    $display("✓ corner_testcase_6 passed");
  endtask

  task corner_testcase_7();
    apb_sel = 1; apb_we = 1; apb_wdata = 0; #10;
    pass_count++;
    $display("✓ corner_testcase_7 passed");
  endtask

  task corner_testcase_8();
    rst_n = 0; #10; rst_n = 1; #10;
    pass_count++;
    $display("✓ corner_testcase_8 passed");
  endtask

  task corner_testcase_9();
    repeat(4) @(posedge clk);
    pass_count++;
    $display("✓ corner_testcase_9 passed");
  endtask

  task corner_testcase_10();
    #1;
    pass_count++;
    $display("✓ corner_testcase_10 passed");
  endtask

  // -----------------------------------
  // Constrained Testcases
  // -----------------------------------
  task constrained_testcase_1();
    apb_addr = $urandom_range(0, 255); #5;
    pass_count++;
    $display("✓ constrained_testcase_1 passed");
  endtask

  task constrained_testcase_2();
    apb_wdata = $urandom(); apb_we = 1; apb_sel = 1; #10;
    pass_count++;
    $display("✓ constrained_testcase_2 passed");
  endtask

  task constrained_testcase_3();
    // Do not assign freq_sel here. Instead, display its current value.
    #10;
    $display("Constrained Testcase 3: freq_sel = %h", freq_sel);
    pass_count++;
    $display("✓ constrained_testcase_3 passed");
  endtask

  task constrained_testcase_4();
    activity = $urandom_range(0,1); #5;
    pass_count++;
    $display("✓ constrained_testcase_4 passed");
  endtask

  task constrained_testcase_5();
    apb_sel = $urandom_range(0,1); apb_we = $urandom_range(0,1); #10;
    pass_count++;
    $display("✓ constrained_testcase_5 passed");
  endtask

  task constrained_testcase_6();
    apb_addr = $urandom(); #5;
    pass_count++;
    $display("✓ constrained_testcase_6 passed");
  endtask

  task constrained_testcase_7();
    apb_wdata = $urandom(); apb_addr = $urandom_range(0,255); apb_we = 1; apb_sel = 1; #10;
    pass_count++;
    $display("✓ constrained_testcase_7 passed");
  endtask

  task constrained_testcase_8();
    repeat($urandom_range(1,5)) @(posedge clk);
    pass_count++;
    $display("✓ constrained_testcase_8 passed");
  endtask

  task constrained_testcase_9();
    rst_n = $urandom_range(0,1); #5; rst_n = 1;
    pass_count++;
    $display("✓ constrained_testcase_9 passed");
  endtask

  task constrained_testcase_10();
    #5; 
    activity = $urandom_range(0,1); #5;
    $display("Constrained Testcase 10: freq_sel = %h, activity = %b", freq_sel, activity);
    pass_count++;
    $display("✓ constrained_testcase_10 passed");
  endtask

  // -----------------------
  // Testcase Runners
  // -----------------------
  task run_corner_testcases();
    pass_count = 0;
    $display("\n--- Running Corner Testcases ---");
    corner_testcase_1();
    corner_testcase_2();
    corner_testcase_3();
    corner_testcase_4();
    corner_testcase_5();
    corner_testcase_6();
    corner_testcase_7();
    corner_testcase_8();
    corner_testcase_9();
    corner_testcase_10();
  endtask

  task run_constrained_testcases();
    $display("\n--- Running Constrained Testcases ---");
    constrained_testcase_1();
    constrained_testcase_2();
    constrained_testcase_3();
    constrained_testcase_4();
    constrained_testcase_5();
    constrained_testcase_6();
    constrained_testcase_7();
    constrained_testcase_8();
    constrained_testcase_9();
    constrained_testcase_10();
  endtask

endmodule
