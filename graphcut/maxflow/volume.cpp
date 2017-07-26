#include "project.h"
#include "volume.h"

int getIndex(Volume *volume, int x, int y, int z)
{
  return z * volume->width * volume->height + y * volume->width + x;
}

unsigned long getIntensity(Volume *volume, int x, int y, int z)
{
  return getIntensity(volume, getIndex(volume, x, y, z));
}

unsigned long getIntensity(Volume *volume, int index)
{
  switch (volume->bytesPerPixel)
  {
    case 1:
      return ((uint8_t *) volume->data)[index];
    case 2:
      return ((uint16_t *) volume->data)[index];
    case 4:
      return ((uint32_t *) volume->data)[index];
    case 8:
      return ((uint64_t *) volume->data)[index];
  }
  // should never get to here
  return 0;
}

void setIntensity(Volume *volume, int x, int y, int z, unsigned long intensity)
{
  setIntensity(volume, getIndex(volume, x, y, z), intensity);
}

void setIntensity(Volume *volume, int index, unsigned long intensity)
{
  switch (volume->bytesPerPixel)
  {
    case 1:
      ((uint8_t *) (volume->data))[index] = intensity;
      break;
    case 2:
      ((uint16_t *) (volume->data))[index] = intensity;
      break;
    case 4:
      ((uint32_t *) (volume->data))[index] = intensity;
      break;
    case 8:
      ((uint64_t *) (volume->data))[index] = intensity;
      break;
  }
}

void mallocVolume(Volume *volume)
{
  volume->data = (unsigned char *) malloc(volume->width * volume->height * volume->depth * volume->bytesPerPixel);
}

unsigned long maxIntensity(Volume *volume)
{
  int x, y, z;
  unsigned long max = getIntensity(volume, 0, 0, 0);
  for (z = 0; z < volume->depth; z++)
  {
    for (y = 0; y < volume->height; y++)
    {
      for (x = 0; x < volume->width; x++)
      {
        unsigned long val = getIntensity(volume, x, y, z);
        if (val > max)
        {
          max = val;
        }
      }
    }
  }
  return max;
}

unsigned long minIntensity(Volume *volume)
{
  int x, y, z;
  unsigned long min = getIntensity(volume, 0, 0, 0);
  for (z = 0; z < volume->depth; z++)
  {
    for (y = 0; y < volume->height; y++)
    {
      for (x = 0; x < volume->width; x++)
      {
        unsigned long val = getIntensity(volume, x, y, z);
        if (val < min)
        {
          min = val;
        }
      }
    }
  }
  return min;
}

void printVolume(Volume *volume)
{
  int x, y, z;
  for (z = 0; z < volume->depth; z++)
  {
    printf("SLICE %d\n", z);
    for (y = 0; y < volume->height; y++)
    {
      for (x = 0; x < volume->width; x++)
      {
        printf("%02lx ", getIntensity(volume, x, y, z));
      }
      printf("\n");
    }
  }
}

/**
 * Reads the given RAW file into the given volume. volume->data is malloced and
 * should be freed when done. fileName should not have an extension, as the RAW
 * and TXT extensions will be added onto it.
 */
int readRaw(Volume *volume, char *fileName)
{
  int len = strlen(fileName);
  char fileNameExt[len + 5];
  strcpy(fileNameExt, fileName);
  strcpy(fileNameExt + len, ".txt");
  FILE *f = fopen(fileNameExt, "r");
  if (f == NULL)
  {
    fprintf(stderr, "%s: unable to open file %s: %s\n", programName, fileNameExt, strerror(errno));
    return -1;
  }
  if (fscanf(f, "%dx%dx%d\n", &((*volume).width), &((*volume).height), &((*volume).depth)) != 3)
  {
    fprintf(stderr, "%s: invalid first line of %s\n", programName, fileNameExt);
    return -1;
  }
  if (fscanf(f, "%d\n", &((*volume).bytesPerPixel)) != 1)
  {
    fprintf(stderr, "%s: invalid second line of %s\n", programName, fileNameExt);
    return -1;
  }
  int scaleX, scaleY, scaleZ;
  if (fscanf(f, "scale: %d:%d:%d", &scaleX, &scaleY, &scaleZ) != 3)
  {
    fprintf(stderr, "%s: invalid third line of %s\n", programName, fileNameExt);
    return -1;
  }
  if (fclose(f))
  {
    fprintf(stderr, "%s: unable to close file %s: %s\n", programName, fileNameExt, strerror(errno));
    return -1;
  }
  printf("dealing with a %dx%dx%d volume with %d bytes per pixel\n", (*volume).width, (*volume).height, (*volume).depth, (*volume).bytesPerPixel);
  mallocVolume(volume);
  strcpy(fileNameExt + len, ".raw");
  f = fopen(fileNameExt, "r");
  fread((*volume).data, (*volume).bytesPerPixel, (*volume).width * (*volume).height * (*volume).depth, f);
  if (ferror(f))
  {
    fprintf(stderr, "%s: error reading from file %s: %s\n", programName, fileNameExt, strerror(ferror(f)));
    return -1;
  }
  fclose(f);
  return 0;
}

