set_global_assignment -entity "sobel" -library "lib_sobel" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "sobel" -library "lib_sobel" -name IP_TOOL_VERSION "15.1"
set_global_assignment -entity "sobel" -library "lib_sobel" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_sobel" -name SPD_FILE [file join $::quartus(sip_path) "sobel.spd"]

set_global_assignment -library "lib_sobel" -name MISC_FILE [file join $::quartus(sip_path) "sobel_sim/sobel.vhd"]
