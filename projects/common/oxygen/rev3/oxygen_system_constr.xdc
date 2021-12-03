
# constraints

# fmc-i2c via CPLD

# set_property PACKAGE_PIN AB4 [get_ports i2c_sda_i]
# set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_i]
# set_property PULLUP true [get_ports i2c_sda_i]
# set_property PACKAGE_PIN AC9 [get_ports i2c_sda_o]
# set_property IOSTANDARD LVCMOS18 [get_ports i2c_sda_o]
# set_property PULLUP true [get_ports i2c_sda_o]
# set_property PACKAGE_PIN AB3 [get_ports i2c_scl]
# set_property IOSTANDARD LVCMOS18 [get_ports i2c_scl]
# set_property PULLUP true [get_ports i2c_scl]

set_property -dict {PACKAGE_PIN AD9 IOSTANDARD LVCMOS18} [get_ports emio_uart1_txd*]

set_property -dict {PACKAGE_PIN AG9 IOSTANDARD LVCMOS18 PULLUP true} [get_ports emio_uart1_rxd*]

set_property -dict {PACKAGE_PIN M8  IOSTANDARD LVCMOS18} [get_ports wd]
