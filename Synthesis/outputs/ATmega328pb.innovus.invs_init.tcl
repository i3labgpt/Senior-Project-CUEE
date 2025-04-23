################################################################################
#
# Init setup file
# Created by Genus(TM) Synthesis Solution on 04/17/2025 15:22:30
#
################################################################################
if { ![is_common_ui_mode] } { error "ERROR: This script requires common_ui to be active."}

read_mmmc outputs/ATmega328pb.innovus.mmmc.tcl

read_netlist outputs/ATmega328pb.innovus.v

init_design
