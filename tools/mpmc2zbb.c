#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#ifdef _WIN32
  #include <io.h>
  #include <fcntl.h>
#endif

uint8_t bitmap[8000];
uint8_t color1[1000];
uint8_t color2[1000];

char buf[256];

enum modes
{
    M_BITMAP,
    M_COLOR1,
    M_COLOR2
};

enum modes mode = M_BITMAP;

int main(void)
{
#ifdef _WIN32
    setmode(fileno(stdout),O_BINARY);
#endif

    size_t nextidx = 0;
    while (fgets(buf, 256, stdin))
    {
	char *start = strstr(buf, ".db");
	if (!start) continue;

	start += 4;
	char *val = strtok(start, ",");
	while (val)
	{
	    uint8_t byte = (uint8_t)atoi(val);
	    switch (mode)
	    {
		case M_BITMAP:
		    bitmap[nextidx++] = byte;
		    if (nextidx == 8000)
		    {
			nextidx = 0;
			mode = M_COLOR1;
		    }
		    break;
		case M_COLOR1:
		    color1[nextidx++] = byte;
		    if (nextidx == 1000)
		    {
			nextidx = 0;
			mode = M_COLOR2;
		    }
		    break;
		case M_COLOR2:
		    if (nextidx == 1000) break;
		    color2[nextidx++] = byte;
		    break;
	    }
	    val = strtok(0, ",");
	}
    }

    for (nextidx = 0; nextidx < 8000; ++nextidx)
    {
	if (!(nextidx % 8))
	{
	    putchar(color1[nextidx >> 3]);
	    putchar(color2[nextidx >> 3]);
	}
	putchar(bitmap[nextidx]);
    }
}
