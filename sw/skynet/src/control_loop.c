/*
 * control_loop.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "control_loop.h"

#include <math.h>

#define SERVO_MAX_RIGHT 7
#define SERVO_CTR 5
#define SERVO_MAX_LEFT  3

#define MOTOR_FORWARD   0
#define MOTOR_BACKWARD  1
#define MOTOR_MIN   0
#define MOTOR_MAX   100

int ControlLoopInit(ControlLoopState* state)
{
    state->LastServoPos = SERVO_CTR;
    return 0;
}

int ControlLoopCalc(ControlLoopParams* params, ControlLoopState* state, ControlLoopOutputs* outputs)
{
    // Assumptions (for now):
    // Only support 1 line
    // Try to aim for the center of the track
    
    LineFeatures* line1 = params->lines[0];
    
    if (line1->LeftLineVisible && line1->RightLineVisible) {
        // We can see both lines
        int ideal_center_pnt = params->LineLength >> 1; // Fast divide by 2
        int cur_center_pnt = (line1->LeftLineLocation + line1->RightLineLocation) >> 1;

        // Calculate the error between the current center
        // and the center we want.  < 0 == left, > 0 == right
        int err = cur_center_pnt - ideal_center_pnt;
        
        float new_servo_pos = state->LastServoPos + 
                            params->Kp * (err - state->LastError) + 
                            params->Ki * (err + state->LastError)/2;

        // Clip
        if (new_servo_pos > 0) {
            new_servo_pos = fmin(new_servo_pos, SERVO_MAX_RIGHT);
        } else {
            new_servo_pos = fmax(new_servo_pos, SERVO_MAX_LEFT);
        }
        
        outputs->ServoDutyCycle = new_servo_pos;

        state->LastServoPos = new_servo_pos;
        state->LastError = err;

        // TODO Add differential drive later (once we have two camera lines)
        outputs->ServoDutyCycle = SERVO_CTR;

        outputs->MotorDirection[0] = MOTOR_FORWARD;
        outputs->MotorDirection[1] = MOTOR_FORWARD;

        outputs->MotorDutyCycle[0] = MOTOR_MAX;
        outputs->MotorDutyCycle[1] = MOTOR_MAX;
    } else if (line1->LeftLineVisible || line1->RightLineVisible) {
        // We can only see one of the lines

        // For now, lets just turn a decent amount
        if (line1->LeftLineVisible) 
        {
            outputs->ServoDutyCycle = (SERVO_MAX_RIGHT + SERVO_CTR) / 2;
        } else {
            outputs->ServoDutyCycle = (SERVO_MAX_LEFT + SERVO_CTR) / 2;
        }

        // TODO add differential drive
        outputs->MotorDirection[0] = MOTOR_FORWARD;
        outputs->MotorDirection[1] = MOTOR_FORWARD;

        outputs->MotorDutyCycle[0] = MOTOR_MAX;
        outputs->MotorDutyCycle[1] = MOTOR_MAX;
    } else {
        // We can't see anything! Help

        // Actually, this will probably mean we're at the 
        // 4 way cross.  Just go straight

        outputs->ServoDutyCycle = SERVO_CTR;

        outputs->MotorDirection[0] = MOTOR_FORWARD;
        outputs->MotorDirection[1] = MOTOR_FORWARD;

        outputs->MotorDutyCycle[0] = MOTOR_MAX;
        outputs->MotorDutyCycle[1] = MOTOR_MAX;
    }
}