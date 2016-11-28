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
  volatile uint32_t DIR;        /**< Motor direction, offset: 0x0 */
  volatile uint32_t DUTY_CYCLE; /**< PWM Duty cycle, offset: 0x4 */
} CAMERA_CONTROL_Type;

#define CAMERA_CONTROL(base)    ((CAMERA_CONTROL_Type *) (base))

int CameraReset(void* base);

#endif /* SRC_CAMERA_DATA_H_ */
