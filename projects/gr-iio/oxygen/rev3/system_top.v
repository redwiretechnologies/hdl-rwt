//  EMIO GPIO Settings:
//    0-11  : GPIO Header (IO)
//    12-15 : Reserved
//    16-21 : RF Personality GPIO (IO)
//    22    : Pushbutton Interrupt (In)
//    23    : Pushbutton Reset Power (In)
//    24    : Watchdog (Out)
//    25    : USBC ID (In)
//    26-31 : Reserved
//    32-39 : ADRV9002 DGPIO (IO)
//    40-43 : Reserved
//    44    : ADRV9002 GP_INT (IO)
//    45    : Reserved
//    46    : ADRV9002 Resetn (IO)
//    47    : Reserved
//    48    : ADRV9002 RX1 Enable (Out)
//    49    : ADRV9002 RX2 Enable (Out)
//    50    : ADRV9002 TX1 Enable (Out)
//    51    : ADRV9002 TX2 Enable (Out)
//    52    : Reserved
//    53    : ADRV9002 Sync (Out)
//    54    : MSSI Sync (Out)
//    55    : Reserved
//    56    : TDD Sync (Out)
//    57-94 : Reserved

`timescale 1ns/100ps

module system_top (
  // Device clock passed through 9001
  input         dev_clk_in,

  // Device clock
  //input       fpga_ref_clk_n,
  //input       fpga_ref_clk_p,

  // MCS
  //input       fpga_mcs_in_n,
  //input       fpga_mcs_in_p,
  //output      dev_mcs_fpga_out_n,
  //output      dev_mcs_fpga_out_p,

  inout [7:0]   dgpio,

  inout         gp_int,
  inout         ioexp_intn,
  inout         reset_trx,

  input         rx1_dclk_in_n,
  input         rx1_dclk_in_p,
  output        rx1_enable,
  input         rx1_idata_in_n,
  input         rx1_idata_in_p,
  input         rx1_qdata_in_n,
  input         rx1_qdata_in_p,
  input         rx1_strobe_in_n,
  input         rx1_strobe_in_p,

  input         rx2_dclk_in_n,
  input         rx2_dclk_in_p,
  output        rx2_enable,
  input         rx2_idata_in_n,
  input         rx2_idata_in_p,
  input         rx2_qdata_in_n,
  input         rx2_qdata_in_p,
  input         rx2_strobe_in_n,
  input         rx2_strobe_in_p,

  output        tx1_dclk_out_n,
  output        tx1_dclk_out_p,
  //input         tx1_dclk_in_n,
  //input         tx1_dclk_in_p,
  output        tx1_enable,
  output        tx1_idata_out_n,
  output        tx1_idata_out_p,
  output        tx1_qdata_out_n,
  output        tx1_qdata_out_p,
  output        tx1_strobe_out_n,
  output        tx1_strobe_out_p,

  output        tx2_dclk_out_n,
  output        tx2_dclk_out_p,
  //input         tx2_dclk_in_n,
  //input         tx2_dclk_in_p,
  output        tx2_enable,
  output        tx2_idata_out_n,
  output        tx2_idata_out_p,
  output        tx2_qdata_out_n,
  output        tx2_qdata_out_p,
  output        tx2_strobe_out_n,
  output        tx2_strobe_out_p,

  //inout         tdd_sync,

  inout         enable,

  inout         gpio_resetn,
  output        gpio_sync,

  output        spi_csn,
  output        spi_clk,
  output        spi_mosi,
  input         spi_miso,

  inout [11:0]  gpio_hdr,
  inout [5:0]   gpio_rf,

  output        wd,

  input         usbc_id,

  input         emio_uart1_rxd,
  output        emio_uart1_txd,
  input         pb_int,
  input         pb_rst_pwr
);
  genvar i;

  wire [94:0] gpio_i;
  wire [94:0] gpio_o;
  wire [94:0] gpio_t;

  reg  [2:0]  mcs_sync_m = 'd0;
  reg         sync;
  wire tdd_sync_loc;
  wire tdd_sync_i;
  wire tdd_sync_cntr;

  // multi-chip synchronization
  // CLK is supposed to be FPGA refclk
  always @(posedge dev_clk_in) begin
    mcs_sync_m <= {mcs_sync_m[1:0], gpio_o[53]};
    sync <= mcs_sync_m[2] & ~mcs_sync_m[1];
  end

  assign gpio_sync = sync;

  // tdd_sync_loc - local sync signal from a GPIO or other source
  // tdd_sync - external sync
  // Modified because we don't have an assigned TDD Sync pin externally

  //assign tdd_sync_i = tdd_sync_cntr ? tdd_sync_loc : tdd_sync;
  //assign tdd_sync = tdd_sync_cntr ? tdd_sync_loc : 1'bz;
  assign tdd_sync_i = tdd_sync_loc;

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

  generate for (i = 0; i < 8; i = i + 1)
    begin
      assign dgpio[i] = gpio_t[i + 32] ? 1'bz : gpio_o[i + 32];
      assign gpio_i[i + 32] = dgpio[i];
    end
  endgenerate

  // Reserved
  assign gpio_i[94:47] = gpio_o[94:47];
  assign gpio_i[45]    = gpio_o[45];
  assign gpio_i[43:40] = gpio_o[43:40];
  assign gpio_i[31:26] = gpio_o[31:26];
  assign gpio_i[15:13] = gpio_o[15:13];

  // Misc Signals
  assign gpio_i[22] = pb_int;
  assign gpio_i[23] = pb_rst_pwr;
  assign gpio_i[24] = gpio_o[24];
  assign wd = gpio_t[24] ? 1'bz : gpio_o[24];
  assign gpio_i[25] = usbc_id;

  assign gp_int      = gpio_t[44] ? 1'bz : gpio_o[44];
  assign gpio_i[44]  = gp_int;
  assign gpio_resetn = gpio_t[46] ? 1'bz : gpio_o[46];
  assign gpio_i[46]  = gpio_resetn;

  // multi-ssi synchronization
  assign mssi_sync = gpio_o[54];

  // Enables
  assign gpio_rx1_enable_in = gpio_o[48];
  assign gpio_rx2_enable_in = gpio_o[49];
  assign gpio_tx1_enable_in = gpio_o[50];
  assign gpio_tx2_enable_in = gpio_o[51];

  // TDD Sync
  assign tdd_sync_loc = gpio_o[56];

  system_wrapper i_system_wrapper (
    //.ref_clk (fpga_ref_clk),
    .mssi_sync (mssi_sync),

    .tx_output_enable (1'b1),

    .rx1_dclk_in_n (rx1_dclk_in_n),
    .rx1_dclk_in_p (rx1_dclk_in_p),
    .rx1_idata_in_n (rx1_idata_in_n),
    .rx1_idata_in_p (rx1_idata_in_p),
    .rx1_qdata_in_n (rx1_qdata_in_n),
    .rx1_qdata_in_p (rx1_qdata_in_p),
    .rx1_strobe_in_n (rx1_strobe_in_n),
    .rx1_strobe_in_p (rx1_strobe_in_p),

    .rx2_dclk_in_n (rx2_dclk_in_n),
    .rx2_dclk_in_p (rx2_dclk_in_p),
    .rx2_idata_in_n (rx2_idata_in_n),
    .rx2_idata_in_p (rx2_idata_in_p),
    .rx2_qdata_in_n (rx2_qdata_in_n),
    .rx2_qdata_in_p (rx2_qdata_in_p),
    .rx2_strobe_in_n (rx2_strobe_in_n),
    .rx2_strobe_in_p (rx2_strobe_in_p),

    .tx1_dclk_out_n (tx1_dclk_out_n),
    .tx1_dclk_out_p (tx1_dclk_out_p),
//    .tx1_dclk_in_n (tx1_dclk_in_n),
//    .tx1_dclk_in_p (tx1_dclk_in_p),
    .tx1_idata_out_n (tx1_idata_out_n),
    .tx1_idata_out_p (tx1_idata_out_p),
    .tx1_qdata_out_n (tx1_qdata_out_n),
    .tx1_qdata_out_p (tx1_qdata_out_p),
    .tx1_strobe_out_n (tx1_strobe_out_n),
    .tx1_strobe_out_p (tx1_strobe_out_p),

    .tx2_dclk_out_n (tx2_dclk_out_n),
    .tx2_dclk_out_p (tx2_dclk_out_p),
//    .tx2_dclk_in_n (tx2_dclk_in_n),
//    .tx2_dclk_in_p (tx2_dclk_in_p),
    .tx2_idata_out_n (tx2_idata_out_n),
    .tx2_idata_out_p (tx2_idata_out_p),
    .tx2_qdata_out_n (tx2_qdata_out_n),
    .tx2_qdata_out_p (tx2_qdata_out_p),
    .tx2_strobe_out_n (tx2_strobe_out_n),
    .tx2_strobe_out_p (tx2_strobe_out_p),

    .rx1_enable (rx1_enable),
    .rx2_enable (rx2_enable),
    .tx1_enable (tx1_enable),
    .tx2_enable (tx2_enable),

    .gpio_rx1_enable_in (gpio_rx1_enable_in),
    .gpio_rx2_enable_in (gpio_rx2_enable_in),
    .gpio_tx1_enable_in (gpio_tx1_enable_in),
    .gpio_tx2_enable_in (gpio_tx2_enable_in),

    .tdd_sync (tdd_sync_i),
    .tdd_sync_cntr (tdd_sync_cntr),

    .ps_intr_00 (1'b0),
    .ps_intr_01 (1'b0),
    .ps_intr_02 (1'b0),
    .ps_intr_03 (1'b0),
    .ps_intr_04 (1'b0),
    .ps_intr_05 (1'b0),
    .ps_intr_06 (1'b0),
    .ps_intr_07 (1'b0),
    .ps_intr_08 (1'b0),
    .ps_intr_11 (1'b0),
    .ps_intr_14 (1'b0),
    .ps_intr_15 (1'b0),

    .gpio_i (gpio_i),
    .gpio_o (gpio_o),
    .gpio_t (gpio_t),
    .spi0_csn (spi_csn),
    .spi0_miso (spi_miso),
    .spi0_mosi (spi_mosi),
    .spi0_sclk (spi_clk),

    .emio_uart1_rxd(emio_uart1_rxd),
    .emio_uart1_txd(emio_uart1_txd)
  );
endmodule

// ***************************************************************************
// ***************************************************************************
