# SPDX-License-Identifier: Apache-2.0

#create_bd_port -dir I ref_clk

create_bd_port -dir I tx_output_enable

create_bd_port -dir I mssi_sync

# adrv9001 interface
create_bd_port -dir I rx1_dclk_in_n
create_bd_port -dir I rx1_dclk_in_p
create_bd_port -dir I rx1_idata_in_n
create_bd_port -dir I rx1_idata_in_p
create_bd_port -dir I rx1_qdata_in_n
create_bd_port -dir I rx1_qdata_in_p
create_bd_port -dir I rx1_strobe_in_n
create_bd_port -dir I rx1_strobe_in_p

create_bd_port -dir I rx2_dclk_in_n
create_bd_port -dir I rx2_dclk_in_p
create_bd_port -dir I rx2_idata_in_n
create_bd_port -dir I rx2_idata_in_p
create_bd_port -dir I rx2_qdata_in_n
create_bd_port -dir I rx2_qdata_in_p
create_bd_port -dir I rx2_strobe_in_n
create_bd_port -dir I rx2_strobe_in_p

create_bd_port -dir O tx1_dclk_out_n
create_bd_port -dir O tx1_dclk_out_p
create_bd_port -dir O tx1_idata_out_n
create_bd_port -dir O tx1_idata_out_p
create_bd_port -dir O tx1_qdata_out_n
create_bd_port -dir O tx1_qdata_out_p
create_bd_port -dir O tx1_strobe_out_n
create_bd_port -dir O tx1_strobe_out_p

create_bd_port -dir O tx2_dclk_out_n
create_bd_port -dir O tx2_dclk_out_p
create_bd_port -dir O tx2_idata_out_n
create_bd_port -dir O tx2_idata_out_p
create_bd_port -dir O tx2_qdata_out_n
create_bd_port -dir O tx2_qdata_out_p
create_bd_port -dir O tx2_strobe_out_n
create_bd_port -dir O tx2_strobe_out_p

create_bd_port -dir O rx1_enable
create_bd_port -dir O rx2_enable
create_bd_port -dir O tx1_enable
create_bd_port -dir O tx2_enable

create_bd_port -dir I gpio_rx1_enable_in
create_bd_port -dir I gpio_rx2_enable_in
create_bd_port -dir I gpio_tx1_enable_in
create_bd_port -dir I gpio_tx2_enable_in

create_bd_port -dir I tdd_sync
create_bd_port -dir O tdd_sync_cntr

create_bd_port -dir I pps

# Create Blocks

# adrv9001

ad_ip_instance axi_adrv9001 axi_adrv9001
ad_ip_parameter axi_adrv9001 CONFIG.CMOS_LVDS_N 0
ad_ip_parameter axi_adrv9001 CONFIG.USE_RX_CLK_FOR_TX1 1
ad_ip_parameter axi_adrv9001 CONFIG.USE_RX_CLK_FOR_TX2 1

ad_ip_instance proc_sys_reset adc_clk_reset_0
ad_ip_instance proc_sys_reset adc_clk_reset_1

ad_ip_instance concat_9002 concat_9002_0
ad_ip_instance concat_9002 concat_9002_1

ad_ip_instance  default_block   default_block_0
ad_ip_parameter default_block_0 CONFIG.CLK_FREQ 100000000
ad_ip_parameter default_block_0 CONFIG.ENABLE_DUAL_CIC 1

ad_ip_instance  default_block   default_block_1
ad_ip_parameter default_block_1 CONFIG.CLK_FREQ 100000000
ad_ip_parameter default_block_1 CONFIG.ENABLE_DUAL_CIC 0

# dma for rx1

ad_ip_instance axi_dmac axi_adrv9001_rx1_dma
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.DMA_DATA_WIDTH_SRC 64
ad_ip_parameter axi_adrv9001_rx1_dma CONFIG.CACHE_COHERENT 1

# dma for rx2

ad_ip_instance axi_dmac axi_adrv9001_rx2_dma
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.DMA_DATA_WIDTH_SRC 32
ad_ip_parameter axi_adrv9001_rx2_dma CONFIG.CACHE_COHERENT 1

