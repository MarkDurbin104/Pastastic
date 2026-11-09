#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <io.h>
#include <dos.h>
#include <string.h>
#include <malloc.h>
#include <memory.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpa.h"
#include "config.h"
#include "gdcsort.h"
#ifdef CTOS
  static struct bRet {
	hwId, clMemSize, xBusModIds[8], iBusModIds[5];
  } *pbRet;
  static void *pRq;
  #define GetClusterId  @
  #include <ctos.lib.h>
#endif //CTOS

extern OFFICED G_office;
extern void errorline (CHAR *e,INT type);
typedef double VARTYPE;
extern VARTYPE G_vars[50];

#ifdef DOS
#ifdef WIEN
extern INT isbegintxn;
PUBLIC void       displog       (INT loglev);
#endif//WIEN
#endif//DOS

extern void removelogt(INT G_loglev);
extern void redrawform(void);
extern NAMEINDEX *G_actnbuf;
extern INT G_numn;
extern void cursor(INT x,INT y,INT num);
extern CHAR *formatstr(CHAR *s,CHAR *fmt,INT len);
extern void remtspace(UCHAR *s);


typedef struct {
	char t;
	int  d;
	char c[20];
	char l0[80];
	char l1[80];
} ALARMDEF;
ALARMDEF *G_calm=NULL;
ALARMDEF *G_als[400];
int G_numals=0;
char G_appt[20];
char G_line[2][80];
int G_calmod=0;
int DBUG;
//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   int funcname(void);

INT            myvoid       (void);
INT            actcomit     (void);
INT            actbgntx     (void);
INT            actrlbck     (void);
INT            rcpcomit     (void);
INT            rcpbgntx     (void);
INT            rcprlbck     (void);
INT            logsumme     (void);
INT            wsnummer     (void);
INT            gewfrmt      (void);
INT            geldfrmt     (void);
INT            mengfrmt     (void);
INT            myscale      (void);
#ifdef WIEN
INT            getoname     (void);
INT            getoplz      (void);
INT            getostreet   (void);
INT            setoname     (void);
INT            getodets     (void);
INT            setodets     (void);
#endif
INT            clearlog     (void);
INT            logcount     (void);
INT            breakpnt     (void);
INT            getgebar     (void);
INT            statline     (void);
INT            GetVerrgr    (void);
INT            Store2Memstor (void);
INT            ShowLog      (void);
INT            ToVenus      (void);
INT            BrieflosDruck     (void);
INT            GDCSort      (void);
INT            AWCSort      (void);
INT            CWaitInp     (void);
INT            AdmExit      (void);
//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"
FILE *trans_file_fp;
//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------

INT myvoid (void)
{
  if(strcmp(G_form.name,"serve")==0) {
	voidlog(0);
  }
  return(1);
}

//Commits the current Database-Transaction
INT actcomit(void)
{
   sendmsg("DBM",MESSAGE_ct);
   PUSHN(1);
   return(1);
}

//Begins a Database-Transaction
INT actbgntx(void)
{
   sendmsg("DBM",MESSAGE_bt);
   return(1);
}

//Rolback of the current Database-Transaction
INT actrlbck(void)
{
   sendmsg("DBM",MESSAGE_rb);
#ifdef DOS
   errorline("ROLLBACK",1);
#endif
   return(1);
}

//Commits the current Database-Transaction (Turbostore)
INT rcpcomit(void)
{
   sendmsg("DBM",MESSAGE_rct);
   PUSHN(1);
   return(1);
}

//Begins a Database-Transaction (Turbostore)
INT rcpbgntx(void)
{
   sendmsg("DBM",MESSAGE_rbt);
   return(1);
}

//Rolback of the current Database-Transaction (Turbostore)
INT rcprlbck(void)
{
   sendmsg("DBM",MESSAGE_rrb);
   return(1);
}

//Returns the logtotal to the 4GL
INT logsumme(void)
{
  PUSHS(logtotal(0));
  return(1);
}

//Function for checking of the Workstationnumber
INT wsnummer(void)
{
#ifdef DOS
  PUSHN(123);
#endif//DOS
#ifdef CTOS
  int erc;
  erc=GetClusterId(pRq,pbRet);
#endif//CTOS   
  return 1;
}

