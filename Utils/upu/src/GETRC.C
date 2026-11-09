//#define __GETRC_C

#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>

#include "trans_rc.h"
#include "getrc.h"

CHAR *sptab=
    "\0\0\0\0\0\0\0\0\0\1"
    "\1\0\1\1\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\1\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0"
    "\0\0\0\0\0\0\0\0\0\0" ;

BOOL ReadRCFile(CHAR *name1,CHAR *name2,CHAR **buffer,INT *fl,INT *f1l)
{
    FILE *fp;
    INT filelength1;
    INT filelength2=0;

    if ((fp=fopen(name1,"rb"))==NULL) return FALSE;
    fseek(fp,0,SEEK_END);
    filelength1=(INT)ftell(fp);
    fclose(fp);
    if ((fp=fopen(name2,"rb"))!=NULL) {
        fseek(fp,0,SEEK_END);
        filelength2=(INT)ftell(fp);
        fclose(fp);
    }

    if ((*buffer=MALLOC(filelength1+filelength2+5000))==NULL) {
        return FALSE;
    }
    if ((fp=fopen(name1,"rb"))==NULL) return FALSE;
    fread(*buffer,1,filelength1,fp);
    fclose(fp);
    if ((fp=fopen(name2,"rb"))==NULL) {
        *((*buffer)+filelength1)='\0';
    } else {
        fread(((*buffer)+filelength1),1,filelength2,fp);
        fclose(fp);
        *((*buffer)+filelength1+filelength2)='\0';
    }
    *fl=filelength1+filelength2+1;
    *f1l=filelength1;
    return TRUE;
}
CHAR *GetToken(CHAR *buffer,INT *len)
{
    CHAR *token,*line;
    BOOL isstring;

    token=buffer;

    while (sptab[*token]) token++;

    if (!*token) { *len=0; return NULL; }

    while ((*token=='\/')&&(*(token+1)=='\/')) {
        while ((*token)&&(*token!='\n')) token++;

        if (!*token) { *len=0; return NULL; }

        while (sptab[*token]) token++;

        if (!*token) { *len=0; return NULL; }
    }
    if (*token=='"') isstring=TRUE; else isstring=FALSE;

    if ((*token==',')||(*token=='|')) {
        *len=1;
        return token;
    }

    line=token;
    token++;
    while (*token) {
        if (isstring) {
            if (*token=='\\') { // skip any Escaped chars
                token++;
            } else {
                if (*token=='"') {
                    if (*(token+1)!='"') {
                        *len=(INT)(token-line)+1;
                        return line;
                    } else {
                        token++;
                    }
                }
            }
        } else {
            if ((sptab[*token])||(*token==',')||(*token=='|')) {
                *len=(INT)(token-line);
                return line;
            }
        }
        token++;
    }
    *len=(INT)(token-line);
    return line;
}
CHAR *GetNTokens(CHAR *buffer,INT *numb,CHAR **params,CHAR **capofs)
{
    CHAR *token;
    BOOL addnext=FALSE;
    INT ppos=0;
    INT len,tlen;
    INT number=*numb;
    token=buffer;

    number++;
    while ((token!=NULL)&&(number)) {
        if ((token=GetToken(token,&len))==NULL) break;
        if (!memcmp(token,"NOT",len)) {
            number++;
        } else if (*token==',') {
            number++;
        } else if (*token!='|') {
            if (addnext) {
                addnext=FALSE;
                tlen=strlen(params[ppos-1]);
                memcpy(&(params[ppos-1][tlen]),token,len);
                params[ppos-1][tlen+len]='\0';
                if (ppos-1==1) *capofs=token;
            } else {
                memcpy(params[ppos],token,len);
                params[ppos++][len]='\0';
                if (ppos-1==1) *capofs=token;
            }
        }
        if ((*GetToken(token+len,&tlen))=='|') {
            addnext=TRUE;
            number+=2;
        }
        number--;
        token+=len;
    }
    while ((token!=NULL)&&((*GetToken(token,&tlen))==',')) {
        number=1;
        (*numb)++;
        while ((token!=NULL)&&(number)) {
            if ((token=GetToken(token,&len))==NULL) break;
            if (!memcmp(token,"NOT",len)) {
                number++;
            } else if (*token==',') {
                number++;
            } else if (*token!='|') {
                if (addnext) {
                    addnext=FALSE;
                    tlen=strlen(params[ppos-1]);
                    memcpy(&(params[ppos-1][tlen]),token,len);
                    params[ppos-1][tlen+len]='\0';
                    if (ppos-1==1) *capofs=token;
                } else {
                    memcpy(params[ppos],token,len);
                    params[ppos++][len]='\0';
                    if (ppos-1==1) *capofs=token;
                }
            }
            if ((*GetToken(token+len,&tlen))=='|') {
                addnext=TRUE;
                number+=2;
            }
            number--;
            token+=len;
        }
    }
    params[ppos][0]='\0';
    return token;
}
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
CHAR *FindDCaption(CHAR *token)
{
    INT len;

    while (token!=NULL) {
        if ((token=GetToken(token,&len))==NULL) break;
        if ((!memcmp(token,"END",len))||(!memcmp(token,"}",len))) {
            return NULL;
        } else if (!memcmp(token,"CAPTION",len)) {
            token+=len;
            token=GetToken(token,&len);
            return token+1;
        } else {
            while ((*token)&&(*token!='\n')) token++;
        }
    }
    return token;
}
CHAR *SkipDialog(CHAR *token,INT *nc)
{
    INT len;

    *nc=0;
    while (token!=NULL) {
        if ((token=GetToken(token,&len))==NULL) break;
        if ((!memcmp(token,"END",len))||(!memcmp(token,"}",len))) {
            return token+len;
        } else {
            while ((*token)&&(*token!='\n')) token++;
            (*nc)++;
        }
    }
    return token;
}
CHAR *ReadDialog(CHAR *laststr,CHAR *buffer,DIALOGREC *dialog,WORD *nc,CONTROLREC *cont)
{
    static CHAR str[MAXSTRLEN];
    static BOOL doneinit=FALSE;
    static CHAR **params;
    CHAR *token,*capofs;
    CHAR use[20];
    INT len;
    INT numtok;
    INT i,j,k,l;
    token=buffer;

    if (!doneinit) {
        doneinit=TRUE;
        params=MALLOC(20*sizeof(CHAR *));
        for (i=0;i<20;i++) {
            params[i]=MALLOC(MAXSTRLEN);
        }
    }
    numtok=4;
    token=GetNTokens(token,&numtok,params,&capofs);

    if (nc!=NULL) *nc=0;
    strcpy(dialog->ident,laststr);
    dialog->x=(WORD)atoi(params[2]);
    dialog->y=(WORD)atoi(params[3]);
    dialog->w=(WORD)atoi(params[4]);
    dialog->h=(WORD)atoi(params[5]);
    dialog->fontsize=8;
    dialog->caption[0]='\0';
    strcpy(dialog->fontname,"MS Sans Serif");

    while (token!=NULL) {
        memset(use,1,20);
        if ((token=GetToken(token,&len))==NULL) break;
        memcpy(str,token,len);
        str[len]=0;
        numtok=0;
        if ((!memcmp(token,"END",len))||(!memcmp(token,"}",len))) {
            return token+len;
        } else if (!memcmp(token,"ICON",len)) {
            use[1]=use[2]=0;
            strcpy(str,"I");
            numtok=6;
        } else if (!memcmp(token,"LTEXT",len)) {
            use[2]=use[7]=0;
            strcpy(str,"L");
            numtok=6;
        } else if (!memcmp(token,"CTEXT",len)) {
            use[2]=use[7]=0;
            strcpy(str,"T");
            numtok=6;
        } else if (!memcmp(token,"RTEXT",len)) {
            use[2]=use[7]=0;
            strcpy(str,"R");
            numtok=6;
        } else if (!memcmp(token,"DEFPUSHBUTTON",len)) {
            use[2]=use[7]=0;
            strcpy(str,"D");
            numtok=6;
        } else if (!memcmp(token,"GROUPBOX",len)) {
            use[2]=use[7]=0;
            strcpy(str,"G");
            numtok=6;
        } else if (!memcmp(token,"EDITTEXT",len)) {
            use[1]=use[6]=0;
            strcpy(str,"E");
            numtok=6;
        } else if (!memcmp(token,"COMBOBOX",len)) {
            use[1]=0;
            strcpy(str,"C");
            numtok=6;
        } else if (!memcmp(token,"LISTBOX",len)) {
            use[1]=use[6]=0;
            strcpy(str,"B");
            numtok=6;
        } else if (!memcmp(token,"PUSHBUTTON",len)) {
            use[2]=use[7]=0;
            strcpy(str,"P");
            numtok=6;
        } else if (!memcmp(token,"CONTROL",len)) {
            use[2]=use[4]=0;
            strcpy(str,"O");
            numtok=8;
        } else if (!memcmp(token,"STYLE",len)) {
            use[1]=0;
            strcpy(str,"S");
            numtok=1;
        } else if (!memcmp(token,"CAPTION",len)) {
            strcpy(str,"A");
            numtok=1;
            token=GetNTokens(token,&numtok,params,&capofs);
            strcpy(dialog->caption,&(params[1][1]));
            dialog->caption[strlen(dialog->caption)-1]=0;
            numtok=0;
        } else if (!memcmp(token,"FONT",len)) {
            strcpy(str,"F");
            numtok=2;
            token=GetNTokens(token,&numtok,params,&capofs);
            dialog->fontsize=(WORD)(atoi(params[1]));
            strcpy(dialog->fontname,&(params[2][1]));
            dialog->fontname[strlen(dialog->fontname)-1]=0;
            numtok=0;
        } else if ((!memcmp(token,"BEGIN",len))||(!memcmp(token,"{",len))) {
        } else {
            while ((*token)&&(*token!='\n')) token++;
            len=0;
        }
        if (numtok!=0) {
            token=GetNTokens(token,&numtok,params,&capofs);
            cont[*nc].type=str[0];
            cont[*nc].index=(INT)cont[*nc].type;
            cont[*nc].index|=(*nc)<<8;
            j=0;
            for (i=1;i<=numtok;i++) {
                if (use[i]) {
                    if (params[i][0]=='"') {
                        if (i==1) {
                            strcpy(cont[*nc].caption,&(params[i][1]));
                            cont[*nc].caption[strlen(&(params[i][1]))-1]=0;
                            cont[*nc].bufofs=capofs+1;
                        } else {
                            strcpy(cont[*nc].caption2,&(params[i][1]));
                            cont[*nc].caption2[strlen(&(params[i][1]))-1]=0;
//                            l=0;
//                            for (k=0;k<strlen(params[i]);k++) {
//                                l<<=1;
//                                l^=(INT)params[i][k];
//                            }
//                            cont[*nc].index^=l;
                        }
                    } else {
                        cont[*nc].offset[j++]=(WORD)atoi(params[i]);
//                        cont[*nc].index^=atoi(params[i]);
                    }    
                } else {
                    l=0;
                    for (k=0;k<strlen(params[i]);k++) {
                        l<<=1;
                        l^=(INT)params[i][k];
                    }
                    cont[*nc].index^=l<<16;
                }
                params[i][0]='\0';
            }
            if (numtok>1) (*nc)++;
            len=0;
        }
        token+=len;
    }
    return token;
}
void ParseTokens(CHAR *buffer,WORD *nd,DLGPTR **dlg,STRLIST **psl)
{
    static CHAR str[MAXSTRLEN];
    static CHAR laststr[MAXSTRLEN];
    STRLIST *sl,*csl;
    DLGPTR *ldlg,*cdlg;
    CHAR *token,*lasttoken=buffer;
    INT len,nc;
    INT lastlen=0;
    INT inside=0;
    BOOL hinstrtab=FALSE;

    str[0]='\0';

    *nd=0;
    token=buffer;
    while (token!=NULL) {
        if ((token=GetToken(token,&len))==NULL) break;
        strcpy(laststr,str);
        if (*token=='"') {
            if ((inside)&&(hinstrtab)) {
                memcpy(str,token+1,len-2);
                str[len-2]=0;
                if ((sl=MALLOC(sizeof(STRLIST)))!=NULL) {
                    sl->str=token+1;
                    sl->str2=lasttoken;
                    sl->len=(WORD)(len-2);
                    sl->len2=(WORD)lastlen;
                    sl->next=NULL;
                    if (*psl==NULL) {
                        *psl=sl;
                        csl=*psl;
                    } else {
                        csl->next=sl;
                        csl=sl;
                    }
                }
            }
        } else {
            if (!memcmp(token,"STRINGTABLE",len)) {
                hinstrtab=TRUE;
            } else if (!memcmp(token,"BEGIN",len)) {
                inside++;
            } else if (!memcmp(token,"END",len)) {
                hinstrtab=FALSE;
                inside--;
            } else if (!memcmp(token,"DIALOG",len)) {
                if ((ldlg=MALLOC(sizeof(DLGPTR)))!=NULL) {
                    ldlg->offset=token;
                    ldlg->ident=lasttoken;
                    ldlg->len=(WORD)lastlen;
                    ldlg->next=NULL;
                    token=SkipDialog(token,&nc);
                    ldlg->numc=nc;
                    if (*dlg==NULL) {
                        *dlg=ldlg;
                        cdlg=*dlg;
                    } else {
                        cdlg->next=ldlg;
                        cdlg=ldlg;
                    }
                    (*nd)++;
                } else {
                    token=SkipDialog(token,&nc);
                }
                len=0;
            } else {
                memcpy(str,token,len);
                str[len]=0;
            }
        }
        lastlen=len;
        lasttoken=token;
        token+=len;
    }
}

