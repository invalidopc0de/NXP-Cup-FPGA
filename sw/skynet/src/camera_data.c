/*
 * camera_data.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "camera_data.h"
#include "hps_0.h"
#include <string.h>

#ifdef NXP_FPGA_FIFO
int CameraDataGetLine(void* data_base, void* status_base, uint32_t* line, int maxLen)
{
    int i = 0;
    char found_start = 0;

    CAMERA_DATA_STATUS_Type* status = CAMERA_DATA_STATUS(status_base);
    CAMERA_DATA_Type* data = CAMERA_DATA(data_base);

    for (i = 0; i < maxLen; i++)
    {
    	if (found_start == 0)
    	{
    		int fill_level = status->FILL_LEVEL;
    		// Find the start of the packet
    		while (fill_level > 0) {
    			int flags = data->FLAGS;
    			if (CAMERA_SOP(flags))
    			{
    				// We found the start of the line
    				found_start = 1;
    				break;
    			}

    			line[i] = data->DATA;
    		}

    		if (found_start == 0) {	return 0; }; // Line isn't ready
    	} else {
    		// We already found the packet start
    		line[i] = data->DATA;

    		int flags = data->FLAGS;
    		if (CAMERA_EOP(flags))
    		{
    			// We found the end of the packet!
    			break;
    		}
    	}
    }

    return i+1; // The length of the packet
}

#else

void CameraDataDMAStart(mSGMDA_Bases_Type* status_base, int maxLen)
{
	mSGMDA_DESCRIPTOR_Type* descriptor_reg = (mSGMDA_DESCRIPTOR_Type*) status_base->Descriptor_ptr;

	// Start Next DMA transaction
	//descriptor_reg->read_addr = 0; // Read from camera stream
	descriptor_reg->write_addr = CAMERA_DATA_BASE; // This is cheating, it shouldn't be hardcoded
	descriptor_reg->length = maxLen;
	descriptor_reg->control = DMA_DSC_CONTROL_END_EOP_MASK;

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

#endif
