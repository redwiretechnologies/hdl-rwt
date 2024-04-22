################################################################################
## GPIO Header
################################################################################

set_property -dict {PACKAGE_PIN AC9 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[0]}]
set_property -dict {PACKAGE_PIN AH9 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[1]}]
set_property -dict {PACKAGE_PIN AC8 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[2]}]
set_property -dict {PACKAGE_PIN AF8 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[3]}]
set_property -dict {PACKAGE_PIN AB8 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[4]}]
set_property -dict {PACKAGE_PIN AG8 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[5]}]
set_property -dict {PACKAGE_PIN N6  IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[6]}]
set_property -dict {PACKAGE_PIN AH8 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[7]}]
set_property -dict {PACKAGE_PIN N7  IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[8]}]
set_property -dict {PACKAGE_PIN AH7 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[9]}]
set_property -dict {PACKAGE_PIN K1  IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[10]}]
set_property -dict {PACKAGE_PIN AE7 IOSTANDARD LVCMOS18} [get_ports {gpio_hdr[11]}]

################################################################################
## RF GPIO
################################################################################
set_property -dict {PACKAGE_PIN F5  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[0]}]
set_property -dict {PACKAGE_PIN G5  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[1]}]
set_property -dict {PACKAGE_PIN C8  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[2]}]
set_property -dict {PACKAGE_PIN B8  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[3]}]
set_property -dict {PACKAGE_PIN G3  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[4]}]
set_property -dict {PACKAGE_PIN F3  IOSTANDARD LVCMOS18} [get_ports {gpio_rf[5]}]

################################################################################
## Misc Carrier board GPIO
################################################################################
set_property -dict {PACKAGE_PIN A5  IOSTANDARD LVCMOS18} [get_ports pb_int]
set_property -dict {PACKAGE_PIN B5  IOSTANDARD LVCMOS18} [get_ports pb_rst_pwr]
set_property -dict {PACKAGE_PIN N9  IOSTANDARD LVCMOS18 PULLUP true} [get_ports usbc_id]

# The next line corrects the following DRC error:
#     ERROR: [DRC PDRC-203] BITSLICE0 not available during BISC: The port gpio_hdr[0] is
#     assigned to a PACKAGE_PIN that uses BITSLICE_0 of a Byte that will be using
#     calibration. The signal connected to gpio_hdr[0] will not be available during
#     calibration and will only be available after RDY asserts. If this condition is not
#     acceptable for your design and board layout, gpio_hdr[0] will have to be moved to
#     another PACKAGE_PIN that is not undergoing calibration or be moved to a PACKAGE_PIN
#     location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition
#     is acceptable for your design and board layout, this DRC can be bypassed by
#     acknowledging the condition and setting the following XDC constraint:
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports gpio_hdr[0]]

# The next line corrects the following DRC error:
#     ERROR: [DRC PDRC-203] BITSLICE0 not available during BISC: The port gpio_hdr[2] is
#     assigned to a PACKAGE_PIN that uses BITSLICE_0 of a Byte that will be using
#     calibration. The signal connected to gpio_hdr[2] will not be available during
#     calibration and will only be available after RDY asserts. If this condition is not
#     acceptable for your design and board layout, gpio_hdr[2] will have to be moved to
#     another PACKAGE_PIN that is not undergoing calibration or be moved to a PACKAGE_PIN
#     location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition
#     is acceptable for your design and board layout, this DRC can be bypassed by
#     acknowledging the condition and setting the following XDC constraint:
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports gpio_hdr[2]]

# The next line corrects the following DRC error:
#     ERROR: [DRC PDRC-203] BITSLICE0 not available during BISC: The port gpio_rf[2] is
#     assigned to a PACKAGE_PIN that uses BITSLICE_1 of a Byte that will be using
#     calibration. The signal connected to gpio_rf[2] will not be available during
#     calibration and will only be available after RDY asserts. If this condition is not
#     acceptable for your design and board layout, gpio_rf[2] will have to be moved to
#     another PACKAGE_PIN that is not undergoing calibration or be moved to a PACKAGE_PIN
#     location that is not BITSLICE_0 or BITSLICE_6 on that same Byte. If this condition
#     is acceptable for your design and board layout, this DRC can be bypassed by
#     acknowledging the condition and setting the following XDC constraint:
set_property UNAVAILABLE_DURING_CALIBRATION TRUE [get_ports gpio_rf[2]]