# dma for tx1

ad_ip_instance axi_dmac axi_adrv9001_tx1_dma
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.DMA_DATA_WIDTH_DEST 64
ad_ip_parameter axi_adrv9001_tx1_dma CONFIG.CACHE_COHERENT 1

# dma for tx2

ad_ip_instance axi_dmac axi_adrv9001_tx2_dma
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.DMA_DATA_WIDTH_DEST 32
ad_ip_parameter axi_adrv9001_tx2_dma CONFIG.CACHE_COHERENT 1

# ad9001 connections

ad_connect  sys_500m_clk       axi_adrv9001/delay_clk

#### STILL UNDER REVIEW
#ad_connect  axi_adrv9001/adc_1_clk axi_adrv9001_rx1_dma/fifo_wr_clk
#ad_connect  axi_adrv9001/adc_2_clk axi_adrv9001_rx2_dma/fifo_wr_clk
#ad_connect  axi_adrv9001/dac_1_clk axi_adrv9001_tx1_dma/m_axis_aclk
#ad_connect  axi_adrv9001/dac_2_clk axi_adrv9001_tx2_dma/m_axis_aclk
####

#ad_connect ref_clk           axi_adrv9001/ref_clk

ad_connect tx_output_enable  axi_adrv9001/tx_output_enable

ad_connect mssi_sync         axi_adrv9001/mssi_sync

ad_connect rx1_dclk_in_n     axi_adrv9001/rx1_dclk_in_n_NC
ad_connect rx1_dclk_in_p     axi_adrv9001/rx1_dclk_in_p_dclk_in
ad_connect rx1_idata_in_n    axi_adrv9001/rx1_idata_in_n_idata0
ad_connect rx1_idata_in_p    axi_adrv9001/rx1_idata_in_p_idata1
ad_connect rx1_qdata_in_n    axi_adrv9001/rx1_qdata_in_n_qdata2
ad_connect rx1_qdata_in_p    axi_adrv9001/rx1_qdata_in_p_qdata3
ad_connect rx1_strobe_in_n   axi_adrv9001/rx1_strobe_in_n_NC
ad_connect rx1_strobe_in_p   axi_adrv9001/rx1_strobe_in_p_strobe_in

ad_connect rx2_dclk_in_n     axi_adrv9001/rx2_dclk_in_n_NC
ad_connect rx2_dclk_in_p     axi_adrv9001/rx2_dclk_in_p_dclk_in
ad_connect rx2_idata_in_n    axi_adrv9001/rx2_idata_in_n_idata0
ad_connect rx2_idata_in_p    axi_adrv9001/rx2_idata_in_p_idata1
ad_connect rx2_qdata_in_n    axi_adrv9001/rx2_qdata_in_n_qdata2
ad_connect rx2_qdata_in_p    axi_adrv9001/rx2_qdata_in_p_qdata3
ad_connect rx2_strobe_in_n   axi_adrv9001/rx2_strobe_in_n_NC
ad_connect rx2_strobe_in_p   axi_adrv9001/rx2_strobe_in_p_strobe_in

ad_connect tx1_dclk_out_n    axi_adrv9001/tx1_dclk_out_n_NC
ad_connect tx1_dclk_out_p    axi_adrv9001/tx1_dclk_out_p_dclk_out
ad_connect tx1_idata_out_n   axi_adrv9001/tx1_idata_out_n_idata0
ad_connect tx1_idata_out_p   axi_adrv9001/tx1_idata_out_p_idata1
ad_connect tx1_qdata_out_n   axi_adrv9001/tx1_qdata_out_n_qdata2
ad_connect tx1_qdata_out_p   axi_adrv9001/tx1_qdata_out_p_qdata3
ad_connect tx1_strobe_out_n  axi_adrv9001/tx1_strobe_out_n_NC
ad_connect tx1_strobe_out_p  axi_adrv9001/tx1_strobe_out_p_strobe_out

