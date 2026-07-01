// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/100ps

module default_block_user #(
  parameter CLK_FREQ = 100000000
)(
  input         user_clk,
  input         user_resetn,
  input         dac_clk,
  input         dac_rstn,
  input         adc_clk,
  input         adc_rstn,

  input         pps_ext,
  output        adc_overflow,
  output        dac_underflow,

  // Register Interface
  input         up_clk,
  input         up_rstn,
  input         up_wreq,
  input [8:0]   up_waddr,
  input [31:0]  up_wdata,
  output        up_wack,
  input         up_rreq,
  input [8:0]   up_raddr,
  output [31:0] up_rdata,
  output        up_rack,

  // Slave ADC interface -- From 9361
  output        s_adc_aclk,
  output        s_adc_aresetn,
  output        s_adc_ready,
  input         s_adc_valid,
  input [3:0]   s_adc_enables,
  input [63:0]  s_adc_data,
  input [9:0]   s_adc_level,

  // Master ADC interface -- To DMA
  output        m_adc_aclk,
  output        m_adc_aresetn,
  input         m_adc_ready,
  output        m_adc_valid,
  output [63:0] m_adc_data,
  output        m_adc_tag_valid,
  output [6:0]  m_adc_tag_type,
  output        m_adc_last,

  // Slave DAC interface -- From DMA
  output        s_dac_aclk,
  output        s_dac_aresetn,
  output        s_dac_ready,
  input         s_dac_valid,
  input [63:0]  s_dac_data,
  input         s_dac_tag_valid,
  input [6:0]   s_dac_tag_type,
  input         s_dac_last,

  // Master DAC interface -- To 9361
  output        m_dac_aclk,
  output        m_dac_aresetn,
  input         m_dac_ready,
  output        m_dac_valid,
  input [3:0]   m_dac_enables,
  input         m_dac_empty,
  input [9:0]   m_dac_room,
  output [63:0] m_dac_data);


  assign s_adc_aclk = user_clk;
  assign m_adc_aclk = user_clk;
  assign s_dac_aclk = user_clk;
  assign m_dac_aclk = user_clk;

  assign s_adc_aresetn = user_resetn;
  assign m_adc_aresetn = user_resetn;
  assign s_dac_aresetn = user_resetn;
  assign m_dac_aresetn = user_resetn;

  /****************************************************************************
   * User Registers
   ***************************************************************************/
  wire        cfg_which_pps;
  wire [55:0] cfg_sample_idx;
  wire        cfg_sample_idx_updated;
  wire        cfg_pps_tags_enabled;
  wire        cfg_overflow_enabled;
  wire [23:0] cfg_overflow_wait;
  wire        adc_overflow_user;
  wire        dac_underflow_user;
  wire        cfg_hold_enabled;
  wire        status_hold_diff_valid;
  wire [55:0] status_hold_diff;
  wire [55:0] sample_idx_adc;
  wire [55:0] sample_idx_dac;

  default_block_regs #(
    .ASYNC_CLK(1))
  regs (
    .user_clk(user_clk),
    .user_rstn(user_resetn),

    .up_clk(up_clk),
    .up_rstn(up_rstn),
    .up_wreq(up_wreq),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack),
    .up_rreq(up_rreq),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata),
    .up_rack(up_rack),

    .dac_underflow(dac_underflow_user),
    .adc_overflow(adc_overflow_user),
    .status_hold_diff(status_hold_diff),
    .status_hold_diff_valid(status_hold_diff_valid),
    .status_sample_idx_adc(sample_idx_adc),
    .status_sample_idx_dac(sample_idx_dac),

    .cfg_which_pps(cfg_which_pps),
    .cfg_sample_idx(cfg_sample_idx),
    .cfg_sample_idx_updated(cfg_sample_idx_updated),
    .cfg_pps_tags_enabled(cfg_pps_tags_enabled),
    .cfg_overflow_enabled(cfg_overflow_enabled),
    .cfg_overflow_wait(cfg_overflow_wait),
    .cfg_hold_enabled(cfg_hold_enabled),
    .cfg_sample_idx_mode(cfg_sample_idx_mode)
  );

  /****************************************************************************
   * sample_clk
   *
   ***************************************************************************/
  wire [111:0] sample_idx;
  wire [1:0]   sample_idx_incr;
  wire         pps_edge;

  sample_clk #(
    .CLK_FREQ(CLK_FREQ),
    .SAMPLE_CLK_WIDTH(56),
    .NUM_SAMPLE_CLKS(2))
  sample_clk (
    .clk(user_clk),
    .aresetn(user_resetn),
    .which_pps(cfg_which_pps),
    .pps_ext(pps_ext),
    .sample_idx_reg(cfg_sample_idx),
    .sample_idx_reg_valid(cfg_sample_idx_updated),
    .sample_idx_incr(sample_idx_incr),
    .sample_idx(sample_idx),
    .pps(),
    .pps_edge(pps_edge));

  assign sample_idx_adc = sample_idx[55:0];
  assign sample_idx_dac = sample_idx[111:56];
  assign sample_idx_incr[0] = s_adc_ready & s_adc_valid;
  assign sample_idx_incr[1] = m_dac_ready & m_dac_valid;

  /****************************************************************************
   * ADC
   ***************************************************************************/
  default_block_adc default_block_adc(
    .clk(user_clk),
    .resetn(user_resetn),

    .pps_edge(pps_edge),
    .adc_overflow(adc_overflow_user),
    .cfg_overflow_enabled(cfg_overflow_enabled),
    .cfg_pps_tags_enabled(cfg_pps_tags_enabled),
    .cfg_overflow_wait(cfg_overflow_wait),
    .sample_idx(sample_idx_adc),

    .s_rf_ready(),
    .s_rf_valid(s_adc_valid),
    .s_rf_data(s_adc_data),
    .s_rf_enables(s_adc_enables),
    .s_rf_level(s_adc_level),

    .m_dma_ready(m_adc_ready),
    .m_dma_valid(m_adc_valid),
    .m_dma_data(m_adc_data),
    .m_dma_tag_valid(m_adc_tag_valid),
    .m_dma_tag_type(m_adc_tag_type),
    .m_dma_last(m_adc_last));

  // Sync overflow to adc_clk
  sync_event #(
    .NUM_OF_EVENTS(1),
    .ASYNC_CLK(1))
  sync_overflow (
    .in_clk(user_clk),
    .in_event(adc_overflow_user),
    .out_clk(adc_clk),
    .out_event(adc_overflow));

  /****************************************************************************
   * DAC
   ***************************************************************************/
  default_block_dac default_block_dac(
    .clk(user_clk),
    .resetn(user_resetn),

    .sample_idx(sample_idx_dac),
    .cfg_hold_enabled(cfg_hold_enabled),
    .status_hold_diff(status_hold_diff),
    .status_hold_diff_valid(status_hold_diff_valid),
    .dac_underflow(dac_underflow_user),

    .s_dma_ready(s_dac_ready),
    .s_dma_valid(s_dac_valid),
    .s_dma_data(s_dac_data),
    .s_dma_tag_valid(s_dac_tag_valid),
    .s_dma_tag_type(s_dac_tag_type),
    .s_dma_last(s_dac_last),

    .m_rf_ready(m_dac_ready),
    .m_rf_valid(m_dac_valid),
    .m_rf_data(m_dac_data),
    .m_rf_empty(m_dac_empty),
    .m_rf_room(m_dac_room),
    .m_rf_enables(m_dac_enables));

  // Sync underflow from dac_clk to user_clk domain.
  sync_event #(
    .NUM_OF_EVENTS(1),
    .ASYNC_CLK(1))
  sync_underflow (
    .in_clk(user_clk),
    .in_event(dac_underflow_user),
    .out_clk(dac_clk),
    .out_event(dac_underflow));

endmodule
