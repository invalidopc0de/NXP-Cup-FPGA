#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <stdio.h>

#define soc_cv_av 1

// For the event loop
#define EV_STANDALONE 1
#include "../libev/ev.c"

// For JSON config
#include "../cJSON/cJSON.h"

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

#define LINE_LENGTH 173

#define LOOP_FREQ_HZ	50.0
#define LOOP_PERIOD 	(1.0/LOOP_FREQ_HZ)

#define CONFIG_BUFF_MAX_LEN	1024*10 // 10kBytes

#define KILLSW_MASK		(1 << 3)

typedef struct {
	void *virtual_base;
	void *motor0_base;
	void *motor1_base;
	void *servo_base;
	void *camera_control_base;
	void *camera_data_base;
	void *dipsw_base;
	//void *camera_data_status_base;
	mSGMDA_Bases_Type camera_data_status_base;

	LineAnalyzerParams la_params;

	ControlLoopParams cl_params;
	ControlLoopState cl_state;

	char camera_config_file[1024];
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

	memset(&features, 0, sizeof(LineFeatures));
	memset(&output, 0, sizeof(ControlLoopOutputs));

	int camera_len = CameraDataGetLine(state->camera_data_base, &state->camera_data_status_base, line, LINE_LENGTH);

	// Get Camera line if available
	if (camera_len > 0)
	{
		state->la_params.LineLength = camera_len;
		state->cl_params.LineLength = camera_len;

		// Analyze the line for feature
		AnalyzeLine(line, &state->la_params, &features);

		state->cl_params.lines[0] = &features;


		if (*((uint32_t *)state->dipsw_base) & KILLSW_MASK){
			// Calculate new outputs
			ControlLoopCalc(&state->cl_params, &state->cl_state, &output);
		} else {
			output.ServoDutyCycle = SERVO_CTR;
		}


		// Drive motors with new output values
		SetDutyCycle(state->motor0_base, output.MotorDutyCycle[0], output.MotorDirection[0]);
		SetDutyCycle(state->motor1_base, output.MotorDutyCycle[1], output.MotorDirection[1]);
		SetDutyCycle(state->servo_base, output.ServoDutyCycle, 1);
	}
}

// Config handling
int readConfig(char *filename, SkynetState* state)
{
	int fd = -1;
	int len = 0;
	char *buffer;

	// Open file
	fd = open(filename, O_RDONLY);
	if (fd < 0)
	{
		printf("Unable to open file! %s\n", filename);
		return -1;
	}

	// Read file into buffer
	buffer = malloc(CONFIG_BUFF_MAX_LEN);
	if (buffer == NULL)
	{
		printf("Error allocating config buffer!\n");
		return -1;
	}

	len = read(fd, buffer, CONFIG_BUFF_MAX_LEN);
	buffer[len] = '\0';

	// Parse file
	cJSON * root = cJSON_Parse(buffer);

	// Pull out interesting configs
	strncpy(state->camera_config_file, cJSON_GetObjectItem(root, "camera_config")->valuestring, 1024);

	cJSON *la_config = cJSON_GetObjectItem(root, "line_analyzer");
	state->la_params.LineThreashold = cJSON_GetObjectItem(la_config, "LineThreshold")->valueint;
	state->la_params.LineTimeout = cJSON_GetObjectItem(la_config, "LineTimeout")->valueint;
	state->la_params.StopDetectionEnabled = cJSON_GetObjectItem(la_config, "StopDetectionEnabled")->valueint;
	state->la_params.PrintDebug = cJSON_GetObjectItem(la_config, "PrintDebug")->valueint;
	state->la_params.PrintLineDebug = cJSON_GetObjectItem(la_config, "PrintLineDebug")->valueint;
	state->la_params.SampleOffset = cJSON_GetObjectItem(la_config, "SampleOffset")->valueint;
	state->la_params.StartOffset = cJSON_GetObjectItem(la_config, "StartOffset")->valueint;
	state->la_params.EndOffset = cJSON_GetObjectItem(la_config, "EndOffset")->valueint;
	state->la_params.GNUPlotEnabled = cJSON_GetObjectItem(la_config, "GNUPlotEnabled")->valueint;
	strncpy(state->la_params.GNUPlotFileName, cJSON_GetObjectItem(la_config, "GNUPlotFile")->valuestring, 1024);
	state->la_params.PointDiff = cJSON_GetObjectItem(la_config, "PointDiff")->valueint;

	cJSON *cl_config = cJSON_GetObjectItem(root, "control_loop");
	state->cl_params.Kp = cJSON_GetObjectItem(cl_config, "Kp")->valuedouble;
	state->cl_params.Ki = cJSON_GetObjectItem(cl_config, "Ki")->valuedouble;
	state->cl_params.Kd = cJSON_GetObjectItem(cl_config, "Kd")->valuedouble;
	state->cl_params.StopDetectionEnabled = cJSON_GetObjectItem(cl_config, "StopDetectionEnabled")->valueint;
	state->cl_params.DefaultSpeed = cJSON_GetObjectItem(cl_config, "DefaultSpeed")->valueint;

	cJSON_Delete(root);

	free(buffer);

	return 0;
}

int main(int argc, char *argv[]) {

	int fd;
	SkynetState state;

	memset(&state, 0, sizeof(SkynetState));

	if (argc != 2) {
		printf("Please specify a config file!\n");
		return -1;
	}

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
	state.dipsw_base = FPGA_MEM(state.virtual_base, DIPSW_PIO_BASE);

	SetDutyCycle(state.servo_base, SERVO_CTR, 0);
	SetDutyCycle(state.motor0_base, 40.0, 0);
	SetDutyCycle(state.motor1_base, 40.0, 0);

	// Load config
	if (readConfig(argv[1], &state) < 0)
	{
		printf("Error reading config!\n");
		return -1;
	}

	if (LineAnalyzerInit(&state.la_params) < 0)
	{
		printf("Error initializing line analyzer\n");
		return -2;
	}

	// Reset Camera
	if (CameraLoadConfig(state.camera_control_base, state.camera_config_file) < 0)
	{
		printf("Error loading camera config!\n");
		return -3;
	}

	// Clear camera data
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