ad_connect tx2_dclk_out_n    axi_adrv9001/tx2_dclk_out_n_NC
ad_connect tx2_dclk_out_p    axi_adrv9001/tx2_dclk_out_p_dclk_out
ad_connect tx2_idata_out_n   axi_adrv9001/tx2_idata_out_n_idata0
ad_connect tx2_idata_out_p   axi_adrv9001/tx2_idata_out_p_idata1
ad_connect tx2_qdata_out_n   axi_adrv9001/tx2_qdata_out_n_qdata2
ad_connect tx2_qdata_out_p   axi_adrv9001/tx2_qdata_out_p_qdata3
ad_connect tx2_strobe_out_n  axi_adrv9001/tx2_strobe_out_n_NC
ad_connect tx2_strobe_out_p  axi_adrv9001/tx2_strobe_out_p_strobe_out

ad_connect rx1_enable        axi_adrv9001/rx1_enable
ad_connect rx2_enable        axi_adrv9001/rx2_enable
ad_connect tx1_enable        axi_adrv9001/tx1_enable
ad_connect tx2_enable        axi_adrv9001/tx2_enable

ad_connect gpio_rx1_enable_in  axi_adrv9001/gpio_rx1_enable_in
ad_connect gpio_rx2_enable_in  axi_adrv9001/gpio_rx2_enable_in
ad_connect gpio_tx1_enable_in  axi_adrv9001/gpio_tx1_enable_in
ad_connect gpio_tx2_enable_in  axi_adrv9001/gpio_tx2_enable_in

ad_connect tdd_sync axi_adrv9001/tdd_sync
ad_connect tdd_sync_cntr axi_adrv9001/tdd_sync_cntr

# adc clk resets
ad_connect sys_cpu_resetn adc_clk_reset_0/ext_reset_in
ad_connect sys_cpu_resetn adc_clk_reset_1/ext_reset_in
ad_connect axi_adrv9001/adc_1_clk adc_clk_reset_0/slowest_sync_clk
ad_connect axi_adrv9001/adc_2_clk adc_clk_reset_1/slowest_sync_clk

# ADRV9002 <-> concat_0
ad_connect axi_adrv9001/adc_1_enable_i0 concat_9002_0/adc_enable_i0
ad_connect axi_adrv9001/adc_1_valid_i0  concat_9002_0/adc_valid_i0
ad_connect axi_adrv9001/adc_1_data_i0   concat_9002_0/adc_data_i0
ad_connect axi_adrv9001/adc_1_enable_q0 concat_9002_0/adc_enable_q0
ad_connect axi_adrv9001/adc_1_valid_q0  concat_9002_0/adc_valid_q0
ad_connect axi_adrv9001/adc_1_data_q0   concat_9002_0/adc_data_q0
ad_connect axi_adrv9001/adc_1_enable_i1 concat_9002_0/adc_enable_i1
ad_connect axi_adrv9001/adc_1_valid_i1  concat_9002_0/adc_valid_i1
ad_connect axi_adrv9001/adc_1_data_i1   concat_9002_0/adc_data_i1
ad_connect axi_adrv9001/adc_1_enable_q1 concat_9002_0/adc_enable_q1
ad_connect axi_adrv9001/adc_1_valid_q1  concat_9002_0/adc_valid_q1
ad_connect axi_adrv9001/adc_1_data_q1   concat_9002_0/adc_data_q1

ad_connect axi_adrv9001/dac_1_enable_i0 concat_9002_0/dac_enable_i0
ad_connect axi_adrv9001/dac_1_valid_i0  concat_9002_0/dac_valid_i0
ad_connect axi_adrv9001/dac_1_enable_q0 concat_9002_0/dac_enable_q0
ad_connect axi_adrv9001/dac_1_valid_q0  concat_9002_0/dac_valid_q0
ad_connect axi_adrv9001/dac_1_enable_i1 concat_9002_0/dac_enable_i1
ad_connect axi_adrv9001/dac_1_valid_i1  concat_9002_0/dac_valid_i1
ad_connect axi_adrv9001/dac_1_enable_q1 concat_9002_0/dac_enable_q1
ad_connect axi_adrv9001/dac_1_valid_q1  concat_9002_0/dac_valid_q1

