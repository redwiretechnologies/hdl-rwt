
`timescale 1ns/100ps

module rwt_tag_insert #(
  parameter DWIDTH = 64,
  parameter TYPE_WIDTH = 7
)(
  input                  clk,
  input                  aresetn,

  input                  use_tags,
  input [DWIDTH-1:0]     tag_escape,

  output                 s_axi_ready,
  input                  s_axi_valid,
  input [DWIDTH-1:0]     s_axi_data,
  input                  s_axi_tag_valid,
  input [TYPE_WIDTH-1:0] s_axi_tag_type,
  input                  s_axi_last,

  input                  m_axi_ready,
  output                 m_axi_valid,
  output [DWIDTH-1:0]    m_axi_data,
  output                 m_axi_last);

  localparam MORE_FLAG = DWIDTH - 1;
  localparam TAG_WIDTH = DWIDTH - 1 - TYPE_WIDTH;

  reg                    send_reg;
  reg                    store_reg;

  reg                    reg_valid;
  reg                    reg_tagged;
  reg                    reg_last;
  reg [TYPE_WIDTH-1:0]   reg_tag_type;
  reg [DWIDTH-1:0]       reg_data;

  wire                   escape_ready;
  reg                    escape_valid;
  reg                    escape_flag;
  reg [DWIDTH-1:0]       escape_data;
  reg                    escape_last;
  reg                    escape_first_tag;

  assign s_axi_ready = s_ready;
  assign s_ready = ~reg_valid || ~escape_valid || escape_ready;

  always @(*)
  begin
    send_reg <= 1'b0;
    store_reg <= 1'b0;

    if (escape_valid && escape_ready) begin
      send_reg <= reg_valid & ~reg_tagged;
    end

    if (s_ready && s_axi_valid) begin
      store_reg <= 1'b1;
      send_reg <= reg_valid;
    end
  end

  always @(posedge clk)
  begin
    if (aresetn == 1'b0) begin
      reg_valid <= 1'b0;
      reg_tagged <= 1'b0;
      reg_last <= 1'b0;
      reg_tag_type <= 'd0;
      reg_data <= 'd0;
    end else begin
      if (store_reg) begin
        reg_valid <= 1'b1;
        reg_tagged <= use_tags & s_axi_tag_valid;
        reg_last <= s_axi_last;
        reg_tag_type <= s_axi_tag_type;
        reg_data <= s_axi_data;
      end else if (send_reg) begin
        reg_valid <= 1'b0;
      end
    end
  end

  always @(posedge clk)
  begin
    if (aresetn == 1'b0) begin
      escape_valid <= 1'b0;
      escape_data <= 'd0;
      escape_last <= 1'b0;
      escape_flag <= 1'b0;
      escape_first_tag <= 1'b1;
    end else begin
      if (escape_ready) begin
        escape_valid <= 1'b0;
      end

      if (send_reg) begin
        escape_valid <= 1'b1;
        if (~reg_tagged) begin

          if (use_tags && (reg_data == tag_escape)) begin
            escape_flag <= 1'b1;
            escape_data <= 'd0;
          end else begin
            escape_flag <= 1'b0;
            escape_data <= reg_data;
          end

          escape_last <= reg_last;
          escape_first_tag <= 1'b1;

        end else begin
          if (s_axi_tag_valid) begin
            escape_data[MORE_FLAG] <= 1'b1;
            escape_last <= 1'b0;
          end else begin
            escape_data[MORE_FLAG] <= 1'b0;
            escape_last <= reg_last;
          end

          escape_flag <= escape_first_tag;
          escape_first_tag <= 1'b0;
          escape_data[TAG_WIDTH +: TYPE_WIDTH] <= reg_tag_type;
          escape_data[0 +: TAG_WIDTH] <= reg_data[0 +: TAG_WIDTH];
        end
      end
    end
  end

  rwt_tag_insert_escape #(
    .DWIDTH(DWIDTH))
  insert_escape (
    .clk(clk),
    .aresetn(aresetn),

    .tag_escape(tag_escape),

    .s_axi_ready(escape_ready),
    .s_axi_valid(escape_valid),
    .s_axi_escape(escape_flag),
    .s_axi_data(escape_data),
    .s_axi_last(escape_last),

    .m_axi_ready(m_axi_ready),
    .m_axi_valid(m_axi_valid),
    .m_axi_data(m_axi_data),
    .m_axi_last(m_axi_last));

endmodule
