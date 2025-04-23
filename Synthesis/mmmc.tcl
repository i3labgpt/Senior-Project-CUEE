create_library_set -name scc013ull_hd_rvt_ss_v1p08_125c_basic \
    -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_ss_v1p08_125c_basic.lib }
create_library_set -name scc013ull_hd_rvt_ff_v1p32_-40c_basic \
    -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_ff_v1p32_-40c_basic.lib }
# create_library_set -name scc013ull_hd_rvt_tt_v1p5_25c_basic \
#     -timing { /nfs/mcu8b/jirath/01lib//scc013ull_hd_rvt_tt_v1p5_25c_basic.lib }
create_timing_condition -name timing_cond_ss_v1p08_125c \
    -library_sets { scc013ull_hd_rvt_ss_v1p08_125c_basic }
create_timing_condition -name timing_cond_ff_v1p32 \
    -library_sets { scc013ull_hd_rvt_ff_v1p32_-40c_basic }
# create_timing_condition -name timing_cond_tt_v1p5_25c \
#     -library_sets { scc013ull_hd_rvt_tt_v1p5_25c_basic }
create_rc_corner -name rc_best\
   -preRoute_res 1.34236\
   -postRoute_res 1.34236\
   -preRoute_cap 1.10066\
   -postRoute_cap 0.960235\
   -postRoute_xcap 1.22327\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -postRoute_clkcap {0.969117 0 0}\
   -T 0
   # -qx_tech_file /nfs/mcu8b/jirath/01lib/scc013u_hd_7lm_1tm_thin.tf

create_rc_corner -name rc_worst\
   -preRoute_res 1.34236\
   -postRoute_res 1.34236\
   -preRoute_cap 1.10066\
   -postRoute_cap 0.960234\
   -postRoute_xcap 1.22327\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -postRoute_clkcap {0.969117 0 0}\
   -T 125
   # -qx_tech_file /nfs/mcu8b/jirath/01lib/scc013u_hd_7lm_1tm_thin.tf

create_delay_corner -name delay_corner_ss_v1p08_125c -rc_corner {rc_worst} -library_set {scc013ull_hd_rvt_ss_v1p08_125c_basic}
create_delay_corner -name delay_corner_ff_v1p32 -rc_corner {rc_best} -library_set {scc013ull_hd_rvt_ff_v1p32_-40c_basic}
# create_delay_corner -name delay_corner_tt_v1p5_25c -rc_corner {rc_worst} -library_set {scc013ull_hd_rvt_tt_v1p5_25c_basic}
create_constraint_mode -name functional_ss_v1p08_125c \
    -sdc_files { /nfs/mcu8b/jirath/PnR2/inputs/ATmega328pb_ss_sdc.sdc}
create_constraint_mode -name functional_ff_v1p32 \
    -sdc_files { /nfs/mcu8b/jirath/PnR2/inputs/ATmega328pb_ff_sdc.sdc}
# create_constraint_mode -name functional_tt_v1p5_25c \
#     -sdc_files { /nfs/mcu8b/jirath/synthesis/constraints/ATMega328/ATmega328_constraints_tt.sdc }
create_analysis_view -name view_ss_v1p08_125c \
    -constraint_mode functional_ss_v1p08_125c \
    -delay_corner delay_corner_ss_v1p08_125c
create_analysis_view -name view_ff_v1p32 \
    -constraint_mode functional_ff_v1p32 \
    -delay_corner delay_corner_ff_v1p32
# create_analysis_view -name view_tt_v1p5_25c \
#     -constraint_mode functional_tt_v1p5_25c \
#     -delay_corner delay_corner_tt_v1p5_25c
# set_analysis_view -setup { view_ss_v1p08_125c view_ff_v1p32 view_tt_v1p5_25c } \
#                   -hold { view_ss_v1p08_125c view_ff_v1p32 view_tt_v1p5_25c }
set_analysis_view -setup { view_ss_v1p08_125c view_ff_v1p32 } \
                  -hold { view_ss_v1p08_125c view_ff_v1p32 }
