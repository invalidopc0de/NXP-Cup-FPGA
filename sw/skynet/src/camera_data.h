/*
 * camera.h
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#ifndef SRC_CAMERA_DATA_H_
#define SRC_CAMERA_DATA_H_

#include "stdint.h"

#ifdef NXP_FPGA_FIFO

/** CAMERA_DATA_STATUS - Register Layout Typedef */
typedef struct {
  volatile uint32_t FILL_LEVEL;     /**< FIFO Fill level, offset: 0x0 */
  volatile uint32_t STATUS; 		/**< FIFO Status, offset: 0x4 */
  volatile uint32_t EVENT;			/**< FIFO Event, offset: 0x8 */
  volatile uint32_t INT_ENABLE;		/**< FIFO Interrupt Enable, offset: 0xC */
  volatile uint32_t ALMOST_FULL;	/**< FIFO Almost Full, offset: 0x10 */
  volatile uint32_t ALMOST_EMPTY;	/**< FIFO Almost Empty, offset: 0x14 */
} CAMERA_DATA_STATUS_Type;

/** CAMERA_DATA - Register Layout Typedef */
typedef struct {
  volatile uint32_t DATA;        /**< FIFO Data, offset: 0x0 */
  volatile uint32_t FLAGS; 		/**< FIFO Flags, offset: 0x4 */
} CAMERA_DATA_Type;



#define CAMERA_EOP_MASK	0x2
#define CAMERA_EOP_SHIFT 1
#define CAMERA_EOP(x) ((x & CAMERA_EOP_MASK) >> CAMERA_EOP_SHIFT)

#define CAMERA_SOP_MASK 0x1
#define CAMERA_SOP_SHIFT 0
#define CAMERA_SOP(x) ((x & CAMERA_SOP_MASK) >> CAMERA_SOP_SHIFT)

#define CAMERA_DATA_STATUS(base)    ((CAMERA_DATA_STATUS_Type *) (base))

#define CAMERA_DATA(base)    ((CAMERA_DATA_Type *) (base))

int CameraDataGetLine(void* data_base, void* status_base, uint32_t* line, int maxLen);

#else

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

#define DMA_CSR_STATUS_RESPONSE_BUFF_EMPTY_SHIFT 	3
#define DMA_CSR_STATUS_RESPONSE_BUFF_EMPTY_MASK 	(1 << 3)

#define DMA_CSR_STATUS_BUSY_SHIFT	0
#define DMA_CSR_STAUTS_BUSY_MASK	(1 << 0)

typedef struct {
	void*	CSR_ptr;
	void*	Response_ptr;
	void*	Descriptor_ptr;
} mSGMDA_Bases_Type;

void CameraDataDMAStart(mSGMDA_Bases_Type* status_base, int maxLen);
int CameraDataGetLine(void* data_base, mSGMDA_Bases_Type* status_base, uint32_t* line, int maxLen);

#endif

#endif /* SRC_CAMERA_DATA_H_ */