ad_connect concat_9002_0/dac_data_i0 axi_adrv9001/dac_1_data_i0
ad_connect concat_9002_0/dac_data_q0 axi_adrv9001/dac_1_data_q0
ad_connect concat_9002_0/dac_data_i1 axi_adrv9001/dac_1_data_i1
ad_connect concat_9002_0/dac_data_q1 axi_adrv9001/dac_1_data_q1

# ADRV9002 <-> concat_1
ad_connect axi_adrv9001/adc_2_enable_i0 concat_9002_1/adc_enable_i0
ad_connect axi_adrv9001/adc_2_valid_i0  concat_9002_1/adc_valid_i0
ad_connect axi_adrv9001/adc_2_data_i0   concat_9002_1/adc_data_i0
ad_connect axi_adrv9001/adc_2_enable_q0 concat_9002_1/adc_enable_q0
ad_connect axi_adrv9001/adc_2_valid_q0  concat_9002_1/adc_valid_q0
ad_connect axi_adrv9001/adc_2_data_q0   concat_9002_1/adc_data_q0
ad_connect GND                          concat_9002_1/adc_enable_i1
ad_connect GND                          concat_9002_1/adc_valid_i1
ad_connect GND                          concat_9002_1/adc_data_i1
ad_connect GND                          concat_9002_1/adc_enable_q1
ad_connect GND                          concat_9002_1/adc_valid_q1
ad_connect GND                          concat_9002_1/adc_data_q1

ad_connect axi_adrv9001/dac_2_enable_i0 concat_9002_1/dac_enable_i0
ad_connect axi_adrv9001/dac_2_valid_i0  concat_9002_1/dac_valid_i0
ad_connect axi_adrv9001/dac_2_enable_q0 concat_9002_1/dac_enable_q0
ad_connect axi_adrv9001/dac_2_valid_q0  concat_9002_1/dac_valid_q0

ad_connect concat_9002_1/dac_data_i0 axi_adrv9001/dac_2_data_i0
ad_connect concat_9002_1/dac_data_q0 axi_adrv9001/dac_2_data_q0

# default_block_0 -> ADRV9002
ad_connect default_block_0/adc_overflow  axi_adrv9001/adc_1_dovf
ad_connect default_block_0/dac_underflow axi_adrv9001/dac_1_dunf

# default_block_1 -> ADRV9002
ad_connect default_block_1/adc_overflow  axi_adrv9001/adc_2_dovf
ad_connect default_block_1/dac_underflow axi_adrv9001/dac_2_dunf

# default_block_0 <-> concat_0
ad_connect concat_9002_0/adc_data   default_block_0/adc_data
ad_connect concat_9002_0/adc_enable default_block_0/adc_enable
ad_connect concat_9002_0/adc_valid  default_block_0/adc_valid

ad_connect default_block_0/dac_data concat_9002_0/dac_data
ad_connect concat_9002_0/dac_enable default_block_0/dac_enable
ad_connect concat_9002_0/dac_valid  default_block_0/dac_valid

# default_block_1 <-> concat_1
ad_connect concat_9002_1/adc_data   default_block_1/adc_data
ad_connect concat_9002_1/adc_enable default_block_1/adc_enable
ad_connect concat_9002_1/adc_valid  default_block_1/adc_valid

ad_connect default_block_1/dac_data concat_9002_1/dac_data
ad_connect concat_9002_1/dac_enable default_block_1/dac_enable
ad_connect concat_9002_1/dac_valid  default_block_1/dac_valid

# DAC_DMA -> default_block
ad_connect axi_adrv9001_tx1_dma/m_axis default_block_0/s_dac_dma
ad_connect axi_adrv9001_tx2_dma/m_axis default_block_1/s_dac_dma

# default_block -> ADC_DMA
ad_connect default_block_0/m_adc_dma axi_adrv9001_rx1_dma/s_axis
ad_connect default_block_1/m_adc_dma axi_adrv9001_rx2_dma/s_axis

# pps
ad_connect pps default_block_0/pps
ad_connect pps default_block_1/pps

