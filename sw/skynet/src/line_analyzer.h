/*
 * line_analyzer.h
 *
 *  Created on: Nov 23, 2016
 *      Author: Mark
 */

#ifndef SRC_LINE_ANALYZER_H_
#define SRC_LINE_ANALYZER_H_

#include <stdint.h>

#define LINEANALYZER_SUCCESS	0
#define LINEANALYZER_ERROR 		-1

typedef struct {
	int LineThreashold;
	int LineLength;
	int LineTimeout;
	int SampleOffset;

	char StopDetectionEnabled;

	char PrintDebug;
} LineAnalyzerParams;

typedef struct {
	char LeftLineVisible;
	int LeftLineLocation;

	char RightLineVisible;
	int RightLineLocation;

	char StopLineVisible;
} LineFeatures;

int AnalyzeLine(uint32_t* line, LineAnalyzerParams* params, LineFeatures* features);

#endif /* SRC_LINE_ANALYZER_H_ */
