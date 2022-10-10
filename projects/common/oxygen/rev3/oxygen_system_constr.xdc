set_property -dict {PACKAGE_PIN AD9 IOSTANDARD LVCMOS18} [get_ports emio_uart1_txd*]

set_property -dict {PACKAGE_PIN AG9 IOSTANDARD LVCMOS18 PULLUP true} [get_ports emio_uart1_rxd*]

set_property -dict {PACKAGE_PIN M8  IOSTANDARD LVCMOS18} [get_ports wd]
