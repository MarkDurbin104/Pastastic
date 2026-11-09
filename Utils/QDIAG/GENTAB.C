//=============================== GENTAB.C =================================
#define GENTAB_C

#include <stdio.h>
#include <math.h>

int main(void)
{
    int i;
    printf("unsigned int G_sintab[90]={");
    for (i=0;i<90;i++) {
        if ((i%10)==0) printf("\n ");
        printf("%5uU,",(int)(sin((double)i*M_PI/180)*60000.0));
    }
    printf("\n};\n");
    printf("unsigned int G_asintab[100]={");
    for (i=0;i<=100;i++) {
        if ((i%10)==0) printf("\n ");
        printf("%5uU,",(int)(asin((double)i/100.0)*36000.0));
    }
    printf("\n};\n");
	return 0;
}
//===============================END OF FILE=================================
