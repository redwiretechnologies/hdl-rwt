// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module cic_filter #(

  parameter CORRECTION_DISABLE = 1,
  parameter FILTER_ID = 0) (

  input                 adc_clk,
  input                 adc_rst,

  input       [15:0]    adc_data_a,
  input       [15:0]    adc_data_b,
  input                 adc_valid_a,
  input                 adc_valid_b,
  input                 adc_enable_a,
  input                 adc_enable_b,

  output      [15:0]    adc_dec_data_a,
  output      [15:0]    adc_dec_data_b,
  output                adc_dec_valid_a,
  output                adc_dec_valid_b,

  input       [4:0]     filter_id,
  input       [31:0]    decimation_ratio,
  input       [ 2:0]    filter_mask,
  input                 adc_correction_enable_a,
  input                 adc_correction_enable_b,
  input       [15:0]    adc_correction_coefficient_a,
  input       [15:0]    adc_correction_coefficient_b,
  input                 adc_filter_reset);

  //For bypassing
  reg               cic_bypass;
  wire    [15:0]    adc_dec_output_data_a;
  wire    [15:0]    adc_dec_output_data_b;
  wire              adc_dec_output_valid_a;
  wire              adc_dec_output_valid_b;
  reg     [15:0]    a_data_out;
  reg     [15:0]    b_data_out;
  reg               a_valid_out;
  reg               b_valid_out;

  reg     [31:0]    decimation_ratio_reg;
  reg     [ 2:0]    filter_mask_reg;
  reg               adc_correction_enable_a_reg;
  reg               adc_correction_enable_b_reg;
  reg     [15:0]    adc_correction_coefficient_a_reg;
  reg     [15:0]    adc_correction_coefficient_b_reg;

  wire    [31:0]    decimation_ratio_i;
  wire    [ 2:0]    filter_mask_i;
  wire              adc_correction_enable_a_i;
  wire              adc_correction_enable_b_i;
  wire    [15:0]    adc_correction_coefficient_a_i;
  wire    [15:0]    adc_correction_coefficient_b_i;

  assign decimation_ratio_i = decimation_ratio_reg;
  assign filter_mask_i = filter_mask_reg;
  assign adc_correction_enable_a_i = adc_correction_enable_a_reg;
  assign adc_correction_enable_b_i = adc_correction_enable_b_reg;
  assign adc_correction_coefficient_a_i = adc_correction_coefficient_a_reg;
  assign adc_correction_coefficient_b_i = adc_correction_coefficient_b_reg;

  always @(posedge adc_clk)
  begin
    if (filter_id == FILTER_ID)
    begin
      decimation_ratio_reg <= decimation_ratio;
      filter_mask_reg <= filter_mask;
      adc_correction_enable_a_reg <= adc_correction_enable_a;
      adc_correction_enable_b_reg <= adc_correction_enable_b;
      adc_correction_coefficient_a_reg <= adc_correction_coefficient_a;
      adc_correction_coefficient_b_reg <= adc_correction_coefficient_b;
    end
  end

  //Block to determine if we should bypass the filter
  always @(negedge adc_clk) begin
    cic_bypass <= adc_filter_reset | adc_rst;
    if (cic_bypass == 1'b1)
    begin
        a_data_out <= adc_data_a;
        b_data_out <= adc_data_b;
        a_valid_out <= adc_valid_a & adc_enable_a;
        b_valid_out <= adc_valid_b & adc_enable_b;
    end
    else
    begin
        a_data_out <= adc_dec_output_data_a;
        b_data_out <= adc_dec_output_data_b;
        a_valid_out <= adc_dec_output_valid_a;
        b_valid_out <= adc_dec_output_valid_b;
    end
  end
  assign adc_dec_data_a = a_data_out;
  assign adc_dec_data_b = b_data_out;
  assign adc_dec_valid_a = a_valid_out;
  assign adc_dec_valid_b = b_valid_out;

  axi_adc_decimate_filter #(
    .CORRECTION_DISABLE(CORRECTION_DISABLE)
  ) axi_adc_decimate_filter (
    .adc_clk (adc_clk),
    .adc_rst (adc_filter_rst),

    .decimation_ratio (decimation_ratio_i),
    .filter_mask (filter_mask_i),
    .adc_correction_enable_a(adc_correction_enable_a_i),
    .adc_correction_enable_b(adc_correction_enable_b_i),
    .adc_correction_coefficient_a(adc_correction_coefficient_a_i),
    .adc_correction_coefficient_b(adc_correction_coefficient_b_i),

    .adc_valid_a(adc_valid_a & adc_enable_a),
    .adc_valid_b(adc_valid_b & adc_enable_b),
    .adc_data_a(adc_data_a[11:0]),
    .adc_data_b(adc_data_b[11:0]),
    .adc_dec_data_a(adc_dec_output_data_a),
    .adc_dec_data_b(adc_dec_output_data_b),
    .adc_dec_valid_a(adc_dec_output_valid_a),
    .adc_dec_valid_b(adc_dec_output_valid_b));

endmodule

// ***************************************************************************
// ***************************************************************************
