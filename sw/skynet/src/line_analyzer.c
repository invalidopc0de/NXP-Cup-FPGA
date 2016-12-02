/*
 * line_analyzer.c
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#include "line_analyzer.h"

#include <stdlib.h>
#include <stdio.h>

int LineAnalyzerInit(LineAnalyzerParams* params)
{
	if (params->GNUPlotEnabled) {
		FILE * fp;
		fp = fopen (params->GNUPlotFileName, "w+");


		if (fp == NULL)
		{
			printf("Unable to open GNU plot file! %s\n", params->GNUPlotFileName);
			return -1;
		}

		params->GNUPlotFile = fp;
	}
	return 0;
}

int AnalyzeLine(uint32_t* line, LineAnalyzerParams* params, LineFeatures* features)
{
	//uint32_t sample;
	int i = 0;
	//value at the last edge
	int last_edge_val = 0;
	//shift register of points with maximum difference
	int edge_points[2] = {-1,-1}; //--------------------------------------------------------
	//difference between resulting points from the edge finder
	int point_diff = 0;

	if (params->PrintDebug){
		printf("%i\n\r",-1); // start value
	}

	if (params->GNUPlotEnabled)
	{
		rewind(params->GNUPlotFile);
	}


	for (i = params->StartOffset; i < params->LineLength - params->EndOffset; i++)
	{
		if (params->PrintDebug) {
			printf("%i\n", line[i]);
		}

		if (params->GNUPlotEnabled) {
			fprintf(params->GNUPlotFile, "%i %i\n",i, line[i]);
		}

		// TODO: Sample offset?-------------------------------------------------------------------
		int difference = line[i+params->SampleOffset] - line[i];

		if ((abs(difference) > last_edge_val)) {
			// Okay, we found an edge
			//shift right
			edge_points[1] = edge_points[0];
			edge_points[0] = i;
			//set new max value
			last_edge_val = abs(difference);

		}
	}
	
	//make sure we have edges
	if (edge_points[1] > params->LineThreashold){
		point_diff = edge_points[0]-edge_points[1];
		if (point_diff > params->PointDiff) {
			// We have two different edges
			features->RightLineVisible = 1;
			features->LeftLineVisible = 1;
			//Left edge in 1
			if (edge_points[0] > params->LineLength/2){
				features->RightLineLocation = edge_points[1];
				features->LeftLineLocation = edge_points[0];
	
				if (params->PrintLineDebug) {
					printf("Found right line at %d\n", edge_points[1]);
					printf("Found left line at %d\n", edge_points[0]);
				}
			}
			else{
				features->RightLineLocation = edge_points[0];
				features->LeftLineLocation = edge_points[1];
	
				if (params->PrintLineDebug) {
					printf("Found right line at %d\n", edge_points[0]);
					printf("Found left line at %d\n", edge_points[1]);
				}
			}
		} else {
			// We have one edge, use edge_points[1]
			//Right edge
			if (edge_points[1] > params->LineLength/2){
				features->LeftLineVisible = 0;
				features->RightLineVisible = 1;
				features->RightLineLocation = edge_points[1];
	
				if (params->PrintLineDebug) {
					printf("Found right line at %d\n", edge_points[1]);
				}
			}
			//Left edge
			else{
				features->RightLineVisible = 0;
				features->LeftLineVisible = 1;
				features->LeftLineLocation = edge_points[1];
	
				if (params->PrintLineDebug) {
					printf("Found left line at %d\n", edge_points[1]);
				}
			}
		}
	}
	//Oh no no edges!
	else{
		features->LeftLineVisible = 0;
		features->RightLineVisible = 0;
	}

	if (params->PrintDebug) {
		printf("%i\n\r",-2); // end value
	}

	return LINEANALYZER_SUCCESS;
}
