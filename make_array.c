#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char* argv[])
{
	FILE* fd;
	ssize_t i, l;
	uint32_t value, index;
	uint8_t buffer[24];
	index = 0;
	if (argc !=2)
	{
		printf("usage: make_array input_file\n");
		exit(-1);
	}
	fd = fopen(argv[1], "rb");
	if (NULL == fd)
	{
		printf("Cannot open %s\n%s\n", argv[1], strerror(errno));
		exit(-1);
	}
	while(1)
	{
		l = fread((void*)buffer, 1, 24, fd);
		if (l < 1)
			break;
		printf("\t");
		for (i = 0; i < l; i += 4)
		{
			value = ((uint32_t)buffer[i + 0] << 0) | ((uint32_t)buffer[i + 1] << 8) | ((uint32_t)buffer[i + 2] << 16) | ((uint32_t)buffer[i + 3] << 24);
			if(i)
				printf(" ");
			printf("%d 0x%08X", index++, (unsigned int)value);
		}
		printf("\n");
	}
	fclose(fd);
}

