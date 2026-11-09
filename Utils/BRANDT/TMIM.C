#include <conio.h>
#include <alloc.h>
#include <mem.h>
#include <dos.h>
#include "tdmouse.h"

#define SVAL(c) ((G_bcol<<12)|(G_fcol<<8)|c)

unsigned int *G_scr=MK_FP(0xB800,0x0000),**G_lns,savscr[2000];
int G_wid,G_hgt,G_xpos,G_ypos,G_cx,G_cy,G_bcol,G_fcol;

void refresh(void);

main() {
	int i,j,xit,ip=(-1);
	char k;
	struct text_info t;

	gettextinfo(&t);
	memcpy(savscr,G_scr,4000);

	G_wid=640;
	G_hgt=500;
	G_cy=G_cx=G_ypos=G_xpos=0;
	G_bcol=0;
	G_fcol=14;

	G_lns=malloc(G_hgt*sizeof(int *));
	for (i=0;i<G_hgt;i++) {
		G_lns[i]=malloc(G_wid*sizeof(int));
		if (G_lns[i]==NULL) {
			G_hgt=i;
			break;
		}
		else {
			for (j=0;j<G_wid;j++) G_lns[i][j]=SVAL(0);
		}
	}
	for (j=0;j<G_wid;j++) {
		G_lns[0][j]=SVAL(0xDB);
		G_lns[G_hgt-1][j]=SVAL(0xDB);
	}
	for (j=0;j<G_hgt;j++) {
		G_lns[j][0]=SVAL(0xDB);
		G_lns[j][G_wid-1]=SVAL(0xDB);
	}
	setupmouse(0,0,0,8*(G_wid-1),0,8*(G_hgt-1));
	xit=0;
	refresh();
	while(!xit) {
		if (kbhit()) {
			switch (k=getch()) {
				case 0 : {
					switch (getch()) {
						case ';' : G_fcol=(++G_fcol)&15; break;
						case '<' : G_bcol=(++G_bcol)&15; break;
					}
				} break;
				case 27 : {
					xit=1;
				} break;
				case 10 :
				case 13 : {
					G_ypos++;
					G_xpos=ip;
				} break;
				default : {
					if (ip==(-1)) ip=G_xpos;
					G_lns[G_ypos+G_cy][G_xpos+G_cx]=SVAL(k);
					G_xpos++;
				}
			}
			refresh();
		}
		if (mousetrap(8)) {
			ip=(-1);
			G_cx=msex/8-G_xpos;
			G_cy=msey/8-G_ypos;
			if (G_cx>79) {
				G_xpos+=G_cx-79;
				G_cx=79;
			}
			if (G_cy>24) {
				G_ypos+=G_cy-24;
				G_cy=24;
			}
			if (G_cx<0) {
				G_xpos+=G_cx;
				G_cx=0;
			}
			if (G_cy<0) {
				G_ypos+=G_cy;
				G_cy=0;
			}
			if (mseb==1) G_lns[G_ypos+G_cy][G_xpos+G_cx]=SVAL(0xDB);
			if (mseb==2) G_lns[G_ypos+G_cy][G_xpos+G_cx]=SVAL(0);
			refresh();
		}
	}
	for (i=0;i<G_hgt;i++) free(G_lns[i]);
	free(G_lns);
	memcpy(G_scr,savscr,4000);
	gotoxy(t.curx,t.cury);
	textattr(t.attribute);
	return(1);
}
void refresh(void) {
	int i;
	for (i=0;i<25;i++) memcpy(G_scr+i*80,&G_lns[i+G_ypos][G_xpos],160);
	gotoxy(G_cx+1,G_cy+1);
	*(G_scr+G_cy*80+G_cx)^=SVAL(0);
}
