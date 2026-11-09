#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include "tdef.h"
#include "tdfrm.h"
#include "tdconv.h"

int conv(char *fil);
int readnxtmnu(int fd);
int copy_dsp(int fdd);
int copy_mhd(int fdh);
int copy_mln(int fdl);
int copy_ftp(int fdt,int fdp,int fdn,int fde,int fdo,int fdv);
int copy_det(int sno,int fdp,int fdn,int fde,int fdo,int fdv);
int copy_fldtxt(int sno,int fno,int fldno,int fdp);
int copy_lnk(int sno,int fno,int fldno,int fdn,int fdo,int fdv);
int copy_val(int sno,int fno,int fldno,int lno,int fdv);
int copy_opt(int sno,int fno,int fldno,int lno,int fdo);
int copy_ehp(int sno,int fno,int fldno,int fde);

int conv(char *fil) {
/* this function controls the copying of files from taskdefine to taskform
format */
	int fdm,fdf,fdd,fdh,fdl,fdt,fdp,fdn,fde,fdo,fdv;
	char filem[20],filef[20],filed[20],fileh[20],filel[20],filet[20];
	char filep[20],filen[20],filee[20],fileo[20],filev[20];

	sprintf(filem,"%s%s",fil,MENU_EXT);
	if ((fdm=open(filem,O_RDONLY|O_BINARY))<0) { err_beep(); return(0); }
	sprintf(filed,"%s.dsp",fil);
	if ((fdd=open(filed,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"dsp - return errno is %s\n",sys_errlist[errno]);
		err_beep();
		close(fdm);
		return(0);
	}
	sprintf(fileh,"%s.mhd",fil);
	if ((fdh=open(fileh,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"mhd - return errno is %s\n",sys_errlist[errno]);
		err_beep();
		close(fdd);
		close(fdm);
		return(0);
	}
	sprintf(filel,"%s.mln",fil);
	if ((fdl=open(filel,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"mln - return errno is %s\n",sys_errlist[errno]);
		err_beep();
		close(fdh);
		close(fdd);
		close(fdm);
		return(0);
	}
	lseek(fdm,0,SEEK_SET);
	while (readnxtmnu(fdm)>0) {
		if (!copy_dsp(fdd)) {
			err_beep();
			close(fdh);
			close(fdl);
			close(fdm);
			close(fdd);
			return(0);
		}
		if (!copy_mhd(fdh)) {
			err_beep();
			close(fdh);
			close(fdl);
			close(fdm);
			close(fdd);
			return(0);
		}
		if (!copy_mln(fdl)) {
			err_beep();
			close(fdh);
			close(fdl);
			close(fdm);
			close(fdd);
			return(0);
		}
		freemnu(G_mnu,0);
	}
	close(fdh);
	close(fdl);
	close(fdm);

	sprintf(filef,"%s%s",fil,FORM_EXT);
	if ((fdf=open(filef,O_RDONLY|O_BINARY))<0) {
		fprintf(printer,"tdr - return errno is %s\n",sys_errlist[errno]);
		close(fdd);
		return(0);
	}
	sprintf(filet,"%s.ftp",fil);
	if ((fdt=open(filet,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"ftp - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}
	sprintf(filep,"%s.det",fil);
	if ((fdp=open(filep,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"det - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}
	sprintf(filen,"%s.lnk",fil);
	if ((fdn=open(filen,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"lnk - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}
	sprintf(filee,"%s.ehp",fil);
	if ((fde=open(filee,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"ehp - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}
	sprintf(fileo,"%s.opt",fil);
	if ((fdo=open(fileo,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"opt - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}
	sprintf(filev,"%s.val",fil);
	if ((fdv=open(filev,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))<0) {
		fprintf(printer,"val - return errno is %s\n",sys_errlist[errno]);
		return(0);
	}

	lseek(fdf,0,SEEK_SET);
	while (readnxtfrm(fdf)>0) {
		if (!copy_dsp(fdd)) {
			err_beep();
			close(fdd);
			close(fdt);
			close(fdp);
			close(fdn);
			close(fde);
			close(fdo);
			close(fdv);
			close(fdf);
			return(0);
		}
		if (!copy_ftp(fdt,fdp,fdn,fde,fdo,fdv)) {
			err_beep();
			close(fdd);
			close(fdt);
			close(fdp);
			close(fdn);
			close(fde);
			close(fdo);
			close(fdv);
			close(fdf);
			return(0);
		}
		freefrm(G_frm,0);
	}
	close(fdd);
	close(fdt);
	close(fdp);
	close(fdn);
	close(fde);
	close(fdo);
	close(fdv);
	close(fdf);
	return(1);
}

int readnxtmnu(int fd) {
	int i;

	G_mnu=&G_dsp.ds.m;
	if (read(fd,&G_dsp,sizeof(display))>0) {
		if ((G_mnu->mh=malloc(1+sizeof(menuhdr *)*(G_mnu->nummh)))
				==(void *)NULL) return(-1);
		for (i=0;i<G_mnu->nummh;i++) {
			if ((G_mnu->mh[i]=malloc(sizeof(menuhdr)))
					==(void *)NULL) return(-1);
			read(fd,G_mnu->mh[i],sizeof(menuhdr));
			if (G_mnu->mh[i]->textlen) {
				if ((G_mnu->mh[i]->text=malloc(G_mnu->mh[i]->textlen))
						==(void *)NULL) return(-1);
				read(fd,G_mnu->mh[i]->text,G_mnu->mh[i]->textlen);
			}
		}
		if ((G_mnu->ml=malloc(1+sizeof(menuln *)*G_mnu->numml))
				==(void *)NULL) return(-1);
		for (i=0;i<G_mnu->numml;i++) {
			if ((G_mnu->ml[i]=malloc(sizeof(menuln)))
					==(void *)NULL) return(-1);
			read(fd,G_mnu->ml[i],sizeof(menuln));
			if (G_mnu->ml[i]->textlen) {
				if ((G_mnu->ml[i]->text=malloc(G_mnu->ml[i]->textlen))
						==(void *)NULL) return(-1);
				read(fd,G_mnu->ml[i]->text,G_mnu->ml[i]->textlen);
			}
			if (G_mnu->ml[i]->promptlen) {
				if ((G_mnu->ml[i]->prompt=malloc(G_mnu->ml[i]->promptlen))
						==(void *)NULL) return(-1);
				read(fd,G_mnu->ml[i]->prompt,G_mnu->ml[i]->promptlen);
			}
			if (G_mnu->ml[i]->helplen) {
				if ((G_mnu->ml[i]->help=malloc(G_mnu->ml[i]->helplen))
						==(void *)NULL) return(-1);
				read(fd,G_mnu->ml[i]->help,G_mnu->ml[i]->helplen);
			}
		}
		return(1);
	}
	else
		return(0);
}

int copy_dsp(int fdd) {
	dsp recd;

	memset(&recd, '\0', sizeof(dsp));
	recd.disp_no=G_dsp.dispno;
	recd.disp_attr=G_dsp.bg_attr;
	recd.disp_type=G_dsp.disp_type;
	if (write(fdd,&recd,sizeof(dsp))<0) return(0);
	return(1);
}

int copy_mhd(int fdh) {
	mhd rech;
	int i;

	for (i=0;i<G_mnu->nummh;i++) {
		memset(&rech, '\0', sizeof(mhd));
		rech.disp_no_hd=G_dsp.dispno;
		rech.menhd_line_n=G_mnu->mh[i]->mh_line;
		rech.xpos_hd=G_mnu->mh[i]->xpos;
		if (G_mnu->mh[i]->textlen)
			strcpy(rech.disp_txt_hd,G_mnu->mh[i]->text);
		if (write(fdh,&rech,sizeof(mhd))<0) return(0);
	}
	return(1);
}

int copy_mln(int fdl) {
	mln recl;
	int i;

	for (i=0;i<G_mnu->numml;i++) {
		memset(&recl, '\0', sizeof(mln));
		recl.disp_no_ml=G_dsp.dispno;
		recl.disp_ln_ml=G_mnu->ml[i]->ml_line;
		recl.access_prv_ml=G_mnu->ml[i]->access;
		recl.action_ml=G_mnu->ml[i]->chain_to;
		recl.ypos_ml=G_mnu->ml[i]->ypos;
		recl.disp_attr_ml=G_mnu->ml[i]->ml_attr;
		recl.dis_mnemonic=G_mnu->ml[i]->mne;
		if (G_mnu->ml[i]->textlen)
			strcpy(recl.disp_txt_ml,G_mnu->ml[i]->text);
		if (G_mnu->ml[i]->promptlen)
			strcpy(recl.prom_txt_ml,G_mnu->ml[i]->prompt);
		if (G_mnu->ml[i]->helplen)
			strcpy(recl.help_txt_ml,G_mnu->ml[i]->help);
		if (write(fdl,&recl,sizeof(mln))<0) return(0);
	}
	return(1);
}

int readnxtfrm(int fd) {
	int i,j,k,l;

	G_frm=&G_dsp.ds.f;
	if (read(fd,&G_dsp,sizeof(display))>0) {
		if ((G_frm->scrn=malloc(1+sizeof(screen *)*G_frm->noscrn))
				==(void *)NULL) return(-1);
		for (i=0;i<G_frm->noscrn;i++) {
			if ((G_frm->scrn[i]=malloc(sizeof(screen)))
					==(void *)NULL) return(-1);
			read(fd,G_frm->scrn[i],sizeof(screen));
			if ((G_frm->scrn[i]->fld=malloc(1+sizeof(field *)*G_frm->scrn[i]->nofld))
					==(void *)NULL) return(-1);
			for (j=0;j<G_frm->scrn[i]->nofld;j++) {
				if ((G_frm->scrn[i]->fld[j]=malloc(sizeof(field)))
						==(void *)NULL) return(-1);
				read(fd,G_frm->scrn[i]->fld[j],sizeof(field));
				if ((G_frm->scrn[i]->fld[j]->lnk=malloc(1+sizeof(fldlink *)*G_frm->scrn[i]->fld[j]->nolnks))
						==(void *)NULL) return(-1);
				for (k=0;k<G_frm->scrn[i]->fld[j]->nolnks;k++) {
					if ((G_frm->scrn[i]->fld[j]->lnk[k]=malloc(sizeof(fldlink)))
							==(void *)NULL) return(-1);
					read(fd,G_frm->scrn[i]->fld[j]->lnk[k],sizeof(fldlink));
					if (G_frm->scrn[i]->fld[j]->lnk[k]->val_ex) {
						if ((G_frm->scrn[i]->fld[j]->lnk[k]->val=malloc(sizeof(validation)))
								==(void *)NULL) return(-1);
						read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val,sizeof(validation));
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->rng_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->rng_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->vld_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->vld_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->scf_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->scf_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->prf_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->prf_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->errstr=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->errstr,G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen);
						}
					}
					if ((G_frm->scrn[i]->fld[j]->lnk[k]->op=malloc(1+sizeof(option *)*G_frm->scrn[i]->fld[j]->lnk[k]->numopt))
							==(void *)NULL) return(-1);
					for (l=0;l<G_frm->scrn[i]->fld[j]->lnk[k]->numopt;l++) {
						if ((G_frm->scrn[i]->fld[j]->lnk[k]->op[l]=malloc(sizeof(option)))
								==(void *)NULL) return(-1);
						read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->op[l],sizeof(option));
						if (G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->text=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen))
									==(void *)NULL) return(-1);
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->text,G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen);
						}
					}
				}
				if (G_frm->scrn[i]->fld[j]->deflen) {
					if ((G_frm->scrn[i]->fld[j]->deftext=malloc(G_frm->scrn[i]->fld[j]->deflen))
							==(void *)NULL) return(-1);
					read(fd,G_frm->scrn[i]->fld[j]->deftext,G_frm->scrn[i]->fld[j]->deflen);
				}
				if (G_frm->scrn[i]->fld[j]->textlen) {
					if ((G_frm->scrn[i]->fld[j]->text=malloc(G_frm->scrn[i]->fld[j]->textlen))
							==(void *)NULL) return(-1);
					read(fd,G_frm->scrn[i]->fld[j]->text,G_frm->scrn[i]->fld[j]->textlen);
				}
				if ((G_frm->scrn[i]->fld[j]->eh=malloc(1+sizeof(entryhelp *)*G_frm->scrn[i]->fld[j]->nohelp))
						==(void *)NULL) return(-1);
				for (k=0;k<G_frm->scrn[i]->fld[j]->nohelp;k++) {
					if ((G_frm->scrn[i]->fld[j]->eh[k]=malloc(sizeof(entryhelp)))
							==(void *)NULL) return(-1);
					read(fd,G_frm->scrn[i]->fld[j]->eh[k],sizeof(entryhelp));
					if (G_frm->scrn[i]->fld[j]->eh[k]->helplen) {
						if ((G_frm->scrn[i]->fld[j]->eh[k]->help=malloc(G_frm->scrn[i]->fld[j]->eh[k]->helplen))
								==(void *)NULL) return(-1);
						read(fd,G_frm->scrn[i]->fld[j]->eh[k]->help,G_frm->scrn[i]->fld[j]->eh[k]->helplen);
					}
				}
			}
		}
		return(1);
	}
	return(0);
}

int copy_ftp(int fdt,int fdp,int fdn,int fde,int fdo,int fdv) {
	ftp rect;
	int sno;

	for (sno=0;sno<G_frm->noscrn;sno++) {
		memset(&rect, '\0', sizeof(ftp));
		rect.tuple_id=G_dsp.dispno;
		rect.tuple_fno=G_frm->scrn[sno]->scrnseq;
		rect.tuple_frm=G_frm->scrn[sno]->formid;
		if (write(fdt,&rect,sizeof(ftp))<0) return(0);
		if (!copy_det(sno,fdp,fdn,fde,fdo,fdv)) return(0);
	}
	return(1);
}

int copy_det(int sno,int fdp,int fdn,int fde,int fdo,int fdv) {
	det recp;
	int fno,fldno=0,i;

	for (fno=0;fno<G_frm->scrn[sno]->nofld;fno++) {
		fldno++;
		memset(&recp, '\0', sizeof(det));
		recp.disp_no_et=G_frm->scrn[sno]->formid;
		recp.disp_scope=G_frm->scrn[sno]->fld[fno]->scope;
		recp.just=G_frm->scrn[sno]->fld[fno]->just;
		recp.disp_attr_et=G_frm->scrn[sno]->fld[fno]->attr;
		recp.dispitem_typ=G_frm->scrn[sno]->fld[fno]->fldtype;
		recp.xpos=G_frm->scrn[sno]->fld[fno]->xpos;
		recp.disp_rng_st=G_frm->scrn[sno]->fld[fno]->top;
		recp.disp_rg_end=G_frm->scrn[sno]->fld[fno]->bottom;
		recp.disp_width=G_frm->scrn[sno]->fld[fno]->width;
		recp.disp_ncols=G_frm->scrn[sno]->fld[fno]->nocols;
		recp.disp_lt=G_frm->scrn[sno]->fld[fno]->nolnks;
		if (strlen(G_frm->scrn[sno]->fld[fno]->seqname)) {
			for (i=0;i<G_noseqs;i++) {
				if (!strcmp(G_frm->scrn[sno]->fld[fno]->seqname,G_seqs[i].name)) {
					recp.action_at=G_seqs[i].seq;
					break;
				}
			}
		}
		recp.disp_glbl_var=G_frm->scrn[sno]->fld[fno]->offset;
		if (G_frm->scrn[sno]->fld[fno]->deflen)
			strcpy(recp.default_val,G_frm->scrn[sno]->fld[fno]->deftext);
		if (G_frm->scrn[sno]->fld[fno]->textlen) {
			if (G_frm->scrn[sno]->fld[fno]->fldtype=='T')
				stcpy(recp.disp_txt_strg,G_frm->scrn[sno]->fld[fno]->text);
			else {
				copy_fldtxt(sno,fno,fldno++,fdp);
				if (G_frm->scrn[sno]->fld[fno]->bottom==G_frm->scrn[sno]->fld[fno]->top)
					recp.xpos+=1+strlen(G_frm->scrn[sno]->fld[fno]->text);
			}
		}
		recp.disp_en_et=fldno;
		if (write(fdp,&recp,sizeof(det))<0) return(0);
		if (!copy_lnk(sno,fno,fldno,fdn,fdo,fdv))	return(0);
		if (!copy_ehp(sno,fno,fldno,fde))	return(0);
	}
	return(1);
}

int copy_fldtxt(int sno,int fno,int fldno,int fdp) {
	det recp;

	memset(&recp, '\0', sizeof(det));
	recp.disp_no_et=G_frm->scrn[sno]->formid;
	recp.disp_en_et=fldno;
	recp.just='L';
	recp.disp_attr_et=G_frm->scrn[sno]->fld[fno]->attr;
	recp.dispitem_typ='T';
	recp.xpos=G_frm->scrn[sno]->fld[fno]->xpos;
	if (G_frm->scrn[sno]->fld[fno]->bottom!=G_frm->scrn[sno]->fld[fno]->top)
		recp.disp_rng_st=recp.disp_rg_end=G_frm->scrn[sno]->fld[fno]->top-1;
	else
		recp.disp_rng_st=recp.disp_rg_end=G_frm->scrn[sno]->fld[fno]->top;
	recp.disp_width=strlen(G_frm->scrn[sno]->fld[fno]->text);
	stcpy(recp.disp_txt_strg,G_frm->scrn[sno]->fld[fno]->text);
	if (write(fdp,&recp,sizeof(det))<0) return(0);
	return(1);
}

int copy_lnk(int sno,int fno,int fldno,int fdn,int fdo,int fdv) {
	lnk recn;
	int lno;

	for (lno=0;lno<G_frm->scrn[sno]->fld[fno]->nolnks;lno++) {
		memset(&recn, '\0', sizeof(lnk));
		recn.formid=G_frm->scrn[sno]->formid;
		recn.fldno=fldno;
		recn.lnkno=G_frm->scrn[sno]->fld[fno]->lnk[lno]->lnkno;
		recn.store_id=G_frm->scrn[sno]->fld[fno]->lnk[lno]->storeid+1;
		recn.st_fldid=G_frm->scrn[sno]->fld[fno]->lnk[lno]->st_fldid;
		recn.key_nb=G_frm->scrn[sno]->fld[fno]->lnk[lno]->st_key;
		recn.disp_type=G_frm->scrn[sno]->fld[fno]->lnk[lno]->disp_type;
		recn.xdisplace=G_frm->scrn[sno]->fld[fno]->lnk[lno]->x_displace;
		recn.width=G_frm->scrn[sno]->fld[fno]->lnk[lno]->st_width;
		if (write(fdn,&recn,sizeof(lnk))<0) return(0);
		if (!copy_val(sno,fno,fldno,lno,fdv)) return(0);
		if (!copy_opt(sno,fno,fldno,lno,fdo)) return(0);
	}
	return(1);
}

int copy_val(int sno,int fno,int fldno,int lno,int fdv) {
	val recv;
	int i;

	if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val_ex) {
		memset(&recv, '\0', sizeof(val));
		recv.formid=G_frm->scrn[sno]->formid;
		recv.fldno=fldno;
		recv.lnkno=G_frm->scrn[sno]->fld[fno]->lnk[lno]->lnkno;
		if (strlen(G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->seqname)) {
			for (i=0;i<G_noseqs;i++) {
				if (!strcmp(G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->seqname,G_seqs[i].name)) {
					recv.seq=G_seqs[i].seq;
					break;
				}
			}
		}
		recv.type=G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->type;
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->rflen)
			strcpy(recv.rng_fmt,G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->rng_fmt);
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->vflen)
			strcpy(recv.vld_fmt,G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->vld_fmt);
		recv.v_case=G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->vcase;
		recv.just=G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->just;
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->sflen)
			strcpy(recv.scf_fmt,G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->scf_fmt);
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->pflen)
			strcpy(recv.prf_fmt,G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->prf_fmt);
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->errlen)
			strcpy(recv.errstr,G_frm->scrn[sno]->fld[fno]->lnk[lno]->val->errstr);
		if (write(fdv,&recv,sizeof(val))<0) return(0);
	}
	return(1);
}

int copy_opt(int sno,int fno,int fldno,int lno,int fdo) {
	opt reco;
	int ono;

	for (ono=0;ono<G_frm->scrn[sno]->fld[fno]->lnk[lno]->numopt;ono++) {
		memset(&reco, '\0', sizeof(opt));
		reco.formid=G_frm->scrn[sno]->formid;
		reco.fldno=fldno;
		reco.lnkno=G_frm->scrn[sno]->fld[fno]->lnk[lno]->lnkno;
		reco.optno=G_frm->scrn[sno]->fld[fno]->lnk[lno]->op[ono]->optno;
		reco.mne=G_frm->scrn[sno]->fld[fno]->lnk[lno]->op[ono]->mne;
		if (G_frm->scrn[sno]->fld[fno]->lnk[lno]->op[ono]->textlen)
			strcpy(reco.text,G_frm->scrn[sno]->fld[fno]->lnk[lno]->op[ono]->text);
		if (write(fdo,&reco,sizeof(opt))<0) return(0);
	}
	return(1);
}

int copy_ehp(int sno,int fno,int fldno,int fde) {
	ehp rece;
	int hno;

	for (hno=0;hno<G_frm->scrn[sno]->fld[fno]->nohelp;hno++) {
		memset(&rece, '\0', sizeof(ehp));
		rece.disp_no_eh=G_frm->scrn[sno]->formid;
		rece.disp_en_hl=fldno;
		rece.hlp_txt_n_hl=G_frm->scrn[sno]->fld[fno]->eh[hno]->hlpno;
		if (G_frm->scrn[sno]->fld[fno]->eh[hno]->helplen)
			strcpy(rece.help_txt_hl,G_frm->scrn[sno]->fld[fno]->eh[hno]->help);
		if (write(fde,&rece,sizeof(ehp))<0) return(0);
	}
	return(1);
}

int stcpy(char * dest,char * src) {
/* copies strings removing \n and \r before copy */
	char temp[100];
	int  i;

	for (i=0;((i<strlen(src))&&(src[i]!='\r'));i++) {
		if ((src[i]=='\n')
		|| (src[i]=='_'))
			temp[i]=' ';
		else
			temp[i]=src[i];
	}
	temp[i]=0;
	strcpy(dest,temp);
	return(1);
}