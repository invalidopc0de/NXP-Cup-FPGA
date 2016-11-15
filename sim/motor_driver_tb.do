vlib work
set worklib work
vcom ../src/motor_driver/thirdparty/pwm.vhd 
vcom ../src/motor_driver/motor_driver_avalon.vhd
vcom motor_driver_tb.vhd
vsim motor_driver_tb


add wave -position end  sim:/motor_driver_tb/uut/r
add wave -position end  sim:/motor_driver_tb/clk
add wave -position end  sim:/motor_driver_tb/rst_n

add wave -position end  sim:/motor_driver_tb/avs_s0_address
add wave -position end  sim:/motor_driver_tb/avs_s0_read
add wave -position end  sim:/motor_driver_tb/avs_s0_readdata
add wave -position end  sim:/motor_driver_tb/avs_s0_write
add wave -position end  sim:/motor_driver_tb/avs_s0_writedata
add wave -position end  sim:/motor_driver_tb/avs_s0_waitrequest
add wave -position end  sim:/motor_driver_tb/motor_pin_a
add wave -position end  sim:/motor_driver_tb/motor_pin_b


run 1000us

#endsim
#quit