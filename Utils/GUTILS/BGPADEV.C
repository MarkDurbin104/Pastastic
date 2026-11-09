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
    fprintf(fp,"PUBLIC int %s_control(char type,va_list ap);\n\n",name);
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
    fprintf(fp,"#ifdef %sDEV_C\n\n",uname);
    fprintf(fp,"#endif  //  def %sDEV_C\n\n",uname);
    fprintf(fp,"#endif  //  ndef %sDEV_H\n",uname);
    fclose(fp);
}
void builddevc(void)
{
    FILE *fp;
    sprintf(file,"%sDEV.C",uname);
	fp=fopen(file,"w");
    if (fp==NULL) {
        printf("Can't open %s\n",file);
        exit(0);
    }
	fprintf(fp,"#define %sDEV_C\n",uname);
	fprintf(fp,"#include <stdarg.h>\n");
	fprintf(fp,"#include <stdio.h>\n");
	fprintf(fp,"#include \"types.h\"\n");
	fprintf(fp,"#include \"%sdev.h\"\n",name);
	fprintf(fp,"//___________________________________________________________________________\n");
	fprintf(fp,"// %sdev shutdown routine\n",name);
	fprintf(fp,"int %s_shutdown(void)\n",name);
	fprintf(fp,"{\n    return(1);\n}\n");
	fprintf(fp,"// %sdev startup routine\n",name);
	fprintf(fp,"int %s_startup(void)\n",name);
	fprintf(fp,"{\n    return(1);\n}\n");
	fprintf(fp,"// %sdev control routine\n",name);
	fprintf(fp,"int %s_control(char type,va_list ap)\n",name);
	fprintf(fp,"{\n    int retval=0;\n   switch(type) {\n");
	for (i=0;i<strlen(G_dcm[devtype].cap);i++) {
		fprintf(fp,"        case \'%c\' :\n            retval=1;\n            break;\n",G_dcm[devtype].cap[i]);
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