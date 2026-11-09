/****************************************************************************
* Project     : GPA
* File        : fr.c
* Description : GPA runtime
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:15:08  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/fr.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:15:08   JGRAY
*  
* 
****************************************************************************/
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
#include <stdlib.h>
#include <time.h>

#include "gpasizes.h"
#include "types.h"
#include "config.h"
#include "formhand.h"
#include "control.h"
#include "actionc.h"

CHAR   *G_fclass[]   ={"MANDATORY","OPTIONAL","SEARCH","TEXT","MANDSRCH","MANDSECS","WAIT","DISPLAY","SECSRCH","TABLE",NULL};
CHAR   *G_formtypes[]={"FORM","SERVE","PROMPT","MENU","REPORT","PPFORM"};
CHAR   *G_acctypes[] ={"ACTION","FORM","UFUNC","CFUNC","TABLE"};

//************************************************************
//S Get text string associated with supplied idx offset by G_nut
//D n.b. G_nut is related to tildas in files - not sure how
//P integer index of text item
//R char pointer to text string

CHAR *langtext(INT idx)
{
    ENTRY(2490);
    idx+=G_nut;
    RETURNV(atextstr(idx));
}

//************************************************************
//S given a string name TEXTnnn find the associated text
//D Searches for TEXTnnn or TEXT_nnn
//P char string name of text to return
//R pointer to string

CHAR *textstr(CHAR *s)
{
    INT j;
    ENTRY(2500);
    if (s==NULL) RETURNV("NOTEXT");
    if ((G_tcnt-G_nut)==0)
        RETURNV(s);
    if (strncmp(s,"TEXT",4))
        RETURNV(s);
    if (*(s+4)=='_')
        j=atoi(s+5);
    else
        j=atoi(s+4);
    if (j>(G_tcnt-G_nut))
        RETURNV(s);
    RETURNV(langtext(j));
}

//************************************************************
//S GPA runtime    Usage - "GPA system_name"
//P integer no. of cli arguments
//P char string array - std cli arguments
//R integer return value

INT main(INT argc,CHAR *argv[]) 
{
    INT i,x;
    FILE *fp;
    PFORMF f;

    G_sstart=((_SS<<16)|_SP);
    if (argc<2)
        {
        printf("%s SYSTEM [FORM]\n",argv[0]);
        return(1);
        }
    if (!readconfig(argv[1]))
        {
        printf("Error reading config file %s.cfg\n",argv[1]);
        RETURNV(1);
        }
    G_lang=0;
    readlang(G_lang);
    freetext();
    if (!loadtext(G_system))
        {
        printf("Error reading text file \n");
        RETURNV(1);
        }
    if (!loadactions(G_system))
        {
        printf("Error reading actions file \n");
        RETURNV(1);
        }

//    addlangname(G_name);
    strcpy(G_form.name,"logon");
    G_form.items=NULL;
    if (!loadform(&G_form))
        {
        printf("Can't load form logon for %s\n",G_system);
        RETURNV(1);
        }
    fp=stdout;
    if (argc==3)
        {
//        clrform(&G_form);
        freeform(&G_form);
        strcpy(G_form.name,argv[2]);
        if (!loadform(&G_form))
            {
            printf("Can't load form [%s] for %s\n",argv[2],G_system);
            RETURNV(1);
            }
        if ((G_form.type==F_MENU)||(G_form.type==F_REPORT))
            {
            orderform(&G_form,1);
            }
        else
            {
            orderform(&G_form,0);
            }
        fprintf(fp,"Form %-8s  Type %s  Containing %d items Access level %d Update %s\n",
            G_form.name,G_formtypes[G_form.type],G_form.numitem,G_form.access,(((G_form.attribs&FA_UPDS)==FA_UPDS)?"ON":"OFF"));
        fprintf(fp,"IDX X  Y  A CLASS     S ID  FUNC      NAME       FORMAT  ITEM               \n");             
        for (i=0;i<G_form.numitem;i++)
            {
            f=&G_form.items[i];
            fprintf(fp,"%03d %02d %02d %X %-9.9s %d %02d [%-8.8s] [%-8.8s] [%4s] [%-17s] \n",
                   i,f->pos.x,f->pos.y,f->attrib,G_fclass[f->class&0x7FFF],f->size,f->ident,f->func,f->name,f->fmt,textstr(f->item));
            }
        fprintf(fp,"\n\n");
        }
    else
        {
        fprintf(fp,"%s %d Forms\n",datestr(0),G_numidx);
        for (x=0;x<G_numidx;x++)
            {
//            clrform(&G_form);
            freeform(&G_form);
            strcpy(G_form.name,G_fid[x]->name);
            if (!loadform(&G_form))
                {
                printf("Can't load form [%s] for %s\n",G_fid[x]->name,G_system);
                RETURNV(1);
                }
            if ((G_form.type==F_MENU)||(G_form.type==F_REPORT))
                {
                orderform(&G_form,1);
                }
            else
                {
                orderform(&G_form,0);
                }
            fprintf(fp,"Form %-8s  Type %s  Containing %d items Access level %d Update %s\n",
                G_form.name,G_formtypes[G_form.type],G_form.numitem,G_form.access,(((G_form.attribs&FA_UPDS)==FA_UPDS)?"ON":"OFF"));
            fprintf(fp,"IDX X  Y  A CLASS     S ID  FUNC      NAME       FORMAT  ITEM               \n");             
            for (i=0;i<G_form.numitem;i++)
                {
                f=&G_form.items[i];
                fprintf(fp,"%03d %02d %02d %X %-9.9s %d %02d [%-8.8s] [%-8.8s] [%4s] [%-17s] \n",
                    i,f->pos.x,f->pos.y,f->attrib,G_fclass[f->class&0x7FFF],f->size,f->ident,f->func,f->name,f->fmt,textstr(f->item));
                }
            fprintf(fp,"\n\n");
            }
        }
//    for (i=0;i<G_numn;i++) {
//        if (actionbuf(i)!=NULL)  {
//            printf("Action %d %-8.8s %-8.8ld,%02X,%02X,%s\n",
//                i,actionname(i),actionofs(i),actiontype(i),actiondeb(i),actionbuf(i));
//        } else {
//            printf("Action %d %-8.8s %-8.8ld,%02X,%02X\n",
//                i,actionname(i),actionofs(i),actiontype(i),actiondeb(i));
//        }
//    }
    RETURNV(0);
}
// **************************************************************************
// fr.c <end-of-file>

