/****************************************************************************
 * ADC
 *                          |-\
 *   ADC samples -> pack -> |  | --> DMA
 *   sample clk -> tags ->  |  |
 *                          |-/
 *
 ***************************************************************************/
`timescale 1ns/100ps

module default_block_adc(
  input         clk,
  input         resetn,

  input         pps_edge,
  output reg    adc_overflow,
  input         cfg_overflow_enabled,
  input         cfg_pps_tags_enabled,
  input [23:0]  cfg_overflow_wait,
  input [55:0]  sample_idx,

  // Slave ADC interface -- From 9361
  output        s_rf_ready,
  input         s_rf_valid,
  input [3:0]   s_rf_enables,
  input [63:0]  s_rf_data,
  input [9:0]   s_rf_level,

  // Master ADC interface -- To DMA
  input         m_dma_ready,
  output        m_dma_valid,
  output [63:0] m_dma_data,
  output        m_dma_tag_valid,
  output [6:0]  m_dma_tag_type,
  output        m_dma_last);

`include "rwt_tag_types.vh"

  reg          adc_fifo_almost_full;
  wire         s_rf_ready_s;
  wire         pack_ready;
  wire         pack_valid;
  wire [63:0]  pack_data;
  wire [55:0]  pack_sample_idx;
  reg          send_tag_valid;
  wire         send_tag_ready;
  reg [6:0]    send_tag_type;
  reg [23:0]   send_tag_overflow_wait;


  // Overflow Logic.
  //  This prevents the FIFO from actually filling up. We indicate an
  //  overflow when the FIFO is within a few samples from filling up and
  //  we can't accept any more samples.
  //
  //  This is done within this block so that we can keep an accurate
  //  sample_clk.

  assign s_rf_ready = s_rf_ready_s | adc_fifo_almost_full;

  // assert almost_full flag when fifo is 500 of 512 samples deep.
  always @(posedge clk) begin
    if (resetn == 1'b0) begin
      adc_fifo_almost_full <= 1'b0;
    end else begin
      if (s_rf_level >= 'd500)
        adc_fifo_almost_full <= 1'b1;
      else
        adc_fifo_almost_full <= 1'b0;
    end
  end

  always @(posedge clk)
    if (resetn == 1'b0)
      adc_overflow <= 1'b0;
    else
      adc_overflow <= s_rf_valid & adc_fifo_almost_full & ~s_rf_ready_s;

  // Pack samples. If only one channel is enabled, it packs two ADC samples
  // into one DMA 64-bit word. If both are enabled, it passes it straight
  // through.
  rwt_sample_pack #(
    .UWIDTH(56))
  rwt_sample_pack (
    .clk(clk),
    .aresetn(resetn),

    .s_axi_ready(s_rf_ready_s),
    .s_axi_valid(s_rf_valid),
    .s_axi_enables(s_rf_enables),
    .s_axi_data(s_rf_data),
    .s_axi_user(sample_idx),
    .s_axi_last(1'b0),

    .m_axi_ready(pack_ready),
    .m_axi_valid(pack_valid),
    .m_axi_data(pack_data),
    .m_axi_user(pack_sample_idx),
    .m_axi_last());

  // Create tags.
  //   * Sends overflow tag if overflow occurs (note that it's throttled
  //     by send_tag_overflow_wait).
  //   * Sends PPS tag with timestamp every pps.
  always @(posedge clk) begin
    if (resetn == 1'b0) begin
      send_tag_valid <= 1'b0;
      send_tag_type <= RWT_TAG_PPS;
      send_tag_overflow_wait <= 'd0;
    end else begin
      if (send_tag_ready)
        send_tag_valid <= 1'b0;

      if (pack_valid & pack_ready & (send_tag_overflow_wait != 0))
        send_tag_overflow_wait <= send_tag_overflow_wait - 1;

      if (adc_overflow & cfg_overflow_enabled & (send_tag_overflow_wait == 0)) begin
        send_tag_valid <= 1'b1;
        send_tag_type <= RWT_TAG_OVERFLOW;
        send_tag_overflow_wait <= cfg_overflow_wait;
      end else if (pps_edge & cfg_pps_tags_enabled & ~send_tag_valid) begin
        send_tag_valid <= 1'b1;
        send_tag_type <= RWT_TAG_PPS;
      end
    end
  end

  // Insert tags into the stream.
  rwt_tag_insert_mux adc_tag_insert_mux(
    .clk(clk),
    .aresetn(resetn),

    .s_tag_valid(send_tag_valid),
    .s_tag_ready(send_tag_ready),
    .s_tag_data(pack_sample_idx),
    .s_tag_type(send_tag_type),

    .s_data(pack_data),
    .s_valid(pack_valid),
    .s_ready(pack_ready),
    .s_last(1'b0),

    .m_valid(m_dma_valid),
    .m_ready(m_dma_ready),
    .m_data(m_dma_data),
    .m_tag_valid(m_dma_tag_valid),
    .m_tag_type(m_dma_tag_type),
    .m_last());

  assign m_dma_last = 1'b0;

endmodule
