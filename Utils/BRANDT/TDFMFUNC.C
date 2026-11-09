#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <stdio.h>
#include "tdef.h"
#include "tdfrm.h"

int  procbox(int lft, int top, int numbox,boxitem **item,char flag);
int  get_string(char *string, int maxlen);
int  bit_on(int number, int position);
int  disp_fmt(void);
int  frm_opt(void);
int  fld_type(char *type);
int  cconv(char *conv);
int  fld_just(char *just);
int  set_attr(char *attr);
int  cmpsf(frmflds *a,frmflds *b);
int  cmpff(field **a,field **b);

void fintitles(int w) {

	switch (inhead(WINX,"File.Edit.Options.Dictionary.Report")) {
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
					print_form(0);
				} break;
				case 6 : {
					print_form(1);
				} break;
			}
		} break;
		case 1 : {
			switch(pulldn(40,0,"Undo.Cut.Copy.Paste.Clear.Insert.Remove.Table.Disband")) {
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
				case 7 : {
					if (!create_table(w)) err_beep();
				} break;
				case 8 : {
					if (!delete_table(w)) err_beep();
				} break;
			}
		} break;
		case 2 : {
			switch(pulldn(90,0,"Field Attr.Table Attr.Link Opt.Validation.List Options.Re-ord Fields.Re-ord Array.Form Opt")) {
				case 0 : {
					if (!fld_attr()) err_beep();
				} break;
				case 1 : {
					if (!tabf_attr()) err_beep();
				} break;
				case 2 : {
					if (!link_opt()) err_beep();
				} break;
				case 3 : {
					if (!val_attr()) err_beep();
				} break;
				case 4 : {
					if (!opt_attr()) err_beep();
				} break;
				case 5 : {
					reordfld();
				} break;
				case 6 : {
					reordoffs();
				} break;
				case 7 : {
					if (!frm_opt()) err_beep();
				} break;
			}
		} break;
		case 3 : {
			switch(pulldn(200,0,"Open.New.Copy.Edit.Close")) {
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
		case 4 : {
			switch(pulldn(270,0,"General.DFD.PSD.IDS.TDS.FORMS.User Rep")) {
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
	}
}

int fld_attr(void) {
	boxitem **itemp;
	int i,noitem=9,fno;
	char valid;

	for (fno=0;fno<G_noflds;fno++) {
		if ((G_fflds[fno].select==1)&&(G_fflds[fno].type!='t'))
			break;
	}
	if (fno>=G_noflds) return(0);
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
		itemp[i]->type='c';
	}
	strcpy(itemp[0]->text,"Field Type");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,2);
	itemp[0]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->fldtype;
	itemp[0]->type='r';
	itemp[0]->runno=1;

	strcpy(itemp[1]->text,"Field Size");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_frm->scrn[G_scrno]->fld[fno]->width;
	itemp[1]->wid=2;
	itemp[1]->type='n';

	strcpy(itemp[2]->text,"Default");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,15))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,15);
	if (G_frm->scrn[G_scrno]->fld[fno]->deflen) {
		strcpy(itemp[2]->valc,G_frm->scrn[G_scrno]->fld[fno]->deftext);
		free(G_frm->scrn[G_scrno]->fld[fno]->deftext);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fno]->deflen;
		G_frm->scrn[G_scrno]->fld[fno]->deflen=0;
	}
	itemp[2]->wid=14;

	strcpy(itemp[3]->text,"Fld Just");
	if ((itemp[3]->valc=realloc(itemp[3]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[3]->valc,0,2);
	itemp[3]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->just;
	itemp[3]->type='r';
	itemp[3]->runno=3;

	strcpy(itemp[4]->text,"Sequence");
	if ((itemp[4]->valc=realloc(itemp[4]->valc,15))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[4]->valc,0,15);
	strcpy(itemp[4]->valc,G_frm->scrn[G_scrno]->fld[fno]->seqname);
	itemp[4]->wid=14;
	itemp[4]->type='r';
	itemp[4]->runno=5;

	strcpy(itemp[5]->text,"Array/Secs");
	if ((itemp[5]->valc=realloc(itemp[5]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[5]->valc,0,6);
	itemp[5]->vali=G_frm->scrn[G_scrno]->fld[fno]->offset;
	itemp[5]->wid=2;
	itemp[5]->type='n';

	strcpy(itemp[7]->text,"Help 2");
	if ((itemp[7]->valc=realloc(itemp[7]->valc,80))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[7]->valc,0,80);
	if (G_frm->scrn[G_scrno]->fld[fno]->nohelp>1) {
		strcpy(itemp[7]->valc,G_frm->scrn[G_scrno]->fld[fno]->eh[1]->help);
		free(G_frm->scrn[G_scrno]->fld[fno]->eh[1]->help);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fno]->eh[1]->helplen;
		free(G_frm->scrn[G_scrno]->fld[fno]->eh[1]);
		G_frm->scrn[G_scrno]->fld[fno]->nohelp--;
		G_cursize-=sizeof(entryhelp);
	}
	itemp[7]->wid=79;

	strcpy(itemp[6]->text,"Help 1");
	if ((itemp[6]->valc=realloc(itemp[6]->valc,80))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[6]->valc,0,80);
	if (G_frm->scrn[G_scrno]->fld[fno]->nohelp) {
		strcpy(itemp[6]->valc,G_frm->scrn[G_scrno]->fld[fno]->eh[0]->help);
		free(G_frm->scrn[G_scrno]->fld[fno]->eh[0]->help);
		G_cursize-=G_frm->scrn[G_scrno]->fld[fno]->eh[0]->helplen;
		free(G_frm->scrn[G_scrno]->fld[fno]->eh[0]);
		G_frm->scrn[G_scrno]->fld[fno]->nohelp=0;
		G_cursize-=sizeof(entryhelp);
	}
	itemp[6]->wid=79;

	strcpy(itemp[8]->text,"Link Opt");
	if ((itemp[8]->valc=realloc(itemp[8]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[8]->valc,0,2);
	itemp[8]->wid=1;
	itemp[8]->type='r';
	itemp[8]->runno=6;

	do {
		valid=1;
		boxover(-50,100,510,noitem,itemp,0);
		if ((itemp[1]->vali<1)
		||  ((80<itemp[1]->vali+strlen(&G_fflds[fno].val[2])+1+G_fflds[fno].xpos)
			&& (G_fflds[fno].type=='s'))
		||  ((strlen(itemp[7]->valc)>0)
			&&  (strlen(itemp[6]->valc)<1))
		||  (itemp[3]->vali > (int)G_offset) ) {
			err_beep();
			valid=0;
		}
	}while (!valid);

	for (i=0;i<G_frm->scrn[G_scrno]->fld[fno]->nolnks;i++) {
		G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->disp_type=itemp[0]->valc[0];
		if (G_fflds[fno].type=='b')
			G_tbltype[G_fflds[fno].ftype][i]=itemp[0]->valc[0];
	}
	G_fflds[fno].ftype=G_frm->scrn[G_scrno]->fld[fno]->fldtype=itemp[0]->valc[0];

	if ((G_frm->scrn[G_scrno]->fld[fno]->width!=itemp[1]->vali)
	&&  (G_fflds[fno].type=='s')) {
		G_frm->scrn[G_scrno]->fld[fno]->width=G_fflds[fno].flen=itemp[1]->vali;
		G_fflds[fno].len=strlen(&G_fflds[fno].val[2])+1+G_fflds[fno].flen;
	}
	if (strlen(itemp[2]->valc))  { /* create default text */
		G_frm->scrn[G_scrno]->fld[fno]->deflen=strlen(itemp[2]->valc)+1;
		if((G_frm->scrn[G_scrno]->fld[fno]->deftext=malloc(G_frm->scrn[G_scrno]->fld[fno]->deflen))
				==(void *)NULL) {
				G_frm->scrn[G_scrno]->fld[fno]->deflen=0;
				free_item(itemp,noitem,2);
				return(0);
		}
		strcpy(G_frm->scrn[G_scrno]->fld[fno]->deftext,itemp[2]->valc);
		G_cursize+=G_frm->scrn[G_scrno]->fld[fno]->deflen;
	}
	G_frm->scrn[G_scrno]->fld[fno]->just=itemp[3]->valc[0];
	strcpy(G_frm->scrn[G_scrno]->fld[fno]->seqname,itemp[4]->valc);
	G_frm->scrn[G_scrno]->fld[fno]->offset=itemp[5]->vali;
	for (i=6;i<8;i++) {
		if (strlen(itemp[i]->valc))  { /* create help lines */
			if ((G_frm->scrn[G_scrno]->fld[fno]->eh=realloc(G_frm->scrn[G_scrno]->fld[fno]->eh,sizeof(entryhelp *)*(i-5)))
					==(void *)NULL) {
				free_item(itemp,noitem,2);
				return(0);
			}
			if ((G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]=malloc(sizeof(entryhelp)))
					==(void *)NULL) {
				free_item(itemp,noitem,2);
				return(0);
			}
			memset(G_frm->scrn[G_scrno]->fld[fno]->eh[i-6],0,sizeof(entryhelp));
			G_cursize+=sizeof(entryhelp);
			G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->hlpno=i-5;
			G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->helplen=strlen(itemp[i]->valc)+1;
			if((G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->help=malloc(G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->helplen))
					==(void *)NULL) {
				free(G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]);
				G_frm->scrn[G_scrno]->fld[fno]->eh=realloc(G_frm->scrn[G_scrno]->fld[fno]->eh,sizeof(entryhelp *)*(i-6)+1);
				free_item(itemp,noitem,2);
				return(0);
			}
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->help,itemp[i]->valc);
			G_cursize+=G_frm->scrn[G_scrno]->fld[fno]->eh[i-6]->helplen;
			G_frm->scrn[G_scrno]->fld[fno]->nohelp++;
		}
	}
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int frm_opt(void) {
	boxitem **itemp;
	int i,noitem=2;
	char valid;

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
	strcpy(itemp[0]->text,"Form Seq");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,6);
	itemp[0]->vali=G_frm->scrn[G_scrno]->scrnseq;
	itemp[0]->wid=2;

	strcpy(itemp[1]->text,"Form ID");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_frm->scrn[G_scrno]->formid;
	itemp[1]->wid=5;
	do {
		valid=1;
		boxover(120, 100, 240, noitem, itemp,0);
		if ((itemp[0]->vali<0)
		||  (itemp[0]->vali>G_frm->noscrn-1)) {
			err_beep();
			valid=0;
		}
	} while (!valid);

	G_frm->scrn[G_scrno]->scrnseq=itemp[0]->vali;
	G_frm->scrn[G_scrno]->formid=itemp[1]->vali;
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int fld_type(char *type) {
	int is,i,noitem=9;
	boxitem **itemp;
	int far *ti;
	struct viewporttype v,far *vp;
	char opttab[10];


	vp=&v;
	mousecur(0);
	is=imagesize(100,150,210,330);
	if (is>30000) {
		setcolor(15);
		outtxtxy(0,0,"error: image size too big");
		return(0);
	}
	else
		if ((ti=malloc(is))==(void *)NULL) return(0);
	getviewsettings(vp);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	getimage(100,150,210,330,ti);

	strcpy(opttab,"DOSCWAMLQ");
	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			free(ti);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			free(ti);
			return(0);
		}
		itemp[i]->wid=1;
		itemp[i]->type='x';
		itemp[i]->x_group=1;
	}
	strcpy(itemp[0]->text,"Display");
	strcpy(itemp[1]->text,"Optional");
	strcpy(itemp[2]->text,"Search");
	strcpy(itemp[3]->text,"sCan");
	strcpy(itemp[4]->text,"Write");
	strcpy(itemp[5]->text,"wAit");
	strcpy(itemp[6]->text,"Mandatory");
	strcpy(itemp[7]->text,"List");
	strcpy(itemp[8]->text,"Password");
	for (i=0; i<noitem; i++){
		if (*type==opttab[i]) itemp[i]->vali=1;
		else                  itemp[i]->vali=0;
	}
	boxover(100, 150, 210, noitem, itemp,1);
	for (i=0;i<noitem;i++)
		if (itemp[i]->vali)
			*type = opttab[i];
	free_item(itemp,noitem,2);
	mousecur(0);
	putimage(100,150,ti,COPY_PUT);
	free(ti);
	setviewport(vp->left,vp->top,vp->right,vp->bottom,vp->clip);
	mousecur(1);
	return(1);
}

