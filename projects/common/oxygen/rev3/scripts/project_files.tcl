lappend project_files \
  "$script_dir/../../../common/oxygen/rev3/oxygen_system_constr.xdc"

if {[info exists NO_ADI9361] != 0} {
    lappend project_files \
      "$script_dir/../../../common/shared/$supported_boards/fake_ad9361_constr.xdc"
} else {
    lappend project_files \
      "$script_dir/../../../common/shared/$supported_boards/ad9361_constr.xdc"
}
