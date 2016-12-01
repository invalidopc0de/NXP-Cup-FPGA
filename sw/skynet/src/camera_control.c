/*
 * camera_control.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "camera_control.h"
#include <unistd.h>

#define DELAY_US	3000
#define CONFIG_BUFF_MAX_LEN	1024*10 // 10kBytes

void CameraSetReg(void *base, uint32_t value)
{
	// Value is in format <reg[15:8]><val[7:0]>
	CAMERA_CONTROL(base)->CONFIG = value;
	usleep(DELAY_US);
}

void AppNoteRegs(void *base)
{
	// Reset the camera
	CameraSetReg(base, 0x1280); // COM7 Reset
	CameraSetReg(base, 0x1280); // COM7 Reset

	// QCIF Config
	CameraSetReg(base, 0x1101); // CLKRC
	CameraSetReg(base, 0x1200); // COM7
	CameraSetReg(base, 0x0c0c); // COM3
	CameraSetReg(base, 0x3e11); // COM14
	CameraSetReg(base, 0x703a); // SCALING_XSC
	CameraSetReg(base, 0x7135); // SCALING_YSC
	CameraSetReg(base, 0x7211); // SCALING_DCWCTR
	CameraSetReg(base, 0x73F1); // SCALING_PCLK_DIV
	CameraSetReg(base, 0xA252); // SCALING_PCLK_DELAY

	// Exposure
	CameraSetReg(base, 0x1438); // COM9  - AGC Celling
	CameraSetReg(base, 0x3dc0); // COM13 - Turn on GAMMA and UV Auto adjust
	CameraSetReg(base, 0x1e20); // Mirror Image
}

void ZedBoard_Fr_Regs(void *base)
{
	CameraSetReg(base, 0x1280); // COM7   Reset
	CameraSetReg(base, 0x1280); // COM7   Reset
	CameraSetReg(base, 0x1204); // COM7   Size & RGB output
	CameraSetReg(base, 0x1100); // CLKRC  Prescaler - Fin/(1+1)
	CameraSetReg(base, 0x0C00); // COM3   Lots of stuff, enable scaling, all others off
	CameraSetReg(base, 0x3E00); // COM14  PCLK scaling off

	CameraSetReg(base, 0x8C00); // RGB444 Set RGB format
	CameraSetReg(base, 0x0400); // COM1   no CCIR601
	CameraSetReg(base, 0x4010); // COM15  Full 0-255 output, RGB 565
	CameraSetReg(base, 0x3a04); // TSLB   Set UV ordering,  do not auto-reset window
	CameraSetReg(base, 0x1438); // COM9  - AGC Celling
	CameraSetReg(base, 0x4f40); //x"4fb3"; // MTX1  - colour conversion matrix
	CameraSetReg(base, 0x5034); //x"50b3"; // MTX2  - colour conversion matrix
	CameraSetReg(base, 0x510C); //x"5100"; // MTX3  - colour conversion matrix
	CameraSetReg(base, 0x5217); //x"523d"; // MTX4  - colour conversion matrix
	CameraSetReg(base, 0x5329); //x"53a7"; // MTX5  - colour conversion matrix
	CameraSetReg(base, 0x5440); //x"54e4"; // MTX6  - colour conversion matrix
	CameraSetReg(base, 0x581e); //x"589e"; // MTXS  - Matrix sign and auto contrast
	CameraSetReg(base, 0x3dc0); // COM13 - Turn on GAMMA and UV Auto adjust
	CameraSetReg(base, 0x1100); // CLKRC  Prescaler - Fin/(1+1)

	CameraSetReg(base, 0x1711); // HSTART HREF start (high 8 bits)
	CameraSetReg(base, 0x1861); // HSTOP  HREF stop (high 8 bits)
	CameraSetReg(base, 0x32A4); // HREF   Edge offset and low 3 bits of HSTART and HSTOP

	CameraSetReg(base, 0x1903); // VSTART VSYNC start (high 8 bits)
	CameraSetReg(base, 0x1A7b); // VSTOP  VSYNC stop (high 8 bits)
	CameraSetReg(base, 0x030a); // VREF   VSYNC low two bits

	CameraSetReg(base, 0x0e61); // COM5(0x0E) 0x61
	CameraSetReg(base, 0x0f4b); // COM6(0x0F) 0x4B

	CameraSetReg(base, 0x1602); //
	CameraSetReg(base, 0x1e37); // MVFP (0x1E) 0x07  // FLIP AND MIRROR IMAGE 0x3x

	CameraSetReg(base, 0x2102);
	CameraSetReg(base, 0x2291);

	CameraSetReg(base, 0x2907);
	CameraSetReg(base, 0x330b);

	CameraSetReg(base, 0x350b);
	CameraSetReg(base, 0x371d);

	CameraSetReg(base, 0x3871);
	CameraSetReg(base, 0x392a);

	CameraSetReg(base, 0x3c78); // COM12 (0x3C) 0x78
	CameraSetReg(base, 0x4d40);

	CameraSetReg(base, 0x4e20);
	CameraSetReg(base, 0x6900); // GFIX (0x69) 0x00

	CameraSetReg(base, 0x6b4a);
	CameraSetReg(base, 0x7410);

	CameraSetReg(base, 0x8d4f);
	CameraSetReg(base, 0x8e00);

	CameraSetReg(base, 0x8f00);
	CameraSetReg(base, 0x9000);

	CameraSetReg(base, 0x9100);
	CameraSetReg(base, 0x9600);

	CameraSetReg(base, 0x9a00);
	CameraSetReg(base, 0xb084);

	CameraSetReg(base, 0xb10c);
	CameraSetReg(base, 0xb20e);

	CameraSetReg(base, 0xb382);
	CameraSetReg(base, 0xb80a);
}

int CameraReset(void* base)
{
	//ZedBoard_Fr_Regs(base);
	AppNoteRegs(base);

	return 0;
}


int CameraLoadConfig(void* base, char* filename)
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
		cJSON *la_config = cJSON_GetObjectItem(root, "line_analyzer");
		state->la_params.LineThreashold = cJSON_GetObjectItem(la_config, "LineThreshold")->valueint;
		state->la_params.LineTimeout = cJSON_GetObjectItem(la_config, "LineTimeout")->valueint;
		state->la_params.StopDetectionEnabled = cJSON_GetObjectItem(la_config, "StopDetectionEnabled")->valueint;
		state->la_params.PrintDebug = cJSON_GetObjectItem(la_config, "PrintDebug")->valueint;
		state->la_params.SampleOffset = cJSON_GetObjectItem(la_config, "SampleOffset")->valueint;

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