int cconv(char *conv) {
	int is,i,noitem=3;
	boxitem **itemp;
	int far *ti;
	struct viewporttype v,far *vp;
	char ctab[4];

	vp=&v;
	mousecur(0);
	is=imagesize(100,150,210,230);
	if (is>30000) {
		setcolor(15);
		outtxtxy(0,0,"error: image size too big");
		return(0);
	}
	else
		if ((ti=malloc(is))==(void *)NULL) return(0);
	getviewsettings(vp);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	getimage(100,150,210,230,ti);

	strcpy(ctab,"ULN");
	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			free(ti);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			free(ti);
			return(0);
		}
		itemp[i]->wid=1;
		itemp[i]->type='x';
		itemp[i]->x_group=1;
	}
	strcpy(itemp[0]->text,"Upper");
	strcpy(itemp[1]->text,"Lower");
	strcpy(itemp[2]->text,"None");
	for (i=0; i<noitem; i++){
		if (*conv==ctab[i]) itemp[i]->vali=1;
		else                itemp[i]->vali=0;
	}
	boxover(100, 150, 210, noitem, itemp,1);
	for (i=0;i<noitem;i++)
		if (itemp[i]->vali)
			*conv = ctab[i];
	free_item(itemp,noitem,2);
	mousecur(0);
	putimage(100,150,ti,COPY_PUT);
	free(ti);
	setviewport(vp->left,vp->top,vp->right,vp->bottom,vp->clip);
	mousecur(1);
	return(1);
}

