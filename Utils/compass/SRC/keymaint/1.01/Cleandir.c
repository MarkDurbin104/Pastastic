//===============|========================================================|
//               |                                                        |
// Module        | CLEANDIR.C                                             |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | Directory Cleanup Program (End-of-Day batch process)   |
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

#define __CLEANDIR_C

//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For FILE *  & fprintf().
#include <stdlib.h>      // For atol
#include <string.h>      // For strdup().
#include <malloc.h>      // For malloc() & free().
#include <dir.h>         // For findfirst() findnext() etc.
#include <dos.h>         // For file attributes
#include <time.h>        // For time_t time() 
#include <ctype.h>       // For isdigit() 
#include <sys\timeb.h>   // For timeb struct

#include "types.h"       // for types INT & CHAR
#include "defines.h"     // for AUDITFILE

//=========================================================================
// Types Section
//=========================================================================

typedef struct file_list {      // file linked list structure
    CHAR * name;                // the file name
    struct file_list * next;    // the next file in the list or NULL
} FILELIST;

//=========================================================================
// Globals Section
//=========================================================================

//=========================================================================
// Define Section
//=========================================================================
#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC

//=========================================================================
// Declarations Section
//=========================================================================

//=========================================================================
// Definitions Section
//=========================================================================
//==========================================================================
//F FindSubDirs
//S Find all the sub-directories of a given directory
//D Find all the sub-directories of a given directory
//P the parent directory
//P the file list to fill
void FindSubDirs(CHAR *path,FILELIST **subdirs)
{
    FILELIST *curdir;
    struct ffblk f;
    static int done;
    static char dirpath[MAXSTRLEN];

    sprintf(dirpath,"%s*.*",path);
    done=findfirst(dirpath,&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            if ((curdir=malloc(sizeof(FILELIST)))==NULL) return;
            curdir->name=strdup(f.ff_name);
            curdir->next=*subdirs;
            *subdirs=curdir;
        }
        done=findnext(&f);
    }
}
//__________________________________________________________________________

//==========================================================================
//F RemoveDir
//S Remove a directory and all the files therein ( does not recurse )
//D Remove a directory and all the files therein ( does not recurse )
//P The directory
void RemoveDir(CHAR *dirname)
{
    FILELIST *curdir;
    struct ffblk f;
    static int done;
    static char dirpath[MAXSTRLEN];

    sprintf(dirpath,"%s\\*.*",dirname);
    done=findfirst(dirpath,&f,FILEATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))) {
            sprintf(dirpath,"%s\\%s",dirname,f.ff_name);
            unlink(dirpath);
        }
        done=findnext(&f);
    }
    rmdir(dirname);
}
//__________________________________________________________________________

//==========================================================================
//F DelDirsOlderThan
//S Delete the directories older then a specified date
//D Delete the directories older then a specified date
//P The date as a number i.e. 960618 - 18th June 1996
void DelDirsOlderThan(LONG date)
{
    LONG dirdate;               // date of current directory as a number
    CHAR path[MAXSTRLEN];       // used for path concatination
    FILELIST *subdirs=NULL;     // list of sub-directories under \KEYMAINT
    FILELIST *curdir;           // current sub-directory

    FindSubDirs(CFGPATH,&subdirs); // get the sub-directories

    curdir=subdirs;                         // select the first
    while (curdir!=NULL) {                  // for each dir
        if (isdigit(curdir->name[0])) {     // if the first char is a digit
            dirdate=atol(curdir->name);     // if > 01/01/96 and < today-8
            if ((dirdate>960101L)&&(dirdate<date)) {
                sprintf(path,"%s%s",CFGPATH,curdir->name);
                RemoveDir(path);            // delete it and its contents
            }
        }
        curdir=curdir->next; // next sub-directory
    }
}
//__________________________________________________________________________

#pragma warn -par
//==========================================================================
//F main
//S Remove the dated directories under \KEYMAINT the are 8 days older than today
//D Remove the dated directories under \KEYMAINT the are 8 days older than today
//P argument count = 1
//P argv[0] = executable name
//R returns 0
INT main(INT argc,CHAR *argv[])
{
    LONG todayminus8;       // today's date minus 8 days as a number
    struct tm *t;           // Used to get current date
    struct timeb tb;        // Used to get current date

   	ftime(&tb);
    t=localtime(&tb.time);
    t->tm_mon++;
    if (t->tm_mday<9) {             // subtract 8 days from today
        switch (t->tm_mon) {          
            case 1 :                // Janruary - go back to December
                t->tm_mon=12;
                t->tm_year--;
                t->tm_mday+=(31-8); 
                break;
            case 3 :                    // back to february
                t->tm_mon--;
                if ((t->tm_year%4)==0)  // leap year
                    t->tm_mday+=(29-8);
                else
                    t->tm_mday+=(28-8);
                break;
            case 2 :                // back to a 31 day month
            case 4 :
            case 6 :
            case 8 :
            case 9 :
            case 11 :
                t->tm_mon--;
                t->tm_mday+=(31-8);
                break;
            case 5 :                // back to a 30 day month
            case 7 :
            case 10 :
            case 12 :
                t->tm_mon--;
                t->tm_mday+=(30-8);
                break;
        }
    } else {
        t->tm_mday-=8;   // just take off 8 days
    }
    todayminus8 =(LONG)t->tm_year*10000L;  // date as number i.e. 960618L
    todayminus8+=(LONG)t->tm_mon *100L  ;  // is 18th June 1996
    todayminus8+=(LONG)t->tm_mday       ;

    DelDirsOlderThan(todayminus8);

    return 0;
}
//__________________________________________________________________________
#pragma warn +par
//=========================================================================
// End of file (CLEANDIR.C)
//=========================================================================


