
`timescale 1ns/100ps

module rwt_common_adc_if (
  // Register Interface
  input             up_clk,
  input             up_rstn,
  input             up_wreq,
  input [8:0]       up_waddr,
  input [31:0]      up_wdata,
  output reg        up_wack,
  input             up_rreq,
  input [8:0]       up_raddr,
  output reg [31:0] up_rdata,
  output reg        up_rack,

  // 9361 interface
  input             adc_rst,
  input             adc_clk,
  input [63:0]      adc_data,
  input [3:0]       adc_enable,
  input [3:0]       adc_valid,
  output reg        adc_overflow,

  // Master user interface
  input             m_user_aclk,
  input             m_user_aresetn,
  input             m_user_ready,
  output            m_user_valid,
  output [63:0]     m_user_data,
  output [3:0]      m_user_enables,
  output [9:0]      m_user_level,

  // Slave user interface
  input             s_user_aclk,
  input             s_user_aresetn,
  output            s_user_ready,
  input             s_user_valid,
  input [63:0]      s_user_data,
  input             s_user_tag_valid,
  input [6:0]       s_user_tag_type,
  input             s_user_last,

  // DMA interface
  input             m_dma_aclk,
  input             m_dma_aresetn,
  input             m_dma_ready,
  output            m_dma_valid,
  output [63:0]     m_dma_data,
  output [0:0]      m_dma_user,
  output            m_dma_last);

  /****************************************************************************
   * Register Interface
   ***************************************************************************/
  integer    i;
  integer    j;
  reg [31:0] up_wdata_reg [0:2];
  reg [2:0]  up_reg_updated;

  always @(negedge up_rstn or posedge up_clk) begin

    if (up_rstn == 0) begin
      up_reg_updated <= 'd0;
      up_wack <= 1'b0;
      up_wdata_reg[0] <= 32'h00000000;
      up_wdata_reg[1] <= 32'hAAAAAAAA;
      up_wdata_reg[2] <= 32'hAAAAAAAA;

    end else begin

      up_reg_updated <= 'd0;
      up_wack <= up_wreq;

      if (up_wreq == 1'b1) begin
        for (i = 0; i < 3; i = i + 1) begin
          if (up_waddr == i) begin
            up_reg_updated[i] <= 1'b1;
            up_wdata_reg[i] <= up_wdata;
          end
        end
      end
    end
  end

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      up_rack <= 1'b0;
      up_rdata <= 'd0;
    end else begin
      up_rack <= up_rreq;
      if (up_rreq == 1'b1) begin
        up_rdata <= 'd0;
        case (up_raddr)
          9'h0: up_rdata[0] <= up_wdata_reg[0][0];
          9'h1: up_rdata <= up_wdata_reg[1];
          9'h2: up_rdata <= up_wdata_reg[2];
          default: ;
        endcase
      end
    end
  end

  /****************************************************************************
   * ADC Interface
   ***************************************************************************/
  reg           adc_valid_reg;
  reg [3:0]     adc_enable_reg;
  reg [63:0]    adc_data_reg;
  wire          adc_ready;
  wire          adc_rstn;

  assign adc_rstn = ~adc_rst;

  always @(posedge adc_clk) begin
    if (adc_rst == 1'b1) begin
      adc_data_reg <= 'd0;
    end else begin
      for (j = 0; j < 4; j = j + 1) begin
        if (adc_enable[j] && adc_valid[j]) begin
          adc_data_reg[j*16 +: 16] <= adc_data[j*16 +: 16];
        end
      end
    end
  end

  always @(posedge adc_clk)
    if (adc_rst == 1'b1)
      adc_enable_reg  <= 'd0;
    else
      adc_enable_reg <= adc_enable;

  always @(posedge adc_clk)
    if (adc_rst == 1'b1)
      adc_valid_reg  <= 1'b0;
    else
      adc_valid_reg <= adc_valid[0];

  always @(posedge adc_clk) begin
    if (adc_rst == 1'b1) begin
      adc_overflow <= 1'b0;
    end else begin
      if (adc_valid_reg == 1'b1) begin
        adc_overflow <= ~adc_ready;
      end
    end
  end

  /****************************************************************************
   * Async FIFO: ADC -> User Code
   *   Notes:
   *     1. ADI's AsyncFifo always uses a BRAM.
   *     2. This fits into 1 36Kb BRAM with the 512 x 72 bits configuration.
   ***************************************************************************/
  util_axis_fifo #(
    .DATA_WIDTH(68),
    .ASYNC_CLK(1),
    .ADDRESS_WIDTH(9),
    .S_AXIS_REGISTERED(1))
  u_async_fifo_adc (

    // AD9361 side
    .s_axis_aclk(adc_clk),
    .s_axis_aresetn(adc_rstn),
    .s_axis_ready(adc_ready),
    .s_axis_valid(adc_valid_reg),
    .s_axis_data({adc_data_reg, adc_enable_reg}),
    .s_axis_empty(),
    .s_axis_room(),

    // User Input Side
    .m_axis_aclk(m_user_aclk),
    .m_axis_aresetn(m_user_aresetn),
    .m_axis_ready(m_user_ready),
    .m_axis_valid(m_user_valid),
    .m_axis_data({m_user_data, m_user_enables}),
    .m_axis_level(m_user_level));

  /****************************************************************************
   * Async FIFO: User -> Tag Inserter
   ***************************************************************************/
  wire         m_tag_aclk;
  wire         m_tag_aresetn;
  wire         m_tag_ready;
  wire         m_tag_valid;
  wire [63:0]  m_tag_data;
  wire         m_tag_last;

  wire         reg_use_tags;
  wire         reg_escape_updated;
  reg [63:0]   reg_tag_escape;

  sync_bits i_sync_use_tags (
    .out_clk(s_user_aclk),
    .out_resetn(s_user_aresetn),
    .in_bits(up_wdata_reg[0][0]),
    .out_bits(reg_use_tags));

  sync_bits i_sync_escape (
    .out_clk(s_user_aclk),
    .out_resetn(s_user_aresetn),
    .in_bits(up_reg_updated[2]),
    .out_bits(reg_escape_updated));

  always @(posedge s_user_aclk)
  begin
    if (s_user_aresetn == 1'b0) begin
      reg_tag_escape <= 64'hAAAAAAAAAAAAAAAA;
    end else begin
      if (reg_escape_updated) begin
        reg_tag_escape <= {up_wdata_reg[1], up_wdata_reg[2]};
      end
    end
  end

  rwt_tag_insert u_tag_insert (
    // User Output Side
    .clk(s_user_aclk),
    .aresetn(s_user_aresetn),

    .use_tags(reg_use_tags),
    .tag_escape(reg_tag_escape),

    .s_axi_ready(s_user_ready),
    .s_axi_valid(s_user_valid),
    .s_axi_data(s_user_data),
    .s_axi_tag_valid(s_user_tag_valid),
    .s_axi_tag_type(s_user_tag_type),
    .s_axi_last(s_user_last),

    .m_axi_ready(m_tag_ready),
    .m_axi_valid(m_tag_valid),
    .m_axi_data(m_tag_data),
    .m_axi_last(m_tag_last));

  assign m_tag_aclk = s_user_aclk;
  assign m_tag_aresetn = s_user_aresetn;

  /****************************************************************************
   * Async FIFO: User -> DMA
   *   Notes:
   *     1. ADI's AsyncFifo always uses a BRAM.
   *     2. This fits into 1 36Kb BRAM with the 512 x 72 bits configuration.
   ***************************************************************************/
  util_axis_fifo #(
    .DATA_WIDTH(65),
    .ASYNC_CLK(1),
    .ADDRESS_WIDTH(9),
    .S_AXIS_REGISTERED(1))
  u_async_fifo_user (

    // User Output Side
    .s_axis_aclk(m_tag_aclk),
    .s_axis_aresetn(m_tag_aresetn),
    .s_axis_ready(m_tag_ready),
    .s_axis_valid(m_tag_valid),
    .s_axis_data({m_tag_data, m_tag_last}),
    .s_axis_empty(),
    .s_axis_room(),

    // DMA - side
    .m_axis_aclk(m_dma_aclk),
    .m_axis_aresetn(m_dma_aresetn),
    .m_axis_ready(m_dma_ready),
    .m_axis_valid(m_dma_valid),
    .m_axis_data({m_dma_data, m_dma_last}),
    .m_axis_level());

  assign m_dma_user[0] = 1'b1;

endmodule
