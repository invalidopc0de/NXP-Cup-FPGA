/*
 * control_loop.h
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#ifndef SRC_CONTROL_LOOP_H_
#define SRC_CONTROL_LOOP_H_

#include <stdint.h>

#include "line_analyzer.h"

#define CONTROLLOOP_SUCCESS	0
#define CONTROLLOOP_ERROR 	-1

#define CONTROLLOOP_LINES 1

typedef struct {
    LineFeatures* lines[CONTROLLOOP_LINES];
    int LineLength;

    float Kp;
    float Ki;
    float Kd; 

	char StopDetectionEnabled;

	int	DefaultSpeed;
	int FrameStraightDelay;
} ControlLoopParams;

typedef struct {
	float FramesSinceLastLine;

	float LastServoPos;
    float LastValue;
    float LastError[2];
} ControlLoopState;

typedef struct {
	char MotorDirection[2];
	int MotorDutyCycle[2];

	float ServoDutyCycle;
} ControlLoopOutputs;

int ControlLoopInit(ControlLoopState* state);
int ControlLoopCalc(ControlLoopParams* params, ControlLoopState* state, ControlLoopOutputs* outputs);

#endif /* SRC_CONTROL_LOOP_H_ */
