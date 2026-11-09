#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#include <sys\stat.h>

#include "gpa.h"

//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   int funcname(void);

int             printtab     (void);
int             sndfiles     (void);
int             prbar        (void);
int             dispense     (void);
int             pay          (void);
int             showg1       (void);
int             stamp1       (void);
int             stamp2       (void);
int             stsel1       (void);
int             stsel2       (void);
int             stgtct       (void);
int             stopst       (void);
int             stinz        (void);
int             stinrz       (void);
int             stgtst       (void);
int             stvost       (void);
int             strest       (void);
int             openta       (void);
int             dumptxn      (void);
int             closeta      (void);
int             reduce       (void);
int             changalr     (void);
int             coinstat     (void);
int             rcptstat     (void);
int             stmpstat     (void);
int             intbillv     (void);
int             pollbill     (void);
int             inzlbprt     (void);
int             lbstring     (void);
int             inzcc        (void);
int             ccdata       (void);
int             getmoney     (void);
int             readcard     (void);
int             prtlabel     (void);
int             laswitch     (void);

//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"
FILE *trans_file_fp;
//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------
int printtab(void)
{
	 int smode,j,cprod,lprod,qty,q=0;
	 char prod[10],qnty[10],amnt[20],name[21],tmp[40];
	 char tabl[8];
	ENTRY(5);
	 if (G_tb==NULL) RETURNV(1);

	 smode=CURR;
	 if (!strcmp(G_tb->sn,TRAN_S)) {
	while (sendmsg("DBM",'r',TRAN_S,smode)) {
		 if (!sendmsg("DBM",'g',TRAN_S,CODE,prod)) RETURNV(0);
		 if (atoi(prod)==0) {
		sendmsg("DBM",'r',TRAN_S,NEXT);
		break;
		 }
		 smode=PREV;
	}
	smode=CURR;
	sendmsg("SPRN",'I');
	getoffdet(OFFICE_N,tmp);
	if (!sendmsg("SPRN",'o',-1,0,"%s\n",tmp)) RETURNV(0);
	getoffdet(OFFICE_L,tmp);
	if (!sendmsg("SPRN",'o',-1,0,"%s\n",tmp)) RETURNV(0);
	getoffdet(OFFICE_P,tmp);
	if (!sendmsg("SPRN",'o',-1,0,"%s\n\n",tmp)) RETURNV(0);

	if (!sendmsg("SPRN",'o',-1,0,"%s\n",datestr(0))) RETURNV(0);
	if (!sendmsg("SPRN",'o',-1,0,"NAZWISKO  -  %s\n\n",G_uname)) RETURNV(0);

	strcpy(tmp,"0");
	while (sendmsg("DBM",'r',TRAN_S,smode)) {
	    if (!sendmsg("DBM",'g',TRAN_S,CODE,prod)) RETURNV(0);
		 cprod=atoi(prod);
	    if (cprod==0) break;
		 if (!sendmsg("DBM",'g',TRAN_S,QNTY,qnty)) RETURNV(0);
	    qty=atoi(qnty);
	    if (!sendmsg("DBM",'g',TRAN_S,AMNT,amnt)) RETURNV(0);
		 if (getprod(atoi(prod))) {
		if (!sendmsg("DBM",'g',PROD_S,NAME,name)) RETURNV(0);
	    }
		 else {
		strcpy(name,prod);
	    }
		 if ((cprod==1)&&(lprod!=1)) {
		for (j=0;j<35;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) RETURNV(0);
		if (!sendmsg("SPRN",'o',-1,0,"\n%-3d           RAZEM %-15s\n",q,mstr(tmp,15))) RETURNV(0);
	    }
	    if ((cprod==1)&&(lprod==1)) strcpy(name,"RESZTA");
	    if (!sendmsg("SPRN",'o',-1,0,"%-3d %15.15s %-15s\n",qty,name,mstr(mulm(amnt,qty),15))) RETURNV(0);
	    if ((cprod==1)&&(lprod==1)) if (!sendmsg("SPRN",'o',-1,0,"\n")) RETURNV(0);
	    strcpy(tmp,addm(tmp,mulm(amnt,qty)));
	    if (cprod!=1) q+=qty;
	    lprod=cprod;
	    smode=NEXT;
	}
	for (j=0;j<11;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) RETURNV(0);
	if (!sendmsg("SPRN",'o',-1,0," DZIEKUJEMY ")) RETURNV(0);
	for (j=0;j<12;j++) if (!sendmsg("SPRN",'o',-1,0,"-")) RETURNV(0);
	for (j=0;j<13;j++) if (!sendmsg("SPRN",'o',-1,0,"\n")) RETURNV(0);
	sendmsg("SPRN",'E');
    }
    smode=FRST;
	 strcpy(TRAN_S,STOK_S);
    tabl[0]='~';
    if (!strcmp(G_tb->sn,tabl)) {
	sendmsg("SPRN",'I');

	if (!sendmsg("SPRN",'o',-1,0,"%s\n",datestr(0))) RETURNV(0);
	if (!sendmsg("SPRN",'o',-1,0,"NAZWISKO  -  %s\n\n",G_uname)) RETURNV(0);
	if (!sendmsg("SPRN",'o',-1,0,"STAN POSIADANIA\n\n")) RETURNV(0);

	while (sendmsg("DBM",'r',tabl,smode)) {
	    if (!sendmsg("DBM",'g',tabl,CODE,prod)) RETURNV(0);
	    if (getprod(atoi(prod))) {
		if (!sendmsg("DBM",'g',PROD_S,NAME,name)) RETURNV(0);
	    }
		 else {
		strcpy(name,prod);
		 }
	    if (!sendmsg("DBM",'g',tabl,QNTY,qnty)) RETURNV(0);
	    if (!sendmsg("DBM",'g',tabl,AMNT,amnt)) RETURNV(0);
		 qty=atoi(qnty);
	    if (!sendmsg("SPRN",'o',-1,0,"%-3d %15.15s %-15s\n",qty,name,mstr(amnt,15))) RETURNV(0);
	    smode=NEXT;
	}
	for (j=0;j<13;j++) if (!sendmsg("SPRN",'o',-1,0,"\n")) RETURNV(0);
	sendmsg("SPRN",'E');
	 }
	 RETURNV(1);
}
//--------------------------------------------------------------------------
int sndfiles(void)
{
	char *buf;
	char *t,tmp[160],file[16];
	int i=0,j;
	ENTRY(10);
	buf=MALLOC(512);
	if (buf==NULL) RETURNV(0);
	memset(buf,0,512);
	strcpy(tmp,G_fupdate);
	t=strtok(tmp,", \t\r\n;");
	while (t!=NULL) {
		strcpy(buf+i,G_database);
		sprintf(file,"%s.*",t);
		j=sendmsg("DISK",'x',buf+i,file);
		if (j!=0) {
			i+=j;
			*(buf+i)=' ';
			i++;
		}
		t=strtok(NULL,", \t\r\n;");
	}
    i=sendmsg("LAN",'F',buf);
	FREE(buf);
    RETURNV(i);
}
int prbar(void)
{
	ENTRY(20);
	sendmsg("OUTPUT2",'C',G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
	RETURNV(1);
}
int coinstat(void)
{
	G_qnty=sendmsg("8255",'GS',G_type<<1);
	RETURNV(1);
}
int rcptstat(void)
{
	G_qnty=sendmsg("PRN",'GS');
	RETURNV(1);
}
int stmpstat(void)
{
	G_qnty=sendmsg("STAMP",'GS',G_type);
	RETURNV(1);
}
int dispense(void)
{

	ENTRY(21);
	G_error = 99;
       

	sendmsg("8255",'DC',G_type,G_qnty,&G_error);
	
/*         sendmsg("8255",'DC','D',1,&G_error);*/
/*         sendmsg("8255",'DC','d',2,&G_error);*/
	RETURNV(1);
}
int pay(void)
{
 sendmsg("8255",'PO',G_globs[3]);
 RETURNV(1);

}
int changalr(void)
{
 
   
 if((atoi(G_globs[6])) == 1)
  {
   sendmsg("8255",'SA',1);
  }
 else
  {
   sendmsg("8255",'RA');
  }
 RETURNV(1);
}


int reduce(void)
{
 sendmsg("8255",'RC',G_qnty);
 return(1);
}
int showg1(void)
{
//      beep();
	sendmsg("OUTPUT1",'o',20,20,"%s",G_globs[1]);
//      beep();
	return(1);
}
int stamp1(void)
{
int counter = 0;
int temp = 0 ;
 sendmsg ("STAMP",'S1');
 counter = sendmsg("STAMP",'C');
 /*sendmsg ("STAMP",'O',G_qnty,G_globs[4]);*/
   sendmsg ("STAMP",'O',1,1);
   if ((sendmsg("STAMP",'C') - counter)!=3)
	{
    temp = sendmsg("STAMP",'I');
    itoa(temp,G_globs[1],10); 
//    showg1();
//    beep();
    
   }
RETURNV(1);
}
int stamp2(void)
{
 int counter = 0;
 int temp= 0;
 sendmsg ("STAMP",'S2');
 counter = sendmsg("STAMP",'C');
 /*sendmsg ("STAMP",'O',G_qnty,G_globs[4]);*/
	sendmsg ("STAMP",'O',22,1);
   if ((sendmsg("STAMP",'C') - counter)!=3)
   {
	 temp = sendmsg("STAMP",'I');
    itoa(temp,G_globs[1],10); 
//    showg1();
//    beep();
   }
RETURNV(1); 
}

/* Select stamp printer 1 */
int stsel1(void) 
{
 sendmsg ("STAMP",'S1');   
RETURNV(1);
}

/*Select stamp printer 2 */
int stsel2(void)
{
 sendmsg ("STAMP",'S2');   
RETURNV(1);
}

/*Get count from stamp printer*/
int stgtct(void)
{
int counter = 990;
counter = sendmsg("STAMP",'C');
itoa(counter,G_globs[6],10);

	 itoa(counter,G_globs[1],10);
//    showg1();

RETURNV(1);
}
 

/*print a stamp*/
int stopst(void)
{
	G_qnty=sendmsg("STAMP",'O',atoi(G_globs[4]),G_qnty);
	RETURNV(1);
}
 

/*inz the stamp printer */
int stinz(void)
{
sendmsg("STAMP",'I');
RETURNV(1);
}
int stinrz(void)
{
sendmsg("STAMP",'RI');
RETURNV(1);
}

/*get status from stamp printer*/
int stgtst(void)
{
int temp;   
long *stat;
stat = 999;

temp = sendmsg("STAMP",'i',stat);
itoa(*stat,G_globs[6],10);
    
	 itoa(temp,G_globs[1],10);
//    showg1();

 RETURNV(1);
}


/*void the stamp in the stamp printer */
int stvost(void)
{
int temp;
temp = sendmsg("STAMP",'V');
    
	 itoa(temp,G_globs[1],10);
//    showg1();

 RETURNV(1);
}


/*reset the stamp printer*/
int strest(void)
{
int temp;
temp = sendmsg("STAMP",'R');

    itoa(temp,G_globs[1],10); 
//    showg1();

RETURNV(1);
}


int openta(void)
{
	 return(1);
}
int closeta(void)
{
	 return(1);
}


int dumptxn(void)
{
	int i=FRST;
	char d[20],q[20],t[20],a[20],l[20];

	 trans_file_fp = fopen("trans","a+");
	 if (trans_file_fp==NULL) RETURNV(0);

	while (sendmsg("DBM",'r',"transact",i)) {
	sendmsg ("DBM",'g',"transact","date",d);
	sendmsg ("DBM",'g',"transact","time",t);
	sendmsg ("DBM",'g',"transact","quantity",q);
	sendmsg ("DBM",'g',"transact","amount",a);
	sendmsg ("DBM",'g',"transact","location",l);
	fprintf(trans_file_fp,"%s,%s,%s,%s,%s\n",d,t,q,a,l);
		i=NEXT;
	}
	fclose(trans_file_fp);
	sendmsg ("DBM",'e',"transact");
	if (!sendmsg("DISK",'C',"trans",".\\","a:\\")) RETURNV(0);
	if (!sendmsg("DISK",'D',"trans",".\\")) RETURNV(0);
	RETURNV(1);
}
//------------------------------------------------------------------------
//                       BILL VALIDATOR COMMMANDS
//------------------------------------------------------------------------
int intbillv()
{
int stat = 99;
stat = sendmsg("BILLV",'I');
printf("from bill inx stat = '%d\n",stat);
//   sendmsg("OUTPUT1",'o',20,20,"%d",stat);
return(1);

}

int pollbill()
{
int stat;

unsigned char cmd[10];
cmd[0] = 8;
//stat = billv_control('P',cmd);
stat = sendmsg("BILLV",'P',cmd);
if (stat == 0||cmd[0] == 0x86||cmd[0]==0x87||cmd[0]==0x8A||cmd[0]== 0x8B)
{
// printf("from bill poll stat = '%d\n",stat);
// printf("from bill valadator, received a '%x'\n",cmd[0]);
 return(cmd[0]= 0);
}

if(cmd[0]== 0x1)
{
 return(100);
}

if(cmd[0]== 0x2)
{
 return(200);
}

if(cmd[0]== 0x5)
{
 return(500);
}

if(cmd[0]== 0xA)
{
 return(1000);
}

if(cmd[0]== 0x14)
{
 return(2000);
}

if(cmd[0]== 0x32)
{
 return(5000);
}

if(cmd[0]== 0x64)
{
 return(10000);
}

return(cmd[0]= 0);
}
//-------------------------------------------------------------------------
//                      LABEL PRINTER COMMANDS
//-------------------------------------------------------------------------
//Initialize Label Printer
int inzlbprt()
{
unsigned char *cmd;
int stat;
stat = sendmsg("LABEL",'I',cmd);
if(stat == 1)
 {
  beep();
 }
 return(1);
}

//output a string to label printer

int lbstring()
{
int stat;
int i;
//unsigned char *string = "123456789012345678901234567890";
//for(i=0;i<10;i++)
 //{
//  stat =  sendmsg("LABEL",'O',string);
// }
//sendmsg("LABEL",'HC');
//if(stat == 1)
 //{
//  beep();
// }
prtlabel();
return(1);
}
//------------- PRINT A BAR CODE LABEL--------
int prtlabel()
{
int retval;
unsigned char cmdb[200];
		  if ((retval = sendmsg("LABEL",'CR', cmdb)) != 1)
		  {
		  beep();
		  beep();
			printf("retval = '%d\n'",retval);
			 return(0);
		   }
		  delay(100);
		  beep();
		   printf("after CR command\n");
		  if ((retval = sendmsg("LABEL",'HT', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb, "\r\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'BL', cmdb, 1, 0xDD)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'BV', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'BW', cmdb, 3, 6)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'BH', cmdb, 0xd0)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'B2', cmdb)) != 1)
			 return(0);
		  memmove(cmdb, "\x9\xf\x11\x3a\x11\x12\x13\x38\x14\x15\x63\x1\x0\x0\x0\x18\x46", 17);
		  if ((retval = sendmsg("LABEL",'BP', cmdb, 17)) != 1)
			 return(0);
		  strcpy(cmdb, "\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'HL', cmdb, 0x24)) != 1)
			 return(0);

		  //
		  // Set print mode to vertical orientation.
		  //
		  if ((retval = sendmsg("LABEL",'HS', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb, "\r\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CW', cmdb, 1)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CH', cmdb, 1)) != 1)
			 return(0);
		  strcpy(cmdb, "TEST UPS BAR CODE");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CH', cmdb, 0)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CW', cmdb, 0)) != 1)
			 return(0);
		  strcpy(cmdb, "\rTRACKING NUMBER\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb, "\r\r\r\r\r\r\r\r\r\r\r1Z123X45100024\n\r\r\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb, "------------------------\n\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'HL', cmdb, 0x29)) != 1)
			 return(0);

		  //
		  // Set print mode to vertical printing.
		  //
		  if ((retval = sendmsg("LABEL",'HS', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb, "\r\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb,"FROM:\r    BOB SMITH\r    1234 MIDDLE ROAD\r    NEW YORK, NY  12345\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  strcpy(cmdb,"\rTO:\r    JOHN DOE\r    4321 OUTER WAY\r    LOS ANGELES, CA\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CW', cmdb, 1)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'CH', cmdb, 1)) != 1)
			 return(0);
		  strcpy(cmdb, "             54321\r");
		  if ((retval = sendmsg("LABEL",'O', cmdb)) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'O', "\r\r")) != 1)
			 return(0);
		  if ((retval = sendmsg("LABEL",'HC', cmdb)) != 1)
			 return(0);
		  return(1); // Break of all breaks

}
//---------------------------------------------------------------------------
//                    CREDIT CARD COMMANDS
//---------------------------------------------------------------------------

int inzcc()
{
sendmsg("MT",'I');
return(1);
}


int ccdata()
{
char name[80];
char *str = "card";
strcpy(name,"9\n");
strcpy(G_globs[2],"0");
if(sendmsg("MT",'n',name,sizeof(name)))return(1);
// printf("INSIDE OF GPA.C NAME RECEIVED IS '%s'\n",name);
 strcpy(G_globs[1],name);
 strcpy(G_globs[2],str);
 return(1);
}


int readcard()
{
 sendmsg("MT",'n',G_globs[1]);
 return(1);
}
//-----------------------------------------------------------------------------
//                             GET MONEY
//------------------------------------------------------------------------------

int getmoney(void)
{
int total;
int intermgqnty;
int diff = 0;
int temp;
int x;


x = pollbill();
G_prod = G_prod + x;
getcoins();
G_qnty = G_qnty + G_prod;

//  intermgqnty = G_qnty;
 // getcoins();
 // G_qnty = intermgqnty + G_qnty;
 // total = pollbill();
 // G_qnty = G_qnty + total;
  return(1);
}


//-----------------------------------------------------------------------------
//                             SWITCH LANG
//-----------------------------------------------------------------------------
int laswitch(void)
{
 sendmsg("SWAPLANG",' ');
 return(1);
}
