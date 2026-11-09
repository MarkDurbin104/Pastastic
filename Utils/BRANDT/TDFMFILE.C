#include <fcntl.h>
#include <io.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tdef.h"
#include "tdfrm.h"
#include "tdconv.h"

fidx G_irec;
long G_cursize;
display G_dsp;
form   *G_frm;
menu   *G_mnu;

long getidx(char *name,int dispno,char itype);
int  tempmnu(display *d,int fd,int id);
void testmenu(void);

loadmenu(char *fil,int dispno) {
	int fd,i;
	char filenam[20];

	sprintf(filenam,"%s%s",fil,MENU_EXT);
	if ((fd=open(filenam,O_RDONLY|O_BINARY))<0)
		fd=open(filenam,O_RDWR|O_TRUNC|O_BINARY|O_CREAT,0777);
	getidx(fil,dispno,'m');
	G_cursize=0;
	if ( G_irec.foffs < (long) 0 ) {
		close(fd);
		memset(&G_dsp,0,sizeof(display));
		G_dsp.dispno=dispno;
		G_dsp.bg_attr=0;
		G_dsp.disp_type=MENUTYPE;
		G_irec.foffs=0;
		G_cursize=sizeof(display);
		return(0);
	}
	lseek(fd,G_irec.foffs,SEEK_SET);
	if (read(fd,&G_dsp,sizeof(display))>0) {
		G_cursize=sizeof(display);
		if ((G_mnu->mh=malloc(1+sizeof(menuhdr *)*(G_mnu->nummh)))
				==(void *)NULL) return(-1);
		for (i=0;i<G_mnu->nummh;i++) {
			if ((G_mnu->mh[i]=malloc(sizeof(menuhdr)))
					==(void *)NULL) return(-1);
			G_cursize+=sizeof(menuhdr);
			read(fd,G_mnu->mh[i],sizeof(menuhdr));
			if (G_mnu->mh[i]->textlen) {
				if ((G_mnu->mh[i]->text=malloc(G_mnu->mh[i]->textlen))
						==(void *)NULL) return(-1);
				G_cursize+=G_mnu->mh[i]->textlen;
				read(fd,G_mnu->mh[i]->text,G_mnu->mh[i]->textlen);
			}
		}
		if ((G_mnu->ml=malloc(1+sizeof(menuln *)*G_mnu->numml))
				==(void *)NULL) return(-1);
		for (i=0;i<G_mnu->numml;i++) {
			if ((G_mnu->ml[i]=malloc(sizeof(menuln)))
					==(void *)NULL) return(-1);
			G_cursize+=sizeof(menuln);
			read(fd,G_mnu->ml[i],sizeof(menuln));
			if (G_mnu->ml[i]->textlen) {
				if ((G_mnu->ml[i]->text=malloc(G_mnu->ml[i]->textlen))
						==(void *)NULL) return(-1);
				G_cursize+=G_mnu->ml[i]->textlen;
				read(fd,G_mnu->ml[i]->text,G_mnu->ml[i]->textlen);
			}
			if (G_mnu->ml[i]->promptlen) {
				if ((G_mnu->ml[i]->prompt=malloc(G_mnu->ml[i]->promptlen))
						==(void *)NULL) return(-1);
				G_cursize+=G_mnu->ml[i]->promptlen;
				read(fd,G_mnu->ml[i]->prompt,G_mnu->ml[i]->promptlen);
			}
			if (G_mnu->ml[i]->helplen) {
				if ((G_mnu->ml[i]->help=malloc(G_mnu->ml[i]->helplen))
						==(void *)NULL) return(-1);
				G_cursize+=G_mnu->ml[i]->helplen;
				read(fd,G_mnu->ml[i]->help,G_mnu->ml[i]->helplen);
			}
		}
		if (G_dsp.dispno==dispno) {
			close(fd);
			return(1);
		}
		else {
			freemnu(G_mnu,1);
		}
	}
	close(fd);
	memset(&G_dsp,0,sizeof(display));
	G_dsp.dispno=dispno;
	G_dsp.bg_attr=0;
	G_dsp.disp_type=MENUTYPE;
	G_cursize=sizeof(display);
	return(0);
}

