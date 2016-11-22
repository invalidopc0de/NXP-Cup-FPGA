/*
 * fpga_interface.h
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#ifndef FPGA_INTERFACE_H_
#define FPGA_INTERFACE_H_

#define HW_REGS_BASE ( ALT_STM_OFST )
#define HW_REGS_SPAN ( 0x04000000 )
#define HW_REGS_MASK ( HW_REGS_SPAN - 1 )

#define FPGA_MEM(base, offset) (base + ((unsigned long )(ALT_LWFPGASLVS_OFST + offset) & (unsigned long)(HW_REGS_MASK)))

void* FPGAMapMemory(int *fdPtr);
int FPGAUnmapMemory(int fd, void* memory);

#endif /* FPGA_INTERFACE_H_ */
