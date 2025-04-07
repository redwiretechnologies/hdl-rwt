# SPDX-License-Identifier: Apache-2.0

hsi open_hw_design [lindex $argv 0]
hsi generate_app -os standalone -proc psu_cortexa53_0 -app zynqmp_fsbl -compile -sw fsbl -dir my_fsbl
exit
