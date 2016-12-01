/*
 * camera.h
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#ifndef SRC_CAMERA_DATA_H_
#define SRC_CAMERA_DATA_H_

#include "stdint.h"

#pragma pack(push,1)
/**
 * @brief mSGDMA control and status register
 */
typedef struct {
	uint32_t	status;
	uint32_t	control;
	uint16_t	rd_fill_level;
	uint16_t	wr_fill_level;
	uint16_t	resp_fill_level;
	uint16_t	reserved_0;
	uint16_t	rd_sequence_number;
	uint16_t	wr_sequence_number;
	uint32_t	reserved_1;
	uint32_t	reserved_2;
	uint32_t	reserved_3;
} mSGDMA_CSR_Type;

typedef struct {
	uint32_t 	bytes_transfered;
	uint32_t 	flags;
} mSGDMA_RESPONSE_Type;

typedef struct {
	uint32_t 	read_addr;
	uint32_t 	write_addr;
	uint32_t 	length;
	uint32_t	control;
} mSGMDA_DESCRIPTOR_Type;
#pragma pack(pop)

#define DMA_DSC_CONTROL_GO_SHIFT	31
#define DMA_DSC_CONTROL_GO_MASK 	(1 << 31)

#define DMA_DSC_CONTROL_END_EOP_SHIFT 	12
#define DMA_DSC_CONTROL_END_EOP_MASK	(1 << 12)

#define DMA_DSC_CONTROL_EARLY_DONE_SHIFT 	24
#define DMA_DSC_CONTROL_EARLY_DONE_MASK		(1 << 24)

#define DMA_CSR_STATUS_RESPONSE_BUFF_EMPTY_SHIFT 	3
#define DMA_CSR_STATUS_RESPONSE_BUFF_EMPTY_MASK 	(1 << 3)

#define DMA_CSR_STATUS_BUSY_SHIFT	0
#define DMA_CSR_STAUTS_BUSY_MASK	(1 << 0)

#define DMA_RESPONSE_EARLY_TERMINATION_SHIFT 	1
#define DMA_RESPONSE_EARLY_TERMINATION_MASK		(1 << 1)

typedef struct {
	void*	CSR_ptr;
	void*	Response_ptr;
	void*	Descriptor_ptr;
} mSGMDA_Bases_Type;

void CameraDataDMAStart(mSGMDA_Bases_Type* status_base, int maxLen);
int CameraDataGetLine(void* data_base, mSGMDA_Bases_Type* status_base, uint32_t* line, int maxLen);

#endif /* SRC_CAMERA_DATA_H_ */
