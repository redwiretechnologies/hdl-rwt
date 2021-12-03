set script_dir [file dirname [ file dirname [ file normalize [ info script ]/... ] ] ]

puts $script_dir

source $script_dir/../../../common/oxygen/rev3/oxygen_system_bd.tcl
source $script_dir/../../scripts/blank_bd.tcl
