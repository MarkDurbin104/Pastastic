#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <dir.h>
#include <dos.h>

#include "trans_rc.h"
#include "getrc.h"

#define DLLFUNC FAR PASCAL _export
#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DIRATTR       FA_DIREC

typedef void (*CBFPTR)(WORD,WORD);

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
    static CHAR buf[MAXSTRLEN];
    static INT state=0;
    static STRLIST *msl=NULL;
    static STRLIST *sl;
    static CHAR *buffer;
    static DLGPTR *mdl=NULL;
    static DLGPTR *dl;
    static WORD    ndl,nc;
    static FILE *fp;
    CONTROLREC *control;
    DIALOGREC thedialog;
    INT j,fl,ctr;

    switch (state) {
        case 0 :
            msl=NULL;
            mdl=NULL;
            if (!ReadRCFile(ifile1,ifile2,&buffer,&fl,&fl)) {
                return -1;
            }
            if ((fp=fopen(ofile,"w"))==NULL) {
                FREE(buffer);
                return -1;
            }
            state++;
            return 1;
        case 1 :
            ParseTokens(buffer,&ndl,&mdl,&msl);
            state++;
            return 1;
        case 2 :
            ctr=0;
            while (msl!=NULL) {
                sl=msl;
                msl=msl->next;
                fprintf(fp,"S<^>%*.*s\n%*.*s\n",sl->len2,sl->len2,sl->str2,sl->len,sl->len,sl->str);
                FREE(sl);
                if (++ctr==20) return 1;
            }
            state++;
            return 1;
        case 3 :
            ctr=0;
            while (mdl!=NULL) {
                dl=mdl;
                mdl=mdl->next;
                memcpy(buf,dl->ident,dl->len);
                buf[dl->len]=0;
                if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
                    memset(control,0,dl->numc*sizeof(CONTROLREC));
                    ReadDialog(buf,dl->offset,&thedialog,&nc,control);
                    fprintf(fp,"D<^>%s\n%s\n",thedialog.ident,thedialog.caption);
                    fprintf(fp,"%d\n%s\n",thedialog.fontsize,thedialog.fontname);
                    if (adjust) {
                        fprintf(fp,"%d\n",((thedialog.x*3)/2));
                        fprintf(fp,"%d\n",((thedialog.y*8)/5));
                        fprintf(fp,"%d\n",((thedialog.w*3)/2)+6);
                        fprintf(fp,"%d\n",((thedialog.h*8)/5)+6+20);
                        fprintf(fp,"%d\n",nc);
                        for (j=0;j<nc;j++) {
                            fprintf(fp,"%c\n%s\n%s\n",control[j].type,control[j].caption,control[j].caption2);
                            fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                            fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                            fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                            fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                            fprintf(fp,"%d\n",control[j].index);
                        }
                    } else {
                        fprintf(fp,"%d\n",thedialog.x);
                        fprintf(fp,"%d\n",thedialog.y);
                        fprintf(fp,"%d\n",thedialog.w);
                        fprintf(fp,"%d\n",thedialog.h);
                        fprintf(fp,"%d\n",nc);
                        for (j=0;j<nc;j++) {
                            fprintf(fp,"%c\n%s\n%s\n",control[j].type,control[j].caption,control[j].caption2);
                            fprintf(fp,"%d\n",control[j].offset[0]);
                            fprintf(fp,"%d\n",control[j].offset[1]);
                            fprintf(fp,"%d\n",control[j].offset[2]);
                            fprintf(fp,"%d\n",control[j].offset[3]);
                            fprintf(fp,"%d\n",control[j].index);
                        }
                    }
                    FREE(control);
                }
                FREE(dl);
                if (++ctr==2) return 1;
            }
            state++;
            return 1;
    }
    fclose(fp);
    FREE(buffer);
    state=0;
    return 0;
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
    static CHAR buf[MAXSTRLEN];
    static DIALOGREC thedialog;
    static DIALOGREC dialogo;
    CONTROLREC *control;
    CONTROLREC *controlo;
    STRLIST *msl=NULL;
    STRLIST *mslo=NULL;
    STRLIST *sl;
    STRLIST *slo;
    CHAR *buffer;
    CHAR *obuffer;
    DLGPTR *mdl=NULL;
    DLGPTR *mdlo=NULL;
    DLGPTR *dl;
    DLGPTR *dlo;
    WORD    ndlo,ndl,nc,nco;
    FILE *fp;
    INT j,fl,cn;

    mkdir(basedir);
	buffer=strrchr(ifile1,'\\');
    if (buffer!=NULL) sprintf(ofile1,"%s%s",basedir,buffer+1);
	buffer=strrchr(ifile2,'\\');
    if (buffer!=NULL) sprintf(ofile2,"%s%s",basedir,buffer+1);

    if (!ReadRCFile(ifile1,ifile2,&buffer,&fl,&fl)) {
        return 0;
    }
    if ((fp=fopen(ofile,"w"))==NULL) {
        FREE(buffer);
        return 0;
    }
    ParseTokens(buffer,&ndl,&mdl,&msl);

    if (!ReadRCFile(ofile1,ofile2,&obuffer,&fl,&fl)) {
        while (msl!=NULL) {
            sl=msl;
            msl=msl->next;
            fprintf(fp,"S<^>%*.*s\n\n",sl->len2,sl->len2,sl->str2);
            FREE(sl);
        }

        while (mdl!=NULL) {
            dl=mdl;
            mdl=mdl->next;
            memcpy(buf,dl->ident,dl->len);
            buf[dl->len]=0;
            if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
                memset(control,0,dl->numc*sizeof(CONTROLREC));
                ReadDialog(buf,dl->offset,&thedialog,&nc,control);
                fprintf(fp,"D<^>%s\n\n",thedialog.ident);
                fprintf(fp,"%d\n%s\n",thedialog.fontsize,thedialog.fontname);
                if (adjust) {
                    fprintf(fp,"%d\n",((thedialog.x*3)/2));
                    fprintf(fp,"%d\n",((thedialog.y*8)/5));
                    fprintf(fp,"%d\n",((thedialog.w*3)/2)+6);
                    fprintf(fp,"%d\n",((thedialog.h*8)/5)+6+20);
                    fprintf(fp,"%d\n",nc);
                    for (j=0;j<nc;j++) {
                        fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                        fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                        fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                        fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                        fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                        fprintf(fp,"%d\n",control[j].index);
                    }
                } else {
                    fprintf(fp,"%d\n",thedialog.x);
                    fprintf(fp,"%d\n",thedialog.y);
                    fprintf(fp,"%d\n",thedialog.w);
                    fprintf(fp,"%d\n",thedialog.h);
                    fprintf(fp,"%d\n",nc);
                    for (j=0;j<nc;j++) {
                        fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                        fprintf(fp,"%d\n",control[j].offset[0]);
                        fprintf(fp,"%d\n",control[j].offset[1]);
                        fprintf(fp,"%d\n",control[j].offset[2]);
                        fprintf(fp,"%d\n",control[j].offset[3]);
                        fprintf(fp,"%d\n",control[j].index);
                    }
                }
                FREE(control);
            }                                                 
            FREE(dl);
        }
    } else {
        ParseTokens(obuffer,&ndlo,&mdlo,&mslo);
        while (msl!=NULL) {
            sl=msl;
            msl=msl->next;
            slo=FindString(mslo,sl->str2,sl->len2);
            if (slo==NULL) {
                fprintf(fp,"S<^>%*.*s\n\n",sl->len2,sl->len2,sl->str2);
            } else {
                fprintf(fp,"S<^>%*.*s\n%*.*s\n",sl->len2,sl->len2,sl->str2,slo->len,slo->len,slo->str);
            }
            FREE(sl);
        }

        while (mdl!=NULL) {
            dl=mdl;
            mdl=mdl->next;
            dlo=FindDialog(mdlo,dl->ident,dl->len);
            if (dlo==NULL) {
                memcpy(buf,dl->ident,dl->len);
                buf[dl->len]=0;
                if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
                    memset(control,0,dl->numc*sizeof(CONTROLREC));
                    ReadDialog(buf,dl->offset,&thedialog,&nc,control);
                    fprintf(fp,"D<^>%s\n\n",thedialog.ident);
                    fprintf(fp,"%d\n%s\n",thedialog.fontsize,thedialog.fontname);
                    if (adjust) {
                        fprintf(fp,"%d\n",((thedialog.x*3)/2));
                        fprintf(fp,"%d\n",((thedialog.y*8)/5));
                        fprintf(fp,"%d\n",((thedialog.w*3)/2)+6);
                        fprintf(fp,"%d\n",((thedialog.h*8)/5)+6+20);
                        fprintf(fp,"%d\n",nc);
                        for (j=0;j<nc;j++) {
                            fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                            fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                            fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                            fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                            fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                            fprintf(fp,"%d\n",control[j].index);
                        }
                    } else {
                        fprintf(fp,"%d\n",thedialog.x);
                        fprintf(fp,"%d\n",thedialog.y);
                        fprintf(fp,"%d\n",thedialog.w);
                        fprintf(fp,"%d\n",thedialog.h);
                        fprintf(fp,"%d\n",nc);
                        for (j=0;j<nc;j++) {
                            fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                            fprintf(fp,"%d\n",control[j].offset[0]);
                            fprintf(fp,"%d\n",control[j].offset[1]);
                            fprintf(fp,"%d\n",control[j].offset[2]);
                            fprintf(fp,"%d\n",control[j].offset[3]);
                            fprintf(fp,"%d\n",control[j].index);
                        }
                    }
                    FREE(control);
                }
            } else {
                memcpy(buf,dl->ident,dl->len);
                buf[dl->len]=0;
                if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
                    memset(control,0,dl->numc*sizeof(CONTROLREC));
                    ReadDialog(buf,dl->offset,&thedialog,&nc,control);
                    memcpy(buf,dlo->ident,dlo->len);
                    buf[dlo->len]=0;
                    if ((controlo=MALLOC(dlo->numc*sizeof(CONTROLREC)))!=NULL) {
                        memset(controlo,0,dlo->numc*sizeof(CONTROLREC));
                        ReadDialog(buf,dlo->offset,&dialogo,&nco,controlo);
                        fprintf(fp,"D<^>%s\n%s\n",thedialog.ident,dialogo.caption);
                        fprintf(fp,"%d\n%s\n",thedialog.fontsize,thedialog.fontname);
                        if (adjust) {
                            fprintf(fp,"%d\n",((thedialog.x*3)/2));
                            fprintf(fp,"%d\n",((thedialog.y*8)/5));
                            fprintf(fp,"%d\n",((thedialog.w*3)/2)+6);
                            fprintf(fp,"%d\n",((thedialog.h*8)/5)+6+20);
                            fprintf(fp,"%d\n",nc);
                            for (j=0;j<nc;j++) {
                                cn=FindControl(&(control[j]),controlo,nco);
                                if (cn==(-1)) {
                                    fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                                    fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                                    fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                                    fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                                    fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                                    fprintf(fp,"%d\n",control[j].index);
                                } else {
                                    fprintf(fp,"%c\n%s\n%s\n",control[j].type,controlo[cn].caption,control[j].caption2);
                                    fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                                    fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                                    fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                                    fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                                    fprintf(fp,"%d\n",control[j].index);
                                }
                            }
                        } else {
                            fprintf(fp,"%d\n",thedialog.x);
                            fprintf(fp,"%d\n",thedialog.y);
                            fprintf(fp,"%d\n",thedialog.w);
                            fprintf(fp,"%d\n",thedialog.h);
                            fprintf(fp,"%d\n",nc);
                            for (j=0;j<nc;j++) {
                                cn=FindControl(&(control[j]),controlo,nco);
                                if (cn==(-1)) {
                                    fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                                    fprintf(fp,"%d\n",control[j].offset[0]);
                                    fprintf(fp,"%d\n",control[j].offset[1]);
                                    fprintf(fp,"%d\n",control[j].offset[2]);
                                    fprintf(fp,"%d\n",control[j].offset[3]);
                                    fprintf(fp,"%d\n",control[j].index);
                                } else {
                                    fprintf(fp,"%c\n%s\n%s\n",control[j].type,controlo[cn].caption,control[j].caption2);
                                    fprintf(fp,"%d\n",control[j].offset[0]);
                                    fprintf(fp,"%d\n",control[j].offset[1]);
                                    fprintf(fp,"%d\n",control[j].offset[2]);
                                    fprintf(fp,"%d\n",control[j].offset[3]);
                                    fprintf(fp,"%d\n",control[j].index);
                                }
                            }
                        }
                        FREE(controlo);
                    }
                    FREE(control);
                }
            }
            FREE(dl);
        }
        while (mslo!=NULL) {
            sl=mslo;
            mslo=mslo->next;
            FREE(sl);
        }
        while (mdlo!=NULL) {
            dl=mdlo;
            mdlo=mdlo->next;
            FREE(dl);
        }
        FREE(obuffer);
    }

    FREE(buffer);
    fclose(fp);
    return 1;
}
WORD DLLFUNC GenETransList(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,INT adjust)
{
    static CHAR buf[MAXSTRLEN];
    static DIALOGREC thedialog;
    CONTROLREC *control;
    STRLIST *msl=NULL;
    STRLIST *sl;
    CHAR *buffer;
    DLGPTR *mdl=NULL;
    DLGPTR *dl;
    WORD    ndl,nc;
    FILE *fp;
    INT j,fl;

    if (!ReadRCFile(ifile1,ifile2,&buffer,&fl,&fl)) {
        return 0;
    }
    if ((fp=fopen(ofile,"w"))==NULL) {
        FREE(buffer);
        return 0;
    }
    ParseTokens(buffer,&ndl,&mdl,&msl);

    while (msl!=NULL) {
        sl=msl;
        msl=msl->next;
        fprintf(fp,"S<^>%*.*s\n\n",sl->len2,sl->len2,sl->str2);
        FREE(sl);
    }

    while (mdl!=NULL) {
        dl=mdl;
        mdl=mdl->next;
        memcpy(buf,dl->ident,dl->len);
        buf[dl->len]=0;
        if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
            memset(control,0,dl->numc*sizeof(CONTROLREC));
            ReadDialog(buf,dl->offset,&thedialog,&nc,control);
            fprintf(fp,"D<^>%s\n\n",thedialog.ident);
            fprintf(fp,"%d\n%s\n",thedialog.fontsize,thedialog.fontname);
            if (adjust) {
                fprintf(fp,"%d\n",((thedialog.x*3)/2));
                fprintf(fp,"%d\n",((thedialog.y*8)/5));
                fprintf(fp,"%d\n",((thedialog.w*3)/2)+6);
                fprintf(fp,"%d\n",((thedialog.h*8)/5)+6+20);
                fprintf(fp,"%d\n",nc);
                for (j=0;j<nc;j++) {
                    if ((strcmp(control[j].caption,"...")==0)
                    || (strcmp(control[j].caption,"Generic1")==0)
                    || (strcmp(control[j].caption,"Generic2")==0)
                    || (strcmp(control[j].caption,"Generic3")==0)
                    || (strcmp(control[j].caption,"Generic4")==0)) {
                        fprintf(fp,"%c\n%s\n%s\n",control[j].type,control[j].caption,control[j].caption2);
                    } else {
                        fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                    }
                    fprintf(fp,"%d\n",((control[j].offset[0]*3)/2)+3);
                    fprintf(fp,"%d\n",((control[j].offset[1]*8)/5)+23);
                    fprintf(fp,"%d\n",((control[j].offset[2]*3)/2));
                    fprintf(fp,"%d\n",((control[j].offset[3]*8)/5));
                    fprintf(fp,"%d\n",control[j].index);
                }
            } else {
                fprintf(fp,"%d\n",thedialog.x);
                fprintf(fp,"%d\n",thedialog.y);
                fprintf(fp,"%d\n",thedialog.w);
                fprintf(fp,"%d\n",thedialog.h);
                fprintf(fp,"%d\n",nc);
                for (j=0;j<nc;j++) {
                    fprintf(fp,"%c\n\n%s\n",control[j].type,control[j].caption2);
                    fprintf(fp,"%d\n",control[j].offset[0]);
                    fprintf(fp,"%d\n",control[j].offset[1]);
                    fprintf(fp,"%d\n",control[j].offset[2]);
                    fprintf(fp,"%d\n",control[j].offset[3]);
                    fprintf(fp,"%d\n",control[j].index);
                }
            }
            FREE(control);
        }                                                 
        FREE(dl);
    }

    FREE(buffer);
    fclose(fp);
    return 1;
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
FSTRLIST *FindSString(FSTRLIST *fsl,CHAR *str,INT len,CHAR *heading)
{
    static CHAR buf[MAXSTRLEN];
    sprintf(buf,"%s%*.*s",heading,len,len,str);
    while (fsl!=NULL) {
        if (!strcmp(fsl->str,buf)) return fsl->next;
        fsl=fsl->next;
    }
    return NULL;
}
INT ReplaceStr(CHAR *buffer,INT buflen,CHAR *offset,CHAR *str)
{
    INT len;
    CHAR *token;
    token=GetToken(offset-1,&len);
    if (token==offset-1) {
        if (len==strlen(str)+2) {
            memcpy(offset,str,len-2);
        } else {
            memmove(offset+strlen(str),token+(len-1),buflen-((INT)(token-buffer)+len));
            memcpy(offset,str,strlen(str));
            buflen+=strlen(str)-(len-2);
        }
    }
    return buflen;
}
FSTRLIST *FindCString(FSTRLIST *fsl,INT index,CHAR *str,INT len)
{
    static FSTRLIST *tsl;
    FSTRLIST *sl;
    int i,j,nc;
    sl=FindSString(fsl,str,len,"D<^>");
    if (sl==NULL) return NULL;
    i=7;
    while ((sl!=NULL)&&(i)) {
        i--;
        sl=sl->next;
    }
    if (sl==NULL) return NULL;
    nc=atoi(sl->str);
    for (j=0;j<nc;j++) {
        i=2;
        while ((sl!=NULL)&&(i)) {
            i--;
            sl=sl->next;
        }
        if (sl==NULL) return NULL;
        tsl=sl;
        i=6;
        while ((sl!=NULL)&&(i)) {
            i--;
            sl=sl->next;
        }
        if (sl==NULL) return NULL;
        if (atoi(sl->str)==index) {
            return tsl;
        }
    }
    return NULL;
}

