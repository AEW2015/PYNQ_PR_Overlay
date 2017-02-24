################################################################
# Brigham Young University Video Filtering Base Design
# 
# build_static_design.tcl
# Version 1.0
# Last Modified: February 24, 2017
################################################################

read_vhdl ./Source/pass_through.vhd
synth_design -mode out_of_context -flatten_hierarchy rebuilt -top Video_Box -part xc7z020clg400-1
write_checkpoint -force Synth/pass_through.dcp 
close_project

open_checkpoint ./Static/top.dcp
read_checkpoint -cell system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0 Synth/pass_through.dcp
set_property HD.RECONFIGURABLE 1 [get_cells system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0]
write_checkpoint -force ./Checkpoint/pr_block_design.dcp

create_pblock pblock_video
add_cells_to_pblock [get_pblocks pblock_video] [get_cells -quiet [list system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0]]
resize_pblock [get_pblocks pblock_video] -add {SLICE_X82Y50:SLICE_X93Y149 DSP48_X3Y20:DSP48_X3Y59 RAMB18_X4Y20:RAMB18_X4Y59 RAMB36_X4Y10:RAMB36_X4Y29}
set_property RESET_AFTER_RECONFIG true [get_pblocks pblock_video]
set_property SNAPPING_MODE ON [get_pblocks pblock_video]

read_xdc Const/top.xdc

opt_design
place_design
route_design

write_checkpoint -force Implement/pass_route_design.dcp
report_utilization -file Implement/pass_utilization.rpt

write_bitstream -file Bitstreams/pass_through.bit -force

update_design -cells system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0 -black_box
lock_design -level routing
write_checkpoint -force Checkpoint/static_route_design.dcp
close_project