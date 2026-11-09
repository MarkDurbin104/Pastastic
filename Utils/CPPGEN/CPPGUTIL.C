#ifndef TESTING
#include <windows.h>
#endif
#include <stdio.h>
#include <string.h>
#include <malloc.h>

#include "types.h"
#include "deballoc.h"

typedef int BOOL;

typedef struct LNK {
    void *elem;
    struct LNK * next;
} LINKLIST;
typedef struct {
    CHAR     *name;
    CHAR     *desc;
    CHAR     *type;
    CHAR     *flags;
} ATTRIB;
typedef struct {
    CHAR     *name;
    CHAR     *desc;
    CHAR     *type;
    CHAR     *def;
} PARAM;
typedef struct {
    CHAR     *name;
    CHAR     *desc;
    CHAR     *rtype;
    CHAR     *rdesc;
    CHAR     *flags;
    LINKLIST *params;
    LINKLIST *code;
} METHOD;
typedef struct {
    CHAR     *name;
    CHAR     *desc;
    CHAR     *type;
    CHAR     *base;
    LINKLIST *attribs;
    LINKLIST *methods;
} CLASS;
typedef struct {
    CHAR     *name;
    CHAR     *desc;
    LINKLIST *classes;
} MODULE;

LINKLIST *G_modules       =NULL;
MODULE   *G_CurrentModule =NULL;
CLASS    *G_CurrentClass  =NULL;
METHOD   *G_CurrentMethod =NULL;
PARAM    *G_CurrentParam  =NULL;
ATTRIB   *G_CurrentAttrib =NULL;

