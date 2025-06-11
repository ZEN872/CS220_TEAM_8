// clock_divider.sv
module clock_divider #(
  parameter DW = 4  // bit-width for divisor control
) (
  input  logic             clk_in,
  input  logic             rst_n,
  input  logic [DW-1:0]    div_ctrl, // divider control: lower value→faster clock
  output logic             clk_out
);
  logic [DW-1:0] counter;
  // Simple counter-based divider: toggles clk_out when counter reaches div_ctrl.
  always_ff @(posedge clk_in or negedge rst_n) begin
    if (!rst_n) begin
      counter <= 0;
      clk_out <= 0;
    end else if (counter >= div_ctrl) begin
      counter <= 0;
      clk_out <= ~clk_out;
    end else begin
      counter <= counter + 1;
    end
  end
endmodule
