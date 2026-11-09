/* outxtxy, outixy, outcxy */


#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include "tdef.h"
#include "tdrep.h"

void write_spec( struct fld_spec *spec, int fldspec);
void fld_spec(int fldspec, struct com *cmd);
void fld_spec_change( int fldspec, int key, struct com *cmd);
struct com *addtoeol( struct com **start);
void select_com( struct com *oldcur, struct com *cur,int startyp, int curpos);
int move_text( struct com *point, int start, int end);
int find_text( struct com *point);
struct com *in_textbox( struct com *listhead, char *type);
int in_headbox(void);
int in_mainbox(void);
int in_footbox(void);
void draw_section( struct com *start, char sectiontype, int startyp);
int in_sectionwin(char sectiontype);
struct com *section_cmd( struct com *start, char sectiontype, int startyp);
struct param *insert_parm(struct com *cmd);
void setuprep(char *choice);
char *selectfrom( int item);
void select_option(void);
void setup_cmds(void);
void freeparm( struct param *parm);
void command_box(char *type);           /*draw command box*/
struct com *copy_com(struct com *from);  /*copy the current command*/
void setupdict(struct com *new);               /*setup the dictionary for this command*/
struct com *edit_command(struct com *chgcmd, char *type, int newcmd, int inhead);     /*edit the command*/

struct com *G_comFILES;			/* the reports FILES command */
struct com *G_comRANGE;  		/* the RANGE command */
struct com *G_comSORT;			/* the SORT command */
struct com *G_headcom; 			/* commands in the header command bar */
struct com *G_maincom;          /*   "		"	   main */
struct com *G_footcom;          /*   "		"      footer*/
struct com *G_headtext;         /* header window commands */
struct com *G_maintext;         /* main window */
struct com *G_foottext;         /* footer window */
struct com *G_cur_text;         /* current text item*/
struct text *G_headt;			/* text items in the header window */
struct text *G_maint;			/* text items in the main window */
struct text *G_foott;			/* text items in the foot window */
struct text *G_curt;			/* current text item */
struct commands G_cmds[30];		/* the list of commands */
char G_choice[40];
char G_subreport[40];


int w;
int G_curx;
int G_cury;
int curfield,curfile,curcmd,cur,changesmade;
int G_yphead,G_ypmain,G_ypfoot,G_ypstart;

char *field_types[5]={"INT","FLOAT","DOUBLE","LONG","STRING"};
char *just[3]={"LEFT","RIGHT","CENTRE"};
char *padding[2]={"ZERO","SPACE"};
char *zero[2]={"NO","YES"};
char *attr[4]={"NORMAL","BOLD","CONDENSED","UNDERLINE"};

char *txt[NBCMDS]={ "FILES","RANGE","SORT","EXPR","CALL","DATE","ELSE",
						   "IF","FNAMEOF","NAMEOF","P","PAGE","READ","RESET",
							"SET","TOTAL","TOTALS","LF"};
int const codes[NBCMDS]={ 0x84,0x85,0x86,0x92,0x88,0x90,0x94,0x93,0x8e,
						  0x8f,0x0c,0x91,0x87,0x8c,0x8d,0x89,0x8a,0x0a};
int const validpos[NBCMDS]={ 7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7};		/*valid in which areas of the report*/

