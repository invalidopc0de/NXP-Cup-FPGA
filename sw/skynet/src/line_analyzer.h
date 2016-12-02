/*
 * line_analyzer.h
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#ifndef SRC_LINE_ANALYZER_H_
#define SRC_LINE_ANALYZER_H_

#include <stdint.h>
#include <stdio.h>

#define LINEANALYZER_SUCCESS	0
#define LINEANALYZER_ERROR 		-1

typedef struct {
	int LineThreashold;
	int LineLength;
	int LineTimeout;
	int SampleOffset;

	char StopDetectionEnabled;

	char PrintDebug;
	char PrintLineDebug;

	int StartOffset;
	int EndOffset;
	int PointDiff;

	char GNUPlotEnabled;
	char GNUPlotFileName[1024];
	FILE* GNUPlotFile;
} LineAnalyzerParams;

typedef struct {
    int LastLinePos;    //0 for left, 1 for right
} LineAnalyzerState;

typedef struct {
	char LeftLineVisible;
	int LeftLineLocation;

	char RightLineVisible;
	int RightLineLocation;

	char StopLineVisible;
} LineFeatures;

int LineAnalyzerInit(LineAnalyzerParams* params);

int AnalyzeLine(uint32_t* line, LineAnalyzerParams* params, LineAnalyzerState* lineState, LineFeatures* features);

#endif /* SRC_LINE_ANALYZER_H_ */