#### BREAK

# Test Block: Clock and Resets
ad_connect axi_adrv9001/adc_1_clk default_block_0/adc_clk
ad_connect axi_adrv9001/adc_2_clk default_block_1/adc_clk
ad_connect axi_adrv9001/dac_1_clk default_block_0/dac_clk
ad_connect axi_adrv9001/dac_2_clk default_block_1/dac_clk
ad_connect sys_user_clk default_block_0/user_clk
ad_connect sys_user_clk default_block_0/m_adc_dma_aclk
ad_connect sys_user_clk default_block_0/s_dac_dma_aclk
ad_connect sys_user_clk default_block_1/user_clk
ad_connect sys_user_clk default_block_1/m_adc_dma_aclk
ad_connect sys_user_clk default_block_1/s_dac_dma_aclk
ad_connect sys_user_clk axi_adrv9001_rx1_dma/s_axis_aclk
ad_connect sys_user_clk axi_adrv9001_rx2_dma/s_axis_aclk
ad_connect sys_user_clk axi_adrv9001_tx1_dma/m_axis_aclk
ad_connect sys_user_clk axi_adrv9001_tx2_dma/m_axis_aclk

ad_connect adc_clk_reset_0/peripheral_aresetn default_block_0/adc_rstn
ad_connect adc_clk_reset_0/peripheral_aresetn default_block_0/dac_rstn
ad_connect adc_clk_reset_1/peripheral_aresetn default_block_1/adc_rstn
ad_connect adc_clk_reset_1/peripheral_aresetn default_block_1/dac_rstn
ad_connect sys_user_resetn default_block_0/user_resetn
ad_connect sys_user_resetn default_block_0/m_adc_dma_aresetn
ad_connect sys_user_resetn default_block_0/s_dac_dma_aresetn
ad_connect sys_user_resetn default_block_1/user_resetn
ad_connect sys_user_resetn default_block_1/m_adc_dma_aresetn
ad_connect sys_user_resetn default_block_1/s_dac_dma_aresetn

# DMA
ad_connect sys_cpu_resetn axi_adrv9001_rx1_dma/m_dest_axi_aresetn
ad_connect sys_cpu_resetn axi_adrv9001_rx2_dma/m_dest_axi_aresetn

# ADC
ad_connect sys_cpu_resetn axi_adrv9001_tx1_dma/m_src_axi_aresetn
ad_connect sys_cpu_resetn axi_adrv9001_tx2_dma/m_src_axi_aresetn

# interconnects

ad_cpu_interconnect 0x44A00000  axi_adrv9001
ad_cpu_interconnect 0x44A30000  axi_adrv9001_rx1_dma
ad_cpu_interconnect 0x44A40000  axi_adrv9001_rx2_dma
ad_cpu_interconnect 0x44A50000  axi_adrv9001_tx1_dma
ad_cpu_interconnect 0x44A60000  axi_adrv9001_tx2_dma
ad_cpu_interconnect 0x7D000000  default_block_0
ad_cpu_interconnect 0x7E000000  default_block_1

# memory interconnect
ad_mem_hpc0_interconnect sys_cpu_clk sys_ps8/S_AXI_HPC0
ad_mem_hpc0_interconnect sys_cpu_clk axi_adrv9001_rx1_dma/m_dest_axi
ad_mem_hpc0_interconnect sys_cpu_clk axi_adrv9001_rx2_dma/m_dest_axi
ad_mem_hpc0_interconnect sys_cpu_clk axi_adrv9001_tx1_dma/m_src_axi
ad_mem_hpc0_interconnect sys_cpu_clk axi_adrv9001_tx2_dma/m_src_axi

# interrupts
ad_cpu_interrupt ps-13 mb-12 axi_adrv9001_rx1_dma/irq
ad_cpu_interrupt ps-12 mb-11 axi_adrv9001_rx2_dma/irq
ad_cpu_interrupt ps-9  mb-6 axi_adrv9001_tx1_dma/irq
ad_cpu_interrupt ps-10 mb-5 axi_adrv9001_tx2_dma/irq
