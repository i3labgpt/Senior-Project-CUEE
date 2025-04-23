# ########################################################################
# Cadence genus synthesis script for ATMEGA328PB
# AUTHOR : Rapin.P
# DATE : 15/02/2025
# #########################################################################

set LIB_DIR     "/nfs/mcu8b/jirath/01lib/"
set mmmc_tcl    "mmmc.tcl"
set RTL_DIR     "/nfs/mcu8b/jirath/RTLtoGDSII/counter_design_database_45nm/ATMega328/"
set TOP_DESIGN_NAME     "ATmega328pb"

file mkdir   report
file mkdir   outputs

set_db  init_lib_search_path     ${LIB_DIR}
set_db  init_hdl_search_path     ${RTL_DIR}
read_mmmc ${mmmc_tcl}


read_hdl -language sv {
    
    ATmega328pb_synt_top.sv

    reg_file.sv
    io_reg_file2.sv
    io_adr_dec2.sv
    bit_processor.sv
    alu_avr.sv
    pm_fetch_dec4.sv
    avr_core2.sv
    avr_mul.sv
    Adder.sv
    CLA16B1x16S.sv
    CLA16B2x8S.sv
    CLA16B4x4S.sv
    StandAdder.sv
    CLA16B.sv
    mul8x8comb.sv

    rg_md.sv          
    synchronizer.sv      
    
    
    Ext_Int.v
    
    
    IO_Port.sv        
    Port_B.sv
    Port_C.sv
    Port_D.sv
    Port_E.sv
    
    
    Timer_Counter.v
    Timer_Counter0_8_bit.sv
    Timer_Counter2_8_bit.sv
    Timer_Counter_16_bit.sv
    prescaler_reset.v
    prescaler0.sv
    prescaler1.sv
    mux0.sv
    Watchdog_prescaler.sv
    Watchdog_Timer.sv
   
    mcu_cs.v
    mux_after_prescaler0.v
    
    TWIn.v
    
   
    SPI_0.sv
    SPI_1.sv

    NVM_wrapper.sv
    NVM_SPI.sv
    NVM_Normal.sv
    NVM_Mode.sv
    NVM_HVPP.sv
    EEPROMIF.sv
    
    
    FIFO.sv           
    USART_Clk.sv      
    USARTn.sv         
    
    uart_rx.sv
    uart_tx.sv
    OCD_pkg.sv
    debugWire_top.sv
    OCD.sv
    
}
    # CLA16B.sv
    # mul8x8comb.sv

elaborate ${TOP_DESIGN_NAME}
current_design ${TOP_DESIGN_NAME}
init_design -top ${TOP_DESIGN_NAME}



syn_generic
syn_map
syn_opt

# Outputs
write_netlist > outputs/${TOP_DESIGN_NAME}_netlist.v
write_netlist -depth 999 > outputs/${TOP_DESIGN_NAME}_hier_netlist.v
write_sdc -view view_ff_v1p32 > outputs/${TOP_DESIGN_NAME}_ff_sdc.sdc
write_sdc -view view_ss_v1p08_125c > outputs/${TOP_DESIGN_NAME}_ss_sdc.sdc
# write_sdc -view tt_v1p5_25c > outputs/${TOP_DESIGN_NAME}_tt_sdc.sdc command to keep tt view
write_sdf -timescale ns -nonegchecks -recrem split -edges check_edge -setuphold split > outputs/${TOP_DESIGN_NAME}.sdf

# write_design -innovus -base outputs/${TOP_DESIGN_NAME}.innovus


# Reports
report_timing -max_paths 1000 -nworst 10 > report/${TOP_DESIGN_NAME}_report_timing.rpt
# report_timing -sort_by slack -max_paths 20000 -reverse > report/${TOP_DESIGN_NAME}_best_paths.rpt
# report_timing -slack_greater_than 0 -sort_by slack -max_paths 20000 -reverse > report/${TOP_DESIGN_NAME}_best_paths.rpt
# report_power -clock_network -view view_ss_v1p08_125c > report/${TOP_DESIGN_NAME}_clock_power2.rpt
# report_clock_power > report/${TOP_DESIGN_NAME}_clock_power.rpt
report_power                > report/${TOP_DESIGN_NAME}_report_power.rpt
report_area -depth 5 > report/${TOP_DESIGN_NAME}_report_area.rpt
report_qor > report/${TOP_DESIGN_NAME}_report_qor.rpt
report_design_rules > report/${TOP_DESIGN_NAME}_design_rules.rpt
report_gates                > report/${TOP_DESIGN_NAME}_gates.rpt
report_messages > report/${TOP_DESIGN_NAME}_messages.rpt
report_timing -unconstrained > report/${TOP_DESIGN_NAME}_report_timing_unconstrained.rpt
# report_summary -directory "report/${TOP_DESIGN_NAME}_summary.rpt"

# Additional reports
# report_clock_gating > report/${TOP_DESIGN_NAME}_clock_gating.rpt
# report_power -clock_network > report/${TOP_DESIGN_NAME}_clock_power.rpt

# report_constraint -all_violators > report/${TOP_DESIGN_NAME}_all_violations.rpt
# report_timing -max_paths 50 -slack_lesser_than 0 -sort_by slack > report/${TOP_DESIGN_NAME}_timing_violations.rpt

# Check Timing Intent
# check_timing_intent > report/${TOP_DESIGN_NAME}_check_timing_intent.rpt
# report_timing -lint > report/${TOP_DESIGN_NAME}_timing_lint.rpt
