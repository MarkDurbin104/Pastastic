#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <stdlib.h>
#include <malloc.h>
#include <ctype.h>
#include <stdarg.h>
#include "types.h"
#include "deballoc.h"


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

BOOL G_includeall=TRUE;

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
                    if (!G_includeall) {
                        if (row==p->rows) {
                            memcpy(file,buf+(row->offset),row->dlength); file[row->dlength]=0;
                            if (atol(RemStEdSpace(file))!=0L)
                                skiprow=TRUE;
                        } else if ((chkcty)&&(!strcmp(row->row,"CTG"))) {
                            memcpy(file,buf+(row->offset),row->dlength); file[row->dlength]=0;
                            strcpy(file,RemStEdSpace(file));
                            if (((file[0]!='T')&&(file[0]!='Y'))||(file[1]!='U'))
                                skiprow=TRUE;
                        }
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
void BFT_E_Data(DEFBLK *p,CHAR *buf,CHAR **i1,CHAR **t1,CHAR **i2,CHAR **t2,CHAR **fn)
{
    static CHAR i1buf[LINELEN];
    static CHAR t1buf[LINELEN];
    static CHAR i2buf[LINELEN];
    static CHAR t2buf[LINELEN];
    static CHAR fnbuf[LINELEN];
    static INT i1o,i1l;
    static INT t1o,t1l;
    static INT i2o,i2l;
    static INT t2o,t2l;
    static INT fno,fnl;
    static BOOL setup=FALSE;
    INT alldone;
    DEFROW *row;
    if (p==NULL) {
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
                    } else if (!strcmp(row->row,"FEAT_NUM")) {
                        fno=row->offset;
                        fnl=row->dlength;
                        alldone++;
                    }
                    if (alldone==5) break;
                    row=row->next;
                }
            }
            if (alldone==5) break;
            p=p->next;
        }
        if (alldone!=5) {
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
    strcpy(fnbuf,rowdata(buf,fno,fnl)); *fn=fnbuf;
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
void OutputData(FILE *fp,DEFBLK *p)
{
    RECORD *rec;
    CHAR *a,*b,*c,*d,*e,*f,*g,*h;
    if (G_bft_j_table==NULL) BFT_J_Data(p,NULL,&a,&b,&c);
    if (G_bft_j_table!=NULL) {
        rec=G_bft_j_table->rec;
        while (rec!=NULL) {
            BFT_J_Data(p,rec->buf,&a,&b,&c);
            fprintf(fp,"J$%ld$%ld$%s\n",atol(a),atol(b),c);
            rec=rec->next;
        }
    }
    if (G_nap_table==NULL) NAP_Data(p,NULL,&a,&b,&c,&d);
    if (G_nap_table!=NULL) {
        rec=G_nap_table->rec;
        while (rec!=NULL) {
            NAP_Data(p,rec->buf,&a,&b,&c,&d);
            fprintf(fp,"N$%ld$%s$%s$%s\n",atol(c),d,b,a);
            rec=rec->next;
        }
    }
    if (G_fb_table==NULL) FB_Data(p,NULL,&a,&b,&c);
    if (G_fb_table!=NULL) {
        rec=G_fb_table->rec;
        while (rec!=NULL) {
            FB_Data(p,rec->buf,&a,&b,&c);
            fprintf(fp,"F$%ld$%ld$%ld\n",atol(a),atol(b),atol(c));
            rec=rec->next;
        }
    }
    if (G_fbp_table==NULL) FBP_Data(p,NULL,&a,&b,&c);
    if (G_fbp_table!=NULL) {
        rec=G_fbp_table->rec;
        while (rec!=NULL) {
            FBP_Data(p,rec->buf,&a,&b,&c);
            fprintf(fp,"P$%ld$%ld$%d\n",atol(a),atol(b),atoi(c));
            rec=rec->next;
        }
    }
    if (G_bft_table==NULL) BFT_Data(p,NULL,&a,&b,&c);
    if (G_bft_table!=NULL) {
        rec=G_bft_table->rec;
        while (rec!=NULL) {
            BFT_Data(p,rec->buf,&a,&b,&c);
            fprintf(fp,"B$%ld$%s$%s\n",atol(c),a,b);
            rec=rec->next;
        }
    }
    if (G_bft_bt_table==NULL) BFT_BT_Data(p,NULL,&a,&b);
    if (G_bft_bt_table!=NULL) {
        rec=G_bft_bt_table->rec;
        while (rec!=NULL) {
            BFT_BT_Data(p,rec->buf,&a,&b);
            fprintf(fp,"U$%ld$%d\n",atol(a),atoi(b));
            rec=rec->next;
        }
    }
    if (G_bft_e_table==NULL) BFT_E_Data(p,NULL,&a,&b,&c,&d,&e);
    if (G_bft_e_table!=NULL) {
        rec=G_bft_e_table->rec;
        while (rec!=NULL) {
            BFT_E_Data(p,rec->buf,&a,&b,&c,&d,&e);
            fprintf(fp,"E$%ld$%d$%ld$%d$%ld\n",atol(a),atoi(b),atol(c),atoi(d),atol(e));
            rec=rec->next;
        }
    }
    if (G_bft_t_table==NULL) BFT_T_Data(p,NULL,&a,&b);
    if (G_bft_t_table!=NULL) {
        rec=G_bft_t_table->rec;
        while (rec!=NULL) {
            BFT_T_Data(p,rec->buf,&a,&b);
            fprintf(fp,"T$%s$%d\n",a,atoi(b));
            rec=rec->next;
        }
    }
    if (G_bft_s_table==NULL) BFT_S_Data(p,NULL,&a,&b,&c,&d,&e,&f,&g,&h);
    if (G_bft_s_table!=NULL) {
        rec=G_bft_s_table->rec;
        while (rec!=NULL) {
            BFT_S_Data(p,rec->buf,&a,&b,&c,&d,&e,&f,&g,&h);
            fprintf(fp,"S$%ld$%ld$%ld$%ld$%s$%s$%ld$%ld\n",
                atol(a),atol(b),atol(g),atol(h),c,d,atol(e),atol(f));
            rec=rec->next;
        }
    }
}




int main(int argc,char *argv[])
{
    DEFBLK *defs=NULL;
    char deffile[LINELEN];

    BFT_J_Data (NULL,NULL,NULL,NULL,NULL);
    NAP_Data   (NULL,NULL,NULL,NULL,NULL,NULL); 
    FB_Data    (NULL,NULL,NULL,NULL,NULL); 
    BFT_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_BT_Data(NULL,NULL,NULL,NULL); 
    FBP_Data   (NULL,NULL,NULL,NULL,NULL); 
    BFT_E_Data (NULL,NULL,NULL,NULL,NULL,NULL,NULL); 
    BFT_T_Data (NULL,NULL,NULL,NULL); 
    BFT_S_Data (NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

    if (argc<2) {
        fprintf(stderr,"Usage: %s TabledefFile [IGNORE G_MASTER!=0]\n",argv[0]);
        return 0;
    } else {
        if (argc>2) G_includeall=FALSE;
        sprintf(deffile,"DATA\\%s.def",argv[1]);
        ReadTableDefs(deffile,&defs);
        ReadTables(defs,"DATA\\");
        OutputData(stdout,defs);
        FreeTableDefs(&defs);
    }
    return 1;
}

