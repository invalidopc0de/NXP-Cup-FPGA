/*
 * camera.h
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#ifndef SRC_CAMERA_DATA_H_
#define SRC_CAMERA_DATA_H_

#include "stdint.h"

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

#endif /* SRC_CAMERA_DATA_H_ */
