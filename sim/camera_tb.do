vlib work
set worklib work
vcom ../src/nxp_fpga_types.vhd 
vcom ../src/line_scan_camera/camera.vhd
vcom camera_tb.vhd
vsim camera_tb


add wave -position end  sim:/camera_tb/uut/r
add wave -position end  sim:/camera_tb/din
add wave -position end  sim:/camera_tb/dout
add wave -position end  sim:/camera_tb/clk
add wave -position end  sim:/camera_tb/rst

run 7.5ms

#endsim
#quit