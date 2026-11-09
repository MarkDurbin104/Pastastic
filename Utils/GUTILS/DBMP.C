#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <alloc.h>
#include <mem.h>
#include "gprim.h"
extern int G_l;
int main(int argc,char *argv[])
{
	int i;
	IMAGE *img;

	if (argc<2) return 1;
	img=getxbmp(argv[1]);
	if (img==NULL) return 1;
	printf("Loaded\n");
	G_l=atoi(argv[2]);
	getch();

	grafix();
	putimage(0,0,img);
	if (getch()!=27) {
		for (i=0;i<32;i++) { putimage(i*8,i*8,img); }
		for (i=32;i>=0;i--){ putimage(i*8,i*8,img); }
		getch();
	}
	freeimg(img);
	closegraf();
	return 0;
}
