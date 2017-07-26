#!/bin/python
import sys
from PIL import Image
import numpy as np

maxintensity = 4095
numbuckets = 20;
numFG = 3863*789*3
numBG = 0
histogram = np.zeros((2, numbuckets))

numchannels = 7

for z in range(49, 52):
    scanimage = Image.open("/home/alex/axondata/injured01original/CNTF_6wpc_OpticNerve_10337_z%04d.tif" % z)
    scanarray = np.array(scanimage)
    gt = np.empty((numchannels, scanarray.shape[0], scanarray.shape[1]), dtype = np.uint8)
    for channel in range(0, numchannels):
        gt[channel] = np.array(Image.open("/home/alex/axondata/injured01gt/_z%03d_c%03d.tif" % (z + 1, channel + 1)))
    for y in range(0, scanarray.shape[0]):
        for x in range(0, scanarray.shape[1]):
            bucket = scanarray[y][x] * 20 / (maxintensity + 1)
            inBG = 1
            for channel in range(0, numchannels):
                inBG &= gt[channel][y][x] >> 7
            numBG += inBG
            numFG -= inBG
            histogram[inBG][bucket] += 1
    print "done with image %d" % z
for bucket in range(0, numbuckets):
    print "P(I = %02d|FG) = %08d / %09d" % (bucket, histogram[0, bucket], numFG)
for bucket in range(0, numbuckets):
    print "P(I = %02d|BG) = %08d / %09d" % (bucket, histogram[1, bucket], numBG)
