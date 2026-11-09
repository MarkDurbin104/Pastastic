#include <dos.h>
#include <alloc.h>
#include <string.h>
#include <dir.h>
#include <stdio.h>

int G_dodir=0;

/***********************************************************************/

#define FILEATTR    FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR     FA_DIREC

/***********************************************************************
*
*   Function:   clearattr
*
*   Purpose:    clear all the attributes off a file
*
*   Arguments:  filename
*
*   Returns:    None
*
***********************************************************************/
void clearattr(char *file)
{
    union REGS regs;
    struct SREGS sregs;

    regs.x.ax=0x4301;
    regs.x.cx=0x0000;
    regs.x.dx=FP_OFF(file);
    sregs.ds =FP_SEG(file);
    
    int86x(0x21,&regs,&regs,&sregs);
}

/***********************************************************************
*
*   Function:   getfiles
*
*   Purpose:    recursivly search [sub-]directorys for files
*
*   Arguments:  root path,  search file i.e. *.* depth indicator i.e 0
*
*   Returns:    None
*
***********************************************************************/
void getfiles(char *path,char *search,int depth)
{
    struct ffblk *fi;                              /* file information     */
    char *curpath;                                  /* local strings        */
    char *newpath;
    char *dirpath;

    curpath=malloc(strlen(path)+strlen(search)+2);  /* get space            */
    newpath=malloc(strlen(path)+16);
    dirpath=malloc(strlen(path)+5);
    fi=malloc(sizeof(struct ffblk));

    sprintf(curpath,"%s%s",path,search);            /* set search path      */
    sprintf(dirpath,"%s%s",path,"*.*");             /* directory not limited*/

    findfirst(dirpath,fi,DIRATTR);             /* ignore .             */
    if (strcmp(fi->ff_name,".")) {                     /* check for root dir   */
        sprintf(newpath,"%s%s\\",path,fi->ff_name);    /* concat dir name      */
        getfiles(newpath,search,depth+1);           /* recurse              */
    }
    else {
        findnext(fi);                          /* ignore ..            */
    }
    while (findnext(fi)==0) {                  /* do all directorys    */
        if (fi->ff_attrib&DIRATTR)  {                  /* make sure it's a dir */
            sprintf(newpath,"%s%s\\",path,fi->ff_name);/* concat dir name      */
            getfiles(newpath,search,depth+1);       /* recurse              */
        }
    }

    if (findfirst(curpath,fi,FILEATTR)==0) {   /* get the first file   */
        do {                                      
            sprintf(newpath,"%s%s",path,fi->ff_name);  /* concat path & file   */
            clearattr(newpath);                     /* make it deletable    */
            if (!G_dodir) printf("DELETING %s\n",newpath);
            unlink(newpath);                        /* delete it            */
        } while (findnext(fi)==0);             /* get the next file    */
    }

    path[strlen(path)-1]=0;                         /* take the '\' off     */
    if (G_dodir) {
        printf("ERASING %s\n",path);                    /* tell them            */
        rmdir(path);                                    /* remove directory     */
    }

    free(fi);                                       /* clean up             */
    free(dirpath);
    free(newpath);
    free(curpath);
}


/***********************************************************************/
int main(int argc,char *argv[])
{
    char *dir;                                      /* holding string       */

    if (argc<2) return(1);                          /* no parameters FAIL   */

    dir=malloc(strlen(argv[1])+2);                  /* get space for string */

    if (argv[1][strlen(argv[1])-1]!='\\')
        sprintf(dir,"%s\\",argv[1]);                /* append a \           */
    else
        strcpy(dir,argv[1]);                        /* already got one      */

    strupr(dir);                                    /* change to uppercase  */

    if (argc==2) {
        G_dodir=1;
        getfiles(dir,"*.*",0);                      /* do the work          */
    }
    else {
        G_dodir=0;
        getfiles(dir,argv[2],0);                    /* do the work          */
    }
    
    return(0);                                      /* return OK            */
}
/***********************************************************************/
