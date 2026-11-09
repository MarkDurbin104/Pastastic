#ifndef GPADSCLS_H
#define GPADSCLS_H


#ifndef STRCLASS_H
#include "strclass.h"
#endif

_CLASSDEF(LRec)
_CLASSDEF(Store)
_CLASSDEF(DataStores)

typedef struct {
    char            name[9];
    char            type;
    unsigned char   len;
} LSTOREF;
typedef LSTOREF *PLSTOREF;

typedef struct {
    char            name[9];
    unsigned long   key;
    unsigned long   skey;
    unsigned char   numitem;
    unsigned int    li[32];
} STORE;
typedef STORE *PSTORE;

class LRec
{
    private:
        Str   name;
        char  type;
        int   len;
    public:
        LRec(LSTOREF &l);
        LRec(char *name,char type,int len);
        char *Name();
        char  Type();
        int   Len();
        char *line();
};
class Store
{
    private:
        unsigned long   key;
        unsigned long   skey;
        int             li[32];
    public:
        Str    name;
        char   numitem;
        Store(STORE &s);
        char *line(int idx);
        char pri(int idx);
        char sec(int idx);
        int  lib(int idx);
};
class DataStores
{
    public:
//    private:
        PLRec   *li;
        PStore  *st;
        int      nli;
        int      nst;
//    public:
        DataStores(char *f);
        ~DataStores();
        char *line(int s,int idx);
        int snum(char *n);
        int fnum(char *sn,char *fn);
};
#endif
