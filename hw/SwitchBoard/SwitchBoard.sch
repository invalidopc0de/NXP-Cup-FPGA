EESchema Schematic File Version 2
LIBS:power
LIBS:device
LIBS:transistors
LIBS:conn
LIBS:linear
LIBS:regul
LIBS:74xx
LIBS:cmos4000
LIBS:adc-dac
LIBS:memory
LIBS:xilinx
LIBS:microcontrollers
LIBS:dsp
LIBS:microchip
LIBS:analog_switches
LIBS:motorola
LIBS:texas
LIBS:intel
LIBS:audio
LIBS:interface
LIBS:digital-audio
LIBS:philips
LIBS:display
LIBS:cypress
LIBS:siliconi
LIBS:opto
LIBS:atmel
LIBS:contrib
LIBS:valves
LIBS:SwitchBoard-cache
EELAYER 25 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Switch_SPDT_x2 SW1
U 1 1 582F68B9
P 4650 2550
F 0 "SW1" H 4450 2700 50  0000 C CNN
F 1 "Switch_SPDT_x2" H 4400 2400 50  0000 C CNN
F 2 "switch:DIP-6_0_ELL" H 4650 2550 50  0001 C CNN
F 3 "" H 4650 2550 50  0000 C CNN
	1    4650 2550
	1    0    0    -1  
$EndComp
$Comp
L Switch_SPDT_x2 SW1
U 2 1 582F6966
P 4650 2950
F 0 "SW1" H 4450 3100 50  0000 C CNN
F 1 "Switch_SPDT_x2" H 4400 2800 50  0000 C CNN
F 2 "switch:DIP-6_0_ELL" H 4650 2950 50  0001 C CNN
F 3 "" H 4650 2950 50  0000 C CNN
	2    4650 2950
	1    0    0    -1  
$EndComp
Wire Wire Line
	3400 2700 3850 2700
Wire Wire Line
	3850 2550 3850 2950
Wire Wire Line
	3850 2950 4350 2950
Wire Wire Line
	3400 3300 6200 3300
$Comp
L CP C1
U 1 1 582F6C9B
P 5350 3050
F 0 "C1" H 5375 3150 50  0000 L CNN
F 1 "220uF" H 5375 2950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L11.5_P3.5" H 5388 2900 50  0001 C CNN
F 3 "" H 5350 3050 50  0000 C CNN
	1    5350 3050
	1    0    0    -1  
$EndComp
$Comp
L CP C2
U 1 1 582F6CD0
P 5700 3050
F 0 "C2" H 5725 3150 50  0000 L CNN
F 1 "220uF" H 5725 2950 50  0000 L CNN
F 2 "Capacitors_ThroughHole:C_Radial_D8_L11.5_P3.5" H 5738 2900 50  0001 C CNN
F 3 "" H 5700 3050 50  0000 C CNN
	1    5700 3050
	1    0    0    -1  
$EndComp
Wire Wire Line
	5700 3200 5700 3300
Connection ~ 5700 3300
Wire Wire Line
	5350 3200 5350 3300
Connection ~ 5350 3300
Wire Wire Line
	5350 2900 5350 2850
Connection ~ 5350 2850
Wire Wire Line
	5700 2850 5700 2900
Connection ~ 5700 2850
Connection ~ 5100 2850
Wire Wire Line
	4350 2550 3850 2550
Connection ~ 3850 2700
Wire Wire Line
	5100 2450 5100 3050
Wire Wire Line
	5100 2850 6200 2850
Wire Wire Line
	5100 3050 4950 3050
Wire Wire Line
	5100 2450 4950 2450
$Comp
L CONN_01X02 CAR1
U 1 1 582FDBAA
P 6500 3050
F 0 "CAR1" H 6500 3200 50  0000 C CNN
F 1 "CONN_01X02" V 6600 3050 50  0000 C CNN
F 2 "switch:terminal_block" H 6500 3050 50  0001 C CNN
F 3 "" H 6500 3050 50  0000 C CNN
	1    6500 3050
	1    0    0    -1  
$EndComp
$Comp
L CONN_01X02 BATT1
U 1 1 582FDBD8
P 3150 3050
F 0 "BATT1" H 3150 3200 50  0000 C CNN
F 1 "CONN_01X02" V 3250 3050 50  0000 C CNN
F 2 "switch:terminal_block" H 3150 3050 50  0001 C CNN
F 3 "" H 3150 3050 50  0000 C CNN
	1    3150 3050
	-1   0    0    1   
$EndComp
Wire Wire Line
	3400 2700 3400 3000
Wire Wire Line
	3400 3000 3350 3000
Wire Wire Line
	3350 3100 3400 3100
Wire Wire Line
	3400 3100 3400 3300
Wire Wire Line
	6200 2850 6200 3000
Wire Wire Line
	6200 3000 6300 3000
Wire Wire Line
	6300 3100 6200 3100
Wire Wire Line
	6200 3100 6200 3300
$EndSCHEMATC
