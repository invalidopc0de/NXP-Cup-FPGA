#include <stdio.h>
#include <stdint.h>


#define soc_cv_av 1

#include "hwlib.h"
#include "soc_cv_av/socal/socal.h"
#include "soc_cv_av/socal/hps.h"

#include "hps_0.h"
#include "fpga_interface.h"
#include "motor_driver.h"

int main() {

	int fd;
	void *virtual_base;
	void *motor0_base;
	
	virtual_base = FPGAMapMemory(&fd);

	// Setup device pointers
	motor0_base = FPGA_MEM(virtual_base, MOTOR_DRIVER_0_BASE);
	
	SetDutyCycle(motor0_base, 50, 0);

	// wait 5s
	usleep( 5*1000*1000 );

	SetDutyCycle(motor0_base, 0, 0);

	FPGAUnmapMemory(fd, virtual_base);

	return( 0 );
}
