/*
 * control_loop.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "control_loop.h"
#include <stdlib.h>

#include <math.h>
#include "motor_driver.h"

int ControlLoopInit(ControlLoopState* state)
{
    state->LastValue = 0;
    return 0;
}

int ControlLoopCalc(ControlLoopParams* params, ControlLoopState* state, ControlLoopOutputs* outputs)
{
    // Assumptions (for now):
    // Only support 1 line
    // Try to aim for the center of the track
    
    LineFeatures* line1 = params->lines[0];
    
    /*
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

        outputs->MotorDutyCycle[0] = 30;
        outputs->MotorDutyCycle[1] = 30;
    } else */

    if (line1->LeftLineVisible || line1->RightLineVisible) {
        // We can only see one of the lines
    	state->FramesSinceLastLine = 0;

    	 // Calculate the error between the current center
		// and the center we want.  < 0 == left, > 0 == right
		float err = 0.0;

        // For now, lets just turn a decent amount
        if (line1->LeftLineVisible) 
        {
        	err = (((float) line1->LeftLineLocation) / params->LineLength);
            //outputs->ServoDutyCycle = (SERVO_MAX_RIGHT + SERVO_CTR) / 2;
        	//outputs->ServoDutyCycle = fmin(((SERVO_MAX_RIGHT - SERVO_CTR) * (line1->LeftLineLocation/(params->LineLength/2))) + SERVO_CTR, SERVO_MAX_RIGHT);
        } else {
        	err = (((float) (params->LineLength - line1->RightLineLocation)) / params->LineLength);

            //outputs->ServoDutyCycle = (SERVO_MAX_LEFT + SERVO_CTR) / 2;
        	//outputs->ServoDutyCycle = fmax(((SERVO_MAX_LEFT - SERVO_CTR) * ((params->LineLength - line1->RightLineLocation)/(params->LineLength/2)) + SERVO_CTR), SERVO_MAX_LEFT);
        }



    	//float new_value = state->LastValue +
    	//						params->Kp * (err - state->LastError) +
    	//						params->Ki * (err + state->LastError)/2;

    	float new_value = state->LastValue + (params->Kp * (err - state->LastError[1]))  +
    	    							(params->Ki * (err + state->LastError[1])/2.0) +
										(params->Kd * (err - 2.0*state->LastError[1] + state->LastError[2]));

    	float new_servo_pos = 0.0;

		// Clip
		if (line1->LeftLineVisible) {
			new_servo_pos = (SERVO_MAX_RIGHT - SERVO_CTR) * new_value + SERVO_CTR;
			new_servo_pos = fmin(new_servo_pos, SERVO_MAX_RIGHT);
		} else {
			new_servo_pos = (SERVO_MAX_LEFT - SERVO_CTR) * new_value + SERVO_CTR;
			new_servo_pos = fmax(new_servo_pos, SERVO_MAX_LEFT);
		}

		printf("Error: %.5f New Value: %.5f New Servo: %.5f \n", err, new_value, new_servo_pos);

		outputs->ServoDutyCycle = new_servo_pos;

		state->LastServoPos = new_servo_pos;
		state->LastValue = new_value;
		state->LastError[2] = state->LastError[1];
		state->LastError[1] = err;

        outputs->MotorDirection[0] = MOTOR_FORWARD;
        outputs->MotorDirection[1] = MOTOR_FORWARD;

        if (params->DiffSteering) {
			if (line1->LeftLineVisible) {
				outputs->MotorDutyCycle[0] = fmin(params->DefaultSpeed * ((1-new_value) * params->DiffSteeringFactor) , params->DefaultSpeed);
				outputs->MotorDutyCycle[1] = params->DefaultSpeed;
			} else {
				outputs->MotorDutyCycle[0] = params->DefaultSpeed;
				outputs->MotorDutyCycle[1] = fmin(params->DefaultSpeed * ((1-new_value) * params->DiffSteeringFactor), params->DefaultSpeed);
			}
    	} else {
    		outputs->MotorDutyCycle[0] = params->DefaultSpeed;
    		outputs->MotorDutyCycle[1] = params->DefaultSpeed;
    	}

		if (params->AutoSpeedControl) {
			outputs->MotorDutyCycle[0] =  outputs->MotorDutyCycle[0] - (params->AutoSpeedRange * new_value);
			outputs->MotorDutyCycle[1] = outputs->MotorDutyCycle[1] - (params->AutoSpeedRange * new_value);
		}
    } else {
        // We can't see anything! Help

        // Actually, this will probably mean we're at the 
        // 4 way cross.  Just go straight

        //outputs->ServoDutyCycle = SERVO_CTR;
    	if (state->FramesSinceLastLine > params->FrameStraightDelay)
    	{
    		outputs->ServoDutyCycle = SERVO_CTR;
    	} else {
    		outputs->ServoDutyCycle = state->LastServoPos;
    		state->FramesSinceLastLine++;
    	}


        state->LastValue = 0.0;
        state->LastError[2] = state->LastError[1];
        state->LastError[1] = 0;

        outputs->MotorDirection[0] = MOTOR_FORWARD;
        outputs->MotorDirection[1] = MOTOR_FORWARD;

        outputs->MotorDutyCycle[0] = params->DefaultSpeed;
        outputs->MotorDutyCycle[1] = params->DefaultSpeed;
    }

    return 0;
}
