#add power stripes
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
set sprCreateIeRingOffset 1.0
set sprCreateIeRingThreshold 1.0
set sprCreateIeRingJogDistance 1.0
set sprCreateIeRingLayers {}
set sprCreateIeStripeWidth 10.0
set sprCreateIeStripeThreshold 1.0
setAddStripeMode -ignore_block_check false -break_at none -route_over_rows_only false -rows_without_stripes_only false -extend_to_closest_target none -stop_at_last_wire_for_area false -partial_set_thru_domain false -ignore_nondefault_domains false -trim_antenna_back_to_shape none -spacing_type edge_to_edge -spacing_from_block 0 -stripe_min_length stripe_width -stacked_via_top_layer METAL7 -stacked_via_bottom_layer METAL1 -via_using_exact_crossover_size false -split_vias false -orthogonal_only true -allow_jog { padcore_ring  block_ring } -skip_via_on_pin {  standardcell } -skip_via_on_wire_shape {  noshape   }
addStripe -nets {VDD VSS} -layer METAL6 -direction vertical -width 1.8 -spacing 1.8 -set_to_set_distance 100 -start_from left -switch_layer_over_obs false -max_same_layer_jog_length 2 -padcore_ring_top_layer_limit METAL7 -padcore_ring_bottom_layer_limit METAL1 -block_ring_top_layer_limit METAL7 -block_ring_bottom_layer_limit METAL1 -use_wire_group 0 -snap_wire_center_to_grid None

#add power rails
globalNetConnect VDD -type pgpin -pin VDD -inst *
globalNetConnect VSS -type pgpin -pin VSS -inst *
setSrouteMode -viaConnectToShape { followpin }
sroute -connect { corePin } -layerChangeRange { METAL1(1) METAL7(7) } -blockPinTarget { nearestTarget } -corePinTarget { firstAfterRowEnd } -allowJogging 1 -crossoverViaLayerRange { METAL1(1) METAL7(7) } -nets { VDD VSS } -allowLayerChange 1 -targetViaLayerRange { METAL1(1) METAL7(7) }

