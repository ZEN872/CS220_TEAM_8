module tb_avfs;
  // Clock and reset signals.
  logic clk, rst_n;
  logic activity;
  logic [3:0] freq_sel;
  logic apb_sel, apb_we;
  logic [7:0] apb_addr;
  logic [31:0] apb_wdata, apb_rdata;

  // Clock generation.
  initial clk = 0;
  always #5 clk = ~clk; // 10ns period clock.

  // Reset generation.
  initial begin
    rst_n = 0;
    #20 rst_n = 1;
    // Stimulate activity: toggle to show dynamic frequency scaling.
    activity = 0;
    #50 activity = 1;
    #100 activity = 0;
    #100 $finish;
  end

  // Instantiate the AVFS controller.
  avfs_controller u_avfs (
    .clk(clk),
    .rst_n(rst_n),
    .activity(activity),
    .freq_sel(freq_sel),
    .apb_sel(apb_sel),
    .apb_we(apb_we),
    .apb_addr(apb_addr),
    .apb_wdata(apb_wdata),
    .apb_rdata(apb_rdata)
  );
  
 initial begin
    $dumpfile("cv32e40p_top_tb.vcd");
    $dumpvars(0, tb_avfs);
  end
  
  // Monitoring results.
  initial begin
    $monitor("Time=%0t, Activity=%b, Freq_SEL=%h", $time, activity, freq_sel);
  end

endmodule
