hsi open_hw_design [lindex $argv 0]
hsi set_repo_path device-tree-xlnx
hsi create_sw_design device-tree -os device_tree -proc psu_cortexa53_0
hsi generate_target -dir my_dts
exit
