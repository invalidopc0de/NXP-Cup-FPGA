/*
 * camera_data.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "camera_data.h"
#include "hps_0.h"
#include <string.h>
#include <stdio.h>


void CameraDataDMAStart(mSGMDA_Bases_Type* status_base, int maxLen)
{
	mSGMDA_DESCRIPTOR_Type* descriptor_reg = (mSGMDA_DESCRIPTOR_Type*) status_base->Descriptor_ptr;

	// Start Next DMA transaction
	//descriptor_reg->read_addr = 0; // Read from camera stream
	descriptor_reg->write_addr = CAMERA_DATA_BASE; // This is cheating, it shouldn't be hardcoded here
	descriptor_reg->length = maxLen;
	descriptor_reg->control = DMA_DSC_CONTROL_END_EOP_MASK;
	descriptor_reg->control |= DMA_DSC_CONTROL_EARLY_DONE_MASK;

	// Lets GOOOOO
	descriptor_reg->control |= DMA_DSC_CONTROL_GO_MASK;
}

int CameraDataGetLine(void* data_base, mSGMDA_Bases_Type* status_base, uint32_t* line, int maxLen)
{
	mSGDMA_RESPONSE_Type response;
	mSGDMA_CSR_Type* csr = (mSGDMA_CSR_Type *) status_base->CSR_ptr;

	// Check if we have a response
	if (csr->status & DMA_CSR_STATUS_RESPONSE_BUFF_EMPTY_MASK)
	{
		// Response buffer is empty right now

		if (!(csr->status & DMA_CSR_STAUTS_BUSY_MASK))
		{
			// If we're not busy, kick off another DMA transfer while we're waiting
			CameraDataDMAStart(status_base, maxLen);
		}
		return 0;
	}

	response.bytes_transfered = ((uint32_t *)status_base->Response_ptr)[0];
	response.flags = ((uint32_t *)status_base->Response_ptr)[1];

	if (response.flags & DMA_RESPONSE_EARLY_TERMINATION_MASK)
	{
		printf("Early termination!\n");
	}

	// Pick the smaller of the two buffers
	int len = (response.bytes_transfered > maxLen) ? maxLen : response.bytes_transfered;

	// Copy Data into buffer

	// Our values are coming in as 8-bit for now... this will need to be fixed
	int i = 0;
	for (i = 0; i < len; i++)
	{
		line[i] = ((char* )data_base)[i];
	}
	//memcpy(line, data_base, len);

	// Start next DMA transfer
	CameraDataDMAStart(status_base, maxLen);

	// Return number of bytes read
	return len;
}

