#include <stdio.h>
#include <graphics.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include "tdef.h"
#include "tdrep.h"
#include "tdrepval.h"

void buildrptfile( FILE *fp);
long int locatereport( FILE *fp);
struct com *add_lf(struct com *curcom, int inhead);
struct com *inlist( struct com *newcom,int inhead,int xpos,int ypos, struct com *curcom);
int get_call( struct com *cmd, FILE *fp, int bytesrem);
void renamerpt( char *oldname, char *newname);
void print_padding( FILE *fp, int cxp, int cyp, int nxp, int nyp);
void print_section( FILE *fp, struct com *startcom, struct com *starttext, struct text *startt, int yporig);
void report_err( int code);
void draw_savemsg(char *msg);
struct fld_spec *get_spec( FILE *fp);
char *set_code( int code);
struct param *getparm( struct com *cmd, struct param *curparm);
int fgeti( FILE *fp);
void fputi( int i, FILE *fp);
void fputl( long l, FILE *fp);
long fgetl( FILE *fp);
void fputf( char *str, FILE *fp);
char *fgetf( FILE *fp);
int get_parm( int pch, struct com *cmd, FILE *fp, int bytesrem);
int got_command( FILE *fp, int ch, struct com **com, int bytesrem, int inhead);
int got_text( FILE *fp, int ch, struct text **txt, int bytesrem);
int save_text( struct text *txt, FILE *fp);
void freeorder( struct order *ord);
void add_padding( FILE *fp, int cxp, int cyp, int nxp, int nyp);
struct order *order_com( struct com *cmd, int yporig);
struct order *order_txt( struct text *txt, int yporig);
int save_command( struct com *curr, FILE *fp);
struct param *save_parm( struct param *parm, FILE *fp);
int get_flags( struct fld_spec *spec);
void filerr(char *name);
void write_section( FILE *fp, struct com *startcom, struct com *starttext, struct text *startt, int yporig);
void get_section( FILE *fp, struct com **startcom, struct com **starttext, struct text **startt, int yporig, int ypend, int seclines);

extern struct commands G_cmds[];
extern int w;
extern int G_ypstart;
extern int G_yphead;
extern int G_ypmain;
extern int G_ypfoot;
extern int const codes[];
extern char G_choice[100];
extern struct com *G_comFILES;			/* the reports FILES command */
extern struct com *G_comRANGE;  		/* the RANGE command */
extern struct com *G_comSORT;			/* the SORT command */
extern struct com *G_headcom; 			/* commands in the header command bar */
extern struct com *G_maincom;          /*   "		"	   main */
extern struct com *G_footcom;          /*   "		"      footer */
extern struct com *G_headtext;         /* header window commands */
extern struct com *G_maintext;         /* main window */
extern struct com *G_foottext;         /* footer window */
extern struct com *G_cur_text;         /* current text item*/
extern struct text *G_headt;			/* text items in the header window */
extern struct text *G_maint;			/* text items in the main window */
extern struct text *G_foott;			/* text items in the foot window */
extern struct text *G_curt;			/* current text item */


void save_rep(void)
{
FILE *fp;
char name[20];
int i;

if( !G_dongin)
	return;

draw_savemsg("SAVING FILE");
if( strlen( G_choice)>8){
	strncpy( name, G_choice, 8);
	strcpy( &name[8], ".rep");
}
else{
	strcpy( name, G_choice);
	strcat( name, ".rep");
}
i=-1;
while( name[++i]!=0)
	if( name[i]==' ')
		name[i]='_';

if( (fp=fopen( name, "w+b"))==NULL){
	unlink( name);
	if( (fp=fopen( name, "w+b"))==NULL){
		filerr(name);
		return;
	}
}
fputi( strlen( G_choice), fp);
fputs( G_choice, fp);
write_section( fp, G_headcom, G_headtext, G_headt, G_ypstart);
write_section( fp, G_maincom, G_maintext, G_maint, G_yphead+12);
write_section( fp, G_footcom, G_foottext, G_foott, G_ypmain+12);

buildrptfile( fp);
fclose(fp);
return;
}

void load_rep(void)
{
FILE *fp;
char name[20];
long pos;

sprintf( name,"%s.rpt", G_cellname);

if( (fp=fopen( name, "r+b"))==NULL){
	if( errno!=2)
		filerr(name);
	return;
}

if( (pos=locatereport( fp))== -1L){
	fclose(fp);
	return;
}
fseek( fp, pos, SEEK_SET);
get_section( fp, &G_headcom, &G_headtext, &G_headt, G_ypstart+1, G_yphead, 9);
get_section( fp, &G_maincom, &G_maintext, &G_maint, G_yphead+12, G_ypmain, 10);
get_section( fp, &G_footcom, &G_foottext, &G_foott, G_ypmain+12, G_ypfoot, 7);

fclose( fp);
}

void write_section( FILE *fp, struct com *startcom, struct com *starttext, struct text *startt, int yporig)
{
long start, current;
int count=0;
int length, cxp, cyp;
struct com *curr;
struct order *ordcom, *ordtxt, *curcom, *curtxt;

start=ftell( fp);
fputi( count, fp);
curr=startcom;
while( curr!=0){
	length=save_command( curr, fp);
	curr=curr->next;
}
if( starttext==0)
	ordcom=0;
else
	ordcom=order_com( starttext, yporig);
if( startt==0)
	ordtxt=0;
else
	ordtxt=order_txt( startt, yporig);

curcom=ordcom;
curtxt=ordtxt;
cxp=0;
cyp=0;
while( curcom!=0 || curtxt!=0){
	if( curcom==0){
		add_padding( fp, cxp, cyp, curtxt->xpos, curtxt->ypos);
		length=save_text(curtxt->point, fp);
		cxp=curtxt->xpos+length;
		cyp=curtxt->ypos;
		curtxt=curtxt->next;
	}
	else if( curtxt==0){
		add_padding( fp, cxp, cyp, curcom->xpos, curcom->ypos);
		length=save_command( curcom->point, fp);
		cxp=curcom->xpos+length;
		cyp=curcom->ypos;
		curcom=curcom->next;
	}
	else if( curcom->yp<curtxt->yp || (curcom->yp==curtxt->yp&&curcom->xp<curtxt->xp)){
		add_padding( fp, cxp, cyp, curcom->xpos, curcom->ypos);
		length=save_command( curcom->point, fp);
		cxp=curcom->xpos+length;
		cyp=curcom->ypos;
		curcom=curcom->next;
	}
	else{
		add_padding( fp, cxp, cyp, curtxt->xpos, curtxt->ypos);
		length=save_text( curtxt->point, fp);
		cxp=curtxt->xpos+length;
		cyp=curtxt->ypos;
		curtxt=curtxt->next;
	}
}


count=(int) (ftell(fp)-start-2);
current=ftell( fp);
fseek( fp, start, SEEK_SET);
fputi( count, fp);
fseek( fp, current, SEEK_SET);
freeorder( ordcom);
freeorder( ordtxt);
}

