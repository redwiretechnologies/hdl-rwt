// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/1ps

`include "rwt.sv"

`define REG_BLK 0
`define REG_ADC 1
`define REG_DAC 2

`define REG_BLK_BLKID          ADDR(`REG_BLK, 0)
`define REG_BLK_CTRL           ADDR(`REG_BLK, 1)
`define REG_BLK_STATUS         ADDR(`REG_BLK, 2)
`define REG_BLK_SAMPLE_IDX_MSB ADDR(`REG_BLK, 3)
`define REG_BLK_SAMPLE_IDX_LSB ADDR(`REG_BLK, 4)
`define REG_BLK_OVERFLOW_WAIT  ADDR(`REG_BLK, 5)

`define REG_ADC_CTRL           ADDR(`REG_ADC, 0)
`define REG_DAC_CTRL           ADDR(`REG_DAC, 0)

module default_block_tb();
  logic clk = 0;
  logic resetn = 0;
  logic pause_dac = 0;
  logic adc_overflow;
  logic dac_underflow;

  function logic [15:0] ADDR(input int id, addr);
    return {id[4:0], addr[8:0], 2'b00};
  endfunction

  always #10 clk = ~clk;
  initial #1000 resetn = 1;

  rwt_axi4lite_lib axi_if (clk, resetn);
  rwt_dac_lib dac_if();
  rwt_adc_lib adc_if();
  rwt_axis #(64) axis_dac_dma(clk, resetn);
  rwt_axis #(64, 1) axis_adc_dma(clk, resetn);

  default_block #(
    .CLK_FREQ(4000))  // The value is low so that I can see pps.
  default_block(
    .user_clk(clk),
    .user_resetn(resetn),

    .pps(1'b0),

    .s_axi_aclk(clk),
    .s_axi_aresetn(resetn),
    `RWT_AXIS4LITE_CONNECT(s_axi_, axi_if),

    .adc_rstn(resetn),
    .adc_overflow(adc_overflow),
    `RWT_ADC_CONNECT(adc_, adc_if),

    .dac_rstn(resetn),
    .dac_underflow(dac_underflow),
    `RWT_DAC_CONNECT(dac_, dac_if),

    .m_adc_dma_aclk(clk),
    .m_adc_dma_aresetn(resetn),
    `RWT_AXIS_CONNECT_NOUSER(m_adc_dma_, axis_adc_dma),
    .m_adc_dma_user(),

    .s_dac_dma_aclk(clk),
    .s_dac_dma_aresetn(resetn),
    `RWT_AXIS_CONNECT_NOUSER(s_dac_dma_, axis_dac_dma));

  initial begin
    axi_if.master_reset();
    dac_if.reset();
    adc_if.reset();
    axis_dac_dma.master_reset();
    axis_adc_dma.slave_reset();

    @(posedge resetn);
    @(posedge clk);

    fork
      begin
        logic [1:0] resp;
        logic [32:0] data;

        // Register Accesses:
        axi_if.write(`REG_ADC_CTRL, 32'h00000001, resp);
        axi_if.write(`REG_DAC_CTRL, 32'h00000001, resp);
        axi_if.write(`REG_BLK_CTRL, 32'h0000000e, resp);

        #6000;
        axi_if.write(`REG_BLK_STATUS, 32'h00000000, resp);

        for (int i = 0; i < 3; i++) begin
          axi_if.read(ADDR(`REG_ADC, i), data, resp);
          $display("ADC 0x%02x : 0x%08x", i, data);
        end
        for (int i = 0; i < 3; i++) begin
          axi_if.read(ADDR(`REG_DAC, i), data, resp);
          $display("DAC 0x%02x : 0x%08x", i, data);
        end
        for (int i = 0; i < 14; i++) begin
          axi_if.read(ADDR(`REG_BLK, i), data, resp);
          $display("BLK 0x%02x : 0x%08x", i, data);
        end

        #200000;
        //axi_if.write(`REG_BLK_SAMPLE_IDX_MSB, 32'h0000FFFF, resp);
        //axi_if.write(`REG_BLK_SAMPLE_IDX_LSB, 32'h00010000, resp);

        #200000;
        pause_dac <= 1'b1;
        #500000;
        pause_dac <= 1'b0;

        #5000;
        axi_if.read(`REG_BLK_STATUS, data, resp);
        $display("Status 0x%08x", data);
        axi_if.read(`REG_BLK_STATUS, data, resp);
        $display("Status 0x%08x", data);

        rwt_adc_lib.quit();
        #300000;
        axi_if.read(`REG_BLK_STATUS, data, resp);
        $display("Status 0x%08x", data);
        axi_if.read(`REG_BLK_STATUS, data, resp);
        $display("Status 0x%08x", data);

      end

      begin
        #5000;
        rwt_adc_lib.file_source(
          "input_adc.txt",
          500,
          4,
          0,
          4'hf,
          1);

        rwt_adc_lib.file_source(
          "input_adc.txt",
          50,
          4,
          0,
          4'hf,
          1);
      end

      begin
        axis_adc_dma.file_sink("output_adc.txt", .throttle(10));
      end

      begin
        dac_if.file_sink(
          "output_dac.txt",
          .samp_rate(120),
          .enable_mask(4'h3),
          .binary(0));
      end

      begin
        #5000;
        forever begin
          if (pause_dac) begin
            $display("%0t: dac paused", $time);
            @(negedge pause_dac);
            $display("%0t: dac unpaused", $time);
          end

          axis_dac_dma.file_source("input_dac.txt");
        end

      end
    join
  end




endmodule
