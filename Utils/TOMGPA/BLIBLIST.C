/****************************************************************************
* Project     : GPA
* File        : bliblist.c
* Description : Program to output a liblist issuing -+ if module exists
*               or + if not.  Uses command line for 2 parameters
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:56  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/bliblist.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:56   JGRAY
*  
* 
****************************************************************************/

#include <io.h>
#include <stdio.h>
#include <string.h>
#include "gpasizes.h"
#include "types.h"

CHAR tmp[LENINPUTSBUF];

//************************************************************
//S Main module - scans input stream and builds list as above
//P standard integer cli count
//P standard array cli strings
//R standard integer reply 0 = success, 1 = failure

INT _cdecl main(INT argc,CHAR *argv[])
{
    FILE *fp;
    CHAR *t;
    INT pm=1;
    INT  i=0;
    if (argc<2) {
        printf("Must Supply Output file\n");
        return(1);
    }
    if (argc==3) {
        if (access(argv[2],0)) pm=0;
    }
    if ((fp=fopen(argv[1],"w"))==NULL) {
        printf("Can't open file %s\n",argv[1]);
        return(1);
    }
    if (fgets(tmp,LENINPUTSBUF,stdin)==NULL) {
        printf("No input stream\n");
        return(1);
    }
    t=strtok(tmp," \t\r\n");
    while (t!=NULL) {
        if (pm) fprintf(fp,"-+%-13s",t); else fprintf(fp,"+%-14s",t);
        i++;
        t=strtok(NULL," \t\r\n");
        if ((i%5==0)&&(t!=NULL)) fprintf(fp,"&\n");
    }
    fprintf(fp,"\n");
    fclose(fp);
    return(0);
}
// **************************************************************************
// bliblist.c <end-of-file>

