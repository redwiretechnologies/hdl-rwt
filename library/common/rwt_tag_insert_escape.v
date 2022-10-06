module rwt_tag_insert_escape #(
  parameter DWIDTH = 64)
(
  input               clk,
  input               aresetn,

  input [DWIDTH-1:0]  tag_escape,

  output reg          s_axi_ready,
  input               s_axi_valid,
  input               s_axi_escape,
  input [DWIDTH-1:0]  s_axi_data,
  input               s_axi_last,

  input               m_axi_ready,
  output              m_axi_valid,
  output [DWIDTH-1:0] m_axi_data,
  output              m_axi_last
);

  localparam ST_PASS = 3'b001;
  localparam ST_ESCAPE = 3'b010;
  localparam ST_SEND_DATA = 3'b100;

  reg [2:0]           state;
  wire                fifo_ready;
  wire                fifo_valid;
  reg [DWIDTH-1:0]    fifo_data;
  reg                 fifo_last;

  assign fifo_valid = s_axi_valid;

  always @(*)
  begin
    if (state == ST_PASS) begin
      if (s_axi_escape) begin
        fifo_data <= tag_escape;
        fifo_last <= 1'b0;
        s_axi_ready <= 1'b0;
      end else begin
        fifo_data <= s_axi_data;
        fifo_last <= s_axi_last;
        s_axi_ready <= fifo_ready;
      end
    end else if (state == ST_ESCAPE) begin
      fifo_data <= tag_escape;
      fifo_last <= 1'b0;
      s_axi_ready <= 1'b0;
    end else if (state == ST_SEND_DATA) begin
      fifo_data <= s_axi_data;
      fifo_last <= s_axi_last;
      s_axi_ready <= fifo_ready;
    end else begin
      fifo_data <= 'd0;
      fifo_last <= 1'b0;
      s_axi_ready <= 1'b0;
    end
  end

  always @(posedge clk)
  begin
    if (aresetn == 1'b0) begin
      state <= ST_PASS;
    end else begin
      case(state)
        ST_PASS :
          if (s_axi_valid) begin
            if (s_axi_escape) begin
              if (fifo_ready) begin
                state <= ST_SEND_DATA;
              end else begin
                state <= ST_ESCAPE;
              end
            end
          end

        ST_ESCAPE :
          if (fifo_ready) begin
            state <= ST_SEND_DATA;
          end

        ST_SEND_DATA :
          if (fifo_ready) begin
            state <= ST_PASS;
          end
      endcase
    end
  end

  util_axis_fifo #(
    .DATA_WIDTH(DWIDTH+1),
    .ASYNC_CLK(0),
    .ADDRESS_WIDTH(2),
    .M_AXIS_REGISTERED(1))
  sync_fifo (
    .s_axis_aclk(clk),
    .s_axis_aresetn(aresetn),
    .s_axis_ready(fifo_ready),
    .s_axis_valid(fifo_valid),
    .s_axis_data({fifo_data, fifo_last}),
    .s_axis_full(),
    .s_axis_room(),

    .m_axis_aclk(clk),
    .m_axis_aresetn(aresetn),
    .m_axis_ready(m_axi_ready),
    .m_axis_valid(m_axi_valid),
    .m_axis_data({m_axi_data, m_axi_last}),
    .m_axis_empty(),
    .m_axis_level());

endmodule
