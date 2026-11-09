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
    int i,fd,fdo,lv;
    FILE *fp;
	char tmp[81];
	FORMF f;
	FORM form;

	if (argc<3) {
		printf("%s SYSTEM INPUTFILE\n",argv[0]);
		return(1);
	}
	if (!readconfig(argv[1])) {
        printf("Error reading config file %s.cfg\n",argv[1]);
		cleanupblks(0);
        RETURNV(1);
	}
    G_lang=0;
 	readlang(G_langfiles[G_lang]);
    isform("logon");

    fd=open(argv[2],O_RDONLY|O_BINARY);
    if (fd==(-1)) {
  		printf("Can't Open Input File %s\n",argv[2]);
   		return(1);
    }

    sprintf(tmp,"%s%sN.DAT",G_config,G_system);
    fdo=open(tmp,O_RDWR|O_BINARY);
    if (fdo==(-1)) {
  		printf("Can't Open Forms File %s\n",tmp);
   		return(1);
    }
    lseek(fdo,0L,SEEK_END);

    fp=fopen(G_textfile,"r+");
    if (fp==NULL) {
  		printf("Can't Open Text File %s\n",G_textfile);
   		return(1);
    }
    while (fgets(tmp,80,fp)!=NULL) lv=atoi(&(tmp[4]));
    fseek(fp,0L,SEEK_END);

    while (read(fd,&form,sizeof(FORM))==sizeof(FORM)) {
        if (isform(form.name)>=0) {
            printf("Form %s exists! - Skipping\n",form.name);
            for (i=0;i<form.numitem;i++) {
                read(fd,&f,sizeof(FORMF));
                read(fd,tmp,80);
            }
        } else {
            printf("Transfering Form %s\n",form.name);
            write(fdo,&form,sizeof(FORM));
            for (i=0;i<form.numitem;i++) {
                memset(tmp,0,80);
                read(fd,&f,sizeof(FORMF));
                read(fd,tmp,80);
                if ((f.class&(~FF_TBLF))==FF_TEXT) {
                    lv++;
                    sprintf(f.item,"TEXT%04d",lv);
                    fprintf(fp,"TEXT%04d %s\n",lv,tmp);
//                    printf("Text line %s\n",tmp);
                }
                write(fdo,&f,sizeof(FORMF));
            }
//            printf("\n");
        }
    }
    close(fd);
    close(fdo);
    fclose(fp);
	cleanupblks(0);
    RETURNV(0);
}
