# SPDX-License-Identifier: Apache-2.0
# ip

set AD_LIB_DIR [lindex $argv 0]
set script_dir [ file dirname [ file normalize [ info script ] ] ]

source $AD_LIB_DIR/scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create cic_filter
adi_ip_files cic_filter [list \
  "$ad_hdl_dir/library/common/ad_iqcor.v" \
  "$ad_hdl_dir/library/xilinx/common/ad_mul.v" \
  "$ad_hdl_dir/library/axi_adc_decimate/fir_decim.v" \
  "$ad_hdl_dir/library/axi_adc_decimate/cic_decim.v" \
  "$ad_hdl_dir/library/axi_adc_decimate/axi_adc_decimate_filter.v" \
  "$script_dir/src/cic_filter.v" ]

adi_ip_properties_lite cic_filter

adi_ip_add_core_dependencies { \
  analog.com:user:util_cic:1.0 \
}

set_property vendor redwiretechnology.com [ipx::current_core]
set_property library user [ipx::current_core]
set_property taxonomy /RWT [ipx::current_core]
set_property vendor_display_name {RWT} [ipx::current_core]
set_property company_url {http://www.redwiretechnology.com} [ipx::current_core]

ipx::infer_bus_interface adc_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface adc_rst xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]

ipx::save_core [ipx::current_core]
