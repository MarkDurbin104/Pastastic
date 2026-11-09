#ifndef TESTING
#include <windows.h>
#endif

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <ctype.h>
#include <stdarg.h>
#include "types.h"
#include "deballoc.h"
#include "tintext.h"

#ifdef TESTING
#include <graphics.h>
#else
FILE *G_fp;
BOOL G_firstln=TRUE;
#include "graph.h"
#endif

#define BOXWID   (7*10)     // 10 characters of 7 width
#define BOXSEPER 50
#define TEXTHGT  14         // 14 points high
#define TUBEHGT  TEXTHGT
#define TUBEDHGT (TUBEHGT*3)
#define TUBEDWID (7*20)     // 20 characters of 7 width
#define TUBEDOFS 14
#define BOXSPACE (TUBEDWID+(TUBEDOFS*2)+TUBEDHGT+3)
#define YUNITMID 10

#define LEFT    (-75)
#define RGT     (-77)
#define UP      (-72)
#define DOWN    (-80)
#define HOME    (-71)
#define END     (-79)
#define PGUP    (-73)
#define PGDN    (-81)
#define CLEFT   (-115)
#define CRGT    (-116)
#define CUP     (-141)
#define CDOWN   (-145)
#define ESC     27

typedef struct REC {
    CHAR *buf;
    struct REC *next;
    struct REC *prev;
} RECORD;

typedef struct DR {
    CHAR *row;
    CHAR *type;
    INT  length;
    INT  dlength;
    INT  offset;
    struct DR *next;
} DEFROW;

typedef struct DB {
    CHAR *table;
    CHAR *file;
    int  rlen;
    DEFROW *rows;
    RECORD *rec;
    struct DB *next;
} DEFBLK;

typedef struct CLNK {
    LONG st;
    LONG ed;
    LONG v;
    struct CLNK *next;
} CLINK;

typedef struct TB {
   LONG  fbpid;    // fibre bundle part id (0=empty (-1)=blocked)
   LONG  fbpfid;   // fibre bundle from nap feat_num
   CHAR *fbpfcd;   // fibre bundle from nap code
   LONG  fbptid;   // fibre bundle to   nap feat_num
   CHAR *fbptcd;   // fibre bundle to   nap code
   LONG  bftquid1;  // bft equipment bft section feat_num 1
   INT   bftqutn1;  // bft equipment bft section tube number 1
   LONG  bftquid2;  // bft equipment bft section feat_num 2
   INT   bftqutn2;  // bft equipment bft section tube number 2
   LONG  bftqunid; // bft equipment nap feat_num
} TUBE;
typedef struct SECT {
    INT   depth ;  // used to order naps
    LONG  napfid;  // nap   from feat_num
    CHAR *napfcd;  // nap   from code
    LONG  jntfid;  // jount from feat_num
    CHAR *jntfcd;  // jount from code
    LONG  naptid;  // nap   to   feat_num
    CHAR *naptcd;  // nap   to   code
    LONG  jnttid;  // jount to   feat_num
    CHAR *jnttcd;  // jount to   code
    LONG  bftsid;  // bft section id
    CHAR *bftscd;  // bft section code
    CHAR *bfttcd;  // bft section type 
    LONG  bftnum;  // bft number
    CHAR *bftacd;  // bft alloc code
    LONG  bftlen;  // bft length
    INT   bfttnt;  // bft section number of tubes
    INT   blockh;  // block height 
    TUBE tubes[7]; // tube information
    struct SECT *next;
} SECTION;

SECTION G_section;
SECTION *G_sections=NULL;

LONG G_napnum  =0L;
LONG G_bftnum  =0L;
LONG G_bftbtnum=0L;
LONG G_bftenum =0L;
LONG G_bftjnum =0L;
LONG G_bftsnum =0L;
LONG G_bfttnum =0L;
LONG G_fbnum   =0L;
LONG G_fbpnum  =0L;
INT  G_fromto  =0;
INT  G_group   =0;
DEFBLK *G_defs =NULL;
BOOL G_setup=FALSE;
CHAR G_path[LINELEN];
INT G_maxy=0;
INT G_maxx=0;
DEFBLK *G_bft_j_table =NULL;
DEFBLK *G_nap_table   =NULL;
DEFBLK *G_fb_table    =NULL;
DEFBLK *G_bft_table   =NULL;
DEFBLK *G_bft_bt_table=NULL;
DEFBLK *G_fbp_table   =NULL;
DEFBLK *G_bft_e_table =NULL;
DEFBLK *G_bft_t_table =NULL;
DEFBLK *G_bft_s_table =NULL;

