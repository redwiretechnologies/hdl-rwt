// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/100ps

module concat_9361 (
  input         adc_enable_i0,
  input         adc_valid_i0,
  input [15:0]  adc_data_i0,
  input         adc_enable_q0,
  input         adc_valid_q0,
  input [15:0]  adc_data_q0,
  input         adc_enable_i1,
  input         adc_valid_i1,
  input [15:0]  adc_data_i1,
  input         adc_enable_q1,
  input         adc_valid_q1,
  input [15:0]  adc_data_q1,

  output [63:0] adc_data,
  output [3:0]  adc_enable,
  output [3:0]  adc_valid,

  input         dac_enable_i0,
  input         dac_valid_i0,
  input         dac_enable_q0,
  input         dac_valid_q0,
  input         dac_enable_i1,
  input         dac_valid_i1,
  input         dac_enable_q1,
  input         dac_valid_q1,
  output [15:0] dac_data_i0,
  output [15:0] dac_data_q0,
  output [15:0] dac_data_i1,
  output [15:0] dac_data_q1,

  input [63:0]  dac_data,
  output [3:0]  dac_enable,
  output [3:0]  dac_valid
);

  assign adc_data[15:0] = adc_data_q0;
  assign adc_data[31:16] = adc_data_i0;
  assign adc_data[47:32] = adc_data_q1;
  assign adc_data[63:48] = adc_data_i1;
  assign adc_valid[0] = adc_valid_q0;
  assign adc_valid[1] = adc_valid_i0;
  assign adc_valid[2] = adc_valid_q1;
  assign adc_valid[3] = adc_valid_i1;
  assign adc_enable[0] = adc_enable_q0;
  assign adc_enable[1] = adc_enable_i0;
  assign adc_enable[2] = adc_enable_q1;
  assign adc_enable[3] = adc_enable_i1;

  assign dac_data_q0 = dac_data[15:0];
  assign dac_data_i0 = dac_data[31:16];
  assign dac_data_q1 = dac_data[47:32];
  assign dac_data_i1 = dac_data[63:48];

  assign dac_valid[0] = dac_valid_q0;
  assign dac_valid[1] = dac_valid_i0;
  assign dac_valid[2] = dac_valid_q1;
  assign dac_valid[3] = dac_valid_i1;
  assign dac_enable[0] = dac_enable_q0;
  assign dac_enable[1] = dac_enable_i0;
  assign dac_enable[2] = dac_enable_q1;
  assign dac_enable[3] = dac_enable_i1;

endmodule
