// SPDX-License-Identifier: Apache-2.0

//  EMIO GPIO Settings:
//    0-11  : GPIO Header (IO)
//    12-15 : Reserved
//    16-21 : RF Personality GPIO (IO)
//    22    : Pushbutton Interrupt (In)
//    23    : Reserved
//    24    : Watchdog (Out)
//    25    : USBC ID (In)
//    26-31 : Reserved
//    32-39 : AD9361 CTRL_OUT (gpio_status) (In)
//    40-43 : AD9361 CTRL_IN (gpio_ctl) (Out)
//    44    : AD9361 EN AGC (Out)
//    45    : AD9361 Sync (Out)
//    46    : AD9361 Resetb (Out)
//    47-94 : Reserved

`timescale 1ns/100ps

module system_top (

  input         rx_clk_in_p,
  input         rx_clk_in_n,
  input         rx_frame_in_p,
  input         rx_frame_in_n,
  input [ 5:0]  rx_data_in_p,
  input [ 5:0]  rx_data_in_n,
  output        tx_clk_out_p,
  output        tx_clk_out_n,
  output        tx_frame_out_p,
  output        tx_frame_out_n,
  output [ 5:0] tx_data_out_p,
  output [ 5:0] tx_data_out_n,

  output        enable,
  output        txnrx,

  output        gpio_resetb,
  output        gpio_sync,
  output        gpio_en_agc,
  output [ 3:0] gpio_ctl,
  input [ 7:0]  gpio_status,

  output        spi_csn,
  output        spi_clk,
  output        spi_mosi,
  input         spi_miso,

  inout [11:0]  gpio_hdr,
  inout [5:0]   gpio_rf,

  input         gps_pps,
  output        wd,

  input         usbc_id,

  input         emio_uart1_rxd,
  output        emio_uart1_txd,
  input         pb_int
);
  genvar i;

  wire [94:0] gpio_i;
  wire [94:0] gpio_o;
  wire [94:0] gpio_t;

  assign tx_clk_out_p = 1'b0;
  assign tx_clk_out_n = 1'b0;
  assign tx_frame_out_p = 1'b0;
  assign tx_frame_out_n = 1'b0;
  assign tx_data_out_p = 6'b000000;
  assign tx_data_out_n = 6'b000000;
  assign enable = 1'b0;
  assign txnrx = 1'b0;

  // Reserved
  assign gpio_i[94:49] = gpio_o[94:49];
  assign gpio_i[31:26] = gpio_o[31:26];
  assign gpio_i[23] = gpio_o[23];
  assign gpio_i[15:13] = gpio_o[15:13];

  // AD9361 GPIO [48:32]
  assign gpio_resetb = gpio_o[46:46];
  assign gpio_sync = gpio_o[45:45];
  assign gpio_en_agc = gpio_o[44:44];
  assign gpio_ctl = gpio_o[43:40];

  assign gpio_i[48:40] = gpio_o[48:40];
  assign gpio_i[39:32] = gpio_status;

  // Misc Signals
  assign gpio_i[22] = pb_int;
  assign gpio_i[24] = gpio_o[24];
  assign wd = gpio_t[24] ? 1'bz : gpio_o[24];
  assign gpio_i[25] = usbc_id;

  generate for (i = 0; i < 12; i = i + 1)
    begin
      assign gpio_hdr[i] = gpio_t[i] ? 1'bz : gpio_o[i];
      assign gpio_i[i] = gpio_hdr[i];
    end
  endgenerate

  generate for (i = 0; i < 6; i = i + 1)
    begin
      assign gpio_rf[i] = gpio_t[i + 16] ? 1'bz : gpio_o[i + 16];
      assign gpio_i[i + 16] = gpio_rf[i];
    end
  endgenerate

  system_wrapper i_system_wrapper (
       .emio_uart1_rxd(emio_uart1_rxd),
       .emio_uart1_txd(emio_uart1_txd),
       .gpio_i (gpio_i),
       .gpio_o (gpio_o),
       .gpio_t(gpio_t),
       .ps_intr_00 (1'b0),
       .ps_intr_01 (1'b0),
       .ps_intr_02 (1'b0),
       .ps_intr_03 (1'b0),
       .ps_intr_04 (1'b0),
       .ps_intr_05 (1'b0),
       .ps_intr_06 (1'b0),
       .ps_intr_07 (1'b0),
       .ps_intr_08 (1'b0),
       .ps_intr_09 (1'b0),
       .ps_intr_10 (1'b0),
       .ps_intr_11 (1'b0),
       .ps_intr_14 (1'b0),
       .ps_intr_15 (1'b0),
       .spi0_csn (spi_csn),
       .spi0_miso (spi_miso),
       .spi0_mosi (spi_mosi),
       .spi0_sclk (spi_clk));

endmodule

// ***************************************************************************
// ***************************************************************************
