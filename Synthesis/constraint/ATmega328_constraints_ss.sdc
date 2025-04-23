#########################################################################
# Cadence genus synthesis design constraints
# AUTHOR : Rapin.P
# DATE : 15/11/20204
# #########################################################################


current_design ATmega328pb

set TOP_DESIGN_NAME     "ATmega328pb"
set TARGET_LIBRARY      "scc013ull_hd_rvt_ss_v1p08_125c_basic.lib"
set_dont_use            [get_lib_cells SD*]
set_dont_use            [get_lib_cells SE*]
set_dont_use            [get_lib_cells SN*]
# ----------------------------------------------------------------------------
# 1. Create Clock
# ----------------------------------------------------------------------------

# ~ MHz
create_clock -name CLK -period 50 [get_ports "clk"]

# TWI gen clock
create_clock -name scl_i -period 10000 


# SPI gen clock

# create_clock -name sck_i -period 20 [get_pins SPI_0_inst/sck_i]
# create_generated_clock -name sck_o -source [get_ports clk] -divide_by 2 [get_pins SPI_0_inst/sck_o]

# For cp2
# create_generated_clock -name cp2_clk -source [get_ports clk] -master_clock CLK [get_nets cp2]

# For gated clocks - identify actual gated clock nets
# create_generated_clock -name clk_t2 -source [get_ports clk] [get_nets clk_t2]


set_clock_uncertainty -setup 1.00                           [get_clocks]
set_clock_uncertainty -hold  0.25                           [get_clocks]

set_clock_latency    1 -max -source -early  [get_clocks]
set_clock_latency    1.25 -max -source -late   [get_clocks]
set_clock_latency    1 -max                              [get_clocks]
set_clock_transition 0.50 -max                              [get_clocks]

set_clock_latency    0.50 -min -source -early [get_clocks]
set_clock_latency    0.75 -min -source -late  [get_clocks]
set_clock_latency    1.00 -min                              [get_clocks]
set_clock_transition 0.30 -min                              [get_clocks]

# create_clock -name wdt_clk -period 50 [ get_ports wdt_clk ]

# ----------------------------------------------------------------------------
# 1.2 Create Clock for Latches
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# 1.1 Identyfy Clock gating
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# 1.1 Check Clock gating
# ----------------------------------------------------------------------------

# ----------------------------------------------------------------------------
# 2. Clock Groups and CDC
# ----------------------------------------------------------------------------

# Asynchronous clock domains
# set_clock_groups -asynchronous \
#     -group {cp2} \
#     -group {scl_i scl_o}
# set_clock_groups -asynchronous -group {cp2} -group {sck_i}
# set_clock_groups -asynchronous -group {CLK cp2_clk} -group {clk_t2}
# ------------------------------------------------------------------------------
# 3. Ideal Network for clock
# ------------------------------------------------------------------------------
# set_ideal_network [get_nets clk]
set_ideal_network -no_propagate [get_nets clk]
#set_ideal_network -no_propagate [get_nets PLS_m/SPI_m/O_CLK]
#set_ideal_network -no_propagate [get_pins "AES_Controlpath/BUF_*_CG/GC AES_Controlpath/DATA_*_CG/GC AES_Controlpath/KEY_*_CG/GC AES_Controlpath/CLK_Control_CG/GC"]

# Add this to your constraints to fix clock propagation
# set_propagated_clock [get_clocks CLK]
# set_propagated_clock [get_clocks cp2_clk]

# ------------------------------------------------------------------------------
# 4. False Path and Multicycle if you have ?
# ------------------------------------------------------------------------------

# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[0]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[1]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[2]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[3]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[4]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[5]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[6]]
# set_false_path -through [get_cells Port_B_inst_IO_Port_B_inst_synchronizer_pinx_inst_b_latch_reg[7]]

# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[0]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[1]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[2]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[3]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[4]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[5]]
# set_false_path -through [get_cells Port_C_inst_IO_Port_C_inst_synchronizer_pinx_inst_c_latch_reg[6]]

# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[0]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[1]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[2]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[3]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[4]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[5]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst_d_latch_reg[6]]
# set_false_path -through [get_cells Port_D_inst_IO_Port_D_inst_synchronizer_pinx_inst/d_latch_reg[7]]

