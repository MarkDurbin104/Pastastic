#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include "tdef.h"
#include "tdfrm.h"

extern FILE *printer;

int  menu_opt(void);
int  print_menu(int det_flag);

void mintitles(int scrnfld) {

	switch (inhead(WINX,"File.Edit.Options")) {
		case 0 : {
			switch(pulldn(0,0,"Open.Close.New.Save.Save As.Print.Print Det")) {
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
					print_menu(0);
				} break;
				case 6 : {
					print_menu(1);
				} break;
			}
		} break;
		case 1 : {
			switch(pulldn(40,0,"Undo.Cut.Copy.Paste.Clear.Insert.Remove")) {
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
				case 6 : {
				} break;
			}
		} break;
		case 2 : {
			switch(pulldn(90,0,"Field Attr.Menu Line Opt.Menu Options")) {
				case 0 : {
/*					if (!fld_attr()) err_beep();*/
				} break;
				case 1 : {
					if (!ml_opt(scrnfld)) err_beep();
				} break;
				case 2 : {
					if (!menu_opt()) err_beep();
				} break;
			}
		} break;
	}
}

int ml_opt(int scrnfld) {
	boxitem **itemp;
	int i,noitem=5,mline;
	char valid;

	if (scrnfld==(-1)) return(0);
	mline=scrnfld-G_nohdr;
	if (mline < 0) return(0);
	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			return(0);
		}
		itemp[i]->type='n';
	}
	strcpy(itemp[0]->text,"Attr");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,6);
	itemp[0]->vali=G_mnu->ml[mline]->ml_attr;
	itemp[0]->wid=2;

	strcpy(itemp[1]->text,"Access");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_mnu->ml[mline]->access;
	itemp[1]->wid=5;

	strcpy(itemp[2]->text,"Chain To");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,6);
	itemp[2]->vali=G_mnu->ml[mline]->chain_to;
	itemp[2]->wid=5;

	strcpy(itemp[3]->text,"Prompt");
	if ((itemp[3]->valc=realloc(itemp[3]->valc,80))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[3]->valc,0,80);
	if (G_mnu->ml[mline]->promptlen) {
		strcpy(itemp[3]->valc,G_mnu->ml[mline]->prompt);
		free(G_mnu->ml[mline]->prompt);
		G_cursize-=G_mnu->ml[mline]->promptlen;
		G_mnu->ml[mline]->promptlen=0;
	}
	itemp[3]->wid=79;
	itemp[3]->type='c';

	strcpy(itemp[4]->text,"Help");
	if ((itemp[4]->valc=realloc(itemp[4]->valc,80))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[4]->valc,0,80);
	if (G_mnu->ml[mline]->helplen) {
		strcpy(itemp[4]->valc,G_mnu->ml[mline]->help);
		free(G_mnu->ml[mline]->help);
		G_cursize-=G_mnu->ml[mline]->helplen;
		G_mnu->ml[mline]->helplen=0;
	}
	itemp[4]->wid=79;
	itemp[4]->type='c';
	do {
		valid=1;
		boxover(-50,100,510,noitem,itemp,0);
/*		if (strlen(itemp[4]->valc)<1) {
			err_beep();
			valid=0;
		}*/
	}while (!valid);

	G_mnu->ml[mline]->access=itemp[1]->vali;
	G_mnu->ml[mline]->chain_to=itemp[2]->vali;
	if (strlen(itemp[3]->valc))  { /* create prompt line */
		G_mnu->ml[mline]->promptlen=strlen(itemp[3]->valc)+1;
		if ((G_mnu->ml[mline]->prompt=malloc(G_mnu->ml[mline]->promptlen))
					==(void *)NULL) {
			G_mnu->ml[mline]->promptlen=0;
			free_item(itemp,noitem,2);
			return(0);
		}
		memset(G_mnu->ml[mline]->prompt,0,G_mnu->ml[mline]->promptlen);
		G_cursize+=G_mnu->ml[mline]->promptlen;
		strcpy(G_mnu->ml[mline]->prompt,itemp[3]->valc);
	}
	if (strlen(itemp[4]->valc))  { /* create help line */
		G_mnu->ml[mline]->helplen=strlen(itemp[4]->valc)+1;
		if ((G_mnu->ml[mline]->help=malloc(G_mnu->ml[mline]->helplen))
					==(void *)NULL) {
			G_mnu->ml[mline]->helplen=0;
			free_item(itemp,noitem,2);
			return(0);
		}
		memset(G_mnu->ml[mline]->help,0,G_mnu->ml[mline]->helplen);
		G_cursize+=G_mnu->ml[mline]->helplen;
		strcpy(G_mnu->ml[mline]->help,itemp[4]->valc);
	}
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int menu_opt(void) {
	boxitem **itemp;
	int i,noitem=3;

	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			return(0);
		}
		itemp[i]->wid=1;
		itemp[i]->type='n';
	}
	strcpy(itemp[0]->text,"Display No");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,6);
	itemp[0]->vali=G_dsp.dispno;
	itemp[0]->wid=5;

	strcpy(itemp[1]->text,"Back Attr");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_dsp.bg_attr;
	itemp[1]->wid=5;

	strcpy(itemp[2]->text,"Menu Name");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,20))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,20);
	itemp[2]->type='c';
	itemp[2]->wid=19;
	boxover(120, 100, 320, noitem, itemp,0);
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int edtextxy(int x,int y,char *ln,int nochrs,int bcol,int col,int w) {
	char tmp[81],tmp1[2];
	int hgt,i,cpos,maxlen;
	char k,xit=0,modifyed=0;

	memset(tmp,'\0',81);
	tmp[nochrs]=0;
	hgt=textheight("8");
	setfillstyle(1,bcol);
	setcolor(col);
	strcpy(tmp,ln);
	maxlen=strlen(ln);
	if (tmp[0]==0) {
		i=0;
	}
	else
		i=strlen(tmp);
	tmp1[1]=0;
	for (i=0;i<strlen(tmp);i++) {
		tmp1[0]=tmp[i];
		outtxtxy(x+i*w,y,tmp1);
	}
	while (mousetrap(1)) ;
	mousecur(0);
	do {
		maxlen=max(maxlen,strlen(ln));
		cpos=x+i*w;
		setcolor(bcol+7);
		line(cpos,y+1,cpos,y+hgt+1);
		while ((!kbhit())&&(!xit)) {
			if (mousetrap(G_snapto)) {
				if (mseb==1) {
					if (!inbox(x-1,WINY+y+2,cpos+1,WINY+y+hgt+2))
						xit=1;
				}
			}
		}
		setcolor(bcol);
		line(cpos,y+1,cpos,y+hgt+1);
		setcolor(col);
		if (!xit) {
			switch (k=getch()) {
				case 8 : { /* backspace */
					if (i>0) {
						if (i<nochrs) bar(x+(i-1)*w-1,y+1,x+(i)*w,y+hgt+2);
						tmp[--i]=0;
					}
					modifyed=1;
				} break;
				case 10 :  /* line feed or carriage return */
				case 13 : {
					xit=2;
				} break;
				case 0 : {
					switch (k=getch()) {
						case 'S' : { /* delete key */
							xit=4;
						} break;
					}
				} break;
				case 27 : {  /* Esc */
					strcpy(tmp,ln);
					xit=3;
				} break;
				default : {
					if ((!(modifyed))&&(k!=' ')) {
						bar(x-2,y+1,x+nochrs*w-w/2,y+hgt+2);
						memset(tmp,0,81);
						i=0;
					}
					if (i<nochrs) {
						tmp[i]=k;
						tmp1[0]=tmp[i];
						outtxtxy(x+i*w,y,tmp1);
						tmp[++i]=0;
/*						maxlen++;*/
					}
					else {
						err_beep();
						xit=1;
					}
					modifyed=1;
				}
			}
		}
	} while (!(xit));
	if (maxlen>0) bar(x-2,y+1,x+(maxlen-1)*w,y+hgt+2);
/*	bar(x-2,y+1,x+maxlen*w+2,y+hgt+2);*/
	if (xit<3)
		for (i=0;i<strlen(tmp);i++) {
			tmp1[0]=tmp[i];
			outtxtxy(x+i*w,y,tmp1);
		}
	mousecur(1);
	strcpy(ln,tmp);
	return(xit);
}

