# SPDX-License-Identifier: Apache-2.0

lappend project_files \
  "$script_dir/../../../common/oxygen/rev3/oxygen_system_constr.xdc"

if {[info exists NO_ADRV9002] != 0} {
    lappend project_files \
      "$script_dir/../../../common/shared/$supported_boards/fake_adrv9002_constr.xdc"
} else {
    lappend project_files \
      "$script_dir/../../../common/shared/$supported_boards/adrv9002_constr.xdc"
}
