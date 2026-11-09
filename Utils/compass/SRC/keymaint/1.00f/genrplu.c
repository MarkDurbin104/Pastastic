#include <stdio.h>
#include <conio.h>
#include <time.h>
#include <sys\timeb.h>

#include "types.h"
#include "defines.h"
#include "fileio.h"

int main(int argc,char *argv[])
{
    PLU *plulist=NULL,*plu;
    INT pindex;
    struct tm *t;
    struct timeb tb;

    if (argc<2) {
        printf("%s PLUFILE\n",argv[0]);
        return 0;
    }
    if (!LoadPLU(argv[1],&plulist)) {
        printf("Error in PLU File !\n");
        if (plulist==NULL) return 2;
        printf("Some Definitions May Be incorect !\n");
        getch();
    }

   	ftime(&tb);
	t=localtime(&tb.time);

    plu=plulist;
    while (plu!=NULL) {
        for (pindex=0;pindex<6;pindex++)  {
            printf("P%015ld%12sGenerated Str%02d%02d%02d%010d0000000000%07ld.%02ld\n",
                plu->plu_code,plu->desc1,t->tm_year,t->tm_mon+1,t->tm_mday,pindex+1,
                plu->price[pindex]/100L,plu->price[pindex]%100L);
        }
        plu=plu->next;
    }
    
    return 1;
}
