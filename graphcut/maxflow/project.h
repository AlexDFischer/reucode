#include <stdio.h>
#include <iostream>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <dirent.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <math.h>
#include "RegionPushRelabel.h"

extern char *programName;
extern int width, height, depth, bytesPerPixel;

#define THREADS_PER_BLOCK (1024)
#define NUM_BLOCKS (1)

#define MAX_INTENSITY (4095l)

#define CONNECTED_TYPE EighteenConnected
#define EIGHTEEN_CONNECTED 1

typedef Array<
	Arc<0, 0, Offsets< 1,  0,  0> >,
	Arc<0, 0, Offsets<-1,  0,  0> >,
	Arc<0, 0, Offsets< 0,  1,  0> >,
	Arc<0, 0, Offsets< 0, -1,  0> >,
  Arc<0, 0, Offsets< 0,  0,  1> >,
  Arc<0, 0, Offsets< 0,  0, -1> >
> SixConnected;

typedef Array<
	Arc<0, 0, Offsets< 1,  0,  0> >,
	Arc<0, 0, Offsets<-1,  0,  0> >,
	Arc<0, 0, Offsets< 0,  1,  0> >,
	Arc<0, 0, Offsets< 0, -1,  0> >,
  Arc<0, 0, Offsets< 0,  0,  1> >,
  Arc<0, 0, Offsets< 0,  0, -1> >,

	Arc<0, 0, Offsets< 1,  1,  0> >,
	Arc<0, 0, Offsets< 1, -1,  0> >,
	Arc<0, 0, Offsets<-1,  1,  0> >,
	Arc<0, 0, Offsets<-1, -1,  0> >,
  Arc<0, 0, Offsets< 1,  0,  1> >,
  Arc<0, 0, Offsets<-1,  0,  1> >,
  Arc<0, 0, Offsets< 0,  1,  1> >,
  Arc<0, 0, Offsets< 0, -1,  1> >,
  Arc<0, 0, Offsets< 1,  0, -1> >,
  Arc<0, 0, Offsets<-1,  0, -1> >,
  Arc<0, 0, Offsets< 0,  1, -1> >,
  Arc<0, 0, Offsets< 0, -1, -1> >
> EighteenConnected;

typedef Array<
	Arc<0, 0, Offsets< 1,  0,  0> >,
	Arc<0, 0, Offsets<-1,  0,  0> >,
	Arc<0, 0, Offsets< 0,  1,  0> >,
	Arc<0, 0, Offsets< 0, -1,  0> >,
	Arc<0, 0, Offsets< 0,  0,  1> >,
	Arc<0, 0, Offsets< 0,  0, -1> >,

	Arc<0, 0, Offsets< 2,  0,  0> >,
	Arc<0, 0, Offsets<-2,  0,  0> >,
	Arc<0, 0, Offsets< 0,  2,  0> >,
	Arc<0, 0, Offsets< 0, -2,  0> >,
	Arc<0, 0, Offsets< 0,  0,  2> >,
	Arc<0, 0, Offsets< 0,  0, -2> >
> TwelveConnected;

typedef Array<
	Arc<0, 0, Offsets< 1, 0,  0> >,
	Arc<0, 0, Offsets< 1, 0,  1> >,
	Arc<0, 0, Offsets< 1, 0, -1> >,
	Arc<0, 0, Offsets< 1, 1,  0> >,
	Arc<0, 0, Offsets< 1, 1,  1> >,
	Arc<0, 0, Offsets< 1, 1, -1> >,
	Arc<0, 0, Offsets< 1,-1,  0> >,
	Arc<0, 0, Offsets< 1,-1,  1> >,
	Arc<0, 0, Offsets< 1,-1, -1> >,

	Arc<0, 0, Offsets<-1, 0,  0> >,
	Arc<0, 0, Offsets<-1, 0,  1> >,
	Arc<0, 0, Offsets<-1, 0, -1> >,
	Arc<0, 0, Offsets<-1, 1,  0> >,
	Arc<0, 0, Offsets<-1, 1,  1> >,
	Arc<0, 0, Offsets<-1, 1, -1> >,
	Arc<0, 0, Offsets<-1,-1,  0> >,
	Arc<0, 0, Offsets<-1,-1,  1> >,
	Arc<0, 0, Offsets<-1,-1, -1> >,

	Arc<0, 0, Offsets< 0, 0,  1> >,
	Arc<0, 0, Offsets< 0, 0, -1> >,
	Arc<0, 0, Offsets< 0, 1,  0> >,
	Arc<0, 0, Offsets< 0, 1,  1> >,
	Arc<0, 0, Offsets< 0, 1, -1> >,
	Arc<0, 0, Offsets< 0,-1,  0> >,
	Arc<0, 0, Offsets< 0,-1,  1> >,
	Arc<0, 0, Offsets< 0,-1, -1> >
> TwentysixConnected;

typedef RegionPushRelabel<
	int, int,               // Capacity Type, Flow Type
	Layout<
		CONNECTED_TYPE,
		BlockDimensions<16, 16, 16>
	>,
	ThreadCount<10>
	//MaxBlocksPerRegion<6>
> VolumeGraph;