int frmtfrmt(VARTYPE l,char *o,char *m)
{
char u[16],f[32],k[32],*pu,*pf,*pm,c;
int si=0;

strcpy(k+1,m);
m=k+1;
//if(l==-2147483648){
//	strcpy(u+1,"2147483648");
//}
//else{
//	if(l<0)l=-l;
//	sprintf(u+1,"%ld",l);
//}
	sprintf(u+1,"%0.0lf",l);
   printf("Value = %lf %s\n",l,u+1);
pf=&f[31];
*(pf)=0;
pu=&(u[strlen(u+1)]);
pm=&(m[strlen(m)-1]);
while(pm>=m){
	c=*(pm--);
	if((c!='Z')&&(c!='9')){
		if((pu>u)||si){
			*(--pf)=c;
		}
		continue;
	}
	if(c=='9')si=1;else si=0;
	if(pu>u){
		*(--pf)=*(pu--);
		continue;
	}
	if(!si)break;
	*(--pf)='0';
}
strcpy(o,pf);
    return 1;
}

//Converts the contents of G_vars[0] (v[0] in the 4GL) into a formatted
//weight-string (max 2,147.483,648)
int gewfrmt(void)
{
   char tmp[32];
   frmtfrmt(G_vars[0],tmp,"ZZZ.ZZZ.ZZ9,999");
   PUSHS(tmp);
   return(1);
}

//Converts the contents of G_vars[0] (v[0] in the 4GL) into a formatted
//money-string (max 21,474.836,48)
int geldfrmt(void)
{
   char tmp[32],tmp1[32];
   frmtfrmt(G_vars[0],tmp,"ZZZ.ZZZ.ZZZ.ZZ9,99");
   if(G_vars[0]<0) {
     strcpy(tmp1,"-");
     strcat(tmp1,tmp);
   }
   else strcpy(tmp1,tmp);
   PUSHS(tmp1);
   return(1);
}

//Converts the contents of G_vars[0] (v[0] in the 4GL) into a formatted
//integer-string (max 2,147,483.648)
int mengfrmt(void)
{
   char tmp[32];
   frmtfrmt(G_vars[0],tmp,"ZZZ.ZZZ.ZZZ,ZZ9");
   PUSHS(tmp);
	return(1);
}

INT myscale(void)
{
  PUSHN(sendmsg("SCALE",'i'));
  return(1);
}

#ifdef WIEN
//gets the office town of the office-details-file
INT getoname(void)
{ 
  char name[20];
  ENTRY(740);
  if (!getoffdet(OFFICE_L  ,name)) RETURNV(0);
  PUSHS(name);
  RETURNV(1);
}

INT getoplz(void)
//gets the office plz of the office-details-file
{
  char name[20];
  ENTRY(740);
  if (!getoffdet(OFFICE_P  ,name)) RETURNV(0);
  PUSHS(name);
  RETURNV(1);
}

INT getostreet(void)
//gets the office street of the office-details-file
{
  char name[20];
  ENTRY(740);
  if (!getoffdet(OFFICE_N  ,name)) RETURNV(0);
  PUSHS(name);
  RETURNV(1);
}

INT setoname(void)
{
	ENTRY(750);
	if (!setoffdet(OFFICE_L  ,G_formvars[G_form.curitem])) RETURNV(0);
	RETURNV(1);
}

INT getodets(void)
{
	ENTRY(760);
	if (!getoffdet(OFFICE_N  ,G_formvars[G_form.curitem+1])) RETURNV(0);
	if (!getoffdet(OFFICE_L  ,G_formvars[G_form.curitem+2])) RETURNV(0);
	if (!getoffdet(OFFICE_P  ,G_formvars[G_form.curitem+3])) RETURNV(0);
	RETURNV(1);
}

INT setodets(void)
{
	ENTRY(770);
	if (!setoffdet(OFFICE_N  ,G_formvars[G_form.curitem-2])) RETURNV(0);
	if (!setoffdet(OFFICE_L  ,G_formvars[G_form.curitem-1])) RETURNV(0);
	if (!setoffdet(OFFICE_P  ,G_formvars[G_form.curitem-0])) RETURNV(0);
	RETURNV(1);
}
#endif

