#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>

#include "gpa.h"
void printrec(char *name)
{
    int i,s,len;
    char tmp[80];

    if ((s=snum(name))<0) return;
    for (i=0;i<G_store[s].numitem;i++) {
        len=G_lib[G_store[s].li[i]].len;
        stget(name,G_lib[G_store[s].li[i]].name,tmp);
        printf("%-*.*s ",len,len,tmp);
    }
    printf("\n");
}

void extract(char *s,char *f,int cond,char *value,char *tmpfile)
{
    int smode=FRST;
    char tmp[160];
    int cval,i=1;
    double val=0;
    double comp;
    switch (G_lib[G_store[snum(s)].li[fnum(s,f)]].type) {
        case 'K' : case 'M' : case 'W' : case '9' :
            i=0;
            val=atof(value);
            break;
    }
    while (stread(s,smode)) {
        if (!stget(s,f,tmp)) return;
        if (i) comp=strcmp(tmp,value); else comp=atof(tmp);
        switch (cond) {
            case 0 : if (comp==val) printrec(s); break;
            case 1 : if (comp!=val) printrec(s); break;
            case 2 : if (comp< val) printrec(s); break;
            case 3 : if (comp<=val) printrec(s); break;
            case 4 : if (comp> val) printrec(s); break;
            case 5 : if (comp>=val) printrec(s); break;
        }
        smode=NEXT;
    }
}
int main(int argc,char *argv[])
{
    char *t,tmp[3];
    int s,f;
    if (argc<5) {
        printf("extract system field cond value\n");
        return(1);
    } else {
        readconfig(argv[1]);
    }
    if (!stinit(G_system)) {
        printf("Can't initialise Datastores for %s\n",G_system);
        return(1);
    }
    t=argv[2];
    while ((*t)&&(*t!='.')) t++;
    if (!(*t)) {
        printf("field \"%s\" must be in the format XXXXXXXX.XXXXXXXX\n",argv[2]);
        return(1);
    }
    *(t++)=0;
    s=snum(argv[2]);
    f=fnum(argv[2],t);
    if (s<0) {
        printf("Store \"%s\" NOT found\n",argv[2]);
        return(1);
    }
    if (f<0) {
        printf("Field %s NOT found in Store \"%s\"\n",t,argv[2]);
        return(1);
    }
    switch (atoi(argv[3])) {
        case 0 :
            strcpy(tmp,"==");
            break;
        case 1 :
            strcpy(tmp,"!=");
            break;
        case 2 :
            strcpy(tmp,"<");
            break;
        case 3 :
            strcpy(tmp,"<=");
            break;
        case 4 :
            strcpy(tmp,">");
            break;
        case 5 :
            strcpy(tmp,">=");
            break;
    }
    printf("Extract Records form table \"%s\" where \"%s\" %s %s\n",argv[2],t,tmp,argv[4]);
    getch();
    extract(argv[2],t,atoi(argv[3]),argv[4],"TEST");    
    return(0);
}

