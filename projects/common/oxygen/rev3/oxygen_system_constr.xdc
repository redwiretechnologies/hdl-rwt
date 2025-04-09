# SPDX-License-Identifier: Apache-2.0

set_property -dict {PACKAGE_PIN AD9 IOSTANDARD LVCMOS18} [get_ports emio_uart1_txd*]

set_property -dict {PACKAGE_PIN AG9 IOSTANDARD LVCMOS18 PULLUP true} [get_ports emio_uart1_rxd*]

set_property -dict {PACKAGE_PIN M8  IOSTANDARD LVCMOS18} [get_ports wd]

set_property -dict {PACKAGE_PIN L8  IOSTANDARD LVCMOS18} [get_ports gps_pps]
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS18} [get_ports pb_int]
set_property -dict {PACKAGE_PIN N9  IOSTANDARD LVCMOS18 PULLUP true} [get_ports usbc_id]
