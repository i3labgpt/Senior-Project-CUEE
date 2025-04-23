saveDesign routed.enc
saveNetlist -includePowerGround -excludeLeafCell  phy.pg.v     -excludeTopCellPGPort VSW
saveNetlist                                       phy.no_pg.v
verifyConnectivity 
verify_drc
write_power_intent phy.innovus.upf -1801
 
write_sdf -view view_ss_v1p08_125c ${TOP_DESIGN_NAME}_ss.sdf 
write_sdf -view view_ff_v1p32 ${TOP_DESIGN_NAME}_ff.sdf 
# write_sdf -view view_tt_v1p5_25c -output ${TOP_DESIGN_NAME}_tt.sdf