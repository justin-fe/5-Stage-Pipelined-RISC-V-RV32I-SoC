# Makefile for running Cocotb with GHDL

# Simulator settings
SIM ?= ghdl
TOPLEVEL_LANG ?= vhdl

# Source files (pointing to the rtl folder)
VHDL_SOURCES = \
	../rtl/forwarding_unit.vhd \
	../rtl/hazard_detection_unit.vhd \
	../rtl/alu.vhd \
	../rtl/register_file.vhd \
	../rtl/control_unit.vhd \
	../rtl/imm_gen.vhd \
	../rtl/pipeline_regs.vhd \
	../rtl/mem_wb_reg.vhd \
	../rtl/riscv_core.vhd \
	../rtl/instruction_memory.vhd \
	../rtl/data_memory.vhd \
	../rtl/riscv_soc.vhd

# Top-level entity name in VHDL
TOPLEVEL = riscv_soc

# Python test module name
MODULE = test_riscv_soc

# Include cocotb's Makefile rules
include $(shell cocotb-config --makefiles)/Makefile.sim

# Enable waveform generation for GHDL
SIM_ARGS ?= --wave=riscv_soc.ghw
