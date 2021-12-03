`timescale 1ns/1ps

`include "rwt.sv"


module rwt_lib_tb();
  logic clk = 0;
  logic resetn = 0;
  logic start_axis = 0;
  logic start_rwt_axis = 0;
  logic start_up = 0;
  logic start_axi = 0;
  logic start_adc = 0;
  logic start_dac = 0;

  always #100 clk = ~clk;
  initial #1000 resetn = 1;
  initial #2000 start_axis = 1;
  initial #150000 start_rwt_axis = 1;
  initial #300000 start_up = 1;
  initial #400000 start_axi = 1;
  initial #600000 start_adc = 1;
  initial #750000 start_dac = 1;

  test_axis test_axis(clk, resetn, start_axis, start_rwt_axis);
  test_up test_up(clk, resetn, start_up);
  test_axi test_axi(clk, resetn, start_axi);
  test_adc test_adc(clk, resetn, start_adc);
  test_dac test_dac(clk, resetn, start_dac);
endmodule

module test_axis(
  input logic clk,
  input logic resetn,
  input logic start_axis,
  input logic start_rwt_axis);

  rwt_axis streamer(clk, resetn);
  rwt_axis_tag_pkt #(.UWIDTH(2)) rwt_streamer(clk, resetn);

  master_axis u_master(streamer, start_axis);
  slave_axis u_slave(streamer, start_axis);

  rwt_master u_rwt_master(rwt_streamer, start_rwt_axis);
  rwt_slave u_rwt_slave(rwt_streamer, start_rwt_axis);
endmodule

