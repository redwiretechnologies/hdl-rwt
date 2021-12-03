M_DEPS = $(ADI_LIB_DIR)/scripts/adi_env.tcl
M_DEPS += $(ADI_LIB_DIR)/scripts/adi_ip_xilinx.tcl
M_DEPS += concat_9361.v
M_DEPS += concat_9361_constr.xdc
M_DEPS += concat_9361_ip.tcl

M_VIVADO := vivado -mode batch -source

.PHONY: all clean clean-all
all: build/concat_9361.xpr

clean:clean-all

clean-all:
	rm -rf build

build/concat_9361.xpr: $(M_DEPS)
	-rm -rf build
	mkdir -p build
	cd build && $(M_VIVADO) ../concat_9361_ip.tcl -tclargs $(ADI_LIB_DIR) >> build.log 2>&1
