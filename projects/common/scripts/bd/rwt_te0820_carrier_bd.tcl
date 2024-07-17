# default ports

create_bd_port -dir I emio_uart1_rxd
create_bd_port -dir O emio_uart1_txd

create_bd_port -dir O spi0_csn
create_bd_port -dir O spi0_sclk
create_bd_port -dir O spi0_mosi
create_bd_port -dir I spi0_miso

create_bd_port -dir I -from 94 -to 0 gpio_i
create_bd_port -dir O -from 94 -to 0 gpio_o
create_bd_port -dir O -from 94 -to 0 gpio_t

# interrupts

create_bd_port -dir I -type intr ps_intr_00
create_bd_port -dir I -type intr ps_intr_01
create_bd_port -dir I -type intr ps_intr_02
create_bd_port -dir I -type intr ps_intr_03
create_bd_port -dir I -type intr ps_intr_04
create_bd_port -dir I -type intr ps_intr_05
create_bd_port -dir I -type intr ps_intr_06
create_bd_port -dir I -type intr ps_intr_07
create_bd_port -dir I -type intr ps_intr_08
create_bd_port -dir I -type intr ps_intr_09
create_bd_port -dir I -type intr ps_intr_10
create_bd_port -dir I -type intr ps_intr_11
create_bd_port -dir I -type intr ps_intr_12
create_bd_port -dir I -type intr ps_intr_13
create_bd_port -dir I -type intr ps_intr_14
create_bd_port -dir I -type intr ps_intr_15

# instance: sys_ps8

ad_ip_instance zynq_ultra_ps_e sys_ps8
apply_bd_automation -rule xilinx.com:bd_rule:zynq_ultra_ps_e \
  -config {apply_board_preset 1}  [get_bd_cells sys_ps8]

ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP0 0
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP1 0
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__M_AXI_GP2 1
ad_ip_parameter sys_ps8 CONFIG.PSU__MAXIGP2__DATA_WIDTH 32
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL0_ENABLE 1
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL0_REF_CTRL__SRCSEL {IOPLL}
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL0_REF_CTRL__FREQMHZ 100
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL1_ENABLE 1
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL1_REF_CTRL__SRCSEL {IOPLL}
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL1_REF_CTRL__FREQMHZ 500
ad_ip_parameter sys_ps8 CONFIG.PSU__FPGA_PL2_ENABLE 1
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL2_REF_CTRL__SRCSEL {IOPLL}
ad_ip_parameter sys_ps8 CONFIG.PSU__CRL_APB__PL2_REF_CTRL__FREQMHZ 100
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__IRQ0 1
ad_ip_parameter sys_ps8 CONFIG.PSU__USE__IRQ1 1
ad_ip_parameter sys_ps8 CONFIG.PSU__GPIO_EMIO__PERIPHERAL__ENABLE 1
ad_ip_parameter sys_ps8 CONFIG.PSU__ENET3__PERIPHERAL__ENABLE 0

set_property -dict [list \
  CONFIG.PSU__GPIO0_MIO__PERIPHERAL__ENABLE {1} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__USB0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__USB3_0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__USB0__REF_CLK_FREQ {100} \
  CONFIG.PSU__USB3_0__PERIPHERAL__IO {GT Lane2} \
  CONFIG.PSU__USB0__RESET__ENABLE {1} \
  CONFIG.PSU__USB0__RESET__IO {MIO 25} \
  CONFIG.PSU__USB__RESET__MODE {Separate MIO Pin} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__SPI0__PERIPHERAL__ENABLE 1 \
  CONFIG.PSU__SPI0__PERIPHERAL__IO {EMIO} \
  CONFIG.PSU__SPI0__GRP_SS1__ENABLE 0 \
  CONFIG.PSU__SPI0__GRP_SS2__ENABLE 0 \
  CONFIG.PSU__CRL_APB__SPI0_REF_CTRL__FREQMHZ 100 \
] [get_bd_cells sys_ps8]

ad_ip_instance proc_sys_reset sys_rstgen
ad_ip_parameter sys_rstgen CONFIG.C_EXT_RST_WIDTH 1

ad_ip_instance proc_sys_reset user_rstgen
ad_ip_parameter user_rstgen CONFIG.C_EXT_RST_WIDTH 1

