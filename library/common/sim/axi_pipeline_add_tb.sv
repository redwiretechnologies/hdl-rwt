// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/1ps

`include "rwt.sv"


module axi_pipeline_add_tb();
  logic clk = 0;
  logic resetn = 0;
  logic start = 0;

  always #100 clk = ~clk;
  initial #1000 resetn = 1;
  initial #2000 start = 1;

  rwt_axis #(.DWIDTH(64), .UWIDTH(8)) m_streamer(clk, resetn);
  rwt_axis #(.DWIDTH(96), .UWIDTH(9)) s_streamer(clk, resetn);

  initial begin
    m_streamer.master_reset();
    @(posedge start);
    @(posedge clk);
    m_streamer.file_source("input_axi_add.txt", 4);
  end

  initial begin
    s_streamer.slave_reset();
    @(posedge start);
    s_streamer.file_sink("output_axi_add.txt", .throttle(5));
  end

  axi_pipeline_add #(
    .DWIDTH(32),
    .CHUNK_SZ(8),
    .UWIDTH(9))
  pipeline_eq(
    .clk(clk),
    .aresetn(resetn),

    .s_axi_ready(m_streamer.m_ready),
    .s_axi_valid(m_streamer.m_valid),
    .s_axi_data_a(m_streamer.m_data[63:32]),
    .s_axi_data_b(m_streamer.m_data[31:0]),
    .s_axi_user({m_streamer.m_last, m_streamer.m_user}),

    .m_axi_ready(s_streamer.m_ready),
    .m_axi_valid(s_streamer.m_valid),
    .m_axi_data_a(s_streamer.m_data[95:64]),
    .m_axi_data_b(s_streamer.m_data[63:32]),
    .m_axi_data_result(s_streamer.m_data[31:0]),
    .m_axi_data_carry(s_streamer.m_user[8]),
    .m_axi_user({s_streamer.m_last, s_streamer.m_user[7:0]}));

endmodule
