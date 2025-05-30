TOP := axis_uart_top

RTL_DIR     := rtl
TB_DIR      := tb
PROJECT_DIR := project

SIM   ?= verilator
BOARD ?= tangprimer20k

MACRO_FILE := wave.do
TCL        := project.tcl

SRC_FILES += $(RTL_DIR)/axis_uart_top.sv
SRC_FILES += $(RTL_DIR)/axis_if.sv
SRC_FILES += $(RTL_DIR)/axis_uart_rx.sv
SRC_FILES += $(RTL_DIR)/axis_uart_tx.sv

SRC_FILES += $(TB_DIR)/axis_uart_top_tb.sv

.PHONY: sim project wave program clean

sim: build run

build:
ifeq ($(SIM), verilator)
	$(SIM) --binary $(SRC_FILES) --trace -I$(RTL_DIR) -I$(TB_DIR) --top $(TOP)_tb
else ifeq ($(SIM), questa)
	vsim -do $(TB_DIR)/$(MACRO_FILE)
endif

run:
ifeq ($(SIM), verilator)
	./obj_dir/V$(TOP)_tb
endif

wave:
	gtkwave $(TOP)_tb.vcd

project: 
ifeq ($(BOARD), tangprimer20k)
	gw_sh $(PROJECT_DIR)/$(BOARD)/$(TCL)
else ifeq ($(BOARD), pz7020starlite)
	vivado -mode tcl -source $(PROJECT_DIR)/$(BOARD)/$(TCL)
endif

program:
	openFPGALoader -b $(BOARD) -m $(PROJECT_DIR)/$(TOP)/impl/pnr/$(TOP).fs

clean:
	rm -rf $(PROJECT_DIR)/$(TOP)
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).cache
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).hw
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).runs
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).sim
	rm -rf $(PROJECT_DIR)/pz7020starlite/$(TOP).ip_user_files
	rm -rf $(PROJECT_DIR)/pz7020starlite/.Xil
	rm $(PROJECT_DIR)/pz7020starlite/$(TOP).xpr
	rm -rf obj_dir
	rm -rf work
	rm transcript
	rm *.vcd
	rm *.wlf
	rm *.log
	rm *.jou
