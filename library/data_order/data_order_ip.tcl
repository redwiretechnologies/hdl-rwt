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

adi_ip_create data_order
adi_ip_files data_order [list \
  "$script_dir/src/data_order.v" \
  "$script_dir/data_order_constr.xdc" ]

adi_ip_properties_lite data_order

set_property vendor redwiretechnologies.us [ipx::current_core]
set_property library user [ipx::current_core]
set_property taxonomy /RWT [ipx::current_core]
set_property vendor_display_name {RWT} [ipx::current_core]
set_property company_url {http://www.redwiretechnologies.us} [ipx::current_core]

ipx::remove_all_bus_interface [ipx::current_core]
ipx::save_core [ipx::current_core]
