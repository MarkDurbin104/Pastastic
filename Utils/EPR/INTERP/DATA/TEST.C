#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    char type;
    int size;
    char *name;
} DDEF;

DDEF G_cvals[]={
    { 'n' ,  10 , "g_version"            },
    { 'n' ,  10 , "feat_num"             },
    { 's' ,   9 , "ex_1141_cd"           },
    { 's' ,   4 , "ctg"                  },
    { 's' ,   9 , "no"                   },
    { 's' ,   2 , "ps_st"                },
    { 's' ,   9 , "house_1141_cd"        },
    { 's' ,   1 , "fp_acp_cd"            },
    { 's' ,   1 , "ab_ind"               },
    { 's' ,  60 , "loc"                  },
    { 's' ,   2 , "licence_cd"           },
    { 's' , 241 , "nb"                   },
    { 's' ,   1 , "equipment_gr_ind"     },
    { 's' ,   1 , "hazard_gr_ind"        },
    { 's' ,   1 , "anticreep_gr_ind"     },
    { 's' ,   1 , "public_ind"           },
    { 'n' ,  10 , "g_next_version"       },
    { 'n' ,  10 , "g_generation"         },
    { '*' ,   0 , NULL                   }
};

char *cleanup(char *s)
{
    char *t;
    while (*(s+strlen(s)-1)==' ') *(s+strlen(s)-1)=0;
    while ((*s)&&(*s==' ')) s++;
    t=s;
    while (*s) { if (*s=='"') *s='\''; s++; }
    return(t);
}

void parseln(char *s)
{
    static char *buf;
    static int lenread=0;
    static int buflen=0;
    int ofs=0;
    if (buflen==0) {
        while (G_cvals[ofs].type!='*') buflen+=G_cvals[ofs++].size+1;
        ofs=0;
        buf=malloc(buflen+256);
    }
    if (buf==NULL) return;
    while (*(s+strlen(s)-1)=='\n') *(s+strlen(s)-1)=0;
    if (lenread<buflen) {
        strcpy(&(buf[lenread]),s);
        lenread+=strlen(s);
        if (lenread<buflen) return;
    }
    s=buf;
    lenread=0;
    while (*s) {
        strncpy(buf,s,G_cvals[ofs].size);
        s+=G_cvals[ofs].size;
        buf[G_cvals[ofs].size]=0;
        if (ofs==0) printf("NAP {");
        if (G_cvals[ofs].type=='n') {
            printf("%ld",atol(buf));
        } else {
            printf("\"%s\"",cleanup(buf));
        }
        ofs++;
        if (G_cvals[ofs].type=='*') {
            ofs=0;
            printf("}\n");
        } else {
            printf(",");
        }
        s++;
    }
//    if (getch()==27) exit(1);
}
int main(int argc,char *argv[])
{
    char tmp[256];
    FILE *fp;
    if ((argc<2)||((fp=fopen(argv[1],"r"))==NULL)) {
        fprintf(stderr,"usage %s filename\n",argv[0]);
        return 1;
    }
    while (fgets(tmp,256,fp)) parseln(tmp);      
    fclose(fp);
    return 0;
}
