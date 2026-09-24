
`timescale 1ns/100ps

module breakout_9002 (
  output         adc_enable_i0,
  output         adc_valid_i0,
  output [15:0]  adc_data_i0,
  output         adc_enable_q0,
  output         adc_valid_q0,
  output [15:0]  adc_data_q0,
  output         adc_enable_i1,
  output         adc_valid_i1,
  output [15:0]  adc_data_i1,
  output         adc_enable_q1,
  output         adc_valid_q1,
  output [15:0]  adc_data_q1,

  input [63:0] adc_data,
  input [3:0]  adc_enable,
  input [3:0]  adc_valid,

  output         dac_enable_i0,
  output         dac_valid_i0,
  output         dac_enable_q0,
  output         dac_valid_q0,
  output         dac_enable_i1,
  output         dac_valid_i1,
  output         dac_enable_q1,
  output         dac_valid_q1,
  input [15:0] dac_data_i0,
  input [15:0] dac_data_q0,
  input [15:0] dac_data_i1,
  input [15:0] dac_data_q1,

  output [63:0]  dac_data,
  input [3:0]  dac_enable,
  input [3:0]  dac_valid
);

  assign adc_data_q0 = adc_data[15:0];
  assign adc_data_i0 = adc_data[31:16];
  assign adc_data_q1 = adc_data[47:32];
  assign adc_data_i1 = adc_data[63:48];
  assign adc_valid_q0 = adc_valid[0];
  assign adc_valid_i0 = adc_valid[1];
  assign adc_valid_q1 = adc_valid[2];
  assign adc_valid_i1 = adc_valid[3];
  assign adc_enable_q0 = adc_enable[0];
  assign adc_enable_i0 = adc_enable[1];
  assign adc_enable_q1 = adc_enable[2];
  assign adc_enable_i1 = adc_enable[3];

  assign dac_data[15:0] = dac_data_q0;
  assign dac_data[31:16] = dac_data_i0;
  assign dac_data[47:32] = dac_data_q1;
  assign dac_data[63:48] = dac_data_i1;

  assign dac_valid_q0 = dac_valid[0];
  assign dac_valid_i0 = dac_valid[1];
  assign dac_valid_q1 = dac_valid[2];
  assign dac_valid_i1 = dac_valid[3];
  assign dac_enable_q0 = dac_enable[0];
  assign dac_enable_i0 = dac_enable[1];
  assign dac_enable_q1 = dac_enable[2];
  assign dac_enable_i1 = dac_enable[3];

endmodule
