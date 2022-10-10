hsi open_hw_design [lindex $argv 0]
hsi generate_app -os standalone -proc psu_pmu_0 -app zynqmp_pmufw -compile -sw pmufw -dir my_pmufw
exit
