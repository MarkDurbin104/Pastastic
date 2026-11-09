#include <windows.h>
#include <stdio.h>


typedef struct {
    char *ctyp; 
    char *name; 
    char *ver ; 
    char *lver; 
    char *base; 
} COMP;
typedef struct key {
   CHAR *str;
   struct key *next;
} KEY;
int QueryKey(LPSTR keyname,HKEY pkey,INT depth,KEY **k)
{
    KEY *kk;
    CHAR buf[500];
    LONG err,csiz;
    DWORD cbClass=500;
    DWORD SubKeys;
    DWORD MaxSKLen;
    DWORD MaxCLen;
    DWORD Values;
    DWORD MaxVNLen;
    DWORD MaxVLen;
    DWORD SecDesc;
    DWORD idx,subsize,clsize;
    CHAR subname[500],classstr[500];
    HKEY key;
    COMP comp;

    buf[0]=0;

    err=RegOpenKeyEx(pkey,keyname,0,KEY_READ,&key);
    if (err!=ERROR_SUCCESS) {
        return 0;
    }
    err=RegQueryInfoKey (key,buf,&cbClass,NULL,&SubKeys,&MaxSKLen,&MaxCLen,&Values,&MaxVNLen,&MaxVLen,&SecDesc,NULL);
    if (err==ERROR_SUCCESS) {
        for (idx=0;idx<SubKeys;idx++) {
            clsize=subsize=500;
            err=RegEnumKeyEx(key,idx,subname,&subsize,NULL,classstr,&clsize,NULL);
            if (err==ERROR_SUCCESS) {
                csiz=500;
                err=RegQueryValue(key,subname,classstr,&csiz);
                if (err==ERROR_SUCCESS) {
                    if ((memcmp(classstr,"GPCS",4)==0)||(depth!=0)) {
                        sprintf(buf,"CLSID\\%s",subname);
                        kk=malloc(sizeof(KEY));
                        kk->str=strdup(buf);
                        kk->next=*k;
                        *k=kk;
                    }
                }
            }
        }
    }
    RegCloseKey(key);
    return 1;
}


int main(void)
{
    KEY *k=NULL;
    QueryKey("CLSID",HKEY_CLASSES_ROOT,0,&k);
    while (k!=NULL) {
        printf("%s\n",k->str);
        RegDeleteKey(HKEY_CLASSES_ROOT,k->str);
        free(k->str);
        k=k->next;
    }
    return 1;
}