void filerr(char *name)
{
char text[60];
mousecur(0);
setfillstyle( 1, BLACK);
settextjustify( CENTER_TEXT, TOP_TEXT);
setcolor( YELLOW);
bar( 100, 180, 400, 265);
rectangle( 100, 180, 400, 265);
rectangle( 190, 185, 310, 206);
outtextxy( 250, 190, "FILE ACCESS ERROR");
setcolor( LIGHTCYAN);
sprintf( text, "FILE %s ERROR %d", name, errno);
outtextxy( 250, 214, text);
button(250,240,"OK",0,0);
mousecur(1);
while( 1){
	if( mousetrap(5)){
		if( mseb==1){
			if( inbox(225,250,275,280)){
				mousecur(0);
				button(250, 240, "OK", 1, 1);
				mousecur(1);
				setfillstyle( 1, BLUE);
				setcolor( YELLOW);
				settextjustify( LEFT_TEXT, TOP_TEXT);
				return;
			}
			while( mseb) mousetrap(5);
		}
	}
}
}

int get_flags( struct fld_spec *spec)
{
int flags=0;

switch( spec->type){
	case 1:
		flags += 0x1;
		break;
	case 2:
		flags += 0x2;
		break;
	case 3:
		flags += 0x3;
		break;
	case 4:
		flags += 0x4;
		break;
	default:
		break;
}
switch( spec->just){
	case 1:
		flags += 0x8;
		break;
	case 2:
		flags += 0x10;
		break;
	default:
		break;
}
switch( spec->padding){
	case 1:
		flags += 0x20;
		break;
	default:
		break;
}
switch( spec->zero){
	case 1:
		flags += 0x40;
		break;
	default:
		break;
}
switch( spec->attr){
	case 1:
		flags += 0x80;
		break;
	case 2:
		flags += 0x100;
		break;
	case 3:
		flags += 0x200;
		break;
	default:
		break;
}
return(flags);
}

