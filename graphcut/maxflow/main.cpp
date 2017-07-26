using namespace std;

#include <ctime>
#include <signal.h>
#include <stdlib.h>
#include <unistd.h>
#include <execinfo.h>
#include "project.h"
#include "volume.h"
#include "graphUtils.h"
#include "RegionPushRelabel.h"

char *programName;
int width, height, depth, bytesPerPixel;
//int minS = INT_MAX, maxS = 0, maxT = 0, minN = INT_MAX, maxN = 0;


void handler(int sig) {
	size_t max_size = 100;
  void *array[max_size];
  size_t size;

  // get void*'s for all entries on the stack
  size = backtrace(array, max_size);

  // print out all the frames to stderr
  fprintf(stderr, "Error: signal %d: stack size is %d:\n", sig, size);
  backtrace_symbols_fd(array, size, STDERR_FILENO);
  exit(1);
}

int main(int argc, char *argv[])
{
	signal(SIGSEGV, handler);
	clock_t startClock, buildGraphClock, maxFlowClock, writeSegmentationClock;
	startClock = clock();
	programName = argv[0];
	if (argc < 4)
	{
		cout << "useage:" << endl;
		cout << "    " << programName << " -[t/r]i input -[t/r]o output" << endl;
	}
	VolumeGraph *g;
	/*
	if (strcmp(argv[1], "-ri") == 0)
	{
		if ((g = buildGraphFromRaw(argv[2])) == NULL)
		{
			exit(1);
		}
	} else if (strcmp(argv[1], "-ti") == 0)
	{
		cout << programName << ": tiff input not yet supported" << endl;
	} else
	{
		cout << programName << ": invalid first argument " << argv[1] << endl;
		exit(0);
	}
	buildGraphClock = clock();
	*/
	// read volume from input file
	Volume *volume;
	volume = (Volume *) malloc(sizeof(Volume));
	if (strcmp(argv[1], "-ri") == 0)
	{
		if (readRaw(volume, argv[2]))
		{
			exit(1);
		}
	} else if (strcmp(argv[1], "-ti") == 0)
	{
		cout << programName << ": tiff input not yet supported" << endl;
	} else
	{
		cout << programName << ": invalid first argument " << argv[1] << endl;
		exit(0);
	}
	// construct graph
	width = volume->width;
	height = volume->height;
	depth = volume->depth;
  long dimensions[] = {volume->width, volume->height, volume->depth};
	g = new VolumeGraph(dimensions);
	for (int z = 0; z < depth; z++)
	{
		cout << "\rbuilding graph: on slice " << z + 1 << " out of " << depth << flush;
		for (int y = 0; y < height; y++)
		{
			for (int x = 0; x < width; x++)
			{
				int id1 = getIndex(volume, x, y, z), id2;
				unsigned long intensity1 = getIntensity(volume, id1);
				int sCap = sourceCapacity(intensity1), tCap = sinkCapacity(intensity1);
				//minS = sCap < minS ? sCap : minS;
				//maxS = sCap > maxS ? sCap : maxS;
				g->add_terminal_weights(id1, sCap, tCap);
				if (x < width - 1)
				{
					id2 = id1 + 1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity, capacity);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;

				}
				if (y < height - 1)
				{
					id2 = width + id1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity, capacity);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;

				}
				if (z < depth - 1)
				{
					id2 = width * height + id1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity, capacity);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;
				}
				#ifdef TWELVE_CONNECTED
				if (x < width - 2)
				{
					id2 = id1 + 2;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / 2, capacity / 2);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;

				}
				if (y < height - 2)
				{
					id2 = 2 * width + id1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / 2, capacity / 2);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;

				}
				if (z < depth - 2)
				{
					id2 = 2 * width * height + id1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / 2, capacity / 2);
					//minN = capacity < minN ? capacity : minN;
					//maxN = capacity > maxN ? capacity : maxN;
				}
				#endif
				#ifdef EIGHTEEN_CONNECTED
				if (x < width - 1 && y < width - 1)
				{
					id2 = id1 + width + 1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				if (x < width - 1 && y > 0)
				{
					id2 = id1 - width + 1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				if (x < width - 1 && z < depth - 1)
				{
					id2 = id1 + width * height + 1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				if (x < width - 1 && z > 0)
				{
					id2 = id1 - width * height + 1;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				if (y > height - 1 && z < depth - 1)
				{
					id2 = id1 + width * height + width;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				if (y > height - 1 && z > 0)
				{
					id2 = id1 - width * height + width;
					short capacity = nLinkCapacity(intensity1, getIntensity(volume, id2));
					g->add_edge(id1, id2, capacity / sqrt(2), capacity / sqrt(2));
				}
				#endif
			}
		}
	}
	free(volume->data);
	buildGraphClock = clock();
	cout << endl << "finished building graph: took " << (buildGraphClock - startClock) / (double) CLOCKS_PER_SEC << " seconds" << endl;
	//cout << "source capacity in [" << minS << ", " << maxS << "]" << endl;
	//cout << "n links in [" << minN << ", " << maxN << "]" << endl;
	g->compute_maxflow();
	maxFlowClock = clock();
	cout << "solving maxFlow took " << (maxFlowClock - buildGraphClock) / (double) CLOCKS_PER_SEC << " seconds" << endl;
	/*
	Volume *volume = (Volume *) malloc(sizeof(Volume));
	volume->width = width;
	volume->height = height;
	volume->depth = depth;
	*/
	volume->bytesPerPixel = 1;
	mallocVolume(volume);
	int numFG = 0, numBG = 0;
	for (int i = 0; i < volume->width * volume->height * volume->depth; i++)
	{

		if (g->get_segment(i) == 0)
		{
			numFG++;
			setIntensity(volume, i, 255l);
		} else
		{
			setIntensity(volume, i, 0l);
			numBG++;
		}
	}
	if (strcmp(argv[3], "-ro") == 0)
	{
		writeRaw(volume, argv[4]);
	} else if (strcmp(argv[3], "-to") == 0)
	{
		writeTiff(volume, argv[4]);
	} else
	{
		cout << programName << ": invalid third argument: " << argv[3] << endl;
	}
	writeSegmentationClock = clock();
	cout << "numFG: " << numFG << "; numBG: " << numBG << endl;
	cout << "writing segmentation took " << (writeSegmentationClock - maxFlowClock) / (double) CLOCKS_PER_SEC << " seconds" << endl;
  delete g;
	free(volume->data);
	free(volume);
}
