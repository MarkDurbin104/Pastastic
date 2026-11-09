#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <dir.h>
#include <dos.h>

#include "trans_rc.h"

extern BOOL outdll(CHAR *name,INT e);
extern FILE *G_ofp;

#define DLLFUNC FAR PASCAL _export
#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC

typedef void (*CBFPTR)(WORD,WORD);

CHAR *StringVal(CHAR *origstr,BOOL keepcrs)
{
    static CHAR retstr[MAXSTRLEN];
    CHAR *sptr;
    CHAR *dptr;
    INT nval;
    BOOL dontend;
    dptr=retstr;
    sptr=origstr;
    while (*sptr) {
        if (*sptr=='\\') {
            if ((keepcrs)&&(*(sptr+1)=='n')) {
                sptr++;
                *(dptr++)='\n';
            } else {
                dontend=FALSE;
                if ((dptr!=retstr)&&(*(dptr-1)=='þ')) {
                    dptr--;
                } else {
                    *(dptr++)='þ';
                }
                *(dptr++)=*(sptr++);
                if ((*sptr)&&isdigit(*sptr)) {
                    nval=*(sptr++)-'0';
                    if ((*sptr)&&isdigit(*sptr)) {
                        nval*=8;
                        nval+=*(sptr++)-'0';
                        if ((*sptr)&&isdigit(*sptr)) {
                            if (nval<32) {
                                nval*=8;
                                nval+=(*sptr)-'0';
                                dontend=TRUE;
                                if (nval<256) {
                                    dptr--;
                                    if (*(dptr-1)=='þ') dptr--;
                                    *(dptr++)=(CHAR)nval;
                                } else {
                                    dptr--;
                                    if (*(dptr-1)=='þ') dptr--;
                                    *(dptr++)=(CHAR)(nval/8);
                                }
                            }
                        }
                    }
                } else {
                    *(dptr++)=*sptr;
                }
                if (!dontend) *(dptr++)='þ';
            }
        } else if (*sptr=='%') {
            if ((dptr!=retstr)&&(*(dptr-1)=='þ')) {
                dptr--;
            } else {
                *(dptr++)='þ';
            }
            *(dptr++)=*(sptr++);
            while ((*sptr)&&((*sptr=='.')||(*sptr=='*')||(*sptr=='l')||isdigit(*sptr))) {
                *(dptr++)=*(sptr++);
            }
            if ((*sptr)&&((*sptr=='s')||(*sptr=='d')||(*sptr=='f')||(*sptr=='u'))) {
                *(dptr++)=*sptr;
            } else {
                sptr--;
            }
            *(dptr++)='þ';
        } else {
            *(dptr++)=*sptr;
        }
        sptr++;
    }
    *dptr='\0';
    return retstr;
}

WORD DLLFUNC SplitString(CHAR *origstr,CHAR *list)
{
    static CHAR str[MAXSTRLEN];
    WORD        numelem=0;
    INT         len=0;
    CHAR *      tok;

    strcpy(str,StringVal(origstr,FALSE));

    if (str[0]=='þ')
        strcpy(list," \r\n");
    else
        list[0]='\0';

    tok=strtok(str,"þ");
    while (tok!=NULL) {
        numelem++;
        len+=strlen(tok)+2; if (len>255) return numelem;
        strcat(list,tok);
        strcat(list,"\r\n");
        tok=strtok(NULL,"þ");
    }

    return numelem;
}
WORD DLLFUNC CheckControlChars(CHAR *str1,CHAR *str2)
{
    static CHAR cvstr[MAXSTRLEN];
    static CHAR cpstr1[MAXSTRLEN];
    static CHAR cpstr2[MAXSTRLEN];
    CHAR *      tok;
    INT         check;


    cpstr1[0]='\0';
    strcpy(cvstr,StringVal(str1,FALSE));
    if (cvstr[0]=='þ') check=1; else check=0;
    tok=strtok(cvstr,"þ");
    while (tok!=NULL) {
        if (check) strcat(cpstr1,tok);
        check^=1;
        tok=strtok(NULL,"þ");
    }

    cpstr2[0]='\0';
    strcpy(cvstr,StringVal(str2,FALSE));
    if (cvstr[0]=='þ') check=1; else check=0;
    tok=strtok(cvstr,"þ");
    while (tok!=NULL) {
        if (check) strcat(cpstr2,tok);
        check^=1;
        tok=strtok(NULL,"þ");
    }

    return (WORD)(strcmp(cpstr1,cpstr2)==0);
}

