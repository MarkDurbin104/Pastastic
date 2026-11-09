#include <stdio.h>

int main(void)
{
	FILE *fp;
	fp=stdprn;
  	fprintf(fp,"%c",0x10);
 	fprintf(fp,"%c",0x16);
	return(0);
}