int fld_just(char *just) {
	int is,i,noitem=4;
	boxitem **itemp;
	int far *ti;
	struct viewporttype v,far *vp;
	char ctab[5];

	vp=&v;
	mousecur(0);
	is=imagesize(100,150,210,250);
	if (is>30000) {
		setcolor(15);
		outtxtxy(0,0,"error: image size too big");
		err_beep();
		return(0);
	}
	else
		if ((ti=malloc(is))==(void *)NULL) return(0);
	getviewsettings(vp);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	getimage(100,150,210,250,ti);

	strcpy(ctab,"LRCN");
	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			free(ti);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			free(ti);
			return(0);
		}
		itemp[i]->wid=1;
		itemp[i]->type='x';
		itemp[i]->x_group=1;
	}
	strcpy(itemp[0]->text,"Left");
	strcpy(itemp[1]->text,"Right");
	strcpy(itemp[2]->text,"Centre");
	strcpy(itemp[3]->text,"None");
	for (i=0; i<noitem; i++){
		if (*just==ctab[i]) itemp[i]->vali=1;
		else                itemp[i]->vali=0;
	}
	boxover(100, 150, 210, noitem, itemp,1);
	for (i=0;i<noitem;i++)
		if (itemp[i]->vali)
			*just = ctab[i];
	free_item(itemp,noitem,2);
	mousecur(0);
	putimage(100,150,ti,COPY_PUT);
	free(ti);
	setviewport(vp->left,vp->top,vp->right,vp->bottom,vp->clip);
	mousecur(1);
	return(1);
}

