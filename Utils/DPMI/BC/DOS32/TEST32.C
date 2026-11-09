


#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>

void helloworld(void);

void main(void)
{

	char *tbuff;

	tbuff = malloc(0x100000);		// allocate 1 mega byte
	if (tbuff == NULL)
		{
		printf("Unable to allocate 1 megabyte of memory\n");
		exit(1);
		}

	printf("Hello World! I allocated 1 megabyte at $%lx\n", tbuff);

	free(tbuff);


}

