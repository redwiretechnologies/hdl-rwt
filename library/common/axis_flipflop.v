module axis_flipflop #(
  parameter DSIZE=1
)(
  input              clk,
  input              resetn,

  input              s_valid,
  output             s_ready,
  input [DSIZE-1:0]  s_data,

  output reg         m_valid,
  input              m_ready,
  output reg [DSIZE-1:0] m_data);

  reg                register;
  reg                advance;
  reg                reg_valid;
  reg [DSIZE-1:0]    reg_data;

  assign s_ready = ~reg_valid;

  always @(*) begin
    register <= 1'b0;
    advance <= 1'b0;

    if (~m_valid | m_ready)
      advance <= 1'b1;
    else if (s_valid & ~reg_valid)
      register <= 1'b1;
  end

  always @(posedge clk) begin
    if (resetn == 1'b0) begin
      m_valid <= 1'b0;
      reg_valid <= 1'b0;
    end else begin

      if (advance) begin
        reg_valid <= 1'b0;
        m_valid <= reg_valid | s_valid;
      end

      if (register) begin
        reg_valid <= 1'b1;
      end
    end
  end

  always @(posedge clk) begin
    if (register)
      reg_data <= s_data;
  end

  always @(posedge clk) begin
    if (advance)
      m_data <= reg_valid ? reg_data : s_data;
  end

endmodule