int print_menu(int det_flag) {
/* this function prints the current menu */

	int  i,j,k;
	char txt[80],found;

/* print title block */
	fprintf(printer,"Cellname : %s\n",G_cellname);
	fprintf(printer,"Menu     : %d \n\n",G_dsp.dispno);

/* print top border */
    fprintf(printer,"%c!%c",27,1);
    fprintf(printer,"%c",201);
    for ( i = 0; i < 80; i++ )
        fprintf(printer,"%c", 205);
	fprintf(printer,"%c\n", 187);

/* print screen lines */
	for (i=0; i<25; i++) {
/*        fprintf(printer,"%c",186); left side */
        fprintf(printer," ");
		if ((i==0)      /* 1st header line */
		&&  (G_mnu->nummh>0)) {
			for ( j = 0; j < G_mnu->mh[0]->xpos; j++ )
				fprintf(printer," ");
			if (G_mnu->mh[0]->textlen)
				fprintf(printer,"%s",G_mnu->mh[0]->text);
			j+=G_mnu->mh[0]->textlen;
/*            for (; j < 80; j++ )
                 fprintf(printer," ");
              fprintf(printer,"%c\n",186); right side */
            continue;
        }
		if ((i==1)         /* 2nd header line */
		&&  (G_mnu->nummh>1)) {
			for (j=0; j<G_mnu->mh[1]->xpos; j++ )
                fprintf(printer," ");
			if (G_mnu->mh[1]->textlen)
				fprintf(printer,"%s",G_mnu->mh[1]->text);
			j+=G_mnu->mh[1]->textlen;
/*			for ( ;j < 80; j++ )
                fprintf(printer," ");
			fprintf(printer,"%c\n",186); right side */
            continue;
        }
/* check for menu lines */
		found=0;
		for (k=0; k<G_mnu->numml; k++)
			if (G_mnu->ml[k]->ypos==i) {
				found=1;
                break;
            }
		if (found) {
			for (j=0; j<15; j++)
                fprintf(printer," ");
			fprintf(printer,"%c",G_mnu->ml[k]->mne);
            j++;
			for (; j<20; j++ )
				fprintf(printer," ");
			if (G_mnu->ml[k]->textlen)
				fprintf(printer,"%s",G_mnu->ml[k]->text);
			j+=G_mnu->ml[k]->textlen;
/*			for (; j<80; j++)
				fprintf(printer," ");*/
        }
		else {
			for (j=0;j<80;j++) {
				if (i==19)
					fprintf(printer,"_");
/*				else
					fprintf(printer," ");*/
			}
/*       	 fprintf(printer,"%c\n",186); right side */
		}
		fprintf(printer,"\n");
    }
/* print bottom border and reset printer to 160 width */
    fprintf(printer,"%c",200);
	for (i=0; i<80; i++)
        fprintf(printer,"%c", 205);
    fprintf(printer,"%c\n%c!%c",188,27,5);

	if (det_flag)
    {
/* print menu information */
        fprintf(printer,"\nMenu Information :\n\n");
		fprintf(printer,"Attributes : %3d, No of Lines : %2d\n\n",G_dsp.bg_attr, G_mnu->numml);
        fprintf(printer,"Lineno  Access  Run Sequence  Attribute  Text \n\n");

/* print menu line details */
		for (i=0;i<G_mnu->numml;i++) {
			fprintf(printer,"  %2d  %5d      %5d",G_mnu->ml[i]->ml_line, G_mnu->ml[i]->access, G_mnu->ml[i]->chain_to);
			if (G_mnu->ml[i]->textlen)
				strcpy(txt,G_mnu->ml[i]->text);
			else
				memset(txt,0,80);
			fprintf(printer,"          %3d      %-79s \n",G_mnu->ml[i]->ml_attr,txt);
        }
	}
/* reset printer attr and page throw */
    fprintf(printer,"%c!%c",27,0);
	fprintf(printer,"%c", 12);
	return(1);
}

