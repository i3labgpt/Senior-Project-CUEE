#################################################################################
#
# Created by Genus(TM) Synthesis Solution 22.10-p001_1 on Thu Apr 17 15:22:29 +07 2025
#
#################################################################################

## library_sets
create_library_set -name scc013ull_hd_rvt_ss_v1p08_125c_basic \
    -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_ss_v1p08_125c_basic.lib }
create_library_set -name scc013ull_hd_rvt_ff_v1p32_-40c_basic \
    -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_ff_v1p32_-40c_basic.lib }
create_library_set -name scc013ull_hd_rvt_tt_v1p5_25c_basic \
    -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_tt_v1p5_25c_basic.lib }

## opcond
create_opcond -name ss_v1p08_125c \
    -process 1.0 \
    -voltage 1.08 \
    -temperature 125.0
create_opcond -name ff_v1p32 \
    -process 1.0 \
    -voltage 1.32 \
    -temperature -40.0
create_opcond -name tt_v1p5_25c \
    -process 1.0 \
    -voltage 1.5 \
    -temperature 25.0

## timing_condition
create_timing_condition -name timing_cond_ss_v1p08_125c \
    -library_sets { scc013ull_hd_rvt_ss_v1p08_125c_basic }
create_timing_condition -name timing_cond_ff_v1p32 \
    -library_sets { scc013ull_hd_rvt_ff_v1p32_-40c_basic }
create_timing_condition -name timing_cond_tt_v1p5_25c \
    -library_sets { scc013ull_hd_rvt_tt_v1p5_25c_basic }

## rc_corner
create_rc_corner -name rc_corner \
    -qrc_tech /nfs/mcu8b/jirath/01lib/scc013u_hd_7lm_1tm_thin.tf \
    -pre_route_res 1.0 \
    -pre_route_cap 1.0 \
    -pre_route_clock_res 0.0 \
    -pre_route_clock_cap 0.0 \
    -post_route_res {1.0 1.0 1.0} \
    -post_route_cap {1.0 1.0 1.0} \
    -post_route_cross_cap {1.0 1.0 1.0} \
    -post_route_clock_res {1.0 1.0 1.0} \
    -post_route_clock_cap {1.0 1.0 1.0}

## delay_corner
create_delay_corner -name delay_corner_ss_v1p08_125c \
    -early_timing_condition { timing_cond_ss_v1p08_125c } \
    -late_timing_condition { timing_cond_ss_v1p08_125c } \
    -early_rc_corner rc_corner \
    -late_rc_corner rc_corner
create_delay_corner -name delay_corner_ff_v1p32 \
    -early_timing_condition { timing_cond_ff_v1p32 } \
    -late_timing_condition { timing_cond_ff_v1p32 } \
    -early_rc_corner rc_corner \
    -late_rc_corner rc_corner
create_delay_corner -name delay_corner_tt_v1p5_25c \
    -early_timing_condition { timing_cond_tt_v1p5_25c } \
    -late_timing_condition { timing_cond_tt_v1p5_25c } \
    -early_rc_corner rc_corner \
    -late_rc_corner rc_corner

## constraint_mode
create_constraint_mode -name functional_ss_v1p08_125c \
    -sdc_files { outputs/ATmega328pb.innovus.functional_ss_v1p08_125c.sdc }
create_constraint_mode -name functional_ff_v1p32 \
    -sdc_files { outputs/ATmega328pb.innovus.functional_ff_v1p32.sdc }
create_constraint_mode -name functional_tt_v1p5_25c \
    -sdc_files { outputs/ATmega328pb.innovus.functional_tt_v1p5_25c.sdc }

## analysis_view
create_analysis_view -name view_ss_v1p08_125c \
    -constraint_mode functional_ss_v1p08_125c \
    -delay_corner delay_corner_ss_v1p08_125c
create_analysis_view -name view_ff_v1p32 \
    -constraint_mode functional_ff_v1p32 \
    -delay_corner delay_corner_ff_v1p32
create_analysis_view -name view_tt_v1p5_25c \
    -constraint_mode functional_tt_v1p5_25c \
    -delay_corner delay_corner_tt_v1p5_25c

## set_analysis_view
set_analysis_view -setup { view_ss_v1p08_125c view_ff_v1p32 view_tt_v1p5_25c } \
                  -hold { view_ss_v1p08_125c view_ff_v1p32 view_tt_v1p5_25c }
