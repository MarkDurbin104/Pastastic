#include <string.h>
#include <stdio.h>

char *G_files[]={
    "CONTROL.H",
    "FORMHAND.H",
    "DST.H",
    "CONFIG.H",
    "DBM.H",
    "TRANSLOG.H",
    "FUNCTION.H",
    "MONEY.H",
    "ACTIONS.H",
    "ARITH.H",
    "INSTRUCT.H",
    "GLOBAL.H ",
    "CALC.H",
    "MENUPROC.H",
    "FORMPROC.H",
    "TABPROC.H",
    "FLDPROC.H",
    "REPPROC.H",
    "KEYNAMES.H",
    "KBDDEV.H",
    "KEYDEF.H",
    "SCANCODE.H",
    "VGADEV.H",
    "STANDARD.H",
    "SPRNDEV.H",
    "PRNDEV.H",
    "DISKDEV.H",
    "SCALEDEV.H",
    "NETDEV.H",
    "MESSAGE.H",
    NULL
};
void getpubs(char *file,int all)
{
    FILE *fp;
    char line[256];
    int togg=0,ot;

    char *e;    
    fp=fopen(file,"r");
    if (fp==NULL) {
        fprintf(stderr,"Can't Open %s\n",file);
        return;
    }
    printf("// ------------------------------ %s START ------------------------------\n\n",file);

    while ((fgets(line,255,fp)!=NULL)) {
        if (!all) {
            if ((e=strstr(line,"INIT"))!=NULL) *e=0;
            e=&line[strlen(line)-1];
            while (((*e=='\n')||(*e==' ')||(*e==';'))&&(e!=line)) *(e--)=0;
        }
        ot=togg;
        if (!strncmp(line,"// PUBLIC SYMBOLS",17)) togg^=1;
        if (togg) {
            if (all) {
                if (ot==togg) printf("%s",line);
            } else {
                if (!strncmp(line,"PUBLIC",6))  printf("extern %s;\n",&line[6]);
                if (!strncmp(line,"#define",7)) printf("%s\n",line);
            }
        }
    }

    fclose(fp);
    printf("\n// ------------------------------- %s END --------------------------------\n\n",file);
}
int main(void)
{
    int i=0;

//    printf("#define INIT(a)        ; // switch off initialisation\n");
//    printf("#define INIT4(a,b,c,d) ; // switch off initialisation\n");

    getpubs("TYPES.H",1);

    while (G_files[i]!=NULL) getpubs(G_files[i++],0);

    return(0);
}
/***********************************************************************/
