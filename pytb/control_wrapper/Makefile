TOPLEVEL_LANG = verilog
VERILOG_SOURCES =$(PWD)/../../rtl/control_wrapper.sv\
				 $(PWD)/../../rtl/control_decoder.sv\
				 $(PWD)/../../rtl/alu_decoder.sv

TOPLEVEL = control_wrapper
MODULE = control_wrapper_tb
SIM = icarus
COMPILE_ARGS = -g2012
WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim
