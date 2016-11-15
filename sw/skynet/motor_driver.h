#ifndef _MOTOR_DRIVER_H_
#define _MOTOR_DRIVER_H_

#include "hps_0.h"

/** MOTOR_DRIVER - Register Layout Typedef */
typedef struct {
  volatile uint32_t DIR;        /**< Motor direction, offset: 0x0 */
  volatile uint32_t DUTY_CYCLE; /**< PWM Duty cycle, offset: 0x4 */
} MOTOR_DRIVER_Type;

#define MOTOR(base)    ((MOTOR_DRIVER_Type *) (base))

#endif