# SPDX-License-Identifier: Apache-2.0

create_bd_port -dir I rx_clk_in_p
create_bd_port -dir I rx_clk_in_n
create_bd_port -dir I rx_frame_in_p
create_bd_port -dir I rx_frame_in_n
create_bd_port -dir I -from 5 -to 0 rx_data_in_p
create_bd_port -dir I -from 5 -to 0 rx_data_in_n

create_bd_port -dir O tx_clk_out_p
create_bd_port -dir O tx_clk_out_n
create_bd_port -dir O tx_frame_out_p
create_bd_port -dir O tx_frame_out_n
create_bd_port -dir O -from 5 -to 0 tx_data_out_p
create_bd_port -dir O -from 5 -to 0 tx_data_out_n

create_bd_port -dir O enable
create_bd_port -dir O txnrx
create_bd_port -dir I up_enable
create_bd_port -dir I up_txnrx

create_bd_port -dir O tdd_sync_o
create_bd_port -dir I tdd_sync_i
create_bd_port -dir O tdd_sync_t

create_bd_port -dir I pps

# Create Blocks
ad_ip_instance axi_ad9361 axi_ad9361
ad_ip_parameter axi_ad9361 CONFIG.ID 0

ad_ip_instance util_tdd_sync util_ad9361_tdd_sync
ad_ip_parameter util_ad9361_tdd_sync CONFIG.TDD_SYNC_PERIOD 10000000

ad_ip_instance proc_sys_reset adc_clk_reset

ad_ip_instance concat_9361 concat_9361

ad_ip_instance default_block default_block
ad_ip_parameter default_block CONFIG.CLK_FREQ 100000000
ad_ip_parameter default_block CONFIG.ENABLE_DUAL_CIC 1

ad_ip_instance axi_dmac axi_ad9361_adc_dma
ad_ip_parameter axi_ad9361_adc_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_ad9361_adc_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad9361_adc_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad9361_adc_dma CONFIG.SYNC_TRANSFER_START 1
ad_ip_parameter axi_ad9361_adc_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad9361_adc_dma CONFIG.AXI_SLICE_DEST 0
ad_ip_parameter axi_ad9361_adc_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad9361_adc_dma CONFIG.DMA_DATA_WIDTH_SRC 64

ad_ip_instance axi_dmac axi_ad9361_dac_dma
ad_ip_parameter axi_ad9361_dac_dma CONFIG.DMA_TYPE_SRC 0
ad_ip_parameter axi_ad9361_dac_dma CONFIG.DMA_TYPE_DEST 1
ad_ip_parameter axi_ad9361_dac_dma CONFIG.CYCLIC 1
ad_ip_parameter axi_ad9361_dac_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad9361_dac_dma CONFIG.AXI_SLICE_SRC 0
ad_ip_parameter axi_ad9361_dac_dma CONFIG.AXI_SLICE_DEST 1
ad_ip_parameter axi_ad9361_dac_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad9361_dac_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# ad9361 -> Outside world

ad_connect sys_500m_clk axi_ad9361/delay_clk
ad_connect axi_ad9361/l_clk axi_ad9361/clk
ad_connect rx_clk_in_p axi_ad9361/rx_clk_in_p
ad_connect rx_clk_in_n axi_ad9361/rx_clk_in_n
ad_connect rx_frame_in_p axi_ad9361/rx_frame_in_p
ad_connect rx_frame_in_n axi_ad9361/rx_frame_in_n
ad_connect rx_data_in_p axi_ad9361/rx_data_in_p
ad_connect rx_data_in_n axi_ad9361/rx_data_in_n
ad_connect tx_clk_out_p axi_ad9361/tx_clk_out_p
ad_connect tx_clk_out_n axi_ad9361/tx_clk_out_n
ad_connect tx_frame_out_p axi_ad9361/tx_frame_out_p
ad_connect tx_frame_out_n axi_ad9361/tx_frame_out_n
ad_connect tx_data_out_p axi_ad9361/tx_data_out_p
ad_connect tx_data_out_n axi_ad9361/tx_data_out_n
ad_connect enable axi_ad9361/enable
ad_connect txnrx axi_ad9361/txnrx
ad_connect up_enable axi_ad9361/up_enable
ad_connect up_txnrx axi_ad9361/up_txnrx

# tdd-sync

ad_connect sys_cpu_clk util_ad9361_tdd_sync/clk
ad_connect sys_cpu_resetn util_ad9361_tdd_sync/rstn
ad_connect util_ad9361_tdd_sync/sync_out axi_ad9361/tdd_sync
ad_connect util_ad9361_tdd_sync/sync_mode axi_ad9361/tdd_sync_cntr
ad_connect tdd_sync_t axi_ad9361/tdd_sync_cntr
ad_connect tdd_sync_o util_ad9361_tdd_sync/sync_out
ad_connect tdd_sync_i util_ad9361_tdd_sync/sync_in

# adc clk resets

ad_connect sys_cpu_resetn adc_clk_reset/ext_reset_in
ad_connect axi_ad9361/l_clk adc_clk_reset/slowest_sync_clk

