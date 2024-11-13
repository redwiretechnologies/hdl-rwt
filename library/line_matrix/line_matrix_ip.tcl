# SPDX-License-Identifier: Apache-2.0

# ip

if {$argc < 1} {
    puts "Project directory must be specified"
    exit 1
}

set AD_LIB_DIR [lindex $argv 0]
set script_dir [ file dirname [ file normalize [ info script ] ] ]

source $AD_LIB_DIR/scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

set sim_files [list \
    "$script_dir/sim/line_matrix.sv" ]

adi_ip_create line_matrix
adi_ip_files line_matrix [list \
  "$script_dir/src/line_matrix.v" \
  "$script_dir/src/line_mux.v" \
  "$script_dir/line_matrix_constr.xdc" ]
add_files -norecurse -scan_for_includes -fileset [get_filesets sim_1] $sim_files

adi_ip_properties_lite line_matrix

set_property vendor redwiretechnologies.us [ipx::current_core]
set_property library user [ipx::current_core]
set_property taxonomy /RWT [ipx::current_core]
set_property vendor_display_name {RWT} [ipx::current_core]
set_property company_url {http://www.redwiretechnologies.us} [ipx::current_core]

ipx::remove_all_bus_interface [ipx::current_core]
ipx::save_core [ipx::current_core]
