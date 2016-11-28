/*
 * motor_driver.c
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#include "motor_driver.h"

void SetDutyCycle(void* base, float dutyCycle, uint32_t dir)
{
	// This will truncate the float, this is expected
	uint32_t mod = (dutyCycle / 100.0) * 255.0; 
	MOTOR(base)->DIR = dir;
	MOTOR(base)->DUTY_CYCLE = mod;
}
