#include <stdio.h>
#include <stdint.h>

#define soc_cv_av 1

// For the event loop
#define EV_STANDALONE 1
#include "../libev/ev.c"

#include "hwlib.h"
#include "soc_cv_av/socal/socal.h"
#include "soc_cv_av/socal/hps.h"

#include "hps_0.h"
#include "line_analyzer.h"
#include "fpga_interface.h"
#include "motor_driver.h"
#include "control_loop.h"
#include "camera_control.h"
#include "camera_data.h"

#define LINE_LENGTH 169

#define LOOP_FREQ_HZ	50.0
#define LOOP_PERIOD 	(1.0/LOOP_FREQ_HZ)

typedef struct {
	void *virtual_base;
	void *motor0_base;
	void *motor1_base;
	void *servo_base;
	void *camera_control_base;
	void *camera_data_base;
	//void *camera_data_status_base;
	mSGMDA_Bases_Type camera_data_status_base;

	LineAnalyzerParams la_params;

	ControlLoopParams cl_params;
	ControlLoopState cl_state;
} SkynetState;

// Libev stuff

// Event Watchers
ev_timer control_loop_watcher;

// Event Callbacks

// Control Loop Callback
static void control_loop_cb (EV_P_ ev_timer *w, int revents)
{
	SkynetState* state = (SkynetState *) w->data;
	LineFeatures features;
	ControlLoopOutputs output;

	//puts ("Loop Fired");

	uint32_t line[LINE_LENGTH];
	memset(line, 0, LINE_LENGTH);

	int camera_len = CameraDataGetLine(state->camera_data_base, &state->camera_data_status_base, line, LINE_LENGTH);

	// Get Camera line if available
	if (camera_len > 0)
	{
		state->la_params.LineLength = camera_len;
		state->cl_params.LineLength = camera_len;

		// Analyze the line for feature
		AnalyzeLine(line, &state->la_params, &features);

		state->cl_params.lines[0] = &features;

		// Calculate new outputs
		ControlLoopCalc(&state->cl_params, &state->cl_state, &output);

		// Drive motors with new output values
		SetDutyCycle(state->motor0_base, output.MotorDutyCycle[0], output.MotorDirection[0]);
		SetDutyCycle(state->motor1_base, output.MotorDutyCycle[1], output.MotorDirection[1]);
		SetDutyCycle(state->servo_base, output.ServoDutyCycle, 1);
	}
}

int main() {

	int fd;
	SkynetState state;

	// Setup virtual base
	state.virtual_base = FPGAMapMemory(&fd);
	
	// Setup device pointers
	state.motor0_base = FPGA_MEM(state.virtual_base, MOTOR_DRIVER_A_BASE);
	state.motor1_base = FPGA_MEM(state.virtual_base, MOTOR_DRIVER_B_BASE);
	state.servo_base =  FPGA_MEM(state.virtual_base, SERVO_DRIVER_BASE);
	state.camera_control_base = FPGA_MEM(state.virtual_base, OV7670_CAMERA_0_BASE);
	state.camera_data_base = FPGA_MEM(state.virtual_base, CAMERA_DATA_BASE);
	//state.camera_data_status_base = FPGA_MEM(state.virtual_base, CAMERA_DATA_IN_CSR_BASE);
	state.camera_data_status_base.CSR_ptr = FPGA_MEM(state.virtual_base, MODULAR_SGDMA_DISPATCHER_0_CSR_BASE);
	state.camera_data_status_base.Descriptor_ptr = FPGA_MEM(state.virtual_base, MODULAR_SGDMA_DISPATCHER_0_DESCRIPTOR_SLAVE_BASE);
	state.camera_data_status_base.Response_ptr = FPGA_MEM(state.virtual_base, MODULAR_SGDMA_DISPATCHER_0_RESPONSE_SLAVE_BASE);

	SetDutyCycle(state.motor0_base, 50.0, 0);
	SetDutyCycle(state.motor1_base, 50, 0);
	SetDutyCycle(state.servo_base, 50, 0);

	state.la_params.LineThreashold = 5000;
	state.la_params.LineTimeout = 20;

	state.cl_params.Kp = 1;
	state.cl_params.Ki = 0;
	state.cl_params.Kd = 0;
	state.cl_params.StopDetectionEnabled = 0;

	// Reset Camera
	CameraReset(state.camera_control_base);

	memset(state.camera_data_base, 0, LINE_LENGTH);

	// Add camera
	CameraDataDMAStart(&state.camera_data_status_base, LINE_LENGTH);

	// use the default event loop unless you have special needs
	struct ev_loop *loop = EV_DEFAULT;

	// Assign state 
	control_loop_watcher.data = &state;

	// initialise a timer watcher, then start it
	ev_timer_init (&control_loop_watcher, control_loop_cb, 0., LOOP_PERIOD);
	ev_timer_again (loop, &control_loop_watcher);

	// now wait for events to arrive
	ev_run (loop, 0);

	// Cleanup 
	FPGAUnmapMemory(fd, state.virtual_base);

	return( 0 );
}
