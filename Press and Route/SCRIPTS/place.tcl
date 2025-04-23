# global settings
setAnalysisMode -analysisType onChipVariation -cppr both
setDesignMode -topRoutingLayer METAL5 -bottomRoutingLayer METAL1 

# enable snapshot stack
enable_metrics -on
push_snapshot_stack
# place 
setPlaceMode -place_global_place_io_pins true
# setPlaceMode -congEffort auto -timingDriven 1 -clkGateAware 1 -powerDriven 0 -ignoreScan 1 -reorderScan 1 -ignoreSpare 0 -placeIOPins 1 -moduleAwareSpare 0 -preserveRouting 1 -rmAffectedRouting 0 -checkRoute 0 -swapEEQ 0

getPlaceMode >> reports/${TOP_DESIGN_NAME}.pre_cts_place_mode.rpt
getOptMode >> reports/${TOP_DESIGN_NAME}.pre_cts_opt_mode.rpt

place_opt_design
# check_design -type opt -verbose -all >> reports/${TOP_DESIGN_NAME}.check_design_prects.rpt
checkPlace reports/${TOP_DESIGN_NAME}.checkPlace
saveDesign outputs/${TOP_DESIGN_NAME}.prects.enc

# early global route
earlyGlobalRoute 

reportCongestion -hotspot -file reports/${TOP_DESIGN_NAME}.congestion.rpt

# RC extraction (add more corner later)
extractRC
rcOut -spef ${TOP_DESIGN_NAME}.spef -rc_corner rc_worst
extractRC
rcOut -spef ${TOP_DESIGN_NAME}.spef -rc_corner rc_best

timeDesign -preCTS -setup -expandReg2Reg -pathReports -drvReports -slackReports -numPaths 50 -prefix ATmega328pb_preCTS -outDir reports
# timeDesign -preCTS -hold -expandReg2Reg -pathReports -drvReports -slackReports -numPaths 50 -prefix ATmega328pb_preCTS -outDir reports

# reports

pop_snapshot_stack
create_snapshot -name pre_CTS

