/*
 * camera.h
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#ifndef SRC_CAMERA_CONTROL_H_
#define SRC_CAMERA_CONTROL_H_

#include "stdint.h"

/** CAMERA - Register Layout Typedef */
typedef struct {
  volatile uint32_t CONFIG;        /**< Camera config write, offset: 0x0 */
} CAMERA_CONTROL_Type;

#define CAMERA_CONTROL(base)    ((CAMERA_CONTROL_Type *) (base))

int CameraReset(void* base);

int CameraLoadConfig(void* base, char* filename);

#endif /* SRC_CAMERA_DATA_H_ */
