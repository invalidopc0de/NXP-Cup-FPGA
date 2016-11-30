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

add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_vsync
add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_href
add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_pclk
add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_data
add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_sioc
add wave -group "Camera Interface" -position end  sim:/ov7670_st_tb/ov_sensor_siod

add wave -group "Avalon ST Output" -position end  sim:/ov7670_st_tb/uut/line0_out_data
add wave -group "Avalon ST Output" -position end  sim:/ov7670_st_tb/uut/line0_out_valid
add wave -group "Avalon ST Output" -position end  sim:/ov7670_st_tb/uut/line0_out_channel
add wave -group "Avalon ST Output" -position end  sim:/ov7670_st_tb/uut/line0_out_startofpacket
add wave -group "Avalon ST Output" -position end  sim:/ov7670_st_tb/uut/line0_out_endofpacket

add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_address
add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_read
add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_readdata
add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_write
add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_writedata
add wave -group "Control Interface" -position end  sim:/ov7670_st_tb/control_waitrequest

add wave -group "I2C Stuff" -position end sim:/ov7670_st_tb/uut/controller/Inst_i2c_sender/*

add wave -position end  sim:/ov7670_st_tb/uut/controller/r

add wave -position end  sim:/ov7670_st_tb/uut/controller/cmd_write
add wave -position end  sim:/ov7670_st_tb/uut/controller/cmd_busy

add wave -position end  sim:/ov7670_st_tb/uut/capture/r



run 1000us

#endsim
#quit