void ClearSection(SECTION *s)
{
    int i;
    if (s==NULL) return;
    if (PTRCHECK(s->napfcd)) FREE(s->napfcd);
    if (PTRCHECK(s->jntfcd)) FREE(s->jntfcd);
    if (PTRCHECK(s->naptcd)) FREE(s->naptcd);
    if (PTRCHECK(s->jnttcd)) FREE(s->jnttcd);
    if (PTRCHECK(s->bftscd)) FREE(s->bftscd);
    if (PTRCHECK(s->bfttcd)) FREE(s->bfttcd);
    if (PTRCHECK(s->bftacd)) FREE(s->bftacd);
    for (i=0;i<s->bfttnt;i++) {
        if (PTRCHECK(s->tubes[i].fbpfcd)) FREE(s->tubes[i].fbpfcd);
        if (PTRCHECK(s->tubes[i].fbptcd)) FREE(s->tubes[i].fbptcd);
    }
    memset(s,0,sizeof(SECTION));
}
void FreeSections(void)
{
    SECTION *s;
    while (G_sections!=NULL) {
        s=G_sections;
        G_sections=G_sections->next;
        ClearSection(s);
        FREE(s);
    }
    G_sections=NULL;
    ClearSection(&G_section);
}
SECTION *AddSection(void)
{
    SECTION *s;
    SECTION *i;
    if ((s=MALLOC(sizeof(SECTION)))==NULL) return NULL;
    memcpy(s,&G_section,sizeof(SECTION));
    s->next=NULL;
    if (G_sections==NULL) {
        G_sections=s;
    } else {
        i=G_sections;
        while (i->next!=NULL) i=i->next;
        i->next=s;
    }
    memset(&G_section,0,sizeof(SECTION));
    return s;
}
DEFBLK *NewDef(CHAR *t,CHAR *f,DEFBLK **p)
{
    DEFBLK *newp=MALLOC(sizeof(DEFBLK));
    if (newp==NULL) return NULL;
    newp->table=t;
    newp->file=STRDUP(f);
    newp->rows=NULL;
    newp->rec=NULL;
    newp->rlen=0;
    newp->next=*p;
    *p=newp;
    return newp;
}
BOOL AddDef(DEFBLK *cb,CHAR *name,CHAR *type,INT length)
{
    DEFROW *newr=MALLOC(sizeof(DEFROW));
    DEFROW *tmp;
    if (newr==NULL) return FALSE;
    if (cb==NULL) return FALSE;
    newr->row=name;
    newr->type=type;
    newr->length=length;
    if (strlen(name)>length) {
        newr->dlength=strlen(name);
    } else {
        newr->dlength=length;
    }
    if (newr->dlength>80) newr->dlength=80;
    if (length==1) newr->dlength=1;
    newr->next=NULL;
    newr->offset=0;
    if (cb->rows==NULL) {
        cb->rows=newr;
    } else {
        tmp=cb->rows;
        while (tmp->next!=NULL) {
            newr->offset+=tmp->dlength;
            tmp=tmp->next;
        }
        newr->offset+=tmp->dlength;
        tmp->next=newr;
    }
    cb->rlen=newr->offset+newr->dlength;
    return TRUE;
}
BOOL ReadTableDefs(CHAR *file,DEFBLK **p)
{
    FILE *fp;
    CHAR buf[LINELEN];
    CHAR *t,*name,*type;
    INT length;
    BOOL intable=FALSE;
    DEFBLK *cb=NULL;

    if ((fp=fopen(file,"r"))==NULL) return FALSE;
    while (fgets(buf,LINELEN,fp)!=NULL) {
        strupr(buf);
        t=strtok(buf," \r\n\t");
        if (t!=NULL) {
            if (intable) {
                if (*t=='}') {
                    intable=FALSE;
                } else if (*t!=';') {
                    name=STRDUP(t);
                    if (name==NULL) return FALSE;
                    t=strtok(NULL," \r\n\t");
                    if (t!=NULL) {
                        type=STRDUP(t);
                        if (type==NULL) return FALSE;
                        t=strtok(NULL," \r\n\t");
                        if (t!=NULL) {
                            length=atoi(t);
                            if (length==0) return FALSE;
                            if (!AddDef(cb,name,type,length))
                                return FALSE;
                        }
                    }
                }
            } else {
                if (!strcmp(t,"TABLE")) {
                    intable=TRUE;
                    t=strtok(NULL," \r\n\t");
                    if (t!=NULL) {
                        name=STRDUP(t);
                        if (name==NULL) return FALSE;
                        t=strtok(NULL," \r\n\t");
                        if (t!=NULL) {
                            cb=NewDef(name,t,p);
                            if (cb==NULL) return FALSE;
                        }
                    }
                }
            }
        }
    }
    fclose(fp);
    return TRUE;
}
void PrintTableDefs(DEFBLK *p)
{
    DEFROW *row;
    while (p!=NULL) {
        printf("TABLE %s %s [%d] {\n",p->table,p->file,p->rlen);
        row=p->rows;
        while (row!=NULL) {
            printf("   %-30s %-10s %4d from %4d to %4d\n",row->row,row->type,row->length,row->offset,row->offset+row->length-1);
            row=row->next;
        }
        p=p->next;
        printf("}\n\n");
    }
}
BOOL CheckLine(char *buf)
{
    if ((strlen(buf)>4)&&(!memcmp(buf,"SQL> ",5))) return FALSE;
    while (*buf) {
        if (!isspace(*buf)) return TRUE;
        buf++;
    }
    return FALSE;
}
BOOL ReadData(FILE *fp,CHAR *buf,INT length,BOOL first)
{
    static char inbuf[1000];
    static INT lastlen=0;
    static INT lastpos=0;
    if (buf==NULL) {
        lastlen=0;
        lastpos=0;
        return TRUE;
    }
    if (lastpos+length<lastlen) {
        memcpy(buf,inbuf+lastpos,length);
        lastpos+=length+1;
    } else {
        while (fgets(inbuf,85,fp)!=NULL) {
            if (strlen(inbuf)>2) {
                inbuf[strlen(inbuf)-1]=0;
                if ((!first)||(CheckLine(inbuf))) {
                    lastlen=strlen(inbuf);
                    lastpos=length+1;
                    memcpy(buf,inbuf,min(length,strlen(inbuf)+1));
                    return TRUE;
                }
            }
        }
        return FALSE;
    }
    return TRUE;
}
void AddRecord(DEFBLK *p,CHAR *buf)
{
    RECORD *rec;

    if ((rec=MALLOC(sizeof(RECORD)))==NULL) return;
    if ((rec->buf=MALLOC(p->rlen))==NULL) return;
    memcpy(rec->buf,buf,p->rlen);
    rec->next=p->rec;
    p->rec=rec;
}
CHAR * RemStEdSpace(CHAR *str)
{
    CHAR *eptr;
    eptr=str+strlen(str)-1;
    while ((*str)&&(isspace(*str))) str++;
    while ((eptr!=str)&&(isspace(*eptr)))  *(eptr--)=0;
    return str;
}
CHAR *rowdata(CHAR *buf,INT o,INT l)
{
    static CHAR tmp[LINELEN];
    memcpy(tmp,buf+o,l); tmp[l]=0;
    strcpy(tmp,RemStEdSpace(tmp));
    return tmp;
}
void BFT_J_Data(DEFBLK *p,CHAR *buf,CHAR **id,CHAR **fn,CHAR **tp)
{
    static CHAR fnbuf[LINELEN];
    static CHAR idbuf[LINELEN];
    static CHAR tpbuf[LINELEN];
    static INT fno,fnl;
    static INT ido,idl;
    static INT tpo,tpl;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_j_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BFT_JOINTS")) {
                G_bft_j_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BJ_ID")) {
                        ido=row->offset;
                        idl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"FEAT_NUM")) {
                        fno=row->offset;
                        fnl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BJ_TYPE")) {
                        tpo=row->offset;
                        tpl=row->dlength;
                        alldone++;
                    }
                    if (alldone==3) break;
                    row=row->next;
                }
            }
            if (alldone==3) break;
            p=p->next;
        }
        if (alldone!=3) {
            fprintf(stderr,"Error in table definitions BFT_J\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(idbuf,rowdata(buf,ido,idl)); *id=idbuf;
    strcpy(fnbuf,rowdata(buf,fno,fnl)); *fn=fnbuf;
    strcpy(tpbuf,rowdata(buf,tpo,tpl)); *tp=tpbuf;
}

void NAP_Data(DEFBLK *p,CHAR *buf,CHAR **nn,CHAR **ct,CHAR **fn,CHAR **ac)
{
    static CHAR nnbuf[LINELEN];
    static CHAR ctbuf[LINELEN];
    static CHAR fnbuf[LINELEN];
    static CHAR acbuf[LINELEN];
    static INT nno,nnl;
    static INT cto,ctl;
    static INT fno,fnl;
    static INT aco,acl;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_nap_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"NETWORK_ACCESS_POINTS")) {
                G_nap_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"NAP_NO")) {
                        nno=row->offset;
                        nnl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"CTG")) {
                        cto=row->offset;
                        ctl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"FEAT_NUM")) {
                        fno=row->offset;
                        fnl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"FP_ACP_CD")) {
                        aco=row->offset;
                        acl=row->dlength;
                        alldone++;
                    }
                    if (alldone==4) break;
                    row=row->next;
                }
            }
            if (alldone==4) break;
            p=p->next;
        }
        if (alldone!=4) {
            fprintf(stderr,"Error in table definitions NAP\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(nnbuf,rowdata(buf,nno,nnl)); *nn=nnbuf;
    strcpy(ctbuf,rowdata(buf,cto,ctl)); *ct=ctbuf;
    strcpy(fnbuf,rowdata(buf,fno,fnl)); *fn=fnbuf;
    strcpy(acbuf,rowdata(buf,aco,acl)); *ac=acbuf;
}
void FB_Data(DEFBLK *p,CHAR *buf,CHAR **id,CHAR **sn,CHAR **en)
{
    static CHAR idbuf[LINELEN];
    static CHAR snbuf[LINELEN];
    static CHAR enbuf[LINELEN];
    static INT ido,idl;
    static INT sno,snl;
    static INT eno,enl;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_fb_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"FIBRE_BUNDLES")) {
                G_fb_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"FBB_ID")) {
                        ido=row->offset;
                        idl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"START_NAP_FEAT_NUM")) {
                        sno=row->offset;
                        snl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"END_NAP_FEAT_NUM")) {
                        eno=row->offset;
                        enl=row->dlength;
                        alldone++;
                    }
                    if (alldone==3) break;
                    row=row->next;
                }
            }
            if (alldone==3) break;
            p=p->next;
        }
        if (alldone!=3) {
            fprintf(stderr,"Error in table definitions FB\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(idbuf,rowdata(buf,ido,idl)); *id=idbuf;
    strcpy(snbuf,rowdata(buf,sno,snl)); *sn=snbuf;
    strcpy(enbuf,rowdata(buf,eno,enl)); *en=enbuf;
}
void BFT_Data(DEFBLK *p,CHAR *buf,CHAR **cd,CHAR **al,CHAR **no)
{
    static CHAR cdbuf[LINELEN];
    static CHAR albuf[LINELEN];
    static CHAR nobuf[LINELEN];
    static INT cdo,cdl;
    static INT alo,all;
    static INT noo,nol;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BLOWN_FIBRE_TUBES")) {
                G_bft_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BFT_CD")) { // !! change to BFT_ID with new data
                        cdo=row->offset;    
                        cdl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"AL_CD")) {
                        alo=row->offset;
                        all=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BFT_NO")) {
                        noo=row->offset;
                        nol=row->dlength;
                        alldone++;
                    }
                    if (alldone==3) break;
                    row=row->next;
                }
            }
            if (alldone==3) break;
            p=p->next;
        }
        if (alldone!=3) {
            fprintf(stderr,"Error in table definitions BFT\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(cdbuf,rowdata(buf,cdo,cdl)); *cd=cdbuf;
    strcpy(albuf,rowdata(buf,alo,all)); *al=albuf;
    strcpy(nobuf,rowdata(buf,noo,nol)); *no=nobuf;
}
void BFT_BT_Data(DEFBLK *p,CHAR *buf,CHAR **id,CHAR **no)
{
    static CHAR idbuf[LINELEN];
    static CHAR nobuf[LINELEN];
    static INT ido,idl;
    static INT noo,nol;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_bt_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BFT_BLOCKED_TUBES")) {
                G_bft_bt_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BS_ID")) {
                        ido=row->offset;
                        idl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS_TUBE_NO")) {
                        noo=row->offset;
                        nol=row->dlength;
                        alldone++;
                    }
                    if (alldone==2) break;
                    row=row->next;
                }
            }
            if (alldone==2) break;
            p=p->next;
        }
        if (alldone!=2) {
            fprintf(stderr,"Error in table definitions BFT_BT\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(idbuf,rowdata(buf,ido,idl)); *id=idbuf;
    strcpy(nobuf,rowdata(buf,noo,nol)); *no=nobuf;
}
void FBP_Data(DEFBLK *p,CHAR *buf,CHAR **id,CHAR **fb,CHAR **bs)
{
    static CHAR idbuf[LINELEN];
    static CHAR fbbuf[LINELEN];
    static CHAR bsbuf[LINELEN];
    static INT ido;
    static INT fbo;
    static INT bso;
    static INT idl;
    static INT fbl;
    static INT bsl;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_fbp_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"FIBRE_BUNDLE_PARTS")) {
                G_fbp_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BS_ID")) {
                        ido=row->offset;
                        idl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"FBB_ID")) {
                        fbo=row->offset;
                        fbl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS_TUBE_NO")) {
                        bso=row->offset;
                        bsl=row->dlength;
                        alldone++;
                    }
                    if (alldone==3) break;
                    row=row->next;
                }
            }
            if (alldone==3) break;
            p=p->next;
        }
        if (alldone!=3) {
            fprintf(stderr,"Error in table definitions FBP\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(idbuf,rowdata(buf,ido,idl)); *id=idbuf;
    strcpy(fbbuf,rowdata(buf,fbo,fbl)); *fb=fbbuf;
    strcpy(bsbuf,rowdata(buf,bso,bsl)); *bs=bsbuf;
}
void BFT_E_Data(DEFBLK *p,CHAR *buf,CHAR **i1,CHAR **i2,CHAR **t1,CHAR **t2)
{
    static CHAR i1buf[LINELEN];
    static CHAR t1buf[LINELEN];
    static CHAR i2buf[LINELEN];
    static CHAR t2buf[LINELEN];
    static INT i1o,i1l;
    static INT t1o,t1l;
    static INT i2o,i2l;
    static INT t2o,t2l;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_e_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BFT_EQUIPMENT")) {
                G_bft_e_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BS1_ID")) {
                        i1o=row->offset;
                        i1l=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS2_ID")) {
                        i2o=row->offset;
                        i2l=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS1_TUBE_NO")) {
                        t1o=row->offset;
                        t1l=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS2_TUBE_NO")) {
                        t2o=row->offset;
                        t2l=row->dlength;
                        alldone++;
                    }
                    if (alldone==4) break;
                    row=row->next;
                }
            }
            if (alldone==4) break;
            p=p->next;
        }
        if (alldone!=4) {
            fprintf(stderr,"Error in table definitions BFT_E\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(i1buf,rowdata(buf,i1o,i1l)); *i1=i1buf;
    strcpy(t1buf,rowdata(buf,t1o,t1l)); *t1=t1buf;
    strcpy(i2buf,rowdata(buf,i2o,i2l)); *i2=i2buf;
    strcpy(t2buf,rowdata(buf,t2o,t2l)); *t2=t2buf;
}
void BFT_T_Data(DEFBLK *p,CHAR *buf,CHAR **bt,CHAR **bq)
{
    static CHAR btbuf[LINELEN];
    static CHAR bqbuf[LINELEN];
    static INT bto,btl;
    static INT bqo,bql;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_t_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BFT_TYPES")) {
                G_bft_t_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"BFT_TYPE")) {
                        bto=row->offset;
                        btl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BFTT_TUBES_QTY")) {
                        bqo=row->offset;
                        bql=row->dlength;
                        alldone++;
                    }
                    if (alldone==2) break;
                    row=row->next;
                }
            }
            if (alldone==2) break;
            p=p->next;
        }
        if (alldone!=2) {
            fprintf(stderr,"Error in table definitions BFT_T\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(btbuf,rowdata(buf,bto,btl)); *bt=btbuf;
    strcpy(bqbuf,rowdata(buf,bqo,bql)); *bq=bqbuf;
}
void BFT_S_Data(DEFBLK *p,CHAR *buf,CHAR **sn,CHAR **en,CHAR **bt,CHAR **bc,CHAR **bi,CHAR **bl,CHAR **si,CHAR **ei)
{
    static CHAR snbuf[LINELEN];
    static CHAR enbuf[LINELEN];
    static CHAR btbuf[LINELEN];
    static CHAR bcbuf[LINELEN];
    static CHAR bibuf[LINELEN];
    static CHAR blbuf[LINELEN];
    static CHAR sibuf[LINELEN];
    static CHAR eibuf[LINELEN];
    static INT sno,snl;
    static INT eno,enl;
    static INT bto,btl;
    static INT bco,bcl;
    static INT bio,bil;
    static INT blo,bll;
    static INT sio,sil;
    static INT eio,eil;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
        G_bft_s_table=NULL;
        setup=FALSE;
        return;
    }
    if (!setup) {
        alldone=0;
        while (p!=NULL) {
            if (!strcmp(p->table,"BFT_SECTIONS")) {
                G_bft_s_table=p;
                row=p->rows;
                while (row!=NULL) {
                    if (!strcmp(row->row,"START_NAP_FEAT_NUM")) {
                        sno=row->offset;
                        snl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"END_NAP_FEAT_NUM")) {
                        eno=row->offset;
                        enl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS_TYPE")) {
                        bto=row->offset;
                        btl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BFT_CD")) {
                        bco=row->offset;
                        bcl=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS_ID")) {
                        bio=row->offset;
                        bil=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"BS_LN_M")) {
                        blo=row->offset;
                        bll=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"START_BJ_ID")) {
                        sio=row->offset;
                        sil=row->dlength;
                        alldone++;
                    } else if (!strcmp(row->row,"END_BJ_ID")) {
                        eio=row->offset;
                        eil=row->dlength;
                        alldone++;
                    }
                    if (alldone==8) break;
                    row=row->next;
                }
            }
            if (alldone==8) break;
            p=p->next;
        }
        if (alldone!=8) {
            fprintf(stderr,"Error in table definitions BFT_S\n");
            exit(-1);
        }
        setup=TRUE;
    }
    if (buf==NULL) return;
    strcpy(snbuf,rowdata(buf,sno,snl)); *sn=snbuf;
    strcpy(enbuf,rowdata(buf,eno,enl)); *en=enbuf;
    strcpy(btbuf,rowdata(buf,bto,btl)); *bt=btbuf;
    strcpy(bcbuf,rowdata(buf,bco,bcl)); *bc=bcbuf;
    strcpy(bibuf,rowdata(buf,bio,bil)); *bi=bibuf;
    strcpy(blbuf,rowdata(buf,blo,bll)); *bl=blbuf;
    strcpy(sibuf,rowdata(buf,sio,sil)); *si=sibuf;
    strcpy(eibuf,rowdata(buf,eio,eil)); *ei=eibuf;
}
void PrintTables(DEFBLK *p)
{
    DEFROW *row;
    RECORD *rec;
    int l;
    CHAR tmp[LINELEN];
    while (p!=NULL) {
        row=p->rows;
        while (row!=NULL) {
            row->length=strlen(row->row);
            row=row->next;
        }
        rec=p->rec;
        while (rec!=NULL) {
            row=p->rows;
            while (row!=NULL) {
                sprintf(tmp,"%*.*s",row->dlength,row->dlength,rec->buf+(row->offset));
                l=strlen(RemStEdSpace(tmp));
                row->length=max(row->length,l);
                row=row->next;
            }
            rec=rec->next;
        }
        printf("TABLE %s [%s.LST]\n",p->table,p->file);
        row=p->rows;
        while (row!=NULL) {
            if (row->type[0]!='N')
                printf("%-*.*s ",row->length,row->length,row->row);
            else
                printf("%*.*s ",row->length,row->length,row->row);
            row=row->next;
        }
        printf("\n");
        rec=p->rec;
        while (rec!=NULL) {
            row=p->rows;
            while (row!=NULL) {
                sprintf(tmp,"%*.*s",row->dlength,row->dlength,rec->buf+(row->offset));
                if (row->type[0]!='N')
                    printf("%-*.*s ",row->length,row->length,RemStEdSpace(tmp));
                else
                    printf("%*.*s ",row->length,row->length,RemStEdSpace(tmp));
                row=row->next;
            }
            printf("\n");
            rec=rec->next;
        }
        p=p->next;
    }
}
void GetStats(DEFBLK *p)
{
    LONG *num;
    CHAR *t;
    RECORD *rec;
    while (p!=NULL) {
        t=strrchr(p->file,'\\');
        if (t!=NULL) t++; else t=p->file;
        if      (!strcmp(t,"NAP"   )) num=&G_napnum  ;
        else if (!strcmp(t,"BFT"   )) num=&G_bftnum  ;
        else if (!strcmp(t,"BFT_BT")) num=&G_bftbtnum;
        else if (!strcmp(t,"BFT_E" )) num=&G_bftenum ;
        else if (!strcmp(t,"BFT_J" )) num=&G_bftjnum ;
        else if (!strcmp(t,"BFT_S" )) num=&G_bftsnum ;
        else if (!strcmp(t,"BFT_T" )) num=&G_bfttnum ;
        else if (!strcmp(t,"FB"    )) num=&G_fbnum   ;
        else if (!strcmp(t,"FBP"   )) num=&G_fbpnum  ;
        (*num)=0;
        rec=p->rec;
        while (rec!=NULL) {
            (*num)++;
            rec=rec->next;
        }
        p=p->next;
    }
}
void ReadTables(DEFBLK *p,CHAR *path)
{
    DEFROW *row;
    CHAR file[100],*buf;
    BOOL dataOK,FirstRow;
    BOOL chkcty;
    BOOL skiprow;
    FILE *fp;
    while (p!=NULL) {
        if (!strcmp(p->table,"NETWORK_ACCESS_POINTS")) chkcty=TRUE; else chkcty=FALSE;
        sprintf(file,"%s%s.LST",path,p->file);
        if ((fp=fopen(file,"r"))!=NULL) {
            if ((buf=MALLOC(p->rlen))==NULL) {
                fclose(fp);
                return;
            }
            dataOK=TRUE;
            while (dataOK) {
                row=p->rows;
                FirstRow=TRUE;
                skiprow=FALSE;
                while ((row!=NULL)&&(dataOK)) {
                    dataOK=ReadData(fp,buf+(row->offset),row->dlength,FirstRow);
                    if (row==p->rows) {
                        memcpy(file,buf+(row->offset),row->dlength); file[row->dlength]=0;
                        if (atol(RemStEdSpace(file))==0L)
                            skiprow=FALSE;
                        else
                            skiprow=TRUE;
                    } else if ((chkcty)&&(!strcmp(row->row,"CTG"))) {
                        memcpy(file,buf+(row->offset),row->dlength); file[row->dlength]=0;
                        strcpy(file,RemStEdSpace(file));
                        if (((file[0]!='T')&&(file[0]!='Y'))||(file[1]!='U')) skiprow=TRUE;
                    }
                    FirstRow=FALSE;
                    if (dataOK) {
                        row=row->next;
                    }
                }
                ReadData(fp,NULL,0,0);
                if ((dataOK)&&(!skiprow)) {
                    AddRecord(p,buf);
                }
            }
            FREE(buf);
            fclose(fp);
        }
        p=p->next;
    }
}
BOOL readvblk(CHAR **buf,FILE *fp)
{
    INT lb;
    if (fread(&lb,sizeof(INT),1,fp)!=1) return FALSE;
    if ((*buf=MALLOC(lb))==NULL) return FALSE;
    if (fread(*buf,1,lb,fp)!=lb) return FALSE;
    return TRUE;
}
BOOL readfblk(void *buf,FILE *fp,INT len)
{
    if (fread(buf,1,len,fp)!=len) return FALSE;
    return TRUE;
}
BOOL GetSavedTable(CHAR *file,DEFBLK **defs)
{
    DEFBLK *def;
    DEFROW *row,*erow=NULL;
    RECORD *rec,*erec=NULL;
    FILE *fp;
    int i,j,numdef,numrow,numrec;

    if ((fp=fopen(file,"rb"))==NULL) return FALSE;
    if (!readfblk((void *)&numdef,fp,sizeof(INT))) { fclose(fp); return FALSE; }
    for (i=0;i<numdef;i++) {
        if ((def=MALLOC(sizeof(DEFBLK)))==NULL) { fclose(fp); return FALSE; }
        if (!readvblk(&(def->table),fp))             { fclose(fp); return FALSE; }
        if (!readvblk(&(def->file ),fp))             { fclose(fp); return FALSE; }
        if (!readfblk((void *)&(def->rlen ),fp,sizeof(INT))) { fclose(fp); return FALSE; }
        if (!readfblk((void *)&numrow,fp,sizeof(INT))) { fclose(fp); return FALSE; }
        def->rows=NULL;
        
        for (j=0;j<numrow;j++) {
            if ((row=MALLOC(sizeof(DEFROW)))==NULL) { fclose(fp); return FALSE; }
            if (!readvblk(&(row->row),fp))             { fclose(fp); return FALSE; }
            if (!readvblk(&(row->type),fp))             { fclose(fp); return FALSE; }
            if (!readfblk((void *)&(row->length),fp ,sizeof(INT))) { fclose(fp); return FALSE; }
            if (!readfblk((void *)&(row->dlength),fp,sizeof(INT))) { fclose(fp); return FALSE; }
            if (!readfblk((void *)&(row->offset ),fp,sizeof(INT))) { fclose(fp); return FALSE; }
            row->next=NULL;
            if (def->rows==NULL) {
                def->rows=row;
            } else {
                erow->next=row;
            }
            erow=row;
        }
        if (!readfblk((void *)&numrec,fp,sizeof(INT))) { fclose(fp); return FALSE; }
        def->rec=NULL;
        for (j=0;j<numrec;j++) {
            if ((rec=MALLOC(sizeof(RECORD)))==NULL) { fclose(fp); return FALSE; }
            if (!readvblk(&(rec->buf),fp))             { fclose(fp); return FALSE; }
            rec->next=NULL;
            if (def->rec==NULL) {
                def->rec=rec;
            } else {
                erec->next=rec;
            }
            erec=rec;
        }
        def->next=(*defs);
        (*defs)=def;
    }
    fclose(fp);
    return(TRUE);
}
BOOL writevblk(CHAR *buf,FILE *fp)
{
    INT lb;
    lb=strlen(buf)+1;
    if (fwrite(&lb,sizeof(INT),1,fp)!=1) return FALSE;
    if (fwrite(buf,1,lb,fp)!=lb) return FALSE;
    return TRUE;
}
BOOL writefblk(void *buf,FILE *fp,INT len)
{
    if (fwrite(buf,1,len,fp)!=len) return FALSE;
    return TRUE;
}
BOOL StoreTable(CHAR *file,DEFBLK *defs)
{
    DEFBLK *def;
    DEFROW *row;
    RECORD *rec;
    FILE *fp;
    INT numitem;

    if ((fp=fopen(file,"wb"))==NULL) return FALSE;
    def=defs;
    numitem=0;
    while (def!=NULL) {
        numitem++;
        def=def->next;
    }
    if (!writefblk((void *)&numitem,fp,sizeof(INT))) { fclose(fp); return FALSE; }
    def=defs;
    while (def!=NULL) {
        if (!writevblk((def->table),fp))             { fclose(fp); return FALSE; }
        if (!writevblk((def->file ),fp))             { fclose(fp); return FALSE; }
        if (!writefblk((void *)&(def->rlen ),fp,sizeof(INT))) { fclose(fp); return FALSE; }
        row=def->rows;
        numitem=0;
        while (row!=NULL) {
            numitem++;
            row=row->next;
        }
        if (!writefblk((void *)&numitem,fp,sizeof(INT))) { fclose(fp); return FALSE; }
        row=def->rows;
        while (row!=NULL) {
            if (!writevblk((row->row),fp))             { fclose(fp); return FALSE; }
            if (!writevblk((row->type),fp))             { fclose(fp); return FALSE; }
            if (!writefblk((void *)&(row->length),fp ,sizeof(INT))) { fclose(fp); return FALSE; }
            if (!writefblk((void *)&(row->dlength),fp,sizeof(INT))) { fclose(fp); return FALSE; }
            if (!writefblk((void *)&(row->offset ),fp,sizeof(INT))) { fclose(fp); return FALSE; }
            row=row->next;
        }
        rec=def->rec;
        numitem=0;
        while (rec!=NULL) {
            numitem++;
            rec=rec->next;
        }
        if (!writefblk((void *)&numitem,fp,sizeof(INT))) { fclose(fp); return FALSE; }
        rec=def->rec;
        while (rec!=NULL) {
            if (!writevblk((rec->buf),fp))             { fclose(fp); return FALSE; }
            rec=rec->next;
        }
        def=def->next;
    }
    fclose(fp);
    return(TRUE);
}
void FreeTableDefs(DEFBLK **p)
{
    DEFBLK *lastb;
    DEFROW *lastr;
    RECORD *lastrec;
    if (p==NULL) return;
    while (*p!=NULL) {
        lastb=*p;
        *p=(*p)->next;
        while (lastb->rows!=NULL) {
            lastr=lastb->rows;
            lastb->rows=(lastb->rows)->next;
            if (lastr->row!=NULL) FREE(lastr->row);
            if (lastr->type!=NULL) FREE(lastr->type);
            FREE (lastr);
        }
        while (lastb->rec!=NULL) {
            lastrec=lastb->rec;
            lastb->rec=(lastb->rec)->next;
            if (lastrec->buf!=NULL) FREE(lastrec->buf);
            FREE(lastrec);
        }
        if (lastb->table!=NULL) FREE(lastb->table);
        if (lastb->file!=NULL) FREE(lastb->file);
        FREE(lastb);
    }
}
BOOL HadConnect(LONG snap,LONG bfts,LONG enap)
{
    static CLINK *list=NULL;
    CLINK *new;
    if (snap==(-2)) {
        while (list!=NULL) {
            new=list;
            list=list->next;
            FREE(new);
        }
        return TRUE;
    }
    new=list;
    while (new!=NULL) {
        if (new->v==bfts) {
            if (((new->st==snap)&&(new->ed==enap))
            ||  ((new->ed==snap)&&(new->st==enap)))
                return TRUE;

        }
        new=new->next;
    }
    if ((new=MALLOC(sizeof(CLINK)))==NULL) return FALSE;
    new->st=snap;
    new->ed=enap;
    new->v=bfts;
    new->next=list;
    list=new;
    return FALSE;
}
LONG FindJointNap(LONG bjid,DEFBLK *p,CHAR *jtb)
{
    RECORD *rec;
    CHAR *bj,*fn,*bt;
    if (G_bft_j_table==NULL) BFT_J_Data(p,NULL,&bj,&fn,&bt);
    if (G_bft_j_table==NULL) return 0L;
    p=G_bft_j_table;
    rec=p->rec;
    while (rec!=NULL) {
        BFT_J_Data(p,rec->buf,&bj,&fn,&bt);
        if (bjid==atol(bj)) {
            strcpy(jtb,bt);
            return atol(fn);
        }
        rec=rec->next;
    }
    return 0L;
}
CHAR *Cat(LONG napid,DEFBLK *p)
{
    static CHAR ret[LINELEN];
    RECORD *rec;
    CHAR *nn,*ct,*fn,*fa;
    if (G_nap_table==NULL) NAP_Data(p,NULL,&nn,&ct,&fn,&fa);
    if (G_nap_table==NULL) return "??";
    p=G_nap_table;
    rec=p->rec;
    while (rec!=NULL) {
        NAP_Data(p,rec->buf,&nn,&ct,&fn,&fa);
        if (napid==atol(fn)) {
            sprintf(ret,"%s%s%s",fa,ct,nn);
            return ret;
        }
        rec=rec->next;
    }
    return "??";
}
void FromToFibre(LONG fb,DEFBLK *p,INT tn)
{
    RECORD *rec;
    CHAR *id,*sn,*en;
    if (G_fb_table==NULL) FB_Data(p,NULL,&id,&sn,&en);
    if (G_fb_table==NULL) return;
    rec=G_fb_table->rec;
    while (rec!=NULL) {
        FB_Data(p,rec->buf,&id,&sn,&en);
        if (fb==atol(id)) {
            G_section.tubes[tn-1].fbpfid=atol(sn);
            G_section.tubes[tn-1].fbpfcd=STRDUP(Cat(atol(sn),p));
            G_section.tubes[tn-1].fbptid=atol(en);
            G_section.tubes[tn-1].fbptcd=STRDUP(Cat(atol(en),p));
            return;
        }
        rec=rec->next;
    }
}
LONG FindFibres(LONG bs,INT tn,DEFBLK *p)
{
    RECORD *rec;
    CHAR *id,*fb,*tu;
    if (G_fbp_table==NULL) FBP_Data(p,NULL,&id,&fb,&tu);
    if (G_fbp_table==NULL) return 0L;
    rec=G_fbp_table->rec;
    while (rec!=NULL) {
        FBP_Data(p,rec->buf,&id,&fb,&tu);
        if ((bs==atol(id))&&(tn==atoi(tu))) {
            FromToFibre(atol(fb),p,tn);
            return atol(fb);
        }
        rec=rec->next;
    }
    return 0L;
}
void GetBFT_NCD(CHAR *bscd,DEFBLK *p) // bscd change to bsid with new data
{                                             
    RECORD *rec;
    CHAR *cd,*al,*no;
    if (G_bft_table==NULL) BFT_Data(p,NULL,&cd,&al,&no);
    if (G_bft_table==NULL) return;
    p=G_bft_table;
    rec=p->rec;
    while (rec!=NULL) {
        BFT_Data(p,rec->buf,&cd,&al,&no);
        if (!strcmp(bscd,cd)) {
            G_section.bftnum=atol(no);
            G_section.bftacd=STRDUP(al);
            return;
        }
        rec=rec->next;
    }
}
BOOL Blocked(LONG bs,INT tn,DEFBLK *p)
{
    RECORD *rec;
    CHAR *id,*tu;
    if (G_bft_bt_table==NULL) BFT_BT_Data(p,NULL,&id,&tu);
    if (G_bft_bt_table==NULL) return FALSE;
    p=G_bft_bt_table;
    rec=p->rec;
    while (rec!=NULL) {
        BFT_BT_Data(p,rec->buf,&id,&tu);
        if ((bs==atol(id))&&(tn==atoi(tu))) return TRUE;
        rec=rec->next;
    }
    return FALSE;
}
void GetEquipment(LONG bsid,INT tn,DEFBLK *p)
{
    RECORD *rec;
    CHAR *id1,*tu1,*id2,*tu2;
    if (G_bft_e_table==NULL) BFT_E_Data(p,NULL,&id1,&tu1,&id2,&tu2);
    if (G_bft_e_table==NULL) return;
    rec=G_bft_e_table->rec;
    while (rec!=NULL) {
        BFT_E_Data(p,rec->buf,&id1,&tu1,&id2,&tu2);
        if ((atol(id1)==bsid)&&(atoi(tu1)==tn)) {
            G_section.tubes[tn-1].bftquid1=bsid;
            G_section.tubes[tn-1].bftqutn1=tn;
            G_section.tubes[tn-1].bftquid2=atol(id2);
            G_section.tubes[tn-1].bftqutn2=atoi(tu2);
            return;
        }
        if ((atol(id2)==bsid)&&(atoi(tu2)==tn)) {
            G_section.tubes[tn-1].bftquid1=bsid;
            G_section.tubes[tn-1].bftqutn1=tn;
            G_section.tubes[tn-1].bftquid2=atol(id1);
            G_section.tubes[tn-1].bftqutn2=atoi(tu1);
            return;
        }
        rec=rec->next;
    }
}
void SectionType(CHAR *bstype,LONG bs,DEFBLK *p)
{
    INT nt,tn;
    RECORD *rec;
    CHAR *bt,*bq;
    if (G_bft_t_table==NULL) BFT_T_Data(p,NULL,&bt,&bq);
    if (G_bft_t_table==NULL) return;
    rec=G_bft_t_table->rec;
    while (rec!=NULL) {
        BFT_T_Data(p,rec->buf,&bt,&bq);
        if (!strcmp(bt,bstype)) {
            nt=atoi(bq);
            G_section.bfttnt=nt;
            for (tn=1;tn<=nt;tn++) {
                GetEquipment(bs,tn,p);
                if (Blocked(bs,tn,p)) {
                    G_section.tubes[tn-1].fbpid=(-1);
                } else {
                    G_section.tubes[tn-1].fbpid=FindFibres(bs,tn,p);
                }
            }
            return;
        }
        rec=rec->next;
    }
}
int FindBFT_S(LONG fnum,LONG exclude,DEFBLK *p,DEFBLK *base,INT sto,INT stl,INT edo,INT edl,INT bso,INT bsl,BOOL first,INT depth)
{
    static CHAR tmp[LINELEN];
    static CHAR jt[12];
//    static INT bll=0;
    static CHAR cs,ce;
    INT bh=0,h,lh=0;
    SECTION *sect;
    LONG st,ed,bs,tnap;
    CHAR *tcd;

    RECORD *rec;
    CHAR *sn,*en,*bt,*bcd,*bid,*bl,*sj,*ej;
    if (G_bft_s_table==NULL) BFT_S_Data(p,NULL,&sn,&en,&bt,&bcd,&bid,&bl,&sj,&ej);
    if (G_bft_s_table==NULL) return 0;
    rec=G_bft_s_table->rec;
    while (rec!=NULL) {
        BFT_S_Data(p,rec->buf,&sn,&en,&bt,&bcd,&bid,&bl,&sj,&ej);
        ClearSection(&G_section);
        st=atol(sn);
        if (st==0) {
            if (atol(sj)!=0L) {
                st=FindJointNap(atol(sj),base,jt);
                G_section.jntfid=st;
                G_section.jntfcd=STRDUP(jt);
            }
        }
        G_section.napfid=st;
        ed=atol(en);
        if (ed==0) {
            if (atol(ej)!=0L) {
                ed=FindJointNap(atol(ej),base,jt);
                G_section.jnttid=ed;
                G_section.jnttcd=STRDUP(jt);
            }
        }
        G_section.naptid=ed;
        strcpy(tmp,Cat(st,base)); cs=tmp[0];
        G_section.napfcd=STRDUP(tmp);
        strcpy(tmp,Cat(ed,base)); ce=tmp[0];
        G_section.naptcd=STRDUP(tmp);
        if ((cs=='F')&&(ce=='F')) {
            if ((st==fnum)&&(ed!=exclude)&&(ed!=0L)) {
                bs=atol(bid);
                G_section.bftsid=bs;
                if (!HadConnect(st,bs,ed)) {
                    G_section.bftscd=STRDUP(bcd);
                    G_section.bfttcd=STRDUP(bt);
                    SectionType(bt,bs,base);
                    G_section.bftlen=atol(bl);
                    GetBFT_NCD(G_section.bftscd,base);
                    G_section.depth=depth;
                    sect=AddSection();
                    bh++;
                    h=FindBFT_S(ed,st,p,base,sto,stl,edo,edl,bso,bsl,FALSE,depth+1);
                    sect->blockh=h;
                    lh+=h;
                }
            } else if ((G_fromto==1)&&(ed==fnum)&&(st!=exclude)&&(st!=0L)&&(first)) {
                bs=atol(bid);
                G_section.bftsid=bs;
                if (!HadConnect(st,bs,ed)) {
                    G_section.bftscd=STRDUP(bcd);
                    G_section.bfttcd=STRDUP(bt);
                    SectionType(bt,bs,base);
                    G_section.bftlen=atol(bl);
                    GetBFT_NCD(G_section.bftscd,base);
                    tnap=G_section.naptid;
                    G_section.naptid=G_section.napfid;
                    G_section.napfid=tnap;
                    tnap=G_section.jnttid;
                    G_section.jnttid=G_section.jntfid;
                    G_section.jntfid=tnap;
                    tcd=G_section.naptcd;
                    G_section.naptcd=G_section.napfcd;
                    G_section.napfcd=tcd;
                    tcd=G_section.jnttcd;
                    G_section.jnttcd=G_section.jntfcd;
                    G_section.jntfcd=tcd;
                    G_section.depth=0-depth;
                    sect=AddSection();
                    bh++;
                    h+=FindBFT_S(st,ed,p,base,sto,stl,edo,edl,bso,bsl,first,depth-1);
                    sect->blockh=h;
                    lh+=h;
                }
            }
        }
        rec=rec->next;
    }
    return max(bh,lh);
}
//============================================================================
//F grafix
//S switch the screen into graphics mode
//D switch the screen into graphics mode using the borland 
//D graphics functions
void grafix(void)
{
    int GraphDriver = DETECT;                 /* Request auto-detection       */
    int GraphMode;
    int ErrorCode;
    initgraph( &GraphDriver, &GraphMode, "e:\\bc45\\bgi" );
    ErrorCode = graphresult();            /* Read result of initialization*/
    if( ErrorCode != grOk ){              /* Error occured during init    */
        printf(" Graphics System Error: %s\n", grapherrormsg( ErrorCode ) );
        exit( 1 );
    }
}
void outxy(INT x,INT y,CHAR *fmt,...)
{
#ifdef DRAW_TEXT
	INT xp,yp,i,mx;
	UCHAR *t,,*s;
#endif
    UCHAR tmp[LINELEN];
	va_list ap;
	va_start(ap,fmt);
	vsprintf((CHAR *)tmp,fmt,ap);
	va_end(ap);

#ifndef DRAW_TEXT
    outtextxy(x,y,(CHAR *)tmp);
#else
    x-=strlen((CHAR *)tmp)*3;
	s=tmp;
	y+=9;
	while (*s) {
		mx=0;
		if ((*s>31)&&(*s<=127)) {
			i=G_charofs[*s-32];
			t=G_chardefs+i;
			i=((G_charofs[*s-31]-i)/2)-1;
			while (i--) {
				xp=(*t&0x3F)-(64*((*(t++)&0x40)!=0));
				yp=(*t&0x3F)-(64*((*(t  )&0x40)!=0));
				if (!(*(t)&0x80)) {
					moveto(x+xp,y-yp);
				} else {
					lineto(x+xp,y-yp);
				}
			  	mx=max(mx,x+xp);
				t++;
			}
		}
		s++;
		x=mx;
	}
#endif
}