int savemenu(char *fil,display *rec,char delete) {
	int fd,tfd,i,xit=0,id,tid;
	display *d;
	menu    *m;
	char filenam[20],tempnam[30],*t,idxnam[20],idtempnm[30];
	long recoffs;

	strcpy(tempnam,".\\");  /* create temporary file and reopen for write only */
	if ((tfd=creattemp(tempnam,0))==(-1)) return(-1);
	close(tfd);
	strcpy(idtempnm,".\\");  /* create temporary index file and reopen for write only */
	if ((tid=creattemp(idtempnm,0))==(-1)) {
		unlink(tempnam);
		return(0);
	}
	close(tid);
	tfd=open(tempnam,O_WRONLY|O_BINARY);
	tid=open(idtempnm,O_WRONLY|O_BINARY);
	if ((d=malloc(sizeof(display)))==(void *)NULL) return(-1);
	d->dispno=(-1);
	sprintf(filenam,"%s%s",fil,MENU_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	sprintf(idxnam,"%s%s",fil,MID_EXT);
	id=open(idxnam,O_WRONLY|O_BINARY);
	recoffs=0;
	while (read(fd,d,sizeof(display))>0) {
		G_irec.dispno=d->dispno;
		G_irec.foffs=recoffs;
		recoffs+=sizeof(display);
		m=&d->ds.m;
		if ((m->mh=malloc(1+sizeof(menuhdr *)*m->nummh))
				==(void *)NULL) return(-1);
		for (i=0;i<m->nummh;i++) {
			if ((m->mh[i]=malloc(sizeof(menuhdr)))
					==(void *)NULL) return(-1);
			read(fd,m->mh[i],sizeof(menuhdr));
			recoffs+=sizeof(menuhdr);
			if (m->mh[i]->textlen) {
				if ((m->mh[i]->text=malloc(m->mh[i]->textlen))
						==(void *)NULL) return(-1);
				read(fd,m->mh[i]->text,m->mh[i]->textlen);
				recoffs+=m->mh[i]->textlen;
			}
		}
		if ((m->ml=malloc(1+sizeof(menuln *)*m->numml))
				==(void *)NULL) return(-1);
		for (i=0;i<m->numml;i++) {
			if ((m->ml[i]=malloc(sizeof(menuln)))
					==(void *)NULL) return(-1);
			read(fd,m->ml[i],sizeof(menuln));
			recoffs+=sizeof(menuln);
			if (m->ml[i]->textlen) {
				if ((m->ml[i]->text=malloc(m->ml[i]->textlen))
						==(void *)NULL) return(-1);
				read(fd,m->ml[i]->text,m->ml[i]->textlen);
				recoffs+=m->ml[i]->textlen;
			}
			if (m->ml[i]->promptlen) {
				if ((m->ml[i]->prompt=malloc(m->ml[i]->promptlen))
						==(void *)NULL) return(-1);
				read(fd,m->ml[i]->prompt,m->ml[i]->promptlen);
				recoffs+=m->ml[i]->promptlen;
			}
			if (m->ml[i]->helplen) {
				if ((m->ml[i]->help=malloc(m->ml[i]->helplen))
						==(void *)NULL) return(-1);
				read(fd,m->ml[i]->help,m->ml[i]->helplen);
				recoffs+=m->ml[i]->helplen;
			}
		}
		if (d->dispno==rec->dispno) { /* if record is same as record in memory */
			xit=1;
			if (!delete) {
				if (!tempmnu(rec,tfd,tid)) { /* write new record to temp file */
					freemnu(m,0);             /* on write error */
					free(d);
					close(fd);
					close(tfd);
					unlink(tempnam);
					close(id);
					close(tid);
					unlink(idtempnm);
					return(0);
				}
				recoffs=G_irec.foffs+G_cursize;
			}
			else {
				recoffs=G_irec.foffs;
			}
		}
		else {
			if (!tempmnu(d,tfd,tid)) { /* otherwise write original rec to temp file */
				freemnu(m,0);           /* write error */
				free(d);
				close(fd);
				close(tfd);
				unlink(tempnam);
				close(id);
				close(tid);
				unlink(idtempnm);
				return(0);
			}
		}
		/* write   has succeeded , but free space anyway */
		freemnu(m,0);
	}
	G_irec.foffs=recoffs;
	G_irec.dispno=rec->dispno;
	if ((!xit)&&(!delete)) tempmnu(rec,tfd,tid); /* write last record to temp file */
	free(d);
	t=malloc(4096); /* block size for block read */
	close(fd);
	close(tfd);
	close(id);
	close(tid);
	unlink(filenam);
	unlink(idxnam);
	if ((tfd=open(tempnam,O_RDONLY|O_BINARY))==(-1)) return(0);
	if ((fd=open(filenam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
	while(write(fd,t,read(tfd,t,4096)));
	close(fd);
	close(tfd);
	unlink(tempnam); /* deletes temporary file */
	if ((tid=open(idtempnm,O_RDONLY|O_BINARY))==(-1)) return(0);
	if ((id=open(idxnam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
	while(write(id,t,read(tid,t,4096)));
	close(id);
	close(tid);
	unlink(idtempnm); /* deletes temporary index file */
	free(t);
	return(1);
}

int tempmnu(display *d,int fd,int id) {
	int i;
	menu *m;

/* write index record */
	if (write(id,&G_irec,sizeof(fidx))==(-1)) return(0);
/* write all parts of display file as required */
	if (write(fd,d,sizeof(display))==(-1)) return(0);
	m=&d->ds.m;
	for (i=0;i<m->nummh;i++) {
		if (write(fd,m->mh[i],sizeof(menuhdr))==(-1)) return(0);
		if (m->mh[i]->textlen)
			if (write(fd,m->mh[i]->text,m->mh[i]->textlen)==(-1)) return(0);
	}
	for (i=0;i<m->numml;i++) {
		if (write(fd,m->ml[i],sizeof(menuln))==(-1)) return(0);
		if (m->ml[i]->textlen)
			if (write(fd,m->ml[i]->text,m->ml[i]->textlen)==(-1)) return(0);
		if (m->ml[i]->promptlen)
			if (write(fd,m->ml[i]->prompt,m->ml[i]->promptlen)==(-1)) return(0);
		if (m->ml[i]->helplen)
			if (write(fd,m->ml[i]->help,m->ml[i]->helplen)==(-1)) return(0);
	}
	return(1);
}

int loadform(char *fil,int dispno) {
	int fd,i,j,k,l;
	char filenam[20];

	sprintf(filenam,"%s%s",fil,FORM_EXT);
	if ((fd=open(filenam,O_RDONLY|O_BINARY))<0)
		fd=open(filenam,O_RDWR|O_TRUNC|O_BINARY|O_CREAT,0777);
	G_cursize=0;
	getidx(fil,dispno,'f');
	if ( G_irec.foffs < (long) 0 ) {
		close(fd);
		memset(&G_dsp,0,sizeof(display));
		G_dsp.dispno=dispno;
		G_dsp.bg_attr=0;
		G_dsp.disp_type=FORMTYPE;
		G_irec.foffs=0;
		G_cursize=sizeof(display);
		return(0);
	}
	lseek(fd,G_irec.foffs,SEEK_SET);
	if (read(fd,&G_dsp,sizeof(display))>0) {
		G_cursize=sizeof(display);
		if ((G_frm->scrn=malloc(1+sizeof(screen *)*G_frm->noscrn))
				==(void *)NULL) return(-1);
		for (i=0;i<G_frm->noscrn;i++) {
			if ((G_frm->scrn[i]=malloc(sizeof(screen)))
					==(void *)NULL) return(-1);
			G_cursize+=sizeof(screen);
			read(fd,G_frm->scrn[i],sizeof(screen));
			if ((G_frm->scrn[i]->fld=malloc(1+sizeof(field *)*G_frm->scrn[i]->nofld))
					==(void *)NULL) return(-1);
			for (j=0;j<G_frm->scrn[i]->nofld;j++) {
				if ((G_frm->scrn[i]->fld[j]=malloc(sizeof(field)))
						==(void *)NULL) return(-1);
				G_cursize+=sizeof(field);
				read(fd,G_frm->scrn[i]->fld[j],sizeof(field));
				if ((G_frm->scrn[i]->fld[j]->lnk=malloc(1+sizeof(fldlink *)*G_frm->scrn[i]->fld[j]->nolnks))
						==(void *)NULL) return(-1);
				for (k=0;k<G_frm->scrn[i]->fld[j]->nolnks;k++) {
					if ((G_frm->scrn[i]->fld[j]->lnk[k]=malloc(sizeof(fldlink)))
							==(void *)NULL) return(-1);
					G_cursize+=sizeof(fldlink);
					read(fd,G_frm->scrn[i]->fld[j]->lnk[k],sizeof(fldlink));
					if (G_frm->scrn[i]->fld[j]->lnk[k]->val_ex) {
						if ((G_frm->scrn[i]->fld[j]->lnk[k]->val=malloc(sizeof(validation)))
								==(void *)NULL) return(-1);
						G_cursize+=sizeof(validation);
						read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val,sizeof(validation));
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->rng_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->rng_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->rflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->vld_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->vld_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->vflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->scf_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->scf_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->sflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->prf_fmt=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->prf_fmt,G_frm->scrn[i]->fld[j]->lnk[k]->val->pflen);
						}
						if (G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->val->errstr=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->val->errstr,G_frm->scrn[i]->fld[j]->lnk[k]->val->errlen);
						}
					}
					if ((G_frm->scrn[i]->fld[j]->lnk[k]->op=malloc(1+sizeof(option *)*G_frm->scrn[i]->fld[j]->lnk[k]->numopt))
							==(void *)NULL) return(-1);
					for (l=0;l<G_frm->scrn[i]->fld[j]->lnk[k]->numopt;l++) {
						if ((G_frm->scrn[i]->fld[j]->lnk[k]->op[l]=malloc(sizeof(option)))
								==(void *)NULL) return(-1);
						G_cursize+=sizeof(option);
						read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->op[l],sizeof(option));
						if (G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen) {
							if ((G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->text=malloc(G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen))
									==(void *)NULL) return(-1);
							G_cursize+=G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen;
							read(fd,G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->text,G_frm->scrn[i]->fld[j]->lnk[k]->op[l]->textlen);
						}
					}
				}
				if (G_frm->scrn[i]->fld[j]->deflen) {
					if ((G_frm->scrn[i]->fld[j]->deftext=malloc(G_frm->scrn[i]->fld[j]->deflen))
							==(void *)NULL) return(-1);
					G_cursize+=G_frm->scrn[i]->fld[j]->deflen;
					read(fd,G_frm->scrn[i]->fld[j]->deftext,G_frm->scrn[i]->fld[j]->deflen);
				}
				if (G_frm->scrn[i]->fld[j]->textlen) {
					if ((G_frm->scrn[i]->fld[j]->text=malloc(G_frm->scrn[i]->fld[j]->textlen))
							==(void *)NULL) return(-1);
					G_cursize+=G_frm->scrn[i]->fld[j]->textlen;
					read(fd,G_frm->scrn[i]->fld[j]->text,G_frm->scrn[i]->fld[j]->textlen);
				}
				if ((G_frm->scrn[i]->fld[j]->eh=malloc(1+sizeof(entryhelp *)*G_frm->scrn[i]->fld[j]->nohelp))
						==(void *)NULL) return(-1);
				for (k=0;k<G_frm->scrn[i]->fld[j]->nohelp;k++) {
					if ((G_frm->scrn[i]->fld[j]->eh[k]=malloc(sizeof(entryhelp)))
							==(void *)NULL) return(-1);
					G_cursize+=sizeof(entryhelp);
					read(fd,G_frm->scrn[i]->fld[j]->eh[k],sizeof(entryhelp));
					if (G_frm->scrn[i]->fld[j]->eh[k]->helplen) {
						if ((G_frm->scrn[i]->fld[j]->eh[k]->help=malloc(G_frm->scrn[i]->fld[j]->eh[k]->helplen))
								==(void *)NULL) return(-1);
						G_cursize+=G_frm->scrn[i]->fld[j]->eh[k]->helplen;
						read(fd,G_frm->scrn[i]->fld[j]->eh[k]->help,G_frm->scrn[i]->fld[j]->eh[k]->helplen);
					}
				}
			}
		}
		if (G_dsp.dispno==dispno) {
			close(fd);
			return(1);
		}
		else {
			freefrm(G_frm,1);
		}
	}
	close(fd);
	memset(&G_dsp,0,sizeof(display));
	G_dsp.dispno=dispno;
	G_dsp.bg_attr=0;
	G_dsp.disp_type=FORMTYPE;
	return(0);
}

long getidx(char *name,int dispno,char itype) {
	int a,norec,id;
	char idxnam[20];
	fidx *irec,*irecp;

	memset(&G_irec,0,sizeof(fidx));
	if (itype=='f')
		sprintf(idxnam,"%s%s",name,FID_EXT);
	else if (itype=='m')
		sprintf(idxnam,"%s%s",name,MID_EXT);
	else return(0);
	if ((id=open(idxnam,O_RDONLY|O_BINARY))<0)
		id=open(idxnam,O_RDWR|O_TRUNC|O_BINARY|O_CREAT,0777);
	irec=malloc(sizeof(fidx)*100);
	a=1;
	lseek(id,0L,SEEK_SET);
	while(a>0) {
		a=read(id,irec,sizeof(fidx)*100); /* read in blocks of up to 100 recs */
		if (a>0) {
			norec=a/sizeof(fidx);
			irecp=lfind(&dispno,irec,(size_t *)&norec,sizeof(fidx),intcmp);
			if (irecp!=(void *)NULL) { /* record found...*/
				memcpy(&G_irec,irecp,sizeof(fidx));
				free(irec);
				close(id);
				return(G_irec.foffs);
			}
		}
	}
	free(irec);
	close(id);
	return(0);
}

int saveform(char *fil,display *rec,char delete) {
	int fd,tfd,i,j,k,l,xit=0,id,tid;
	char filenam[20],tempnam[30],*t,idxnam[20],idtempnm[30];
	display *d;
	form    *f;
	long recoffs;

	strcpy(tempnam,".\\");  /* create temporary file and reopen for write only */
	if ((tfd=creattemp(tempnam,0))==(-1)) return(0);
	close(tfd);
	strcpy(idtempnm,".\\");  /* create temporary index file and reopen for write only */
	if ((tid=creattemp(idtempnm,0))==(-1)) {
		unlink(tempnam);
		return(0);
	}
	close(tid);
	tfd=open(tempnam,O_WRONLY|O_BINARY);
	tid=open(idtempnm,O_WRONLY|O_BINARY);
	if ((d=malloc(sizeof(display)))==(void *)NULL) return(0);
	d->dispno=(-1);
	sprintf(filenam,"%s%s",fil,FORM_EXT);
	fd=open(filenam,O_RDONLY|O_BINARY);
	sprintf(idxnam,"%s%s",fil,FID_EXT);
	id=open(idxnam,O_WRONLY|O_BINARY);
	recoffs=0;
	while (read(fd,d,sizeof(display))>0) {
		G_irec.dispno=d->dispno;
		G_irec.foffs=recoffs;
		recoffs+=sizeof(display);
		f=&d->ds.f;
		if ((f->scrn=malloc(1+sizeof(screen *)*(f->noscrn)))
				==(void *)NULL) return(0);
		for (i=0;i<f->noscrn;i++) {
			if ((f->scrn[i]=malloc(sizeof(screen)))
					==(void *)NULL) return(0);
			read(fd,f->scrn[i],sizeof(screen));
			recoffs+=sizeof(screen);
			if ((f->scrn[i]->fld=malloc(1+sizeof(field *)*(f->scrn[i]->nofld)))
					==(void *)NULL) return(0);
			for (j=0;j<f->scrn[i]->nofld;j++) {
				if ((f->scrn[i]->fld[j]=malloc(sizeof(field)))
						==(void *)NULL) return(0);
				read(fd,f->scrn[i]->fld[j],sizeof(field));
				recoffs+=sizeof(field);
				if ((f->scrn[i]->fld[j]->lnk=malloc(1+sizeof(fldlink *)*(f->scrn[i]->fld[j]->nolnks)))
						==(void *)NULL) return(0);
				for (k=0;k<f->scrn[i]->fld[j]->nolnks;k++) {
					if ((f->scrn[i]->fld[j]->lnk[k]=malloc(sizeof(fldlink)))
							==(void *)NULL) return(0);
					read(fd,f->scrn[i]->fld[j]->lnk[k],sizeof(fldlink));
					recoffs+=sizeof(fldlink);
					if (f->scrn[i]->fld[j]->lnk[k]->val_ex) {
						if ((f->scrn[i]->fld[j]->lnk[k]->val=malloc(sizeof(validation)))
								==(void *)NULL) return(0);
						read(fd,f->scrn[i]->fld[j]->lnk[k]->val,sizeof(validation));
						recoffs+=sizeof(validation);
						if (f->scrn[i]->fld[j]->lnk[k]->val->rflen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->val->rng_fmt=malloc(f->scrn[i]->fld[j]->lnk[k]->val->rflen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->val->rflen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->val->rng_fmt,f->scrn[i]->fld[j]->lnk[k]->val->rflen);
						}
						if (f->scrn[i]->fld[j]->lnk[k]->val->vflen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->val->vld_fmt=malloc(f->scrn[i]->fld[j]->lnk[k]->val->vflen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->val->vflen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->val->vld_fmt,f->scrn[i]->fld[j]->lnk[k]->val->vflen);
						}
						if (f->scrn[i]->fld[j]->lnk[k]->val->sflen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->val->scf_fmt=malloc(f->scrn[i]->fld[j]->lnk[k]->val->sflen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->val->sflen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->val->scf_fmt,f->scrn[i]->fld[j]->lnk[k]->val->sflen);
						}
						if (f->scrn[i]->fld[j]->lnk[k]->val->pflen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->val->prf_fmt=malloc(f->scrn[i]->fld[j]->lnk[k]->val->pflen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->val->pflen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->val->prf_fmt,f->scrn[i]->fld[j]->lnk[k]->val->pflen);
						}
						if (f->scrn[i]->fld[j]->lnk[k]->val->errlen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->val->errstr=malloc(f->scrn[i]->fld[j]->lnk[k]->val->errlen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->val->errlen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->val->errstr,f->scrn[i]->fld[j]->lnk[k]->val->errlen);
						}
					}
					if ((f->scrn[i]->fld[j]->lnk[k]->op=malloc(1+sizeof(option *)*(f->scrn[i]->fld[j]->lnk[k]->numopt)))
							==(void *)NULL) return(0);
					for (l=0;l<f->scrn[i]->fld[j]->lnk[k]->numopt;l++) {
						if ((f->scrn[i]->fld[j]->lnk[k]->op[l]=malloc(sizeof(option)))
								==(void *)NULL) return(0);
						read(fd,f->scrn[i]->fld[j]->lnk[k]->op[l],sizeof(option));
						recoffs+=sizeof(option);
						if (f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen) {
							if ((f->scrn[i]->fld[j]->lnk[k]->op[l]->text=malloc(f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen))
									==(void *)NULL) return(0);
							recoffs+=f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen;
							read(fd,f->scrn[i]->fld[j]->lnk[k]->op[l]->text,f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen);
						}
					}
				}
				if (f->scrn[i]->fld[j]->deflen) {
					if ((f->scrn[i]->fld[j]->deftext=malloc(f->scrn[i]->fld[j]->deflen))
							==(void *)NULL) return(0);
					recoffs+=f->scrn[i]->fld[j]->deflen;
					read(fd,f->scrn[i]->fld[j]->deftext,f->scrn[i]->fld[j]->deflen);
				}
				if (f->scrn[i]->fld[j]->textlen) {
					if ((f->scrn[i]->fld[j]->text=malloc(f->scrn[i]->fld[j]->textlen))
							==(void *)NULL) return(0);
					recoffs+=f->scrn[i]->fld[j]->textlen;
					read(fd,f->scrn[i]->fld[j]->text,f->scrn[i]->fld[j]->textlen);
				}
				if ((f->scrn[i]->fld[j]->eh=malloc(1+sizeof(entryhelp *)*(f->scrn[i]->fld[j]->nohelp)))
						==(void *)NULL) return(0);
				for (k=0;k<f->scrn[i]->fld[j]->nohelp;k++) {
					if ((f->scrn[i]->fld[j]->eh[k]=malloc(sizeof(entryhelp)))
							==(void *)NULL) return(0);
					read(fd,f->scrn[i]->fld[j]->eh[k],sizeof(entryhelp));
					recoffs+=sizeof(entryhelp);
					if (f->scrn[i]->fld[j]->eh[k]->helplen) {
						if ((f->scrn[i]->fld[j]->eh[k]->help=malloc(f->scrn[i]->fld[j]->eh[k]->helplen))
								==(void *)NULL) return(0);
						recoffs+=f->scrn[i]->fld[j]->eh[k]->helplen;
						read(fd,f->scrn[i]->fld[j]->eh[k]->help,f->scrn[i]->fld[j]->eh[k]->helplen);
					}
				}
			}
		}
		if (d->dispno==rec->dispno) { /* if record is same as record in memory */
			xit=1;
			if (!delete) {
				if (!writefrm(rec,tfd,tid,1)) { /* write new record to temp file */
					freefrm(f,0); /* if write error free all space */
					free(d);    /* and close files */
					close(fd);
					close(tfd);
					unlink(tempnam);
					close(id);
					close(tid);
					unlink(idtempnm);
					return(0);
				}
				recoffs=G_irec.foffs+G_cursize;
			}
			else
				recoffs=G_irec.foffs;
		}
		else {
			if (!writefrm(d,tfd,tid,1)) { /* otherwise write original rec to temp file */
				freefrm(f,0); /* if write error free all space */
				free(d);    /* and close files */
				close(fd);
				close(tfd);
				unlink(tempnam);
				close(id);
				close(tid);
				unlink(idtempnm);
				return(0);
			}
		}
		/* write   has succeeded , but free space anyway */
		freefrm(f,0);
	}
	G_irec.foffs=recoffs;
	G_irec.dispno=rec->dispno;
	if ((!xit)&&(!delete)) writefrm(rec,tfd,tid,1); /* write last record to temp file */
	free(d);
	t=malloc(4096); /* block size for block read */
	close(fd);
	close(tfd);
	close(id);
	close(tid);
	unlink(filenam);
	unlink(idxnam);
	if ((tfd=open(tempnam,O_RDONLY|O_BINARY))==(-1)) return(0);
	if ((fd=open(filenam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
	while(write(fd,t,read(tfd,t,4096)));
	close(fd);
	close(tfd);
	unlink(tempnam); /* deletes temporary file */
	if ((tid=open(idtempnm,O_RDONLY|O_BINARY))==(-1)) return(0);
	if ((id=open(idxnam,O_WRONLY|O_TRUNC|O_BINARY|O_CREAT,0777))==(-1)) return(0);
	while(write(id,t,read(tid,t,4096)));
	close(id);
	close(tid);
	unlink(idtempnm); /* deletes temporary index file */
	free(t);
	return(1);
}

int writefrm(display *d,int fd,int id,char iflag) {
	int i,j,k,l;
	form *f;

/* write index record */
	if (iflag) {
		if (write(id,&G_irec,sizeof(fidx))==(-1)) return(0);
	}
/* write all parts of display file as required */
	if (write(fd,d,sizeof(display))==(-1)) return(0);
	f=&d->ds.f;
	for (i=0;i<f->noscrn;i++) {
		if (write(fd,f->scrn[i],sizeof(screen))==(-1)) return(0);
		for (j=0;j<f->scrn[i]->nofld;j++) {
			if (write(fd,f->scrn[i]->fld[j],sizeof(field))==(-1)) return(0);
			for (k=0;k<f->scrn[i]->fld[j]->nolnks;k++) {
				if (write(fd,f->scrn[i]->fld[j]->lnk[k],sizeof(fldlink))==(-1)) return(0);
				if (f->scrn[i]->fld[j]->lnk[k]->val_ex) {
					if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val,sizeof(validation))==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->val->rflen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val->rng_fmt,f->scrn[i]->fld[j]->lnk[k]->val->rflen)==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->val->vflen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val->vld_fmt,f->scrn[i]->fld[j]->lnk[k]->val->vflen)==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->val->sflen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val->scf_fmt,f->scrn[i]->fld[j]->lnk[k]->val->sflen)==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->val->pflen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val->prf_fmt,f->scrn[i]->fld[j]->lnk[k]->val->pflen)==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->val->errlen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->val->errstr,f->scrn[i]->fld[j]->lnk[k]->val->errlen)==(-1)) return(0);
				}
				for (l=0;l<f->scrn[i]->fld[j]->lnk[k]->numopt;l++) {
					if (write(fd,f->scrn[i]->fld[j]->lnk[k]->op[l],sizeof(option))==(-1)) return(0);
					if (f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen)
						if (write(fd,f->scrn[i]->fld[j]->lnk[k]->op[l]->text,f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen)==(-1)) return(0);
				}
			}
			if (f->scrn[i]->fld[j]->deflen)
				if (write(fd,f->scrn[i]->fld[j]->deftext,f->scrn[i]->fld[j]->deflen)==(-1)) return(0);
			if (f->scrn[i]->fld[j]->textlen)
				if (write(fd,f->scrn[i]->fld[j]->text,f->scrn[i]->fld[j]->textlen)==(-1)) return(0);
			for (k=0;k<f->scrn[i]->fld[j]->nohelp;k++) {
				if (write(fd,f->scrn[i]->fld[j]->eh[k],sizeof(entryhelp))==(-1)) return(0);
				if (f->scrn[i]->fld[j]->eh[k]->helplen)
					if (write(fd,f->scrn[i]->fld[j]->eh[k]->help,f->scrn[i]->fld[j]->eh[k]->helplen)==(-1)) return(0);
			}
		}
	}
	return(1);
}

