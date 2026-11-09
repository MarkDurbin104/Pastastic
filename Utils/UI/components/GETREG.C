#include <windows.h>
#include <stdio.h>

typedef struct {
    char *ctyp; 
    char *name; 
    char *ver ; 
    char *lver; 
    char *base; 
    char *base2; 
} COMP;

typedef struct ll {
  char *sn;
  char *cs;
  COMP *comp;
  struct ll *prev;
} LL;

LL *G_ll=NULL;

int PrintKey(LPSTR keyname,HKEY pkey,INT depth,COMP *comp)
{
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
                    if (strcmp(subname,"GPCS")==0) {
                        comp->ctyp=strdup(classstr);
                    } else if (strcmp(subname,"ProgID")==0) {
                        comp->name=strdup(classstr);
                    } else if (strcmp(subname,"InprocServer32")==0) {
                        comp->base=strdup(classstr);
                    } else if (strcmp(subname,"LocalServer32")==0) {
                        comp->base2=strdup(classstr);
                    } else if (strcmp(subname,"Version")==0) {
                        comp->ver=strdup(classstr);
                    } else if (strcmp(subname,"LVersion")==0) {
                        comp->lver=strdup(classstr);
                    }
                    PrintKey(subname,key,depth+1,comp);
                }
            }
        }
    }
    RegCloseKey(key);
    return 1;
}
void AddToLatest(CHAR *subname,CHAR *classstr,COMP *comp)
{
    LL *ll;
    COMP *c;

    ll=G_ll;
    while (ll!=NULL) {
        if (!strcmp(ll->comp->name,comp->name)) {
            if (atoi(ll->comp->ver)<atoi(comp->ver)) {
                free(ll->sn); ll->sn=strdup(subname);
                free(ll->cs); ll->cs=strdup(classstr);
                memcpy(ll->comp,comp,sizeof(COMP));
            }
            return;
        }
        ll=ll->prev;
    }
    ll=malloc(sizeof(LL));
    ll->sn=strdup(subname);
    ll->cs=strdup(classstr);
    ll->comp=malloc(sizeof(COMP));
    memcpy(ll->comp,comp,sizeof(COMP));
    if (G_ll==NULL) {
        ll->prev=NULL;
    } else {
        ll->prev=G_ll;
    }
    G_ll=ll;
}
int QueryKey(LPSTR keyname,HKEY pkey,INT depth,BOOL latest)
{
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

    printf("REGEDIT4\n\n");
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
                        
                        comp.ctyp=NULL;
                        comp.name=NULL;
                        comp.ver =NULL;
                        comp.lver=NULL;
                        comp.base=NULL;
                        comp.base2=NULL;

                        PrintKey(subname,key,depth+1,&comp);

                        if (latest) {
                            AddToLatest(subname,classstr,&comp);
                        } else {
                            printf("[HKEY_CLASSES_ROOT\\CLSID\\%s]\n@=\"%s\"\n\n",subname,classstr);
                            if (comp.name!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\ProgID]\n@=\"%s\"\n\n",subname,comp.name);
                            if (comp.base!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\InprocServer32]\n@=\"%s\"\n\n",subname,comp.base);
                            if (comp.base2!=NULL) printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\LocalServer32]\n@=\"%s\"\n\n",subname,comp.base2);
                            if (comp.ctyp!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\GPCS]\n@=\"%s\"\n\n",subname,comp.ctyp);
                            if (comp.ver !=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\GPCS\\Version]\n@=\"%s\"\n\n",subname,comp.ver);

                            if (comp.ctyp!=NULL)  { free(comp.ctyp);  }
                            if (comp.name!=NULL)  { free(comp.name);  }
                            if (comp.ver !=NULL)  { free(comp.ver );  }
                            if (comp.lver!=NULL)  { free(comp.lver);  }
                            if (comp.base!=NULL)  { free(comp.base);  }
                            if (comp.base2!=NULL) { free(comp.base2); }
                        }

                    }
                }
            }
        }
    }
    RegCloseKey(key);
    return 1;
}


int main(int argc,char *argv[])
{
    LL *ll;
    QueryKey("CLSID",HKEY_CLASSES_ROOT,0,argc>1);
    if (argc>1) {
        if (argc==2) {
            ll=G_ll;
            while (ll!=NULL) {
                printf("[HKEY_CLASSES_ROOT\\CLSID\\%s]\n@=\"%s\"\n\n",ll->sn,ll->cs);
                if (ll->comp->name!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\ProgID]\n@=\"%s\"\n\n",ll->sn,ll->comp->name);
                if (ll->comp->base!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\InprocServer32]\n@=\"%s\"\n\n",ll->sn,ll->comp->base);
                if (ll->comp->base2!=NULL) printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\LocalServer32]\n@=\"%s\"\n\n",ll->sn,ll->comp->base2);
                if (ll->comp->ctyp!=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\GPCS]\n@=\"%s\"\n\n",ll->sn,ll->comp->ctyp);
                if (ll->comp->ver !=NULL)  printf("[HKEY_CLASSES_ROOT\\CLSID\\%s\\GPCS\\Version]\n@=\"%s\"\n\n",ll->sn,ll->comp->ver);
                ll=ll->prev;
            }
        } else {
            ll=G_ll;
            while (ll!=NULL) {
                if (ll->comp->base!=NULL)  printf("%s\n",ll->comp->base);
                if (ll->comp->base2!=NULL) printf("%s\n",ll->comp->base2);
                ll=ll->prev;
            }
        }

    }
    return 1;
}
