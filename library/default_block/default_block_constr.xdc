# SPDX-License-Identifier: Apache-2.0

set_property ASYNC_REG TRUE [get_cells -hier -filter {name =~ *i_address_gray/*/cdc_sync_stage1*}]
set_false_path -to [get_cells -hier -filter {name =~ *i_address_gray/*/cdc_sync_stage1* && IS_SEQUENTIAL}]

set_property ASYNC_REG TRUE [get_cells -hier -filter {name =~ *sync_overflow/*/cdc_sync_stage1*}]
set_false_path -to [get_cells -hier -filter {name =~ *sync_overflow/*/cdc_sync_stage1*}]

set_property ASYNC_REG TRUE [get_cells -hier -filter {name =~ *sync_underflow/*/cdc_sync_stage1*}]
set_false_path -to [get_cells -hier -filter {name =~ *sync_underflow/*/cdc_sync_stage1*}]