void reordfld(void) {
	int i;

	qsort(G_fflds,G_noflds,sizeof(frmflds),cmpsf);
	qsort(G_frm->scrn[G_scrno]->fld,G_noflds,sizeof(field *),cmpff);
	for (i=0;i<G_noflds;i++)
		G_frm->scrn[G_scrno]->fld[i]->fldno=i+1;
}

int cmpsf(frmflds *a,frmflds *b) {

	return(((a->ypos - b->ypos)<<8)+(a->xpos - b->xpos));
}

int cmpff(field **a,field **b) {

	return((((*a)->top - (*b)->top)<<8)+((*a)->xpos - (*b)->xpos));
}

void reordoffs(void) {
	int i;

	G_offset=0;
	for (i=0;i<G_noflds;i++)
		if (G_fflds[i].type!='t')
			G_frm->scrn[G_scrno]->fld[i]->offset=G_offset++;
}

int set_attr(char *attr) {
/*	int is,i,noitem=6;
	boxitem **itemp;
	int far *ti;
	struct viewporttype v,far *vp;

	vp=&v;
	mousecur(0);
	is=imagesize(200,200,310,330);
	if (is>30000) {
		setcolor(15);
		outtxtxy(0,0,"error: image size too big");
		return(1);
	}
	else
		if ((ti=malloc(is))==(void *)NULL) return(0);
	getviewsettings(vp);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	getimage(200,200,310,330,ti);

	if ((itemp=malloc(sizeof(boxitem *) * noitem)) ==(void *)NULL) return(0);
	for (i=0; i<noitem; i++) {
		if ((itemp[i]=malloc(sizeof(boxitem)))==(void *)NULL) {
			free_item(itemp,i,0);
			free(ti);
			return(0);
		}
		memset(itemp[i], '\0', sizeof(boxitem));
		if ((itemp[i]->valc=malloc(1))==(void *)NULL) {
			free_item(itemp,i,1);
			free(ti);
			return(0);
		}
		itemp[i]->wid=1;
		itemp[i]->type='x';
		itemp[i]->x_group=1;
	}

	strcpy(itemp[0]->text,"Blink");
	strcpy(itemp[1]->text,"Bright");
	strcpy(itemp[2]->text,"Reverse");
	strcpy(itemp[3]->text,"Mono");
	strcpy(itemp[4]->text,"FG colour");
	strcpy(itemp[5]->text,"BG colour");
	for (i=0; i<4; i++){
		if (bit_on(*attr, (i+1)))  itemp[i]->vali=1;
		else  itemp[i]->vali=0;
	}
	boxover(200, 200, 310, noitem, itemp,1);
	*attr=0;
	for (i=0; i<4; i++) {
		if (itemp[i]->vali)
			*attr += (pow(2.0, (double) i) * itemp[i]->vali );
	}
	free_item(itemp,noitem,2);
	putimage(200,200,ti,COPY_PUT);
	mousecur(1);
	free(ti);
	setviewport(vp->left,vp->top,vp->right,vp->bottom,vp->clip);
	mseb=0;
*/	return(*attr);
}

