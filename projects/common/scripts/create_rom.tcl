# SPDX-License-Identifier: Apache-2.0

ad_ip_instance blk_mem_gen rom

set_property -dict [list \
  CONFIG.Memory_Type {Single_Port_ROM} \
  CONFIG.Enable_32bit_Address {true} \
  CONFIG.Use_Byte_Write_Enable {false} \
  CONFIG.Byte_Size {8} \
  CONFIG.Write_Depth_A {1024} \
  CONFIG.Enable_A {Always_Enabled} \
  CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
  CONFIG.Load_Init_File {true} \
  CONFIG.Coe_File {../../../../../../git_log.txt.coe} \
  CONFIG.Use_RSTA_Pin {true} \
  CONFIG.Port_A_Write_Rate {0} \
  CONFIG.use_bram_block {BRAM_Controller} \
  CONFIG.EN_SAFETY_CKT {true} \
] [get_bd_cells rom]

ad_ip_instance axi_bram_ctrl bram_ctrl

set_property -dict [list \
  CONFIG.SINGLE_PORT_BRAM {1} \
] [get_bd_cells bram_ctrl]

ad_connect bram_ctrl/BRAM_PORTA rom/BRAM_PORTA

ad_cpu_interconnect 0x7F000000 bram_ctrl