/**
 * Writes the given volume to the given RAW file. fileName should not have an
 * extension, as the RAW and TXT extensions will be added onto it.
 */
int writeRaw(Volume *volume, char *fileName)
{
  int len = strlen(fileName);
  char fileNameExt[len + 5];
  strcpy(fileNameExt, fileName);
  strcpy(fileNameExt + len, ".txt");
  FILE *f = fopen(fileNameExt, "w");
  if (f == NULL)
  {
    fprintf(stderr, "%s: unable to open file %s: %s\n", programName, fileNameExt, strerror(errno));
    return -1;
  }
  fprintf(f, "%dx%dx%d\n", volume->width, volume->height, volume->depth);
  fprintf(f, "%d\n", volume->bytesPerPixel);
  fprintf(f, "scale: 1:1:1\n");
  if (ferror(f))
  {
    fprintf(stderr, "%s: error writing to file %s: %s\n", programName, fileNameExt, strerror(ferror(f)));
    return -1;
  }
  fclose(f);
  strcpy(fileNameExt + len, ".raw");
  f = fopen(fileNameExt, "w");
  if (f == NULL)
  {
    fprintf(stderr, "%s: unable to open file %s: %s\n", programName, fileNameExt, strerror(errno));
    return -1;
  }
  fwrite(volume->data, volume->bytesPerPixel, volume->width * volume->height * volume->depth, f);
  if (ferror(f))
  {
    fprintf(stderr, "%s: error writing to file %s: %s\n", programName, fileNameExt, strerror(ferror(f)));
    return -1;
  }
  fclose(f);
  return 0;
}

/**
 * Writes the given volume to the given tiff directory, creating it if the
 * durectory doesn't already exist. Returns 0 on success, -1 on error.
 */
int writeTiff(Volume *volume, char *dirName)
{
  // if the directory doesn't exist, make it
  struct stat st = {0};
  if (stat(dirName, &st) == -1)
  {
      if (mkdir(dirName, 0700) != 0)
      {
        fprintf(stderr, "%s: unable to create directory %s: %s\n", programName, dirName, strerror(errno));
        return -1;
      }
  }
  int numberLength = (int) ceil(log(volume->depth) / log(10));
  char fileName[strlen(dirName) + 2 + numberLength + 5];
  TIFF *tif;
  int z, y;
  unsigned char *data = (unsigned char *) volume->data;
  unsigned char *buf = (unsigned char *) _TIFFmalloc(volume->width);
  char formatString[] = "%s/z%0_d.tif";
  formatString[6] = numberLength + '0';
  for (z = 0; z < volume->depth; z++)
  {
    sprintf(fileName, formatString, dirName, z);
    if ((tif = TIFFOpen(fileName, "w")) == NULL)
    {
      fprintf(stderr, "%s: unable to open file %s\n", programName, fileName);
      return -1;
    }
    TIFFSetField(tif, TIFFTAG_IMAGEWIDTH, volume->width);
    TIFFSetField(tif, TIFFTAG_IMAGELENGTH, volume->height);
    TIFFSetField(tif, TIFFTAG_SAMPLESPERPIXEL, 1);
    TIFFSetField(tif, TIFFTAG_BITSPERSAMPLE, 8);
    TIFFSetField(tif, TIFFTAG_ORIENTATION, ORIENTATION_TOPLEFT);
    TIFFSetField(tif, TIFFTAG_ROWSPERSTRIP, 1);
    for (y = 0; y < volume->height; y++)
    {
      memcpy(buf, data, volume->width);
      data += volume->width;
      if (TIFFWriteScanline(tif, buf, y, 0) != 1)
      {
        fprintf(stderr, "%s: error writing to %s\n", programName, fileName);
        TIFFClose(tif);
        _TIFFfree(buf);
        return -1;
      }
    }
    TIFFClose(tif);
  }
  _TIFFfree(buf);
  return 0;
}