module master_axis(rwt_axis streamer, input logic start);
  initial begin
    logic [31:0] pkt[$];

    streamer.master_reset();
    @(posedge start);
    @(posedge streamer.m_clk);
    $display("------------------------------------------------------");
    $display("Starting AXIS test");

    streamer.write(32'd0);
    streamer.write(32'd1, 1'd1, 1'b1, 10);
    streamer.write(32'd2);

    for (int i=0; i < 20; i++) begin
      pkt.push_back(i);
    end
    streamer.write_pkt(pkt, 1'b1, 10);
    streamer.write_pkt(pkt, 1'b1, 0);
    streamer.write_pkt(pkt, 1'b0, 5);

    streamer.file_source("input.txt", .throttle(3));
  end
endmodule

module slave_axis(rwt_axis streamer, input logic start);
  initial begin
    logic [31:0] data;
    logic [31:0] pkt[$];

    streamer.slave_reset();
    @(posedge start);
    @(posedge streamer.m_clk);
    streamer.read(data);
    streamer.read(data, 5);
    streamer.read(data);

    streamer.read_pkt(pkt);
    streamer.read_pkt(pkt, 10, 5, 1);
    streamer.read_pkt(pkt, 10, 0, 0);
    streamer.read_pkt(pkt, 20, 2, 1);

    streamer.file_sink("output.txt", .max_pkts(1));
    streamer.file_sink("output.txt", .append(1), .max_samples(10), .throttle(6));
    streamer.file_sink("output.txt", .append(1), .max_pkts(11));
  end
endmodule

module rwt_master(rwt_axis_tag_pkt streamer, input logic start);
  initial begin
    logic [31:0] pkt[$];

    streamer.master_reset();
    @(posedge start);
    $display("------------------------------------------------------");
    $display("Starting RWT-AXIS test");

    @(posedge streamer.m_clk);

    streamer.file_source_escaped("input_rwt.txt", 32'hAAAAAAAA, 1, 3);
    streamer.file_source_tagged("input_rwt.txt", 1, 1, 2);

    streamer.file_source_escaped("input_rwt.txt", 32'hAAAAAAAA, 1, 3);
    streamer.file_source_tagged("input_rwt.txt", 1, 1, 2);

  end
endmodule

module rwt_slave(rwt_axis_tag_pkt streamer, input logic start);
  initial begin
    streamer.slave_reset();
    @(posedge start);

    streamer.streamer.file_sink("output_rwt.txt", .max_pkts(4));
    streamer.file_sink_escaped("output_rwt.txt", 32'hAAAAAAAA, .append(1), .max_pkts(2));
    streamer.file_sink_tagged("output_rwt.txt", 1, .append(1), .max_pkts(2));
  end
endmodule


module test_up(
  input logic clk,
  input logic resetn,
  input logic start);

  localparam NUM_REGS = 32;

  rwt_up_lib up_if(clk, resetn);
  rwt_up_regs #(32) up_regs(up_if);

  initial up_regs.run(2, 2);

  initial begin
    logic [31:0] data;

    up_if.master_reset();

    @(posedge start);
    @(posedge clk);
    $display("------------------------------------------------------");
    $display("Starting UP test");


    up_if.write(0, 32'haabbccdd);
    up_if.write(1, 32'hbbccddee);
    up_if.write(2, 32'hccddeeff);
    up_if.write(0, 32'hddeeff00);
    up_if.write(1, 32'heeff0011);
    up_if.write(2, 32'hff001122);
    up_if.write(3, 32'h00112233);
    up_if.write(50, 32'hdeaddead);

    for (int i = 0; i < 10; i++) begin
      up_if.read(i, data);
      $display("%02x: %08x", i, data);
    end

    for (int i = 0; i < 40; i++) begin
      up_if.write(i, i);
    end

    for (int i = 0; i < 40; i++) begin
      up_if.read(i, data);
      $display("%02x: %08x", i, data);
    end
  end
endmodule

module test_axi(
  input logic clk,
  input logic resetn,
  input logic start);

  localparam NUM_REGS = 32;

  rwt_axi4lite_lib axi_if (clk, resetn);
  rwt_up_lib up_if(clk, resetn);
  rwt_up_regs #(32) up_regs(up_if);

  initial up_regs.run(2, 2);

  up_axi #(
    .ADDRESS_WIDTH(14),
    .AXI_ADDRESS_WIDTH(16))
 up_axi (
    .up_clk(clk),
    .up_rstn(resetn),
    `RWT_AXIS4LITE_CONNECT(up_axi_, axi_if),
    `RWT_UP_CONNECT(up_, up_if));

  initial begin
    logic [31:0] data;
    logic [1:0]  resp;

    axi_if.master_reset();

    @(posedge start);
    @(posedge clk);
    $display("------------------------------------------------------");
    $display("Starting AXI test");

    axi_if.write(0, 32'haabbccdd, resp);
    axi_if.write(4, 32'hbbccddee, resp);
    axi_if.write(8, 32'hccddeeff, resp);
    axi_if.write(0, 32'hddeeff00, resp);
    axi_if.write(4, 32'heeff0011, resp);
    axi_if.write(8, 32'hff001122, resp);
    axi_if.write(12, 32'h00112233, resp);
    axi_if.write(200, 32'hdeaddead, resp);

    for (int i = 0; i < 10; i++) begin
      axi_if.read(i*4, data, resp);
      $display("%02x: %08x", i, data);
    end

    for (int i = 0; i < 40; i++) begin
      axi_if.write(i*4, i, resp);
    end

    for (int i = 0; i < 40; i++) begin
      axi_if.read(i*4, data, resp);
      $display("%02x: %08x", i, data);
    end
  end
endmodule

module test_adc(
  input logic clk,
  input logic resetn,
  input logic start);

  rwt_adc_lib adc_lib();

  initial begin
    adc_lib.reset();

    @(posedge start);
    @(posedge clk);
    $display("------------------------------------------------------");
    $display("Starting ADC test");

    adc_lib.file_source(
      "input_adc.txt",
      100,
      4,
      0,
      4'h7,
      0);

    #1000;
    adc_lib.file_source(
      "input_adc.bin",
      100,
      4,
      1,
      4'h3,
      0);

    #1000;

    fork
      begin
        #50000 adc_lib.stop = 1;
      end
      begin

        adc_lib.file_source(
          "input_adc.bin",
          100,
          2,
          1,
          4'hf,
          1);
      end
    join
  end
endmodule

module test_dac(
  input logic clk,
  input logic resetn,
  input logic start);

  rwt_dac_lib dac_lib_a();
  rwt_dac_lib dac_lib_b();

  initial begin
    dac_lib_a.reset();
    dac_lib_b.reset();

    @(posedge start);
    @(posedge clk);
    $display("------------------------------------------------------");
    $display("Starting DAC test");


    fork
      #50000 dac_lib_a.stop = 1;
      #60000 dac_lib_b.stop = 1;

      begin
        dac_lib_a.file_sink(
          "output_dac.txt",
          100,
          4,
          0,
          4'hf);
      end

      begin
        dac_lib_b.file_sink(
          "output_dac.bin",
          100,
          4,
          1,
          4'hf);
      end

      begin
        dac_lib_a.data <= {16'h1000, 16'h2000, 16'h3000, 16'h4000};

        forever begin
          @(posedge dac_lib_a.clk);
          dac_lib_a.data[63:48] <= dac_lib_a.data[63:48] + 1;
          dac_lib_a.data[47:32] <= dac_lib_a.data[47:32] + 1;
          dac_lib_a.data[31:16] <= dac_lib_a.data[31:16] + 1;
          dac_lib_a.data[15:0] <= dac_lib_a.data[15:0] + 1;
        end
      end

      begin
        dac_lib_b.data <= {16'h5000, 16'h6000, 16'h7000, 16'h8000};

        forever begin
          @(posedge dac_lib_b.clk);
          dac_lib_b.data[63:48] <= dac_lib_b.data[63:48] + 1;
          dac_lib_b.data[47:32] <= dac_lib_b.data[47:32] + 1;
          dac_lib_b.data[31:16] <= dac_lib_b.data[31:16] + 1;
          dac_lib_b.data[15:0] <= dac_lib_b.data[15:0] + 1;
        end
      end
    join
  end

endmodule