void repdef(int item) {
int yp,xit=0;

setup_cmds();
yp=((G_maxy-46-WINY)/11)*11;
G_ypstart=54;
G_yphead=30+yp/3;
G_ypmain=30+(2*yp)/3;
G_ypfoot=yp;
settextstyle(2,0,4);
setuprep("(Name Undefined)");
strcpy( G_choice,selectfrom( item));
if( strcmp(G_choice,"")==0){
	mousecur(0);
	return;
}
load_rep();
changesmade=0;
draw_reportwin(G_choice);
setfillstyle(1,11);
while (!xit) {
	if (kbhit()) {
		switch (getch()) {
			case 0 : { /* Function Keys */
				switch(getch()) {
					case '<': 			/* F2 */
						if( oktosave()){
							save_rep();
							changesmade=0;
						}
						draw_reportwin(G_choice);
						setfillstyle(1,11);
						setcolor(YELLOW);
						break;
					case '=':           /* F3 */
						strcpy( G_choice,selectfrom( item));
						freeall();
						if( strcmp(G_choice,"")==0){
							mousecur(0);
							return;
						}
						draw_reportwin(G_choice);
						load_rep();
						changesmade=0;
						draw_reportwin(G_choice);
						setfillstyle(1,11);
						setcolor(YELLOW);
					break;
					case '?':  /* F5 */
						print_report();
						draw_reportwin(G_choice);
						setfillstyle(1,11);
						setcolor(YELLOW);
					break;
					case 'S': /* delete key */
						if( deletecmd()!=0)
							draw_reportwin( G_choice);
						break;
					default : {
					}
				}
			} break;
			default : {
			}
		}
	}
	if (mousetrap(5)) {
		if (mseb==1) {
			if( inbox(16,WINY+G_ypstart,18+80*w,WINY+G_yphead)){
				if(in_headbox())
					draw_reportwin(G_choice);
			}
			else if( inbox(16,WINY+12+G_yphead,18+80*w,WINY+G_ypmain)){
				if(in_mainbox())
					draw_reportwin(G_choice);
			}
			else if( inbox(16,WINY+12+G_ypmain,18+80*w,WINY+G_ypfoot)){
				if(in_footbox())
					draw_reportwin(G_choice);
			}
			else if( inbox(16,WINY+G_ypstart-11,18+80*w,WINY+G_ypstart)){
				if(in_sectionwin('H'))
					draw_reportwin(G_choice);
			}
			else if( inbox(16,WINY+G_yphead,18+80*w,WINY+G_yphead+12)){
				if(in_sectionwin('M'))
					draw_reportwin(G_choice);
			}
			else if( inbox(16,WINY+G_ypmain,18+80*w,WINY+G_ypmain+12)){
				if(in_sectionwin('F'))
					draw_reportwin(G_choice);
			}
			else if( inbox( 520, 30+WINY, 620, 407+WINY))
				select_option();
			else if (inbox(275,G_maxy-30,325,G_maxy-10)) {
				mousecur(0);
				button(300,G_maxy-WINY-20,"EXIT",1,1);
				mousecur(1);
				if( !changesmade || save_request()==1){
					xit=1;
					changesmade=0;
				}
				else
					setuprep(G_choice);
			}
		}
		while (mseb) mousetrap(5);
	}
	if( G_subreport[0]!=0){
		if( !changesmade || save_request()==1){
			freeall();
			strcpy( G_choice,G_subreport);
			draw_reportwin(G_choice);
			load_rep();
			changesmade=0;
			draw_reportwin(G_choice);
			setfillstyle(1,11);
			setcolor(YELLOW);
		}
		G_subreport[0]=0;
	}

}
mousecur(0);
freeall();
}
void setuprep(char *choice) {
int i;
char tmp[100];

mousecur(0);
setcolor(1);
cleardevice();
settextjustify(CENTER_TEXT,2);
setviewport(0,0,G_maxx,G_maxy,1);
rectangle(0,0,G_maxx,G_maxy);
setcolor(YELLOW);
outtextxy(150,2,"Function Keys Defined: F2 Save F3 Load F5 Print");
setcolor(1);
setviewport(0,WINY,G_maxx,G_maxy,1);
setfillstyle(1,1);
bar(0,0,G_maxx,G_maxy-WINY);
rectangle(0,0,G_maxx,G_maxy-WINY);
line(0,24,G_maxx,24);
setcolor(9);
tmp[1]=0;
for (i=0;i<80;i++) {
	tmp[0]=((i+1)%10)+'0';
/*	outtextxy((w/2)+17+i*w,35,tmp);*/
	printxy((w/2)+17+i*w,35,tmp);
}
draw_reportwin(choice);
mousecur(0);
button(300,G_maxy-WINY-20,"EXIT",0,0);
mousecur(1);
}
char *selectfrom(int item)
{
int nblines=0;
int i,j,len,maxlen=0;
int ypos;

mousecur(0);
settextjustify( CENTER_TEXT, TOP_TEXT);
for(i=0;i<G_nocont[G_nowlev];i++)
	if((lev[G_nowlev].G_cont[i].to==item)&&(!(lev[G_nowlev].G_cont[i].deled))) {
		nblines++;
		if( (len=strlen( lev[G_nowlev].G_cont[i].text))>maxlen)
			maxlen=len;
	}
	if( nblines==0){
	settextjustify( LEFT_TEXT, TOP_TEXT);
	return("");
}
if( nblines==1)
	for (i=0;i<G_nocont[G_nowlev];i++)
		if ((lev[G_nowlev].G_cont[i].to==item)&&(!(lev[G_nowlev].G_cont[i].deled))){
			settextjustify( LEFT_TEXT, TOP_TEXT);
			return(lev[G_nowlev].G_cont[i].text);
		}
maxlen=maxlen+2;
setfillstyle( 1,7);
bar( 200-((30*w)/2),200,200+((30*w)/2),200+(7+nblines)*11);
setcolor(9);
rectangle( 200-((30*w)/2),200,200+((30*w)/2),200+(7+nblines)*11);
setfillstyle( 1,1);
bar( 200-((maxlen*w)/2),225,200+((maxlen*w)/2),222+(1+nblines)*11);
setcolor(14);
rectangle( 200-((maxlen*w)/2),225,200+((maxlen*w)/2),222+(1+nblines)*11);
j=1;
for (i=0;i<G_nocont[G_nowlev];i++) {
	if ((lev[G_nowlev].G_cont[i].to==item)&&(!(lev[G_nowlev].G_cont[i].deled))) {
		outtextxy(200,j*11+220,lev[G_nowlev].G_cont[i].text);
		j++;
	}
}
outtextxy( 200, 210, "Select One Of The Following:");
button(200,200+(5+nblines)*11,"EXIT",0,0);
mousecur(1);
while( 1){
	if( mousetrap(5)){
		if( mseb==1){
			if( inbox(175,210+(5+nblines)*11,225,230+(5+nblines)*11)){
				mousecur(0);
				button(200, 200+(5+nblines)*11, "EXIT", 1, 1);
				mousecur(1);
				settextjustify( LEFT_TEXT, TOP_TEXT);
				return("");
			}
			if( inbox( 200-(maxlen*w)/2,WINY+225,200+(maxlen*w)/2,WINY+222+(1+nblines)*11)) {
				ypos=(msey-WINY-232)/11;
				if( ypos<0)
					ypos=0;
				j=0;
				for (i=0;i<G_nocont[G_nowlev];i++) {
					if ((lev[G_nowlev].G_cont[i].to==item)&&(!(lev[G_nowlev].G_cont[i].deled))) {
						if( j>=ypos){
							mousecur(0);
							setcolor( LIGHTCYAN);
							outtextxy(200,(j+1)*11+220,lev[G_nowlev].G_cont[i].text);
							while( mseb) mousetrap(5);
							settextjustify( LEFT_TEXT, TOP_TEXT);
							return( lev[G_nowlev].G_cont[i].text);
						}
						j++;
					}
				}
				mousecur(0);
				settextjustify( LEFT_TEXT, TOP_TEXT);
				return("");
			}
		}
		while( mseb) mousetrap(5);
	}
}
}
void command_box(char *type)
{

if( strcmp( type,"FILES")==0||strcmp(type, "FOOT")==0){
	G_curx=18;
	G_cury=100;
}
else if(strcmp( type, "MAIN")==0){
	G_curx=18;
	G_cury=62;
}
else if(strcmp( type, "HEAD")==0){
	G_curx=18;
	G_cury=200;
}
mousecur(0);
setfillstyle(1,1);
bar(G_curx,G_cury,G_curx+(80*w)-1,G_cury+106);
setcolor(14);
rectangle(G_curx-1,G_cury-1,G_curx+(80*w),G_cury+106);
settextstyle(2,0,5);
setfillstyle(1,7);
outtextxy(G_curx+(41*w),G_cury+4,"EDIT COMMAND");
bar(G_curx+w,G_cury+20,G_curx+(79*w),G_cury+34);
rectangle(G_curx-1+w,G_cury+20,G_curx+1+(79*w),G_cury+34);
settextjustify(RIGHT_TEXT, 2);
settextstyle(2,0,4);
bar(G_curx+(16*w),G_cury+42,G_curx+(23*w),G_cury+53);
outtextxy(G_curx+(15*w), G_cury+42, "Field Type");
rectangle(G_curx+(16*w)-1,G_cury+42,G_curx+1+(23*w),G_cury+54);
bar(G_curx+(40*w),G_cury+42,G_curx+(47*w),G_cury+53);
outtextxy(G_curx+(39*w), G_cury+42, "Justification");
rectangle(G_curx-1+(40*w),G_cury+42,G_curx+1+(47*w),G_cury+54);
bar(G_curx+(65*w),G_cury+42,G_curx+(72*w),G_cury+53);
outtextxy(G_curx+(64*w), G_cury+42, "Padding");
rectangle(G_curx-1+(65*w),G_cury+42,G_curx+1+(72*w),G_cury+54);

bar(G_curx+(16*w),G_cury+62,G_curx+(20*w),G_cury+73);
outtextxy(G_curx+(15*w), G_cury+62, "Zero Suppress");
rectangle(G_curx+(16*w)-1,G_cury+62,G_curx+1+(20*w),G_cury+74);
bar(G_curx+(40*w),G_cury+62,G_curx+(50*w),G_cury+73);
outtextxy(G_curx+(39*w), G_cury+62, "Attribute");
rectangle(G_curx+(40*w)-1,G_cury+62,G_curx+1+(50*w),G_cury+74);
bar(G_curx+(65*w),G_cury+62,G_curx+(70*w),G_cury+73);
outtextxy(G_curx+(64*w), G_cury+62, "Width");
rectangle(G_curx+(65*w)-1,G_cury+62,G_curx+1+(70*w),G_cury+74);

bar(G_curx+(75*w),G_cury+62,G_curx+(77*w),G_cury+73);
outtextxy(G_curx+(74*w), G_cury+62, "Dec");
rectangle(G_curx+(75*w)-1,G_cury+62,G_curx+1+(77*w),G_cury+74);

button(G_curx+(18*w),G_cury+92,"OK",0,0);
button(G_curx+(38*w),G_cury+92,"SYNTAX",0,0);
button(G_curx+(58*w),G_cury+92,"CANCEL",0,0);
mousecur(1);
settextjustify(LEFT_TEXT, TOP_TEXT);
return;
}