void free_item(boxitem **item,int noitem,char flag) {
	int i;

	for (i=0; i<noitem-1; i++) {
		free(item[i]->valc);
		free(item[i]);
	}
	if (flag>1) free(item[i]->valc);
	if (flag>0) free(item[i]);
	free(item);
}

bit_on(int number,int position) {
/* this function takes a number and shifts it along to put the byte in
   "position" onto the 1st byte which it then returns .ie it returns a 0
   or 1 depending whether or not that byte is turned on */

    return( ( number >> (position-1) ) & ~( ~0 << 1 ) );
}

int boxover(int lft, int top, int rgt, int numbox,boxitem **item,char flag) {
	int i,j,w,hgt,bot,curx,cury;
	char tmp[2];

	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,0);
	mousecur(0);
	settextjustify(0,2);  /* left,top */
	settextstyle(2,0,4);
	setfillstyle(1,7);
	setcolor(1);
	hgt=textheight("8");
	w=textwidth("8");   /* width of single char */
	bot=top+((numbox+1) * hgt * 2);

	bar(lft,top,rgt,bot);
	rectangle(lft,top,rgt,bot);
	rectangle(lft+2,top+2,rgt-2,bot-2);
	tmp[1]=0;

	for (i=0; i<numbox; i++) {
		curx=lft+w;
		cury=top+(hgt*2*(1+i))-hgt-1;
		outtxtxy(curx,cury,item[i]->text);
		curx+=10*w+6;
		rectangle(curx-3,cury-1,curx+1+(item[i]->wid*w),cury+2+hgt);
		switch(item[i]->type) {
			case 'x': {
				if (item[i]->vali) {
					line(curx-3,cury,curx+1+w,cury+hgt);
					line(curx-3,cury+hgt,curx+1+w,cury);
				}
			} break;
			case 'n': {
				itoa(item[i]->vali,item[i]->valc,10);
				for (j=0;j<strlen(item[i]->valc);j++) {
					tmp[0]=item[i]->valc[j];
					outcxy(curx+j*w,cury-1,tmp[0]);
				}
			} break;
			default : {
				for (j=0;j<strlen(item[i]->valc);j++) {
					tmp[0]=item[i]->valc[j];
					outcxy(curx+j*w,cury-1,tmp[0]);
				}
			} break;
		}
	}
	setcolor(1);
	mousecur(1);
	procbox(lft,top,numbox,item,flag);
	return(0);
}

