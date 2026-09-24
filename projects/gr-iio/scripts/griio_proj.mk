# SPDX-License-Identifier: Apache-2.0

M_CUSTOM_LIBS += concat_9002
M_CUSTOM_LIBS += breakout_9002
M_CUSTOM_LIBS += data_order

M_DEPS += ../../scripts/griio_bd.tcl

include ../../../common/scripts/common_deps.mk
include ../../../common/scripts/axi_adrv9002.mk
include ../../../common/scripts/project.mk
