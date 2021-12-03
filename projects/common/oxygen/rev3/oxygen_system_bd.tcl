source $script_dir/../../../common/scripts/bd/rwt_te0820_carrier_bd.tcl

set_property -dict [list \
  CONFIG.PSU__PCIE__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__PCIE__PERIPHERAL__ENDPOINT_IO {MIO 33} \
  CONFIG.PSU__PCIE__PERIPHERAL__ROOTPORT_IO {MIO 33} \
  CONFIG.PSU__PCIE__DEVICE_PORT_TYPE {Root Port} \
  CONFIG.PSU__PCIE__REF_CLK_SEL {Ref Clk3} \
  CONFIG.PSU__PCIE__CLASS_CODE_SUB {0x04} \
  CONFIG.PSU__PCIE__CRS_SW_VISIBILITY {1} \
] [get_bd_cells sys_ps8]

ad_connect  gpio_i sys_ps8/emio_gpio_i
