proc part_gen {str} {
	read_vhdl Source/$str.vhd
	synth_design -mode out_of_context -flatten_hierarchy rebuilt -top Video_Box -part xc7z020clg400-1
	write_checkpoint Synth/$str.dcp -force
	close_project
	
	open_checkpoint Checkpoint/static_route_design.dcp

	read_checkpoint -cell system_i/video/Video_PR_0/U0/Video_PR_v1_0_S_AXI_inst/Video_Box_0 Synth/$str.dcp

	opt_design
	place_design
	route_design

	write_checkpoint -force Implement/$str.dcp

	write_bitstream -file Bitstreams/$str.bit -force

	close_project

}


