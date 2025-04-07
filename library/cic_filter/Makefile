# SPDX-License-Identifier: Apache-2.0

LIB_NAME = cic_filter
M_DEPS += \
  src/cic_filter.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/fir_decim.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/axi_adc_decimate_filter.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/cic_decim.v \
  cic_filter_ip.tcl \
  $(ADI_LIB_DIR)/common/ad_iqcor.v \
  $(ADI_LIB_DIR)/util_cic/cic_comb.v \
  $(ADI_LIB_DIR)/util_cic/cic_int.v \

include ../scripts/library.mk
