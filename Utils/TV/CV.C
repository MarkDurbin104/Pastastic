#include <stdio.h>
#include <ctype.h>
#include <conio.h>
#include <dir.h>
#include <dos.h>
#include <string.h>
#include <stdlib.h>
/*#include <alloc.h>*/
#include <fcntl.h>
#include <io.h>

int selafile(char *path);

int G_notosel;
char G_filename[100],pl,filespec[100];

main (int argc,char **argv) {
	char sys[200];
	int  r,i;
	if (argc<2) {
		strcpy(filespec,"*.lst");
		pl='1';
	}
	else {
		if (argc<3) {
			if (argv[1][0]=='-') {
				pl=argv[1][1];
				strcpy(filespec,"*.lst");
			}
			else {
				pl='1';
				strcpy(filespec,argv[1]);
			}
		}
		else {
			if (argv[1][0]=='-') {
				pl=argv[1][1];
				strcpy(filespec,argv[2]);
			}
			if (argv[2][0]=='-') {
				pl=argv[2][1];
				strcpy(filespec,argv[1]);
			}
		}
	}
	do {
		r=selafile(filespec);
		if (r==0) {
			textcolor(15);
			textbackground(0);
			clrscr();
			printf("Bad File Specifier %s\n",argv[1]);
		}
		else {
			textcolor(15);
			textbackground(0);
			clrscr();
			for (i=0;i<13;i++) if (G_filename[i]=='.') G_filename[i]=0;
			strcpy(sys,"conv ");
			strcat(sys,G_filename);
			strcat(sys," A1");
			sys[strlen(sys)-1]=pl;
			system(sys);
		}
	}while ((r!=0)&&(G_notosel>1));
	return(1);
}
int selafile(char *path) {
	int i,j,k;
	static int cur=0,st=0;
	char charpos=0;
	char key,findst[13];
	struct ffblk name;
	char names[200][13];
	i=0;
	if ((findfirst(path,&name,FA_RDONLY|FA_HIDDEN))==(-1)) return(0);
	strcpy(names[i++],name.ff_name);
	while ((i<200)&&(!(findnext(&name)))) {
		strcpy(names[i++],name.ff_name);
	}
	G_notosel=i;
	if (G_notosel==1) {
		strcpy(G_filename,names[0]);
		return(1);
	}
	qsort(names,i,13,strcmp);
	textbackground(1);
	clrscr();
	textcolor(14);
	gotoxy(10,1);
	cprintf("Select A File With Letters And Cursor Keys Paper A%c",pl);
	for (j=1;j<80;j++) {
		gotoxy(j,2); cprintf("%c",205);
		gotoxy(j,25); cprintf("%c",205);
	}
	for (j=3;j<25;j++) {
		for (k=0;k<7;k++) {
			gotoxy(1+(k*13),j); cprintf("%c",186);
		}
	}
	for (k=1;k<6;k++) {
		gotoxy(1+(k*13),2); cprintf("%c",203);
		gotoxy(1+(k*13),25); cprintf("%c",202);
	}
	gotoxy(1,2); cprintf("%c",201);
	gotoxy(1,25); cprintf("%c",200);
	gotoxy(79,2); cprintf("%c",187);
	gotoxy(79,25); cprintf("%c",188);
	textcolor(11);
	for (j=0;j<min(i,132);j++) {
		gotoxy(((j/22)*13)+2,(j%22)+3);
		cprintf("%-12s",names[j]);
	}
	do {
		textbackground(4);
		gotoxy((((cur-st)/22)*13)+2,((cur-st)%22)+3);
		cprintf("%-12s",names[cur]);
		key=getch();
		textbackground(1);
		gotoxy((((cur-st)/22)*13)+2,((cur-st)%22)+3);
		cprintf("%-12s",names[cur]);
		switch(key) {
			case 0 : {
				charpos=0;
				key=getch();
				switch(key) {
					case 'P' : {
						if (cur<i-1) {
							cur++;
							if (cur>st+131) {
								st++;
								for (j=st;j<st+132;j++) {
									gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
									cprintf("%-12s",names[j]);
								}
							}
						}
					} break;
					case 'H' : {
						if (cur>0) {
							cur--;
							if (cur<st) {
								st--;
								for (j=st;j<st+132;j++) {
									gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
									cprintf("%-12s",names[j]);
								}
							}
						}
					} break;
					case 'M' : {
						if (cur<(i-21)) cur+=22; else cur=i-1;
						if (cur>st+131) {
							st+=22;
							if (st>i-132) st=i-132;
							for (j=st;j<st+132;j++) {
								gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
								if (j<i) {
									cprintf("%-12s",names[j]);
								}
								else {
								cprintf("            ");
								}
							}
						}
					} break;
					case 'Q' : {
						key=13;
					} break;
					case 'K' : {
						if (cur>21) cur-=22; else cur=0;
						if (cur<st) {
							st-=22;
							if (st<0) st=0;
							for (j=st;j<st+132;j++) {
								gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
								if (j<i) {
									cprintf("%-12s",names[j]);
								}
								else {
									cprintf("            ");
								}
							}
						}
					} break;
				}
			} break;
			case ' ' : {
				pl++;
				if (pl>='5') pl='0';
				textcolor(14);
				gotoxy(10,1);
				cprintf("Select A File With Letters And Cursor Keys Paper A%c",pl);
				textcolor(11);
			} break;
			case 13 : {
			} break;
			case 27 : {
			} break;
			default : {
				if (isalpha(key)) key&=0xDF;
				findst[charpos]=key;
				findst[charpos+1]=0;
				for (j=0;j<i;j++) {
					if (strcmp(names[j],findst)>=0) {
						cur=j;
						charpos++;
						if (charpos>12) charpos=0;
						break;
					}
				}
				if ((cur<st)||(cur>(st+131))) {
					st=(cur-64);
					if (st<0) st=0;
					for (j=st;j<st+132;j++) {
						gotoxy((((j-st)/22)*13)+2,((j-st)%22)+3);
						if (j<i) {
							cprintf("%-12s",names[j]);
						}
						else {
							cprintf("            ");
						}
					}
				}
			}
		}
	} while ((key!=27)&&(key!=13));
	if (key==27) {
		textcolor(15);
		textbackground(0);
		clrscr();
		exit(1);
	}
	strcpy(G_filename,names[cur]);
	return(1);
}
