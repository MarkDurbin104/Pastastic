#include <graphics.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>
#include <conio.h>
#include <math.h>
#include <stdio.h>
#include "tdef.h"
#include "tdfrm.h"

int tabf_attr(void) {
	boxitem **itemp;
	int i,noitem=2,fno;
	char valid;

	for (fno=0;fno<G_noflds;fno++) {
		if ((G_fflds[fno].select==1)&&(G_fflds[fno].type=='b'))
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
	}

	strcpy(itemp[0]->text,"Rows");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,6);
	itemp[0]->vali=G_frm->scrn[G_scrno]->fld[fno]->bottom - G_frm->scrn[G_scrno]->fld[fno]->top;
	itemp[0]->wid=2;
	itemp[0]->type='n';

	strcpy(itemp[1]->text,"Columns");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_frm->scrn[G_scrno]->fld[fno]->nocols;
	itemp[1]->type='n';
	do {
		valid=1;
		boxover(120, 100, 230, noitem, itemp,0);
		if ((itemp[0]->vali<1)
		||  (23<itemp[0]->vali+G_fflds[fno].ypos+2)
		||  (itemp[1]->vali<1)
		||  (80<itemp[1]->vali*(G_fflds[fno].len+1))) {
			err_beep();
			valid=0;
		}
	}while (!valid);

	G_frm->scrn[G_scrno]->fld[fno]->bottom=G_frm->scrn[G_scrno]->fld[fno]->top+itemp[0]->vali;
	G_frm->scrn[G_scrno]->fld[fno]->nocols=itemp[1]->vali;
	if (G_frm->scrn[G_scrno]->fld[fno]->nocols>1) {
		G_fflds[fno].xpos=G_frm->scrn[G_scrno]->fld[fno]->xpos=(80-(itemp[1]->vali*(G_fflds[fno].len+1)))/2;
	}
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int link_opt(void) {
	boxitem **itemp;
	int i,noitem=5,fno,is;
	char valid;
	int far *ti;
	struct viewporttype v,far *vp;

	vp=&v;
	mousecur(0);
	is=imagesize(120,100,230,330);
	if (is>30000) {
		setcolor(15);
		outtxtxy(0,0,"error: image size too big");
		return(0);
	}
	else
		if ((ti=malloc(is))==(void *)NULL) return(0);
	getviewsettings(vp);
	setviewport(WINX,WINY,G_maxx-11,G_maxy-11,1);
	getimage(120,100,230,330,ti);

	if (G_lnkno==(-1)) return(0);
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
		itemp[i]->type='n';
	}
	strcpy(itemp[0]->text,"Link Type");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,2);
	itemp[0]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->disp_type;
	itemp[0]->type='r';
	itemp[0]->runno=1;

	strcpy(itemp[1]->text,"X_displace");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,6);
	itemp[1]->vali=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->x_displace;
	itemp[1]->wid=3;

	strcpy(itemp[2]->text,"Store ID");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,6);
	itemp[2]->vali=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->storeid+1;
	itemp[2]->wid=3;

	strcpy(itemp[3]->text,"Store Fld");
	if ((itemp[3]->valc=realloc(itemp[3]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[3]->valc,0,6);
	itemp[3]->vali=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->st_fldid;
	itemp[3]->wid=3;

	strcpy(itemp[4]->text,"Store Key");
	if ((itemp[4]->valc=realloc(itemp[4]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[4]->valc,0,6);
	itemp[4]->vali=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->st_key;
	itemp[4]->wid=2;

	do {
		valid=1;
		boxover(120, 100, 230, noitem, itemp,0);
	}while (!valid);

	G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->disp_type=itemp[0]->valc[0];
	G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->x_displace=itemp[1]->vali;
	G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->storeid=itemp[2]->vali-1;
	G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->st_fldid=itemp[3]->vali;
	G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->st_key=itemp[4]->vali;

	free_item(itemp,noitem,2);
	mousecur(0);
	putimage(120,100,ti,COPY_PUT);
	free(ti);
	setviewport(vp->left,vp->top,vp->right,vp->bottom,vp->clip);
	mousecur(1);
	return(1);
}

int val_attr(void) {
	boxitem **itemp;
	int i,noitem=9,fno;

	if (G_lnkno==(-1)) return(0);
	for (fno=0;fno<G_noflds;fno++) {
		if (G_fflds[fno].select==1) {
			if (G_fflds[fno].type=='t') return(0);
			break;
		}
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

	strcpy(itemp[0]->text,"Sequence");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,15))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,15);
	itemp[0]->wid=14;
	itemp[0]->type='r';
	itemp[0]->runno=5;

	strcpy(itemp[1]->text,"Field Type");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,2);
	itemp[1]->type='r';
	itemp[1]->runno=1;

	strcpy(itemp[2]->text,"Range Fmt");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,30))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,30);
	itemp[2]->wid=29;

	strcpy(itemp[3]->text,"Val Format");
	if ((itemp[3]->valc=realloc(itemp[3]->valc,30))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[3]->valc,0,30);
	itemp[3]->wid=29;

	strcpy(itemp[4]->text,"Case Conv");
	if ((itemp[4]->valc=realloc(itemp[4]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[4]->valc,0,2);
	itemp[4]->type='r';
	itemp[4]->runno=2;

	strcpy(itemp[5]->text,"Link Just");
	if ((itemp[5]->valc=realloc(itemp[5]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[5]->valc,0,2);
	itemp[5]->type='r';
	itemp[5]->runno=3;

	strcpy(itemp[6]->text,"Scanf Fmt");
	if ((itemp[6]->valc=realloc(itemp[6]->valc,30))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[6]->valc,0,30);
	itemp[6]->wid=29;

	strcpy(itemp[7]->text,"Printf Fmt");
	if ((itemp[7]->valc=realloc(itemp[7]->valc,30))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[7]->valc,0,30);
	itemp[7]->wid=29;

	strcpy(itemp[8]->text,"Error Text");
	if ((itemp[8]->valc=realloc(itemp[8]->valc,80))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[8]->valc,0,80);
	itemp[8]->wid=79;

	if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val_ex) {
		strcpy(itemp[0]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->seqname);
		itemp[1]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->type;
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rflen) {
			strcpy(itemp[2]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rng_fmt);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rng_fmt);
		}
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vflen) {
			strcpy(itemp[3]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vld_fmt);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vld_fmt);
		}
		itemp[4]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vcase;
		itemp[5]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->just;
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->sflen) {
			strcpy(itemp[6]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->scf_fmt);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->scf_fmt);
		}
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->pflen) {
			strcpy(itemp[7]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->prf_fmt);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->prf_fmt);
		}
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errlen) {
			strcpy(itemp[8]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr);
		}
		free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val);
		G_cursize-=sizeof(validation);
		G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val_ex=0;
	}
	boxover(-50, 100, 510, noitem, itemp,0);

	if ((itemp[0]->vali!=0)
	||  (itemp[1]->valc[0]!='O')
	||  (strlen(itemp[2]->valc))
	||  (strlen(itemp[3]->valc))
	||  (itemp[4]->valc[0]!='N')
	||  (itemp[5]->valc[0]!='N')
	||  (strlen(itemp[6]->valc))
	||  (strlen(itemp[7]->valc))
	||  (strlen(itemp[8]->valc)) ) {
		if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val=malloc(sizeof(validation)))
			==(void *)NULL) return(0);
		memset(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val,0,sizeof(validation));
		G_cursize+=sizeof(validation);
		G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val_ex=1;
		strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->seqname,itemp[0]->valc);
		G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->type=itemp[1]->valc[0];
		if (strlen(itemp[2]->valc)) {
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rng_fmt=malloc(strlen(itemp[2]->valc)))
				==(void *)NULL) return(0);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rflen=(strlen(itemp[2]->valc));
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->rng_fmt,itemp[2]->valc);
		}
		if (strlen(itemp[3]->valc)) {
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vld_fmt=malloc(strlen(itemp[3]->valc)))
				==(void *)NULL) return(0);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vflen=(strlen(itemp[3]->valc));
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vld_fmt,itemp[3]->valc);
		}
		G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->vcase=itemp[4]->valc[0];
		G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->just=itemp[5]->valc[0];
		if (strlen(itemp[6]->valc)) {
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->scf_fmt=malloc(strlen(itemp[6]->valc)))
				==(void *)NULL) return(0);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->sflen=(strlen(itemp[6]->valc));
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->scf_fmt,itemp[6]->valc);
		}
		if (strlen(itemp[7]->valc)) {
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->prf_fmt=malloc(strlen(itemp[7]->valc)))
				==(void *)NULL) return(0);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->pflen=(strlen(itemp[7]->valc));
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->prf_fmt,itemp[7]->valc);
		}
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errlen) {
			strcpy(itemp[8]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr);
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr);
		}
		if (strlen(itemp[8]->valc)) {
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr=malloc(strlen(itemp[8]->valc)))
				==(void *)NULL) return(0);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errlen=(strlen(itemp[8]->valc));
			strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->val->errstr,itemp[8]->valc);
		}
	}
	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int create_table(int w) {
	int nofld=0,fno,lsize=0,end,i,j,newfno,nolnk;
	char title[81];
	link newlnk[MAX_LINK];

	if (G_tblno>3) return(0);
	G_tblno++;
	memset(newlnk,0,MAX_LINK*sizeof(link));
	memset(title,0,81);
	reordfld();
	for (fno=0;fno<G_noflds;fno++) {  /* check valid fields selected */
		end=G_fflds[fno].xpos+G_fflds[fno].len;
		if (G_fflds[fno].select==1) {
			if (G_fflds[fno].type!='s') return(0);
			if (nofld>MAX_LINK) return(0);
			if (nofld<1) newfno=fno;
			else         strcat(title,"\n");
			strcat(title,&G_fflds[fno].val[2]);
			newlnk[nofld].fldno=fno;
			newlnk[nofld].len=max(G_fflds[fno].flen,strlen(&G_fflds[fno].val[2]))+1;
			for (i=strlen(&G_fflds[fno].val[2]);i<newlnk[nofld].len-1;i++)
				strcat(title," ");
/*			lsize+=newlnk[nofld].len;*/
			nofld++;
		}   /* check no unselected fields within area */
		else if ( ( ((G_fflds[fno].xpos>=G_clft)&&(G_fflds[fno].xpos<=G_crgt))
				||((end>=G_clft)&&(end<=G_crgt)) )
				&&((G_fflds[fno].ypos>=G_ctop)&&(G_fflds[fno].ypos<=G_cbot)) ) {
			return(0);
		}
	}
	strcat(title," ");
/*	strcat(title,"\r");*/
	if (nofld==0) return(0);
	lsize=strlen(title);
	if (lsize>80) return(0);
	G_clft=(80-lsize)/2;   /* centre tablefld */
	lsize=0;
	for (i=0;i<nofld;i++) { /* allocate displacements */
		newlnk[i].xpos=G_clft+lsize;
		lsize+=newlnk[i].len;
	}
/* check limits of new tablefield */
	if (G_clft+lsize>80) return(0);
	for (fno=0;fno<G_noflds;fno++) {
		if (G_fflds[fno].select==0) {
			if ( (G_fflds[fno].ypos>=G_ctop)
			&& (G_fflds[fno].ypos<=G_ctop+5)
			&& (G_fflds[fno].xpos<=G_clft+lsize)
			&& (G_fflds[fno].xpos+G_fflds[fno].len>=G_clft) )
				return(0);
		}
	}
	G_crgt=G_clft+lsize;
	G_cbot=G_ctop+5;
/* 1st, create the link field */
	nolnk=G_frm->scrn[G_scrno]->fld[newfno]->nolnks;
	if ( (G_frm->scrn[G_scrno]->fld[newfno]->lnk=realloc(G_frm->scrn[G_scrno]->fld[newfno]->lnk,1+sizeof(fldlink *)*nofld))
		==(void *)NULL ) return(0);
	for (i=0;i<nofld;i++) {
		if (nolnk<=i) {
			if ( (G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]=malloc(sizeof(fldlink)))
					==(void *)NULL ) {
				for (j=0;j<i;j++) {
					free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]->op);
					free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]);
					G_cursize-=sizeof(fldlink);
				}
				G_frm->scrn[G_scrno]->fld[newfno]->lnk=realloc(G_frm->scrn[G_scrno]->fld[newfno]->lnk,1+sizeof(fldlink *)*nolnk);
				return(0);
			}
			G_cursize+=sizeof(fldlink);
			memset(G_frm->scrn[G_scrno]->fld[newfno]->lnk[i],0,sizeof(fldlink));
		}
		if (G_frm->scrn[G_scrno]->fld[newlnk[i].fldno]->nolnks) {
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->storeid=G_frm->scrn[G_scrno]->fld[newlnk[i].fldno]->lnk[0]->storeid;
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->st_fldid=G_frm->scrn[G_scrno]->fld[newlnk[i].fldno]->lnk[0]->st_fldid;
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->st_key=G_frm->scrn[G_scrno]->fld[newlnk[i].fldno]->lnk[0]->st_key;
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->disp_type=G_frm->scrn[G_scrno]->fld[newlnk[i].fldno]->lnk[0]->disp_type;
		}
		else {
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->storeid=G_fflds[newlnk[i].fldno].val[0];
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->st_fldid=G_fflds[newlnk[i].fldno].val[1];
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->st_key=1;
			G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->disp_type=G_frm->scrn[G_scrno]->fld[newfno]->fldtype;
		}
		G_tbltype[G_tblno][i]=G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->disp_type;
		G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->lnkno=i;
		G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->x_displace=newlnk[i].xpos-G_clft;
		G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->st_width=G_fflds[newlnk[i].fldno].flen;
		if ( (G_frm->scrn[G_scrno]->fld[newfno]->lnk[i]->op=malloc(1))
				==(void *)NULL ) {
			for (j=0;j<=i;j++) {
				if (j<i)  free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]->op);
				free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]);
				G_cursize-=sizeof(fldlink);
			}
			G_frm->scrn[G_scrno]->fld[newfno]->lnk=realloc(G_frm->scrn[G_scrno]->fld[newfno]->lnk,1+sizeof(fldlink *)*nolnk);
			return(0);
		}
	}
	if ( (G_frm->scrn[G_scrno]->fld[newfno]->text=realloc(G_frm->scrn[G_scrno]->fld[newfno]->text,strlen(title)+1))
				==(void *)NULL ) {
		for (j=0;j<nofld;j++) {
			free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]->op);
			free(G_frm->scrn[G_scrno]->fld[newfno]->lnk[j]);
			G_cursize-=sizeof(fldlink);
		}
		G_frm->scrn[G_scrno]->fld[newfno]->lnk=realloc(G_frm->scrn[G_scrno]->fld[newfno]->lnk,1+sizeof(fldlink *)*nolnk);
		return(0);
	}
	G_cursize-=G_frm->scrn[G_scrno]->fld[newfno]->textlen;
	G_frm->scrn[G_scrno]->fld[newfno]->textlen=strlen(title)+1;
	G_cursize+=G_frm->scrn[G_scrno]->fld[newfno]->textlen;
	memset(G_frm->scrn[G_scrno]->fld[newfno]->text,0,G_frm->scrn[G_scrno]->fld[newfno]->textlen);
	strcpy(G_frm->scrn[G_scrno]->fld[newfno]->text,title);
	strcpy(&G_fflds[newfno].val[2],title);
	G_frm->scrn[G_scrno]->fld[newfno]->nolnks=nofld;
	G_frm->scrn[G_scrno]->fld[newfno]->xpos=G_fflds[newfno].xpos=G_clft;
	G_fflds[newfno].ypos=G_ctop;
	G_frm->scrn[G_scrno]->fld[newfno]->top=G_fflds[newfno].ypos+2;
	G_frm->scrn[G_scrno]->fld[newfno]->bottom=G_cbot;
	G_frm->scrn[G_scrno]->fld[newfno]->width=G_fflds[newfno].len=G_fflds[newfno].flen=lsize;
	G_frm->scrn[G_scrno]->fld[newfno]->nocols=1;
	G_fflds[newfno].type='b';

