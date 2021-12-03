export ADI_SRC_TREE := $(abspath ../../../hdl-adi)
export ADI_LIB_DIR := $(ADI_SRC_TREE)/library

M_DEPS = \
  $(ADI_LIB_DIR)/scripts/adi_env.tcl \
  $(ADI_LIB_DIR)/scripts/adi_ip_xilinx.tcl \
  src/cic_filter.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/fir_decim.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/axi_adc_decimate_filter.v \
  $(ADI_LIB_DIR)/axi_adc_decimate/cic_decim.v \
  cic_filter_ip.tcl \
  $(ADI_LIB_DIR)/common/ad_iqcor.v \
  $(ADI_LIB_DIR)/util_cic/cic_comb.v \
  $(ADI_LIB_DIR)/util_cic/cic_int.v \

M_VIVADO := vivado -mode batch -source

.PHONY: all clean clean-all
all: build/cic_filter.xpr

clean:clean-all

clean-all:
	rm -rf build

build/cic_filter.xpr: $(M_DEPS)
	-rm -rf build
	mkdir -p build
	cd build && $(M_VIVADO) ../cic_filter_ip.tcl -tclargs $(ADI_LIB_DIR) >> build.log 2>&1
