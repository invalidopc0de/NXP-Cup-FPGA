/*
 * line_analyzer.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "line_analyzer.h"

#include <stdlib.h>
#include <stdio.h>

//#define PRINT_DEBUG 1

int AnalyzeLine(uint32_t* line, LineAnalyzerParams* params, LineFeatures* features)
{
	//uint32_t sample;
	int i = 0;
	int last_edge = 0;

	if (params->PrintDebug){
		printf("%i\n\r",-1); // start value
	}

	for (i = 15; i < params->LineLength-10; i++)
	{
		if (params->PrintDebug) {
			printf("%i\n", line[i]);
		}

		int difference = line[i+params->SampleOffset] - line[i];

		if ((abs(difference) > params->LineThreashold) &&
				((i - last_edge) > params->LineTimeout)) {
			// Okay, we found an edge

			// Thoughts... should I be making sure I have the
			// largest slope, as opposed to just any slope
			// that matches the threashold?

			if ((difference > 0) && !features->LeftLineVisible) {
				// We found the left edge  __/--

				features->LeftLineVisible = 1;
				features->LeftLineLocation = i;
				last_edge = i;
				printf("Found left line at %d\n", i);

			} else if ((difference < 0) && !features->RightLineVisible) {
				// We found the right edge	--\__

				features->RightLineVisible = 1;
				features->RightLineLocation = i;
				last_edge = i;
				printf("Found right line at %d\n", i);
			}
		}
	}
	if (params->PrintDebug) {
		printf("%i\n\r",-2); // end value
	}

	return LINEANALYZER_SUCCESS;
}
