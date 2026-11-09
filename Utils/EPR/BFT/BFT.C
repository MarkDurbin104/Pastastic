//=============================== BFT.C =================================
#define BFT_C

#include <stdio.h>
#include <conio.h>
#include <graphics.h>

#include "bft.h"

typedef struct {
    
} DATAITEMS;

int main(int argc,char *argv[])
{
    DATAITEMS data;
    if (argc<2) {
        fprintf(stderr,"Usage %s datafile",argv[0]);
    	return 1;
    }
    if (!read_data(argv[1],&data)) {
        fprintf(stderr,"Unable to read datafile %s",argv[1]);
    	return 2;
    }
    if (grafix()) {
        display_data(data);
        getch();
        closegraph();
    }
    reset_link(&data);
	return 0;
}
//===============================END OF FILE=================================
