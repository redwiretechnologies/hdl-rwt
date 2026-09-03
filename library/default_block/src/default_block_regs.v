// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/100ps

module default_block_regs #(
  parameter ASYNC_CLK=1
)(
  input             user_clk,
  input             user_rstn,

  // Up-side Interface
  input             up_clk,
  input             up_rstn,
  input             up_wreq,
  input [8:0]       up_waddr,
  input [31:0]      up_wdata,
  output            up_wack,
  input             up_rreq,
  input [8:0]       up_raddr,
  output [31:0]     up_rdata,
  output            up_rack,

  // Input Status
  input             adc_overflow,
  input             dac_underflow,
  input [55:0]      status_hold_diff,
  input             status_hold_diff_valid,
  input [55:0]      status_sample_idx_adc,
  input [55:0]      status_sample_idx_dac,
  // Output Registers
  output            cfg_which_pps,
  output reg [55:0] cfg_sample_idx,
  output reg        cfg_sample_idx_updated,
  output            cfg_pps_tags_enabled,
  output            cfg_overflow_enabled,
  output reg [23:0] cfg_overflow_wait,
  output            cfg_hold_enabled,
  output            cfg_sample_idx_mode,
  // Output registers for the CIC filter
  output    [31:0]  cfg_adc_decimation_ratio,
  output    [ 2:0]  cfg_adc_filter_mask,
  output            cfg_adc_correction_enable_a,
  output            cfg_adc_correction_enable_b,
  output    [15:0]  cfg_adc_correction_coefficient_a,
  output    [15:0]  cfg_adc_correction_coefficient_b,
  output            cfg_adc_filter_reset,
  output    [4:0]   cfg_adc_filter_id
);

  localparam BLK_ID = 16'h0002;
  localparam BLK_VER = 16'h0002;

  reg         status_clear;
  reg [2:0]   status_reg;
  wire [2:0]  status_edge;
  wire [2:0]  status_level;
  reg [4:0]   control;

  wire        user_wreq;
  wire [8:0]  user_waddr;
  wire [31:0] user_wdata;
  reg         user_wack;
  wire        user_rreq;
  wire [8:0]  user_raddr;
  reg [31:0]  user_rdata;
  reg         user_rack;

  //For CIC filter
  reg [31:0]  adc_decimation_ratio;
  reg [ 2:0]  adc_filter_mask;
  reg [ 1:0]  adc_config;
  reg [15:0]  adc_correction_coefficient_a;
  reg [15:0]  adc_correction_coefficient_b;
  reg         adc_filter_reset;
  reg [4:0]   adc_filter_id;

  assign status_edge = {1'b0, adc_overflow, dac_underflow};
  assign status_level = {status_hold_diff_valid, 2'b00};

  assign cfg_which_pps = control[0];
  assign cfg_overflow_enabled = control[1];
  assign cfg_pps_tags_enabled = control[2];
  assign cfg_hold_enabled = control[3];
  assign cfg_sample_idx_mode = control[4];

  //For CIC filter
  assign cfg_adc_decimation_ratio = adc_decimation_ratio;
  assign cfg_adc_filter_mask = adc_filter_mask;
  assign cfg_adc_correction_enable_a = adc_config[0];
  assign cfg_adc_correction_enable_b = adc_config[1];
  assign cfg_adc_correction_coefficient_a = adc_correction_coefficient_a;
  assign cfg_adc_correction_coefficient_b = adc_correction_coefficient_b;
  assign cfg_adc_filter_reset = adc_filter_reset;
  assign cfg_adc_filter_id = adc_filter_id;

  sync_up_bus #(
    .ASYNC_CLK(ASYNC_CLK))
  sync_up_bus (
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

    .user_clk(user_clk),
    .user_rstn(user_rstn),
    .user_wreq(user_wreq),
    .user_waddr(user_waddr),
    .user_wdata(user_wdata),
    .user_wack(user_wack),
    .user_rreq(user_rreq),
    .user_raddr(user_raddr),
    .user_rdata(user_rdata),
    .user_rack(user_rack));

  always @(posedge user_clk) begin
    if (user_rstn == 0) begin
      user_wack <= 1'b0;
      cfg_sample_idx  <= 'd0;
      cfg_sample_idx_updated <= 1'b0;
      cfg_overflow_wait <= 24'd10000;
      status_reg <= 3'b000;
      control  <= 5'b11110;

      //For CIC filter
      adc_decimation_ratio <= 'd0;
      adc_filter_mask <= 'd0;
      adc_config <= 'd0;
      adc_correction_coefficient_a <= 'd0;
      adc_correction_coefficient_b <= 'd0;
      adc_filter_reset <= 'd0;
      adc_filter_id <= 'd0;

    end else begin
      cfg_sample_idx_updated <= 1'b0;
      user_wack <= user_wreq;

      if (status_clear)
        status_reg <= status_edge;
      else
        status_reg <= status_reg | status_edge;

      if (user_wreq == 1'b1) begin
        case (user_waddr)
          9'd1: control <= user_wdata[4:0];
          9'd2: status_reg <= user_wdata[2:0];
          9'd3: cfg_sample_idx[55:32] <= user_wdata[23:0];

          9'd4: begin
            cfg_sample_idx[31:0] <= user_wdata;
            cfg_sample_idx_updated <= 1'b1;
          end

          9'd9: cfg_overflow_wait <= user_wdata[23:0];
          //For CIC filter
          9'd12: adc_filter_reset             <= user_wdata[0];
          9'd13: adc_decimation_ratio         <= user_wdata;
          9'd14: adc_filter_mask              <= user_wdata[2:0];
          9'd15: adc_config                   <= user_wdata[1:0];
          9'd16: adc_correction_coefficient_a <= user_wdata[15:0];
          9'd17: adc_correction_coefficient_b <= user_wdata[15:0];
          9'd18: adc_filter_id                <= user_wdata[4:0];

        endcase
      end
    end
  end

  always @(posedge user_clk) begin
    if (user_rstn == 0) begin
      user_rack <= 'd0;
      user_rdata <= 'd0;
      status_clear <= 1'b0;
    end else begin
      user_rack <= user_rreq;
      status_clear <= 1'b0;
      if (user_rreq == 1'b1) begin
        user_rdata <= 'd0;
        case (user_raddr)
          9'd0:  user_rdata       <= {BLK_ID, BLK_VER};
          9'd1:  user_rdata[4:0]  <= control;
          9'd2:  begin
            status_clear <= 1'b1;
            user_rdata[2:0]  <= status_reg | status_level;
          end

          9'd3:  user_rdata[23:0] <= cfg_sample_idx[55:32];
          9'd4:  user_rdata       <= cfg_sample_idx[31:0];
          9'd5:  user_rdata[23:0] <= status_sample_idx_adc[55:32];
          9'd6:  user_rdata       <= status_sample_idx_adc[31:0];
          9'd7:  user_rdata[23:0] <= status_sample_idx_dac[55:32];
          9'd8:  user_rdata       <= status_sample_idx_dac[31:0];

          9'd9:  user_rdata[23:0] <= cfg_overflow_wait;
          9'd10: user_rdata[23:0] <= status_hold_diff[55:32];
          9'd11: user_rdata       <= status_hold_diff[31:0];
          //For CIC filter
          9'd12: user_rdata        <= { 31'h0, adc_filter_reset};
          9'd13: user_rdata        <= adc_decimation_ratio;
          9'd14: user_rdata        <= { 29'h0, adc_filter_mask};
          9'd15: user_rdata        <= { 30'h0, adc_config};
          9'd16: user_rdata        <= { 16'h0, adc_correction_coefficient_a};
          9'd17: user_rdata        <= { 16'h0, adc_correction_coefficient_b};
          9'd18: user_rdata        <= { 27'h0, adc_filter_id};
          default: user_rdata <= 32'hdeadbeef;
        endcase
      end
    end
  end

endmodule