WORD DLLFUNC SaveResource(CHAR *ifile1,CHAR *ifile2,CHAR *ofile,CHAR *basedir)
{
    static CHAR ofile1[MAXSTRLEN];
    static CHAR ofile2[MAXSTRLEN];
    static CHAR buf[MAXSTRLEN];
    static DIALOGREC thedialog;
    CONTROLREC *control;
    STRLIST *msl=NULL;
    STRLIST *sl;
    FSTRLIST *fsl;
    FSTRLIST *mfsl=NULL;
    CHAR *buffer;
    DLGPTR *mdl=NULL;
    DLGPTR *dl;
    WORD    ndl,nc;
    INT     j,nfl,fl,f1l;
    FILE *fp;
    INT moveofs=0,moveofs2;

    mkdir(basedir);
	buffer=strrchr(ifile1,'\\');
    if (buffer!=NULL)
        sprintf(ofile1,"%s%s",basedir,buffer+1);
    else
        sprintf(ofile1,"%s%s",basedir,ifile1);
	buffer=strrchr(ifile2,'\\');
    if (buffer!=NULL)
        sprintf(ofile2,"%s%s",basedir,buffer+1);
    else
        sprintf(ofile2,"%s%s",basedir,ifile2);

    if (!ReadRCFile(ifile1,ifile2,&buffer,&fl,&f1l)) {
        return 0;
    }
    ParseTokens(buffer,&ndl,&mdl,&msl);

    LoadStringFile(ofile,&mfsl);

    while (msl!=NULL) {
        sl=msl;
        msl=msl->next;
        fsl=FindSString(mfsl,sl->str2+moveofs,sl->len2,"S<^>");
        if ((fsl!=NULL)
        &&  ((memcmp(sl->str+moveofs,fsl->str,sl->len))
        ||   (sl->len!=strlen(fsl->str))               )   ) {
            nfl=ReplaceStr(buffer,fl,sl->str+moveofs,fsl->str);
//            if ((INT)((sl->str)-buffer)<f1l) {
                f1l+=nfl-fl;
//            }
            moveofs+=nfl-fl;
            fl=nfl;
        }
        FREE(sl);
    }

    while (mdl!=NULL) {
        dl=mdl;
        mdl=mdl->next;
        fsl=FindSString(mfsl,dl->ident+moveofs,dl->len,"D<^>");
        if (fsl!=NULL) {
            dl->offset=FindDCaption(dl->offset+moveofs);
            if (dl->offset!=NULL) {
                dl->ident+=moveofs;
                nfl=ReplaceStr(buffer,fl,dl->offset,fsl->str);
//                if ((INT)((dl->offset)-buffer)<f1l) {
//                    f1l+=nfl-fl;
//                }
                moveofs+=nfl-fl;
                fl=nfl;
                memcpy(buf,dl->ident,dl->len);
                buf[dl->len]=0;
                if ((control=MALLOC(dl->numc*sizeof(CONTROLREC)))!=NULL) {
                    memset(control,0,dl->numc*sizeof(CONTROLREC));
                    ReadDialog(buf,dl->offset,&thedialog,&nc,control);
                    moveofs2=0;
                    for (j=0;j<nc;j++) {
                        fsl=FindCString(mfsl,control[j].index,dl->ident,dl->len);
                        if ((fsl!=NULL)&&(strcmp(control[j].caption,fsl->str))) {
#ifndef BLDDLL
                            printf("%s    %s\n",control[j].caption,fsl->str);
#endif
                            nfl=ReplaceStr(buffer,fl,control[j].bufofs+moveofs2,fsl->str);
//                            if ((INT)((control[j].bufofs+moveofs2)-buffer)<f1l) {
//                                f1l+=nfl-fl;
//                            }
                            moveofs2+=nfl-fl;
                            moveofs+=nfl-fl;
                            fl=nfl;
                        }
                    }
                    FREE(control);
                }
            }      
        }      
        FREE(dl);
    }
    if ((fp=fopen(ofile1,"wb"))!=NULL) {
        fwrite(buffer,f1l,1,fp);
        fclose(fp);
    }
    if ((fp=fopen(ofile2,"wb"))!=NULL) {
        fwrite(buffer+f1l,(fl-f1l)-1,1,fp);
        fclose(fp);
    }
    FREE(buffer);
    return 1;
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