int print_form(int det_flag) {
/* this function will print the current form */

	int  xdiff,ydiff,i,j,lno/*,displace*/,x,y,pline;
	char txt[80],found;

	xdiff = 80;
	ydiff = 24;

/* print title block */
	fprintf(printer,"Cellname : %s\n",G_cellname);
	fprintf(printer,"Form     : %6d\n",G_frm->scrn[G_scrno]->formid);
	fprintf(printer,"Display  : %6d\n\n",G_dsp.dispno);
    pline = 4;

/* print top border */
    if ( xdiff < 94 )
        fprintf(printer,"%c!%c",27,1);
    else
        if ( xdiff < 132 )
            fprintf(printer,"%c!%c",27,4);
        else
            fprintf(printer,"%c!%c",27,5);
    fprintf(printer,"%c",201);
    for ( i = 0; i < xdiff; i++ )
        fprintf(printer,"%c", 205);
    fprintf(printer,"%c\n", 187);
    pline++;

/* print screen lines */
	for (y=0; y<ydiff; y++,pline++) {
/*		fprintf(printer,"%c",186); left side */
		fprintf(printer," ");
/* check for flds */
		for(x=0;x<xdiff;x++) {
			found=0;
			for (i=0; i<G_frm->scrn[G_scrno]->nofld; i++) {
				if ((G_frm->scrn[G_scrno]->fld[i]->top<=y)
				&&  (G_frm->scrn[G_scrno]->fld[i]->bottom>=y)
				&&  (G_frm->scrn[G_scrno]->fld[i]->xpos==x)) {
					found=1;
					break;
				}
				if ((G_frm->scrn[G_scrno]->fld[i]->top-1==y) /* table fld text */
				&&  (G_frm->scrn[G_scrno]->fld[i]->bottom-1>y)
				&&  (G_frm->scrn[G_scrno]->fld[i]->xpos==x)) {
					found=2;
					break;
				}
			}
			if (found) {
				if (G_frm->scrn[G_scrno]->fld[i]->top==G_frm->scrn[G_scrno]->fld[i]->bottom) {
					if (G_frm->scrn[G_scrno]->fld[i]->fldtype=='T') { /* text fld */
						if (G_frm->scrn[G_scrno]->fld[i]->textlen) {
							stcpy(txt,G_frm->scrn[G_scrno]->fld[i]->text);
							fprintf(printer,"%s",txt);
							x+=G_frm->scrn[G_scrno]->fld[i]->textlen-1;
						}
						else fprintf(printer," ");
					}
					else { /* single fld with text */
						if (G_frm->scrn[G_scrno]->fld[i]->textlen) {
							stcpy(txt,G_frm->scrn[G_scrno]->fld[i]->text);
							fprintf(printer,"%s",txt);
							x+=G_frm->scrn[G_scrno]->fld[i]->textlen-1;
						}
						fprintf(printer," ");
						x++;
						if (G_frm->scrn[G_scrno]->fld[i]->width) {
							for (j=0;j<G_frm->scrn[G_scrno]->fld[i]->width;j++,x++)
								fprintf(printer,"X");
						}
					}
				}
				else { /* table fld */
					if (found==2) { /* text for table fld */
						if (G_frm->scrn[G_scrno]->fld[i]->textlen) {
							stcpy(txt,G_frm->scrn[G_scrno]->fld[i]->text);
							fprintf(printer,"%s",txt);
							x+=G_frm->scrn[G_scrno]->fld[i]->textlen-1;
						}
					}
					else { /* body of table fld */
/*						displace=0;*/
						for (lno=0;lno<G_frm->scrn[G_scrno]->fld[i]->nolnks;lno++) {
							while (x < G_frm->scrn[G_scrno]->fld[i]->xpos+
									G_frm->scrn[G_scrno]->fld[i]->lnk[lno]->x_displace) {
								fprintf(printer," ");
								x++;
							}
							while (x < G_frm->scrn[G_scrno]->fld[i]->xpos+
									G_frm->scrn[G_scrno]->fld[i]->lnk[lno]->x_displace+
									G_frm->scrn[G_scrno]->fld[i]->lnk[lno]->st_width) {
								fprintf(printer,"X");
								x++;
							}
						}
					}
				}
			}
			else {
				fprintf(printer," ");
			}
		}
/*		fprintf(printer,"%c\n",186); right side */
		fprintf(printer,"\n");
    }
/* print bottom border and reset printer to 160 char per line */
    fprintf(printer,"%c",200);
    for ( i = 0; i < xdiff; i++ )
        fprintf(printer,"%c", 205);
    fprintf(printer,"%c\n\n%c!%c",188,27,5);
    pline += 2;

	if ( !det_flag )
    {
        fprintf(printer,"%c!%c %c", 27, 0, 12);
		return(1);
    }

/* print form and field information */
	fprintf(printer,"Form Attributes - %d\n\n",G_dsp.bg_attr);
    fprintf(printer,"Fld Typ Xpos Ytop Ybot Size Just Attr Seq Offs ");
    fprintf(printer,"Link Col Default         Text \n");
    pline += 3;
	for (i=0;i<G_frm->scrn[G_scrno]->nofld;i++) {
		if (pline>60) {
            fprintf(printer,"%c",12);   /* page throw */
/*			fprintf(printer,"Page No : %d\n",G_pageno++);*/
            fprintf(printer,"Fld Typ Xpos Ytop Ybot Size Just Attr Seq Offs ");
            fprintf(printer,"Link Col Default         Text \n");
			pline=3;
        }
		fprintf(printer,"\n %2d  %c  %3d  ",i+1, G_frm->scrn[G_scrno]->fld[i]->fldtype,G_frm->scrn[G_scrno]->fld[i]->xpos);
		fprintf(printer,"%3d  %3d  %3d   ",G_frm->scrn[G_scrno]->fld[i]->top,G_frm->scrn[G_scrno]->fld[i]->bottom,G_frm->scrn[G_scrno]->fld[i]->width);
		fprintf(printer,"%c   %3d       ",G_frm->scrn[G_scrno]->fld[i]->just,G_frm->scrn[G_scrno]->fld[i]->attr/*,G_frm->scrn[G_scrno]->fld[i]->seqname*/);
		fprintf(printer,"%2d   %2d  ",G_frm->scrn[G_scrno]->fld[i]->offset,G_frm->scrn[G_scrno]->fld[i]->nolnks);
		if (G_frm->scrn[G_scrno]->fld[i]->deflen)
			stcpy(txt,G_frm->scrn[G_scrno]->fld[i]->deftext);
		else
			memset(txt,0,80);
		fprintf(printer,"%2d  %-14s  ",G_frm->scrn[G_scrno]->fld[i]->nocols,txt);
        pline++;
		if (G_frm->scrn[G_scrno]->fld[i]->textlen) {
			stcpy(txt,G_frm->scrn[G_scrno]->fld[i]->text);
			fprintf(printer,"%-79s",txt);
		}
		else
			memset(txt,0,80);
		for (j=0;j<G_frm->scrn[G_scrno]->fld[i]->nolnks;j++) { /* each link */
			fprintf(printer,"\n                                                                        ");
			pline++;
			fprintf(printer,"Linkno. : %2d, Type : %c, ",j+1,G_frm->scrn[G_scrno]->fld[i]->lnk[j]->disp_type);
			fprintf(printer,"Storeid : %2d, Store Field : %3d, ",G_frm->scrn[G_scrno]->fld[i]->lnk[j]->storeid,G_frm->scrn[G_scrno]->fld[i]->lnk[j]->st_fldid);
			fprintf(printer,"Key : %2d, Displacement : %3d",G_frm->scrn[G_scrno]->fld[i]->lnk[j]->st_key,G_frm->scrn[G_scrno]->fld[i]->lnk[j]->x_displace);
			if (pline>60) {
				fprintf(printer,"%c",12);   /* page throw */
/*				fprintf(printer,"Page No : %d\n",G_pageno++);*/
				fprintf(printer,"Fld Typ Xpos Ytop Ybot Size Just Attr Seq Offs ");
				fprintf(printer,"Link Col Default         Text \n");
				fprintf(printer,"\nField No. : %3d (cont)\n\n", (i+1));
				pline = 6;
			}
		}
	}
/* reset printer to normal print and page feed */
	fprintf(printer,"%c!%c %c", 27, 0, 12);
	return(1);
}