int CountTubes(SECTION *sect,BOOL group)
{
    INT i,cnt=0;
    BOOL tog=FALSE;
    if (group) {
        for (i=0;i<sect->bfttnt;i++) {
            if (sect->tubes[i].fbpid<1) {
                if (tog) cnt++;
                tog=TRUE;
            } else {
                tog=FALSE;
            }
        }
    }
    return sect->bfttnt-cnt;
}
int BoxHeight(LONG fid)
{
    SECTION *all;
    INT h=0,bh;
    BOOL hadone=FALSE;
    INT th=0;
    all=G_sections;
    while (all!=NULL) {
        if (all->napfid==fid) {
            th+=CountTubes(all,G_group)*TUBEHGT;
            bh=BoxHeight(all->naptid);
            if (bh==0) {
                h+=CountTubes(all,G_group)*TUBEHGT;
            } else {
                h+=bh;
            }
            if (hadone) h+=BOXSEPER+TUBEDHGT;
            hadone=TRUE;
        }
        all=all->next;
    }
    h=max(h,th);
    return h;
}
void TubeBore(INT x,INT y,INT r,INT t,INT bt,INT ut)
{
    circle(x,y,r);
    t--;
    if ((ut&(1<<t))!=0) {
        setcolor(14);
        circle(x,y,r-1);
        circle(x,y,r-2);
        setcolor(15);
    }
    if ((bt&(1<<t))!=0) {
        setcolor(12);
        line(x-r,y,x+r,y);
        line(x,y-r,x,y+r);
        setcolor(15);
    }
}
void DrawTube(INT x,INT y,INT nt,INT bt,INT ut)
{
    int bsize;
    x+=TUBEDHGT/2+1;
    y+=TEXTHGT/2;
    circle(x,y,TUBEDHGT/2);
    bsize=TUBEDHGT/7;

    switch (nt) {
        case 1 :
            TubeBore(x   ,y  ,bsize,1,bt,ut);
            break;
        case 2 :
            TubeBore(x   ,y-6,bsize,1,bt,ut);
            TubeBore(x   ,y+6,bsize,2,bt,ut);
            break;
        case 4 :
            TubeBore(x-6 ,y-6,bsize,1,bt,ut);
            TubeBore(x-6 ,y+6,bsize,2,bt,ut);
            TubeBore(x+6 ,y-6,bsize,3,bt,ut);
            TubeBore(x+6 ,y+6,bsize,4,bt,ut);
            break;
        case 7 :
            TubeBore(x         ,y            ,bsize,1,bt,ut);
            TubeBore(x+bsize*2 ,y            ,bsize,2,bt,ut);
            TubeBore(x+bsize   ,y+(bsize*7)/4,bsize,3,bt,ut);
            TubeBore(x-bsize   ,y+(bsize*7)/4,bsize,4,bt,ut);
            TubeBore(x-bsize*2 ,y            ,bsize,5,bt,ut);
            TubeBore(x-bsize   ,y-(bsize*7)/4,bsize,6,bt,ut);
            TubeBore(x+bsize   ,y-(bsize*7)/4,bsize,7,bt,ut);
            break;
        default :
            outxy(x,y-TEXTHGT/2,"UNKNOWN");
    }
}
void GasSeal(INT x,INT y,BOOL FlatLeft,BOOL Permanent)
{
    if (Permanent) {
        if (FlatLeft) {
            line(x-4,y-4,x-4,y+4);
            line(x-6,y-4,x-6,y+4);
            arc(x-4,y,270,90,4);
        } else {
            line(x+4,y-4,x+4,y+4);
            line(x+6,y-4,x+6,y+4);
            arc(x+4,y,90,270,4);
        }
    } else {
        if (FlatLeft) {
            line(x-4,y-4,x-4,y+4);
            line(x-6,y-4,x-6,y+4);
            arc(x-4,y,270,90,4);
        } else {
            line(x+4,y-4,x+4,y+4);
            line(x+6,y-4,x+6,y+4);
            arc(x+4,y,90,270,4);
        }
    }
}
INT DrawTubes(INT x,INT y,SECTION *all)
{
    INT i,cnt=0,pos=0;
    BOOL tog=FALSE;
    INT bt,ut,tx;

    setcolor(15);
    bt=0;
    ut=0;
    if (G_group) {
        for (i=0;i<all->bfttnt;i++) {
            if (all->tubes[i].fbpid<1) {
                if (all->tubes[i].fbpid==(-1)) bt|=(1<<i);
                if (tog) {
                    cnt++;
                    pos++;
                } else {
                    GasSeal(x+BOXWID-3,y+TUBEHGT/2+(i-pos)*TUBEHGT,1,all->tubes[i].bftquid1!=0);
                    line(x+BOXWID-3,y+TUBEHGT/2+(i-pos)*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+(i-pos)*TUBEHGT);
                    GasSeal(x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+(i-pos)*TUBEHGT,0,all->tubes[i].bftquid1!=0);
                }
                tog=TRUE;
            } else {
                if (tog) {
                    if (cnt==0) {
                        outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+(i-(pos+1))*TEXTHGT-TEXTHGT/2,"%s%d",((i-cnt==1)?"  TUBE":"      "),i-cnt);
                    } else {
                        outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+(i-(pos+1))*TEXTHGT-TEXTHGT/2,"%s%d-%d",((i-cnt==1)?"TUBE":"    "),i-cnt,i);
                    }
                }
                cnt=0;
                outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+(i-pos)*TEXTHGT-TEXTHGT/2,"%s%d",((i==0)?"  TUBE":"      "),i+1);
                tog=FALSE;
                if (all->tubes[i].bftquid1) {
                    setcolor(15);
                    circle(x+BOXWID/2,y+TUBEHGT/2+(i-pos)*TUBEHGT,1);
                    circle(x+BOXWID/2,y+TUBEHGT/2+(i-pos)*TUBEHGT,2);
                    if (all->naptcd[1]=='T') {
                        line(x+BOXWID/2,y+TUBEHGT/2+(i-pos)*TUBEHGT,x+BOXWID+BOXSPACE+BOXWID/2,y+TUBEHGT/2+(i-pos)*TUBEHGT);
                    } else {
                        line(x+BOXWID/2,y+TUBEHGT/2+(i-pos)*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+(i-pos)*TUBEHGT);
                    }
                } else {
                    line(x+BOXWID-3,y+TUBEHGT/2+(i-pos)*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+(i-pos)*TUBEHGT);
                }
                ut|=(1<<i);
            }
        }
        if (tog) {
            if (cnt==0) {
                outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+(i-(pos+1))*TEXTHGT-TEXTHGT/2,"%s%d",((i-cnt==1)?"  TUBE":"      "),i-cnt);
            } else {
                outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+(i-(pos+1))*TEXTHGT-TEXTHGT/2,"%s%d-%d",((i-cnt==1)?"TUBE":"    "),i-cnt,i);
            }
        }
        i-=pos;
    } else {
        for (i=0;i<all->bfttnt;i++) {
            outxy(x+BOXWID+TUBEDOFS+TUBEDWID/2+TUBEDHGT/2,y+i*TEXTHGT-TEXTHGT/2,"%s%d",((i==0)?"TUBE":"    "),i+1);
            switch (all->tubes[i].fbpid) {
                case 0  :
                    GasSeal(x+BOXWID-3,y+TUBEHGT/2+i*TUBEHGT,1,all->tubes[i].bftquid1!=0);
                    line(x+BOXWID-3,y+TUBEHGT/2+i*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+i*TUBEHGT);
                    GasSeal(x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+i*TUBEHGT,0,all->tubes[i].bftquid1!=0);
                    break;
                case -1 :
                    bt|=(1<<i);
                    GasSeal(x+BOXWID-3,y+TUBEHGT/2+i*TUBEHGT,1,all->tubes[i].bftquid1!=0);
                    line(x+BOXWID,y+TUBEHGT/2+i*TUBEHGT,x+BOXWID+BOXSPACE,y+TUBEHGT/2+i*TUBEHGT);
                    GasSeal(x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+i*TUBEHGT,0,all->tubes[i].bftquid1!=0);
                    break;
                default:
                    if (all->tubes[i].bftquid1) {
                        setcolor(15);
                        circle(x+BOXWID/2,y+TUBEHGT/2+i*TUBEHGT,1);
                        circle(x+BOXWID/2,y+TUBEHGT/2+i*TUBEHGT,2);
                        if (all->naptcd[1]=='T') {
                            line(x+BOXWID/2,y+TUBEHGT/2+i*TUBEHGT,x+BOXWID+BOXSPACE+BOXWID/2,y+TUBEHGT/2+i*TUBEHGT);
                        } else {
                            line(x+BOXWID/2,y+TUBEHGT/2+i*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+i*TUBEHGT);
                        }
                    } else {
                        line(x+BOXWID-3,y+TUBEHGT/2+i*TUBEHGT,x+BOXWID+BOXSPACE+3,y+TUBEHGT/2+i*TUBEHGT);
                    }
                    ut|=(1<<i);
            }
        }
    }
    tx=x+BOXWID+TUBEDOFS;
    rectangle(tx,y+(i+1)*TEXTHGT,tx+TUBEDWID,y+(i+1)*TEXTHGT+TUBEDHGT);
    line     (tx,y+(i+2)*TEXTHGT,tx+TUBEDWID,y+(i+2)*TEXTHGT);
    line     (tx,y+(i+3)*TEXTHGT,tx+TUBEDWID,y+(i+3)*TEXTHGT);
    outxy(tx+15,y+i*TEXTHGT,"%ld.%03ld",all->bftlen/1000L,all->bftlen%1000L);
    tx+=TUBEDWID/2;
    outxy(tx,y+(i+1)*TEXTHGT,"%s",all->bftscd);
    outxy(tx,y+(i+2)*TEXTHGT,"%s",all->bfttcd);
    outxy(tx,y+(i+3)*TEXTHGT,"%s %d",all->bftacd,all->bftnum);
    DrawTube(tx+TUBEDWID/2,y+(i+2)*TEXTHGT,all->bfttnt,bt,ut);
    return y+i*TEXTHGT;
}
int PrintSubSections(LONG fid,INT x,INT y)
{
    INT ny,boxtop=y,boxbot;
    INT oy;
    BOOL firstsect=TRUE;
    SECTION *all;


    ny=y+BoxHeight(fid);
    if (ny==y) return y;
    all=G_sections;
    while (all!=NULL) {
        if (all->napfid==fid) {
            if (firstsect) {
                setcolor(15);
                if (all->jntfid) {
                    outxy(x+BOXWID/2,y-TEXTHGT*2,"%c%s",all->napfcd[1],(all->napfcd)+3,all->bfttnt);
                    outxy(x+BOXWID/2,y-TEXTHGT,"%s",all->jntfcd);
                } else {
                    outxy(x+BOXWID/2,y-TEXTHGT,"%c%s",all->napfcd[1],(all->napfcd)+3,all->bfttnt);
                }
            }
            firstsect=FALSE;
            boxbot=DrawTubes(x,y,all);
            oy=y;
            y=PrintSubSections(all->naptid,x+BOXWID+BOXSPACE,oy);
            if (oy==y) {
                if (all->naptcd[1]=='Y') {
                    moveto(x+BOXWID+BOXSPACE+YUNITMID,y-YUNITMID);
                    lineto(x+BOXWID+BOXSPACE+YUNITMID*2,y);
                    lineto(x+BOXWID+BOXSPACE+YUNITMID*2,y+CountTubes(all,G_group)*TUBEHGT);
                    lineto(x+BOXWID+BOXSPACE+YUNITMID,y+CountTubes(all,G_group)*TUBEHGT+YUNITMID);
                    lineto(x+BOXWID+BOXSPACE,y+CountTubes(all,G_group)*TUBEHGT);
                    lineto(x+BOXWID+BOXSPACE,y);
                    lineto(x+BOXWID+BOXSPACE+YUNITMID,y-YUNITMID);
                    outxy(x+BOXWID+BOXSPACE+YUNITMID,y-YUNITMID*2,"%c%s",all->naptcd[1],(all->naptcd)+3);
                } else {
                    rectangle(x+BOXWID+BOXSPACE,y,x+BOXWID*2+BOXSPACE,y+CountTubes(all,G_group)*TUBEHGT);
                    outxy(x+BOXWID+BOXSPACE+BOXWID/2,y-BOXSEPER/2,"%c%s",all->naptcd[1],(all->naptcd)+3);
                }
                y+=CountTubes(all,G_group)*TUBEHGT+BOXSEPER+TUBEDHGT;
            }
            G_maxx=max(G_maxx,(x+BOXWID*2+BOXSPACE+BOXSEPER));
        }
        all=all->next;
    }
    rectangle(x,boxtop,x+BOXWID,boxbot);
    return ny+BOXSEPER+TUBEDHGT;
}
INT getkey(void)
{
    INT k;
    if (!(k=getch())) k=0-getch();
    return k;
}
BOOL PrintSections(int type)
{
    SECTION *s=G_sections;
    int i;
#ifdef TESTING
    int xit=FALSE;
#endif
    int x=10,y=BOXSEPER+10;
    if (type) {
        while (s!=NULL) {
            printf("%*.*s",s->depth,s->depth,"");
            if (s->jntfid)
                printf("From %s(%ld) %s(%ld) ",s->jntfcd,s->jntfid,s->napfcd,s->napfid);
            else
                printf("From %s(%ld) ",s->napfcd,s->napfid);
            printf("Via %s(%ld) ",s->bftscd,s->bftsid);
            if (s->jnttid)
                printf("To %s(%ld) %s(%ld) ",s->jnttcd,s->jnttid,s->naptcd,s->naptid);
            else
                printf("To %s(%ld) ",s->naptcd,s->naptid);
            printf("(%s)",s->bfttcd);
            printf(" [%d]\n",(s->blockh!=0)?s->blockh:1);
            for (i=0;i<s->bfttnt;i++) {
                printf("%*.*s ",s->depth,s->depth,"");
                switch (s->tubes[i].fbpid) {
                    case (-1) :
                        printf("Tube %d BLOCKED",i+1);
                        break;
                    case 0 :
                        printf("Tube %d EMPTY",i+1);
                        break;
                    default :
                        printf("Tube %d - Fibre %ld",i+1,s->tubes[i].fbpid);
                        printf(" From %s(%ld)",s->tubes[i].fbpfcd,s->tubes[i].fbpfid);
                        printf(" To %s(%ld)"  ,s->tubes[i].fbptcd,s->tubes[i].fbptid);
                }
                if (s->tubes[i].bftquid1) {
                    printf(" EQUIP(%ld[%d] %ld[%d])\n",s->tubes[i].bftquid1,s->tubes[i].bftqutn1,s->tubes[i].bftquid2,s->tubes[i].bftqutn2);
                } else {
                    printf("\n");
                }
            }
            s=s->next;
        }
        return FALSE;

    } else {
        while ((s!=NULL)&&(s->depth)) {
            s=s->next;
        }
#ifdef TESTING
        if (s!=NULL) {
            grafix();
            settextstyle(2,0,2);
            settextjustify(1,2);
            while (!xit) {
                clearviewport();
                G_maxy=PrintSubSections(s->napfid,x,y);
                switch (getkey()) {
                    case 10 :
                    case 13 :
                        xit=TRUE;
                        break;
                    case HOME:
                        x=10;
                        y=BOXSEPER+10;
                        break;
                    case UP:
                        y+=48;
                        break;
                    case DOWN :
                        y-=48;
                        break;
                    case CUP:
                    case PGUP:
                        y+=400;
                        break;
                    case CDOWN:
                    case PGDN :
                        y-=400;
                        break;
                    case LEFT :
                        x+=64;
                        break;
                    case CLEFT :
                        x+=600;
                        break;
                    case RGT :
                        x-=64;
                        break;
                    case CRGT :
                        x-=600;
                        break;
                    case 'g' :
                    case 'G' :
                        G_group^=1;
                        break;
                    case ESC :
                        closegraph();
                        return TRUE;
                }
            }
            closegraph();
        }
#else
        if (s!=NULL) G_maxy=PrintSubSections(s->napfid,x,y);
#endif
    }
    return FALSE;
}
#ifdef TESTING
void PrPage(INT w,RECORD *cunit,RECORD *tunit)
{
    int i;
    textattr(0x0F);
    for (i=0;i<22*(80/w);i++) {
        gotoxy(((i/23)*w)+1,(i%23)+1);
        if (tunit!=NULL) {
            if (tunit==cunit) {
                textattr(0x1F);
                cprintf("%-*.*s",w,w,tunit->buf);
                textattr(0x0F);
            } else {
                cprintf("%-*.*s",w,w,tunit->buf);
            }
            tunit=tunit->next;
        } else {
            cprintf("%-*.*s",w,w,"");
        }
    }
    gotoxy(1,23);
    textattr(0x0C);
    cprintf("%s  %s",((G_fromto==1)?"FROM - TO":"FROM     "),((G_group==1)?"GROUP LINES      ":"DON'T GROUP LINES"));
}
void SelectPage(RECORD *allunits,DEFBLK *base)
{
    RECORD *tunit;
    RECORD *cunit;
    int w=0;
    BOOL xit=FALSE;
    cunit=tunit=allunits;
    while (cunit!=NULL) {
        w=max(w,strlen(cunit->buf));
        cunit=cunit->next;
    }
    w++;
    cunit=tunit;
    while (!xit) {
        PrPage(w,cunit,tunit);
        switch (getkey()) {
            case 10 :
            case 13 :
                FindBFT_S(atol(cunit->buf),-1L,base,base,-1,0,0,0,0,0,TRUE,0);
                if (PrintSections(0)) xit=1;
                HadConnect(-2L,0L,0L);
                FreeSections();
                break;
            case ESC :
                xit=TRUE;
                break;
            case HOME:
                cunit=tunit=allunits;
                break;
            case UP:
                if (cunit->prev!=NULL) cunit=cunit->prev;
                break;
            case DOWN :
                if (cunit->next!=NULL) cunit=cunit->next;
                break;
            case 'f' :
            case 'F' :
                G_fromto^=1;
                break;
            case 'g' :
            case 'G' :
                G_group^=1;
                break;
        }
    }
    textattr(0x07);
    clrscr();
}
#endif
LONG ConvJointToNap(LONG bjid,DEFBLK *p)
{
    static CHAR tmp[LINELEN];
    INT bjo,bjl;
    INT no,nl;
    DEFROW *row;
    RECORD *rec;
    while (p!=NULL) {
        if (!strcmp(p->table,"BFT_JOINTS")) {
            row=p->rows;
            while (row!=NULL) {
                if (!strcmp(row->row,"BJ_ID")) {
                    bjo=row->offset;
                    bjl=row->dlength;
                } else if (!strcmp(row->row,"FEAT_NUM")) {
                    no=row->offset;
                    nl=row->dlength;
                }
                row=row->next;
            }
            rec=p->rec;
            while (rec!=NULL) {
                memcpy(tmp,rec->buf+bjo,bjl); tmp[bjl]=0;
                if (bjid==atol(RemStEdSpace(tmp))) {
                    memcpy(tmp,rec->buf+no,nl); tmp[nl]=0;
                    return atol(RemStEdSpace(tmp));
                }
                rec=rec->next;
            }
            return 0L;
        }
        p=p->next;
    }
    return 0L;
}
BOOL TUnitConnected(LONG fnum,DEFBLK *base)
{
    CHAR tmp[LINELEN];
    INT sjo=0;
    INT sjl=0;
    INT ejo=0;
    INT ejl=0;
    INT sto=0;
    INT stl=0;
    INT edo=0;
    INT edl=0;
    LONG st;
    DEFROW *row;
    RECORD *rec;
    DEFBLK *p=base;
    while (p!=NULL) {
        if (!strcmp(p->table,"BFT_SECTIONS")) {
            row=p->rows;
            while (row!=NULL) {
                if (!strcmp(row->row,"START_NAP_FEAT_NUM")) {
                    sto=row->offset;
                    stl=row->dlength;
                } else if (!strcmp(row->row,"END_NAP_FEAT_NUM")) {
                    edo=row->offset;
                    edl=row->dlength;
                } else if (!strcmp(row->row,"START_BJ_ID")) {
                    sjo=row->offset;
                    sjl=row->dlength;
                } else if (!strcmp(row->row,"END_BJ_ID")) {
                    ejo=row->offset;
                    ejl=row->dlength;
                }
                row=row->next;
            }
            rec=p->rec;
            while (rec!=NULL) {
                memcpy(tmp,rec->buf+sto,stl); tmp[stl]=0;
                st=atol(RemStEdSpace(tmp));
                if (st==fnum) return TRUE;
                if (st==0) {
                    memcpy(tmp,rec->buf+sjo,sjl); tmp[sjl]=0;
                    if (atol(RemStEdSpace(tmp))!=0L) {
                        st=ConvJointToNap(atol(RemStEdSpace(tmp)),base);
                        if (st==fnum) return TRUE;
                    }
                }
                memcpy(tmp,rec->buf+edo,edl); tmp[edl]=0;
                st=atol(RemStEdSpace(tmp));
                if (st==fnum) return TRUE;
                if (st==0) {
                    memcpy(tmp,rec->buf+ejo,ejl); tmp[ejl]=0;
                    if (atol(RemStEdSpace(tmp))!=0L) {
                        st=ConvJointToNap(atol(RemStEdSpace(tmp)),base);
                        if (st==fnum) return TRUE;
                    }
                }
                rec=rec->next;
            }
            return FALSE;
        }
        p=p->next;
    }
    return FALSE;
}
void ListTunits(DEFBLK *base)
{
    DEFBLK *p;
    DEFROW *row;
    RECORD *rec;
    RECORD *allunits=NULL;
    RECORD *aunit;
    INT octg,lctg;
    INT ofnum,lfnum;
    CHAR tmp[LINELEN];
    LONG nap;
#ifndef TESTING
    FILE *fp;
    if ((fp=fopen("\\gengraph\\TUNITLST.GGF","w"))!=NULL) {
        fprintf(fp,"NO TUNITS FOUND\n");
        fclose(fp);
    }
#endif

    p=base;
    while (p!=NULL) {
        if (!strcmp(p->table,"NETWORK_ACCESS_POINTS")) {
            row=p->rows;
            while (row!=NULL) {
                if (!strcmp(row->row,"CTG")) {
                    octg=row->offset;
                    lctg=row->dlength;
                } else if (!strcmp(row->row,"FEAT_NUM")) {
                    ofnum=row->offset;
                    lfnum=row->dlength;
                }
                row=row->next;
            }
            rec=p->rec;
            while (rec!=NULL) {
                memcpy(tmp,rec->buf+octg,lctg); tmp[lctg]=0;
                strcpy(tmp,RemStEdSpace(tmp));
                if (!strcmp(tmp,"TU")) {
                    memcpy(tmp,rec->buf+ofnum,lfnum); tmp[lfnum]=0;
                    nap=atol(RemStEdSpace(tmp));
                    if (TUnitConnected(nap,base)) {
                        sprintf(tmp,"%ld %s",nap,Cat(nap,base));
                        if ((aunit=MALLOC(sizeof(RECORD)))!=NULL) {
                            aunit->buf=STRDUP(tmp);
                            aunit->next=allunits;
                            aunit->prev=NULL;
                            if (allunits!=NULL) allunits->prev=aunit;
                            allunits=aunit;
                        }
                    }
                }
                rec=rec->next;
            }
#ifdef TESTING
            SelectPage(allunits,base);
            while (allunits!=NULL) {
                aunit=allunits;
                allunits=allunits->next;
                FREE(aunit->buf);
                FREE(aunit);
            }
#else
            if ((fp=fopen("\\gengraph\\TUNITLST.GGF","w"))!=NULL) {
                while (allunits!=NULL) {
                    aunit=allunits;
                    allunits=allunits->next;
                    fprintf(fp,"%s\n",aunit->buf);
                    FREE(aunit->buf);
                    FREE(aunit);
                }
                fclose(fp);
            }
#endif
            return;
        }
        p=p->next;
    }
}
#ifdef TESTING
int main(int argc,char *argv[])
{
    DEFBLK *defs=NULL;
    char deffile[LINELEN];
    memset(&G_section,0,sizeof(SECTION));
    BFT_J_Data (NULL,NULL,NULL,NULL,NULL);
    NAP_Data   (NULL,NULL,NULL,NULL,NULL,NULL); 
    FB_Data    (NULL,NULL,NULL,NULL,NULL); 
    BFT_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_BT_Data(NULL,NULL,NULL,NULL); 
    FBP_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_E_Data (NULL,NULL,NULL,NULL,NULL,NULL); 
    BFT_T_Data (NULL,NULL,NULL,NULL); 
    BFT_S_Data (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL); 
    if (argc<2) {
        fprintf(stderr,"Usage: %s TabledefFile [NAP_FEAT_NUM] [LIST]\n",argv[0]);
        return 0;
    } else {
        sprintf(deffile,"DATA\\%s.STO",argv[1]);
        if (!GetSavedTable(deffile,&defs)) {
            sprintf(deffile,"DATA\\%s.def",argv[1]);
            ReadTableDefs(deffile,&defs);
            ReadTables(defs,"DATA\\");
            sprintf(deffile,"DATA\\%s.STO",argv[1]);
            StoreTable(deffile,defs);
        }
    }
//    PrintTableDefs(defs);
//    PrintTables(defs);
//    if (getch()) return 1;
    if (argc==2) {
        GetStats(defs);
        clrscr();
        printf("%ld NETWORK_ACCESS_POINTS\n",G_napnum  );
        printf("%ld BLOWN_FIBRE_TUBES\n"    ,G_bftnum  );
        printf("%ld BFT_BLOCKED_TUBES\n"    ,G_bftbtnum);
        printf("%ld BFT_EQUIPMENT\n"        ,G_bftenum );
        printf("%ld BFT_JOINTS\n"           ,G_bftjnum );
        printf("%ld BFT_SECTIONS\n"         ,G_bftsnum );
        printf("%ld BFT_TYPES\n"            ,G_bfttnum );
        printf("%ld FIBRE_BUNDLES\n"        ,G_fbnum   );
        printf("%ld FIBRE_BUNDLE_PARTS\n"   ,G_fbpnum  );
        getch();
        ListTunits(defs);
    } else {
//        fprintf(stderr,"Press a Key!"); getch();
        FindBFT_S(atol(argv[2]),-1L,defs,defs,-1,0,0,0,0,0,TRUE,0);
        PrintSections(argc==4);
        HadConnect(-2L,0L,0L);
    }
    FreeTableDefs(&defs);
    return 1;
}