struct param *save_parm( struct param *parm, FILE *fp)
{
struct param *curr;
int i,j,len;
long l;

curr=parm;
if( curr->soe==1)
	fputc( EXPR_VAL, fp);
if( curr->code==OPERATOR){
	fputc( OP_VAL, fp);
	for(i=0;i<1000;i++);
	fputc( curr->typecode, fp);
	return( curr->next);
}
if( curr->code==FILEP){
	fputc( FNO_VAL, fp);
	for(i=0; i<G_file.nofiles ;i++){
		if( strcmp( curr->text, G_file.files[i])==0){
			fputc( i+1, fp);
			return( curr->next);
		}
	}
	fputc( 0, fp);
	return( curr->next);
}
if( curr->code==FFIELD){
	if( sscanf( curr->text,"%d",&i)==1){
		fputc( FFIELD_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==KNO){
	if( sscanf( curr->text,"%d",&i)==1){
		fputc( KNO_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==SDIREC){
	if( sscanf( curr->text,"%d",&i)==1){
		fputc( SDIREC_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==FIELD){
	fputc( FSPEC_VAL, fp);
	for(i=0; i<G_file.nofiles ;i++){
		len=strlen( G_file.files[i]);
		if( strncmp( curr->text, G_file.files[i], len)==0){
			for( j=0; j<G_file.cont[i]->nofld; j++){
				if( strcmp( &(curr->text[len+1]), G_file.cont[i]->flds[j]->name)==0){
					fputc( i+1, fp);
					fputc( j, fp);
					return( curr->next);
				}
			}
		}
	}
	fputc( 1, fp);
	fputc( 1, fp);
	return( curr->next);
}
if( curr->code==CONST){
	fputc( CONST_VAL, fp);
	fputc( curr->typecode, fp);
	if( curr->typecode==C_INT){
		sscanf( curr->text, "%d", &i);
		fputi( i, fp);
	}
	else if( curr->typecode==C_TEXT){
		if( strcmp( curr->text, "\"\"")!=0)
			fwrite(curr->text, sizeof( char), strlen( curr->text), fp);
		fputc( NOOP_VAL, fp);
	}
	else if( curr->typecode==C_LONG){
		sscanf( curr->text, "%ld", &l);
		fputl( l, fp);
	}
	else if( curr->typecode==C_FLOAT){
		fputf( curr->text, fp);
	}
	else{
		/*** revise for other CONST types ***/
		fwrite(curr->text, sizeof( char), strlen( curr->text), fp);
		fputc( NOOP_VAL, fp);
	}
	return( curr->next);
}
if( curr->code==LITER){
	/* ignore LITER types */
	return( curr->next);
}
if( curr->code==PARM){
	if( sscanf( curr->text,"p%d",&i)==1 || sscanf( curr->text, "P%d", &i)==1){
		fputc( PARM_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==IFNO){
	if( sscanf( curr->text,"%d",&i)==1){
		fputc( IFNO_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==VSPEC){
	if( sscanf( curr->text,"v%d",&i)==1 || sscanf( curr->text, "V%d", &i)==1){
		fputc( VSPEC_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==TSP){
	if( sscanf( curr->text,"t%d",&i)==1 || sscanf( curr->text,"T%d",&i)==1){
		fputc( TSPEC_VAL, fp);
		fputc( i, fp);
	}
	return( curr->next);
}
if( curr->code==TSPEC){
	if( sscanf( curr->text,"t%d.%d",&i,&j)==2 || sscanf( curr->text, "T%d.%d", &i,&j)==2){
		fputc( TSPEC_VAL, fp);
		fputc( i, fp);
		fputc( TNO_VAL, fp);
		fputc( j, fp);
	}
	return( curr->next);
}
return( curr->next);
}

int save_command( struct com *curr, FILE *fp)
{
int flags,i,nl;
struct param *parm;

fputc( curr->code, fp);
if( curr->code==codes[LF]){
	parm=curr->parm;
	if( parm!=0){
		sscanf( parm->text, "%d", &nl);
		for(i=1;i<nl;i++)
			fputc( curr->code, fp);
	}
	fputc( NOOP_VAL, fp);
	return( strlen( curr->text)*w);
 }
if( curr->code==codes[CALL]){
	if( curr->parm!=0)
		fwrite(curr->parm->text, sizeof( char), strlen( curr->parm->text), fp);
	fputc( NOOP_VAL, fp);
	return( strlen( curr->text)*w);
}
if( curr->spec!=0) {
	if( curr->code==codes[EXPR]){
		flags=get_flags( curr->spec);
		fputc( FLDSPC_VAL, fp);
		fputi( flags, fp);
		fputc( curr->spec->width, fp);
		fputc( curr->spec->dec_width, fp);
	}
}
parm=curr->parm;
while( parm!=0)
	parm=save_parm( parm, fp);
if( curr->spec!=0) {
	if( curr->code==codes[TOTALS] || curr->code==codes[FNAMEOF] || curr->code==codes[NAMEOF] ){
		flags=get_flags( curr->spec);
		fputc( FLDSPC_VAL, fp);
		fputi( flags, fp);
		fputc( curr->spec->width, fp);
		fputc( curr->spec->dec_width, fp);
	}
}
fputc(0,fp);
return( strlen( curr->text)*w);

}

struct order *order_com( struct com *cmd, int yporig)
{
struct order *head=0, *curord=0, *foot=0, *neword;
struct com *curcmd;
int placed;

curcmd=cmd;
while( curcmd!=0){
	neword=(struct order *)malloc( sizeof(struct order));
	neword->point=curcmd;
	neword->xpos=curcmd->xscr-16;
	neword->ypos=curcmd->yscr-yporig;
	neword->xp=(curcmd->xscr-16)/w;
	neword->yp=(curcmd->yscr-yporig+5)/11;
	if( head==0){
		head=neword;
		foot=neword;
		neword->next=0;
		neword->prev=0;
		curcmd=curcmd->next;
	}
	else{
		curord=head;
		placed=0;
		while( !placed && curord!=0){
			if(neword->yp<curord->yp||(neword->yp==curord->yp&&neword->xp<curord->xp)){
				if( curord==head){
					neword->prev=0;
					neword->next=curord;
					curord->prev=neword;
					head=neword;
				}
				else{
					neword->prev=curord->prev;
					neword->next=curord;
					curord->prev=neword;
					if( neword->prev!=0)
						neword->prev->next=neword;
				}
				placed=1;
			}
			curord=curord->next;
		}
		if(!placed){
			neword->prev=foot;
			foot->next=neword;
			neword->next=0;
			foot=neword;
		}
		curcmd=curcmd->next;
	}
}
return( head);
}

struct order *order_txt( struct text *txt, int yporig)
{
struct order *head=0, *curord=0, *foot=0, *neword;
struct text *curtext;
int placed;

curtext=txt;
while( curtext!=0){
	neword=(struct order *)malloc( sizeof(struct order));
	neword->point=curtext;
	neword->xpos=curtext->xpos-16;
	neword->ypos=curtext->ypos-yporig;
	neword->xp=(curtext->xpos-16)/w;
	neword->yp=(curtext->ypos-yporig+5)/11;
	if( head==0){
		head=neword;
		foot=neword;
		neword->next=0;
		neword->prev=0;
		curtext=curtext->next;
	}
	else{
		curord=head;
		placed=0;
		while( !placed && curord!=0){
			if(neword->yp<curord->yp||(neword->yp==curord->yp&&neword->xp<curord->xp)){
				if( curord==head){
					neword->prev=0;
					neword->next=curord;
					curord->prev=neword;
					head=neword;
				}
				else{
					neword->prev=curord->prev;
					neword->next=curord;
					curord->prev=neword;
					if( neword->prev!=0)
						neword->prev->next=neword;
				}
				placed=1;
			}
			curord=curord->next;
		}
		if(!placed){
			neword->prev=foot;
			foot->next=neword;
			neword->next=0;
			foot=neword;
		}
		curtext=curtext->next;
	}
}
return( head);
}

void add_padding( FILE *fp, int cxp, int cyp, int nxp, int nyp)
{
int i,j;

/*fputc( 0, fp);*/
i=(nyp-cyp+5)/11;
for(j=0;j<i;j++)
	fputc( 10, fp);
if( i>0){
	for(j=0;j<(nxp/w);j++)
		fputc( ' ', fp);
}
else{
	i=(nxp-cxp)/w;
	for(j=0;j<i;j++)
		fputc( ' ', fp);
}
if( i>0)
	fputc( NOOP_VAL, fp);
}

void freeorder( struct order *ord)
{
struct order *point;

while(ord!=0){
	point=ord->next;
	free( ord);
	ord=point;
}
}

int save_text( struct text *txt, FILE *fp)
{
fwrite( txt->text, sizeof( char), strlen(txt->text), fp);
fputc( NOOP_VAL, fp);
return( strlen( txt->text)*w);
}

void get_section( FILE *fp, struct com **startcom, struct com **starttext, struct text **startt, int yporig, int ypend, int seclines)
{
struct com *headcom=0, *headtext=0;
struct com *curcom=0, *newcom=0;
struct text *headt=0, *newtxt=0, *curtxt=0;
int length, count=0;
int inhead, ch,nblines=0,newline=0;
int curx=0, cury=0;

inhead=1;
length=fgeti( fp);
while( count<length) {
	ch=0xff&fgetc( fp);
	count++;
	if( ch==0x0c || (ch>=0x80 && ch<=0xff)){
		count=count+got_command( fp, ch, &newcom, length-count, inhead);
		newline=0;
		if( inhead && newcom->spec!=0)
			inhead=0;
		if( inhead){
			if( headcom==0)
				headcom=inlist( newcom, inhead, curx, cury+yporig, 0);
			else
				newcom=inlist( newcom, inhead, curx, cury+yporig, curcom);
		}
		else{
			if( headtext==0)
				headtext=inlist( newcom, inhead, curx, cury+yporig, 0);
			else
				newcom=inlist( newcom, inhead, curx, cury+yporig, curcom);
			curx=curx+strlen( newcom->text)*w;
			if( curx>(80*w)-strlen( newcom->text)*w)
				curx=80*w-strlen( newcom->text)*w;
		}
		curcom=newcom;
	}
	else if(ch!=0){
		/* is text */
		inhead=0;
		if( isspace( ch)){
			if( ch==10){
				nblines++;
				newline++;
				if( nblines>seclines){
					newcom=add_lf(curcom, inhead);
					if( newcom!=curcom){
						if( headtext==0)
							headtext=inlist( newcom, inhead, curx, cury+yporig, 0);
						else
							newcom=inlist( newcom, inhead, curx, cury+yporig, curcom);
						curcom=newcom;
						curx=curx+strlen( newcom->text)*w;
						if( curx>(80*w)-strlen( newcom->text)*w)
							curx=80*w-strlen( newcom->text)*w;
					}
				}
				else{
					curx=0;
					cury=cury+11;
					if( cury>ypend)
						cury=ypend;
				}
			}
			else{
				curx=curx+w;
			}
		}
		else{
			count=count+got_text( fp, ch, &newtxt, length-count);
			newline=0;
			/* link in to headt list */
			if( headt==0){
				headt=newtxt;
				curtxt=newtxt;
			}
			else{
				curtxt->next=newtxt;
				newtxt->prev=curtxt;
				curtxt=newtxt;
			}
			newtxt->xpos=curx+16;
			if( newtxt->xpos<18)
				newtxt->xpos=18;
			if( newtxt->xpos+strlen(newtxt->text)*w>18+(80*w))
				newtxt->xpos=18+(80*w)-strlen(newtxt->text)*w;
			curx=curx+strlen( newtxt->text)*w;
			newtxt->ypos=cury+yporig;
			if( curx>(80*w))
				curx=80*w;
		}
	}
}
*startcom=headcom;
*starttext=headtext;
*startt=headt;
return;
}

int got_command( FILE *fp, int ch, struct com **newcom, int bytesrem, int inhead)
{
char temp[50];
struct com *cmd;
int i=0, count=0, pch;
int found=0;

while( !found && i<NBCMDS)
	if( ch==codes[i])
		found=1;
	else
		i++;

cmd=(struct com *)malloc(sizeof( struct com));
*newcom=cmd;
if( found){
	cmd->code=codes[i];
	cmd->prev=0;
	cmd->next=0;
	cmd->spec=0;
	cmd->parm=0;
	cmd->text=0;
	cmd->ctext=G_cmds[i].text;
}
else{
	cmd->code=0;
	cmd->prev=0;
	cmd->next=0;
	cmd->spec=0;
	cmd->parm=0;
	cmd->text=0;
	strcpy(temp, "<ERROR>");
	cmd->text=(char *)malloc(strlen(temp)+1);
	strcpy(cmd->text,temp);
}
if( bytesrem<=0){
	gen_cmdtext( cmd, inhead);
	return(0);
}
if( cmd->code==codes[CALL]){
	count=get_call( cmd, fp, bytesrem);
	gen_cmdtext( cmd, inhead);
	return(count);
}
pch=0xff&fgetc(fp);
if( (pch<=0x1f && pch>=0x1) || (pch>=0x80 && pch<=0xff))
	count=1+get_parm( pch, cmd, fp, bytesrem-1);
else
	ungetc( pch, fp);
gen_cmdtext( cmd, inhead);
return(count);
}

int got_text( FILE *fp, int ch, struct text **txt, int bytesrem)
{
int count=0;
int inch;
struct text *newtxt;
char str[100];

newtxt=(struct text *)malloc(sizeof( struct text));
newtxt->prev=0;
newtxt->next=0;
*txt=newtxt;

str[count++]=ch;
while( count<99 && bytesrem-count>=0){
	inch=getc( fp);
	if( (inch<=0x1f && inch>=0x1) || (inch>=0x80 && inch<=0xff) || inch<=0){
		ungetc( inch, fp);
		str[count]=0;
		newtxt->text=(char *)malloc(strlen(str)+1);
		strcpy( newtxt->text, str);
		return( count-1);
	}
	str[count++]=inch;
}
str[count]=0;
newtxt->text=(char *)malloc(strlen(str)+1);
strcpy( newtxt->text, str);
return( count-1);
}

int get_parm( int pch, struct com *cmd, FILE *fp, int bytesrem)
{
int ch, ch1;
int soe=0;
int count=0;
int i;
struct param *curparm=0;
char str[100];

ch=pch;
while( 1){
	switch( ch){
		case FFIELD_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=FFIELD;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case OP_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=OPERATOR;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			curparm->typecode=ch;
			curparm->text=set_code( ch);
			break;
		case FNO_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=FILEP;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			if( ch>=1 && ch <=G_file.nofiles){
				curparm->text=(char *)malloc(strlen(G_file.files[ch-1])+1);
				strcpy( curparm->text, G_file.files[ch-1]);
			}
			break;
		case FSPEC_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=FIELD;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			ch1=0xff&fgetc( fp);
			count++;
			if( ch>=1 && ch <=G_file.nofiles){
				if(ch1>=0 && ch1<G_file.cont[ch-1]->nofld){
					strcpy( str, G_file.files[ch-1]);
					strcat( str, ".");
					strcat( str, G_file.cont[ch-1]->flds[ch1]->name);
					curparm->text=(char *)malloc(strlen(str)+1);
					strcpy( curparm->text, str);
				}
			}
			break;
		case CONST_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=CONST;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			curparm->typecode=ch;
			count++;
			switch( ch){
				case C_INT:
					sprintf( str, "%d", fgeti( fp));
					curparm->text=(char *)malloc(strlen(str)+1);
					strcpy( curparm->text, str);
					count=count+2;
					break;
				case C_LONG:
					sprintf( str, "%ld", fgetl( fp));
					curparm->text=(char *)malloc(strlen(str)+1);
					strcpy( curparm->text, str);
					count=count+4;
					break;
				case C_FLOAT:
					curparm->text=fgetf( fp);
					count=count+6;
					break;
				case C_DOUBLE:
				case C_TEXT:
					i=0;
					while( i<99 && (ch=fgetc(fp))!=0){
						str[i++]=ch;
						count++;
					}
					if( ch==0)
						count++;
					if( i!=0)
						str[i]=0;
					else
						strcpy( str, "\"\"");
					curparm->text=(char *)malloc(strlen(str)+1);
					strcpy( curparm->text, str);
					break;
				default:
					break;
			}
			break;
		case PARM_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=PARM;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "P%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case LITER:
			/* ignore LITER types */
			break;
		case IFNO_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=IFNO;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case VSPEC_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=VSPEC;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "V%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case TSPEC_VAL:
			curparm=getparm( cmd, curparm);
			curparm->soe=soe;
			soe=0;
			ch1=0xff&fgetc( fp);
			count++;
			ch=0xff&fgetc( fp);
			count++;
			if( ch==TNO_VAL){
				curparm->code=TSPEC;
				ch=0xff&fgetc( fp);
				count++;
				sprintf( str, "T%d.%d", ch1, ch);
			}
			else{
				curparm->code=TSP;
				ungetc( ch, fp);
				count--;
				sprintf( str, "T%d", ch1);
			}
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case FLDSPC_VAL:
			cmd->spec=get_spec( fp);
			count=count+4;
			break;
		case KNO_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=KNO;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case SDIREC_VAL:
			curparm=getparm( cmd, curparm);
			curparm->code=SDIREC;
			curparm->soe=soe;
			soe=0;
			ch=0xff&fgetc( fp);
			count++;
			sprintf( str, "%d", ch);
			curparm->text=(char *)malloc(strlen(str)+1);
			strcpy( curparm->text, str);
			break;
		case EXPR_VAL:
			soe=1;
			break;
		default:
			break;
	}
	if( bytesrem-count<0){
		fseek( fp, (long) bytesrem-count, SEEK_CUR);
		return(bytesrem);
	}
	if( bytesrem-count==0)
		return(count);
	ch=getc(fp);
	count++;
	if( ch<=0x80 ){
		ungetc( ch, fp);
		return(count-1);
	}
}
}

void fputi( int i, FILE *fp)
{
fputc( (i>>8)&0xff, fp);
fputc( i, fp);
}
int fgeti( FILE *fp)
{
return(((0xff&fgetc(fp))<<8)+(0xff&fgetc( fp)));
}

struct param *getparm( struct com *cmd, struct param *curparm)
{
struct param *parm;

parm=(struct param *)malloc(sizeof(struct param));
if( cmd->parm==0)
	cmd->parm=parm;
parm->next=0;
parm->prev=curparm;
parm->text=0;
parm->soe=0;
if( curparm!=0)
	curparm->next=parm;
return( parm);
}

char *set_code( int code)
{
char *txt;

txt=(char *)malloc(3);
switch( code){
	case O_eq:
		strcpy( txt, "=");
		return( txt);
	case O_gt:
		strcpy( txt, ">");
		return( txt);
	case O_lt:
		strcpy( txt, "<");
		return( txt);
	case O_nt:
		strcpy( txt, "!");
		return( txt);
	case O_pl:
		strcpy( txt, "+");
		return( txt);
	case O_mi:
		strcpy( txt, "-");
		return( txt);
	case O_ml:
		strcpy( txt, "*");
		return( txt);
	case O_dv:
		strcpy( txt, "/");
		return( txt);
	case O_pc:
		strcpy( txt, "%");
		return( txt);
	case O_ob:
		strcpy( txt, "(");
		return( txt);
	case O_cb:
		strcpy( txt, ")");
		return( txt);
	case O_ne:
		strcpy( txt, "<>");
		return( txt);
	case O_le:
		strcpy( txt, "<=");
		return( txt);
	case O_ge:
		strcpy( txt, ">=");
		return( txt);
	case O_lo:
		strcpy( txt, "||");
		return( txt);
	case O_la:
		strcpy( txt, "&&");
		return( txt);
	case O_bo:
		strcpy( txt, "|");
		return( txt);
	case O_ba:
		strcpy( txt, "&");
		return( txt);
	case O_ca:
		strcpy( txt, "~");
		return( txt);
	default:
		return(0);
}
}

struct fld_spec *get_spec( FILE *fp)
{
int flags;
struct fld_spec *spec;

flags=fgeti( fp);
spec=(struct fld_spec *)malloc( sizeof(struct fld_spec));
spec->type=0;
spec->just=0;
spec->padding=0;
spec->zero=0;
spec->attr=0;

if( flags&0x4)
	spec->type=4;
else if( flags&0x3)
	spec->type=3;
else if( flags&0x2)
	spec->type=2;
else if( flags&0x1)
	spec->type=1;

if( flags&0x10)
	spec->just=2;
else if( flags&0x8)
	spec->just=1;

if( flags&0x20)
	spec->padding=1;

if( flags&0x40)
	spec->zero=1;

if( flags&0x200)
	spec->attr=3;
else if( flags&0x100)
	spec->attr=2;
else if( flags&0x80)
	spec->attr=1;

spec->width=0xff&fgetc( fp);
spec->dec_width=0xff&fgetc( fp);

return( spec);
}

void draw_savemsg(char *msg)
{
mousecur(0);
settextjustify( CENTER_TEXT, TOP_TEXT);
setfillstyle( 1, BLACK);
setcolor( YELLOW);
bar( 100, 180, 400, 240);
rectangle( 100, 180, 400, 240);
rectangle( 200, 185, 300, 206);
outtextxy( 250, 190, msg);
setcolor( LIGHTCYAN);
outtextxy( 250, 214, "Please Wait");
settextjustify( LEFT_TEXT, TOP_TEXT);
mousecur(1);
}

int save_request(void)
{
mousecur(0);
setfillstyle( 1, BLUE);
settextjustify( CENTER_TEXT, TOP_TEXT);
setcolor( YELLOW);
bar( 100, 180, 400, 265);
rectangle( 100, 180, 400, 265);
rectangle( 187, 185, 313, 206);
rectangle( 185, 183, 315, 208);
outtextxy( 250, 190, "Do You Wish To Save?");
button(200,240,"YES",0,0);
button(300,240,"NO",0,0);
mousecur(1);
while( 1){
	if( mousetrap(5)){
		if( mseb==1){
			if( inbox(175,250,225,280)){
				mousecur(0);
				button(200, 240, "YES", 1, 1);
				mousecur(1);
				setfillstyle( 1, BLUE);
				setcolor( YELLOW);
				if( oktosave()){
					save_rep();
					draw_reportwin(G_choice);
					setfillstyle(1,11);
					setcolor(YELLOW);
					settextjustify( LEFT_TEXT, TOP_TEXT);
					return(1);
				}
				else{
					draw_reportwin(G_choice);
					setfillstyle(1,11);
					setcolor(YELLOW);
					settextjustify( LEFT_TEXT, TOP_TEXT);
					return(0);
				}
			}
			if( inbox(275,250,325,280)){
				mousecur(0);
				button(300, 240, "NO", 1, 1);
				mousecur(1);
				draw_reportwin(G_choice);
				setfillstyle( 1, BLUE);
				setcolor( YELLOW);
				settextjustify( LEFT_TEXT, TOP_TEXT);
				return(1);
			}
			while( mseb) mousetrap(5);
		}
	}
}
}
int oktosave(void)
{
/* count FILES, SORT, RANGE commands */
int nbfiles=0, nbsort=0, nbrange=0;
struct com *cmd;

cmd=G_headcom;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
cmd=G_maincom;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
cmd=G_footcom;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
cmd=G_headtext;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
cmd=G_maintext;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
cmd=G_foottext;
while( cmd!=0){
	if( cmd->code==codes[FILES])
		nbfiles++;
	if( cmd->code==codes[SORT])
		nbsort++;
	if( cmd->code==codes[RANGE])
		nbrange++;
	cmd=cmd->next;
}
if( nbfiles>1){
	report_err(0);
	return(0);
}
if( nbrange>1){
	report_err(2);
	return(0);
}
if( nbsort>1){
	report_err(3);
	return(0);
}
return(1);
}

void report_err( int code)
{

static char *errtext[4]={"Too Many FILES Commands (One Only Allowed)",
						"No FILES Command In Report (Report Must Have One)",
						"Too Many RANGE Commands (One Only Allowed)",
						"Too Many SORT Commands (One Only Allowed)" };

mousecur(0);
setfillstyle( 1, BLACK);
settextjustify( CENTER_TEXT, TOP_TEXT);
setcolor( YELLOW);
bar( 100, 180, 400, 265);
rectangle( 100, 180, 400, 265);
rectangle( 210, 185, 290, 206);
outtextxy( 250, 190, "REPORT ERROR");
setcolor( LIGHTCYAN);
outtextxy( 250, 214, errtext[code]);
button(250,240,"OK",0,0);
mousecur(1);
while( 1){
	if( mousetrap(5)){
		if( mseb==1){
			if( inbox(225,250,275,280)){
				mousecur(0);
				button(250, 240, "OK", 1 ,1);
				mousecur(1);
				setfillstyle( 1, BLUE);
				setcolor( YELLOW);
				settextjustify( LEFT_TEXT, TOP_TEXT);
				return;
			}
			while( mseb) mousetrap(5);
		}
	}
}

}

void print_report(void)
{
FILE *fp;

draw_savemsg("PRINTING REPORT");
if( (fp=fopen( "prn", "w"))==NULL){
	filerr("printer");
	return;
}
fprintf(fp, "\n\n\n\t\t\tReport Configuration For Report: %s\n",G_choice);
fprintf(fp, "\nHEAD\n\n");
print_section( fp, G_headcom, G_headtext, G_headt, G_ypstart);
fprintf(fp, "\nMAIN\n\n");
print_section( fp, G_maincom, G_maintext, G_maint, G_yphead+12);
fprintf(fp, "\nFOOT\n\n");
print_section( fp, G_footcom, G_foottext, G_foott, G_ypmain+12);
fprintf(fp, "\n\n\n\t\t\tEnd Of Report Configuration\f");

fclose(fp);
return;


}
void print_section( FILE *fp, struct com *startcom, struct com *starttext, struct text *startt, int yporig)
{
int length, cxp, cyp;
struct com *curr;
struct order *ordcom, *ordtxt, *curcom, *curtxt;

curr=startcom;
while( curr!=0){
	gen_cmdtext( curr, 2);
	fprintf( fp, "%s\n", curr->text);
	gen_cmdtext( curr, 1);
	curr=curr->next;
}
if( starttext==0)
	ordcom=0;
else
	ordcom=order_com( starttext, yporig);
if( startt==0)
	ordtxt=0;
else
	ordtxt=order_txt( startt, yporig);

curcom=ordcom;
curtxt=ordtxt;
cxp=0;
cyp=0;
while( curcom!=0 || curtxt!=0){
	if( curcom==0){
		print_padding( fp, cxp, cyp, curtxt->xpos, curtxt->ypos);
		length=fprintf( fp, "%s", ((struct text *)(curtxt->point))->text);
		cxp=curtxt->xpos+length;
		cyp=curtxt->ypos;
		curtxt=curtxt->next;
	}
	else if( curtxt==0){
		print_padding( fp, cxp, cyp, curcom->xpos, curcom->ypos);
		gen_cmdtext( curcom->point, 0);
		length=fprintf( fp, "%s", ((struct com *)(curcom->point))->text);
		cxp=curcom->xpos+length;
		cyp=curcom->ypos;
		curcom=curcom->next;
	}
	else if( curcom->ypos<curtxt->ypos || (curcom->ypos==curtxt->ypos&&curcom->xpos<curtxt->xpos)){
		print_padding( fp, cxp, cyp, curcom->xpos, curcom->ypos);
		gen_cmdtext( curcom->point, 0);
		length=fprintf( fp, "%s", ((struct com *)(curcom->point))->text);
		cxp=curcom->xpos+length;
		cyp=curcom->ypos;
		curcom=curcom->next;
	}
	else{
		print_padding( fp, cxp, cyp, curtxt->xpos, curtxt->ypos);
		length=fprintf( fp, "%s", ((struct text *)(curtxt->point))->text);
		cxp=curtxt->xpos+length;
		cyp=curtxt->ypos;
		curtxt=curtxt->next;
	}
}
freeorder( ordcom);
freeorder( ordtxt);
}

void gen_cmdtext( struct com *cmd, int isheader)
{
int maxlen, count;
struct param *parm;
int i;
char text[80];

if( isheader==1)
	maxlen=20;
else if( isheader==2)
	maxlen=79;
else
	if( cmd->spec!=0)
		maxlen=cmd->spec->width;
	else
		maxlen=79;

text[0]='<';
text[1]=0;
i=0;
while( i<NBCMDS && i>-1)
	if( codes[i]==cmd->code){
		strcat( text, G_cmds[i].text);
		i= -1;
	}
	else
		i++;

count=strlen(text);
text[count++]=' ';
text[count]=0;
parm=cmd->parm;
while( parm!=0 && count<maxlen){
	if( strlen(parm->text)+count>=maxlen){
		parm=0;
	}
	else{
		strcat( text, parm->text);
		count=count+strlen(parm->text);
		text[count++]=' ';
		text[count]=0;
		parm=parm->next;
	}
}
if( !isheader && cmd->spec!=0){
	if( cmd->spec->width<80){
		for( i=count; i<cmd->spec->width;i++)
			text[i]=' ';
		text[cmd->spec->width]='>';
		text[cmd->spec->width+1]=0;
	}
	else{
		for( i=count; i<79;i++)
			text[i]=' ';
		text[79]='>';
		text[80]=0;
	}
}
else{
	text[count-1]='>';
	text[count]=0;
}
/*cmd->xscr=cmd->xscr-textwidth(cmd->text)/2+textwidth(text)/2;*/
if( cmd->text!=0)
	free( cmd->text);
cmd->text=(char *)malloc( strlen(text)+1);
strcpy( cmd->text, text);
return;
}

void print_padding( FILE *fp, int cxp, int cyp, int nxp, int nyp)
{
int i,j;

i=nyp-cyp;
for(j=0;j<i;j++)
	fprintf(fp, "\n");
if( i>0){
	for(j=0;j<nxp;j++)
		fprintf( fp, " ");
}
else{
	i=nxp-cxp;
	for(j=0;j<i;j++)
		fprintf( fp, " ");
}
}

void fputl( long l, FILE *fp)
{
fputc( (char)(l>>24)&0xff, fp);
fputc( (char)(l>>16)&0xff, fp);
fputc( (char)(l>>8)&0xff, fp);
fputc( (char)l, fp);
}
long fgetl( FILE *fp)
{
long l=0;

l = fgetc(fp);
l = 256*l + fgetc(fp);
l = 256*l + fgetc(fp);
l = 256*l + fgetc( fp);

return(l);
}

void fputf( char *str, FILE *fp)
{
int i=0,j;
int exp;
long l;

while(i<strlen(str) && str[i]!='.')
	i++;
if( i==strlen(str)){
	exp=0;
	sscanf( str, "%ld", &l);
}
else{
	exp= -(strlen(str)-i-1);
	for(j=i+1; j<=strlen(str); j++)
		str[j-1]=str[j];
	sscanf( str, "%ld", &l);
}
fputl( l, fp);
fputi( exp, fp);
}

char *fgetf( FILE *fp)
{
char str[50], tmp[50], *text;
int exp, i;
long l;

l=fgetl( fp);
exp=fgeti( fp);

sprintf( str, "%ld", l);
if( exp>0){
	for(i=0; i<exp; i++) {
		sprintf( tmp, "%s0", str);
		strcpy( str, tmp);
	}
}
if( exp<0){
	i=strlen( str) + exp;
	strncpy( tmp, str, i);
	tmp[i]='.';
	strcpy( &(tmp[i+1]), &(str[i]));
	strcpy( str, tmp);
}
text=(char *)malloc( strlen(str)+1);
strcpy( text, str);
return( text);
}

void renamerpt( char *oldname, char *newname)
{
int rlen, slen, bytesleft, nread;
char buf[500];
char name[20];
int end=0;
FILE *ffp, *tfp;

if( (tfp=fopen( "tmprpt.rpt", "w+b"))==NULL){
	unlink( "tmprpt.rpt");
	if( (tfp=fopen( "tmprpt.rpt", "w+b"))==NULL){
		filerr("tmprpt.rpt");
		return;
	}
}
sprintf( name,"%s.rpt", G_cellname);
if( (ffp=fopen( name, "r+b"))==NULL){
	end=1;
}

while( !end){
	rlen=fgeti(ffp);
	slen=fgeti(ffp);
	if( slen>50 || slen<=0)
		end=1;
	else{
		nread=fread( buf, 1, slen, ffp);
		if( nread!=slen)
			end=1;
	}
	if( !end){
		if( strncmp( buf, oldname, slen)==0){
			rlen=rlen-slen;
			slen=strlen(newname);
			rlen=rlen+slen;
			fputi( rlen, tfp);
			fputi( slen, tfp);
			fwrite( newname, 1, slen, tfp);
		}
		else{
			fputi( rlen, tfp);
			fputi( slen, tfp);
			fwrite( buf, 1, slen, tfp);
		}
		bytesleft=rlen-slen-2;
		while( bytesleft>0){
			if((nread=fread( buf, 1, bytesleft, ffp))>0)
				fwrite( buf, 1, nread, tfp);
			else
				end=1;
			bytesleft=bytesleft-nread;
		}
	}
}
fclose(ffp);
if( (ffp=fopen( name, "w+b"))==NULL){
	unlink( name);
	if( (ffp=fopen( name, "w+b"))==NULL){
		filerr(name);
		return;
	}
}
fseek( tfp, 0, SEEK_SET);
while((nread=fread( buf, 1, 500, tfp))>0)
	fwrite( buf, 1, nread, ffp);
fclose(tfp);
fclose(ffp);
unlink( "tmprpt.rpt");
}


int get_call( struct com *cmd, FILE *fp, int bytesrem)
{
struct param *curparm=0;
int count=0, ch;
char str[100];

curparm=getparm( cmd, curparm);
curparm->code=CONST;
curparm->typecode=C_TEXT;
while(count<99 && bytesrem-count-2>=0){
	if( (ch=0xff&fgetc( fp))==0){
		ungetc( ch, fp);
		str[count]=0;
		curparm->text=(char *)malloc(strlen(str)+1);
		strcpy( curparm->text, str);
		return( count);
	}
	str[count++]=ch;
}
str[count]=0;
curparm->text=(char *)malloc(strlen(str)+1);
strcpy( curparm->text, str);
return( count);
}

struct com *inlist( struct com *newcom,int inhead,int xpos,int ypos, struct com *curcom)
{
if( curcom!=0)
	curcom->next=newcom;
newcom->prev=curcom;

if( !inhead){
	newcom->xscr=xpos+16;
	if( newcom->xscr<18)
		newcom->xscr=18;
	if( newcom->xscr+strlen(newcom->text)*w>18+(80*w))
		newcom->xscr=18+(80*w)-strlen(newcom->text)*w;
	newcom->yscr=ypos;
}
return(newcom);
}

struct com *add_lf(struct com *curcom, int inhead)
{
struct com *new;
int nb;

if( curcom!=0){
	if( curcom->code==codes[LF]){
		sscanf( curcom->parm->text, "%d", &nb);
		nb++;
		sprintf( curcom->parm->text, "%d", nb);
		gen_cmdtext( curcom, inhead);
		return( curcom);
	}
}
new=(struct com *)malloc(sizeof( struct com));
new->code=codes[LF];
new->prev=0;
new->next=0;
new->spec=0;
new->parm=0;
new->text=0;
new->ctext=G_cmds[LF].text;
new->parm=(struct param *)malloc( sizeof( struct param));
new->parm->code=CONST;
new->parm->typecode=C_TEXT;
new->parm->soe=0;
new->parm->next=0;
new->parm->prev=0;
new->parm->text=(char *)malloc( 4);
strcpy( new->parm->text, "1");
gen_cmdtext( new, inhead);
return(new);
}

long int locatereport( FILE *fp)
{
int slen, rlen, nread;
char buf[50];

slen=strlen( G_choice);
while(1){
	rlen=fgeti(fp);
	slen=fgeti(fp);
	if( slen>50 || slen<0)
		return(-1L);
	nread=fread( buf, 1, slen, fp);
	if( nread!=slen)
		return(-1L);
	if( strncmp( buf, G_choice, slen)==0)
		return(ftell( fp));
	fseek( fp, (long) (rlen-slen-2), SEEK_CUR);
}
}

void buildrptfile( FILE *fp)
{
int rlen, slen, bytesleft, nread;
long len;
char buf[500], name[20];
int skip=0, end=0;
FILE *ffp, *tfp;

if( (tfp=fopen( "tmprpt.rpt", "w+b"))==NULL){
	unlink( "tmprpt.rpt");
	if( (tfp=fopen( "tmprpt.rpt", "w+b"))==NULL){
		filerr("tmprpt.rpt");
		return;
	}
}
sprintf( name,"%s.rpt", G_cellname);
if( (ffp=fopen( name, "r+b"))==NULL){
	end=1;
}

while( !end){
	rlen=fgeti(ffp);
	slen=fgeti(ffp);
	if( slen>50 || slen<=0)
		end=1;
	else{
		nread=fread( buf, 1, slen, ffp);
		if( nread!=slen)
			end=1;
	}
	if( !end){
		if( strncmp( buf, G_choice, slen)==0)
			skip=1;
		else{
			fputi( rlen, tfp);
			fputi( slen, tfp);
			fwrite( buf, 1, slen, tfp);
			skip=0;
		}
		bytesleft=rlen-slen-2;
		while( bytesleft>0){
			if((nread=fread( buf, 1, bytesleft, ffp))>0){
				if( !skip)
					fwrite( buf, 1, nread, tfp);
			}
			else
				end=1;
			bytesleft=bytesleft-nread;
		}
	}
}
fseek( fp, 0, SEEK_END);
len=ftell(fp);
fseek( fp, 0, SEEK_SET);
fputi( (int)len, tfp);
while((nread=fread( buf, 1, 500, fp))>0)
	fwrite( buf, 1, nread, tfp);
fclose(ffp);
if( (ffp=fopen( name, "w+b"))==NULL){
	unlink( name);
	if( (ffp=fopen( name, "w+b"))==NULL){
		filerr(name);
		return;
	}
}
fseek( tfp, 0, SEEK_SET);
while((nread=fread( buf, 1, 500, tfp))>0)
	fwrite( buf, 1, nread, ffp);
fclose(tfp);
fclose(ffp);
unlink( "tmprpt.rpt");
}

void swaprflds( int from, int to)
{
int ch;
char name[20];
long pos;
FILE *fp;

sprintf( name,"%s.rpt", G_cellname);
if( (fp=fopen( name, "r+b"))==NULL)
	return;
while( (ch=fgetc(fp))!=EOF){
	if( ch==FSPEC_VAL){
		if( fgetc(fp)==G_storeid+1){
			if( (ch=fgetc(fp))==from){
				pos=ftell( fp);
				fseek( fp, -1, SEEK_CUR);
				fputc( to, fp);
				fseek( fp, pos, SEEK_SET);
			}
			else if( ch==to){
				pos=ftell( fp);
				fseek( fp, -1, SEEK_CUR);
				fputc( from, fp);
				fseek( fp, pos, SEEK_SET);
			}
		}
	}
}
fclose(fp);
}

int findrfld( int findfield)
{
int ch;
char name[20];
FILE *fp;

sprintf( name,"%s.rpt", G_cellname);
if( (fp=fopen( name, "rb"))==NULL)
	return(0);
while( (ch=fgetc(fp))!=EOF){
	if( ch==FSPEC_VAL){
		if( fgetc(fp)==G_storeid+1){
			if( fgetc(fp)==findfield){
				fclose(fp);
				return(1);
			}
		}
	}
}
fclose(fp);
return(0);
}