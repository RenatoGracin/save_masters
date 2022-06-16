#ifndef FUNC_H
#define FUNC_H

#define DIM_NUM 3

#define dataSize 400

#define crosPointNumber 100

#define maxdist 1024
#define maxClust 400
#define simMatrixSize 20

#define mergingConst 0.7f

void quicksort(float number[],int first,int last);

int getNeighbors ( float eps, int pointIndex, float distances[]);

float calcCoreDist ( int pointIndx, int neighCount, int Nmin, float distances[]);

void sortDistances(float distances[], int size);

int getUnproces (void);

int update ( int neighCount, int seedNum, int pointIndx,  int change, float distances[]);

void sortSeeds( int seedNum);

void optics ( float eps, int Nmin );



float gradientDet(float x_r, float y_r, float z_r, float w);

float inflectionIndex(float x_r, float y_r, float z_r, float w);

float vectAbs(float rx, float ry, float w);

int gradientClustering( int Nmin, float t, float w, float largeClustPerc, float mergePerc, int minMax);

void getClusterIndices(int clustNum);



int opticsMerging( int clustNum,  int iter, int newClustIndex);

void featureExtraction( int clustNum, float timeStampEnd, float timeStampStart, int Nmin );
	
#endif