struct com *copy_com(struct com *from)
{
struct param *prevpar, *frompar, *topar;
struct com *to;

if( from==0)
	return(0);

to = (struct com *)malloc( sizeof(struct com));
memcpy( to, from, sizeof(struct com));
to->parm=0;

if( from->spec!=0){
	to->spec=(struct fld_spec *)malloc( sizeof( struct fld_spec));
	memcpy( to->spec, from->spec, sizeof( struct fld_spec));
}
frompar=from->parm;
prevpar=0;
while( frompar!=0){
	topar=(struct param *)malloc( sizeof(struct param));
	if( to->parm==0)
		to->parm=topar;
	if( prevpar!=0)
		prevpar->next=topar;
	topar->code=frompar->code;
	topar->typecode=frompar->typecode;
	topar->soe=frompar->soe;
	topar->text=frompar->text;
	topar->next=0;
	topar->prev=prevpar;
	prevpar=topar;
	frompar=frompar->next;
}
return(to);

}
void write_com( struct com *cmd)
{
struct param *parm;
int curxp;
int xpos,ypos;

xpos=G_curx+w+5;
ypos=G_cury+21;
mousecur(0);
setfillstyle( 1, LIGHTGRAY);
setcolor(YELLOW);
bar( G_curx+w, G_cury+20, G_curx+(79*w), G_cury+34);
rectangle( G_curx-1+w, G_cury+20, G_curx+1+(79*w), G_cury+34);
if( cmd==0){
	mousecur(1);
	return;
}

settextjustify( LEFT_TEXT, TOP_TEXT);
/*outtextxy( xpos, ypos, cmd->ctext);*/
printxy( xpos, ypos, cmd->ctext);
cmd->xpos=xpos;
cmd->ypos=ypos;
parm=cmd->parm;
curxp=xpos+strlen(cmd->ctext)*w;
while( parm!=0 && G_curx+(79*w)>=curxp+strlen(parm->text)*w ){
	parm->xpos=curxp+w;
	parm->ypos=ypos;
/*	outtextxy( parm->xpos, ypos, parm->text);*/
	printxy( parm->xpos, ypos, parm->text);
	curxp=parm->xpos+strlen(parm->text)*w;
	parm=parm->next;
}
if( cmd->spec>0)
	write_spec( cmd->spec, 0);
mousecur(1);
}

void setupdict(struct com *new)
{
new->code=codes[curcmd];
new->text=0;
new->ctext=G_cmds[curcmd].text;
new->parm=0;
new->next=0;
new->prev=0;
new->spec=0;
return;
}

