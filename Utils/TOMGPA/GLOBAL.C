/****************************************************************************
* Project     : GPA
* File        : global.c
* Description : process globals
* 
* $Revision:   1.2  $  $Date:   Nov 03 1995 11:32:52  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/global.c_v  $
* 
*    Rev 1.2   Nov 03 1995 11:32:52   JGRAY
* Annotations
* 
*    Rev 1.1   Nov 01 1995 15:15:14   JGRAY
*  
* 
****************************************************************************/
#define GLOBAL_C

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "gpasizes.h"
#include "types.h"
#include "config.h"
#include "translog.h"
#include "function.h"
#include "formhand.h"
#include "dst.h"
#include "control.h"
#include "global.h"

//**************************************************************************
//S find the global variable "n" 
//P char string variable name
//R -1 failed, or integer global number from 0 to nglobs-1

INT findgname(CHAR *n)
{
    INT i=0;
    ENTRY(2370);
    while (G_gvars[i].n!=NULL)
        {
        if (!strcmp(n,G_gvars[i++].n)) RETURNV(i-1);
        }
    RETURNV(-1);
}

//**************************************************************************
//S true if "n" is a global variable
//P char string variable name
//R TRUE or FALSE

INT isglobal(CHAR *n)
{
    ENTRY(2380);
    if (findgname(n)<0) RETURNV(0);
    RETURNV(1);
}

//**************************************************************************
//S RETURN the value of the global variable "i" as a string
//P integer variable id 
//R char string address

CHAR *getglobal(INT i)
{
    static CHAR tmp[LENOFGLOBAL];
    ENTRY(2390);

    switch (G_gvars[i].t) {
        case 'c' :
            sprintf(tmp,"%c",*((CHAR *)G_gvars[i].v));
            break;
        case 'C' :
            sprintf(tmp,"%c",*((UCHAR *)G_gvars[i].v));
            break;
        case 'I' :
            sprintf(tmp,"%d",*((INT *)G_gvars[i].v));
            break;
        case 'i' :
            sprintf(tmp,"%d",*((UCHAR *)G_gvars[i].v));
            break;
        case 'U' :
            sprintf(tmp,"%u",*((UINT *)G_gvars[i].v));
            break;
        case 'm' :
            sprintf(tmp,"%s",*((CHAR **)(G_gvars[i].v)));
            break;
        case 's' :
            sprintf(tmp,"%s",((CHAR *)(G_gvars[i].v)));
            break;
        case 'M' :
            sprintf(tmp,"%s",*((UCHAR **)(G_gvars[i].v)));
            break;
        case 'S' :
            sprintf(tmp,"%s",((UCHAR *)(G_gvars[i].v)));
            break;
        case 'L' :
            sprintf(tmp,"%ld",*((LONG *)G_gvars[i].v));
            break;
    }
    RETURNV(tmp);
}

//**************************************************************************
//S set the value of the global variable "n"
//P integer variable id
//P char string value
//R TRUE

INT setglobal(INT i,CHAR *v)
{
    ENTRY(2400);
    switch (G_gvars[i].t) {
        case 'c' :
            *((CHAR *)G_gvars[i].v)=v[0];
            break;
        case 'C' :
            *((UCHAR *)G_gvars[i].v)=(UCHAR)v[0];
            break;
        case 'I' :
            *((INT *)G_gvars[i].v)=atoi(v);
            break;
        case 'i' :
            *((UCHAR *)G_gvars[i].v)=(UCHAR)atoi(v);
            break;
        case 'U' :
            *((UINT *)G_gvars[i].v)=atoi(v);
            break;
        case 'm' :
            if (*((CHAR **)(G_gvars[i].v))!=NULL)
                FREE(*(CHAR **)(G_gvars[i].v));
            *((CHAR **)(G_gvars[i].v))=STRDUP(v);
            break;
        case 's' :
            strcpy(((CHAR *)(G_gvars[i].v)),v);
            break;
        case 'M' :
            if (*((UCHAR **)(G_gvars[i].v))!=NULL)
                FREE(*(UCHAR **)(G_gvars[i].v));
            *((UCHAR **)(G_gvars[i].v))=(UCHAR *)STRDUP(v);
            break;
        case 'S' :
            strcpy(((CHAR *)(G_gvars[i].v)),v);
            break;
        case 'L' :
            *((LONG *)G_gvars[i].v)=atol(v);
            break;
    }
    RETURNV(1);
}

//**************************************************************************
//S print global variable number 'n' to stdout
//P integer variable number id

void printglob(INT i)
{
    ENTRY(2410);
    printf("%d %c %-9.9s ",i,G_gvars[i].t,G_gvars[i].n);
    switch (G_gvars[i].t) {
        case 'c' :
            printf("%c",*((CHAR *)G_gvars[i].v));
            break;
        case 'C' :
            printf("%c",*((UCHAR *)G_gvars[i].v));
            break;
        case 'I' :
            printf("%d",*((INT *)G_gvars[i].v));
            break;
        case 'i' :
            printf("%d",*((UCHAR *)G_gvars[i].v));
            break;
        case 'U' :
            printf("%u",*((UINT *)G_gvars[i].v));
            break;
        case 'm' :
            printf("%s",*((CHAR **)(G_gvars[i].v)));
            break;
        case 's' :
            printf("%s",((CHAR *)(G_gvars[i].v)));
            break;
        case 'M' :
            printf("%s",*((UCHAR **)(G_gvars[i].v)));
            break;
        case 'S' :
            printf("%s",((UCHAR *)(G_gvars[i].v)));
            break;
        case 'L' :
            printf("%ld",*((LONG *)G_gvars[i].v));
            break;
    }
    printf("\n");
    RETURN;
}

// **************************************************************************
// global.c <end-of-file>

