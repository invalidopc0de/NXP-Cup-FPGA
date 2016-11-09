vlib work
set worklib work
vcom ../src/nxp_fpga_types.vhd 
vcom ../ip/sobel/sobel_sim/sobel.vhd
vcom ../src/edge_filter.vhd
vcom edge_filter_tb.vhd
vsim edge_filter_tb


add wave -position end  sim:/edge_filter_tb/uut/r
add wave -position end  sim:/edge_filter_tb/din
add wave -position end  sim:/edge_filter_tb/dout
add wave -position end  sim:/edge_filter_tb/clk
add wave -position end  sim:/edge_filter_tb/rst

run 175us

#endsim
#quit