struct com *edit_command(struct com *chgcmd, char *type, int newcmd, int inhead)
{
int in_fld_box=0;
int res=1;
char keyp;
int found;
struct param *cursor;
struct fld_spec *spec;
struct param *parm;
struct com *cmd;

changesmade=1;
cursor=0;
cmd=copy_com( chgcmd);
write_com( cmd);
if( cmd->code==codes[CALL])
	draw_subrep(0);
highlight_com( cmd, 1, 0, cursor);
do{
	if(kbhit()){
		if( !in_fld_box){
			switch(keyp=getch()){
				case 0:
					switch(getch()){
						case 'S':			/* del key*/
							if( cursor!=0){
								parm=delete_parm( cmd, cursor);
								write_com( cmd);
								highlight_com( cmd, 1, 0, parm);
								cursor=parm;
							}
							break;
						case 'M':
							if( cursor==0){
								if( cmd->parm!=0){
									cursor=cmd->parm;
									highlight_com( cmd, 0, 0, cursor);
								}
							}
							else{
								if( cursor->next!=0){
									highlight_com( cmd, 0, cursor, cursor->next);
									cursor=cursor->next;
								}
							}
							break;
						case 'K':
							if( cursor!=0){
								if( cursor->prev==0){
									highlight_com( cmd, 0, cursor, 0);
									cursor=0;
								}
								else{
									highlight_com( cmd, 0, cursor, cursor->prev);
									cursor=cursor->prev;
								}
							}
							break;
					}
					break;
				default:
					if( keyp<32 || keyp >126)
						break;
					if( inbox( G_curx+w, WINY+G_cury+20, G_curx+(79*w), WINY+G_cury+34)){
						parm=addtext_parm( keyp, cmd);
						if( parm!=0)
							cursor=parm;
						write_com( cmd);
						highlight_com( cmd, 1, 0, cursor);
					}
					break;

			}
		}
		else{
			switch(keyp=getch()){
				case 0:
					switch(getch()){
						case 'M':
							fld_spec_change( in_fld_box, -1, cmd);
							break;
						case 'K':
							fld_spec_change( in_fld_box, -2, cmd);
							break;
					}
					break;
				default:
					fld_spec_change( in_fld_box, keyp, cmd);
					break;
			}
		}
	}
	if (mousetrap(5)) {
		if( mseb==2){
			if( inbox( G_curx+w, WINY+G_cury+20, G_curx+(79*w), WINY+G_cury+34)){
				parm=insert_parm(cmd);
				in_fld_box=0;
				if( cmd->spec!=0)
					write_spec( cmd->spec, 0);
				if( parm!=0){
					write_com( cmd);
					highlight_com( cmd, 0, cursor, parm);
					cursor=parm;
				}
			}
			if( 1==1 && inbox(G_curx+(65*w),WINY+G_cury+62,G_curx+(72*w),WINY+G_cury+73)){
				if( in_fld_box==6)
					fld_spec_change( in_fld_box, -2, cmd);
			}
			if( 1==1 && inbox(G_curx+(75*w),WINY+G_cury+62,G_curx+(77*w),WINY+G_cury+73)){
				if( in_fld_box==7)
					fld_spec_change( in_fld_box, -2, cmd);
			}
		}
		if( mseb==1){
			if( inbox( 520, 30+WINY, 620, 407+WINY))
				select_option();
			if( inbox( G_curx+w, WINY+G_cury+20, G_curx+(79*w), WINY+G_cury+34)){
				if( msex>cmd->xpos && msex<cmd->xpos+strlen(cmd->ctext)*w){
					highlight_com(cmd, 0, cursor, 0);
					cursor=0;
				}
				else{
					found=0;
					parm=cmd->parm;
					while(found==0 && parm!=0){
						if(msex>parm->xpos && msex<parm->xpos+strlen(parm->text)*w){
							highlight_com(cmd, 0, cursor, parm);
							cursor=parm;
							found=1;
						}
						parm=parm->next;
					}
				}
				if( cmd->spec!=0)
					write_spec( cmd->spec, 0);
				in_fld_box=0;
			}
			if( 1==1){					/* in fld_spec box? */
				if( inbox(G_curx+(16*w),WINY+G_cury+42,G_curx+(23*w),WINY+G_cury+53)){
					if( in_fld_box!=1){
						in_fld_box=1;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);

				}
				else if(inbox(G_curx+(40*w),WINY+G_cury+42,G_curx+(47*w),WINY+G_cury+53)){
					if( in_fld_box!=2){
						in_fld_box=2;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
				else if(inbox(G_curx+(65*w),WINY+G_cury+42,G_curx+(72*w),WINY+G_cury+53)){
					if( in_fld_box!=3){
						in_fld_box=3;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
				else if(inbox(G_curx+(16*w),WINY+G_cury+62,G_curx+(20*w),WINY+G_cury+73)){
					if( in_fld_box!=4){
						in_fld_box=4;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
				else if(inbox(G_curx+(40*w),WINY+G_cury+62,G_curx+(50*w),WINY+G_cury+73)){
					if( in_fld_box!=5){
						in_fld_box=5;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
				else if(inbox(G_curx+(65*w),WINY+G_cury+62,G_curx+(70*w),WINY+G_cury+73)){
					if( in_fld_box!=6){
						in_fld_box=6;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
			else if(inbox(G_curx+(75*w),WINY+G_cury+62,G_curx+1+(77*w),WINY+G_cury+74)){
					if( in_fld_box!=7){
						in_fld_box=7;
						fld_spec(in_fld_box, cmd);
					}
					else
						fld_spec_change( in_fld_box, -1, cmd);
				}
			}
			if( cmd->code==codes[CALL] && inbox(G_curx+6,WINY+G_cury+77,G_curx+32,WINY+G_cury+102)){
				draw_subrep(1);
				if( (parm=syntax_check( cmd))==0){
					if( cmd->parm!=0)
						strcpy( G_subreport, cmd->parm->text);
					parm=chgcmd->parm;
					spec=chgcmd->spec;
					memcpy( chgcmd, cmd, sizeof(struct com));
					cmd->text=0;
					cmd->parm=parm;
					cmd->spec=spec;
					while(parm!=0){
						parm->text=0;
						parm=parm->next;
					}
					freecom(cmd);
					gen_cmdtext( chgcmd, inhead);
					res=2;
				}
				else{
					draw_reportwin(G_choice);
					command_box(type);
					write_com( cmd);
					cursor=parm;
					if( cmd->code==codes[CALL])
						draw_subrep(0);
					highlight_com( cmd, 1, 0, cursor);
				}
			}
			if( inbox(G_curx+(38*w)-25,G_cury+92,G_curx+(38*w)+25,G_cury+122)){
				mousecur(0);
				button( G_curx+(38*w), G_cury+92, "SYNTAX", 1, 1);
				mousecur(1);
				if( (parm=syntax_check( cmd))!=0)
					cursor=parm;
				mousecur(0);
				button( G_curx+(38*w), G_cury+92, "SYNTAX", 1, 1);
				mousecur(1);
				draw_reportwin(G_choice);
				command_box(type);
				write_com( cmd);
				if( cmd->code==codes[CALL])
					draw_subrep(0);
				highlight_com( cmd, 1, 0, cursor);
			}
			if( inbox(G_curx+(18*w)-25,G_cury+92,G_curx+(18*w)+25,G_cury+122)){
				mousecur(0);
				button( G_curx+(18*w), G_cury+92, "OK", 1, 1);
				mousecur(1);
				if( (parm=syntax_check( cmd))==0){
					mousecur(0);
					button( G_curx+(18*w), G_cury+92, "OK", 1, 1);
					mousecur(1);
					parm=chgcmd->parm;
					spec=chgcmd->spec;
					memcpy( chgcmd, cmd, sizeof(struct com));
					cmd->text=0;
					cmd->parm=parm;
					cmd->spec=spec;
					while(parm!=0){
						parm->text=0;
						parm=parm->next;
					}
					freecom(cmd);
					gen_cmdtext( chgcmd, inhead);
					res=2;
				}
				else{
					draw_reportwin(G_choice);
					command_box(type);
					write_com( cmd);
					cursor=parm;
					if( cmd->code==codes[CALL])
						draw_subrep(0);
					highlight_com( cmd, 1, 0, cursor);
				}
			}
			if( inbox(G_curx+(58*w)-25,G_cury+92,G_curx+(58*w)+25,G_cury+122)){
				mousecur(0);
				button( G_curx+(58*w), G_cury+92, "CANCEL", 1, 1);
				mousecur(1);
				cmd->text=0;
				parm=cmd->parm;
				while(parm!=0){
					parm->text=0;
					parm=parm->next;
				}
				freecom(cmd);
				if( newcmd){
					freecom( chgcmd);
					chgcmd=0;
				}
				res=2;
			}
		}
		while( mseb) mousetrap(5);
	}
}while( res==1);
settextjustify( LEFT_TEXT, TOP_TEXT);
return( chgcmd);

}

void draw_reportwin(char *choice)
{
int i;
char tmp[100];

mousecur(0);
settextjustify( CENTER_TEXT, TOP_TEXT);
setfillstyle(1,1);
bar(0,2,G_maxx,13);
setcolor(14);
sprintf(tmp,"    PMA CDL    REPORT DEFINITION     REPORT %s FOR CELL %s",choice,G_cellname);
outtextxy(G_maxx/2,2,tmp);
setcolor(9);
setfillstyle(1,8);
settextstyle(2,0,4);
bar(16,50,18+80*w,G_ypfoot);
setfillstyle(1,7);
bar( 17,45,18+80*w,55);
bar( 17,1+G_yphead,18+80*w,11+G_yphead);
bar( 17,1+G_ypmain,18+80*w,11+G_ypmain);
setcolor(14);
rectangle(16,30,18+80*w,G_ypfoot);
outtextxy(9+40*w,46,"REPORT HEADER");
outtextxy(9+40*w,1+G_yphead,"MAIN");
outtextxy(9+40*w,1+G_ypmain,"REPORT FOOTER");
setfillstyle( 1, BLACK);
bar(520,30,620,G_ypfoot);
rectangle(520,30,620,G_ypfoot);
rectangle(520,30,555,55);
rectangle(555,30,585,55);
for (i=55;i<G_ypfoot;i+=11) line(520,i,620,i);
setcolor(YELLOW);
outtextxy(572,35,"FILE  CMD  FIELD");
draw_reptext( G_headtext, G_cur_text, G_headt);
draw_reptext( G_maintext, G_cur_text, G_maint);
draw_reptext( G_foottext, G_cur_text, G_foott);
settextjustify( CENTER_TEXT, TOP_TEXT);
if( cur==1){
	for (i=0;i<27;i++) {
		bar(521,i*11+56,619,i*11+65);
		if (i<G_file.nofiles) outtextxy(570,i*11+56,G_file.files[i]);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curfile*11+56,619,curfile*11+65);
	outtextxy(570,curfile*11+56,G_file.files[curfile]);
}
else if( cur==2){
	for (i=0;i<27;i++){
		bar(521,i*11+56,619,i*11+65);
		if( i<NBCMDS) outtextxy(570,i*11+56,G_cmds[i].text);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curcmd*11+56,619,curcmd*11+65);
	outtextxy(570,curcmd*11+56,G_cmds[curcmd].text);
}
else{
	for (i=0;i<27;i++) {
		bar(521,i*11+56,619,i*11+65);
		if (i<G_file.cont[curfile]->nofld) outtextxy(570,i*11+56,G_file.cont[curfile]->flds[i]->name);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curfield*11+56,619,curfield*11+65);
	outtextxy(570,curfield*11+56,G_file.cont[curfile]->flds[curfield]->name);
}
setfillstyle(1,7);
setcolor( YELLOW);
settextjustify( LEFT_TEXT, TOP_TEXT);
mousecur(1);

}

void select_option()
{
int i,pos;

pos=(((msey-WINY)-55)/11);
settextjustify( CENTER_TEXT, TOP_TEXT);
if (inbox(520,56+WINY,620,407+WINY)) {
	if (cur==1) {
		if (pos<G_file.nofiles && pos>=0) {
			mousecur(0);
			setfillstyle(1,BLACK);
			setcolor(YELLOW);
			bar(521,curfile*11+56,619,curfile*11+65);
			outtextxy(570,curfile*11+56,G_file.files[curfile]);
			setfillstyle(1,11);
			setcolor(1);
			curfile=pos;
			bar(521,curfile*11+56,619,curfile*11+65);
			outtextxy(570,curfile*11+56,G_file.files[curfile]);
			curfield=0;
			mousecur(1);
		}
	}
	else if(cur==3){
		if (pos<G_file.cont[curfile]->nofld && pos>=0) {
			mousecur(0);
			setfillstyle(1,BLACK);
			setcolor(YELLOW);
			bar(521,curfield*11+56,619,curfield*11+65);
			outtextxy(570,curfield*11+56,G_file.cont[curfile]->flds[curfield]->name);
			setfillstyle(1,11);
			setcolor(1);
			bar(521,pos*11+56,619,pos*11+65);
			outtextxy(570,pos*11+56,G_file.cont[curfile]->flds[pos]->name);
			curfield=pos;
			mousecur(1);
		}
	}
	else{
		if (pos<NBCMDS && pos>=0) {
			mousecur(0);
			setfillstyle(1,BLACK);
			setcolor(YELLOW);
			bar(521,curcmd*11+56,619,curcmd*11+65);
			outtextxy(570,curcmd*11+56,G_cmds[curcmd].text);
			setfillstyle(1,11);
			setcolor(1);
			bar(521,pos*11+56,619,pos*11+65);
			outtextxy(570,pos*11+56,G_cmds[pos].text);
			curcmd=pos;
			mousecur(1);
		}
	}
}
if( inbox(520,30+WINY,555,55+WINY)  &&cur!=1){
	mousecur(0);
	setfillstyle(1,BLACK);
	setcolor(YELLOW);
	for (i=0;i<27;i++) {
		bar(521,i*11+56,619,i*11+65);
		if (i<G_file.nofiles) outtextxy(570,i*11+56,G_file.files[i]);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curfile*11+56,619,curfile*11+65);
	outtextxy(570,curfile*11+56,G_file.files[curfile]);
	mousecur(1);
	cur=1;
}
if( inbox(555,30+WINY,585,55+WINY) && cur!=2){
	mousecur(0);
	setfillstyle(1,BLACK);
	setcolor(YELLOW);
	for (i=0;i<27;i++){
		bar(521,i*11+56,619,i*11+65);
		if( i<NBCMDS) outtextxy(570,i*11+56,G_cmds[i].text);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curcmd*11+56,619,curcmd*11+65);
	outtextxy(570,curcmd*11+56,G_cmds[curcmd].text);
	mousecur(1);
	cur=2;
}
if( inbox(585,30+WINY,620,55+WINY) && cur!=3){
	curfield=0;
	mousecur(0);
	setfillstyle(1,BLACK);
	setcolor( YELLOW);
	for (i=0;i<27;i++) {
		bar(521,i*11+56,619,i*11+65);
		if (i<G_file.cont[curfile]->nofld)
			outtextxy(570,i*11+56,G_file.cont[curfile]->flds[i]->name);
	}
	setfillstyle(1,11);
	setcolor(1);
	bar(521,curfield*11+56,619,curfield*11+65);
	outtextxy(570,curfield*11+56,G_file.cont[curfile]->flds[curfield]->name);
	mousecur(1);
	cur=3;
}
settextjustify( LEFT_TEXT, TOP_TEXT);
}

void setup_cmds()
{
int i;

for(i=0;i<NBCMDS;i++){
	G_cmds[i].code=codes[i];
	G_cmds[i].text=txt[i];
}

G_comFILES=0;
G_comRANGE=0;
G_comSORT=0;
G_headcom=0;
G_maincom=0;
G_footcom=0;
G_headtext=0;
G_maintext=0;
G_foottext=0;
G_headt=0;
G_maint=0;
G_foott=0;
G_curt=0;
G_cur_text=0;
w=textwidth("8");
curfile=0;
curfield=0;
curcmd=0;
cur=1;
G_subreport[0]=0;
changesmade=0;

}

void freecom( struct com *cmd)
{
struct param *parm,*nextparm;

parm=cmd->parm;
while(parm!=0){
	nextparm=parm->next;
	freeparm(parm);
	parm=nextparm;
}
if( cmd->text!=0)
	free( cmd->text);
if( cmd->spec!=0)
	free( cmd->spec);
free( cmd);

}

void freeparm( struct param *parm)
{
if( parm->text!=0)
	free( parm->text);
free( parm);
}

void highlight_com( struct com *cmd, int offon, struct param *old, struct param *new)
{
mousecur(0);
settextjustify( LEFT_TEXT, TOP_TEXT);
if( old==0 && offon!=1)
/*	outtextxy( cmd->xpos, cmd->ypos, cmd->ctext);*/
	printxy( cmd->xpos, cmd->ypos, cmd->ctext);
else if(offon!=1)
/*	outtextxy( old->xpos, old->ypos, old->text);*/
	printxy( old->xpos, old->ypos, old->text);
setcolor(RED);
if( new==0 && offon!=2)
/*	outtextxy( cmd->xpos, cmd->ypos, cmd->ctext);*/
	printxy( cmd->xpos, cmd->ypos, cmd->ctext);
else if(offon != 2)
/*	outtextxy( new->xpos, new->ypos, new->text);*/
	printxy( new->xpos, new->ypos, new->text);
setcolor(YELLOW);
mousecur(1);
}


struct param *insert_parm(struct com *cmd)
{
int found=0;
struct param *parm;
struct param *newparm;
char temp[60];

if( msex>cmd->xpos && msex<cmd->xpos+strlen(cmd->ctext)*w)
	return(0);
else{
	parm=cmd->parm;
	while(found==0 && parm!=0){
		if(msex>=parm->xpos-w && msex<=parm->xpos+strlen(parm->text)*w)
			found=1;
		else
			parm=parm->next;
	}
	if(parm==0){
		parm=cmd->parm;
		if(parm!=0)
			while(parm->next!=0)
				parm=parm->next;
	}
}

newparm=(struct param *)malloc(sizeof(struct param));
if( cur==1){
	newparm->text=(char *)malloc( sizeof(int)*(strlen(G_file.files[curfile])+1));
	strcpy( newparm->text,G_file.files[curfile]);
	newparm->code=FILEP;
}
else if(cur==3){
	strcpy( temp,G_file.files[curfile]);
	strcat( temp, ".");
	strcat( temp, G_file.cont[curfile]->flds[curfield]->name);
	newparm->text=(char *)malloc( sizeof(char)*(strlen(temp)+1));
	strcpy( newparm->text,temp);
	newparm->code=FIELD;
}
else if(cur==2){
	newparm->text=(char *)malloc( sizeof(char)*(strlen(G_cmds[curcmd].text)+1));
	strcpy( newparm->text,G_cmds[curcmd].text);
	newparm->code=G_cmds[curcmd].code;
}

if(parm==0){
	cmd->parm=newparm;
	newparm->prev=0;
	newparm->next=0;
}
else if(found==1){
	newparm->prev=parm->prev;
	if(parm->prev!=0)
		parm->prev->next=newparm;
	else
		cmd->parm=newparm;
	newparm->next=parm;
	parm->prev=newparm;
}
else{
	newparm->prev=parm;
	newparm->next=0;
	parm->next=newparm;
}
return(newparm);

}

struct param *delete_parm( struct com *cmd, struct param *cursor)
{
struct param *retparm;

if( cursor->next!=0)
	cursor->next->prev=cursor->prev;
if( cursor->prev==0)
	cmd->parm=cursor->next;
else
	cursor->prev->next=cursor->next;

if( cursor->next!=0)
	retparm=cursor->next;
else if( cursor->prev!=0)
	retparm=cursor->prev;
else
	retparm=0;

freeparm( cursor);
return( retparm);

}

struct com *in_textbox( struct com *listhead, char *type)
{
struct com *point;
int xp,yp,wid;

xp=msex;
yp=msey-WINY;
point=listhead;
while(point != 0){
	wid=strlen(point->text)*w;
	if(inbox( point->xscr, WINY+point->yscr-1, point->xscr+wid, WINY+point->yscr+12)){
		command_box(type);
		mousecur(0);
		if( G_cur_text!=0)
/*			outtextxy(G_cur_text->xscr, G_cur_text->yscr, G_cur_text->text);*/
			printxy(G_cur_text->xscr, G_cur_text->yscr, G_cur_text->text);
		G_cur_text=point;
		setcolor( LIGHTCYAN);
/*		outtextxy(point->xscr, point->yscr, point->text);*/
		printxy(point->xscr, point->yscr, point->text);
		setcolor( YELLOW);
		mousecur(1);
		point=edit_command(point, type, 0, 0);
		return(listhead);
	}
	point=point->next;
}
command_box(type);
point=(struct com *)malloc( sizeof( struct com));
setupdict(point);
point=edit_command(point, type, 1, 0);
if( point==0)
	return(listhead);
G_cur_text=point;
if( xp<18)
	xp=17;
else if( xp+strlen(point->text)*w>=18+(80*w))
	xp=18+(80*w)-strlen(point->text)*w;
if( strcmp(type, "HEAD")==0)
	if( yp>G_yphead-10)
		yp=G_yphead-10;
if( strcmp(type, "MAIN")==0)
	if( yp>G_ypmain-10)
		yp=G_ypmain-10;
if( strcmp(type, "FOOT")==0)
	if( yp>G_ypfoot-10)
		yp=G_ypfoot-10;
point->yscr=yp;
point->xscr=xp;
if( listhead!=0){
	listhead->prev=point;
	point->next=listhead;
	listhead=point;
}
else{
	listhead=point;
	listhead->prev=0;
	listhead->next=0;
}
return(listhead);
}

int in_headbox()
{
int count,found=0,dble=0;
int chgd=0;

found = find_text( G_headtext);
if( found){
	chgd=move_text( G_cur_text, G_ypstart, G_yphead-10);
	if( chgd)
		draw_reptext( G_headtext, G_cur_text, G_headt);
	while (mseb) mousetrap(5);
	count=0;
	while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
	if (count!=CLICKRATE)
		dble=1;
}
else{
	mousecur(0);
	dble=edit_text( G_headt, G_ypstart, G_yphead-10);
	while (mseb) mousetrap(5);
	if( G_headt==0 && !dble)
		G_headt=G_curt;
	mousecur(1);
}
if( dble){
	G_headtext=in_textbox( G_headtext, "HEAD");
	return(1);
}
return(0);
}

int in_mainbox()
{
int count,found=0,dble=0;
int chgd=0;

found = find_text( G_maintext);
if( found){
	chgd=move_text( G_cur_text, G_yphead+11, G_ypmain-10);
	if( chgd)
		draw_reptext( G_maintext, G_cur_text, G_maint);
	while (mseb) mousetrap(5);
	count=0;
	while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
	if (count!=CLICKRATE)
		dble=1;
}
else{
	mousecur(0);
	dble=edit_text( G_maint, G_yphead+11, G_ypmain-10);
	while (mseb) mousetrap(5);
	if( G_maint==0 && !dble)
		G_maint=G_curt;
	mousecur(1);
}
if( dble){
	G_maintext=in_textbox( G_maintext, "MAIN");
	return(1);
}
return(0);
}

int in_footbox()
{
int count,found=0,dble=0;
int chgd=0;

found = find_text( G_foottext);
if( found){
	chgd=move_text( G_cur_text, G_ypmain+11, G_ypfoot-10);
	if( chgd)
		draw_reptext( G_foottext, G_cur_text, G_foott);
	while (mseb) mousetrap(5);
	count=0;
	while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
	if (count!=CLICKRATE)
		dble=1;
}
else{
	mousecur(0);
	dble=edit_text( G_foott, G_ypmain+11, G_ypfoot-11);
	while (mseb) mousetrap(5);
	if( G_foott==0 && !dble)
		G_foott=G_curt;
	mousecur(1);
}
if( dble){
	G_foottext=in_textbox( G_foottext, "FOOT");
	return(1);
}
return(0);
}

void draw_reptext(struct com *start, struct com *current, struct text *firstt)
{
struct com *point;
struct text *pointt;

point=start;
setcolor( YELLOW);
settextjustify( LEFT_TEXT, TOP_TEXT);
while(point!=0){
	if( point==current){
		setcolor( LIGHTCYAN);
/*		outtextxy(point->xscr, point->yscr, point->text);*/
		printxy(point->xscr, point->yscr, point->text);
		setcolor( YELLOW);
	}
	else
/*		outtextxy(point->xscr, point->yscr, point->text);*/
		printxy(point->xscr, point->yscr, point->text);
	point=point->next;
}

pointt=firstt;
while( pointt!=0){
/*	outtextxy( pointt->xpos, pointt->ypos, pointt->text);*/
	printxy( pointt->xpos, pointt->ypos, pointt->text);
	pointt=pointt->next;
}

}

int find_text( struct com *point)
{
int wid;

settextjustify( LEFT_TEXT, TOP_TEXT);
while(point != 0){
	wid=strlen(point->text)*w;
	if(inbox( point->xscr, WINY+point->yscr-1, point->xscr+wid, WINY+point->yscr+12)){
		mousecur(0);
/*		outtextxy(G_cur_text->xscr, G_cur_text->yscr, G_cur_text->text);*/
		printxy(G_cur_text->xscr, G_cur_text->yscr, G_cur_text->text);
		G_cur_text=point;
		setcolor( LIGHTCYAN);
		printxy(point->xscr, point->yscr, point->text);
		setcolor( YELLOW);
		mousecur(1);
		return(1);
	}
	else
		point=point->next;
}
return(0);
}

int move_text( struct com *point, int start, int end)
{
int chgd, xp, yp, wid;

changesmade=1;
wid=strlen(point->text)*w;
xp=msex-point->xscr;
yp=msey-point->yscr;
mousecur(0);
while( mseb) {
	if( mousetrap(5)!=32 ){
		chgd=1;
		setcolor(DARKGRAY);
		printxy(point->xscr, point->yscr, point->text);
		if(msex-xp<17+80*w-wid && msex-xp>16)
			point->xscr=msex-xp;
		else{
			if(msex-xp<=16)
				point->xscr=16;
			else
				point->xscr=17+80*w-wid;
		}
		if(msey-yp>start && msey-yp<end)
			point->yscr=msey-yp;
		else{
			if(msey-yp<=start)
				point->yscr=start;
			else
				point->yscr=end;
		}
		setcolor(LIGHTCYAN);
		printxy(point->xscr, point->yscr, point->text);
		setcolor( YELLOW);
	}
}
mousecur(1);
return( chgd);
}

int in_sectionwin(char whichsection)
{
int count=0;

if( G_cur_text!=0){
	printxy(G_cur_text->xscr, G_cur_text->yscr, G_cur_text->text);
	G_cur_text=0;
}
while (mseb) mousetrap(5);
while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
if (count!=CLICKRATE) {
	switch( whichsection){
		case 'H':
			G_headcom=section_cmd( G_headcom, 'H', G_ypstart-4);
			break;
		case 'M':
			G_maincom=section_cmd( G_maincom, 'M', G_yphead+6);
			break;
		case 'F':
			G_footcom=section_cmd( G_footcom, 'F', G_ypmain+6);
			break;
	}
	return(1);
}
return(0);

}

struct com *section_cmd( struct com *start, char sectiontype, int startyp)
{
struct com *cur=0, *newcur, *lastcur;
int gotone=0,curpos,count;

draw_section( start, sectiontype, startyp);
while (mseb) mousetrap(5);
if( start!=0){
	cur=start;
	select_com( 0, cur, 0, 0);
}
while(1){
	if (kbhit()) {
		switch (getch()) {
			case 27:    			/*Escape key*/
				return(start);
			case 0:
				switch(getch()){
					case 'S':
						if( cur!=0){
							if( cur->prev!=0)
								(cur->prev)->next=cur->next;
							if( cur->next!=0)
								(cur->next)->prev=cur->prev;
							if( start==cur)
								start=cur->next;
							if( cur->next!=0)
								newcur=cur->next;
							else
								newcur=cur->prev;
							freecom( cur);
							if( cur==start){
								start=0;
								cur=0;
							}
							else
								cur=newcur;
							draw_section( start, sectiontype, startyp);
							if(cur!=0)
								select_com( 0, cur,0,0);
						}
						break;
				}
		}
	}
	if (mousetrap(5)) {
		if (mseb==1) {
			if( inbox( 520, 30+WINY, 620, 407+WINY))
				select_option();
			if( inbox(18+30*w,WINY+startyp+11,18+50*w,WINY+startyp+99)){
				newcur=start;
				gotone=0;
				curpos=msey-WINY;
				while( newcur!=0 && !gotone){
					if( curpos>=newcur->ypos && curpos<=newcur->ypos+11)
						gotone=1;
					else
						newcur=newcur->next;
				}
				if( gotone && newcur!=cur){
					select_com( cur, newcur, 0, 0);
					cur=newcur;
				}
				else if(!gotone){
					if( cur!=0)
						select_com( cur, 0, startyp, curpos);
					cur=0;
				}
				while (mseb) mousetrap(5);
				count=0;
				while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
				mousetrap(5);
				if (count!=CLICKRATE){
					if( !gotone){
						command_box("FOOT");
						lastcur=start;
						if( lastcur!=0)
							while( lastcur->next!=0)
								lastcur=lastcur->next;
						cur=addtoeol( &start);
						cur=edit_command(cur, "FOOT", 1, 1);
						if( cur==0)
							cur=lastcur;
						if( cur!=0)
							cur->next=0;
						else
							start=0;
						draw_reportwin(G_choice);
						draw_section( start, sectiontype, startyp);
						if(cur!=0)
							select_com( 0, cur,0,0);
					}
					else if(inbox(18+30*w, cur->ypos+WINY, 18+50*w, cur->ypos+WINY+11)){
						command_box("FOOT");
						cur=edit_command( cur, "FOOT", 0, 1);
						draw_reportwin(G_choice);
						draw_section( start, sectiontype, startyp);
						select_com( 0, cur,0,0);
					}
				}
			}
		}
	}
}

}
void draw_section( struct com *start, char sectiontype, int startyp)
{
int footyp,i;
struct com *point;
char type[50];

switch( sectiontype){
	case 'H':
		strcpy( type, "REPORT HEADER");
		break;
	case 'M':
		strcpy( type, "MAIN");
		break;
	case 'F':
		strcpy( type, "REPORT FOOTER");
		break;
}
footyp=startyp+9*11;
point=start;
settextjustify(CENTER_TEXT,TOP_TEXT);
mousecur(0);
setfillstyle( 1, BLACK);
setcolor(YELLOW);
bar( 18+30*w, startyp-4, 18+50*w, footyp);
outtxtxy(18+40*w,startyp-3,type);
rectangle( 18+30*w, startyp-4, 18+50*w, footyp);
settextjustify( LEFT_TEXT, TOP_TEXT);
for(i=1;i<9;i++){
	line(18+30*w, startyp+i*11, 18+50*w, startyp+i*11);
	if( point!=0){
		point->ypos=startyp+i*11+1;
		printxy(19+30*w,point->ypos,point->text);
		point=point->next;
	}
}
mousecur(1);

}
void select_com( struct com *oldcur, struct com *cur, int startyp, int curpos)
{
static int oldpos=0;

mousecur(0);
settextjustify( LEFT_TEXT, TOP_TEXT);
if( cur!=0){
	line(19+30*w, cur->ypos-1, 19+50*w, cur->ypos-1);
}
if( oldcur!=0){
	bar(19+30*w, oldcur->ypos, 17+50*w, oldcur->ypos+9);
	printxy(19+30*w,oldcur->ypos,oldcur->text);
}
else if(oldpos!=0)
	bar(19+30*w, oldpos, 17+50*w, oldpos+9);
setfillstyle( 1, LIGHTCYAN);
setcolor(BLUE);
if( cur!=0){
	bar(19+30*w, cur->ypos, 17+50*w, cur->ypos+9);
	printxy(19+30*w,cur->ypos,cur->text);
}
else
	bar(19+30*w, startyp+((curpos-startyp)/11)*11+1, 17+50*w, startyp+((curpos-startyp)/11)*11+10);
setfillstyle( 1, BLACK);
setcolor(YELLOW);
if( cur==0)
	oldpos=startyp+((curpos-startyp)/11)*11+1;
else
	oldpos=0;
mousecur(1);

}
struct com *addtoeol( struct com **start)
{
struct com *new, *point;

if( *start==0){
	*start=(struct com *)malloc( sizeof( struct com));
	setupdict(*start);
	return( *start);
}
point=*start;
while( point->next!=0)
	point=point->next;

new=(struct com *)malloc( sizeof( struct com));
setupdict( new);
point->next=new;
new->prev=point;
return(new);
}

void fld_spec_change( int fldspec, int key, struct com *cmd)
{
int i;
struct fld_spec *spec;
/* change the current field spec value */

spec=cmd->spec;
if( key==-2){
	switch(fldspec){
		case 1:
			if( spec->type>0)
				spec->type=spec->type-1;
			else
				spec->type=4;
			break;
		case 2:
			if( spec->just>0)
				spec->just=spec->just-1;
			else
				spec->just=2;
			break;
		case 3:
			if( spec->padding>0)
				spec->padding=spec->padding-1;
			else
				spec->padding=1;
			break;
		case 4:
			if( spec->zero>0)
				spec->zero=spec->zero-1;
			else
				spec->zero=1;
			break;
		case 5:
			if( spec->attr>0)
				spec->attr=spec->attr-1;
			else
				spec->attr=3;
			break;
		case 6:
			if( spec->width>0)
				spec->width--;
			break;
		case 7:
			if( spec->dec_width>0)
				spec->dec_width--;
			break;
	}
write_spec( spec, fldspec);
return;
}

if( key==-1){
	switch(fldspec){
		case 1:
			if( spec->type<4)
				spec->type=spec->type+1;
			else
				spec->type=0;
			break;
		case 2:
			if( spec->just<2)
				spec->just=spec->just+1;
			else
				spec->just=0;
			break;
		case 3:
			if( spec->padding==0)
				spec->padding=1;
			else
				spec->padding=0;
			break;
		case 4:
			if( spec->zero==0)
				spec->zero=1;
			else
				spec->zero=0;
			break;
		case 5:
			if( spec->attr<3)
				spec->attr=spec->attr+1;
			else
				spec->attr=0;
			break;
		case 6:
			spec->width++;
			break;
		case 7:
			if( spec->dec_width<98)
				spec->dec_width++;
			break;
	}
write_spec( spec, fldspec);
return;
}

switch( fldspec){
	case 1:
		for( i=0;i<5;i++)
			if( key==field_types[i][0] || key==field_types[i][0]+32){
				spec->type=i;
				i=6;
			}
		break;
	case 2:
		for( i=0;i<3;i++)
			if( key==just[i][0] || key==just[i][0]+32){
				spec->just=i;
				i=6;
			}
		break;
	case 3:
		for( i=0;i<2;i++)
			if( key==padding[i][0] || key==padding[i][0]+32){
				spec->padding=i;
				i=6;
			}
		break;
	case 4:
		for( i=0;i<2;i++)
			if( key==zero[i][0] || key==zero[i][0]+32){
				spec->zero=i;
				i=6;
			}
		break;
	case 5:
		for( i=0;i<3;i++)
			if( key==attr[i][0] || key==attr[i][0]+32){
				spec->attr=i;
				i=6;
			}
		break;
}
write_spec( spec, fldspec);
}

void fld_spec(int fldspec, struct com *cmd)
{
struct fld_spec *spec;
/* place the cursor in the given field spec box */

if( cmd->spec==0){
	cmd->spec=(struct fld_spec *)malloc( sizeof( struct fld_spec));
	spec=cmd->spec;
	spec->type=0;
	spec->just=0;
	spec->padding=0;
	spec->zero=0;
	spec->attr=0;
	spec->width=0;
	spec->dec_width=0;
}
else
	spec=cmd->spec;

write_spec(spec, fldspec);

}
void write_spec( struct fld_spec *spec, int fldspec)
{

mousecur(0);
setcolor( RED);
setfillstyle(1, LIGHTGRAY);
settextjustify( LEFT_TEXT, TOP_TEXT);
bar(G_curx+(16*w),G_cury+43,G_curx+(23*w),G_cury+53);
outtxtxy(G_curx+(16*w)+2,G_cury+42, field_types[spec->type]);
bar(G_curx+(40*w),G_cury+43,G_curx+(47*w),G_cury+53);
outtxtxy(G_curx+(40*w)+2,G_cury+42, just[spec->just]);
bar(G_curx+(65*w),G_cury+43,G_curx+(72*w),G_cury+53);
outtxtxy(G_curx+(65*w)+2,G_cury+42, padding[spec->padding]);
bar(G_curx+(16*w),G_cury+63,G_curx+(20*w),G_cury+73);
outtxtxy(G_curx+(16*w)+2,G_cury+62, zero[spec->zero]);
bar(G_curx+(40*w),G_cury+63,G_curx+(50*w),G_cury+73);
outtxtxy(G_curx+(40*w)+2,G_cury+62, attr[spec->attr]);
if( fldspec!=6){
	bar(G_curx+(65*w),G_cury+63,G_curx+(70*w),G_cury+73);
	outixy(G_curx+(65*w)+2,G_cury+62, spec->width);
}
if( fldspec!=7){
	bar(G_curx+(75*w),G_cury+63,G_curx+(77*w),G_cury+73);
	outixy(G_curx+(75*w)+2,G_cury+62, spec->dec_width);
}
if( fldspec>0){
	setcolor( BLUE);
	setfillstyle(1, LIGHTCYAN);
	switch( fldspec){
		case 1:
			bar(G_curx+(16*w),G_cury+43,G_curx+(23*w),G_cury+53);
			outtxtxy(G_curx+(16*w)+2,G_cury+42, field_types[spec->type]);
			break;
		case 2:
			bar(G_curx+(40*w),G_cury+43,G_curx+(47*w),G_cury+53);
			outtxtxy(G_curx+(40*w)+2,G_cury+42, just[spec->just]);
			break;
		case 3:
			bar(G_curx+(65*w),G_cury+43,G_curx+(72*w),G_cury+53);
			outtxtxy(G_curx+(65*w)+2,G_cury+42, padding[spec->padding]);
			break;
		case 4:
			bar(G_curx+(16*w),G_cury+63,G_curx+(20*w),G_cury+73);
			outtxtxy(G_curx+(16*w)+2,G_cury+62, zero[spec->zero]);
			break;
		case 5:
			bar(G_curx+(40*w),G_cury+63,G_curx+(50*w),G_cury+73);
			outtxtxy(G_curx+(40*w)+2,G_cury+62, attr[spec->attr]);
			break;
		case 6:
			bar(G_curx+(65*w),G_cury+63,G_curx+(70*w),G_cury+73);
			outixy(G_curx+(65*w)+2,G_cury+62, spec->width);
			break;
		case 7:
			bar(G_curx+(75*w),G_cury+63,G_curx+(77*w),G_cury+73);
			outixy(G_curx+(75*w)+2,G_cury+62, spec->dec_width);
			break;
	}
}
setcolor(YELLOW);
mousecur(1);

}
