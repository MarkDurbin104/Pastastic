// OWLCVT 07/07/94 00:46:42
#include "owl\compat.h"
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include "gpadscls.h"

LRec::LRec(char *n,char t,int l)
{
    name=n;
    len=l;
    type=t;
}
LRec::LRec(LSTOREF &l)
{
    name=l.name;
    len=l.len;
    type=l.type;
}
char *LRec::Name(void)
{
    return name;
}
char LRec::Type(void)
{
    return type;
}
int LRec::Len(void)
{
    return len;
}
char *LRec::line(void)
{
    static char ret[20];
    sprintf(ret,"%-8s %c %03d",(char *)name,type,len);
    return ret;
}
Store::Store(STORE &s)
{
    name=s.name;
    numitem=s.numitem;
    key=s.key;
    skey=s.skey;
    for (int i=0;i<numitem;i++) li[i]=s.li[i];
}
char Store::pri(int idx)
{
    char ret;
    if ((key&(0x80000000L>>idx))!=0) ret=12; else ret=32;
    return ret;
}
char Store::sec(int idx)
{
    char ret;
    if ((skey&(0x80000000L>>idx))!=0) ret=12; else ret=32;
    return ret;
}
int Store::lib(int idx)
{
    return li[idx];
}
DataStores::DataStores(char *f)
{
    PLSTOREF pl;
    PSTORE ps;
    int i,fd;

    nli=0;
    li=NULL;
    nst=0;
    st=NULL;

    if ((fd=open(f,O_RDONLY|O_BINARY))==(-1)) return;

    if (read(fd,&nst,sizeof(int))!=sizeof(int)) {
       close(fd);
       return;
    }
    ps=new STORE[nst];
    st=new PStore[nst];
    if (read(fd,ps,nst*sizeof(STORE))!=(nst*sizeof(STORE))) {
       delete ps;
       delete st;
       st=NULL;
       nst=0;
       close(fd);
       return;
    }
    for (i=0;i<nst;i++) st[i]=new Store(ps[i]);
    delete ps;

    if (read(fd,&nli,sizeof(int))!=sizeof(int)) {
       close(fd);
       return;
    }
    pl=new LSTOREF[nli];
    li=new PLRec[nli];
    if (read(fd,pl,nli*sizeof(LSTOREF))!=(nli*sizeof(LSTOREF))) {
       delete pl;
       delete li;
       li=NULL;
       nli=0;
       close(fd);
       return;
    }
    close(fd);
    for (i=0;i<nli;i++) li[i]=new LRec(pl[i]);
    delete pl;
}
DataStores::~DataStores()
{
    int i;
    if (st!=NULL) {
       for (i=0;i<nst;i++) delete st[i];
       delete st;
    }
    if (li!=NULL) {
       for (i=0;i<nli;i++) delete li[i];
       delete li;
    }
}
int DataStores::snum(char *n)
{
    for (int i=0;i<nst;i++) {
        if (st[i]->name==n) return i;
    }
    return -1;
}
int DataStores::fnum(char *sn,char *fn)
{
    int s=snum(sn);
    if (s==(-1)) return s;

    for (int i=0;i<st[s]->numitem;i++) {
        if (st[s]->name==fn) return i;
    }
    return -1;
}
char * DataStores::line(int s,int idx)
{
    static char ret[30];
    sprintf(ret,"%c %c %s",st[s]->pri(idx),st[s]->sec(idx),li[st[s]->lib(idx)]->line());
    return ret;
}
