module i_tcm #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10  // Assume 1024 words, for example
) (
    input logic clk,
    input logic we,
    input logic [ADDR_WIDTH-1:0] addr,
    input logic [DATA_WIDTH-1:0] data_in,
    output logic [DATA_WIDTH-1:0] data_out
);
  // Behavioral memory model (for simulation)
  logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
  
  always_ff @(posedge clk) begin
    if (we)
        mem[addr] <= data_in;
    data_out <= mem[addr];
  end
endmodule