WORD DLLFUNC GenStringList(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,INT adjust)
{
    static INT step=0;
    switch (step) {
        case 0 :
            if ((G_ofp=fopen(ofile,"w"))!=NULL) {
                step++;
                return 1;
            }
            break;
        case 1 :
            if (!outdll(ifile1,0)) {
               step=0;
               return -1;
            }
            step++;
            return 1;
        case 2 :
            if (!outdll(ifile2,0)) {
               step=0;
               return -1;
            }
            step++;
            return 1;
        case 3 :
            fclose(G_ofp);
            step=0;
            return 0;
    }
    return -1;
}
STRLIST *FindString(STRLIST *mslo,CHAR *s,INT l)
{
    STRLIST *sl;
    sl=mslo;
    while (sl!=NULL) {
        if ((!memcmp(s,sl->str2,l))&&(sl->len2==l)) {
            return sl;
        }
        sl=sl->next;
    }
    return NULL;
}
DLGPTR *FindDialog(DLGPTR *mdlo,CHAR *s,INT l)
{
    DLGPTR *dl;
    dl=mdlo;
    while (dl!=NULL) {
        if ((!memcmp(s,dl->ident,l))&&(dl->len==l)) {
            return dl;
        }
        dl=dl->next;
    }
    return NULL;
}
INT FindControl(CONTROLREC *cont,CONTROLREC *controlo,INT nco)
{
    INT cn;
    for (cn=0;cn<nco;cn++) {
        if (cont->index==controlo[cn].index) {
            return cn;
        }
    }
    return -1;
}

WORD DLLFUNC GenTransList(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,CHAR *basedir,INT adjust)
{
    static CHAR ofile1[MAXSTRLEN];
    static CHAR ofile2[MAXSTRLEN];
    CHAR *buffer;

    mkdir(basedir);
	buffer=strrchr(ifile1,'\\');
    if (buffer!=NULL) sprintf(ofile1,"%s%s",basedir,buffer+1);
	buffer=strrchr(ifile2,'\\');
    if (buffer!=NULL) sprintf(ofile2,"%s%s",basedir,buffer+1);

    if ((G_ofp=fopen(ofile,"w"))!=NULL) {
        if (!outdll(ofile1,0)) outdll(ifile1,1);
        if (!outdll(ofile2,0)) outdll(ifile2,1);
        fclose(G_ofp);
        return 1;
    }
    return -1;
}
WORD DLLFUNC GenETransList(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,INT adjust)
{
    if ((G_ofp=fopen(ofile,"w"))!=NULL) {
        outdll(ifile1,1);
        outdll(ifile2,1);
        fclose(G_ofp);
        return 1;
    }
    return -1;
}
void LoadStringFile(CHAR *name,FSTRLIST **cfsl)
{
    static CHAR buf[MAXSTRLEN];
    FSTRLIST *mfsl=NULL;
    FSTRLIST *fsl;
    FILE *fp;

    if ((fp=fopen(name,"r"))==NULL) {
        return;
    }
    while (fgets(buf,MAXSTRLEN,fp)!=NULL) {
        buf[strlen(buf)-1]='\0';
        if ((fsl=MALLOC(sizeof(FSTRLIST)))!=NULL) {
            fsl->str=STRDUP(buf);
            fsl->next=NULL;
        }
        if (mfsl==NULL) {
            mfsl=fsl;
            *cfsl=mfsl;
        } else {
            mfsl->next=fsl;
            mfsl=mfsl->next;
        }
    }
    fclose(fp);
}
WORD DLLFUNC SaveResource(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,CHAR *basedir)
{
    return 0;
}
void DLLFUNC ListLangs(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,CHAR *basedir)
{
    static CHAR base[MAXSTRLEN];
    FSTRLIST *fsl=NULL;
    FSTRLIST *sl;
    CHAR *file1;
    CHAR *file2;
    FILE *fp;
    struct ffblk f;
    int done;

	file1=strrchr(ifile1,'\\');
    if (file1==NULL) file1=ifile1; else file1++;
	file2=strrchr(ifile2,'\\');
    if (file2==NULL) file2=ifile2; else file2++;
    
    sprintf(base,"%s*.*",basedir);
    done=findfirst(base,&f,DIRATTR);
    while (done!=(-1)) {
        if ((strcmp(f.ff_name,"."))&&(strcmp(f.ff_name,".."))&&(f.ff_attrib&DIRATTR)) {
            if ((sl=MALLOC(sizeof(FSTRLIST)))!=NULL) {
                sl->str=STRDUP(f.ff_name);
                sl->next=fsl;
                fsl=sl;
            }
        }
        done=findnext(&f);
    }
    sl=fsl;
    while (sl!=NULL) {
        sprintf(base,"%s%s\\%s",basedir,sl->str,file1);
        done=findfirst(base,&f,FILEATTR);
        if (done!=(-1)) {
            sprintf(base,"%s%s\\%s",basedir,sl->str,file2);
            done=findfirst(base,&f,FILEATTR);
            if (done==(-1)) {
                FREE(sl->str);
                sl->str=NULL;
            }
        } else {
            FREE(sl->str);
            sl->str=NULL;
        }
        sl=sl->next;
    }
    if ((fp=fopen(ofile,"w"))!=NULL) {
        while (fsl!=NULL) {
            sl=fsl;
            fsl=fsl->next;
            if (sl->str!=NULL) {
                fprintf(fp,"%s\n",sl->str);
                FREE(sl->str);
            }
            FREE(sl);
        }
        fclose(fp);
    }
}

#ifndef BLDDLL
int main(void)
{
    ListLangs("\\ips96trans\\scures.rc","\\ips96trans\\ips96ures.rc","LANGLIST.STR","c:\\upu\\");
    return 1;
}
#endif
