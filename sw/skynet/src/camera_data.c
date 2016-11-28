/*
 * camera_data.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "camera_data.h"

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
