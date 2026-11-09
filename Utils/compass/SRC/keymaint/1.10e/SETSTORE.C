//=========================================================================
// Include Section
//=========================================================================

#include <stdio.h>       // For stdout printf() etc...
#include <stdlib.h>      // For max()
#include <string.h>      // For strlen() vsprintf() etc...
#include <dir.h>         // For mkdir()
#include <dos.h>         // For file attributes
#include <conio.h>       // For getch() etc...
#include <malloc.h>      // For getch() etc...
#include <time.h>
#include <sys\timeb.h>
#include <ctype.h>

#include "defines.h"     // definitions
#include "types.h"       // type definitions
#include "fileio.h"      // File i/o declarations
#include "keydef.h"      // keyboard definitions

INT GetKey(void)
{
    INT k;
    if (!(k=getch())) k=0-getch();
    return k;
}
void InputLine(CHAR *tmp)
{
    struct text_info t;
    INT key,curpos=0;
    BOOL xit=FALSE;

    gettextinfo(&t);
    tmp[0]=0;
    while (!xit) {
        gotoxy(t.curx,t.cury);
        cprintf("%s   ",tmp);
        gotoxy(t.curx+curpos,t.cury);
        key=GetKey();
        switch (key) {
            case ESC :
                tmp[0]=0;
                xit=TRUE;
                break;
            case ENTER :
                xit=TRUE;
                break;
            case BKSP :
                if (curpos>0) tmp[--curpos]='\0';
                break;
            case '0' :
            case '1' :
            case '2' :
            case '3' :
            case '4' :
            case '5' :
            case '6' :
            case '7' :
            case '8' :
            case '9' :
                tmp[curpos++]=(CHAR)key;
                tmp[curpos]='\0';
                break;
        }
    }
}
int main(void)
{
    CONFIG          *cfglist=NULL;    // configuration list
    CONFIG          *cfg;             // current config line
    FILE            *fp;              // store.dat file pointer
    CHAR filename[100];
    CHAR tmp[100];
    INT key;
    if ((LoadConfig(CONFIGFILE,&cfglist))==FALSE) {
        printf("Error Loading Configuration File!\n");
        if (cfglist==NULL) {
            return FALSE;
        }
        printf("Some data in the file is correct !\nDo you wish to proceed? Y/N");
        key=getch();
        if ((key!='Y')&&(key!='y')) {
            return 2;
        }
    }
    cfg=cfglist;
    while (cfg!=NULL) {
        if (!strcmp(cfg->term_type,"OMR")) {
            printf("Input Phone Number for Control Centre %s ",cfg->ctrl_centre);
            InputLine(tmp);
            if (tmp[0]==0) return 0;
            printf("\n");
            sprintf(filename,CFGPATH "%2.2s\\STORE.DAT",cfg->ctrl_centre);
            if ((fp=fopen(filename,"w"))!=NULL) {
                fprintf(fp,"0000,%-35s,%-35s,1,050,N,%-15s,000,16,Y,N,21,%-20s",cfg->cc_desc,tmp,"","");
                fclose(fp);
            }
        }
        cfg=cfg->next;
    }
    return 1;
}
