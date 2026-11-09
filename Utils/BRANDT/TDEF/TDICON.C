#include <graphics.h>
#include <dos.h>
#include <io.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <conio.h>
#include "mouse.h"

void grafix(void);
void dump(char *filename);

int G_driver,G_mode,G_maxx,G_maxy;
int msex,msey,mseb;
unsigned long G_icon[36][33];

main(int argc,char **argv){
	int i,j,k,mx,my,cicon=0,setclr,fd,xit,cutting;
	char far *t=MK_FP(0x0000,0x0417);
	FILE *fp;
	if (argc<2) {
		printf("Filename ?\n");
		exit(-1);
	}
	fd=open(argv[1],O_RDONLY);
	if (fd!=(-1)) {
		read(fd,G_icon,sizeof(G_icon));
		close(fd);
	}
	grafix();
	setupmouse(G_maxx/2,G_maxy/2,(G_maxx-330)/2,((G_maxx-330)/2)+320,(G_maxy-330)/2,((G_maxy-330)/2)+320);
	setbkcolor(1);
	cleardevice();
	setviewport(0,0,G_maxx,G_maxy,1);
	for(i=0;i<36;i++) {
		for (j=0;j<32;j++) {
			for (k=0;k<32;k++) {
				putpixel(10+((i/12)*36)+k,10+j+((i%12)*36),15*((G_icon[i][j]&(1L<<(31-k)))!=0));
			}
		}
	}
	setcolor(14);
	rectangle(9+((cicon/12)*36),9+((cicon%12)*36),42+((cicon/12)*36),42+((cicon%12)*36));
	setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
	setcolor(11);
	for (i=0;i<33;i++) {
		line(i*10,0,i*10,320);
		line(0,i*10,320,i*10);
	}
	setcolor(4);
	line(240,0,240,320);
	line(0,240,320,240);
	line(80,0,80,320);
	line(0,80,320,80);
	setcolor(12);
	line(160,0,160,320);
	line(0,160,320,160);
	setcolor(11);
	for (j=0;j<32;j++) {
		for (k=0;k<32;k++) {
			setfillstyle(1,15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
			bar(k*10+1,j*10+1,k*10+9,j*10+9);
		}
	}
	mousecur(1);
	cutting=0;
	xit=0;
	while (!xit) {
		if (kbhit()) {
			switch (getch()) {
				case 'c' : {
					mousecur(0);
					for (i=0;i<32;i++) G_icon[cicon][i]=0L;
					for (j=0;j<32;j++) {
						for (k=0;k<32;k++) {
							setfillstyle(1,15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
							bar(k*10+1,j*10+1,k*10+9,j*10+9);
						}
					}
					setviewport(0,0,G_maxx,G_maxy,1);
					for (j=0;j<32;j++) {
						for (k=0;k<32;k++) {
							putpixel(10+((cicon/12)*36)+k,10+j+((cicon%12)*36),15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
						}
					}
					setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
					mousecur(1);
				} break;
				case 'x' : {
					cutting=cicon;
				} break;
				case 'p' : {
					mousecur(0);
					setviewport(0,0,G_maxx,G_maxy,1);
					dump(argv[1]);
					setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
					mousecur(1);
				} break;
				case 'v' : {
					mousecur(0);
					for (i=0;i<32;i++) G_icon[cicon][i]=G_icon[cutting][i];
					for (j=0;j<32;j++) {
						for (k=0;k<32;k++) {
							setfillstyle(1,15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
							bar(k*10+1,j*10+1,k*10+9,j*10+9);
						}
					}
					setviewport(0,0,G_maxx,G_maxy,1);
					for (j=0;j<32;j++) {
						for (k=0;k<32;k++) {
							putpixel(10+((cicon/12)*36)+k,10+j+((cicon%12)*36),15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
						}
					}
					setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
					mousecur(1);
				} break;
				case 27 : {
					xit=1;
				} break;
				default : {
					sound(2000);
					for(i=0;i<10000;i++);
					nosound();
				}
			}
		}
		if (mousetrap(1)) {
			mx=(((msex/10)*10)+5)-((G_maxx-330)/2);
			my=(((msey/10)*10)+5)-((G_maxy-330)/2);
			if (mseb==1) {
				setclr=((G_icon[cicon][my/10]&(long)(1L<<(31-(mx/10))))==0);
				while (((mousetrap(1)>>5)&0x07)==1) {
					mx=(((msex/10)*10)+5)-((G_maxx-330)/2);
					my=(((msey/10)*10)+5)-((G_maxy-330)/2);
					if ((mx<320)&&(my<320)) {
						mousecur(0);
					setfillstyle(1,15);
						bar(mx,my,mx+8,my+8);
						setviewport(0,0,G_maxx,G_maxy,1);
						if (setclr) {
							G_icon[cicon][my/10]|=(long)(1L<<(31-(mx/10)));
						}
						else {
							G_icon[cicon][my/10]&=0xFFFFFFFFL^(long)(1L<<(31-(mx/10)));
						}
						for (k=0;k<32;k++) {
							putpixel(10+((cicon/12)*36)+k,10+(my/10)+((cicon%12)*36),15*((G_icon[cicon][my/10]&(1L<<(31-k)))!=0));
						}
/*						sprintf(tmp,"0x%08lX",G_icon[cicon][my/10]);
						outtextxy((G_maxx/2)+200,((G_maxy-330)/2)+my,tmp);*/
						setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
						for (k=0;k<32;k++) {
							setfillstyle(1,15*((G_icon[cicon][my/10]&(1L<<(31-k)))!=0));
							bar(k*10+1,my,k*10+9,my+8);
						}
						mousecur(1);
					}
				}
			}
			if (mseb==2) {
				mousecur(0);
				setviewport(0,0,G_maxx,G_maxy,1);
				setcolor(0);
				rectangle(9+((cicon/12)*36),9+((cicon%12)*36),42+((cicon/12)*36),42+((cicon%12)*36));
				if ((*t)&3) {
					if (--cicon<0) cicon=35;
				}
				else {
					if (++cicon>35) cicon=0;
				}
				setcolor(14);
				rectangle(9+((cicon/12)*36),9+((cicon%12)*36),42+((cicon/12)*36),42+((cicon%12)*36));
				setviewport((G_maxx-330)/2,(G_maxy-330)/2,((G_maxx-330)/2)+320,((G_maxy-330)/2)+320,1);
				for (j=0;j<32;j++) {
					for (k=0;k<32;k++) {
						setfillstyle(1,15*((G_icon[cicon][j]&(1L<<(31-k)))!=0));
						bar(k*10+1,j*10+1,k*10+9,j*10+9);
					}
				}
				mousecur(1);
			}
		}
	}
	fd=open(argv[1],O_WRONLY|O_TRUNC|O_CREAT|O_BINARY,0777);
	if (fd!=(-1)) {
		write(fd,G_icon,sizeof(G_icon));
		close(fd);
	}
	for (j=0;j<36;j++) {
		for (k=0;k<32;k++) {
			G_icon[j][k]=
			((G_icon[j][k]&0x000000FFL)<<24)+((G_icon[j][k]&0x0000FF00L)<<8)+
			((G_icon[j][k]&0x00FF0000L)>>8)+((G_icon[j][k]&0xFF000000L)>>24);
		}
	}
	fp=fopen("tdicon.h","w");
	fprintf(fp,"unsigned long	G_icon[36][33]={\n");
	for (j=0;j<35;j++) {
		fprintf(fp,"	{");
		for (k=0;k<31;k++) {
			fprintf(fp,"0x%08lXL,",G_icon[j][k]);
			if (!((k+1)%4)) fprintf(fp,"\n	 ");
		}
		fprintf(fp,"0x%08lXL},\n",G_icon[j][k]);
	}
	fprintf(fp,"	{");
	for (k=0;k<31;k++) {
		fprintf(fp,"0x%08lXL,",G_icon[j][k]);
		if (!((k+1)%4)) fprintf(fp,"\n	 ");
	}
	fprintf(fp,"0x%08lXL}};\n",G_icon[j][k]);
	fclose(fp);
	closegraph();
	return(1);
}
void grafix(void) {
	int errormode;
	G_driver = DETECT;
	initgraph( &G_driver, &G_mode, "" );
	errormode = graphresult();
	if( errormode != grOk ){
		printf("graphics System Error: %s\n",grapherrormsg(errormode));
		exit(1);
	}
	G_maxx=getmaxx();
	G_maxy=getmaxy();
}
void dump(char *filename) {
	int i,j,l,prbyte;
	FILE *printer;
	if ((printer=fopen("PRN","w"))!=NULL) {
		fprintf(printer,"Icons [%s] Printed For P.M.A. TASK DEFINE\n\n",filename);
		fprintf(printer,"%cU1%cA%c",27,27,8);
		for (i=0;i<G_maxy-1;i+=8) {
			fprintf(printer,"%cZ%c%c",27,(G_maxx*3)%256,(G_maxx*3)/256);
			for (j=0;j<G_maxx;j++) {
				prbyte=0;
				for (l=0;l<8;l++) {
					prbyte|=((getpixel(j,i+l)&0x0F)!=0)<<(7-l);
				}
				switch(prbyte) {
					case 26 : {
						fprintf(printer,"%c%c%c",24,22,24);
					} break;
					case 10 : {
						fprintf(printer,"%c%c%c",11,9,11);
					} break;
					default : {
						fprintf(printer,"%c%c%c",prbyte,prbyte,prbyte);
					}
				}
			}
			fprintf(printer,"\n");
			if (kbhit()) break;
		}
		if (kbhit()) getch();
		fprintf(printer,"%c",12);
		fclose(printer);
	}
}