void freemnu(menu *m,char flag) {
	int i;

	for (i=0;i<m->numml;i++) {
		if (m->ml[i]->textlen)
			free(m->ml[i]->text);
		if (m->ml[i]->promptlen)
			free(m->ml[i]->prompt);
		if (m->ml[i]->helplen)
			free(m->ml[i]->help);
		free(m->ml[i]);
	}
	free(m->ml);
	for (i=0;i<m->nummh;i++) {
		if (m->mh[i]->textlen)
			free(m->mh[i]->text);
		free(m->mh[i]);
	}
	free(m->mh);
	if (flag) G_cursize=sizeof(display);
}

void freefrm(form *f,char flag) {
	int i,j,k,l;

	for (i=0;i<f->noscrn;i++) {
		for (j=0;j<f->scrn[i]->nofld;j++) {
			for (k=0;k<f->scrn[i]->fld[j]->nolnks;k++) {
				if (f->scrn[i]->fld[j]->lnk[k]->val_ex) {
					if (f->scrn[i]->fld[j]->lnk[k]->val->rflen)
						free(f->scrn[i]->fld[j]->lnk[k]->val->rng_fmt);
					if (f->scrn[i]->fld[j]->lnk[k]->val->vflen)
						free(f->scrn[i]->fld[j]->lnk[k]->val->vld_fmt);
					if (f->scrn[i]->fld[j]->lnk[k]->val->sflen)
						free(f->scrn[i]->fld[j]->lnk[k]->val->scf_fmt);
					if (f->scrn[i]->fld[j]->lnk[k]->val->pflen)
						free(f->scrn[i]->fld[j]->lnk[k]->val->prf_fmt);
					if (f->scrn[i]->fld[j]->lnk[k]->val->errlen)
						free(f->scrn[i]->fld[j]->lnk[k]->val->errstr);
					free(f->scrn[i]->fld[j]->lnk[k]->val);
				}
				for(l=0;l<f->scrn[i]->fld[j]->lnk[k]->numopt;l++) {
					if (f->scrn[i]->fld[j]->lnk[k]->op[l]->textlen)
						free(f->scrn[i]->fld[j]->lnk[k]->op[l]->text);
					free(f->scrn[i]->fld[j]->lnk[k]->op[l]);
				}
				free(f->scrn[i]->fld[j]->lnk[k]->op);
				free(f->scrn[i]->fld[j]->lnk[k]);
			}
			free(f->scrn[i]->fld[j]->lnk);
			if (f->scrn[i]->fld[j]->deflen)
				free(f->scrn[i]->fld[j]->deftext);
			if (f->scrn[i]->fld[j]->textlen)
				free(f->scrn[i]->fld[j]->text);
			for (k=0;k<f->scrn[i]->fld[j]->nohelp;k++) {
				if (f->scrn[i]->fld[j]->eh[k]->helplen)
					free(f->scrn[i]->fld[j]->eh[k]->help);
				free(f->scrn[i]->fld[j]->eh[k]);
			}
			free(f->scrn[i]->fld[j]->eh);
			free(f->scrn[i]->fld[j]);
		}
		free(f->scrn[i]->fld);
		free(f->scrn[i]);
	}
	free(f->scrn);
	if (flag) G_cursize=sizeof(display);
}
