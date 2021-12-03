module default_block_dac_hold (
  input             clk,
  input             resetn,

  input [55:0]      sample_idx,
  input             cfg_hold_enabled,
  output reg [55:0] sample_diff,
  output            sample_diff_valid,
  output reg        tx_active,

  input             s_valid,
  output reg        s_ready,
  input [63:0]      s_data,
  input             s_tag_valid,
  input [6:0]       s_tag_type,

  output            m_valid,
  input             m_ready,
  output [63:0]     m_data);

`include "rwt_tag_types.vh"

  localparam S_PASSTHROUGH = 3'b001;
  localparam S_WAIT = 3'b010;
  localparam S_HOLD = 3'b100;

  reg [2:0]     state;
  reg           in_pkt;
  wire          sample_go;
  wire          hold_tag_valid;

  reg [55:0]    hold_idx;

  reg           ff_valid;
  reg [63:0]    ff_data;
  wire          ff_ready;
  wire          sob_tag_valid;
  wire          eob_tag_valid;


  assign sample_diff_valid = state == S_HOLD;

  assign sample_go = sample_diff[55] || (sample_diff == 0);

  assign hold_tag_valid =
      (cfg_hold_enabled && s_tag_valid && (s_tag_type == RWT_TAG_HOLD));

  assign sob_tag_valid = (s_tag_valid && (s_tag_type == RWT_TAG_SOB));
  assign eob_tag_valid = (s_tag_valid && (s_tag_type == RWT_TAG_EOB));

  always @(posedge clk)
    if (resetn == 1'b0)
      sample_diff <= 'd0;
    else
      sample_diff <= hold_idx - (sample_idx + 2);

  always @(posedge clk)
    begin
      if (resetn == 1'b0) begin
        state <= S_PASSTHROUGH;
        hold_idx <= 'd0;
        tx_active <= 1'b0;
        in_pkt <= 1'b1;
      end else begin
        if (state == S_PASSTHROUGH) begin
          if (s_valid && ff_ready) begin
            if (hold_tag_valid) begin
              state <= S_WAIT;
              hold_idx <= s_data[55:0];
              tx_active <= 1'b0;
            end else if (eob_tag_valid) begin
              tx_active <= 1'b0;
              in_pkt <= 1'b0;
            end else if (sob_tag_valid || in_pkt) begin
              tx_active <= 1'b1;
              in_pkt <= 1'b1;
            end
          end
        end else if (state == S_WAIT) begin
          state <= S_HOLD;
        end else begin
          if (sample_go || ~cfg_hold_enabled) begin
            state <= S_PASSTHROUGH;
            in_pkt <= 1'b1;
          end
        end
      end
    end

  always @(*)
    begin
      if (state == S_PASSTHROUGH) begin
          // In default state, if in_pkt then pass through all non-tagged
          // data. If in_pkt=0, drop the data and send 0's.
          // Note: ~s_tag_valid condition causes tags to be dropped here.
          s_ready <= ff_ready;
          ff_valid <= s_valid && ~s_tag_valid;

          if (in_pkt)
            ff_data <= s_data;
          else
            ff_data <= 'd0;

      end else begin
        // In HOLD state, block input and pass 0 to DAC.
        s_ready <= 1'b0;
        ff_valid <= 1'b1;
        ff_data <= 'd0;
      end
    end

  // Breaks up the combinatorial logic.
  axis_flipflop #(
    .DSIZE(64))
  axis_flipflop (
    .clk(clk),
    .resetn(resetn),

    .s_valid(ff_valid),
    .s_ready(ff_ready),
    .s_data(ff_data),

    .m_valid(m_valid),
    .m_data(m_data),
    .m_ready(m_ready));

endmodule
