# NXP-Cup-FPGA

## Overview

This project involved directing the NXP (Freescale) Cup Car to drive around a white track with two black lanes on each side.  This solution uses a Cyclone V SE SoC/FPGA with an OV7670 camera sensor to steer the car.  The FPGA side of the SoC is used to interface with the camera, apply filtering to the data stream, and finally hand the data over to the ARM CPU for processing in Linux.  The Linux application analyzes the data, determines which lines can be seen, and uses a PID loop to calculate motor control outputs.  These outputs are then communicated back to the FPGA, which controls the motors.  

## Project Directory Layout

**doc** Project Documentation (Diagrams, Whitepapers, Datasheets)

**hw** Hardware Schematics and PCBs

**ip** Generated IP Cores (Altera MegaWizard)

**mech** Mechanical CAD models 

**prj** Tool specific files (Quartus Project Files, etc)

**sim** Simulations for Programmable Logic (Testbenches)

**src** Source for Programmable Logic

**sw** Software source code