//Clears all logentries for the current customer
INT clearlog(void) {
  removelogt(G_loglev);
  return(0);
}

//Returns the amount of open logentries
INT logcount(void) {
  PUSHN(G_numt);
  return 1;
}

//Dummy-Function to enter the debugger
INT breakpnt (void) {
  return 1;
}

INT getgebar(void)
{
  if (!sendmsg("DBM",MESSAGE_p,"tempgeb","gebstat","0")) RETURNV(0);
  if (!sendmsg("DBM",MESSAGE_p,"tempgeb","verrgr",G_formvars[G_form.curitem])) RETURNV(0);
  if (!sendmsg("DBM",MESSAGE_sp,"tempgeb",2,FRST)) RETURNV(0);
  if (!sendmsg("DBM",MESSAGE_r,"tempgeb",(LONG)CURR)) RETURNV(0);
  if (!sendmsg("DBM",MESSAGE_g,"tempgeb","gebar",G_formvars[G_form.curitem])) RETURNV(0);
  RETURNV(1);
}

INT statline(void)
//outputs a statusline on the screen, the string is written in glob0
{
  INT s=(INT)sendmsg("OUTPUT1",MESSAGE_i);
  sendmsg("OUTPUT1",MESSAGE_S,0);
  sendmsg("OUTPUT1",MESSAGE_o,1,21,G_globs[0]);
  sendmsg("OUTPUT1",MESSAGE_S,s);
  RETURNV(1);
}

INT islogon(void)
{
DBUG=1;
return 1;
}

INT islogoff(void)
{
DBUG=0;
return 1;
}

INT GetVerrgr(void)
//gets the "Verrechnungsgruppe" out of "tempgeb"
{
  char buf[40];
  if (!sendmsg("DBM",MESSAGE_g,"tempgeb","verrgr",buf)) RETURNV(0);
  PUSHS(buf);
  RETURNV(1);
}

INT Store2Memstor(void)
//Copies the prod-table and the gebarung-table into memstores product and tempgeb
{
#ifdef CTOS
  runaction("BCOPYMST");
//  int ststatus=1;
//  sendmsg("DBM",MESSAGE_bt);
//  if (!sendmsg("DBM",MESSAGE_r,"prod",(LONG)FRST)) ststatus=0;
//  do {
//    if (!sendmsg("DBM",MESSAGE_cr,"product","prod")) ststatus=0;
//  } while (sendmsg("DBM",MESSAGE_r,"prod",(LONG)NEXT));
//  if (!sendmsg("DBM",MESSAGE_r,"gebarung",(LONG)FRST)) ststatus=0;
//  do {
//    if (!sendmsg("DBM",MESSAGE_cr,"tempgeb","gebarung")) ststatus=0;
//  } while (sendmsg("DBM",MESSAGE_r,"gebarung",(LONG)NEXT));
//  if (ststatus) sendmsg("DBM",MESSAGE_ct);
//  else sendmsg("DBM",MESSAGE_rb);
#else
  runaction("ACOPYMST");
#endif
  RETURNV(1);
}

//Redraws the Transactionlog
INT ShowLog(void)
{
  displog(0);
  RETURNV(1);
}


INT ToVenus(void) {
#ifdef CTOS
  
#else
  errorline("UMSCHALTEN ZU VENUS",1);
#endif
  RETURNV(1);
}

INT BrieflosDruck(void) {
//DAtum von in G_globs[0] (DATE(8))
//Datum bis in G_globs[1] (DATE(8))
  RETURNV(1);
}


int cmpsrtk(char **k1,char **k2)
{
if (*((unsigned int *)(*k1))!=*((unsigned int *)(*k2)))
   if (*((unsigned int *)(*k1))>*((unsigned int *)(*k2)))
	   return(1);else return(-1); 
if (*((unsigned long *)((*k1)+2))!=*((unsigned long *)((*k2)+2)))
   if (*((unsigned long *)((*k1)+2))>*((unsigned long *)((*k2)+2)))
	   return(1);else return(-1); 
return(0);
}

int blcmp(struct str_blsrt *s1,struct str_blsrt *s2)
{
if(s1->date!=s2->date)if(s1->date>s2->date)return(1);else return(-1);
return(0);
}

