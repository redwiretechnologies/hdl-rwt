# ip

if {$argc < 1} {
    puts "Project directory must be specified"
    exit 1
}

set AD_LIB_DIR [lindex $argv 0]
set script_dir [ file dirname [ file normalize [ info script ] ] ]

source $AD_LIB_DIR/scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create concat_9002
adi_ip_files concat_9002 [list \
  "$script_dir/src/concat_9002.v" \
  "$script_dir/concat_9002_constr.xdc" ]

adi_ip_properties_lite concat_9002

set_property vendor ornl.gov [ipx::current_core]
set_property library user [ipx::current_core]
set_property taxonomy /ORNL [ipx::current_core]
set_property vendor_display_name {ORNL} [ipx::current_core]
set_property company_url {http://www.ornl.gov} [ipx::current_core]

ipx::remove_all_bus_interface [ipx::current_core]
ipx::save_core [ipx::current_core]
