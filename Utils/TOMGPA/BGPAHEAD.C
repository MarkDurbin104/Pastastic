/****************************************************************************
* Project     : GPA
* File        : bgpahead.c
* Description : Program to read a list of file names from stdin
*               and scan them for public declarations and defines
*               and build up a merged output header file
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:56  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/bgpahead.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:56   JGRAY
*  
* 
****************************************************************************/
#include <string.h>
#include <stdio.h>
#include "gpasizes.h"
#include "types.h"

FILE *G_fp=NULL;
CHAR tmp[LENINPUTSBUF];

//************************************************************
//S strip out to G_fp the defines and public declarations from the specified file
//P char string file name
//P BOOL all parameter : TRUE and you get the whole line, FALSE and it strips the tail

void getpubs(CHAR *file,INT all)
{
    FILE *fp;
    CHAR line[LENOFPUBSLINE];
    INT togg=0,ot;
    CHAR *e;

    strupr(file);
    fp=fopen(file,"r");
    if (fp==NULL)
        {
        fprintf(stderr,"Can't Open %s\n",file);
        return;
    }
    fprintf(G_fp,"// ------------------------------ %s START ------------------------------\n\n",file);

    while ((fgets(line,255,fp)!=NULL))
        {
        if (!all)
            {
            if ((e=strstr(line,"INIT"))!=NULL) *e=0;
            e=&line[strlen(line)-1];
            while (((*e=='\n')||(*e==' ')||(*e==';'))&&(e!=line)) *(e--)=0;
            }
        ot=togg;
        if (!strncmp(line,"// PUBLIC SYMBOLS",17)) togg^=1;
        if (togg)
            {
            if (all)
                {
                if (ot==togg) fprintf(G_fp,"%s",line);
                }
            else
                {
                if (!strncmp(line,"PUBLIC",6))
                    fprintf(G_fp,"extern %s;\n",&line[6]);
                if (!strncmp(line,"#define",7))
                    fprintf(G_fp,"%s\n",line);
                }
            }
        }

    fclose(fp);
    fprintf(G_fp,"\n// ------------------------------- %s END --------------------------------\n\n",file);
}

//************************************************************
//S main program module to build summary include file
//D expects stdin to convey a list of include filenames to be processed.
//P command line P1 is output filename
//R integer 1 for failure 0 for success

INT _cdecl main(INT argc, CHAR *argv[])
{
    CHAR *t;
    if (argc<2)
        {
        fprintf(stderr,"Must Supply Output file\n");
        return(1);
        }
    if ((G_fp=fopen(argv[1],"w"))==NULL)
        {
        fprintf(stderr,"Can't open file %s\n",argv[1]);
        return(1);
        }
    if (fgets(tmp,LENINPUTSBUF,stdin)==NULL)
        {
        fprintf(stderr,"No input stream\n");
        return(1);
        }
    fprintf(stderr,"Re-Building %s\n",argv[1]);
    getpubs("GPASIZES.H",1);
    getpubs("TYPES.H",1);
    t=strtok(tmp," \t\r\n");
    while (t!=NULL)
        {
        getpubs(t,0);
        t=strtok(NULL," \t\r\n");
        }
    fclose(G_fp);
    return(0);
}
// **************************************************************************
// bgpahead.c <end-of-file>
