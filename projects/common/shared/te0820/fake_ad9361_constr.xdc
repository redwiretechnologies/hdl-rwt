################################################################################
## AD9361
##
## These are all LVCMOS18 so Vivado doesn't complain since they are tied off.
## Use ad9361_constr.xdc whenever they are actually connected.
################################################################################
set_property -dict {PACKAGE_PIN C3 IOSTANDARD LVCMOS18} [get_ports rx_clk_in_p]
set_property -dict {PACKAGE_PIN C2 IOSTANDARD LVCMOS18} [get_ports rx_clk_in_n]
set_property -dict {PACKAGE_PIN D4 IOSTANDARD LVCMOS18} [get_ports rx_frame_in_p]
set_property -dict {PACKAGE_PIN C4 IOSTANDARD LVCMOS18} [get_ports rx_frame_in_n]
set_property -dict {PACKAGE_PIN A2 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[0]}]
set_property -dict {PACKAGE_PIN A1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[0]}]
set_property -dict {PACKAGE_PIN G1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[1]}]
set_property -dict {PACKAGE_PIN F1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[1]}]
set_property -dict {PACKAGE_PIN E1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[2]}]
set_property -dict {PACKAGE_PIN D1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[2]}]
set_property -dict {PACKAGE_PIN C6 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[3]}]
set_property -dict {PACKAGE_PIN B6 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[3]}]
set_property -dict {PACKAGE_PIN C1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[4]}]
set_property -dict {PACKAGE_PIN B1 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[4]}]
set_property -dict {PACKAGE_PIN A7 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_p[5]}]
set_property -dict {PACKAGE_PIN A6 IOSTANDARD LVCMOS18} [get_ports {rx_data_in_n[5]}]

set_property -dict {PACKAGE_PIN B4 IOSTANDARD LVCMOS18} [get_ports tx_clk_out_p]
set_property -dict {PACKAGE_PIN A4 IOSTANDARD LVCMOS18} [get_ports tx_clk_out_n]
set_property -dict {PACKAGE_PIN A9 IOSTANDARD LVCMOS18} [get_ports tx_frame_out_p]
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS18} [get_ports tx_frame_out_n]
set_property -dict {PACKAGE_PIN F2 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[0]}]
set_property -dict {PACKAGE_PIN E2 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[0]}]
set_property -dict {PACKAGE_PIN E4 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[1]}]
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[1]}]
set_property -dict {PACKAGE_PIN G6 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[2]}]
set_property -dict {PACKAGE_PIN F6 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[2]}]
set_property -dict {PACKAGE_PIN C9 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[3]}]
set_property -dict {PACKAGE_PIN B9 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[3]}]
set_property -dict {PACKAGE_PIN F8 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[4]}]
set_property -dict {PACKAGE_PIN E8 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[4]}]
set_property -dict {PACKAGE_PIN E9 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_p[5]}]
set_property -dict {PACKAGE_PIN D9 IOSTANDARD LVCMOS18} [get_ports {tx_data_out_n[5]}]

set_property -dict {PACKAGE_PIN F7 IOSTANDARD LVCMOS18} [get_ports enable]
set_property -dict {PACKAGE_PIN G8 IOSTANDARD LVCMOS18} [get_ports txnrx]

set_property -dict {PACKAGE_PIN AB2 IOSTANDARD LVCMOS18} [get_ports {gpio_status[0]}]
set_property -dict {PACKAGE_PIN AC2 IOSTANDARD LVCMOS18} [get_ports {gpio_status[1]}]
set_property -dict {PACKAGE_PIN AG4 IOSTANDARD LVCMOS18} [get_ports {gpio_status[2]}]
set_property -dict {PACKAGE_PIN AH4 IOSTANDARD LVCMOS18} [get_ports {gpio_status[3]}]
set_property -dict {PACKAGE_PIN AE3 IOSTANDARD LVCMOS18} [get_ports {gpio_status[4]}]
set_property -dict {PACKAGE_PIN AF3 IOSTANDARD LVCMOS18} [get_ports {gpio_status[5]}]
set_property -dict {PACKAGE_PIN AB1 IOSTANDARD LVCMOS18} [get_ports {gpio_status[6]}]
set_property -dict {PACKAGE_PIN AC1 IOSTANDARD LVCMOS18} [get_ports {gpio_status[7]}]
set_property -dict {PACKAGE_PIN AH1 IOSTANDARD LVCMOS18} [get_ports {gpio_ctl[0]}]
set_property -dict {PACKAGE_PIN AH2 IOSTANDARD LVCMOS18} [get_ports {gpio_ctl[1]}]
set_property -dict {PACKAGE_PIN AG3 IOSTANDARD LVCMOS18} [get_ports {gpio_ctl[2]}]
set_property -dict {PACKAGE_PIN AH3 IOSTANDARD LVCMOS18} [get_ports {gpio_ctl[3]}]
set_property -dict {PACKAGE_PIN AD2 IOSTANDARD LVCMOS18} [get_ports gpio_en_agc]
set_property -dict {PACKAGE_PIN AD1 IOSTANDARD LVCMOS18} [get_ports gpio_sync]
set_property -dict {PACKAGE_PIN AC7 IOSTANDARD LVCMOS18} [get_ports gpio_resetb]

set_property -dict {PACKAGE_PIN AG6 IOSTANDARD LVCMOS18 PULLUP true} [get_ports spi_csn]
set_property -dict {PACKAGE_PIN AG5 IOSTANDARD LVCMOS18} [get_ports spi_clk]
set_property -dict {PACKAGE_PIN AE2 IOSTANDARD LVCMOS18} [get_ports spi_mosi]
set_property -dict {PACKAGE_PIN AF2 IOSTANDARD LVCMOS18} [get_ports spi_miso]