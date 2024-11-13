// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/1ps

`include "rwt.sv"


module rwt_tag_insert_tb();
  logic clk = 0;
  logic resetn = 0;
  logic start = 0;

  always #100 clk = ~clk;
  initial #1000 resetn = 1;
  initial #2000 start = 1;

  rwt_axis #(.DWIDTH(64), .UWIDTH(8)) m_streamer(clk, resetn);
  rwt_axis_tag_pkt #(.DWIDTH(64), .UWIDTH(1)) s_streamer(clk, resetn);

  initial begin
    logic [31:0] pkt[$];

    m_streamer.master_reset();
    @(posedge start);
    @(posedge clk);

    m_streamer.file_source("input_tag_insert.txt", 3);
  end

  initial begin
    s_streamer.slave_reset();
    @(posedge start);
    s_streamer.file_sink_escaped(
      "output_tag_pkt_insert.txt",
       64'hAAAAAAAAAAAAAAAA);
  end

  initial begin
    @(posedge start);
    s_streamer.streamer.file_sink("output_tag_raw_insert.txt", .monitor(1));
  end

  rwt_tag_insert u_tag_insert (
    .clk(clk),
    .aresetn(resetn),
    .use_tags(1'b1),
    .tag_escape(64'hAAAAAAAAAAAAAAAA),

    `RWT_AXIS_CONNECT_NOUSER(s_axi_, m_streamer),
    .s_axi_tag_valid(m_streamer.m_user[7]),
    .s_axi_tag_type(m_streamer.m_user[6:0]),

    `RWT_AXIS_TAG_CONNECT_NOUSER(m_axi_, s_streamer));

endmodule
