#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <conio.h>
#include <graphics.h>
#include "tdef.h"

int popup(int x,int y,int w,int h,char *q,int def,char *items) {
	int i=0,j;
	char tmp[100],*t;
	struct viewporttype s;
	getviewsettings(&s);
	strcpy(tmp,items);
	t=strtok(tmp,".");
	while(t!=(char *)NULL) {
		i++;
		t=strtok((char *)NULL,".");
	}
	setfillstyle(1,1);
	settextjustify(1,2);
	setcolor(14);
	mousecur(0);
	bar(x-2,y-2,x+w+2,y+h+2);
	rectangle(x-2,y-2,x+w+2,y+h+2);
	rectangle(x,y,x+w,y+h);
	settextstyle(0,0,1);
	outtxtxy(x+(w/2),y+10,q);
	strcpy(tmp,items);
	t=strtok(tmp,".");
	for (j=0;j<i;j++) {
		button(x+50+((w-100)/(i-1))*j,y+(h/2),t,0,(j==def));
		t=strtok((char *)NULL,".");
	}
	mousecur(1);
	while (1) {
		if (mousetrap(G_snapto)) {
			if (mseb==1) {
				strcpy(tmp,items);
				t=strtok(tmp,".");
				for (j=0;j<i;j++) {
					if (inbox(s.left+x+25+((w-100)/(i-1))*j,s.top+(y+(h/2))-10,s.left+x+75+((w-100)/(i-1))*j,s.top+(y+(h/2))+10)) {
						mousecur(0);
						button(x+50+((w-100)/(i-1))*j,y+(h/2),t,1,1);
						mousecur(1);
						while (mseb) mousetrap(G_snapto);
						return(j);
					}
					t=strtok((char *)NULL,".");
				}
			}
		}
		if (kbhit()) {
			if (getch()=='\r') return(def);
		}
	}
}
int pulldn(int x,int y,char *items) {
	int i=0,j,h,w=0,ch;
	char tmp[100],*t;
	strcpy(tmp,items);
	settextstyle(0,0,1);
	t=strtok(tmp,".");
	while(t!=(char *)NULL) {
		i++;
		w=max(w,textwidth(t));
		t=strtok((char *)NULL,".");
	}
	setfillstyle(1,1);
	settextjustify(1,2);
	setcolor(14);
	mousecur(0);
	ch=textheight("8")*2;
	h=i*ch;
	w+=20;
	bar(x-2,y,x+w+2,y+h+2);
	rectangle(x-2,y,x+w+2,y+h+2);
	rectangle(x,y+2,x+w,y+h);
	strcpy(tmp,items);
	t=strtok(tmp,".");
	for (j=0;j<i;j++) {
		outtxtxy(x+(w/2),y+5+(ch*j),t);
		t=strtok((char *)NULL,".");
	}
	mousecur(1);
	while (mseb) mousetrap(G_snapto);
	while (1) {
		if (mousetrap(G_snapto)) {
			if (mseb==1) {
				strcpy(tmp,items);
				t=strtok(tmp,".");
				for (j=0;j<i;j++) {
					if (inbox(WINX+x,WINY+y+(ch*j),WINX+x+w,WINY+y+(ch*(j+1)))) {
						mousecur(0);
						setfillstyle(1,0);
						bar(x+1,(y+(ch*j)+1)+(2*(j==0)),x+w-1,y+(ch*(j+1))-1);
						outtxtxy(x+(w/2),y+5+(ch*j),t);
						mousecur(1);
						while (mseb) mousetrap(G_snapto);
						if (!(inbox(WINX+x,WINY+y,WINX+x+w,WINY+y+(ch*i)))) {
							return(-1);
						}
						return(j);
					}
					t=strtok((char *)NULL,".");
				}
				return(-1);
			}
		}
	}
}
void headings(int x,char *items) {
	int k;
	char tmp[100],*t;
	settextstyle(0,0,1);
	settextjustify(0,2);
	setcolor(14);
	mousecur(0);
	strcpy(tmp,items);
	t=strtok(tmp,".");
	k=x+10;
	while(t!=(char *)NULL) {
		outtxtxy(k,WINY/4,t);
		k+=(textwidth(t)+20);
		t=strtok((char *)NULL,".");
	}
	mousecur(1);
}
int inhead(int x,char *items) {
	int i=0,k;
	char tmp[100],*t;
	settextstyle(0,0,1);
	settextjustify(0,2);
	strcpy(tmp,items);
	t=strtok(tmp,".");
	k=x+10;
	while(t!=(char *)NULL) {
		if (inbox(k,1,k+textwidth(t),WINY-1)) {
			return(i);
		}
		i++;
		k+=(textwidth(t)+20);
		t=strtok((char *)NULL,".");
	}
	return(-1);
}
void intitles(void) {
	int s=1,noln,i,j,k,l,fileno,xit;
	file *b;
	FILE *repfil;
	char tmp[40];
	switch (inhead(WINX,"File.Options.Dictionary.Report")) {
		case 0 : {
			switch(pulldn(0,0,"Open.Close.New.Save.Save As.Print")) {
				case 0 : {
				} break;
				case 1 : {
				} break;
				case 2 : {
				} break;
				case 3 : {
				} break;
				case 4 : {
				} break;
				case 5 : {
				} break;
			}
		} break;
		case 1 : {
			switch(pulldn(60,0,"Colour.Library.Character.Font.Size")) {
				case 0 : {
				} break;
				case 1 : {
				} break;
				case 2 : {
				} break;
				case 3 : {
				} break;
				case 4 : {
				} break;
			}
		} break;
		case 2 : {
			switch(pulldn(140,0,"Open.New.Copy.Edit.Close.Report")) {
				case 0 : {
				} break;
				case 1 : {
				} break;
				case 2 : {
				} break;
				case 3 : {
					eddict();
					mousecur(0);
					cls();
					markpoints();
					mousecur(1);
				} break;
				case 4 : {
				} break;
				case 5 : {
					opendict();
					sprintf(tmp,"%s.rdd",G_cellname);
					repfil=fopen(tmp,"w");
					for (i=0;i<2;i++) {
						retdict(0);
						noln=0;
						do {
							if (!(noln%(G_dpp/15))) {
								fprintf(repfil,"TaskDefine Dictionary Report For Cell %-14s   Page %d\n",G_cellname,(noln/(G_dpp/15))+1);
								fprintf(repfil,"Name            Type Length Description\n\n");
								noln+=6;
							}
							fprintf(repfil,"%-14s  %c    %-5d  %-40s\n",G_dictent.name,G_dictent.type,G_dictent.len,G_dictent.desc);
							noln++;
							if (!(noln%(G_dpp/15))) fprintf(repfil,"%c",12);
						} while (nextdict());
						if ((noln%(G_dpp/15))) fprintf(repfil,"%c",12);
						fclose(repfil);
						repfil=stdprn;
					}
					closedict();
				} break;
			}
		} break;
		case 3 : {
			switch(pulldn(240,0,"Data Stores.DFD.PSD.IDS.TDS.FORMS.User Rep")) {
				case 0 : {
					sprintf(tmp,"%s.rds",G_cellname);
					repfil=fopen(tmp,"w");
					noln=0;
					xit=0;
					fileno=1;
					while (xit<3) {
						b=loadfile(G_cellname,fileno);
						if (b->name[0]==0) {
							free(b);
							xit++;
						}
						else {
							noln++;
							for (k=0;k<strlen(b->name);k++) if ((b->name[k]==13)||(b->name[k]==10)) b->name[k]=32;
							fprintf(repfil,"%s\t%c\t%d\t%s\r",b->name,b->type,fileno,b->desc);
							for (l=0;l<b->nofld;l++) {
								for (k=0;k<b->nokey;k++) {
									for (j=0;j<b->keys[k]->noparts;j++) {
										if (b->keys[k]->keypts[j]->fld==l) {
											fprintf(repfil,"%d\t",b->keys[k]->keypts[j]->fldordr);
											break;
										}
									}
									if (j==b->keys[k]->noparts) fprintf(repfil,"\t");
								}
								for (;k<8;k++) fprintf(repfil,"\t");
								fprintf(repfil,"%s\t%c\t%d\t%d\t%s\r",b->flds[l]->name,b->flds[l]->type,b->flds[l]->len,b->flds[l]->ofs,b->flds[l]->desc);
/*								if (l<b->nofld-1) fprintf(repfil,"\t");*/
							}
							for (k=0;k<b->nofld;k++) {
								free(b->flds[k]);
							}
							free(b->flds);
							for (k=0;k<b->nokey;k++) {
								for(j=0;j<b->keys[k]->noparts;j++) {
									free(b->keys[k]->keypts[j]);
								}
								free(b->keys[k]->keypts);
								free(b->keys[k]);
							}
							free(b->keys);
							free(b);
							fprintf(repfil,"\n",27);
						}
						fileno++;
					}
					fclose(repfil);
					noln=0;
					xit=0;
					fileno=1;
					fprintf(stdprn,"%cM",27);
					while (xit<3) {
						b=loadfile(G_cellname,fileno);
						if (b->name[0]==0) {
							free(b);
							xit++;
						}
						else {
							noln++;
							fprintf(stdprn,"%cTaskDefine Data Store Report For Cell %-14s   Page %d\n\n",12,G_cellname,noln);
							fprintf(stdprn,"\nStore Name      Type Number Description\n\n");
							for (k=0;k<strlen(b->name);k++) if ((b->name[k]==13)||(b->name[k]==10)) b->name[k]=32;
							fprintf(stdprn,"%-14s  %c    %-5d  %-40s\n\n\n",b->name,b->type,fileno,b->desc);
							fprintf(stdprn,"        K E Y S         FIELD NAME     TYPE LENGTH OFFSET DESCRIPTION\n");
							for (l=1;l<9;l++) fprintf(stdprn,"%-2d ",l);
							fprintf(stdprn,"\n\n");
							for (l=0;l<b->nofld;l++) {
								for (k=0;k<b->nokey;k++) {
									for (j=0;j<b->keys[k]->noparts;j++) {
										if (b->keys[k]->keypts[j]->fld==l) {
											fprintf(stdprn,"%-2d ",b->keys[k]->keypts[j]->fldordr);
											break;
										}
									}
									if (j==b->keys[k]->noparts) fprintf(stdprn,"   ");
								}
								for (;k<8;k++) fprintf(stdprn,"   ");
								fprintf(stdprn,"%-14s %c    %-5d  %-5d  %-40s\n",b->flds[l]->name,b->flds[l]->type,b->flds[l]->len,b->flds[l]->ofs,b->flds[l]->desc);
							}
							for (k=0;k<b->nofld;k++) {
								free(b->flds[k]);
							}
							free(b->flds);
							for (k=0;k<b->nokey;k++) {
								for(j=0;j<b->keys[k]->noparts;j++) {
									free(b->keys[k]->keypts[j]);
								}
								free(b->keys[k]->keypts);
								free(b->keys[k]);
							}
							free(b->keys);
							free(b);
						}
						fileno++;
					}
					fprintf(stdprn,"%cP",27);
				} break;
				case 1 : {
				} break;
				case 2 : {
				} break;
				case 3 : {
				} break;
				case 4 : {
				} break;
				case 5 : {
				} break;
				case 6 : {
				} break;
			}
		} break;
		default : s=0;
	}
	if (s) {
		mousecur(0);
		clearviewport();
		redraw(1);
		mousecur(1);
	}
}
int colmen(char *bc,char *fc) {
	int i,xit=0;
	char *t;
	struct viewporttype a;

	t=malloc(imagesize(10,10,110,190));
	getviewsettings(&a);
	mousecur(0);
	getimage(10,10,110,190,t);
	setfillstyle(1,0);
	settextjustify(1,2);
	settextstyle(2,0,4);
	setcolor(11);
	bar(10,10,110,190);
	rectangle(10,10,110,190);
	outtxtxy(35,15,bc);
	outtxtxy(85,15,fc);
	setcolor(8);
	for (i=0;i<16;i++) {
		setfillstyle(1,i);
		bar(25,i*10+25,45,i*10+33);
		rectangle(25,i*10+25,45,i*10+33);
		bar(75,i*10+25,95,i*10+33);
		rectangle(75,i*10+25,95,i*10+33);
	}
	setcolor(14);
	rectangle(25,G_lcol*10+24,45,G_lcol*10+34);
	rectangle(75,G_tcol*10+24,95,G_tcol*10+34);
	mousecur(1);
	while (mseb) mousetrap(G_snapto);
	while (!xit) {
		if (mousetrap(1)>>5) {
			if (inbox(25+a.left,25+a.top,45+a.left,183+a.top)) {
				setcolor(0);
				mousecur(0);
				rectangle(25,G_lcol*10+24,45,G_lcol*10+34);
				G_lcol=(msey-a.top-25)/10;
				setcolor(14);
				rectangle(25,G_lcol*10+24,45,G_lcol*10+34);
				mousecur(1);
			}
			if (inbox(75+a.left,25+a.top,95+a.left,183+a.top)) {
				mousecur(0);
				setcolor(0);
				rectangle(75,G_tcol*10+24,95,G_tcol*10+34);
				G_tcol=(msey-a.top-25)/10;
				setcolor(14);
				rectangle(75,G_tcol*10+24,95,G_tcol*10+34);
				mousecur(1);
			}
			if (!(inbox(10+a.left,10+a.top,110+a.left,190+a.top))) xit=1;
		}
	}
	while (mseb) mousetrap(G_snapto);
	mousecur(0);
	putimage(10,10,t,COPY_PUT);
	free(t);
	mousecur(1);
	return((G_lcol<<4)|G_tcol);
}