BOOL addlink(LINKLIST **base,void *elem)
{
    LINKLIST *newlink;
    if ((newlink=MALLOC(sizeof(LINKLIST)))==NULL) return FALSE;
    newlink->elem=elem;
    newlink->next=*base;
    *base=newlink;
    return TRUE;
}
LINKLIST *applink(LINKLIST **base,void *elem)
{
    LINKLIST *iterlink;
    LINKLIST *newlink;
    if ((newlink=MALLOC(sizeof(LINKLIST)))==NULL) return NULL;
    newlink->elem=elem;
    newlink->next=NULL;
    iterlink=*base;
    if (iterlink==NULL) {
        *base=newlink;
    } else {
        while (iterlink->next!=NULL) iterlink=iterlink->next;
        iterlink->next=newlink;
    }
    return newlink;
}
void freelink(LINKLIST **base,BOOL freeelem)
{
    LINKLIST *lastlink;
    while (*base!=NULL) {
        lastlink=*base;
        *base=(*base)->next;
        if (freeelem) FREE(lastlink->elem);
        FREE(lastlink);
    }
}
CHAR *PasToCStr(CHAR *str)
{
    static CHAR tmp[100];
    CHAR *s;
    INT len,i;
    len=(INT)*str;
    s=tmp;
    for (i=0;i<len;i++) {
        *s=*(str+1);
        str++;
        s++;
    }
    *s=0;
    return tmp;
}
void RemTSpace(CHAR *line)
{
    CHAR *end;
    end=line+strlen(line)-1;
    while ((end!=line)&&((*end==' ')||(*end=='\r')||(*end=='\n')||(*end=='\t')))
        *(end--)=0;
    if ((end==line)&&((*end==' ')||(*end=='\r')||(*end=='\n')||(*end=='\t')))
        *end=0;
}
INT loadfile(CHAR *filename,LINKLIST **l)
{
    FILE *fp;
    LINKLIST *end=NULL;
    char line[LINESIZE+1];
    if ((fp=fopen(filename,"r"))==NULL) return FALSE;
    while (fgets(line,LINESIZE,fp)!=NULL) {
        RemTSpace(line);
        if (end==NULL) {
            end=applink(l,(void *)STRDUP(line));
        } else {
            end=applink(&end,(void *)STRDUP(line));
        }
    }
    fclose(fp);
    return TRUE;
}
LINKLIST *LoadCode(LINKLIST *l,LINKLIST **cl)
{
    if ((l==NULL)||strcmp((CHAR *)l->elem,"SCODEBLOCK")) return l;
    l=l->next;
    while ((l!=NULL)&&(strcmp((CHAR *)l->elem,"ECODEBLOCK"))) {
        applink(cl,STRDUP(l->elem)); l=l->next;
    }
    if (l!=NULL) l=l->next;
    return l;
}
void PrintCode(LINKLIST *cl)
{   
    while (cl!=NULL) {
        printf("%s\n",(CHAR *)(cl->elem));
        cl=cl->next;
    }
}
LINKLIST *LoadAttrib(LINKLIST *l,LINKLIST **al)
{
    ATTRIB *a;

    while ((l!=NULL)&&(*((CHAR *)l->elem)=='A')) {
        if ((a=MALLOC(sizeof(ATTRIB)))==NULL) return l;
        a->name =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        a->desc =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        a->type =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        a->flags=STRDUP(((CHAR *)l->elem)+1); l=l->next;
        applink(al,(void *)a);
    }
    return l;
}
void FreeAttribs(LINKLIST *al)
{   
    ATTRIB *a;

    while (al!=NULL) {
        a=(ATTRIB *)(al->elem);
        FREE(a->name );
        FREE(a->desc );
        FREE(a->type );
        FREE(a->flags);
        al=al->next;
    }
}
void SaveAttribs(LINKLIST *al,FILE *fp)
{   
    ATTRIB *a;

    while (al!=NULL) {
        a=(ATTRIB *)(al->elem);
        fprintf(fp,"A%s\n",a->name );
        fprintf(fp,"D%s\n",a->desc );
        fprintf(fp,"T%s\n",a->type );
        fprintf(fp,"F%s\n",a->flags);
        al=al->next;
    }
}
void ListAttribs(LINKLIST *al,FILE *fp)
{
    ATTRIB *a;

    while (al!=NULL) {
        a=(ATTRIB *)(al->elem);
        fprintf(fp,"%s",a->name);
        if (al->next!=NULL) fprintf(fp,"\n");
        al=al->next;
    }
}
void PrintAttribs(LINKLIST *al)
{   
    ATTRIB *a;

    while (al!=NULL) {
        a=(ATTRIB *)(al->elem);
        printf("    \/\/ %s\n    %s %s;\n",a->desc,a->type,a->name);
        al=al->next;
    }
}
LINKLIST *LoadParam(LINKLIST *l,LINKLIST **pl)
{
    PARAM *p;

    while ((l!=NULL)&&(*((CHAR *)l->elem)=='P')) {
        if ((p=MALLOC(sizeof(PARAM)))==NULL) return l;
        p->name =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        p->desc =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        p->type =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        p->def  =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        applink(pl,(void *)p);
    }
    return l;
}
void FreeParams(LINKLIST *pl)
{   
    PARAM *p;

    while (pl!=NULL) {
        p=(PARAM *)(pl->elem);
        FREE(p->name);
        FREE(p->desc);
        FREE(p->type);
        FREE(p->def );
        pl=pl->next;
    }
}
void SaveParams(LINKLIST *pl,FILE *fp)
{   
    PARAM *p;

    while (pl!=NULL) {
        p=(PARAM *)(pl->elem);
        fprintf(fp,"P%s\n",p->name);
        fprintf(fp,"D%s\n",p->desc);
        fprintf(fp,"T%s\n",p->type);
        fprintf(fp,"d%s\n",p->def );
        pl=pl->next;
    }
}
void ListParams(LINKLIST *pl,FILE *fp)
{
    PARAM *p;
    while (pl!=NULL) {
        p=(PARAM *)(pl->elem);
        fprintf(fp,"%s",p->name);
        if (pl->next!=NULL) fprintf(fp,"\n");
        pl=pl->next;
    }
}
void PrintParams(LINKLIST *pl,BOOL codeblock)
{   
    PARAM *p;

    while (pl!=NULL) {
        p=(PARAM *)(pl->elem);
        printf("%s %s",p->type,p->name);
        if ((!codeblock)&&(strlen(p->def)!=0)) printf("=%s",p->def);
        if (pl->next!=NULL) printf(",");
        pl=pl->next;
    }
}
void PrintParamDesc(LINKLIST *pl)
{   
    PARAM *p;

    while (pl!=NULL) {
        p=(PARAM *)(pl->elem);
        printf("\/\/P %s\n",p->desc);
        pl=pl->next;
    }
}
LINKLIST *LoadMethod(LINKLIST *l,LINKLIST **ml)
{
    METHOD *m;

    while ((l!=NULL)&&(*((CHAR *)l->elem)=='m')) {
        if ((m=MALLOC(sizeof(METHOD)))==NULL) return l;
        m->name  =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->desc  =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->rtype =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->rdesc =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->flags =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->params=NULL; l=LoadParam(l,&(m->params));
        m->code  =NULL; l=LoadCode(l,&(m->code));
        applink(ml,(void *)m);
    }
    return l;
}
void FreeMethods(LINKLIST *ml)
{   
    METHOD *m;

    while (ml!=NULL) {
        m=(METHOD *)(ml->elem);
        FREE(m->name );
        FREE(m->desc );
        FREE(m->rtype);
        FREE(m->rdesc);
        FREE(m->flags);
        FreeParams(m->params); freelink(&(m->params),TRUE);
        freelink(&(m->code),TRUE);
        ml=ml->next;
    }
}
void SaveMethods(LINKLIST *ml,FILE *fp)
{   
    METHOD *m;
    LINKLIST *cl;

    while (ml!=NULL) {
        m=(METHOD *)(ml->elem);
        fprintf(fp,"m%s\n",m->name );
        fprintf(fp,"D%s\n",m->desc );
        fprintf(fp,"R%s\n",m->rtype);
        fprintf(fp,"D%s\n",m->rdesc);
        fprintf(fp,"F%s\n",m->flags);
        SaveParams(m->params,fp);
        fprintf(fp,"SCODEBLOCK\n");
        cl=m->code;
        while (cl!=NULL) {
            fprintf(fp,"%s\n",(CHAR *)(cl->elem));
            cl=cl->next;
        }
        fprintf(fp,"ECODEBLOCK\n");
        ml=ml->next;
    }
}
void PrintMethodCode(LINKLIST *ml,CHAR *clas)
{   
    METHOD *m;

    while (ml!=NULL) {
        m=(METHOD *)(ml->elem);
        printf("\/\/D %s\n",m->desc);
        printf("\/\/R %s\n",m->rdesc);
        PrintParamDesc(m->params);
        printf("%s %s::%s(",m->rtype,clas,m->name);
        PrintParams(m->params,TRUE);
        printf(")\n{\n");
        PrintCode(m->code);
        printf("}\n");
        ml=ml->next;
    }
}
void ListMethods(LINKLIST *ml,FILE *fp)
{
    METHOD *m;
    while (ml!=NULL) {
        m=(METHOD *)(ml->elem);
        fprintf(fp,"%s",m->name);
        if (ml->next!=NULL) fprintf(fp,"\n");
        ml=ml->next;
    }
}
void PrintMethods(LINKLIST *ml)
{   
    METHOD *m;

    while (ml!=NULL) {
        m=(METHOD *)(ml->elem);
        printf("    %s %s(",m->rtype,m->name);
        PrintParams(m->params,FALSE);
        printf(");\n");
        ml=ml->next;
    }
}
LINKLIST *LoadClass(LINKLIST *l,LINKLIST **cl)
{
    CLASS *c;

    while ((l!=NULL)&&(*((CHAR *)l->elem)=='c')) {
        if ((c=MALLOC(sizeof(CLASS)))==NULL) return l;
        c->name   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        c->desc   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        c->base   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        c->type   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        c->attribs=NULL; l=LoadAttrib(l,&(c->attribs));
        c->methods=NULL; l=LoadMethod(l,&(c->methods));
        applink(cl,(void *)c);
    }
    return l;
}
void FreeClasses(LINKLIST *cl)
{   
    CLASS *c;
    while (cl!=NULL) {
        c=(CLASS *)(cl->elem);
        FREE(c->name);
        FREE(c->desc);
        FREE(c->base);
        FREE(c->type);
        FreeAttribs(c->attribs); freelink(&(c->attribs),TRUE);
        FreeMethods(c->methods); freelink(&(c->methods),TRUE);
        cl=cl->next;
    }
}
void SaveClasses(LINKLIST *cl,FILE *fp)
{   
    CLASS *c;
    while (cl!=NULL) {
        c=(CLASS *)(cl->elem);
        fprintf(fp,"c%s\n",c->name);
        fprintf(fp,"D%s\n",c->desc);
        fprintf(fp,"B%s\n",c->base);
        fprintf(fp,"T%s\n",c->type);
        SaveAttribs(c->attribs,fp);
        SaveMethods(c->methods,fp);
        cl=cl->next;
    }
}
void ListClasses(LINKLIST *cl,FILE *fp)
{
    CLASS *c;
    while (cl!=NULL) {
        c=(CLASS *)(cl->elem);
        fprintf(fp,"%s",c->name);
        if (cl->next!=NULL) fprintf(fp,"\n");
        cl=cl->next;
    }
}
void PrintClasses(LINKLIST *cl)
{   
    CLASS *c;
    LINKLIST *firstclass;
    firstclass=cl;

    while (cl!=NULL) {
        c=(CLASS *)(cl->elem);
        if (c->base[0]==0)
            printf("class %s %s\n{\n",c->name,c->type);
        else
            printf("class %s %s : %s\n{\n",c->name,c->type,c->base);
        printf(" \/\/ %s\n",c->desc);
        PrintAttribs(c->attribs);
        PrintMethods(c->methods);
        printf("};\n",c->desc);
        cl=cl->next;
    }
    cl=firstclass;
    while (cl!=NULL) {
        c=(CLASS *)(cl->elem);
        PrintMethodCode(c->methods,c->name);
        cl=cl->next;
    }
}
LINKLIST *LoadModul(LINKLIST *l,LINKLIST **ml)
{
    MODULE *m;

    while ((l!=NULL)&&(*((CHAR *)l->elem)=='M')) {
        if ((m=MALLOC(sizeof(MODULE)))==NULL) return l;
        m->name   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->desc   =STRDUP(((CHAR *)l->elem)+1); l=l->next;
        m->classes=NULL; l=LoadClass(l,&(m->classes));
        applink(ml,(void *)m);
    }
    return l;
}
void FreeModules(LINKLIST **aml)
{
    MODULE *m;
    LINKLIST *ml;

    if (aml==NULL) return;
    ml=*aml;
    while (ml!=NULL) {
        m=(MODULE *)(ml->elem);
        FREE(m->name);
        FREE(m->desc);
        FreeClasses(m->classes); freelink(&(m->classes),TRUE);
        ml=ml->next;
    }
    freelink(aml,TRUE);
}
void SaveModules(LINKLIST *ml,FILE *fp)
{
    MODULE *m;

    while (ml!=NULL) {
        m=(MODULE *)(ml->elem);
        fprintf(fp,"M%s\n",m->name);
        fprintf(fp,"D%s\n",m->desc);
        SaveClasses(m->classes,fp);
        ml=ml->next;
    }
}
void PrintModules(LINKLIST *ml)
{
    MODULE *m;
    while (ml!=NULL) {
        m=(MODULE *)(ml->elem);
        printf("Module %s\n",m->name);
        printf("%s\n",m->desc);
        PrintClasses(m->classes);
        ml=ml->next;
    }
}
void ListModules(LINKLIST *ml,FILE *fp)
{
    MODULE *m;
    while (ml!=NULL) {
        m=(MODULE *)(ml->elem);
        fprintf(fp,"%s",m->name);
        if (ml->next!=NULL) fprintf(fp,"\n");
        ml=ml->next;
    }
}
#ifndef TESTING
#pragma warn -par
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
    return 1;
}
int FAR PASCAL WEP (int nParameter)
{
    if (G_modules!=NULL) FreeModules(&G_modules);
    return 1;
}
#pragma warn +par
void FAR PASCAL _export LoadProject(CHAR *name)
{
    FILE *fp;
    LINKLIST *l=NULL;

    if (G_modules!=NULL) FreeModules(&G_modules);
    name=PasToCStr(name);
    loadfile(name,&l);
    LoadModul(l,&G_modules);
    freelink(&l,TRUE);
    if ((fp=fopen("MODULES.OPT","w"))==NULL) return;
    ListModules(G_modules,fp);
    fclose(fp);
}
void FAR PASCAL _export SaveProject(CHAR *name)
{
    FILE *fp;
    if (G_modules==NULL) return;
    name=PasToCStr(name);
    if ((fp=fopen(name,"w"))==NULL) return;
    SaveModules(G_modules,fp);
    fclose(fp);
}
void FAR PASCAL _export GetClasses(CHAR *name)
{
    FILE *fp;
    LINKLIST *l=G_modules;

    name=PasToCStr(name);
    while (l!=NULL) {
        if (!strcmp(((MODULE *)l->elem)->name,name)) {
            G_CurrentModule=((MODULE *)l->elem);
            if ((fp=fopen("MODULES.OPT","w"))==NULL) return;
            ListClasses(G_CurrentModule->classes,fp);
            fclose(fp);
            return;
        }
        l=l->next;
    }
    
}
void FAR PASCAL _export GetMethods(CHAR *name)
{
    FILE *fp;
    LINKLIST *l=G_CurrentModule->classes;

    name=PasToCStr(name);
    while (l!=NULL) {
        if (!strcmp(((CLASS *)l->elem)->name,name)) {
            G_CurrentClass=((CLASS *)l->elem);
            if ((fp=fopen("MODULES.OPT","w"))==NULL) return;
            ListMethods(G_CurrentClass->methods,fp);
            fclose(fp);
            return;
        }
        l=l->next;
    }
    
}
void FAR PASCAL _export GetAttribs(CHAR *name)
{
    FILE *fp;
    LINKLIST *l=G_CurrentModule->classes;

    name=PasToCStr(name);
    while (l!=NULL) {
        if (!strcmp(((CLASS *)l->elem)->name,name)) {
            G_CurrentClass=((CLASS *)l->elem);
            if ((fp=fopen("MODULES.OPT","w"))==NULL) return;
            ListAttribs(G_CurrentClass->attribs,fp);
            fclose(fp);
            return;
        }
        l=l->next;
    }
    
}
void FAR PASCAL _export Pass(UCHAR *name)
{
    FILE *fp;
    int i;
    if ((fp=fopen("PASS.OPT","w"))==NULL) return;
    fwrite(name,1024,1,fp);
    fclose(fp);
}
void FAR PASCAL _export GetParams(CHAR *name)
{
    FILE *fp;
    LINKLIST *l=G_CurrentClass->methods;

    name=PasToCStr(name);
    while (l!=NULL) {
        if (!strcmp(((METHOD *)l->elem)->name,name)) {
            G_CurrentMethod=((METHOD *)l->elem);
            if ((fp=fopen("MODULES.OPT","w"))==NULL) return;
            ListParams(G_CurrentMethod->params,fp);
            fclose(fp);
            return;
        }
        l=l->next;
    }
    
}
#else
int main(void)
{
    LINKLIST *l=NULL;
    LINKLIST *ll;
    LINKLIST *lll;

    loadfile("CPPGUTIL.PRJ",&l);
    LoadModul(l,&G_modules);
    freelink(&l,TRUE);

    ListModules(G_modules,stdout);
    printf("\n");
    l=G_modules;
    while (l!=NULL) {
        ListClasses(((MODULE *)l->elem)->classes,stdout);
        printf("\n");
        ll=((MODULE *)l->elem)->classes;
        while (ll!=NULL) {
            ListAttribs(((CLASS *)ll->elem)->attribs,stdout);
            printf("\n");
            ListMethods(((CLASS *)ll->elem)->methods,stdout);
            printf("\n");
            lll=((CLASS *)ll->elem)->methods;
            while (lll!=NULL) {
                ListParams(((METHOD *)lll->elem)->params,stdout);
                printf("\n");
                lll=lll->next;
            }
            ll=ll->next;
        }
        l=l->next;
    }

//    PrintModules(G_modules);
    FreeModules(&G_modules);

    return 1;
}
#endif //def TESTING
