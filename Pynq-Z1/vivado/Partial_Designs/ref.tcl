system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0

read_checkpoint -cell system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0 Synth/pass_through.dcp


set_property HD.RECONFIGURABLE 1 [get_cells system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0]
create_pblock pblock_video
add_cells_to_pblock [get_pblocks pblock_video] [get_cells -quiet [list system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0]]
resize_pblock [get_pblocks pblock_video] -add {SLICE_X80Y50:SLICE_X97Y149 DSP48_X3Y20:DSP48_X3Y59 RAMB18_X4Y20:RAMB18_X4Y59 RAMB36_X4Y10:RAMB36_X4Y29}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_video]
set_property SNAPPING_MODE ON [get_pblocks pblock_video]


update_design -cells system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0 -black_box
