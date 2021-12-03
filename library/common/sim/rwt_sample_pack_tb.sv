`timescale 1ns/1ps

`include "rwt.sv"


module rwt_sample_pack_tb();
  logic clk = 0;
  logic resetn = 0;
  logic start = 0;

  always #100 clk = ~clk;
  initial #1000 resetn = 1;
  initial #2000 start = 1;

  rwt_axis #(.DWIDTH(64), .UWIDTH(4)) m_streamer(clk, resetn);
  rwt_axis #(.DWIDTH(64), .UWIDTH(1)) s_streamer(clk, resetn);

  initial begin
    m_streamer.master_reset();
    @(posedge start);
    @(posedge clk);
    m_streamer.file_source("input_rwt_sample_pack.txt", 4);
  end

  initial begin
    s_streamer.slave_reset();
    @(posedge start);
    s_streamer.file_sink("output_rwt_sample_pack.txt", .throttle(5));
  end

  rwt_sample_pack rwt_sample_pack(
    .clk(clk),
    .aresetn(resetn),

    `RWT_AXIS_CONNECT_NOUSER(s_axi_, m_streamer),
    .s_axi_enables(m_streamer.m_user),

    `RWT_AXIS_CONNECT_NOUSER(m_axi_, s_streamer));

endmodule
