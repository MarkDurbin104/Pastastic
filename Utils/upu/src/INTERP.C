#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <ctype.h>
#include <time.h>


typedef char CHAR;
typedef int  INT ;
typedef int  BOOL;
typedef long LONG;

#define MAXSTRLEN   512
#define TRUE        1
#define FALSE       0
#define MALLOC      malloc
#define FREE        free
#define STRDUP      strdup

#define STRING      1
#define BEGIN       2
#define END         3
#define DIALOG      4
#define ICON        5
#define BITMAP      6
#define STRINGTABLE 7

char *sptab=
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

CHAR *G_dialogs[200];
INT  G_numdialogs=0;

BOOL ReadFile(CHAR *name,CHAR **buffer)
{
    FILE *fp;
    INT filelength;

    if ((fp=fopen(name,"rb"))==NULL) return FALSE;
    fseek(fp,0,SEEK_END);
    filelength=(INT)ftell(fp);
    fseek(fp,0,SEEK_SET);

    if ((*buffer=MALLOC(filelength+1))==NULL) {
        fclose(fp);
        return FALSE;
    }
    fread(*buffer,1,filelength,fp);
    *((*buffer)+filelength)='\0';
    fclose(fp);
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
CHAR *GetNTokens(CHAR *buffer,INT *numb,CHAR **params)
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
            } else {
                memcpy(params[ppos],token,len);
                params[ppos++][len]='\0';
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
                } else {
                    memcpy(params[ppos],token,len);
                    params[ppos++][len]='\0';
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
CHAR *StringVal(CHAR *origstr)
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
CHAR *ReadDialog(CHAR *laststr,CHAR *buffer)
{
    static CHAR str[MAXSTRLEN];
    static BOOL doneinit=FALSE;
    static CHAR **params;
    CHAR *token;
    CHAR use[20];
    INT len;
    INT numtok;
    INT i;
    token=buffer;

    if (!doneinit) {
        doneinit=TRUE;
        params=MALLOC(20*sizeof(CHAR *));
        for (i=0;i<20;i++) {
            params[i]=MALLOC(MAXSTRLEN);
        }
    }
    numtok=4;
    token=GetNTokens(token,&numtok,params);
    G_dialogs[G_numdialogs++]=strdup(laststr);
//    printf("* %d ",numtok);
//    for (i=1;i<=numtok;i++) printf("%s%c",params[i],((i<numtok)?',':'þ'));
//    printf("\n");

    while (token!=NULL) {
        memset(use,1,20);
        if ((token=GetToken(token,&len))==NULL) break;
        memcpy(str,token,len);
        str[len]=0;
        numtok=0;
        if ((!memcmp(token,"END",len))||(!memcmp(token,"}",len))) {
//            printf("\n");
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
        } else if (!memcmp(token,"FONT",len)) {
            strcpy(str,"F");
            numtok=2;
        } else if ((!memcmp(token,"BEGIN",len))||(!memcmp(token,"{",len))) {
        } else {
//            printf("?(%s)",str);
            while ((*token)&&(*token!='\n')) token++;
            len=0;
        }
        if (numtok!=0) {
            token=GetNTokens(token,&numtok,params);
//            printf("%s %d ",str,numtok);
//            for (i=1;i<=numtok;i++) {
//                if (use[i]) {
//                    if (params[i][0]=='"') {
//                        printf("%s%c",StringVal(params[i]),((i<numtok)?'þ':' '));
//                    } else {
//                        printf("%s%c",params[i],((i<numtok)?'þ':' '));
//                    }    
//                }
//            }
//            printf("\n");
            len=0;
        }
        token+=len;
    }
    return token;
}
void ParseTokens(CHAR *buffer)
{
    static CHAR str[MAXSTRLEN];
    static CHAR laststr[MAXSTRLEN];
    CHAR *token;
    INT len;
    INT inside=0;
    BOOL hinstrtab=FALSE;

    str[0]='\0';

    token=buffer;
    while (token!=NULL) {
        if ((token=GetToken(token,&len))==NULL) break;
        strcpy(laststr,str);
        if (*token=='"') {
            if ((inside)&&(hinstrtab)) {
                memcpy(str,token+1,len-2);
                str[len-2]=0;
//                printf("STRING %s %s\n",laststr,StringVal(str));
            }
        } else {
            if (!memcmp(token,"STRINGTABLE",len)) {
                hinstrtab=TRUE;
            } else if (!memcmp(token,"BEGIN",len)) {
                inside++;
            } else if (!memcmp(token,"END",len)) {
//                if (hinstrtab) printf("\n");
                hinstrtab=FALSE;
                inside--;
            } else if (!memcmp(token,"DIALOG",len)) {
                token=ReadDialog(laststr,token);
                len=0;
            } else {
                memcpy(str,token,len);
                str[len]=0;
            }
        }
        token+=len;
    }
}
INT main(INT argc,CHAR *argv[])
{
    CHAR *buffer=NULL;
    if (argc<2) {
//        printf("%s filename\n",argv[0]);
        return 1;
    }
    if (!ReadFile(argv[1],&buffer)) {
        printf("%s File Read Error\n",argv[1]);
        return 1;
    }
    ParseTokens(buffer);
    FREE(buffer);
    return 0;
}
