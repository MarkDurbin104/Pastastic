//===============|========================================================|
//               |                                                        |
// Module        | CLEANLOG.C                                             |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | Audit Trail Cleanup Program (End-of-Day batch process) |
//               |                                                        |
// Functions     | main()                                                 |
//               |                                                        |
// Global Vars.  | None.                                                  |
//               |                                                        |
//===============|========================================================|
//               |                                                        |
// Copyright (c) | Unisys Limited                                         |
//               | 22 Southwark Bridge Road                               |
//               | London SE1 9HB                                         |
//               |                                                        |
// Author        | Mark Durbin                                            |
//               | P.S.L.                                                 |
//               | 160 Charles street, Greenhithe, Kent. DA9 9AJ          |
//               |                                                        |
//===============|========================================================|
// Date          | Modifications                                 | By     |
//===============|===============================================|========|
// 20/06/96      | Initial Version                               | MJD    |
//===============|========================================================|
//               |                                               |        |
//===============|========================================================|

#define __CLEANLOG_C

//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For FILE *  & fprintf().
#include <string.h>      // For strdup().
#include <malloc.h>      // For malloc() & free().

#include "types.h"       // for types INT & CHAR
#include "defines.h"     // for AUDITFILE

//=========================================================================
// Types Section
//=========================================================================

typedef struct line_list {      // line linked list structure
    CHAR * line;                // the text line from the file
    struct line_list * next;    // the next line in the list or NULL
    struct line_list * prev;    // the previous line in the list or NULL
} LINELIST;

//=========================================================================
// Globals Section
//=========================================================================

//=========================================================================
// Define Section
//=========================================================================

#define MAXNUMBLINES  500       // maximum number of lines in the list
#define FILEERROR     1         // errorlevel for exit on file error
#define MEMORYERROR   2         // errorlevel for exit on memory error

//=========================================================================
// Declarations Section
//=========================================================================

//=========================================================================
// Definitions Section
//=========================================================================
#pragma warn -par
//==========================================================================
//F main
//S Clean the audit log to the last 500 lines
//D Clean the audit log to the last 500 lines
//P argument count = 1
//P argv[0] = executable name
//R Errorlevel 1 = File open error, 2 = memory error
INT main(INT argc,CHAR *argv[])
{
    FILE *fp;                 // audit trail file pointer
    INT linecount;            // current niumber of lines
    CHAR line[MAXSTRLEN];     // read line buffer
    LINELIST *lastline=NULL;  // list of lines
    LINELIST *firstline;      // last line in list
    LINELIST *curline;        // current line

    fp=fopen(AUDITFILE,"r");  // open the audit trail for read
    if (fp==NULL) {
        fprintf(stderr,"%s - ERROR - Can't Open Audit Trail!\n",argv[0]);
        return FILEERROR;
    }          
    linecount=0;
    while (fgets(line,MAXSTRLEN,fp)!=NULL) { // for each line
        // allocate space for the link
        if ((curline=malloc(sizeof(LINELIST)))==NULL) {
            fprintf(stderr,"%s - ERROR - Insufficient memory!\n",argv[0]);
            fclose(fp);
            return MEMORYERROR;
        }
        curline->line=strdup(line);  // save the read line
        if (curline->line==NULL) {
            fprintf(stderr,"%s - ERROR - Insufficient memory!\n",argv[0]);
            fclose(fp);
            return MEMORYERROR;
        }
        curline->prev=lastline;     // append to end of list
        curline->next=NULL;
        if (lastline==NULL) {
            firstline=curline;
        } else {
            lastline->next=curline;
        }
        lastline=curline;
        linecount++;
        if (linecount>MAXNUMBLINES) {   // remove first line if max count reached
            curline=firstline;
            firstline=firstline->next;
            firstline->prev=NULL;
            free(curline->line);
            free(curline);
            linecount--;
        }
    }   
    fclose(fp);
    fp=fopen(AUDITFILE,"w");  // open the audit trail for write
    if (fp==NULL) {
        fprintf(stderr,"%s - ERROR - Can't Open Audit Trail!\n",argv[0]);
        return FILEERROR;
    }
    curline=firstline;                   // goto start of list
    while (curline!=NULL) {              // for each line
        firstline=curline;               // move the firstline
        fprintf(fp,"%s",curline->line);  // output the current line
        free(curline->line);             // free the line memory
        curline=curline->next;           // move to next item
        free(firstline);                 // fre the first item
    }
    fclose(fp);  // done - close file
    return 0;
}
//__________________________________________________________________________
#pragma warn +par
//=========================================================================
// End of file (CLEANLOG.C)
//=========================================================================