# set_false_path -through [get_cells Port_E_inst_IO_Port_E_inst_synchronizer_pinx_inst_e_latch_reg[0]]
# set_false_path -through [get_cells Port_E_inst_IO_Port_E_inst_synchronizer_pinx_inst_e_latch_reg[1]]
# set_false_path -through [get_cells Port_E_inst_IO_Port_E_inst_synchronizer_pinx_inst_e_latch_reg[2]]
# set_false_path -through [get_cells Port_E_inst_IO_Port_E_inst_synchronizer_pinx_inst_e_latch_reg[3]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[0]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[1]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[2]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[3]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[4]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[5]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[6]]
# set_false_path -through [get_cells IO_Port_B_inst/synchronizer_pinx_inst/d_latch_reg[7]]

# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[0]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[1]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[2]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[3]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[4]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[5]]
# set_false_path -through [get_cells IO_Port_C_inst/synchronizer_pinx_inst/d_latch_reg[6]]

# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[0]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[1]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[2]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[3]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[4]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[5]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[6]]
# set_false_path -through [get_cells IO_Port_D_inst/synchronizer_pinx_inst/d_latch_reg[7]]

# set_false_path -through [get_cells IO_Port_E_inst/synchronizer_pinx_inst/d_latch_reg[0]]
# set_false_path -through [get_cells IO_Port_E_inst/synchronizer_pinx_inst/d_latch_reg[1]]
# set_false_path -through [get_cells IO_Port_E_inst/synchronizer_pinx_inst/d_latch_reg[2]]
# set_false_path -through [get_cells IO_Port_E_inst/synchronizer_pinx_inst/d_latch_reg[3]]

# Add to your constraints file
# set_multicycle_path 2 -setup -from [get_pins */avr_core/pm_fetch_dec*/pc_reg*/Q] -to [get_pins */avr_core/alu_avr*/*/D]
# set_multicycle_path 2 -setup -from [get_pins */avr_mul/*/Q] -to [get_pins */avr_mul/*/D]

# ------------------------------------------------------------------------------
# 4. Input/Output Contraints
# ------------------------------------------------------------------------------

set_input_delay 2 -clock CLK           [all_inputs]
# set_max_delay 25 -from [all_inputs] -to [all_registers]
set_output_delay 2 -clock CLK          [all_outputs]


# Clock signals
remove_input_delay                        [get_ports "clk"]
# Reset signals
remove_input_delay                        [get_ports "ireset"]
# ------------------------------------------------------------------------------
# 5. Driving Cell/Output Load Contraints
# ------------------------------------------------------------------------------

set_driving_cell -lib_cell BUFHDV8RD  [all_inputs]
remove_driving_cell [get_ports "clk"]
set_driving_cell -lib_cell CLKBUFHDV32  [get_ports "clk"]
#set_driving_cell -lib_cell BUFX12 [get_ports "ABE_CPR_RFCLK APM_CPR_PORSYS"]
set_multicycle_path 2 -setup -from [get_pins CPU_core/pm_fetch_dec_inst/pc_reg*/Q] -to [get_pins CPU_core/alu_core/*/D]

#set_load -max [DQHDV0] [all_outputs]
#set_load -min [DQHDV0] [all_outputs]

set_load -max 0.0022433 [all_outputs]
set_load -min 0.0022335 [all_outputs]

#set_load -max -lib_cell DFFX4 [all_outputs]
#set_load -min -lib_cell DFFX4 [all_outputs]


# ------------------------------------------------------------------------------
# 6. Exclusion list for clock gating
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# 7. Interclock Relation
# ------------------------------------------------------------------------------
# report_interclock_relation > outputs/${TOP_DESIGN_NAME}.report_interclock_relation.before.rpt
# set_clock_groups -asynchronous -group PCLK -group QSCLK -allow_path

#set_clock_groups -asynchronous         -group CLK_PA0

# report_interclock_relation > outputs/${TOP_DESIGN_NAME}.report_interclock_relation.after.rpt

# report_clocks > outputs/${TOP_DESIGN_NAME}.report_clock_ff.rpt
# report_clock_tree > outputs/${TOP_DESIGN_NAME}.report_clock_tree_ff.rpt
# report_clock_tree -summary > outputs/${TOP_DESIGN_NAME}.report_clock_tree.summary_ff.rpt
# report_interclock_relation > outputs/${TOP_DESIGN_NAME}.report_interclock_relation.rpt