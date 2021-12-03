module rwt_tag_insert_mux (
  input         clk,
  input         aresetn,

  input         s_tag_valid,
  output reg    s_tag_ready,
  input [6:0]   s_tag_type,
  input [55:0]  s_tag_data,

  input         s_valid,
  output reg    s_ready,
  input [63:0]  s_data,
  input         s_last,

  output        m_valid,
  input         m_ready,
  output [63:0] m_data,
  output        m_tag_valid,
  output [6:0]  m_tag_type,
  output        m_last);

  reg           send_tag;
  reg           ff_valid;
  wire          ff_ready;
  reg [65:0]    ff_data;
  wire [65:0]   ff_out_data;

  always @(*) begin
    if (send_tag) begin
      s_tag_ready <= ff_ready & s_valid;
      s_ready <= 1'b0;
      ff_valid <= s_tag_valid & s_valid;
      ff_data <= {s_tag_valid, 1'b0, 1'b0, s_tag_type, s_tag_data};
    end else begin
      s_tag_ready <= 1'b0;
      s_ready <= ff_ready;
      ff_valid <= s_valid;
      ff_data <= {1'b0, s_last, s_data};
    end
  end

  always @(posedge clk) begin
    if (aresetn == 1'b0) begin
      send_tag <= 1'b0;
    end else begin
      if (ff_valid & ff_ready)
        if (send_tag)
          send_tag <= 1'b0;
        else
          send_tag <= s_tag_valid;
    end
  end

  axis_flipflop #(
    .DSIZE(66))
  flop (
    .clk(clk),
    .resetn(aresetn),

    .s_valid(ff_valid),
    .s_ready(ff_ready),
    .s_data(ff_data),

    .m_valid(m_valid),
    .m_ready(m_ready),
    .m_data(ff_out_data));

  assign m_data = ff_out_data[63:0];
  assign m_last = ff_out_data[64];
  assign m_tag_valid = ff_out_data[65];
  assign m_tag_type = ff_out_data[62:56];

endmodule
