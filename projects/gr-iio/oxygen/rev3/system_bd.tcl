# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [ file dirname [ file normalize [ info script ]/... ] ] ]

puts $script_dir

source "$script_dir/../../../common/oxygen/rev3/oxygen_system_bd.tcl"
source "$script_dir/../../scripts/griio_bd.tcl"
source "$script_dir/../../../common/scripts/common_bd.tcl"
