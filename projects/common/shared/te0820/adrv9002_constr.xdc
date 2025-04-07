# SPDX-License-Identifier: Apache-2.0

# adrv9002 constraints

# Polarity matches zcu102 board.The LVDS data pairs are inverted by default.
# The clock and frame signals are not inverted.
#  adi,lvds-invert1-control = <0xFF>;
#  adi,lvds-invert2-control = <0x0F>;

# RX1
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_dclk_in_p]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_dclk_in_n]
set_property -dict {PACKAGE_PIN E9 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_qdata_in_p]
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_qdata_in_n]
set_property -dict {PACKAGE_PIN F8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_idata_in_p]
set_property -dict {PACKAGE_PIN E8 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_idata_in_n]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_strobe_in_p]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx1_strobe_in_n]

# RX2
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_dclk_in_p]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_dclk_in_n]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_qdata_in_p]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_qdata_in_n]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_idata_in_p]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_idata_in_n]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_strobe_in_p]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVDS DIFF_TERM_ADV TERM_100} [get_ports rx2_strobe_in_n]

# TX1
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVDS} [get_ports tx1_dclk_out_p]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVDS} [get_ports tx1_dclk_out_n]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVDS} [get_ports tx1_qdata_out_p]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVDS} [get_ports tx1_qdata_out_n]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVDS} [get_ports tx1_idata_out_p]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVDS} [get_ports tx1_idata_out_n]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVDS} [get_ports tx1_strobe_out_p]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVDS} [get_ports tx1_strobe_out_n]

# TX2
set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVDS} [get_ports tx2_dclk_out_p]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVDS} [get_ports tx2_dclk_out_n]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVDS} [get_ports tx2_qdata_out_p]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVDS} [get_ports tx2_qdata_out_n]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVDS} [get_ports tx2_idata_out_p]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVDS} [get_ports tx2_idata_out_n]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVDS} [get_ports tx2_strobe_out_p]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVDS} [get_ports tx2_strobe_out_n]

# DGPIOs
set_property -dict {PACKAGE_PIN AH1 IOSTANDARD LVCMOS18} [get_ports {dgpio[0]}]
set_property -dict {PACKAGE_PIN AH2 IOSTANDARD LVCMOS18} [get_ports {dgpio[1]}]
set_property -dict {PACKAGE_PIN AG3 IOSTANDARD LVCMOS18} [get_ports {dgpio[2]}]
set_property -dict {PACKAGE_PIN AH3 IOSTANDARD LVCMOS18} [get_ports {dgpio[3]}]
set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS18} [get_ports {dgpio[4]}]
set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVCMOS18} [get_ports {dgpio[5]}]
set_property -dict {PACKAGE_PIN AG4 IOSTANDARD LVCMOS18} [get_ports {dgpio[6]}]
set_property -dict {PACKAGE_PIN AH4 IOSTANDARD LVCMOS18} [get_ports {dgpio[7]}]

# Enables
set_property -dict {PACKAGE_PIN AE3 IOSTANDARD LVCMOS18} [get_ports {tx1_enable}]
set_property -dict {PACKAGE_PIN AF3 IOSTANDARD LVCMOS18} [get_ports {tx2_enable}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS18} [get_ports {rx1_enable}]
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVCMOS18} [get_ports {rx2_enable}]

# Other RF Control
set_property -dict {PACKAGE_PIN F7  IOSTANDARD LVCMOS18} [get_ports enable]
set_property -dict {PACKAGE_PIN AD1 IOSTANDARD LVCMOS18} [get_ports gpio_sync]
set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVCMOS18} [get_ports gpio_resetn]

# Interrupts
set_property -dict {PACKAGE_PIN G8  IOSTANDARD LVCMOS18} [get_ports ioexp_intn]
set_property -dict {PACKAGE_PIN AD2 IOSTANDARD LVCMOS18} [get_ports gp_int]

# SPI
set_property -dict {PACKAGE_PIN AG6 IOSTANDARD LVCMOS18 PULLUP true} [get_ports spi_csn]
set_property -dict {PACKAGE_PIN AG5 IOSTANDARD LVCMOS18} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN AE2 IOSTANDARD LVCMOS18} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN AF2 IOSTANDARD LVCMOS18} [get_ports spi_miso]

set_property -dict {PACKAGE_PIN E5  IOSTANDARD LVCMOS18} [get_ports dev_clk_in]

# clocks
create_clock -period 4.000 -name rx1_clk [get_ports rx1_clk_in_p]
create_clock -period 4.000 -name rx2_clk [get_ports rx2_clk_in_p]

set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports tx1_dclk_out_p]
