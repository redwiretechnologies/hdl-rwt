// SPDX-License-Identifier: Apache-2.0

module rwt_sample_unpack #(
  parameter UWIDTH = 1
)(
  input               clk,
  input               aresetn,

  output              s_axi_ready,
  input               s_axi_valid,
  input [3:0]         s_axi_enables,
  input [63:0]        s_axi_data,
  input [UWIDTH-1:0]  s_axi_user,
  input               s_axi_last,

  input               m_axi_ready,
  output              m_axi_valid,
  output [63:0]       m_axi_data,
  output [UWIDTH-1:0] m_axi_user,
  output              m_axi_last
);

  wire [1:0]          enable_reduce;

  wire                prefifo_ready;
  wire                prefifo_valid;
  wire [1:0]          prefifo_enables;
  wire [63:0]         prefifo_data;
  wire                prefifo_last;
  wire [UWIDTH-1:0]   prefifo_user;

  reg                 hold_valid, hold_valid_s;
  reg [31:0]          hold_data, hold_data_s;
  reg                 hold_last, hold_last_s;
  reg                 hold_pos, hold_pos_s;

  wire                postfifo_ready;
  reg                 postfifo_valid;
  reg [63:0]          postfifo_data;
  reg [UWIDTH-1:0]    postfifo_user;
  reg                 postfifo_last;

  assign enable_reduce[0] = |s_axi_enables[1:0];
  assign enable_reduce[1] = |s_axi_enables[3:2];

  util_axis_fifo #(
    .DATA_WIDTH(67+UWIDTH),
    .ASYNC_CLK(0),
    .ADDRESS_WIDTH(1),
    .M_AXIS_REGISTERED(1))
  pre_fifo (
    .s_axis_aclk(clk),
    .s_axis_aresetn(aresetn),
    .s_axis_ready(s_axi_ready),
    .s_axis_valid(s_axi_valid),
    .s_axis_data({s_axi_data, enable_reduce, s_axi_last, s_axi_user}),
    .s_axis_full(),
    .s_axis_room(),

    .m_axis_aclk(clk),
    .m_axis_aresetn(aresetn),
    .m_axis_ready(prefifo_ready),
    .m_axis_valid(prefifo_valid),
    .m_axis_data({prefifo_data, prefifo_enables, prefifo_last, prefifo_user}),
    .m_axis_empty(),
    .m_axis_level());

  assign prefifo_ready = postfifo_ready & ~hold_valid;

  always @(*)
  begin
    hold_valid_s <= hold_valid;
    hold_data_s <= hold_data;
    hold_last_s <= hold_last;
    hold_pos_s <= hold_pos;
    postfifo_valid <= 1'b0;
    postfifo_last <= 1'b0;
    postfifo_data <= 'd0;
    postfifo_user = 'd0;

    if (~hold_valid) begin
      if (prefifo_enables[0] & prefifo_enables[1]) begin
        postfifo_valid <= prefifo_valid;
        postfifo_last <= prefifo_last;
        postfifo_data <= prefifo_data;
        postfifo_user = prefifo_user;
      end else if (postfifo_ready) begin
        hold_valid_s <= prefifo_valid;
        hold_last_s <= prefifo_last;
        postfifo_valid <= prefifo_valid;
        postfifo_last <= 1'b0;
        postfifo_data <= 'd0;
        postfifo_user = prefifo_user;
        hold_data_s <= prefifo_data[31:0];
        hold_pos_s <= prefifo_enables[0];

        if (prefifo_enables[0])
          postfifo_data[31:0] <= prefifo_data[63:32];
        else
          postfifo_data[63:32] <= prefifo_data[63:32];
      end

    end else if (postfifo_ready) begin

      hold_valid_s <= 1'b0;
      postfifo_valid <= 1'b1;
      postfifo_last <= hold_last;
      postfifo_data <= 'd0;
      postfifo_user = 'd0;

      if (hold_pos)
        postfifo_data[31:0] <= hold_data;
      else
        postfifo_data[63:32] <= hold_data;
    end
  end

  always @(posedge clk)
  begin
    if (aresetn == 1'b0) begin
      hold_valid <= 1'b0;
      hold_data <= 'd0;
      hold_last <= 1'b0;
      hold_pos <= 1'b0;
    end else begin
      hold_valid <= hold_valid_s;
      hold_data <= hold_data_s;
      hold_last <= hold_last_s;
      hold_pos <= hold_pos_s;
    end
  end

  util_axis_fifo #(
    .DATA_WIDTH(65+UWIDTH),
    .ASYNC_CLK(0),
    .ADDRESS_WIDTH(1),
    .M_AXIS_REGISTERED(1))
  post_fifo (
    .s_axis_aclk(clk),
    .s_axis_aresetn(aresetn),
    .s_axis_ready(postfifo_ready),
    .s_axis_valid(postfifo_valid),
    .s_axis_data({postfifo_data, postfifo_last, postfifo_user}),
    .s_axis_full(),
    .s_axis_room(),

    .m_axis_aclk(clk),
    .m_axis_aresetn(aresetn),
    .m_axis_ready(m_axi_ready),
    .m_axis_valid(m_axi_valid),
    .m_axis_data({m_axi_data, m_axi_last, m_axi_user}),
    .m_axis_empty(),
    .m_axis_level());

endmodule
