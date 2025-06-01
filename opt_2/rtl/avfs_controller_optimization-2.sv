//***************************************************************************
// Filename : avfs_controller_optimization-2.sv
// Description : Adaptive Voltage and Frequency Scaling (AVFS) Controller.
//               This module monitors an "activity" signal and adjusts the
//               frequency selection output accordingly. It also supports an
//               APB interface for software override of the frequency setting.
//               [Revised: Combined multiple always_ff blocks into one]
// Author : [Your Name]
//***************************************************************************
module avfs_controller (
  input  logic        clk,        // System/reference clock
  input  logic        rst_n,      // Active-low reset
  input  logic        activity,   // Workload activity indicator (1 = high activity)
  output logic [3:0]  freq_sel,   // Frequency selection output (to drive clock divider/PLL)
  // APB interface for override control
  input  logic        apb_sel,    // APB chip-select for AVFS registers
  input  logic        apb_we,     // APB write enable
  input  logic [7:0]  apb_addr,   // APB address (only address 0 is used)
  input  logic [31:0] apb_wdata,  // APB write data (bit0: override enable; bits[4:1]: manual frequency setting)
  output logic [31:0] apb_rdata   // APB read data for status/override monitoring
);

  // Internal registers
  logic [3:0]   freq_setting;  // Frequency setting register (driving freq_sel)
  logic         override_en;   // Indicates if APB override is active

  // State machine for adaptive frequency control
  typedef enum logic [1:0] {IDLE, ACTIVE} state_t;
  state_t state;

  // Combined always_ff block for FSM and APB override updates.
  // This block ensures that freq_setting is updated in a single process.
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= IDLE;
      override_en  <= 1'b0;
      freq_setting <= 4'hF;  // Default: highest frequency (lowest division)
    end else begin
      // APB override has priority.
      if (apb_sel && apb_we && (apb_addr == 8'd0)) begin
        override_en  <= apb_wdata[0];
        freq_setting <= apb_wdata[4:1];
      end else if (!override_en) begin
        // Update FSM state based on the activity signal.
        state <= (activity) ? ACTIVE : IDLE;
        // Simple frequency selection policy:
        // When activity is high, set freq_setting to 4'hA (lower frequency)
        // When activity is low, set freq_setting to 4'hF (higher frequency)
        case (state)
          IDLE:   freq_setting <= (activity) ? 4'hA : 4'hF;
          ACTIVE: freq_setting <= (activity) ? 4'hA : 4'hF;
          default: freq_setting <= 4'hF;
        endcase
      end
      // If override_en is high, freq_setting remains fixed from the APB write.
    end
  end

  // Drive the output frequency selection signal directly from freq_setting.
  assign freq_sel = freq_setting;

  // APB read interface (combinational logic)
  always_comb begin
    if (apb_sel && !apb_we)
      case (apb_addr)
        8'd0: apb_rdata = {28'b0, freq_setting, override_en};
        8'd4: apb_rdata = 32'hDEADBEEF;  // Example status value
        default: apb_rdata = 32'b0;
      endcase
    else
      apb_rdata = 32'b0;
  end

endmodule
