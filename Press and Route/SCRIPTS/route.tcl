push_snapshot_stack 

setNanoRouteMode -quiet -drouteFixAntenna 1
setNanoRouteMode -quiet -routeInsertAntennaDiode 1
setNanoRouteMode -quiet -routeAntennaCellName F_DIODEHD2
setNanoRouteMode -quiet -routeWithTimingDriven 1
setNanoRouteMode -quiet -routeWithEco 0
setNanoRouteMode -quiet -routeWithLithoDriven 0
setNanoRouteMode -quiet -droutePostRouteLithoRepair 1
setNanoRouteMode -quiet -routeWithSiDriven 1
setNanoRouteMode -quiet -drouteAutoStop 0
setNanoRouteMode -quiet -routeSelectedNetOnly 0

setNanoRouteMode -quiet -routeTopRoutingLayer 6
setNanoRouteMode -quiet -routeBottomRoutingLayer 1
#WARNING (NRIF-91) Option setNanoRouteMode -route_top_routing_layer is obsolete. It will continue to work for the current release. To ensure compatibility with future releases, use option setDesignMode -topRoutingLayer instead.
# setNanoRouteMode -quiet -drouteEndIteration 1
setNanoRouteMode -quiet -routeWithTimingDriven true
setNanoRouteMode -quiet -routeWithSiDriven true


route_opt_design

# setExtractRCMode -engine postRoute 
# setExtractRCMode -effortLevel medium 
# timeDesign -postRoute 

# timeDesign -postRoute -hold
timeDesign -postRoute -setup -expandReg2Reg -pathReports -drvReports -slackReports -numPaths 50 -prefix ${TOP_DESIGN_NAME}_postRoute -outDir reports
timeDesign -postRoute -hold -expandReg2Reg -pathReports -slackReports -numPaths 50 -prefix ${TOP_DESIGN_NAME}_postRoute -outDir reports

pop_snapshot_stack 
create_snapshot -name post_ROUTE
saveDesign DBS/postroute.enc 
report_qor -file metrics.html -format html