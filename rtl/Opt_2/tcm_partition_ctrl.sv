//***************************************************************************
// Filename: tcm_partition_ctrl.sv
// Description: Partition controller that splits a unified memory interface
//              into two dedicated channels: I-TCM (instruction memory) and
//              D-TCM (data memory). For this example, we assume that if the
//              MSB (addr[31]) is 0, the access is directed to I-TCM; if 1,
//              the access goes to D-TCM.
//***************************************************************************
module tcm_partition_ctrl (
  input  logic         clk,
  input  logic         rst_n,
  // Unified memory interface from the core
  input  logic [31:0]  addr,
  input  logic [31:0]  data_wr,
  input  logic         we,
  output logic [31:0]  data_rd,
  // I-TCM memory interface
  output logic [31:0]  itcm_addr,
  output logic [31:0]  itcm_data_wr,
  output logic         itcm_we,
  input  logic [31:0]  itcm_data_rd,
  // D-TCM memory interface
  output logic [31:0]  dtcm_addr,
  output logic [31:0]  dtcm_data_wr,
  output logic         dtcm_we,
  input  logic [31:0]  dtcm_data_rd
);

  // Partitioning decision: use the MSB of the address as a selector.
  // (This mapping is just one example; adjust according to your memory map.)
  always_comb begin
    if (addr[31] == 1'b0) begin
      // Route to I-TCM
      itcm_addr    = addr;
      itcm_data_wr = data_wr;
      itcm_we      = we;
      // Disable D-TCM outputs
      dtcm_addr    = 32'd0;
      dtcm_data_wr = 32'd0;
      dtcm_we      = 1'b0;
    end else begin
      // Route to D-TCM
      dtcm_addr    = addr;
      dtcm_data_wr = data_wr;
      dtcm_we      = we;
      // Disable I-TCM outputs
      itcm_addr    = 32'd0;
      itcm_data_wr = 32'd0;
      itcm_we      = 1'b0;
    end
  end

  // Select the proper read data based on the address.
  assign data_rd = (addr[31] == 1'b0) ? itcm_data_rd : dtcm_data_rd;

endmodule
