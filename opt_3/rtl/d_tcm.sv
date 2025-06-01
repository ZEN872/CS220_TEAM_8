`timescale 1ns/1ps
//***************************************************************************
// Filename: d_tcm.sv
// Description: Behavioral model for Data TCM (D‑TCM) memory.
//              This model supports synchronous writes and a registered, 
//              one-cycle latency read. It is suitable for simulation and 
//              synthesis.
// Author:      [Your Name]
//***************************************************************************

module d_tcm #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 10  // Default: 1024 words (2^10)
)(
    input  logic                    clk,      // Memory clock
    input  logic                    we,       // Write enable
    input  logic [ADDR_WIDTH-1:0]   addr,     // Memory address
    input  logic [DATA_WIDTH-1:0]   data_in,  // Write data
    output logic [DATA_WIDTH-1:0]   data_out  // Read data (one cycle latency)
);

    // Declare the memory array
    logic [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];

    // Register for output data
    logic [DATA_WIDTH-1:0] q;

    // Synchronous memory operation (write and registered read)
    always_ff @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in;
        end
        q <= mem[addr];
    end

    assign data_out = q;

endmodule
