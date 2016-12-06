# TCL File Generated by Component Editor 15.1
# Mon Nov 28 17:29:07 EST 2016
# DO NOT MODIFY


# 
# line_scan_camera "Line Scan Camera" v1.0
#  2016.11.28.17:29:07
# 
# 

# 
# request TCL package from ACDS 15.1
# 
package require -exact qsys 15.1


# 
# module line_scan_camera
# 
set_module_property DESCRIPTION ""
set_module_property NAME line_scan_camera
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property GROUP Other
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Line Scan Camera"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL line_scan_camera_st
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file line_scan_camera_st.vhd VHDL PATH ../src/line_scan_camera/line_scan_camera_st.vhd TOP_LEVEL_FILE
add_fileset_file LTC2308.v VERILOG PATH ../src/line_scan_camera/thirdparty/LTC2308.v
add_fileset_file camera.vhd VHDL PATH ../src/line_scan_camera/camera.vhd

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE true
add_fileset_file line_scan_camera_st.vhd VHDL PATH ../src/line_scan_camera/line_scan_camera_st.vhd
add_fileset_file LTC2308.v VERILOG PATH ../src/line_scan_camera/thirdparty/LTC2308.v
add_fileset_file camera.vhd VHDL PATH ../src/line_scan_camera/camera.vhd


# 
# parameters
# 


# 
# display items
# 


# 
# connection point data_out
# 
add_interface data_out avalon_streaming start
set_interface_property data_out associatedClock clk
set_interface_property data_out associatedReset clk_reset
set_interface_property data_out dataBitsPerSymbol 8
set_interface_property data_out errorDescriptor ""
set_interface_property data_out firstSymbolInHighOrderBits true
set_interface_property data_out maxChannel 0
set_interface_property data_out readyLatency 0
set_interface_property data_out ENABLED true
set_interface_property data_out EXPORT_OF ""
set_interface_property data_out PORT_NAME_MAP ""
set_interface_property data_out CMSIS_SVD_VARIABLES ""
set_interface_property data_out SVD_ADDRESS_GROUP ""

add_interface_port data_out data_out_endofpacket endofpacket Output 1
add_interface_port data_out data_out_data data Output 8
add_interface_port data_out data_out_startofpacket startofpacket Output 1
add_interface_port data_out data_out_valid valid Output 1


# 
# connection point control
# 
add_interface control avalon end
set_interface_property control addressUnits WORDS
set_interface_property control associatedClock clk
set_interface_property control associatedReset clk_reset
set_interface_property control bitsPerSymbol 8
set_interface_property control burstOnBurstBoundariesOnly false
set_interface_property control burstcountUnits WORDS
set_interface_property control explicitAddressSpan 0
set_interface_property control holdTime 0
set_interface_property control linewrapBursts false
set_interface_property control maximumPendingReadTransactions 0
set_interface_property control maximumPendingWriteTransactions 0
set_interface_property control readLatency 0
set_interface_property control readWaitTime 1
set_interface_property control setupTime 0
set_interface_property control timingUnits Cycles
set_interface_property control writeWaitTime 0
set_interface_property control ENABLED true
set_interface_property control EXPORT_OF ""
set_interface_property control PORT_NAME_MAP ""
set_interface_property control CMSIS_SVD_VARIABLES ""
set_interface_property control SVD_ADDRESS_GROUP ""

add_interface_port control control_address address Input 8
add_interface_port control control_read read Input 1
add_interface_port control control_readdata readdata Output 32
add_interface_port control control_write write Input 1
add_interface_port control control_writedata writedata Input 32
add_interface_port control control_waitrequest waitrequest Output 1
set_interface_assignment control embeddedsw.configuration.isFlash 0
set_interface_assignment control embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment control embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment control embeddedsw.configuration.isPrintableDevice 0


# 
# connection point pins
# 
add_interface pins conduit end
set_interface_property pins associatedClock ""
set_interface_property pins associatedReset ""
set_interface_property pins ENABLED true
set_interface_property pins EXPORT_OF ""
set_interface_property pins PORT_NAME_MAP ""
set_interface_property pins CMSIS_SVD_VARIABLES ""
set_interface_property pins SVD_ADDRESS_GROUP ""

add_interface_port pins adc_convst adc_convst_pin Output 1
add_interface_port pins adc_sck adc_sck_pin Output 1
add_interface_port pins adc_sdi adc_sdi_pin Output 1
add_interface_port pins adc_sdo adc_sdo_pin Input 1
add_interface_port pins camera_clk camera_clk_pin Output 1
add_interface_port pins camera_si camera_si_pin Output 1


# 
# connection point clk_reset
# 
add_interface clk_reset reset end
set_interface_property clk_reset associatedClock clk
set_interface_property clk_reset synchronousEdges DEASSERT
set_interface_property clk_reset ENABLED true
set_interface_property clk_reset EXPORT_OF ""
set_interface_property clk_reset PORT_NAME_MAP ""
set_interface_property clk_reset CMSIS_SVD_VARIABLES ""
set_interface_property clk_reset SVD_ADDRESS_GROUP ""

add_interface_port clk_reset reset_reset reset_n Input 1


# 
# connection point clk
# 
add_interface clk clock end
set_interface_property clk clockRate 40000000
set_interface_property clk ENABLED true
set_interface_property clk EXPORT_OF ""
set_interface_property clk PORT_NAME_MAP ""
set_interface_property clk CMSIS_SVD_VARIABLES ""
set_interface_property clk SVD_ADDRESS_GROUP ""

add_interface_port clk clock_clk clk Input 1
