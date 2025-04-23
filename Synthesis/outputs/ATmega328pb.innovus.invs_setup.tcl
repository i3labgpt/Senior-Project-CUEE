################################################################################
#
# Innovus setup file
# Created by Genus(TM) Synthesis Solution 22.10-p001_1
#   on 04/17/2025 15:22:30
#
################################################################################
#
# Genus(TM) Synthesis Solution setup file
# This file can only be run in Innovus Common UI mode.
#
################################################################################


# Version Check
###########################################################

      namespace eval ::genus_innovus_version_check { 
        set minimum_version 22
        set maximum_version 23
        regexp {\d\d} [get_db program_version] this_version
        puts "Checking Innovus major version against Genus expectations ..."
        if { $this_version < $minimum_version || $this_version > $maximum_version } {
          error "**ERROR: this operation requires Innovus major version to be between '$minimum_version' and '$maximum_version'."
        }
      }
    
set _t0 [clock seconds]
puts [format  {%%%s Begin Genus to Innovus Setup (%s)} \# [clock format $_t0 -format {%m/%d %H:%M:%S}]]
set_db read_physical_allow_multiple_port_pin_without_must_join true
set_db must_join_all_ports true
set_db timing_cap_unit 1pf
set_db timing_time_unit 1ns


# Design Import
################################################################################
source -quiet /home/cadence/DDI22.10.000/GENUS221/tools.lnx86/lib/cdn/rc/edi/innovus_procs_common_ui.tcl
## Reading FlowKit settings file
source outputs/ATmega328pb.innovus.flowkit_settings.tcl

source outputs/ATmega328pb.innovus.invs_init.tcl
update_analysis_view -name view_ss_v1p08_125c -constraint_mode functional_ss_v1p08_125c -latency_file outputs/ATmega328pb.innovus.view_ss_v1p08_125c_latency.sdc
update_analysis_view -name view_ff_v1p32 -constraint_mode functional_ff_v1p32 -latency_file outputs/ATmega328pb.innovus.view_ff_v1p32_latency.sdc
update_analysis_view -name view_tt_v1p5_25c -constraint_mode functional_tt_v1p5_25c -latency_file outputs/ATmega328pb.innovus.view_tt_v1p5_25c_latency.sdc

# Reading metrics file
################################################################################
read_metric -id current outputs/ATmega328pb.innovus.metrics.json

## Reading common preserve file for dont_touch and dont_use preserve settings
source -quiet outputs/ATmega328pb.innovus.preserve.tcl

## Reading Innovus Mode attributes file
pqos_eval {rcp::read_taf outputs/ATmega328pb.innovus.mode_attributes.taf.gz}


# Mode Setup
################################################################################
source outputs/ATmega328pb.innovus.mode


# MSV Setup
################################################################################

# Reading write_name_mapping file
################################################################################

      if { [is_attribute -obj_type port original_name] &&
           [is_attribute -obj_type pin original_name] &&
           [is_attribute -obj_type pin is_phase_inverted]} {
        source outputs/ATmega328pb.innovus.wnm_attrs.tcl
      }
    

# Reading NDR file
source outputs/ATmega328pb.innovus.ndr.tcl

# Reading Instance Attributes file
pqos_eval { rcp::read_taf outputs/ATmega328pb.innovus.inst_attributes.taf.gz}

# Reading minimum routing layer data file
################################################################################
pqos_eval {rcp::load_min_layer_file outputs/ATmega328pb.innovus.min_layer {} {}}
eval_legacy {set edi_pe::pegConsiderMacroLayersUnblocked 1}
eval_legacy {set edi_pe::pegPreRouteWireWidthBasedDensityCalModel 1}

      set _t1 [clock seconds]
      puts [format  {%%%s End Genus to Innovus Setup (%s, real=%s)} \# [clock format $_t1 -format {%m/%d %H:%M:%S}] [clock format [expr {28800 + $_t1 - $_t0}] -format {%H:%M:%S}]]
    
