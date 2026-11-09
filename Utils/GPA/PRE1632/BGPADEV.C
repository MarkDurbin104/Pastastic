#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
char devtype;
char uname[10];
char name[10];
char fullname[20];
char copyright[20];
char file[20];

typedef struct {
	char *name;
	char *cap;
} DEVCAPMAP;
int G_devcomoff[]={0,17,28,41,9999,9999,9999,9999,9999};
char *G_devcoms[]={
	"INPUT                 - Return the character size",
	"OUTPUT                - int x,int y,char *fmt(as in printf)...",
	"RESET                 - no params",
	"SET ATTRIBUTE         - int a",
	"CURSOR                - int xorigin,int xoffset,int y,int length",
	"DRAW BOX              - int x,int y,int x1,int y1",
	"DRAW LINE             - int x,int y,int x1,int y1",
	"SET WRITE MODE TO XOR - int x=TRUE/FALSE",
	"SET CHARATER SIZE     - int size",
	"SHOW THE SHIFT LIGHTS - int shiftstat",
	"INITIALISE DEVICE     - no params",
	"END        DEVICE     - no params",
	"DRAW LOGO             - int x,int y",
	"SINK  A FIELD         - int x,int y,int len",
	"RAISE A FIELD         - int x,int y,int len",
	"POSITION OF CURSOR    - int x,int pos,char *string",
	"LOAD FONT             - char *fontfilename"

	"RESET                 - no params",
	"OUTPUT                - int x,int y,char *fmt(as in printf)...",
	"INITIALISE DEVICE     - no params",
	"SET CHARATER SIZE     - int size",
	"SET ATTRIBUTE         - int a",
	"SET PAPER BORDERS     - int maxx, int maxy",
	"END        DEVICE     - no params",
	"END OF FORM           - no params",
	"DRAW BOX              - int x,int y,int x1,int y1",
	"DRAW LINE             - int x,int y,int x1,int y1",
	"SET OPERATING MODE    - int mode"

	"INPUT                 - wait for keypress and return it",
	"FLUSH                 - clear the keyboard buffer",
	"INITIALISE DEVICE     - no params",
	"END        DEVICE     - no params",
	"HIT                   - return TRUE if keypress present",
	"REPLACE			   - replace top item in key buffer with int k",
	"P",
	"C",
	"e",
	"r",
	"p",
	"A",
	"D"
};
DEVCAPMAP G_dcm[]={
	{"OUTPUT01","ioRACBLXSlIEDsrpF" },
	{"OUTPUT02","RoISAbEFBLM"		},
	{"INPUT 01","iFIEHRPCerpAD"		},
	{"INPUT 02","iRZIOE"			},
	{"DISK  01","CUDTSGFPRNIEd"		},
	{"LAN   01","irISRDNGEC"		}
};

void builddevh(void)
{
    FILE *fp;
    sprintf(file,"%sDEV.H",uname);
    fp=fopen(file,"w");
    if (fp==NULL) {
        printf("Can't open %s\n",file);
        exit(0);
    }
    fprintf(fp,"#ifndef %sDEV_H\n",uname);
    fprintf(fp,"#define %sDEV_H\n\n",uname);
    fprintf(fp,"#ifdef PUBLIC\n");
    fprintf(fp,"#undef PUBLIC\n");
    fprintf(fp,"#endif\n");
    fprintf(fp,"#ifdef INIT\n");
    fprintf(fp,"#undef INIT\n");
    fprintf(fp,"#endif\n\n");
    fprintf(fp,"#ifdef %sDEV_C\n",uname);
    fprintf(fp,"#define PUBLIC\n");
    fprintf(fp,"#define INIT 1\n");
    fprintf(fp,"#else\n");
    fprintf(fp,"#define PUBLIC extern\n");
    fprintf(fp,"#define INIT 0\n");
    fprintf(fp,"#endif\n\n");
    fprintf(fp,"// PUBLIC SYMBOLS S\n\n");
    fprintf(fp,"#ifdef %sDEV_C\n",uname);
    fprintf(fp,"PUBLIC int %s_control(int type,va_list ap);\n",name);
    fprintf(fp,"#endif\n\n");
    fprintf(fp,"PUBLIC DEVHEADER dev_%s\n",name);
    fprintf(fp,"#if INIT\n");
    fprintf(fp,"= {\n");
    fprintf(fp,"    DEVSIG,\n");
    fprintf(fp,"    \"%s Copyright (c) %s Version 1.00\",\n",fullname,copyright);
   	fprintf(fp,"    \"%s\",\n",G_dcm[devtype].name);
   	fprintf(fp,"    \"%s\",\n",uname);
   	fprintf(fp,"    \"%s\",\n",G_dcm[devtype].cap);
	fprintf(fp,"    NULL,\n");
	fprintf(fp,"    NULL,\n");
    fprintf(fp,"    (DFPTR)%s_control,\n",name);
	fprintf(fp,"    NULL,\n");
    fprintf(fp,"    DEVSIG\n");
    fprintf(fp,"}\n");
    fprintf(fp,"#endif\n");
    fprintf(fp,";\n\n");
    fprintf(fp,"// PUBLIC SYMBOLS E\n\n");
    fprintf(fp,"#ifdef %sDEV_C\n",uname);
    fprintf(fp,"// Place your device's variables & prototypes here\n\n");
    fprintf(fp,"#endif  //  def %sDEV_C\n\n",uname);
    fprintf(fp,"#endif  //  ndef %sDEV_H\n",uname);
    fclose(fp);
}
void builddevc(void)
{
    FILE *fp;
	int i;
    sprintf(file,"%sDEV.C",uname);
	fp=fopen(file,"w");
    if (fp==NULL) {
        printf("Can't open %s\n",file);
        exit(0);
    }
	fprintf(fp,"#define %sDEV_C\n",uname);
	fprintf(fp,"#include <stdio.h>\n");
	fprintf(fp,"#include <stdarg.h>\n");
	fprintf(fp,"#include \"types.h\"\n");
	fprintf(fp,"#include \"%sdev.h\"\n\n",name);
	fprintf(fp,"//___________________________________________________________________________\n\n");
	fprintf(fp,"// %sdev control routine\n",name);
	fprintf(fp,"int %s_control(int type,va_list ap)\n",name);
	fprintf(fp,"{\n    int retval=0;\n    switch(type) {\n");
	for (i=0;i<strlen(G_dcm[devtype].cap);i++) {
		fprintf(fp,"        case \'%c\' : // %s\n            retval=1;\n            break;\n",
			G_dcm[devtype].cap[i],
			(G_devcomoff[devtype]==9999)?"":G_devcoms[G_devcomoff[devtype]+i] );
	}
	fprintf(fp,"    }\n");
	fprintf(fp,"    return(retval);\n}\n");
	fprintf(fp,"//___________________________________________________________________________\n");

    fclose(fp);
}
int main(int argc,char*argv[])
{
    if (argc<5) {
        printf("bgpadev O|o|I|i|d|n DeviceName DescriptiveName Copyright&Date\n");
        return(0);
    }
	switch (argv[1][0]) {
		case 'O' : devtype=0; break;
		case 'o' : devtype=1; break;
		case 'I' : devtype=2; break;
		case 'i' : devtype=3; break;
		case 'd' : devtype=4; break;
		case 'n' : devtype=5; break;
	}
    strcpy(name,argv[2]);
    strcpy(uname,argv[2]);
    strupr(uname);
    strcpy(fullname,argv[3]);
    strcpy(copyright,argv[4]);
	builddevh();
	builddevc();
    return(1);
}