# AD9361 <-> concat
ad_connect axi_ad9361/adc_enable_i0 concat_9361/adc_enable_i0
ad_connect axi_ad9361/adc_valid_i0 concat_9361/adc_valid_i0
ad_connect axi_ad9361/adc_data_i0 concat_9361/adc_data_i0
ad_connect axi_ad9361/adc_enable_q0 concat_9361/adc_enable_q0
ad_connect axi_ad9361/adc_valid_q0 concat_9361/adc_valid_q0
ad_connect axi_ad9361/adc_data_q0 concat_9361/adc_data_q0
ad_connect axi_ad9361/adc_enable_i1 concat_9361/adc_enable_i1
ad_connect axi_ad9361/adc_valid_i1 concat_9361/adc_valid_i1
ad_connect axi_ad9361/adc_data_i1 concat_9361/adc_data_i1
ad_connect axi_ad9361/adc_enable_q1 concat_9361/adc_enable_q1
ad_connect axi_ad9361/adc_valid_q1 concat_9361/adc_valid_q1
ad_connect axi_ad9361/adc_data_q1 concat_9361/adc_data_q1

ad_connect axi_ad9361/dac_enable_i0 concat_9361/dac_enable_i0
ad_connect axi_ad9361/dac_valid_i0 concat_9361/dac_valid_i0
ad_connect axi_ad9361/dac_enable_q0 concat_9361/dac_enable_q0
ad_connect axi_ad9361/dac_valid_q0 concat_9361/dac_valid_q0
ad_connect axi_ad9361/dac_enable_i1 concat_9361/dac_enable_i1
ad_connect axi_ad9361/dac_valid_i1 concat_9361/dac_valid_i1
ad_connect axi_ad9361/dac_enable_q1 concat_9361/dac_enable_q1
ad_connect axi_ad9361/dac_valid_q1 concat_9361/dac_valid_q1

ad_connect concat_9361/dac_data_i0 axi_ad9361/dac_data_i0
ad_connect concat_9361/dac_data_q0 axi_ad9361/dac_data_q0
ad_connect concat_9361/dac_data_i1 axi_ad9361/dac_data_i1
ad_connect concat_9361/dac_data_q1 axi_ad9361/dac_data_q1

# default_block -> AD9361
ad_connect default_block/adc_overflow axi_ad9361/adc_dovf
ad_connect default_block/dac_underflow axi_ad9361/dac_dunf

# default_block <-> concat
ad_connect concat_9361/adc_data default_block/adc_data
ad_connect concat_9361/adc_enable default_block/adc_enable
ad_connect concat_9361/adc_valid default_block/adc_valid

ad_connect default_block/dac_data concat_9361/dac_data
ad_connect concat_9361/dac_enable default_block/dac_enable
ad_connect concat_9361/dac_valid default_block/dac_valid

# DAC_DMA -> default_block
ad_connect axi_ad9361_dac_dma/m_axis default_block/s_dac_dma

# default_block -> ADC_DMA
ad_connect default_block/m_adc_dma axi_ad9361_adc_dma/s_axis

# pps
ad_connect pps default_block/pps

# Test Block: Clock and Resets
ad_connect axi_ad9361/l_clk default_block/adc_clk
ad_connect axi_ad9361/l_clk default_block/dac_clk
ad_connect sys_user_clk default_block/user_clk
ad_connect sys_user_clk default_block/m_adc_dma_aclk
ad_connect sys_user_clk default_block/s_dac_dma_aclk
ad_connect sys_user_clk axi_ad9361_dac_dma/m_axis_aclk
ad_connect sys_user_clk axi_ad9361_adc_dma/s_axis_aclk

ad_connect adc_clk_reset/peripheral_aresetn default_block/adc_rstn
ad_connect adc_clk_reset/peripheral_aresetn default_block/dac_rstn
ad_connect sys_user_resetn default_block/user_resetn
ad_connect sys_user_resetn default_block/m_adc_dma_aresetn
ad_connect sys_user_resetn default_block/s_dac_dma_aresetn

# DMA
ad_connect sys_cpu_resetn axi_ad9361_adc_dma/m_dest_axi_aresetn

# ADC
ad_connect sys_cpu_resetn axi_ad9361_dac_dma/m_src_axi_aresetn

# interconnects

ad_cpu_interconnect 0x79020000 axi_ad9361
ad_cpu_interconnect 0x7C400000 axi_ad9361_adc_dma
ad_cpu_interconnect 0x7C420000 axi_ad9361_dac_dma
ad_cpu_interconnect 0x7D000000 default_block

ad_mem_hp1_interconnect sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect sys_cpu_clk axi_ad9361_adc_dma/m_dest_axi
ad_mem_hp2_interconnect sys_cpu_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect sys_cpu_clk axi_ad9361_dac_dma/m_src_axi

# interrupts

ad_cpu_interrupt ps-13 mb-12 axi_ad9361_adc_dma/irq
ad_cpu_interrupt ps-12 mb-13 axi_ad9361_dac_dma/irq
