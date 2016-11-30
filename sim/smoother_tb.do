vlib work
set worklib work
vcom ../src/nxp_fpga_types.vhd 
vcom ../src/smoothing_filter/smoother.vhd
vcom smoother_tb.vhd
vsim smoother_tb


add wave -position end  sim:/smoother_tb/rst
add wave -position end  sim:/smoother_tb/clk
add wave -position end  sim:/smoother_tb/s_raw_data
add wave -position end  sim:/smoother_tb/s_raw_channel
add wave -position end  sim:/smoother_tb/s_raw_valid
add wave -position end  sim:/smoother_tb/s_raw_sop
add wave -position end  sim:/smoother_tb/s_raw_eop

run 1ms

#endsim
#quit
