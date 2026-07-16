TOPLEVEL_LANG = verilog
VERILOG_SOURCES = $(wildcard $(PWD)/../../rtl/*.sv)
TOPLEVEL = top_wrapper
MODULE = top_wrapper_tb
SIM = icarus
COMPILE_ARGS = -g2012 -v -Wall
WAVES = 1

include $(shell cocotb-config --makefiles)/Makefile.sim
