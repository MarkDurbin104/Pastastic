#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpa.h"

typedef struct {
    char  t;
    char *n;
    int   o;
} NAMEIDX;

extern NAMEIDX *G_nbuf;
extern char *G_stack;
extern char *G_linein;
extern int G_numn;
extern int G_lastst;
extern int G_sp;
extern int G_open;
extern int G_lnum;
extern int G_nume;

extern void error (char *err);
extern void parse (char **form);

int main(int argc,char *argv[])
{
    char *form;
    char *last;
    FILE *fp;
    char s[100];
    char tmp[80];
    int i,fd;

    if (argc<2) readconfig("GPA"); else readconfig(argv[1]);

    if (!loadsdata(G_system)) {
        printf("Can't load store data for %s\n",G_system);
        return(1);
    }
    if (!loadtext(G_system)) {
        printf("Can't load text for %s\n",G_system);
        return(2);
    }
    sprintf(tmp,"b %s%sA.DAT",G_config,G_system);

    cprintf("Unisys Action Editor  Version 1.0 - Copyright (c) 1993 Unisys Ltd.\r\n%s:\r\n\r\n",tmp);
    do {
        system(tmp);
        tmp[1]=0;
        i=0;
        G_numn=G_lastst=G_sp=G_open=G_lnum=G_nume=G_nume=0;
        if ((fp=fopen(&tmp[2],"r"))!=NULL) {
            while (fgets(G_linein,80,fp)!=NULL) {
                i+=strlen(G_linein);
                G_lnum++;
                form=G_linein;
                do {
                    if (*form==';') form++;
                    last=form;
                    parse(&form);
                } while (form!=last);
            }
        }
        if (G_open) error("missing }");
        textattr(0x07);
        if (G_nume) {
            cprintf("\r\n%d Error%c found in %s\r\n",G_nume,((G_nume!=1)?'s':' '),&tmp[2]);
            cprintf("press any key to re-edit %s.  (ESC to exit)\r\n",&tmp[2]);

            if (getch()==27) G_nume=(-1);
        } else {
            cprintf("No Errors found in %s\r\n",&tmp[2]);
        }
    } while (G_nume>0);
    if (!G_nume) {
        sprintf(tmp,"%s%sI.DAT",G_config,G_system);
        fd=open(tmp,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
        write(fd,&G_numn,sizeof(int));
        for (i=0;i<G_numn;i++) {
            write(fd,&G_nbuf[i].t,sizeof(char));
            write(fd,&G_nbuf[i].o,sizeof(int));
            write(fd,G_nbuf[i].n,9);
        }
        write(fd,&G_sp,sizeof(int));
        write(fd,G_stack,G_sp);
        close(fd);
    }
    return(0);
}