#else
#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
    return 1;
}
int FAR PASCAL WEP (int nParameter)
{
    BFT_J_Data (NULL,NULL,NULL,NULL,NULL);
    NAP_Data   (NULL,NULL,NULL,NULL,NULL,NULL); 
    FB_Data    (NULL,NULL,NULL,NULL,NULL); 
    BFT_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_BT_Data(NULL,NULL,NULL,NULL); 
    FBP_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_E_Data (NULL,NULL,NULL,NULL,NULL,NULL); 
    BFT_T_Data (NULL,NULL,NULL,NULL); 
    BFT_S_Data (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL); 
    if (G_defs!=NULL) FreeTableDefs(&G_defs);
    G_setup=FALSE;
    return 1;
}
#pragma warn +par
CHAR *PasToCStr(CHAR *str)
{
    static CHAR news[LINELEN];
    CHAR *newsp;
    INT len,i;
    if (sizeof(INT)!=sizeof(INT16)) return str;
    len=(INT)*str;
    newsp=news;
    str++;
    for (i=0;i<len;i++) {
        *(newsp++)=*(str++);
    }
    *newsp=0;
    return news;
}
INT  FAR PASCAL _export MaxWidth(void)
{
    return G_maxx;
}
INT  FAR PASCAL _export MaxHeight(void)
{
    return G_maxy;
}
void FAR PASCAL _export LoadTable(CHAR *filename)
{
    FILE *fp;
    INT i;
    CHAR deffile[LINELEN];
    CHAR *el;
    CHAR *ep;

    if ((fp=fopen("\\gengraph\\INPUT.GGF","w"))!=NULL) {
        fprintf(fp,"%s\n",filename);
        for (i=0;i<20;i++) fprintf(fp,"%02X ",filename[i]);
        fprintf(fp,"\n");
        fclose(fp);
    }
    BFT_J_Data (NULL,NULL,NULL,NULL,NULL);
    NAP_Data   (NULL,NULL,NULL,NULL,NULL,NULL); 
    FB_Data    (NULL,NULL,NULL,NULL,NULL); 
    BFT_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_BT_Data(NULL,NULL,NULL,NULL); 
    FBP_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_E_Data (NULL,NULL,NULL,NULL,NULL,NULL); 
    BFT_T_Data (NULL,NULL,NULL,NULL); 
    BFT_S_Data (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL); 
    if (G_defs!=NULL) FreeTableDefs(&G_defs);
    memset(&G_section,0,sizeof(SECTION));

    filename=PasToCStr(filename);
    el=strrchr(filename,'.');
    if (el!=NULL) *el=0;
    ep=strrchr(filename,'\\');
    if (ep!=NULL) {
        *(ep++)=0;
        strcpy(G_path,filename);
        strcat(G_path,"\\");
        strcpy(filename,ep);
    } else {
        strcpy(G_path,"");
    }
    sprintf(deffile,"%s%s.STO",G_path,filename);
    if (!GetSavedTable(deffile,&G_defs)) {
        sprintf(deffile,"%s%s.def",G_path,filename);
        ReadTableDefs(deffile,&G_defs);
        ReadTables(G_defs,G_path);
        sprintf(deffile,"%s%s.STO",G_path,filename);
        StoreTable(deffile,G_defs);
    }
    ListTunits(G_defs);
    G_setup=TRUE;
}

void FAR PASCAL _export Traverse(CHAR *TUnit,INT group,INT fromto)
{
    if (!G_setup) return;
    G_maxx=0;
    G_maxy=0;
    TUnit=PasToCStr(TUnit);
    if ((G_fp=fopen("\\gengraph\\COMPNT.GGF","w"))==NULL) return;
    G_firstln=TRUE;
    fprintf(G_fp,"8Params %s %d %d",TUnit,group,fromto);
    G_firstln=FALSE;
    fflush(G_fp);
    G_fromto=fromto;
    G_group =group;
    FindBFT_S(atol(TUnit),-1L,G_defs,G_defs,-1,0,0,0,0,0,TRUE,0);
    PrintSections(0);
    HadConnect(-2L,0L,0L);
    FreeSections();
    fprintf(G_fp,"\n8Finish OK");
    fflush(G_fp);
    fclose(G_fp);
    G_fp=NULL;
}
#endif
