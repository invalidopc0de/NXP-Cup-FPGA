/*
 * motor_driver.c
 *
 *  Created on: Nov 20, 2016
 *      Author: Mark
 */

#include "motor_driver.h"

void SetDutyCycle(void* base, uint32_t dutyCycle, uint32_t dir)
{
	uint32_t mod = (dutyCycle / 100) * 255;
	MOTOR(base)->DIR = dir;
	MOTOR(base)->DUTY_CYCLE = mod;
}
