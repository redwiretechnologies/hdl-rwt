

module axis_terminate_on_reset #(
  parameter UWIDTH = 1,
  parameter DWIDTH = 32
)(
  // Register Interface
  input               clk,
  input               rstn,
  input               user_reset,

  output              s_ready,
  input               s_valid,
  input               s_last,
  input [DWIDTH-1:0]  s_data,
  input [UWIDTH-1:0]  s_user,

  input               m_ready,
  output              m_valid,
  output              m_last,
  output [DWIDTH-1:0] m_data,
  output [UWIDTH-1:0] m_user);


  reg                 terminate;
  reg                 in_frame;

  assign s_ready = terminate ? 1'b0 : m_ready;
  assign m_valid = terminate ? 1'b1 : s_valid;
  assign m_last = terminate ? 1'b1 : s_last;
  assign m_data = s_data;
  assign m_user = s_user;

  always @(posedge clk) begin
    if (rstn == 1'b0) begin
      in_frame <= 1'b0;
    end else begin
      if (m_ready && m_valid) begin
        in_frame <= ~m_last;
      end
    end
  end

  always @(posedge clk) begin
    if (rstn == 1'b0) begin
      terminate <= 1'b0;
    end else begin
      if (terminate && m_ready) begin
        terminate <= 1'b0;
      end else if (user_reset && in_frame) begin
        terminate <= 1'b1;
      end
    end
  end

endmodule
