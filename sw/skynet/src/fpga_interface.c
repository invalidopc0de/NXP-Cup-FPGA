/*
 * fpga_interface.c
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>

#include "soc_cv_av/socal/hps.h"

#include "fpga_interface.h"

void* FPGAMapMemory(int *fdPtr)
{
	void *virtual_base, fpga_base;

	// map the address space for the registers into user space so we can interact with them.
	// we'll actually map in the entire CSR span of the HPS since we want to access various registers within that span

	if((*fdPtr = open("/dev/mem", (O_RDWR | O_SYNC))) == -1) {
		printf("ERROR: could not open \"/dev/mem\"...\n" );
		return -1;
	}

	virtual_base = mmap(NULL, HW_REGS_SPAN, (PROT_READ | PROT_WRITE), MAP_SHARED, *fdPtr, HW_REGS_BASE);

	if(virtual_base == MAP_FAILED) {
		printf("ERROR: mmap() failed...\n");
		close(*fdPtr);
		return -1;
	}

	return virtual_base;
}


int FPGAUnmapMemory(int fd, void* memory)
{
	// clean up our memory mapping and exit

	if( munmap(memory, HW_REGS_SPAN) != 0 ) {
		printf("ERROR: munmap() failed...\n");
		close(fd);
		return -1;
	}

	close(fd);

	return 0;
}
