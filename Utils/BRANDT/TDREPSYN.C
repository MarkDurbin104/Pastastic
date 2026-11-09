#include <graphics.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include "tdef.h"
#include "tdrep.h"

#define ILLEGAL		-1
#define OK			0
#define MANDATORY	1

extern struct com *G_cur_text;         /* current text item*/
extern struct text *G_curt;			/* current text item */
extern int curfield,curfile,curcmd,cur;
extern int const codes[];
extern struct com *G_headcom; 			/* commands in the header command bar */
extern struct com *G_maincom;          /*   "		"	   main */
extern struct com *G_footcom;          /*   "		"      footer*/
extern struct com *G_headtext;         /* header window commands */
extern struct com *G_maintext;         /* main window */
extern struct com *G_foottext;         /* footer window */
extern struct text *G_headt;			/* text items in the header window */
extern struct text *G_maint;			/* text items in the main window */
extern struct text *G_foott;			/* text items in the foot window */
extern int w, changesmade;
extern int G_curx, G_cury;

struct param *G_saveparm;
int G_exprcnt;

struct param *syntxck_LF( struct com *cmd)
{
if(cmd->parm!=0);
return(0);
}

struct param *syntxck_TOTALS( struct com *cmd)
{
struct param *parm;
int tspec,tno;

parm=cmd->parm;
if( cmd->spec==0){
	syntax_err( NO_FLD_SPEC);
	return(cmd->parm);
}
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code != TSPEC){
	if( parm->code!=TEXT){
		syntax_err( UNKNOWNITEM);
		return( parm);
	}
	if( sscanf( parm->text, "t%d.%d", &tspec, &tno)!=2 && sscanf( parm->text, "T%d.%d", &tspec, &tno)!=2){
		syntax_err( UNKNOWNITEM);
		return( parm);
	}
	if( tspec<0 || tspec >9){
		syntax_err( UNKNOWNTSPEC);
		return( parm);
	}
	parm->code=TSPEC;
}
parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( cmd->parm);
}
return(0);

}
struct param *syntxck_TOTAL( struct com *cmd)
{
struct param *parm;
int tspec,i,cnt;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code != TSP){
	if( parm->code==TEXT){
		if( sscanf( parm->text, "t%d", &tspec)!=1 && sscanf( parm->text, "T%d", &tspec)!=1){
			syntax_err( UNKNOWNITEM);
			return( parm);
		}
		if( tspec<0 || tspec >9){
			syntax_err( UNKNOWNTSPEC);
			return( parm);
		}
	}
	else{
		syntax_err( UNKNOWNITEM);
		return( parm);
	}
	parm->code=TSP;
}
parm=parm->next;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
while( parm!=0){
	if( (cnt=syntxck_expr( cmd, parm, 0))!=0){
		syntax_err( UNKNOWNITEM);
		for(i=1;i<cnt;i++)
			if( parm->next!=0)
				parm=parm->next;
		return( parm);
	}
	parm->soe=1;
	i=0;
	while( parm!=0 && i<G_exprcnt){
		parm=parm->next;
		i++;
	}
}
return(0);

}
struct param *syntxck_SET( struct com *cmd)
{
struct param *parm;
int spec,tno,i,cnt;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code==TEXT){
	if( sscanf( parm->text, "v%d", &spec)!=1 && sscanf( parm->text, "V%d", &spec)!=1){
		if( sscanf( parm->text, "t%d.%d", &spec, &tno)!=2){
			if( sscanf( parm->text, "T%d.%d", &spec, &tno)!=2){
				syntax_err( UNKNOWNITEM);
				return( parm);
			}
		}
		if( spec<0 || spec>9 || tno<0 || tno>9){
			syntax_err( UNKNOWNTSPEC);
			return(parm);
		}
		parm->code=TSPEC;
	}
	else{
		if( spec<0 || spec>19){
			syntax_err( VSPECERR);
			return(parm);
		}
		parm->code=VSPEC;
	}
}
if( parm->code!=VSPEC && parm->code!=TSPEC){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm=parm->next;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( (cnt=syntxck_expr( cmd, parm, 0))!=0){
	syntax_err( UNKNOWNITEM);
		for(i=1;i<cnt;i++)
			if( parm->next!=0)
				parm=parm->next;
	return( parm);
}
parm->soe=1;
i=0;
while( parm!=0 && i++<G_exprcnt)
	parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_RESET( struct com *cmd)
{
struct param *parm;
int tspec;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code==TEXT){
	if( sscanf( parm->text, "t%d", &tspec)==1 || sscanf( parm->text, "T%d", &tspec)==1){
		if( tspec<0 || tspec>9){
			syntax_err( UNKNOWNTSPEC);
			return( parm);
		}
		parm->code=TSP;
	}
	else if( strcmp( parm->text, "P")!=0 && strcmp( parm->text , "p")!=0){
		syntax_err( UNKNOWNITEM);
		return( parm);
	}
}
if( parm->code != TEXT && parm->code != TSP){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm=parm->next;
if(parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_READ( struct com *cmd)
{
struct param *parm;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code!=FILEP){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm=parm->next;
if(parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_P( struct com *cmd)
{
if(cmd->parm!=0){
	syntax_err( UNKNOWNITEM);
	return( cmd->parm);
}
return(0);

}
struct param *syntxck_NAMEOF( struct com *cmd)
{
struct param *parm;

if( cmd->spec==0){
	syntax_err( NO_FLD_SPEC);
	return(cmd->parm);
}
parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( parm);
}
if( parm->code!=FIELD){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_IF( struct com *cmd)
{
struct param *parm;
int i,cnt;
int ifno;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code!=TEXT && parm->code!=IFNO){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
if( sscanf( parm->text, "%d", &ifno)!=1){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm->code=IFNO;
parm=parm->next;
if( (cnt=syntxck_expr( cmd, parm, 0))!=0){
	syntax_err( UNKNOWNITEM);
	for(i=1;i<cnt;i++)
		if( parm->next!=0)
			parm=parm->next;
	return( parm);
}
parm->soe=1;
i=0;
while( parm!=0 && i++<G_exprcnt)
	parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_ELSE( struct com *cmd)
{
struct param *parm;
int ifno;

parm=cmd->parm;
if( parm==0){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code!=TEXT && parm->code!=IFNO){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
if( sscanf( parm->text, "%d", &ifno)!=1){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm->code=IFNO;
parm=parm->next;
if(parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);

}
struct param *syntxck_DATE( struct com *cmd)
{
if(cmd->parm!=0){
	syntax_err( UNKNOWNITEM);
	return( cmd->parm);
}
return(0);

}
struct param *syntxck_CALL( struct com *cmd)
{
struct param *parm;

parm=cmd->parm;
if( parm==0 ){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
if( parm->code==TEXT){
	parm->code=CONST;
	parm->typecode=C_TEXT;
}
if( parm->code!=CONST || parm->typecode!=C_TEXT){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
parm=parm->next;
if(parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);
}


struct param *syntxck_RANGE( struct com *cmd)
{
struct param *parm;
int i,cnt;

parm=cmd->parm;
if( parm==0 ){
	syntax_err( COMNOTFIN);
	return( 0);
}
if( parm->code!=FILEP){
	syntax_err( FILEEXP);
	return( parm);
}
parm=parm->next;
if( parm==0){
	syntax_err( NO_EXPR);
	return(cmd->parm);
}
if( (cnt=syntxck_expr( cmd, parm, 0))!=0){
	syntax_err( UNKNOWNITEM);
	for(i=1;i<cnt;i++)
		if( parm->next!=0)
			parm=parm->next;
	return( parm);
}
parm->soe=1;
i=0;
while( parm!=0 && i++<G_exprcnt)
	parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);
}

struct param *syntxck_SORT( struct com *cmd)
{
struct param *parm, *delparm;
int count, kno;
int i,j,len;

parm=cmd->parm;
if( parm==0){
	syntax_err( FILEEXP);
	return( parm);
}
if( parm->code!=FILEP){
	syntax_err( FILEEXP);
	return( parm);
}
parm=parm->next;
count=0;
if( parm==0){
	/* need SDIREC */
	syntax_err( NEEDSDIREC);
	return(parm->prev);
}
if( parm->code==TEXT || parm->code==KNO){
	if( parm->code==TEXT){
		while( resolve_text( parm)==1 && parm->next!=0){
			delparm=parm;
			parm=parm->next;
			delete_parm( cmd, delparm);
		}
		if( parm==0){
			syntax_err( FILEEXP);
			return( parm);
		}
	}
	if( sscanf( parm->text, "%d", &kno)!=1){
		syntax_err( INVALIDKNO);
		return( parm);
	}
	if( kno!=atoi( parm->text)){
		syntax_err( INVALIDKNO);
		return( parm);
	}
	parm->code=KNO;
	parm=parm->next;
	if( parm==0){
		/* need SDIREC */
		syntax_err( NEEDSDIREC);
		return(parm->prev);
	}
	if( strcmp( parm->text, "0")!=0 && strcmp( parm->text, "1")!=0){
		syntax_err( NEEDSDIREC);
		return(parm);
	}
	parm->code=SDIREC;
	return(0);
}
while( parm->next!=0){
	if( ++count>8){
		/* more than eight things */
		syntax_err( EXCEED_NEST);
		return(parm);
	}
	if( parm->code != FFIELD){
		if( parm->code!=FIELD){
			syntax_err( UNKNOWNITEM);
			return( parm);
		}
		else{
			parm->code=FFIELD;
			for(i=0; i<G_file.nofiles ;i++){
				len=strlen( G_file.files[i]);
				if( strncmp( parm->text, G_file.files[i], len)==0){
					for( j=0; j<G_file.cont[i]->nofld; j++){
						if( strcmp( &(parm->text[len+1]), G_file.cont[i]->flds[j]->name)==0){
							sprintf( parm->text, "%d", j+1);
						}
					}
				}
			}
		}
	}
	parm=parm->next;
}
if( parm->code!=TEXT && parm->code!=SDIREC){
	/* need SDIREC */
	syntax_err( NEEDSDIREC);
	return(parm);
}
if( strcmp( parm->text, "0")!=0 && strcmp( parm->text, "1")!=0){
	syntax_err( NEEDSDIREC);
	return(parm);
}
parm->code=SDIREC;
return(0);
}

struct param *syntxck_EXPR( struct com *cmd)
{
int i,cnt;
struct param *parm;

parm=cmd->parm;
if( cmd->spec==0){
	syntax_err( NO_FLD_SPEC);
	return(parm);
}
if( parm==0){
	syntax_err( NO_EXPR);
	return(parm);
}
if( (cnt=syntxck_expr( cmd, parm, 0))!=0){
	syntax_err( UNKNOWNITEM);
	for(i=1;i<cnt;i++)
		if( parm->next!=0)
			parm=parm->next;
	return( parm);
}
i=0;
while( parm!=0 && i++<G_exprcnt)
	parm=parm->next;
if( parm!=0){
	syntax_err( UNKNOWNITEM);
	return( parm);
}
return(0);
}

struct param *syntxck_FILES( struct com *cmd)
{
struct param *parm, *delparm;
int field, constant, file, op1;
int reparse=0;

parm=cmd->parm;
if( parm->code!=FILEP){
	syntax_err( FILEEXP);
	return( parm);
}
parm=parm->next;
constant=ILLEGAL;
field=OK;
file=OK;
op1=1;
while( parm!=0){
	switch( parm->code){
		case FILEP:
			if( file==ILLEGAL){
				syntax_err( FILEILL);
				return( parm);
			}
			constant=ILLEGAL;
			field=OK;
			file=ILLEGAL;
			break;
		case FIELD:
			if( field==ILLEGAL){
				syntax_err( FIELDILL);
				return( parm);
			}
			if( op1==1){
				op1=2;
				file=ILLEGAL;
				field=OK;
				constant=OK;
			}
			else{
				op1=1;
				file=OK;
				field=OK;
				constant=ILLEGAL;
			}
			break;
		case CONST:
			if( constant==ILLEGAL){
				syntax_err( CONSTILL);
				return( parm);
			}
			op1=1;
			constant=ILLEGAL;
			field=OK;
			file=OK;
			break;
		case TEXT:
			if( resolve_text( parm)==1){
				delparm=parm;
				parm=parm->next;
				delete_parm( cmd, delparm);
			}
			else
				reparse=1;
			break;
		default:
			syntax_err( UNKNOWNITEM);
			return( parm);
	}
	if( !reparse)
		parm=parm->next;
	else
		reparse=0;
}
if( op1==2){
	syntax_err( COMNOTFIN);
	return( cmd->parm);
}
return(0);
}

void syntax_err( int code)
{

static char *errtext[NBERRCODES]={"OPERATOR ILLEGAL Marked On Screen",
						"FILE ILLEGAL Marked on Screen",
						"FIELD ILLEGAL Marked on Screen",
						"UNKNOWN ITEM Marked on Screen",
						"FIELD SPECIFIER Expected With This Command",
						"UNEXPECTED PARAMETER At End Of Command",
						"FILE PARAMETER Expected At This Point",
						"NESTING LIMIT Exceeded",
						"INVALID KEY NUMBER",
						"NEED SDIREC Value As Last Parameter",
						"CONSTANT ILLEGAL Marked On Screen",
						"Unfinished Command",
						"EXPRESSION Expected",
						"TOTAL SPEC Defined Out Of Range",
						"VARIABLE Out Of Range",
						"PRIMITIVE ILLEGAL Expression Syntax Error",
						"OPERATOR ILLEGAL Expression Syntax Error",
						"UNTERMINATED PARENTHESIS In Expression" };

mousecur(0);
setfillstyle( 1, BLACK);
setcolor( YELLOW);
settextjustify( CENTER_TEXT, TOP_TEXT);
bar( 100, 180, 400, 265);
rectangle( 100, 180, 400, 265);
rectangle( 210, 185, 290, 206);
outtextxy( 250, 190, "SYNTAX ERROR");
setcolor( LIGHTCYAN);
outtextxy( 250, 214, errtext[code]);
button(250,240,"OK",0,0);
mousecur(1);
while( 1){
	if( mousetrap(5)){
		if( mseb==1){
			if( inbox(225,250,275,280)){
				mousecur(0);
				button(250, 240, "OK",1 ,1);
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

int syntxck_expr( struct com *cmd, struct param *parm, int level)
{
int primitive, operator,count,reparse=0;
int res;
struct param *tmpparm, *delparm;

primitive=OK;
operator=ILLEGAL;

count=1;
G_exprcnt=0;
while( parm!=0){
	switch( parm->code){
		case TEXT:
			if( resolve_text( parm)==1){
				delparm=parm;
				parm=parm->next;
				delete_parm( cmd, delparm);
			}
			else
				reparse=1;
			break;
		case FIELD:
		case CONST:
		case LITER:
		case PARM:
		case VSPEC:
		case TSPEC:
			if( primitive==ILLEGAL){
				if( level==0){
					G_exprcnt=count-1;
					return(0);
				}
				syntax_err( PRIMITIVEILL);
				return( count);
			}
			primitive=ILLEGAL;
			operator=OK;
			break;
		case OPERATOR:
			if( operator==ILLEGAL){
				if( parm->typecode==O_ob){
					if( (res=syntxck_expr( cmd, parm->next, level+1))>0)
						return( count+res-1);
					if( G_saveparm==0){
						if( level!=0){
							syntax_err( PAREN_UNFIN);
							return( count);
						}
						return(0);
					}
					else{
						tmpparm=parm;
						while( tmpparm!=0 && tmpparm->next!=G_saveparm){
							count++;
							tmpparm=tmpparm->next;
						}
						parm=G_saveparm;
					}
					primitive=ILLEGAL;
					operator=OK;
					break;
				}
				if( parm->typecode!=O_nt){
					syntax_err( OPERATORILL);
					return( count);
				}
				break;
			}
			if( parm->typecode==O_cb){
				if( level==0){
					syntax_err( OPERATORILL);
					return( count);
				}
				G_saveparm=parm;
				G_exprcnt=count;
				return( 0);
			}
			if( parm->typecode==O_ob){
				syntax_err( OPERATORILL);
				return( count);
			}
			primitive=OK;
			operator=ILLEGAL;
			break;
		default:
			syntax_err( UNKNOWNITEM);
			return( count);
	}
	if( !reparse)
		parm=parm->next;
	else
		reparse=0;
	count++;
}
if( operator==ILLEGAL){
	syntax_err( COMNOTFIN);
	return(count);
}
if( level!=0){
	syntax_err( PAREN_UNFIN);
	return( count);
}
G_exprcnt=count;
return(0);
}

int resolve_text( struct param *parm)
{
struct param *newparm;
char *text, oldtext[61];
char token[61];
int count, res=0;

strcpy(oldtext, parm->text);
text=oldtext;
for( count=0;count<strlen(text);count++)
	if( !isspace( text[count]))
		res=1;
if( !res){
	return(1);
}
if( text[0]!='"'){
	res=sscanf( text, "%s%n", token, &count);
	if( res<=0)
		return(0);
}
else{
	count=1;
	token[0]=text[0];
	while( text[count]!='"' && text[count]!=0){
		token[count]=text[count];
		count++;
	}
	token[count]=text[count];
	if( token[count]!=0)
		token[count+1]=0;
	count++;
}
free( parm->text);
parm->text=(char *)malloc(strlen(token)+1);
strcpy( parm->text, token);
parm->typecode=0;
parm->code=getcode(parm);

while( count<strlen(text)){
	text= &(text[count]);
	if( text[0]!='"'){
		res=sscanf( text, "%s%n", token, &count);
		if( res<=0)
			return(0);
	}
    else{
		count=1;
		token[0]=text[0];
		while( text[count]!='"' && text[count]!=0){
			token[count]=text[count];
			count++;
		}
		token[count]=text[count];
		if( token[count]!=0)
			token[count+1]=0;
		count++;
	}
	newparm=(struct param *)malloc(sizeof( struct param));
	newparm->text=(char *)malloc(strlen(token)+1);
	strcpy(newparm->text,token);
	newparm->typecode=0;
	newparm->code=getcode(newparm);
	newparm->prev=parm;
	newparm->next=parm->next;
	parm->next=newparm;
	if( newparm->next!=0)
		newparm->next->prev=newparm;
	parm=newparm;
}
return(0);
}

int getcode( struct param *parm)
{
char *text;
int inta, intb;
long int longa;
float floata;
double doublea;
char cmptext[50];

text=parm->text;
if( sscanf( text,"v%d",&inta)==1 || sscanf( text, "V%d", &inta)==1)
	return( VSPEC);
if( sscanf( text,"p%d",&inta)==1 || sscanf( text, "P%d", &inta)==1)
	return( PARM);
if( sscanf( text,"t%d.%d",&inta,&intb)==2 || sscanf( text, "T%d.%d", &inta,&intb)==2)
	return( TSPEC);

parm->typecode=0;
switch( strlen( text)){
	case 1:
		switch( text[0]){
			case '=':
				parm->typecode = O_eq;
				return(OPERATOR);
			case '>':
				parm->typecode = O_gt;
				return(OPERATOR);
			case '<':
				parm->typecode = O_lt;
				return(OPERATOR);
			case '!':
				parm->typecode = O_nt;
				return(OPERATOR);
			case '+':
				parm->typecode = O_pl;
				return(OPERATOR);
			case '-':
				parm->typecode = O_mi;
				return(OPERATOR);
			case '*':
				parm->typecode = O_ml;
				return(OPERATOR);
			case '/':
				parm->typecode = O_dv;
				return(OPERATOR);
			case '%':
				parm->typecode = O_pc;
				return(OPERATOR);
			case '(':
				parm->typecode = O_ob;
				return(OPERATOR);
			case ')':
				parm->typecode = O_cb;
				return(OPERATOR);
			case '|':
				parm->typecode = O_bo;
				return(OPERATOR);
			case '&':
				parm->typecode = O_ba;
				return(OPERATOR);
			case '~':
				parm->typecode = O_ca;
				return(OPERATOR);
		}
		break;
	case 2:
		if( text[0]=='<' && text[1]=='>'){
			parm->typecode = O_ne;
			return(OPERATOR);
		}
		if( text[0]=='<' && text[1]=='='){
			parm->typecode = O_le;
			return(OPERATOR);
		}
		if( text[0]=='>' && text[1]=='='){
			parm->typecode = O_ge;
			return(OPERATOR);
		}
		if( text[0]=='|' && text[1]=='|'){
			parm->typecode = O_lo;
			return(OPERATOR);
		}
		if( text[0]=='&' && text[1]=='&'){
			parm->typecode = O_la;
			return(OPERATOR);
		}
		break;
}
if( sscanf( text, "%d", &inta)==1){
	sprintf( cmptext, "%d", inta);
	if( strncmp( cmptext, text, strlen(text))==0){
		parm->typecode=C_INT;
		return( CONST);
	}
}
if( sscanf( text, "%ld", &longa)==1){
	sprintf( cmptext, "%ld", longa);
	if( strncmp( cmptext, text, strlen(text))==0){
		parm->typecode=C_LONG;
		return( CONST);
	}
}
if( sscanf( text, "%f", &floata)==1){
	sprintf( cmptext, "%f", floata);
	if( strncmp( cmptext, text, strlen(text))==0){
		parm->typecode=C_FLOAT;
		return( CONST);
	}
}
if( sscanf( text, "%Ld", &doublea)==1){
	sprintf( cmptext, "%Ld", doublea);
	if( strcmp( cmptext, text)==0){
		parm->typecode=C_DOUBLE;
		return( CONST);
	}
}
parm->typecode=C_TEXT;
return(CONST);


}

struct param *syntax_check( struct com *cmd)
{
struct param *res;
int i=0,found=0;

while( i<NBCMDS && !found)
	if( cmd->code==codes[i])
		found=1;
	else
		i++;
res=cmd->parm;
while(res!=0){
	res->soe=0;
	res=res->next;
}
switch( i){
	case FILES:
		res=syntxck_FILES( cmd);
		break;
	case RANGE:
		res=syntxck_RANGE( cmd);
		break;
	case SORT:
		res=syntxck_SORT( cmd);
		break;
	case EXPR:
		res=syntxck_EXPR( cmd);
		break;
	case CALL:
		res=syntxck_CALL( cmd);
		break;
	case DATE:
		res=syntxck_DATE( cmd);
		break;
	case ELSE:
		res=syntxck_ELSE( cmd);
		break;
	case IF:
		res=syntxck_IF( cmd);
		break;
	case NAMEOF:
	case FNAMEOF:
		res=syntxck_NAMEOF( cmd);
		break;
	case P:
	case PAGE:
		res=syntxck_P( cmd);
		break;
	case READ:
		res=syntxck_READ( cmd);
		break;
	case RESET:
		res=syntxck_RESET( cmd);
		break;
	case SET:
		res=syntxck_SET( cmd);
		break;
	case TOTAL:
		res=syntxck_TOTAL( cmd);
		break;
	case TOTALS:
		res=syntxck_TOTALS( cmd);
		break;
	case LF:
		res=syntxck_LF( cmd);
		break;
	default:
		res=0;
}
return(res);
}

int deletecmd(void)
{

if( G_cur_text==0)
	return(0);

if( G_cur_text->prev!=0)
	G_cur_text->prev->next=G_cur_text->next;
if( G_cur_text->next!=0)
	G_cur_text->next->prev=G_cur_text->prev;
if( G_headtext==G_cur_text)
	G_headtext=G_cur_text->next;
if( G_maintext==G_cur_text)
	G_maintext=G_cur_text->next;
if( G_foottext==G_cur_text)
	G_foottext=G_cur_text->next;
freecom( G_cur_text);
G_cur_text=0;

return(1);

}

void freeall(void)
{
struct com *curcom, *frecom;
struct text *curtxt, *freetxt;

curtxt=G_headt;
while( curtxt!=0){
	freetxt=curtxt;
	curtxt=curtxt->next;
	free_text( freetxt);
}
curtxt=G_maint;
while( curtxt!=0){
	freetxt=curtxt;
	curtxt=curtxt->next;
	free_text( freetxt);
}
curtxt=G_foott;
while( curtxt!=0){
	freetxt=curtxt;
	curtxt=curtxt->next;
	free_text( freetxt);
}
curcom=G_headtext;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
curcom=G_maintext;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
curcom=G_foottext;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
curcom=G_headcom;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
curcom=G_maincom;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
curcom=G_footcom;
while( curcom!=0){
	frecom=curcom;
	curcom=curcom->next;
	freecom( frecom);
}
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
curfile=0;
curfield=0;
curcmd=0;
cur=1;
}

int move_txt( struct text *point, int start, int end)
{
int chgd, xp, yp, wid;

setfillstyle( 1, DARKGRAY);
settextjustify( LEFT_TEXT, TOP_TEXT);
setcolor( LIGHTCYAN);
wid=strlen(point->text)*w;
bar( point->xpos, point->ypos, point->xpos+wid, point->ypos+11);
printxy( point->xpos, point->ypos, point->text);
xp=msex-point->xpos;
yp=msey-point->ypos;
mousecur(0);
while( mseb) {
	if( mousetrap(5)!=32 ){
		chgd=1;
		bar( point->xpos, point->ypos, point->xpos+wid, point->ypos+11);
		if(msex-xp<17+80*w-wid && msex-xp>16)
			point->xpos=msex-xp;
		else{
			if(msex-xp<=16)
				point->xpos=17;
			else
				point->xpos=17+80*w-wid;
		}
		if(msey-yp>start+2 && msey-yp<end)
			point->ypos=msey-yp;
		else{
			if(msey-yp<=start+2)
				point->ypos=start+2;
			else
				point->ypos=end-1;
		}
		printxy( point->xpos, point->ypos, point->text);
	}
}
mousecur(1);
setcolor( YELLOW);
bar( point->xpos, point->ypos, point->xpos+wid, point->ypos+11);
printxy( point->xpos, point->ypos, point->text);
return( chgd);
}

struct param *addtext_parm(int keypress, struct com *cmd)
{
struct param *newparm;
struct param *cursor;
int found=0;
int keyp;
int len;

if( msex>cmd->xpos && msex<cmd->xpos+strlen(cmd->ctext)*w)
	return(0);
else{
	cursor=cmd->parm;
	while(found==0 && cursor!=0){
		if(msex>=cursor->xpos-w && msex<=cursor->xpos+w*strlen(cursor->text))
			found=1;
		else
			cursor=cursor->next;
	}
	if(cursor==0){
		cursor=cmd->parm;
		if(cursor!=0)
			while(cursor->next!=0)
				cursor=cursor->next;
	}
}
newparm=(struct param *)malloc(sizeof(struct param));
newparm->text=(char *)malloc( sizeof(int)*60);
newparm->text[0]=keypress;
newparm->text[1]=0;
newparm->code=TEXT;

if(cursor==0 && cmd->parm==0){
	cmd->parm=newparm;
	newparm->prev=0;
	newparm->next=0;
}
else if( found){
	newparm->prev=cursor->prev;
	if(cursor->prev!=0)
		cursor->prev->next=newparm;
	else
		cmd->parm=newparm;
	newparm->next=cursor;
	cursor->prev=newparm;
}
else{
	newparm->prev=cursor;
	newparm->next=0;
	cursor->next=newparm;
}
len=1;
write_com( cmd);
highlight_com( cmd, 1, 0, newparm);

while( 1){
	if (mousetrap(5))
		if (mseb==1||mseb==2)
			return( newparm);
	if( kbhit()){
		switch( keyp=getch()){
			case 010 :
				if( len>0){
					newparm->text[--len]=0;
					write_com( cmd);
					highlight_com( cmd, 1, 0, newparm);
				}
				break;
			case 0:
				switch( getch()){
					case 'S':
						if( len>0){
							newparm->text[--len]=0;
							write_com( cmd);
							highlight_com( cmd, 1, 0, newparm);
						}
						break;
					default:
						return( newparm);
				}
			break;
			case 012 :
			case 015 :
			case 033 :
				return( newparm);
			default:
				if( len<59){
					newparm->text[len++]=keyp;
					newparm->text[len]=0;
					write_com( cmd);
					highlight_com( cmd, 1, 0, newparm);
				}
				break;
		}
	}
}
}

void draw_subrep(int onoff )
{
mousecur(0);
settextjustify( CENTER_TEXT, TOP_TEXT);
setfillstyle( 1, DARKGRAY);
bar(G_curx+6,G_cury+77,G_curx+32,G_cury+102);
rectangle(G_curx+6,G_cury+77,G_curx+32,G_cury+102);
settextstyle(4,0,0);
if( onoff==1)
	setcolor( LIGHTCYAN);
outtextxy( G_curx+20, G_cury+73, "S");
settextstyle(2,0,4);
if( onoff==1)
	setcolor( YELLOW);
settextjustify( LEFT_TEXT, TOP_TEXT);
mousecur(1);
}

int add_text(int x, int y, char *ln, int nochrs,int bcol,int col )
{
char tmp[80],tmp1[2];
int hgt,i,cpos,maxlen;
char k,xit=0,modifyed=0;

memset(tmp,'\0',79);
tmp[nochrs]=0;
hgt=textheight("8");
setfillstyle(1,bcol);
setcolor(col);
strcpy(tmp,ln);
maxlen=strlen(ln);
if (tmp[0]==0) {
	i=0;
}
tmp1[1]=0;
while (mousetrap(1)) ;
do {
	mousecur(0);
	bar(x-2,y+1,x+maxlen*w-w/2,y+hgt+2);
	for (i=0;i<strlen(tmp);i++) {
		tmp1[0]=tmp[i];
		outtxtxy(x+i*w,y,tmp1);
	}
	maxlen=max(maxlen,strlen(ln));
	cpos=x+i*w;
	setcolor(bcol+7);
	line(cpos,y+1,cpos,y+hgt+1);
	mousecur(1);
	while ((!kbhit())&&(!xit)) {
		if (mousetrap(G_snapto)) {
			if (mseb==1) {
				if (!inbox(x-1,WINY+y+2,cpos+1,WINY+y+hgt+2))
					xit=1;
			}
		}
	}
	setcolor(bcol);
	mousecur(0);
	line(cpos,y+1,cpos,y+hgt+1);
	mousecur(1);
	setcolor(col);
	if (!xit) {
		switch (k=getch()) {
			case 8 : { /* backspace */
				if (i>0) {
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
				if (!(modifyed)) i=0;
				if (i<nochrs) {
					if ((((i>25)&&(i<45)) || ((i>55)&&(i<75))) && (k=='\b'))
						tmp[i++]='\n';
					else
						tmp[i++]=k;
					tmp[i]=0;
					maxlen++;
				}
				modifyed=1;
			}
		}
	}
} while (!(xit));
mousecur(0);
bar(x-2,y+1,x+maxlen*w+2,y+hgt+2);
if (xit<3)
	for (i=0;i<strlen(tmp);i++) {
		tmp1[0]=tmp[i];
		outtxtxy(x+i*w,y,tmp1);
	}
mousecur(1);
strcpy(ln,tmp);
return(0);
}

int edit_text( struct text *head, int start, int end)
{
struct text *curtxt, *nextxt=0;
int chgd,count;
int done;

done=0;
curtxt=head;
while( !done && curtxt!=0){
	if( msex>=curtxt->xpos && msex<=curtxt->xpos+strlen(curtxt->text)*w && msey>=curtxt->ypos+WINY && msey<=curtxt->ypos+WINY+11){
		chgd=move_txt( curtxt, start, end);
		if( chgd)
			draw_reptext( G_headtext, G_cur_text, G_headt);
		mousecur(0);
		add_text(curtxt->xpos,curtxt->ypos,curtxt->text,60,DARKGRAY,YELLOW);
		if( strlen(curtxt->text)==0){
			nextxt=curtxt->next;
			free_text( curtxt);
		}
		mousecur(1);
		done=1;
	}
	if( nextxt!=0){
		curtxt=nextxt;
		nextxt=0;
	}
	else
		curtxt=curtxt->next;
}
if( done)
	return(0);

count=0;
while (mseb) mousetrap(5);
while ((((mousestat(5)>>5)&&7)==0)&&(count<CLICKRATE)) count++;
if (count!=CLICKRATE)
	return(1);

changesmade=1;
if( head==0){
	head=(struct text *)malloc( sizeof( struct text));
	head->next=0;
	head->prev=0;
	head->xpos=msex;
	head->ypos=msey-WINY-5;
	head->text=(char *)malloc(60*sizeof(char));
	strcpy( head->text, "");
	G_curt=head;
	while (mseb) mousetrap(5);
	mousecur(0);
	add_text(msex, msey-WINY-5, head->text, 60,DARKGRAY,YELLOW);
	if( strlen( head->text)==0)
		free_text( head);
	mousecur(1);
	return(0);
}
else{
	curtxt=head;
	while( curtxt->next!=0)
		curtxt=curtxt->next;
	curtxt->next=(struct text *)malloc( sizeof( struct text));
	curtxt->next->prev=curtxt;
	curtxt=curtxt->next;
	curtxt->next=0;
	curtxt->xpos=msex;
	curtxt->ypos=msey-WINY-5;
	curtxt->text=(char *)malloc(60*sizeof(char));
	strcpy( curtxt->text, "");
	mousecur(0);
	add_text(msex, msey-WINY-5, curtxt->text, 60,DARKGRAY,YELLOW);
	if( strlen( curtxt->text)==0)
		free_text( curtxt);
}
mousecur(1);
return(0);
}

void free_text(struct text *item)
{

if( G_headt==item)
	G_headt=item->next;
if( G_maint==item)
	G_maint=item->next;
if( G_foott==item)
	G_foott=item->next;
if( item->prev!=0)
	item->prev->next=item->next;
if( item->next!=0)
	item->next->prev=item->prev;
free( item->text);
free( item);
item=0;
}

void printxy( int x, int y, char *text)
{
int i;

for(i=0;i<strlen(text);i++)
	outcxy( x+i*w, y, text[i]);
}
