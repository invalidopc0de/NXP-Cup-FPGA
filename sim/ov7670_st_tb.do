vlib work
set worklib work
vcom ../src/nxp_fpga_types.vhd 
vcom ../src/OV7670_camera/third_party/i2c_sender.vhd
vcom ../src/OV7670_camera/third_party/ov7670_controller.vhd
vcom ../src/OV7670_camera/third_party/ov7670_registers.vhd
vcom ../src/OV7670_camera/ov7670_capture.vhd
vcom ../src/OV7670_camera/ov7670_st.vhd
vcom ov7670_st_tb.vhd
vsim ov7670_st_tb


add wave -position end  sim:/ov7670_st_tb/clk
add wave -position end  sim:/ov7670_st_tb/rst
add wave -position end  sim:/ov7670_st_tb/ov_sensor_vsync
add wave -position end  sim:/ov7670_st_tb/ov_sensor_href
add wave -position end  sim:/ov7670_st_tb/ov_sensor_pclk
add wave -position end  sim:/ov7670_st_tb/ov_sensor_data

add wave -position end  sim:/ov7670_st_tb/uut/line0_out_data
add wave -position end  sim:/ov7670_st_tb/uut/line0_out_valid
add wave -position end  sim:/ov7670_st_tb/uut/line0_out_channel
add wave -position end  sim:/ov7670_st_tb/uut/line0_out_startofpacket
add wave -position end  sim:/ov7670_st_tb/uut/line0_out_endofpacket

add wave -position end  sim:/ov7670_st_tb/uut/capture/r

run 175us

#endsim
#quit