int procbox(int lft, int top, int numbox,boxitem **item,char flag) {
	int i,j,w,hgt,count,curx,cury;
	char k,xit=0;

	hgt=textheight(item[0]->text);
	w=textwidth("8");   /* width of single char */
	do {
		mousecur(1);
		if (mousetrap(1)) {
			if (mseb==1) {
				while (mousetrap(1)) ;
				for (i=0; i<numbox; i++) {
					curx=lft+6+11*w;
					cury=top+(hgt*2*(1+i))-hgt-1;
					if (inbox(WINX+curx-3,WINY+cury,WINX+curx+(item[i]->wid*w),WINY+cury+hgt)) {
						switch(item[i]->type) {
							case 'c': {
								edtextxy(curx,cury-1,item[i]->valc,item[i]->wid,7,1,w);
								while (mousetrap(1)) ;
							} break;
							case 'n': {
								edtextxy(curx,cury-1,item[i]->valc,item[i]->wid,7,1,w);
								item[i]->vali=atoi(item[i]->valc);
								while (mousetrap(1)) ;
							} break;
							case 'r': {
								switch(item[i]->runno) {
									case 1 : {
										if (item[i]->valc[0]==0)
											item[i]->valc[0]='O';
										if (!fld_type(item[i]->valc)) err_beep();
										bar(curx,cury,curx+w,cury+hgt+1);
										outtxtxy(curx,cury-1,item[i]->valc);
									} break;
									case 2 : {
										if (item[i]->valc[0]==0)
											item[i]->valc[0]='N';
										if (!cconv(item[i]->valc)) err_beep();
										bar(curx,cury,curx+w,cury+hgt+1);
										outtxtxy(curx,cury-1,item[i]->valc);
									} break;
									case 3 : {
										if (item[i]->valc[0]==0)
											item[i]->valc[0]='N';
										if (!fld_just(item[i]->valc)) err_beep();
										bar(curx,cury,curx+w,cury+hgt+1);
										outtxtxy(curx,cury-1,item[i]->valc);
									} break;
									case 4 : {  /* need to initialise null here */
										if (!set_attr(item[i]->valc)) err_beep();
										bar(curx,cury,curx+w,cury+hgt+1);
										outtxtxy(curx,cury-1,item[i]->valc);
									} break;
									case 5 : {  /* sequence */
										count=0;
										while ((((mousestat(1)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
										if (count!=CLICKRATE) {
											if (strlen(item[i]->valc)>0) {
												mousecur(0);
												fldseq(item[i]->valc);
												xit=1;
											}
										}
										else {
											edtextxy(curx,cury-1,item[i]->valc,item[i]->wid,7,1,w);
										}
									} break;
									case 6 : {  /* link opt */
										if (!link_opt()) err_beep();
									} break;
								}
								while (mousetrap(1)) ;
							} break;
							case 'x': {
								mousecur(0);
								if (item[i]->vali) {
									item[i]->vali=0;
									bar(curx-1,cury,curx+w,cury+hgt+1);
								}
								else {
									item[i]->vali=1;
									line(curx-3,cury,curx+1+w,cury+hgt+1);
									line(curx-3,cury+hgt+1,curx+1+w,cury);
									for (j=0;j<numbox;j++) {
										if (!(item[j]->x_group)) continue;
										if ((item[j]->type=='x') && (item[i]->x_group==item[j]->x_group)) {
											if (i != j) {
												item[j]->vali=0;
												curx=lft+5+11*w;
												cury=top+(hgt*2*(1+j))-hgt-1;
												bar(curx-1,cury,curx+w,cury+hgt+1);
											}
										}
									}
								}
								mousecur(1);
								while (mousetrap(1)) ;
								if (flag) { mseb=2; xit=1; }
							} break;
						}
					}
				}
			}
		}
		if (mseb==2) xit=1;
		if (kbhit()) {
			switch(k=getch()) {
			}
		}
	} while ((k!=27)&&(!xit));
	while (mousetrap(1)) ;
	mousecur(1);
	return(0);
}

void err_beep(void) {
	int i;

	sound(1000);
	for (i=0;i<20000;i++) ;
	nosound();
}

int delidsform(int item) {

	G_frm=&G_dsp.ds.f;
	if (!loadform(G_cellname,item)) return(0);
	if (!saveform(G_cellname,&G_dsp,1)) {
		freefrm(G_frm,1);
		return(-1);
	}
	freefrm(G_frm,1);
	return(1);
}

int flfldlen(void) {

	if ((G_curfile<0) || (G_curfield<0)) return(0);
	if (G_file.cont[G_curfile]->flds[G_curfield]->type=='C')
		return(G_file.cont[G_curfile]->flds[G_curfield]->len);
	if (G_file.cont[G_curfile]->flds[G_curfield]->type=='i')
		return(6);
	return(12);
}
