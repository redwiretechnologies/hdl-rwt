export ADI_SRC_TREE := $(abspath ../../../hdl)
export ADI_LIB_DIR := $(ADI_SRC_TREE)/library

M_VIVADO := vivado -mode batch -source

M_DEPS := \
  $(ADI_LIB_DIR)/scripts/adi_env.tcl \
  $(ADI_LIB_DIR)/scripts/adi_ip_xilinx.tcl \

.PHONY: all clean clean-all
all: build/$(LIB_NAME).xpr

clean:clean-all

clean-all:
	rm -rf build

build/$(LIB_NAME).xpr: $(M_DEPS)
	-rm -rf build
	mkdir -p build
	cd build && $(M_VIVADO) ../$(LIB_NAME)_ip.tcl -tclargs $(ADI_LIB_DIR) >> build.log 2>&1

