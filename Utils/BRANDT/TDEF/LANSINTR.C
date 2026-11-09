#include <fcntl.h>
#include <stdio.h>
#include <conio.h>
#include <io.h>
#include <mem.h>
#include <ctype.h>
#include <string.h>
#include "convhpgl.h"

int  readinfile(char *filnam) {
	int i,length,bufsiz,ptr,j;
	char currentln[200];
	char tmpln[200];
	int  fdes;
	int  counter=0;
	char term1='\n';
	char term2=';';
	seperator=',';
	if ((fdes=open(filnam,O_RDONLY))==(-1)) {
		return(0);
	}
	counter=0;
	while (1) {
		if ((bufsiz=read(fdes,textlns,16000))==0) {
			close(fdes);
			return(1);
		}
		ptr=0;
/*		while (((currentln[counter]=getrx())==(-1))&&(!(kbhit())));
		lookrx()		*/
		while (ptr<bufsiz) {
			currentln[counter]=textlns[ptr++];
			if ((currentln[counter]==term1) || (currentln[counter]==term2)) {
				if (counter>1) {
					currentln[counter]=0;
					length=counter;
					for(i=2;i<length;i++) {
						if (isdigit(currentln[i])
						&& ((currentln[i+1]>64)&&(currentln[i+1]<86))) {
							for (j=0;j<=i;j++) tmpln[j]=currentln[j];
							tmpln[i+1]=0;
							for (j=i+1;j<=length;j++) tmpln[j+1]=currentln[j];
							length++;
							memcpy(currentln,tmpln,length+1);
						}
					}
					for(i=2;i<length;i++) {
						if ((currentln[i]==',')
						&& ((currentln[i+1]>64)&&(currentln[i+1]<86))) {
							currentln[i]=0;
						}
					}
					interpln(currentln);
					for(i=2;i<length;i++) {
						if (currentln[i]==0) {
							interpln(&currentln[i+1]);
							if ((currentln[i+3]>64)&&(currentln[i+3]<86)) {
								interpln(&currentln[i+3]);
							}
						}
					}
					counter=(-1);
				}
				else {
					counter=(-1);
				}
			}
			counter++;
		}
	}
	return(1);
}
void interpln(char *passedln) {
	int i=0;
	char currentln[200];
	static int lastinst=0;
	union test {
		int val;
		char line[200];
	} current;
	while (isspace(passedln[i])) i++;
	strcpy(currentln,&passedln[i]);
	current.line[0]=currentln[0];
	current.line[1]=currentln[1];
	switch(current.val) {
		case 'DF' : {	/* DF  set default status					*/
			setdefaults();
/*			coords[0][0]=0;
			coords[0][1]=0;
			G_xcur=0;
			G_ycur=0;*/
		} break;
		case 'PA' : {	/* PA Plot Absolute							*/
			if ((nocds==0)&&(lastinst==1)) {
				coords[nocds][0]=G_xcur;
				coords[nocds][1]=G_ycur;
				nocds++;
			}
			lastinst=0;
			getints(currentln);
			if (argus.no>=2) {
				for (i=0;i<argus.no;i+=2) {
					coords[nocds][0]=argus.ag[i  ];
					coords[nocds][1]=argus.ag[i+1];
					nocds++;
				}
				G_xcur=coords[nocds-1][0];
				G_ycur=coords[nocds-1][1];
			}
		} break;
		case 'PR' : {	/* PR Plot Relative							*/
			if ((nocds==0)&&(lastinst==1)) {
				coords[nocds][0]=G_xcur;
				coords[nocds][1]=G_ycur;
				nocds++;
			}
			lastinst=0;
			getints(currentln);
			if (argus.no>=2) {
				for (i=0;i<argus.no;i+=2) {
					coords[nocds][0]=coords[nocds-1][0]+argus.ag[i  ];
					coords[nocds][1]=coords[nocds-1][1]+argus.ag[i+1];
					nocds++;
				}
				G_xcur=coords[nocds-1][0];
				G_ycur=coords[nocds-1][1];
			}
		} break;
		case 'PD' : {	/* PD Pen down								*/
			if (lastinst==2) {
				lastinst=1;
            }
            else {
				lastinst=0;
			}
			penup=0;
			getints(currentln);
			if (argus.no>=2) {
				for (i=0;i<argus.no;i+=2) {
					coords[nocds][0]=argus.ag[i  ];
					coords[nocds][1]=argus.ag[i+1];
					nocds++;
				}
				G_xcur=coords[nocds-1][0];
				G_ycur=coords[nocds-1][1];
			}
		} break;
		case 'PU' : {	/* PU Pen up								*/
			lastinst=2;
			penup=1;
			getints(currentln);
			if ((argus.no==2)
			&&  (G_xcur==argus.ag[argus.no-2])
			&&  (G_ycur==argus.ag[argus.no-1])) {
				G_xcur=coords[nocds][0]=argus.ag[argus.no-2];
				G_ycur=coords[nocds][1]=argus.ag[argus.no-1];
				nocds++;
			}
			else {
				if (nocds>0) ddrawpoly(0,nocds,(int *)coords);
				nocds=0;
				if (argus.no>=2) {
					G_xcur=coords[nocds][0]=argus.ag[argus.no-2];
					G_ycur=coords[nocds][1]=argus.ag[argus.no-1];
					nocds++;
				}
			}
		} break;
		case 'SP' : {	/* SP Select pen							*/
			getints(currentln);
			if (argus.no>=1) {
				G_colour=argus.ag[0];
			}
		} break;
		default  : {
		}
	}
}