set_property -dict [list \
  CONFIG.PSU__I2C0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__I2C0__PERIPHERAL__IO {MIO 38 .. 39} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__I2C1__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__I2C1__PERIPHERAL__IO {MIO 28 .. 29} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__UART0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__UART0__PERIPHERAL__IO {MIO 30 .. 31} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__UART1__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__UART1__PERIPHERAL__IO {EMIO} \
  CONFIG.PSU__UART1__BAUD_RATE {115200}
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__SD0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__SD0__SLOT_TYPE {eMMC} \
  CONFIG.PSU__SD0__DATA_TRANSFER_MODE {8Bit} \
  CONFIG.PSU__SD0__PERIPHERAL__IO {MIO 13 .. 22} \
  CONFIG.PSU__SD0__RESET__ENABLE {1} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__SD1__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__SD1__PERIPHERAL__IO {MIO 46 .. 51} \
  CONFIG.PSU__SD1__SLOT_TYPE {SD 2.0} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__PMU__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__PMU__GPI0__ENABLE {0} \
  CONFIG.PSU__PMU__GPI1__ENABLE {0} \
  CONFIG.PSU__PMU__GPI2__ENABLE {0} \
  CONFIG.PSU__PMU__GPI3__ENABLE {0} \
  CONFIG.PSU__PMU__GPI4__ENABLE {0} \
  CONFIG.PSU__PMU__GPI5__ENABLE {0} \
  CONFIG.PSU__PMU__GPO1__ENABLE {0} \
  CONFIG.PSU__PMU__GPO2__ENABLE {0} \
  CONFIG.PSU__PMU__GPO3__ENABLE {0} \
  CONFIG.PSU__PMU__GPO4__ENABLE {0} \
  CONFIG.PSU__PMU__GPO5__ENABLE {0} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__QSPI__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__QSPI__PERIPHERAL__MODE {Dual Parallel} \
  CONFIG.PSU__QSPI__GRP_FBCLK__ENABLE {1} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__SWDT0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__SWDT1__PERIPHERAL__ENABLE {1} \
] [get_bd_cells sys_ps8]

set_property -dict [list \
  CONFIG.PSU__TTC0__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__TTC1__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__TTC2__PERIPHERAL__ENABLE {1} \
  CONFIG.PSU__TTC3__PERIPHERAL__ENABLE {1} \
] [get_bd_cells sys_ps8]

# system reset/clock definitions
ad_connect  sys_500m_clk sys_ps8/pl_clk1

ad_connect  sys_cpu_clk sys_ps8/pl_clk0
ad_connect  sys_cpu_clk sys_rstgen/slowest_sync_clk
ad_connect  sys_cpu_reset sys_rstgen/peripheral_reset
ad_connect  sys_cpu_resetn sys_rstgen/peripheral_aresetn
ad_connect  sys_ps8/pl_resetn0 sys_rstgen/ext_reset_in

ad_connect  sys_user_clk sys_ps8/pl_clk2
ad_connect  sys_user_clk user_rstgen/slowest_sync_clk
ad_connect  sys_user_resetn user_rstgen/peripheral_aresetn
ad_connect  sys_cpu_resetn user_rstgen/ext_reset_in

# gpio

ad_connect  gpio_o sys_ps8/emio_gpio_o
ad_connect  gpio_t sys_ps8/emio_gpio_t

# spi

ad_connect  sys_ps8/emio_spi0_ss_o_n spi0_csn
ad_connect  sys_ps8/emio_spi0_sclk_o spi0_sclk
ad_connect  sys_ps8/emio_spi0_m_o spi0_mosi
ad_connect  sys_ps8/emio_spi0_m_i spi0_miso
ad_connect  sys_ps8/emio_spi0_ss_i_n VCC
ad_connect  sys_ps8/emio_spi0_sclk_i GND
ad_connect  sys_ps8/emio_spi0_s_i GND

# uart1

ad_connect  sys_ps8/emio_uart1_rxd emio_uart1_rxd
ad_connect  sys_ps8/emio_uart1_txd emio_uart1_txd

# interrupts

ad_ip_instance xlconcat sys_concat_intc_0
ad_ip_parameter sys_concat_intc_0 CONFIG.NUM_PORTS 8

ad_ip_instance xlconcat sys_concat_intc_1
ad_ip_parameter sys_concat_intc_1 CONFIG.NUM_PORTS 8

ad_connect  sys_concat_intc_0/dout sys_ps8/pl_ps_irq0
ad_connect  sys_concat_intc_1/dout sys_ps8/pl_ps_irq1

ad_connect  sys_concat_intc_1/In7 ps_intr_15
ad_connect  sys_concat_intc_1/In6 ps_intr_14
ad_connect  sys_concat_intc_1/In5 ps_intr_13
ad_connect  sys_concat_intc_1/In4 ps_intr_12
ad_connect  sys_concat_intc_1/In3 ps_intr_11
ad_connect  sys_concat_intc_1/In2 ps_intr_10
ad_connect  sys_concat_intc_1/In1 ps_intr_09
ad_connect  sys_concat_intc_1/In0 ps_intr_08
ad_connect  sys_concat_intc_0/In7 ps_intr_07
ad_connect  sys_concat_intc_0/In6 ps_intr_06
ad_connect  sys_concat_intc_0/In5 ps_intr_05
ad_connect  sys_concat_intc_0/In4 ps_intr_04
ad_connect  sys_concat_intc_0/In3 ps_intr_03
ad_connect  sys_concat_intc_0/In2 ps_intr_02
ad_connect  sys_concat_intc_0/In1 ps_intr_01
ad_connect  sys_concat_intc_0/In0 ps_intr_00
