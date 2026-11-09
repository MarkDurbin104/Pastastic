//SYSDOC GPAMAIN.DOC
#define GPA_C

#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <mem.h>
#include <alloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include <stdlib.h>
#include <time.h>

#include "types.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "dst.h"
#include "menuproc.h"
#include "fldproc.h"
#include "formhand.h"
#include "translog.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "memory.h"
#include "arith.h"
#include "lang.h"
#include "instruct.h"

// GPA runtime    Usage - "GPA system_name"
int main(int argc,char *argv[]) 
{
    int i,fd;
	char tmp[81];
	PFORMF f;

	if (argc<4) {
		printf("%s SYSTEM FORM OUTPUTFILE\n",argv[0]);
		return(1);
	}
    fd=open(argv[3],O_RDWR|O_BINARY);
    if (fd==(-1)) {
        fd=open(argv[3],O_RDWR|O_BINARY|O_CREAT,S_IREAD|S_IWRITE);
        if (fd==(-1)) {
    		printf("Can't Open Output File %s\n",argv[3]);
    		return(1);
        }
        printf("Created Output File %s\n",argv[3]);
    } else {
        printf("Appending to Output File %s\n",argv[3]);
    }
	if (!readconfig(argv[1])) {
        printf("Error reading config file %s.cfg\n",argv[1]);
		cleanupblks(0);
        RETURNV(1);
	}
    G_lang=0;
 	readlang(G_langfiles[G_lang]);
   	freetext();
   	loadtext(G_system);
	addlangname(G_name);
    clrform(&G_form);
    freeform(&G_form);
    strcpy(G_form.name,argv[2]);
    if (!loadform(&G_form)) {
        printf("Can't load form [%s] for %s\n",argv[2],G_system);
		cleanupblks(0);
        RETURNV(1);
    }
    if ((G_form.type==F_MENU)||(G_form.type==F_REPORT)) {
        orderform(&G_form,1);
    } else {
        orderform(&G_form,0);
    }

    lseek(fd,0L,SEEK_END);
    write(fd,&G_form,sizeof(FORM));
    for (i=0;i<G_form.numitem;i++) {
        f=&G_form.items[i];
        write(fd,f,sizeof(FORMF));
        memset(tmp,0,80);
        strcpy(tmp,textstr(f));
        write(fd,tmp,80);
    }
    close(fd);
    printf("%s copied From %s to %s\n\n",argv[2],argv[1],argv[3]);
	cleanupblks(0);
    RETURNV(0);
}
