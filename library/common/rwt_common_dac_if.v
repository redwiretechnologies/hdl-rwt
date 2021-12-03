
`timescale 1ns/100ps

module rwt_common_dac_if (
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

  // DMA interface
  input             s_dma_aclk,
  input             s_dma_aresetn,
  output            s_dma_ready,
  input             s_dma_valid,
  input [63:0]      s_dma_data,
  input             s_dma_last,

  // Master user interface
  input             m_user_aclk,
  input             m_user_aresetn,
  input             m_user_ready,
  output            m_user_valid,
  output [63:0]     m_user_data,
  output            m_user_tag_valid,
  output [6:0]      m_user_tag_type,
  output            m_user_last,

  // Slave user interface
  input             s_user_aclk,
  input             s_user_aresetn,
  output            s_user_ready,
  input             s_user_valid,
  input [63:0]      s_user_data,
  output [3:0]      s_user_enables,
  output            s_user_empty,
  output [9:0]      s_user_room,

  // 9361 interface
  input             dac_rst,
  input             dac_clk,
  output reg [63:0] dac_data,
  input [3:0]       dac_enable,
  input [3:0]       dac_valid,
  output reg        dac_underflow);

  /****************************************************************************
   * Register Interface
   ***************************************************************************/
  reg [31:0]    up_wdata_reg [0:7];
  reg [7:0]     up_reg_updated;
  integer       i;
  integer       j;
  integer       k;

  always @(negedge up_rstn or posedge up_clk) begin
    if (up_rstn == 0) begin
      for (i = 0; i < 8; i = i + 1) begin
        up_wdata_reg[i] <= 'd0;
      end

      up_reg_updated <= 'd0;
      up_wack <= 1'b0;
      up_wdata_reg[1] <= 32'hAAAAAAAA;
      up_wdata_reg[2] <= 32'hAAAAAAAA;
      up_wdata_reg[7] <= 32'hABBABAAB;

    end else begin

      up_reg_updated <= 'd0;
      up_wack <= up_wreq;

      if (up_wreq == 1'b1) begin
        for (k = 0; k < 8; k = k + 1) begin
          if (up_waddr == k) begin
            up_reg_updated[k] <= 1'b1;
            up_wdata_reg[k] <= up_wdata;
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
        case (up_raddr)
          9'h0: up_rdata <= up_wdata_reg[0];
          9'h1: up_rdata <= up_wdata_reg[1];
          9'h2: up_rdata <= up_wdata_reg[2];
          9'h3: up_rdata <= up_wdata_reg[3];
          9'h4: up_rdata <= up_wdata_reg[4];
          9'h5: up_rdata <= up_wdata_reg[5];
          9'h6: up_rdata <= up_wdata_reg[6];
          9'h7: up_rdata <= up_wdata_reg[7];
          default: up_rdata <= 0;
        endcase
      end
    end
  end

  /****************************************************************************
   * Async FIFO: DMA -> Tag
   *   Notes:
   *     1. ADI's AsyncFifo always uses a BRAM.
   *     2. This fits into 1 36Kb BRAM with the 512 x 72 bits configuration.
   ***************************************************************************/
  wire        m_tag_aclk;
  wire        m_tag_aresetn;
  wire        m_tag_ready;
  wire        m_tag_valid;
  wire [63:0] m_tag_data;
  wire        m_tag_last;

  assign m_tag_aclk = m_user_aclk;
  assign m_tag_aresetn = m_user_aresetn;

  util_axis_fifo #(
    .DATA_WIDTH(65),
    .ASYNC_CLK(1),
    .ADDRESS_WIDTH(9),
    .S_AXIS_REGISTERED(1))
  u_async_fifo_dma (
    .s_axis_aclk(s_dma_aclk),
    .s_axis_aresetn(s_dma_aresetn),
    .s_axis_ready(s_dma_ready),
    .s_axis_valid(s_dma_valid),
    .s_axis_data({s_dma_data, s_dma_last}),
    .s_axis_empty(),
    .s_axis_room(),

    .m_axis_aclk(m_tag_aclk),
    .m_axis_aresetn(m_tag_aresetn),
    .m_axis_ready(m_tag_ready),
    .m_axis_valid(m_tag_valid),
    .m_axis_data({m_tag_data, m_tag_last}),
    .m_axis_level());

  /****************************************************************************
   * Tag -> User
   ***************************************************************************/
  wire        reg_use_tags;
  wire        reg_escape_updated;
  reg [63:0]  reg_tag_escape;

  sync_bits i_sync_use_tags (
    .out_clk(m_user_aclk),
    .out_resetn(m_user_aresetn),
    .in_bits(up_wdata_reg[0][0]),
    .out_bits(reg_use_tags));

  sync_bits i_sync_escape (
    .out_clk(m_user_aclk),
    .out_resetn(m_user_aresetn),
    .in_bits(up_reg_updated[2]),
    .out_bits(reg_escape_updated));

  always @(posedge m_user_aclk)
  begin
    if (m_user_aresetn == 1'b0) begin
      reg_tag_escape <= 64'hAAAAAAAAAAAAAAAA;
    end else begin
      if (reg_escape_updated) begin
        reg_tag_escape <= {up_wdata_reg[1], up_wdata_reg[2]};
      end
    end
  end

  rwt_tag_extract u_tag_extract (
    // User Output Side
    .clk(m_user_aclk),
    .aresetn(m_user_aresetn),

    .use_tags(reg_use_tags),
    .tag_escape(reg_tag_escape),

    .s_axi_ready(m_tag_ready),
    .s_axi_valid(m_tag_valid),
    .s_axi_data(m_tag_data),
    .s_axi_last(m_tag_last),

    .m_axi_ready(m_user_ready),
    .m_axi_valid(m_user_valid),
    .m_axi_data(m_user_data),
    .m_axi_tag_valid(m_user_tag_valid),
    .m_axi_tag_type(m_user_tag_type),
    .m_axi_last(m_user_last));

  /****************************************************************************
   * Async FIFO: User -> ADC
   *   Notes:
   *     1. ADI's AsyncFifo always uses a BRAM.
   *     2. This fits into 1 36Kb BRAM with the 512 x 72 bits configuration.
   ***************************************************************************/
  wire        m_dac_ready;
  wire        m_dac_valid;
  wire [63:0] m_dac_data;
  wire        dac_rstn;

  assign dac_rstn = ~dac_rst;

  util_axis_fifo #(
    .DATA_WIDTH(64),
    .ASYNC_CLK(1),
    .ADDRESS_WIDTH(9),
    .S_AXIS_REGISTERED(1))
  u_async_fifo_user (

    // User side
    .s_axis_aclk(s_user_aclk),
    .s_axis_aresetn(s_user_aresetn),
    .s_axis_ready(s_user_ready),
    .s_axis_valid(s_user_valid),
    .s_axis_data(s_user_data),
    .s_axis_empty(s_user_empty),
    .s_axis_room(s_user_room),

    // 9361 Side
    .m_axis_aclk(dac_clk),
    .m_axis_aresetn(dac_rstn),
    .m_axis_ready(m_dac_ready),
    .m_axis_valid(m_dac_valid),
    .m_axis_data(m_dac_data),
    .m_axis_level());

  sync_bits #(
    .NUM_OF_BITS(4))
  i_sync_enables(
    .out_clk(s_user_aclk),
    .out_resetn(s_user_aresetn),
    .in_bits(dac_enable),
    .out_bits(s_user_enables));

  /****************************************************************************
   * DAC Interface
   ***************************************************************************/

  always @(posedge dac_clk) begin
    if (dac_rst == 1'b1) begin
      dac_data <= 'd0;
    end else begin
      for (j = 0; j < 4; j = j + 1) begin
        if (dac_enable[j] && dac_valid[j]) begin
		  dac_data[j*16 +: 16] <= m_dac_data[j*16 +: 16];
          //dac_data[(16*(j+1) - 1): (16*j)] <= m_dac_data[(16*(j+1) - 1): (16*j)];
        end
      end
    end
  end

  always @(posedge dac_clk) begin
    if (dac_rst == 1'b1) begin
      dac_underflow <= 1'b0;
    end else begin
      if (dac_valid[0]) begin
        dac_underflow <= ~m_dac_valid;
      end
    end
  end

  /* This works because it's interfacing to a FIFO. The valid will be asserted
     w/o waiting for the ready signal. If the FIFO isn't ready, the underflow
     signal will be asserted. */
  assign m_dac_ready = dac_valid[0];

endmodule
