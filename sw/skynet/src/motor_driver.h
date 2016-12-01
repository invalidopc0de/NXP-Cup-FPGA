#ifndef _MOTOR_DRIVER_H_
#define _MOTOR_DRIVER_H_

#include "hps_0.h"
#include "stdint.h"

#define SERVO_MAX_RIGHT 8.63
#define SERVO_CTR 7
#define SERVO_MAX_LEFT  4.3

#define MOTOR_FORWARD   0
#define MOTOR_BACKWARD  1
#define MOTOR_MIN   0
#define MOTOR_MAX   100

/** MOTOR_DRIVER - Register Layout Typedef */
typedef struct {
  volatile uint32_t DIR;        /**< Motor direction, offset: 0x0 */
  volatile uint32_t DUTY_CYCLE; /**< PWM Duty cycle, offset: 0x4 */
} MOTOR_DRIVER_Type;

#define MOTOR(base)    ((MOTOR_DRIVER_Type *) (base))

void SetDutyCycle(void* base, float dutyCycle, uint32_t frequency);

#endif