unsigned int cnvch2ui(char *p)
{
unsigned int s;

s=(*(p++)-'0')*10;
s+=*p-'0';
return(s);
}


unsigned int cnvdateui(char *p)
{
unsigned int s;

s=cnvch2ui(p);
p+=2;
s<<=4;
s+=cnvch2ui(p);
p+=2;
s<<=5;
s+=cnvch2ui(p);
return(s);
}


unsigned long cnvtimeul(char *p)
{
unsigned long s;

s=cnvch2ui(p);
p+=2;
s<<=6;
s+=cnvch2ui(p);
p+=2;
s<<=6;
s+=cnvch2ui(p);
p+=2;
s<<=7;
s+=cnvch2ui(p);
return(s);
}

unsigned long cnvstrul(char *p,int l)
{
unsigned long s=0;
char c;

if(*p=='-'){
	p++;
	l--;
}
while(l-->0){
	c=*(p++)-'0';
	if(c<0||c>9)break;
	s*=10;
	s+=c;
}
return(s);
}

void copy_ser(char *d,char *s)
{
unsigned int u;

u=*((unsigned int *)s);
if(u>999)u-=1000;
sprintf(d,"%-3u",u);
}

void copy_dat(char *d,char *s)
{
unsigned long l,l1;
unsigned int j,m,t;

l=*((unsigned long *)s);
l1=l;
l1>>=5;
t=(int)(l-(l1<<5));
l=l1;
l1>>=4;
m=(int)(l-(l1<<4));
j=(int)l1;
sprintf(d,"%02u-%02u-%02u",t,m,j);
}

void copy_val(char *d,char *s)
{
sprintf(d,"%-5u",*((unsigned int *)s));
}

void copy_sum(char *d,char *s)
{
sprintf(d,"%-15lu",*((unsigned long *)s));
}

void cnv_hex(char *d, char *s)
{
unsigned char cl=(unsigned char)*s; 
unsigned char ch=(unsigned char)*s; 

ch>>=4;
cl-=(ch<<4);
if(ch<10)*d=ch+48;else *d=ch+55;
d++;
if(cl<10)*d=cl+48;else *d=cl+55;
}

void cop_hex(char *d,char *s,int l)
{
int i;
for(i=0;i<l;i++){
	if(!(i%2))*(d++)=' ';
	cnv_hex(d,s);
	d+=2;
	s++;
}
}

