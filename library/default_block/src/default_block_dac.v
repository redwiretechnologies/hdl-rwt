// SPDX-License-Identifier: Apache-2.0

/****************************************************************************
 * DAC
 *   Unpack the data. If only one channel is enabled, it unpacks one 64-bit
 *   DMA word into two DAC samples on the enabled channel. The disabled
 *   channel outputs 0. If both are enabled, this is a default.
 ***************************************************************************/
`timescale 1ns/100ps

module default_block_dac (
  input         clk,
  input         resetn,

  input         cfg_enabled,
  input [55:0]  sample_idx,
  input         cfg_hold_enabled,
  output [55:0] status_hold_diff,
  output        status_hold_diff_valid,
  output reg    dac_underflow,
  output        tx_active,

  // Slave DAC interface -- From DMA
  output        s_dma_ready,
  input         s_dma_valid,
  input [63:0]  s_dma_data,
  input         s_dma_tag_valid,
  input [6:0]   s_dma_tag_type,
  input         s_dma_last,

  // Master DAC interface -- To 9361
  input         m_rf_ready,
  output        m_rf_valid,
  input [3:0]   m_rf_enables,
  input         m_rf_empty,
  input [9:0]   m_rf_room,
  output [63:0] m_rf_data);

`include "rwt_tag_types.vh"

  wire          unpack_ready;
  wire          unpack_valid;
  wire [63:0]   unpack_data;
  wire          unpack_tag_valid;
  wire [6:0]    unpack_tag_type;
  wire [3:0]    enables;
  wire          hold_valid;
  reg           fifo_almost_full;

  assign enables = s_dma_tag_valid ? 4'hf : m_rf_enables;

  rwt_sample_unpack #(
    .UWIDTH(8))
  rwt_sample_unpack (
    .clk(clk),
    .aresetn(resetn),

    .s_axi_ready(s_dma_ready),
    .s_axi_valid(s_dma_valid),
    .s_axi_enables(enables),
    .s_axi_data(s_dma_data),
    .s_axi_user({s_dma_tag_valid, s_dma_tag_type}),
    .s_axi_last(1'b0),

    .m_axi_ready(unpack_ready),
    .m_axi_valid(unpack_valid),
    .m_axi_data(unpack_data),
    .m_axi_user({unpack_tag_valid, unpack_tag_type}),
    .m_axi_last());

  default_block_dac_hold dac_hold (
    .clk(clk),
    .resetn(resetn),

    .sample_idx(sample_idx),
    .cfg_hold_enabled(cfg_hold_enabled),
    .sample_diff(status_hold_diff),
    .sample_diff_valid(status_hold_diff_valid),
    .tx_active(tx_active),

    .s_valid(unpack_valid),
    .s_ready(unpack_ready),
    .s_data(unpack_data),
    .s_tag_valid(unpack_tag_valid),
    .s_tag_type(unpack_tag_type),

    .m_valid(hold_valid),
    .m_data(m_rf_data),
    .m_ready(m_rf_ready));


  // If the FIFO is close to filling up, we have to add more samples so
  // that it doesn't cause an actual overflow which would screw up the
  // sample count. I'm intentionally using >503 because 504 == 0x1f8 and
  // a >503 comparison is equivalent count[8:3] == 0x3f.
  always @(posedge clk)
    if (resetn == 1'b0)
      fifo_almost_full <= 1'b0;
    else
      fifo_almost_full <= (m_rf_room > 503);

  // Assert overflow whenever the FIFO is empty, and we are in a packet.
  always @(posedge clk)
    if (resetn == 1'b0)
      dac_underflow <= 1'b0;
    else
      dac_underflow <= fifo_almost_full && tx_active && ~hold_valid && ~dac_underflow;

  assign m_rf_valid = fifo_almost_full | hold_valid;

endmodule
