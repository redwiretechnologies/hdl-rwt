export ADI_SRC_TREE := $(abspath ../../../../../hdl)

export ADI_PROJ_DIR := $(ADI_SRC_TREE)/projects
export ADI_LIB_DIR := $(ADI_SRC_TREE)/library
export ADI_USE_OOC_SYNTHESIS := n

M_VIVADO := vivado -mode batch -source

M_DEPS += $(ADI_PROJ_DIR)/scripts/adi_project_xilinx.tcl
M_DEPS += $(ADI_PROJ_DIR)/scripts/adi_env.tcl
M_DEPS += $(ADI_PROJ_DIR)/scripts/adi_board.tcl
M_DEPS += $(ADI_LIB_DIR)/common/ad_iobuf.v
M_DEPS += $(ADI_LIB_DIR)/axi_ad9361/axi_ad9361_delay.tcl

M_DEPS += $(foreach lib,$(M_ADI_LIBS),$(subst ^^,$(lastword $(subst /, ,$(lib))),$(subst %%,$(lib), $(ADI_LIB_DIR)/%%/^^.xpr)))
M_DEPS += $(foreach lib,$(M_CUSTOM_LIBS),$(subst ^^,$(lastword $(subst /, ,$(lib))),$(subst %%,$(lib), ../../../../library/%%/build/^^.xpr)))

define BOARD_template =

.PHONY: $(1)-$(2) proj-$(1)-$(2) clean-$(1)-$(2)

$(1)-$(2): build/$(1)/$(2)/$(PROJECT_NAME).sdk/system_top.xsa

build/$(1)/$(2)/$(PROJECT_NAME).sdk/system_top.xsa: $(M_DEPS)
	-rm -rf build/$(1)/$(2)
	mkdir -p build/$(1)/$(2)
	cd build/$(1)/$(2) && $(M_VIVADO) ../../../system_project.tcl -tclargs $(ADI_PROJ_DIR) $(1) $(2)\
		>> build.log 2>&1

proj-$(1)-$(2): build/$(1)/$(2)/$(PROJECT_NAME).xpr

build/$(1)/$(2)/$(PROJECT_NAME).xpr: $(M_DEPS)
	-rm -rf build/$(1)/$(2)
	mkdir -p build/$(1)/$(2)
	cd build/$(1)/$(2) && $(M_VIVADO) ../../../system_project.tcl -tclargs $(ADI_PROJ_DIR) $(1) $(2) --project-only

clean-$(1)-$(2):
	-rm -rf build/$(1)/$(2)

clean: clean-$(1)-$(2)
endef


define LIB_template =

.PHONY: clean-lib-$(1) lib-$(1)

lib-$(1): $(2)/$(1)/$(4)$(lastword $(subst /, ,$(1))).xpr

$(2)/$(1)/$(4)$(lastword $(subst /, ,$(1))).xpr: $(2)/$(1)/Makefile $(2)/$(1)/*.tcl $(wildcard $(2)/$(1)/src/*.v) $(wildcard $(2)/$(1)/*.v)
	make -C $(2)/$(1)

clean-lib-$(1):
	make -C $(2)/$(1) clean


clean$(3)-libs: clean-lib-$(1)
clean-all-libs: clean-lib-$(1)
lib: lib-$(1)
endef

.PHONY: standard all lib clean clean-all-libs clean-adi-libs clean-libs help

clean-all:clean clean-all-libs
clean:
clean-all-libs:
clean-adi-libs:
clean-libs:
lib:


help:
	@echo "Example Usage:"
	@echo ""
	@echo "  Make Everything:"
	@echo "     make all"
	@echo "  Make Specific board with revision"
	@echo "    > make 2cg-1.0"
	@echo "  Make Project for board with revision only"
	@echo "    > make proj-2cg-1.0"
	@echo "  Clean Specific board with revision"
	@echo "    > make clean-2cg-1.0"
	@echo "  Clean Board files (not libs)"
	@echo "    > make clean"
	@echo "  Clean Custom libraries"
	@echo "    > make clean-libs"
	@echo "  Clean ADI libraries"
	@echo "    > make clean-adi-libs"
	@echo "  Clean Everything libs and boards"
	@echo "    > make clean-all"

$(foreach rev,$(ALL_REVS),$(foreach board,$(ALL_BOARDS),$(eval $(call BOARD_template,$(board),$(rev)))))
$(foreach lib,$(M_ADI_LIBS),$(eval $(call LIB_template,$(lib),$(ADI_LIB_DIR),-adi,)))
$(foreach lib,$(M_CUSTOM_LIBS),$(eval $(call LIB_template,$(lib),../../../../library,,build/)))