int GDCSort(void)
{
static unsigned int reccnt=0,reccntb=0,reccntr=0,blkcnt=0,blkcntr=0;
static char *pblk[MAXBLK];
static char *pb,*pb1,*pbk,*pbv;
static char **pk=0;
static struct str_blsrt blser,*tser,*tserv;
static unsigned int vs,tcnt,tcntv,blcntk,blcntv,ci,cj;
char func;
static struct str_blsrt *pc,*pcbs;
unsigned int d,acnt[8],u,v;
unsigned long t,quntty,amount,qt;
int i;

func=G_globs[0][0];
switch (func){
	case 'C':
		if(reccnt){
			for(i=0;i<blkcnt;i++)free(pblk[i]);
			free(pk);
			free(tser);
			free(tserv);
			pk=0;
			reccnt=0;
			reccntb=0;
			reccntr=0;
			blkcnt=0;
			blkcntr=0;
			return(1);
		}
		break;
	case 'R':
	case 'r':  //Brieflos
		if (reccnt>=MAXREC)return(0);
		if (!reccnt){
			if ((pk=malloc(64000U))==0)return(0);
			if ((tser=malloc(sizeof(struct str_blsrt)*300))==0)return(0);
			if ((tserv=malloc(sizeof(struct str_blsrt)*300))==0)return(0);
		}
		if (!reccntb){
			if ((pb=malloc(64000U))==0)return(0);
			pblk[blkcnt++]=pb;
		}
		if(func=='R'){
			d=cnvdateui(&(G_globs[0][8]));
			t=cnvtimeul(&(G_globs[0][16]));
		}
		else{
			d=(unsigned int)cnvstrul(G_globs[1],3); //Brieflos
			if(G_globs[0][33]=='1')d+=1000;         //Verschl.
			t=(unsigned long)cnvdateui(&(G_globs[0][8]));
		}
		pk[reccnt]=pb;
		memcpy(pb,&d,2);
		pb+=2;
		memcpy(pb,&t,4);
		pb+=4;
		if(func=='R'){
			memcpy(pb,&(G_globs[0][1]),56);     // bis amount incl.
			pb+=56;
			memcpy(pb,&(G_globs[1][0]),40);     // addinf1
			pb+=40;
			memcpy(pb,&(G_globs[2][0]),40);     // addinf2
			pb+=40;
			memcpy(pb,&(G_globs[3][0]),40);     // addinf3
			pb+=40;
			memcpy(pb,&(G_globs[4][0]),40);     // addinf4
			pb+=40;
			memcpy(pb,&(G_globs[5][0]),43);     // addinf5+WSID
			pb+=43;
		}
		else{
			memset(acnt,0,sizeof(acnt));
			qt=cnvstrul(&(G_globs[2][0]),5);            
			amount=cnvstrul(&(G_globs[0][42]),15);            
			quntty=(amount/100)/qt;
			switch(qt){
				case 10:
					acnt[0]=(int)quntty;
					break;
				case 20:
					acnt[1]=(int)quntty;
					break;
				case 50:
					acnt[2]=(int)quntty;
					break;
				case 100:
					acnt[3]=(int)quntty;
					break;
				case 1000:
					acnt[4]=(int)quntty;
					break;
				case 5000:
					acnt[5]=(int)quntty;
					break;
				case 10000:
					acnt[6]=(int)quntty;
					break;
				default:
					acnt[7]=(int)quntty;
					break;
			}
			memcpy(pb,acnt,sizeof(acnt));
			memcpy(pb+sizeof(acnt),&amount,4);
			cop_hex(&(G_globs[0][1]),pb+8,12);
			pb+=(int)(RECLEN-6);
		}            
		reccnt++;
		reccntb++;
		if(reccntb>=RpBLK)reccntb=0;
		return(1);
	case 'S':
	case 's':
		qsort(pk,reccnt,4,(QSPTR)cmpsrtk);
		if(func=='s'){
			blcntk=0;
			blcntv=0;
			u=0;
			v=1;
			pbk=0;
			pbv=0;
			pb=pk[0];
			if(*((unsigned int *)pb)<1000){
				blcntk=1;
				pbk=pb;
				memcpy(&tser[0],pb,sizeof(struct str_blsrt));
				tcnt=1;
				tcntv=0;
			}
			else{
				blcntv=1;
				pbv=pb;
				memcpy(&tserv[0],pb,sizeof(struct str_blsrt));
				tcnt=0;
				tcntv=1;
			}
			while(v<reccnt){
				pb1=pk[v];
				if(*((unsigned int *)pb1)<1000){
					if((pc=bsearch(pb1,tser,tcnt,sizeof(struct str_blsrt),(QSPTR)blcmp))==0){
						memcpy(&tser[tcnt],pb1,sizeof(struct str_blsrt));
						tcnt++;
						qsort(tser,tcnt,sizeof(struct str_blsrt),(QSPTR)blcmp);                }
					else{
						for(i=0;i<8;i++){
							pc->cnt[i]+=(*((unsigned int *)(pb1+6+i*2)));
						}
						pc->sum+=(*((unsigned long *)(pb1+22)));
					}
				}
				else{
					if(!blcntv)pbv=pb1;
					if((pc=bsearch(pb1,tserv,tcntv,sizeof(struct str_blsrt),(QSPTR)blcmp))==0){
						memcpy(&tserv[tcntv],pb1,sizeof(struct str_blsrt));
						tcntv++;
						qsort(tserv,tcntv,sizeof(struct str_blsrt),(QSPTR)blcmp);                }
					else{
						for(i=0;i<8;i++){
							pc->cnt[i]+=(*((unsigned int *)(pb1+6+i*2)));
						}
						pc->sum+=(*((unsigned long *)(pb1+22)));
					}
				}
				if(*((unsigned int *)pb)==(*((unsigned int *)pb1))&&
				   *((unsigned long *)(pb+2))==(*((unsigned long *)(pb1+2)))){
					for(i=6;i<=20;i+=2){
						*((unsigned int *)(pb+i))+=(*((unsigned int *)(pb1+i)));
					}
					*((unsigned long *)(pb+22))+=(*((unsigned long *)(pb1+22)));
				}
				else{
					if(*((unsigned int *)pb1)<1000){
						blcntk++;
					}
					else{
						blcntv++;
					}
					u=u+1;
					if(u<v){
						pk[u]=pk[v];
					}
					pb=pk[u];
				}
				v++;
			}
			reccnt=u+1;
		}
		reccntr=0;
		reccntb=0;
		blkcntr=0;
		return(1);
	case 'T':
		pb=pk[reccntr];
		pb+=6;
		memcpy(&(G_globs[0][1]),pb,56);     // bis amount incl.
		pb+=56;
		G_globs[0][57]=0;
		memcpy(&(G_globs[1][0]),pb,40);     // addinf1
		pb+=40;
		G_globs[1][40]=0;
		memcpy(&(G_globs[2][0]),pb,40);     // addinf2
		pb+=40;
		G_globs[2][40]=0;
		memcpy(&(G_globs[3][0]),pb,40);     // addinf3
		pb+=40;
		G_globs[3][40]=0;
		memcpy(&(G_globs[4][0]),pb,40);     // addinf4
		pb+=40;
		G_globs[4][40]=0;
		memcpy(&(G_globs[5][0]),pb,43);     // addinf5+WSID
		pb+=43;
		G_globs[5][43]=0;
		reccntr++;
		return(1);
	case 'N':
		 reccntr=0;
		 break;
	case 'k' :   //Return Brieflos Kunden
	case 'v' :   //Return Brieflos Verschl.
		if(!reccntr){
			if(func=='k'){
			pb=pk[0];
			reccnt=blcntk;
			}
			else{
			pb=pbv;
			reccnt=blcntv;
			}
			vs=*((unsigned int *)pb);
			memset((void *)&blser,0,sizeof(struct str_blsrt));
			blser.ser=vs;
			if(blcntk>0&&func=='v'){
			memcpy(&pk[0],&pk[blcntk],blcntv*4);
			}
		}
		if(reccntr==reccnt){
			G_globs[0][1]='t';
			copy_ser(&(G_globs[0][2]),(char *)&blser.ser);
			copy_dat(&(G_globs[0][5]),(char *)&blser.date);
			for(i=0;i<8;i++){
				copy_val(&(G_globs[0][13+i*5]),(char *)&blser.cnt[i]);
			}
			copy_sum(&(G_globs[0][53]),(char *)&blser.sum);
			if(func=='k'){
				pcbs=tser;
				cj=tcnt;
				ci=0; 
			}
			else{
				pcbs=tserv;
				cj=tcntv;
				ci=0;
			}
			memset(&blser,0,sizeof(struct str_blsrt));
			reccntr++;
			return(1);
		}
		if(reccntr>reccnt){
			if(ci<cj){
				G_globs[0][1]='D';
				copy_ser(&(G_globs[0][2]),(char *)&(pcbs->ser));
				copy_dat(&(G_globs[0][5]),(char *)&(pcbs->date));
				for(i=0;i<8;i++){
					copy_val(&(G_globs[0][13+i*5]),(char *)&(pcbs->cnt[i]));
					blser.cnt[i]+=pcbs->cnt[i];
				}
				copy_sum(&(G_globs[0][53]),(char *)&(pcbs->sum));
				blser.sum+=pcbs->sum;
				ci++;
				pcbs++;
				return(1);
			}
			else{
				if(ci==cj){
					G_globs[0][1]='T';
					for(i=0;i<8;i++){
						copy_val(&(G_globs[0][13+i*5]),(char *)&(blser.cnt[i]));
					}
					copy_sum(&(G_globs[0][53]),(char *)&(blser.sum));
					ci++;
					return(1);
				}
				else{
					strcpy(&(G_globs[0][1]),"0");
					return(1);
				}
			}
		}
		pb=pk[reccntr];
		if(*((unsigned int *)pb)==vs){
			G_globs[0][1]='d';
			copy_ser(&(G_globs[0][2]),pb);
			copy_dat(&(G_globs[0][5]),pb+2);
			for(i=0;i<8;i++){
				blser.cnt[i]+=*((unsigned int *)(pb+6+i*2));
				copy_val(&(G_globs[0][13+i*5]),pb+6+i*2);
			}
			blser.sum+=*((unsigned long *)(pb+22));
			copy_sum(&(G_globs[0][53]),pb+22);
			reccntr++;
			}
			else{
				vs=*((unsigned int *)pb);
				G_globs[0][1]='t';
				copy_ser(&(G_globs[0][2]),(char *)&blser.ser);
				copy_dat(&(G_globs[0][5]),(char *)&blser.date);
				for(i=0;i<8;i++){
					copy_val(&(G_globs[0][13+i*5]),(char *)&blser.cnt[i]);
				}
				copy_sum(&(G_globs[0][53]),(char *)&blser.sum);
				memset((void *)&blser,0,sizeof(struct str_blsrt));
				blser.ser=vs;
			}
		return(1);
	default:
		return(0);
}
return(1);
}   