int swapfflds(int f1, int f2) {
/* this function checks the form file and swaps store field nos as required */
	char filenam[20],tempnam[20],*t;
	int i,j,k,fdf,tfd;

	sprintf(filenam,"%s%s",G_cellname,FORM_EXT);
	if ((fdf=open(filenam,O_RDONLY|O_BINARY))<0) {
		fprintf(printer,"tdr - return errno is %s\n",sys_errlist[errno]);
		err_beep();
		return(0);
	}
	strcpy(tempnam,".\\");  /* create temporary file and reopen for write only */
	if ((tfd=creattemp(tempnam,0))==(-1)) {
		close(fdf);
		return(-1);
	}
	close(tfd);
	tfd=open(tempnam,O_WRONLY|O_BINARY);

	lseek(fdf,0,SEEK_SET);
	while (readnxtfrm(fdf)>0) {
		for (i=0;i<G_frm->noscrn;i++) {
			for (j=0;j<G_frm->scrn[i]->nofld;j++) {
				for (k=0;k<G_frm->scrn[i]->fld[j]->nolnks;k++) {
					if (G_storeid==G_frm->scrn[i]->fld[j]->lnk[k]->storeid) {
						if (G_frm->scrn[i]->fld[j]->lnk[k]->st_fldid==f1) {
							G_frm->scrn[i]->fld[j]->lnk[k]->st_fldid=f2;
						}
						else if (G_frm->scrn[i]->fld[j]->lnk[k]->st_fldid==f2) {
							G_frm->scrn[i]->fld[j]->lnk[k]->st_fldid=f1;
						}
					}
				}
			}
		}
		if (!writefrm(&G_dsp,tfd,0,0)) { /* otherwise write original rec to temp file */
			freefrm(G_frm,0); /* if write error free all space */
			close(fdf);    /* and close files */
			close(tfd);
			unlink(tempnam);
			return(0);
		}
		freefrm(G_frm,0);
	}
	t=malloc(4096); /* block size for block read */
	close(fdf);
	close(tfd);
	unlink(filenam);
	if ((tfd=open(tempnam,O_RDONLY|O_BINARY))==(-1)) return(0);
	if ((fdf=open(filenam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
	while(write(fdf,t,read(tfd,t,4096)));
	close(fdf);
	close(tfd);
	unlink(tempnam); /* deletes temporary file */
	free(t);
	return(1);
}
