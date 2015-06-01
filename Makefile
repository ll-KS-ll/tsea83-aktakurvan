# Makefile for hardware implementation on Xilinx FPGAs and ASICs
# Author: Andreas Ehliar <ehliar@isy.liu.se>
# 
# T is the testbench file for this project
# S is the synthesizable sources for this project
# U is the UCF file
# PART is the part

# Important makefile targets:
# make aktakurvan.sim		GUI simulation
# make aktakurvan.simc		batch simulation
# make aktakurvan.synth		Synthesize
# make aktakurvan.route		Route the design
# make aktakurvan.bitgen	Generate bit file
# make aktakurvan.timing	Generate timing report
# make aktakurvan.clean		Use whenever you change settings in the Makefile!
# make aktakurvan.prog		Downloads the bitfile to the FPGA. NOTE: Does not
#                       		rebuild bitfile if source files have changed!
# make clean        		Removes all generated files for all projects. Also
#                       		backup files (*~) are removed.

# VIKTIG NOTERING:
#	Om du ändrar vilka filer som finns med i projektet så måste du köra make aktakurvan.clean

# Syntesrapporten ligger i lab-synthdir/xst/synth/design.syr
# Maprapporten (bra att kolla i för arearapportens skull) ligger i lab-synthdir/layoutdefault/design_map.mrp
# Timingrapporten (skapas av make aktakurvan.timing) ligger i lab-synthdir/layoutdefault/design.trw

XILINX_INIT = source /sw/xilinx/ise_14.2i/ISE_DS/settings64.sh;
#XILINX_INIT = source /opt/xilinx/14.7/ISE_DS/settings64.sh;
PART=xc6slx16-3-csg324

aktakurvan.%: S=master.vhd ram.vhd gpu.vhd alu.vhd controller.vhd greg.vhd areg.vhd mux.vhd cpu.vhd gpu_display_numbers.vhd uart.vhd gpu_text.vhd
aktakurvan.%: T=tb.vhd
aktakurvan.%: U=aktakurvan.ucf

# Misc functions that are good to have
include build/util.mk
# Setup simulation environment
include build/vsim.mk
# Setup synthesis environment
include build/xst.mk
# Setup backend flow environment
include build/xilinx-par.mk
# Setup tools for programming the FPGA
include build/digilentprog.mk

# Alternative synthesis methods
# The following is for ASIC synthesis
#include design_compiler.mk
# The following is for synthesis to a Xilinx target using Precision.
#include precision-xilinx.mk