INT CWaitInp(void)
{
	sendmsg("INPUT1",MESSAGE_i);
    G_form.curitem=G_form.numitem;
	return(1);
}

INT cmpawk(struct str_awk *k1,struct str_awk *k2)
{
return(k1->gr-k2->gr);
}

unsigned int cnvchtui(char *p,int c)
{
int i,t;
unsigned int s=0;

for(i=0;i<c;i++){
	t=(int)(*(p++)-'0');
	if(t<0||t>9)break;
	s*=10;
	s+=t;
}
return(s);
}

unsigned long cnvchtul(char *p,int c)
{
int i,t;
unsigned long s=0;

for(i=0;i<c;i++){
	t=(int)(*(p++)-'0');
	if(t<0||t>9)break;
	s*=10;
	s+=t;
}
return(s);
}

int AWCSort(void)
{
static unsigned int grcnt=0;
static struct str_awk awk[MAXGRP],*pk;
static char arr1[64],arr2[64];
static int ar1cnt=0,ar2cnt=0,arccnt=0;
unsigned int gr;
unsigned long mg;
char func;

func=G_globs[0][0];
switch(func){
	case 'R' :
		if(grcnt>=MAXGRP)return(0);
		gr=cnvchtui(&(G_globs[0][1]),4);
		mg=cnvchtul(&(G_globs[0][5]),8);
		if(!grcnt){
			awk[0].gr=gr;
			awk[0].mg=mg;
			grcnt=1;
			return(1);
		}
		pk=(struct str_awk *)bsearch(&gr,awk,grcnt,sizeof(struct str_awk),(QSPTR)cmpawk);
		if(!pk){
			awk[grcnt].gr=gr;
			awk[grcnt].mg=mg;
			grcnt++;
			qsort(awk,grcnt,sizeof(struct str_awk),(QSPTR)cmpawk);            
		}
		else{
			pk->mg+=mg;
		}
		return(1);
	case 'T' :
		gr=cnvchtui(&(G_globs[0][1]),4);
		pk=(struct str_awk *)bsearch(&gr,awk,grcnt,sizeof(struct str_awk),(QSPTR)cmpawk);
		if(!pk){                
		  strcpy(&(G_globs[0][1]),"0       ");
		  return(1);
		}
		else{
		  sprintf(&(G_globs[0][1]),"%lu        ",pk->mg);
		  return(1);
		}
	case 'C' :
		grcnt=0;
		return(1);
	case '1' :
		strcpy(arr1,&(G_globs[0][1]));
		ar1cnt=strlen(arr1);
		ar2cnt=0;
		arccnt=0;
		return(1);
	case '2' :
		strcpy(arr2,&(G_globs[0][1]));
		ar2cnt=strlen(arr2);
		arccnt=0;
		return(1);
	case 'A' :
		if(arccnt<ar1cnt)G_globs[0][1]=arr1[arccnt];
		else             G_globs[0][1]=' ';
		G_globs[0][2]=' ';
		G_globs[0][3]=' ';
		if(arccnt<ar2cnt)G_globs[0][4]=arr2[arccnt];
		else             G_globs[0][4]=' ';
		G_globs[0][5]=' ';
		G_globs[0][6]=' ';
		arccnt++;
		return(1);
	default :
		return(0);
}     
}


int AdmExit(void)
{
 return(1);
}
