//SYSDOC FR.CMT
#define GPA_C

#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <mem.h>
#include <alloc.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>

#include "types.h"
#include "config.h"
#include "formhand.h"
#include "control.h"
#include "actionc.h"

char   *G_fclass[]   ={"MANDATORY","OPTIONAL","SEARCH","TEXT","MANDSRCH","MANDSECS","WAIT","DISPLAY","SECSRCH","TABLE",NULL};
char   *G_formtypes[]={"FORM","SERVE","PROMPT","MENU","REPORT","PPFORM"};
char   *G_acctypes[] ={"ACTION","FORM","UFUNC","CFUNC","TABLE"};

CHAR *langtext(INT idx)
{
	ENTRY(2490);
    idx+=G_nut;
	RETURNV(atextstr(idx));
}
CHAR *textstr(CHAR *s)
{
    INT j;
	ENTRY(2500);
    if (s==NULL) RETURNV("NOTEXT");
    if (strncmp(s,"TEXT",4)) RETURNV(s);
    if (*(s+4)=='_') j=atoi(s+5); else j=atoi(s+4);
    if (j>(G_tcnt-G_nut)) RETURNV(s);
	RETURNV(langtext(j));
}
// GPA runtime    Usage - "GPA system_name"
int main(int argc,char *argv[]) 
{
    int i,x;
	FILE *fp;
	PFORMF f;

	G_sstart=((_SS<<16)|_SP);
	if (argc<2) {
		printf("%s SYSTEM [FORM]\n",argv[0]);
		return(1);
	}
	if (!readconfig(argv[1])) {
        printf("Error reading config file %s.cfg\n",argv[1]);
        RETURNV(1);
	}
    G_lang=0;
 	readlang(G_lang);
   	freetext();
   	loadtext(G_system);
   	loadactions(G_system);
//	addlangname(G_name);
    strcpy(G_form.name,"logon");
    G_form.items=NULL;
    if (!loadform(&G_form)) {
        printf("Can't load form logon for %s\n",G_system);
        RETURNV(1);
    }
    fp=stdout;
	if (argc==3) {
//    	clrform(&G_form);
    	freeform(&G_form);
       	strcpy(G_form.name,argv[2]);
    	if (!loadform(&G_form)) {
        	printf("Can't load form [%s] for %s\n",argv[2],G_system);
        	RETURNV(1);
    	}
    	if ((G_form.type==F_MENU)||(G_form.type==F_REPORT)) {
        	orderform(&G_form,1);
    	} else {
        	orderform(&G_form,0);
    	}
       	fprintf(fp,"Form %-8s  Type %s  Containing %d items Access level %d Update %s\n",
			G_form.name,G_formtypes[G_form.type],G_form.numitem,G_form.access,(((G_form.attribs&FA_UPDS)==FA_UPDS)?"ON":"OFF"));
       	fprintf(fp,"IDX X  Y  A CLASS     S ID  FUNC      NAME       FORMAT  ITEM               \n");             
       	for (i=0;i<G_form.numitem;i++) {
           	f=&G_form.items[i];
          	fprintf(fp,"%03d %02d %02d %X %-9.9s %d %02d [%-8.8s] [%-8.8s] [%4s] [%-17s] \n",
           		i,f->pos.x,f->pos.y,f->attrib,G_fclass[f->class&0x7FFF],f->size,f->ident,f->func,f->name,f->fmt,textstr(f->item));
       	}
       	fprintf(fp,"\n\n");
	} else {
    	fprintf(fp,"%s %d Forms\n",datestr(0),G_numidx);
    	for (x=0;x<G_numidx;x++) {
//	    	clrform(&G_form);
	    	freeform(&G_form);
        	strcpy(G_form.name,G_fid[x]->name);
	    	if (!loadform(&G_form)) {
	        	printf("Can't load form [%s] for %s\n",G_fid[x]->name,G_system);
	        	RETURNV(1);
	    	}
	    	if ((G_form.type==F_MENU)||(G_form.type==F_REPORT)) {
	        	orderform(&G_form,1);
	    	} else {
	        	orderform(&G_form,0);
	    	}
        	fprintf(fp,"Form %-8s  Type %s  Containing %d items Access level %d Update %s\n",
				G_form.name,G_formtypes[G_form.type],G_form.numitem,G_form.access,(((G_form.attribs&FA_UPDS)==FA_UPDS)?"ON":"OFF"));
           	fprintf(fp,"IDX X  Y  A CLASS     S ID  FUNC      NAME       FORMAT  ITEM               \n");             
        	for (i=0;i<G_form.numitem;i++) {
            	f=&G_form.items[i];
            	fprintf(fp,"%03d %02d %02d %X %-9.9s %d %02d [%-8.8s] [%-8.8s] [%4s] [%-17s] \n",
            		i,f->pos.x,f->pos.y,f->attrib,G_fclass[f->class&0x7FFF],f->size,f->ident,f->func,f->name,f->fmt,textstr(f->item));
        	}
        	fprintf(fp,"\n\n");
		}
	}
//    for (i=0;i<G_numn;i++) {
//        if (actionbuf(i)!=NULL)  {
//            printf("Action %d %-8.8s %-8.8ld,%02X,%02X,%s\n",
//                i,actionname(i),actionofs(i),actiontype(i),actiondeb(i),actionbuf(i));
//        } else {
//            printf("Action %d %-8.8s %-8.8ld,%02X,%02X\n",
//                i,actionname(i),actionofs(i),actiontype(i),actiondeb(i));
//        }
//    }
    RETURNV(0);
}