/* now delete fields that are not required */
	G_fflds[newfno].select=0; /* so this fld is not deleted */
	df(w);
	G_fflds[newfno].select=1;
	reordfld();
	reordoffs();
	return(1);
}

int delete_table(int w) {
	int i,j,nolnks,fno=0,start,end;
	char text[MAX_LINK][40];

	memset(text[0],0,MAX_LINK*40);
	for (i=0;i<G_noflds;i++) {		/* find selected field */
		if (G_fflds[i].select==1) {
			if (G_fflds[i].type!='b') return(0);
			nolnks=G_frm->scrn[G_scrno]->fld[i]->nolnks;
			fno=i;
		}
	}
/*printf("fno %d,nolnks %d,G_noflds %d\n",fno,nolnks,G_noflds);*/
	if (fno==0) return(0);
	if (nolnks>24-G_fflds[fno].ypos) return(0); /* check disbanded fields fit */
	if (G_noflds+nolnks>40) return(0); /* max no of fields on form */
	memset(text[0],0,40);
	strcpy(text[0],strtok(&G_fflds[fno].val[2],"\n"));
	for (i=1;i<nolnks/*-1*/;i++) {
		memset(text[i],0,40);
		strcpy(text[i],strtok((char *)NULL,"\n"));
	}
	start=G_noflds-1;
	for (i=0;i<nolnks;i++) { /* create new fields */
		memset(&G_fflds[G_noflds],0,sizeof(frmflds));
		G_fflds[G_noflds].xpos=G_fflds[fno].xpos;
		G_fflds[G_noflds].ypos=G_fflds[fno].ypos+i+1;
		G_fflds[G_noflds].type='s';
		G_fflds[G_noflds].flen=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->st_width;
		G_fflds[G_noflds].val[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->storeid;
		G_fflds[G_noflds].val[1]=G_frm->scrn[G_scrno]->fld[fno]->lnk[i]->st_fldid;
		strcpy(&G_fflds[G_noflds].val[2],text[i]);
		for (j=strlen(&G_fflds[G_noflds].val[2])-1;G_fflds[G_noflds].val[j+2]==' ';j--) {
			G_fflds[G_noflds].val[j+2]='\0';
		}
		G_fflds[G_noflds].len=G_fflds[G_noflds].flen+strlen(&G_fflds[G_noflds].val[2])+1;
		addfld(G_noflds++);
	}
	for (i=G_fflds[fno].ftype;i<4;i++) {
		memset(&G_tbltype[i][0],0,MAX_LINK+1);
		strcpy(G_tbltype[i],G_tbltype[i+1]);
	}
	memset(&G_tbltype[4][0],0,MAX_LINK+1);
	end=G_noflds-1;
	df(w);	/* delete linked field */
	for (i=start;i<end;i++)
		G_fflds[i].select=1;
	return(1);
}

int opt_attr(void) {
	boxitem **itemp;
	int i,noitem=3,fno,ono=0;
	char exit_opt;

	if (G_lnkno==(-1)) return(0);
	for (fno=0;fno<G_noflds;fno++) {
		if (G_fflds[fno].select==1)
			break;
	}
	if (fno>=G_noflds) return(0);
	if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->disp_type!='L') return(0);
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

	strcpy(itemp[0]->text,"Option No");
	if ((itemp[0]->valc=realloc(itemp[0]->valc,6))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[0]->valc,0,6);
	itemp[0]->wid=2;
	itemp[0]->type='n';

	strcpy(itemp[1]->text,"Mnemonic");
	if ((itemp[1]->valc=realloc(itemp[1]->valc,2))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[1]->valc,0,2);

	strcpy(itemp[2]->text,"Opt Value");
	if ((itemp[2]->valc=realloc(itemp[2]->valc,30))==(void *)NULL) {
		free_item(itemp,noitem,2);
		return(0);
	}
	memset(itemp[2]->valc,0,30);
	itemp[2]->wid=29;

	do {
		exit_opt=0;
		itemp[0]->vali=ono+1;
		if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt>ono) {
			itemp[1]->valc[0]=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->mne;
			if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->textlen)
				strcpy(itemp[2]->valc,G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->text);
		}
		else { /* create option */
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op=
				realloc(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op,1+sizeof(option *)*(ono+1)))
				==(void *)NULL) return(0);
			if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]=malloc(sizeof(option)))
				==(void *)NULL) return(0);
			memset(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono],0,sizeof(option));
			G_cursize+=sizeof(option);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt++;
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->optno=ono+1;
			memset(itemp[1]->valc,0,2);
			memset(itemp[2]->valc,0,30);
		}
		boxover(120, 100, 380, noitem, itemp,0);
		if (itemp[0]->vali==0) exit_opt=1;
		if ((itemp[1]->valc[0]==0)
		&& (itemp[2]->valc[0]==0)
		&& (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt<=ono+1)) {
			if (G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->textlen) {
				free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->text);
				G_cursize-=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->textlen;
			}
			free(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]);
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op=
				realloc(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op,1+sizeof(option *)*(ono));
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt--;
			G_cursize-=sizeof(option);
		}
		else {
			G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->mne=itemp[1]->valc[0];
			if (strlen(itemp[2]->valc)) {
				if ((G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->text=malloc(strlen(itemp[2]->valc)))
					==(void *)NULL) return(0);
				G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->textlen=strlen(itemp[2]->valc);
				G_cursize+=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->textlen;
				strcpy(G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->op[ono]->text,itemp[2]->valc);
			}
		}
		if (itemp[0]->vali > G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt+1) { /* up only to last option */
			ono=G_frm->scrn[G_scrno]->fld[fno]->lnk[G_lnkno]->numopt;
			err_beep();
			continue;
		}
		else
			ono=itemp[0]->vali-1;
	}while (!exit_opt);

	free_item(itemp,noitem,2);
	mousecur(1);
	return(1);
}

