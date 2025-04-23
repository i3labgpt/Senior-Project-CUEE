create_route_type -name clkroute  -bottom_preferred_layer METAL3 -top_preferred_layer METAL6
# Exclude specific instance by path
set_ccopt_property route_type clkroute -net_type trunk
set_ccopt_property route_type clkroute -net_type leaf 
set_ccopt_property buffer_cells {CLKBUFHDV2  CLKBUFHDV3  CLKBUFHDV4  CLKBUFHDV6 CLKBUFHDV8 CLKBUFHDV12 CLKBUFHDV16 CLKBUFHDV20 CLKBUFHDV24}
set_ccopt_property inverter_cells {CLKINHDV2  CLKINHDV3  CLKINHDV4  CLKINHDV6 CLKINHDV8 CLKINHDV12 CLKINHDV16 CLKINHDV20 CLKINHDV24}
set_ccopt_property clock_gating_cells CLKLAHAQHD*
create_ccopt_clock_tree_spec -file ccopt.spec
source ccopt.spec

set_db opt_enable_podv2_clock_opt_flow true
push_snapshot_stack
clock_opt_design -cts

saveDesign DBS/cts.enc

timeDesign -postCTS -setup -expandReg2Reg -pathReports -drvReports -slackReports -numPaths 50 -prefix ATmega328pb_postCTS -outDir reports
timeDesign -postCTS -hold -expandReg2Reg -pathReports -slackReports -numPaths 50 -prefix ATmega328pb_postCTS -outDir reports

optDesign -postCTS
optDesign -postCTS -hold

saveDesign outputs/${TOP_DESIGN_NAME}.postcts.enc

pop_snapshot_stack
create_snapshot -name post_CTS