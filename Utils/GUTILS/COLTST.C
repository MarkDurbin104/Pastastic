#include <stdio.h>
/*
ESCE                                            Resets printer
ESC*r-4U                                        Chooses KCMY palette
ESC*v1S                                         Chooses true Black
This is a test of true black
ESC*v2S                                         Chooses Cyan
This is a test of Cyan
ESC*v4S                                         Chooses Magenta
This is a test of Magenta
ESC*v6S                                         Chooses Blue
This is a test of Blue
ESC*v8S                                         Chooses Yellow
This is a test of Yellow
ESC*v10S                                        Chooses Green
This is a test of Green
ESC*v12S                                        Chooses Red
This is a test of Red
ESC*v14S                                        Chooses composite Black
This is a test of composite Black
ESCE                                            Resets printer
*/
0001 Black
0010 Cyan
0100 Magenta
1000 Yellow
int main(void)
{
	int i;
	fprintf(stdprn,"%cE",27);							 // Resets printer
	fprintf(stdprn,"%c*r-4U",27);						 // Chooses KCMY palette
	fprintf(stdprn,"%c*v%dSThis is a test of Colour %d\r\n",27,1,1);
	for (i=1;i<16;i++) {
		fprintf(stdprn,"%c*v%dSThis is a test of Colour %d\r\n",27,i<<1,i<<1);
	}
	fprintf(stdprn,"%cE",27);							 // Resets printer
	return(0);
}