int redrawtbl(int fldno) { /* resize table string & table size on screen */
	int i,j,nolnks;
	char tmp[80],title[90],text[MAX_LINK][40];

	nolnks=G_frm->scrn[G_scrno]->fld[fldno]->nolnks;
	memset(text[0],0,40);
	strcpy(tmp,&G_fflds[fldno].val[2]);
	strcpy(text[0],strtok(tmp,"\n"));
	for (i=1;i<nolnks;i++) {
		memset(text[i],0,40);
		strcpy(text[i],strtok((char *)NULL,"\n"));
	}
	memset(title,0,90);
	for (i=0;i<nolnks;i++) {
		if (i) {
			G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->x_displace=strlen(title)+1;
			strcat(title,"\n");
		}
		strcat(title,text[i]);
		for (j=strlen(text[i]);j<G_frm->scrn[G_scrno]->fld[fldno]->lnk[i]->st_width;j++)
			strcat(title," ");
		G_fflds[fldno].flen=strlen(title);
		if (strlen(title)>80) return(0);
	}
/*	strcat(title," ");*/
	if ( (G_frm->scrn[G_scrno]->fld[fldno]->text=realloc(G_frm->scrn[G_scrno]->fld[fldno]->text,strlen(title)+1))
				==(void *)NULL ) {
		return(0);
	}
	G_cursize-=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
	G_frm->scrn[G_scrno]->fld[fldno]->textlen=strlen(title)+1;
	G_cursize+=G_frm->scrn[G_scrno]->fld[fldno]->textlen;
	memset(G_frm->scrn[G_scrno]->fld[fldno]->text,0,G_frm->scrn[G_scrno]->fld[fldno]->textlen);
	strcpy(G_frm->scrn[G_scrno]->fld[fldno]->text,title);
	strcpy(&G_fflds[fldno].val[2],title);
	return(1);
}
