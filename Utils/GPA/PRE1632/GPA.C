#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <ctype.h>
#include <io.h>
#include <dos.h>
#include <sys\types.h>
#include <sys\stat.h>

#include "gpa.h"
typedef struct {
	CHAR t;
	INT  d;
	CHAR c[20];
	CHAR l0[80];
	CHAR l1[80];
} ALARMDEF;
ALARMDEF *G_calm=NULL;
ALARMDEF *G_als[400];
INT G_numals=0;
CHAR G_appt[20];
CHAR G_line[2][80];
INT G_calmod=0;
CHAR *b62nums="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   INT funcname(void);

INT             prbar        (void);
INT             pay          (void);    
INT             showg1       (void);
INT             stamp1       (void);
INT             stamp2       (void);
INT             stsel1       (void);
INT             stsel2       (void);
INT             stgtct       (void);
INT             stopst       (void);
INT             stinz        (void);
INT             stinrz       (void);
INT             stgtst       (void);
INT             stvost       (void);
INT             strest       (void);
INT             openta       (void);   
INT             dumptxn      (void);
INT             closeta      (void);
INT             reduce       (void);
INT             changalr     (void);             
INT 			rcptstat	 (void);
INT 			stmpstat	 (void);
INT             caklf       (void);
INT             cainfo      (void);
CHAR           *cagetvar    (CHAR *);
INT             backup      (void);
INT             calendar    (void);

INT             datecvt     (void);
INT             getalm      (INT d,INT ofs,INT h,INT today);
INT             addalm      (INT d,INT h,INT b);
INT             isestr      (CHAR *s);
INT             setalm      (INT d,INT h,INT b);
INT             firstday    (INT m,INT y);
INT             daypm       (INT m,INT y);
void            prcald      (INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h,INT da);
void            edithour    (INT x,INT y,INT h,CHAR *s,CHAR *l0,CHAR *l1,INT k);
void            editday     (INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h);
INT             chkalm      (void);
void            ringbell    (void);
void            savemon     (INT y,INT m);
void            loadmon     (INT y,INT m);
INT             chktpass    (void);
INT             gentpass    (void);
INT             carestor    (void);
INT             cabackup    (void);


//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"
FILE *trans_file_fp;
//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------
INT datecvt(void)
{
    INT d,m,y;
    CHAR *s=G_formvars[G_form.curitem];
    d=getday(s); m=getmon(s); y=getyear(s);
  	orddfrom(&y,&m,&d);
    sprintf(s,"%02d%02d%02d",d,m,y);
    return(1);
}
// Return the VALUE associated with the VARIABLE
CHAR *cagetvar(CHAR *name)
{
   INT i=isaction(name);
   if (i>=0) return("                    ");
   return(getvarib((0-i)-1));
}
void casetstat(CHAR *name,CHAR *val)
{
   INT i=isaction(name);
   if (i>=0) return;
   setstatic((0-i)-1,val);
}
CHAR *ver(void)
{
    INT fd;
    static CHAR tmp[10];
    UINT d,t;

    strcpy(tmp,cagetvar("VERSION"));
    if (atoi(tmp)==0) {
        if ((fd=open(G_afilename,O_RDONLY))==(-1)) return("NO_VER");
        _dos_getftime(fd,&d,&t);
        close(fd);
        sprintf(tmp,"%d.%02d",(d-7434),(t>>11));
        casetstat("VERSION",tmp);
    }
    return(tmp);
}
INT caklf(void)
{
    static CHAR tmp[80];
    INT size;
    CHAR wrkdate[20];
    INT wkday;
    static CHAR attrib=1;
    static CHAR flash=1;
    static INT ro=0;
    INT d,m,y;

	size=sendmsg("OUTPUT1",'i');

    if (ro==0) {
        strcpy(wrkdate,cagetvar("WRKDATE"));
        d=getday(wrkdate); m=getmon(wrkdate); y=getyear(wrkdate);
    	orddfrom(&y,&m,&d);
        wkday=((atoi(cagetvar("WRKDAY"))-1)%6)+1;
        if (wkday>=4) wkday-=3; else wkday+=3;
        if (atol(wrkdate)!=atol(cagetvar("CURDATE"))) flash=1; else flash=0;
        sprintf(tmp,"CA WEEK:%2s DAY:%s %3s %02d/%02d/%02d V%s",
            cagetvar("WRKWK"),cagetvar("WRKDAY"),G_days[wkday],d,m,y,ver());
    }
    if ((++ro)==10) ro=0;
    if (flash) {
        attrib^=1;
        if (attrib)
        	sendmsg("OUTPUT1",'A',0x07);
        else
        	sendmsg("OUTPUT1",'A',0x43);
    } else {
        attrib=1;
    	sendmsg("OUTPUT1",'A',attrib);
    }
	sendmsg("OUTPUT1",'S',1);
	sendmsg("OUTPUT1",'o',0,0,"%30s",tmp);

	sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'S',size);
    return(1);
}

INT cainfo(void)
{
    chkalm();
    sendmsg("INPUT1",'A',5,caklf);
    sendmsg("INPUT1",'A',182,chkalm);
    return(1);
}
void flipround(CHAR *s)
{
    CHAR t;
    t=s[0]; s[0]=s[3]; s[3]=t;
    t=s[1]; s[1]=s[2]; s[2]=t;
}
LONG pdnum(CHAR *date,CHAR *time)
{
    LONG d;
    d=(LONG)datetonum(date)*144L;
    d+=(LONG)((((time[0]-'0')*10)+(time[1]-'0'))*6)+(time[2]-'0');
    return(d);
}
CHAR *numtob62(LONG n)
{
    INT i,j;
    static CHAR ret[5];
    for (i=3;i>=0;i--) {
        j=(INT)(n%62L);
        n/=62;
        ret[i]=b62nums[j];
    }
    ret[4]=0;
    flipround(ret);
    return(ret);
}
LONG b62tonum(CHAR *n)
{
    INT j;
    static CHAR tmp[5];
    LONG ret=0;
    strcpy(tmp,n);
    n=tmp;
    flipround(tmp);
    while (*n) {
        ret*=62L;
        if ((*n>='0')&&(*n<='9')) {
            j=*n-'0';
        } else if ((*n>='A')&&(*n<='Z')) {
            j=(*n-'A')+10;
        } else if ((*n>='a')&&(*n<='z')) {
            j=(*n-'a')+36;
        }
        ret+=(LONG)j;
        n++;
    }
    return(ret);
}
INT chktpass(void)
{
    CHAR tmp[10];
    LONG d;
    strcpy(tmp,datestr(8));
    d=pdnum(tmp,datestr(9));
    if (d==b62tonum(G_formvars[G_form.curitem])) return(1);
    G_form.curitem--;
    return(0);
}
INT gentpass(void)
{
    LONG d;
    d=pdnum(G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
    strcpy(G_formvars[G_form.curitem+1],numtob62(d));
    return(1);
}
INT prbar(void)
{
	ENTRY(20);
	sendmsg("OUTPUT2",'C',G_formvars[G_form.curitem-1],G_formvars[G_form.curitem]);
	RETURNV(1);
}
INT rcptstat(void)
{
	G_qnty=sendmsg("PRN",'GS');
	RETURNV(1);
}
INT stmpstat(void)
{
	G_qnty=sendmsg("STAMP",'GS',G_type);
	RETURNV(1);
}
INT pay(void)
{
 sendmsg("8255",'PO',G_globs[3]);
 RETURNV(1);

}
INT changalr(void)
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


INT reduce(void)
{
 sendmsg("8255",'RC',G_qnty);
 return(1);
}
INT showg1(void)
{
//	beep();
	sendmsg("OUTPUT1",'o',20,20,"%s",G_globs[1]);
//	beep();
	return(1);
}
INT stamp1(void)
{
INT counter = 0;
INT temp = 0 ;
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
INT stamp2(void)
{
 INT counter = 0;
 INT temp= 0;
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
INT stsel1(void) 
{
 sendmsg ("STAMP",'S1');   
RETURNV(1);
}

/*Select stamp printer 2 */
INT stsel2(void)
{
 sendmsg ("STAMP",'S2');   
RETURNV(1);
}

/*Get count from stamp printer*/
INT stgtct(void)
{
INT counter = 990;
counter = sendmsg("STAMP",'C');
itoa(counter,G_globs[6],10);
    
    itoa(counter,G_globs[1],10); 
//    showg1();

RETURNV(1);
}
 

/*print a stamp*/
INT stopst(void)
{
	G_qnty=sendmsg("STAMP",'O',atoi(G_globs[4]),G_qnty);       
	RETURNV(1);
}
 

/*inz the stamp printer */
INT stinz(void)
{
sendmsg("STAMP",'I');
RETURNV(1);
}
INT stinrz(void)
{
sendmsg("STAMP",'RI');
RETURNV(1);
}

/*get status from stamp printer*/
INT stgtst(void)
{
    INT temp;   
    LONG stat;
    stat = 999;
    temp = sendmsg("STAMP",'i',&stat);
    sprintf(G_globs[6],"%ld",&stat);
    sprintf(G_globs[1],"%d",temp);

    RETURNV(1);
}


/*void the stamp in the stamp printer */
INT stvost(void)
{
INT temp;
temp = sendmsg("STAMP",'V');
    
    itoa(temp,G_globs[1],10); 
//    showg1();

 RETURNV(1);
}


/*reset the stamp printer*/
INT strest(void)
{
INT temp;
temp = sendmsg("STAMP",'R');
    
    itoa(temp,G_globs[1],10); 
//    showg1();

RETURNV(1);
}


INT openta(void)
{
    return(1);
}
INT closeta(void)
{
    return(1);
}


INT dumptxn(void)
{
	INT i=FRST;
  	CHAR d[20],q[20],t[20],a[20],l[20];

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
INT getalm(INT d,INT ofs,INT h,INT today)
{
	INT r,i;
	if (ofs<today) r=3; else r=1;
	d+=ofs-1;
	G_calm=NULL;
	for (i=0;i<G_numals;i++) {
		if ((G_als[i]->d==d)&&((G_als[i]->t&0x0F)==h)) {
			G_calm=G_als[i];
			return(r+((G_calm->t&0x80)==0x80));
		}
	}
	return(0);
}
INT addalm(INT d,INT h,INT b)
{
    if (G_numals>=400) return(0);
    G_als[G_numals]=MALLOC(sizeof(ALARMDEF));
    if (G_als[G_numals]==NULL) return(0);
    G_calm=G_als[G_numals];
    G_numals++;

    G_calm->d=d;
    if (b) G_calm->t=h|0x80; else G_calm->t=h;
    strcpy(G_calm->c,G_appt);
    strcpy(G_calm->l0,G_line[0]);
    strcpy(G_calm->l1,G_line[1]);
    return(1);
}
INT isestr(CHAR *s)
{
    while (*s) if (!isspace(*s++)) return(0);
    return(1);
}
INT setalm(INT d,INT h,INT b)
{
	INT i,j,a=1;
    if (isestr(G_appt)&&isestr(G_line[0])&&isestr(G_line[1])&&(b==0)) a=0;
	for (i=0;i<G_numals;i++) {
		if ((G_als[i]->d==d)&&((G_als[i]->t&0x0F)==h)) {
            if (a) {
			    G_calm=G_als[i];
                strcpy(G_calm->c,G_appt);
                strcpy(G_calm->l0,G_line[0]);
                strcpy(G_calm->l1,G_line[1]);
                if (b) G_calm->t|=0x80; else G_calm->t&=0x7F;
            } else {
                FREE(G_als[i]);
                G_numals--;
            	for (j=i;j<G_numals;j++) G_als[j]=G_als[j+1];
            }
            return(1);
		}
	}
    if (a) addalm(d,h,b);
	return(0);
}
INT firstday(INT m,INT y)
{
	INT d;
	CHAR tmp[10];
	sprintf(tmp,"%02d%02d01",y%100,m);
	d=datetonum(tmp);
	return(d);
}
INT daypm(INT m,INT y)
{
	INT d;
	if (m==0) m=12;
	d=G_dpm[m-1];
	if ((m==2)&&((y%4)==0)) d++;
	return(d);
}
void prcald(INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h,INT da)
{
	INT nd,i,dr=0;
	INT fd,j,k,l;
	static INT lm=0,ly=0;
	if (((lm!=mn)||(ly!=yr))||(da)) dr=1;
	lm=mn; ly=yr;
	fd=firstday(mn,yr);
	nd=(fd+2)%7;
	sendmsg("OUTPUT1",'A',0);
	for (i=0;i<7;i++) sendmsg("OUTPUT1",'o',x+1+i*5,y+1,"%-4.4s",G_days[i]);
	for (i=0;i<nd;i++) {
		sendmsg("OUTPUT1",'o',x+2+i*5,y+3,"  ");
		if (dr) sendmsg("OUTPUT1",'P',x+1+i*5,y+4,"notag.bmp");
	}
	for (i=0;i<daypm(mn,yr);i++) {
		if (dy==(i+1)) k=2; else k=0;
		sendmsg("OUTPUT1",'A',k);
		sendmsg("OUTPUT1",'o',x+2+((i+nd)%7)*5,y+3+((i+nd)/7)*2,"%2d",i+1);
		if (dr) {
			k=l=0;
			for (j=0;j<12;j++) { l=getalm(fd,i+1,j,td); k=max(l,k); }
			switch (k) {
				case 0 :
					sendmsg("OUTPUT1",'P',x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,"notag.bmp");
					break;
				case 1 :
				case 3 :
					sendmsg("OUTPUT1",'P',x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,"greentag.bmp");
					break;
				case 2 :
				case 4 :
					sendmsg("OUTPUT1",'P',x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,"redtag.bmp");
					break;
			}
		}
	}
	sendmsg("OUTPUT1",'A',0);
	for (;i<((6*7)-nd)-5;i++) {
		sendmsg("OUTPUT1",'o',x+2+((i+nd)%7)*5,y+3+((i+nd)/7)*2,"  ");
		if (dr) sendmsg("OUTPUT1",'P',x+1+((i+nd)%7)*5,y+4+((i+nd)/7)*2,"notag.bmp");
	}
	for (i=7;i<20;i++) {
		if (h==i) sendmsg("OUTPUT1",'A',2); else sendmsg("OUTPUT1",'A',0);
		l=getalm(fd,dy,i-7,td);
		sendmsg("OUTPUT1",'o',x+36,(y+i)-4,"%02d:00",i);
		if (l) {
			sendmsg("OUTPUT1",'o',x+43,(y+i)-4,"  %s",G_calm->c);
			if ((l==2)||(l==4)) sendmsg("OUTPUT1",'P',x+43,(y+i)-4,"bell.bmp");
		} else {
			sendmsg("OUTPUT1",'o',x+43,(y+i)-4,"                    ",i);
		}
	}
	i=(31-strlen(datestr(0)))/2;
	sendmsg("OUTPUT1",'o',x+1,y+15,"%*.*s%s%*.*s",i,i,"",datestr(0),i,i,"");
	sendmsg("OUTPUT1",'o',x+44,y+1,"%d %s %d  ",dy,G_mnths[mn-1],yr+1900);
	l=getalm(fd,dy,h-7,td);
	if (l) {
    	sendmsg("OUTPUT1",'o',x+1,y+17,"%-64.64s",G_calm->l0);
    	sendmsg("OUTPUT1",'o',x+1,y+18,"%-64.64s",G_calm->l1);
    } else {
    	sendmsg("OUTPUT1",'o',x+1,y+17,"%-64.64s","");
    	sendmsg("OUTPUT1",'o',x+1,y+18,"%-64.64s","");
    }
}
void edithour(INT x,INT y,INT h,CHAR *s,CHAR *l0,CHAR *l1,INT k)
{
    INT cf=G_form.curitem;
    if (inputstr(x+45,(y+h)-4,s,"XXXXXXXXXXXXXXXXXX",k)) G_calmod=1;
    if (inputstr(x+1,y+17,l0,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0)) G_calmod=1;
    if (inputstr(x+1,y+18,l1,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",0)) G_calmod=1;
    G_exitkey=0;
    G_form.curitem=cf;
}
void editday(INT x,INT y,INT yr,INT mn,INT dy,INT td,INT h)
{
    INT xit=0,k,fd,oh=-1;
    INT l,bell;
    fd=firstday(mn,yr);
    if (h<7) h=7;
    if (h>19) h=19;
	while (!xit) {
        if (h!=oh) {
    	    l=getalm(fd,dy,h-7,td);
    	    if (l) {
    		    strcpy(G_appt,G_calm->c);
                strcpy(G_line[0],G_calm->l0);
                strcpy(G_line[1],G_calm->l1);
    		    if ((l==2)||(l==4)) bell=1; else bell=0;
            	sendmsg("OUTPUT1",'o',x+1,y+17,"%-64.64s",G_calm->l0);
            	sendmsg("OUTPUT1",'o',x+1,y+18,"%-64.64s",G_calm->l1);
	        } else {
    		    G_appt[0]=0;
    		    G_line[0][0]=0;
    		    G_line[1][0]=0;
                bell=0;
    			sendmsg("OUTPUT1",'o',x+43,(y+h)-4,"                    ");
            	sendmsg("OUTPUT1",'o',x+1,y+17,"%-64.64s","");
            	sendmsg("OUTPUT1",'o',x+1,y+18,"%-64.64s","");
	        }
            oh=h;
        }
        sendmsg("OUTPUT1",'C',x+45,0,(y+h)-4,19,1);
        k=sendmsg("INPUT1",'i');
        sendmsg("OUTPUT1",'C',x+45,0,(y+h)-4,19,1);
		switch (k) {
			case DEL  :
    		    G_appt[0]=0;
    		    G_line[0][0]=0;
    		    G_line[1][0]=0;
                bell=0;
                G_calmod=1;
               	setalm((fd+dy)-1,h-7,bell);
                oh=h-1;
                break;
			case INS  :
                bell^=1;
                if (bell) {
                    sendmsg("OUTPUT1",'P',x+43,(y+h)-4,"bell.bmp");
                    G_calmod=1;
                } else {
        			sendmsg("OUTPUT1",'o',x+43,(y+h)-4,"  ");
                    G_calmod=1;
                }
              	setalm((fd+dy)-1,h-7,bell);
                break;
			case F10 :
				xit=1;
				break;
			case DOWN : if (h<19) h++; break;
			case UP   : if (h>7)  h--; break;
			case CR   :
                edithour(x,y,h,G_appt,G_line[0],G_line[1],0);
               	setalm((fd+dy)-1,h-7,bell);
                break;
            default   :
                if (chkfmt('X',k)) {
                    edithour(x,y,h,G_appt,G_line[0],G_line[1],k);
                	setalm((fd+dy)-1,h-7,bell);
                } else {
                    beep();
                }
        }                             
    }
}
INT chkalm(void)
{
	INT d,m,y,h,fd,l;
//    INT lm,ly,dy,td;
	CHAR dt[10];
    static CHAR inhere=0;
    if (inhere) return(1);
    if (!strcmp(G_form.name,"calendar")) return(1);

    inhere=1;
    strcpy(dt,datestr(MINDATE)); d=getday(dt); m=getmon(dt); y=getyear(dt);
	orddfrom(&y,&m,&d);
    strcpy(dt,datestr(TIMEM)); h=atoi(dt);
    fd=firstday(m,y);
    loadmon(y,m);
    l=getalm(fd,d,h-7,d);
    if ((l==2)||(l==4)) {
     	setalm((fd+d)-1,h-7,0);
        savemon(y,m);
        loadmon(y,m+1);
        ringbell();
        runaction("calendar");
    }
    inhere=0;
    return(1);
}
void ringbell(void)
{
    INT i;
    beep();
    beep();
#ifdef __TURBOC__
	for (i=0;i<10;i++) {
        sound(3000);
        delay(10);
        sound(1000);
        delay(20);
    }
    nosound();
    delay(100);
	for (i=0;i<10;i++) {
        sound(3000);
        delay(10);
        sound(1000);
        delay(20);
    }
    nosound();
#endif
}
void savemon(INT y,INT m)
{
    INT fd,i;
    LONG ofs,last,tmp[12];

    if (!G_calmod) return;

    memset(tmp,0,12*sizeof(LONG));
    y-=94;
    m-=1;
    ofs=m+(y*12);
    fd=open("GPATODO.DAT",O_RDWR|O_BINARY);
    last=(156L*12L*sizeof(LONG))+sizeof(LONG);
    if (fd==(-1)) {
        fd=open("GPATODO.DAT",O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
        if (fd==(-1)) return;
        write(fd,&last,sizeof(LONG));
        for(i=0;i<156;i++) write(fd,tmp,sizeof(tmp));

        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        write(fd,&last,sizeof(LONG));
        ofs=last;

        lseek(fd,0L,SEEK_SET);
        last+=(31L*(LONG)sizeof(ALARMDEF))+sizeof(INT);
        write(fd,&last,sizeof(LONG));
    } else {
        lseek(fd,0L,SEEK_SET);
        read(fd,&last,sizeof(LONG));
        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        read(fd,tmp,sizeof(LONG));
        if (tmp[0]==0L) {
            lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
            write(fd,&last,sizeof(LONG));
            ofs=last;
            lseek(fd,0L,SEEK_SET);
            last+=(31L*(LONG)sizeof(ALARMDEF))+sizeof(INT);
            write(fd,&last,sizeof(LONG));
        } else {
            ofs=tmp[0];
        }
    }
    lseek(fd,ofs,SEEK_SET);
    write(fd,&G_numals,sizeof(INT));
    for (i=0;i<G_numals;i++) {
        write(fd,G_als[i],sizeof(ALARMDEF));
    }
    close(fd);
    G_calmod=0;
}
void loadmon(INT y,INT m)
{
    ALARMDEF ad;
    static INT lm=0,ly=0;
    INT fd,i;
    LONG ofs;
    if ((lm!=m)||(ly!=y)) {
        for (i=0;i<G_numals;i++) if(G_als[i]!=NULL) FREE(G_als[i]);
        G_numals=0;
        y-=94;
        m-=1;
        ofs=m+(y*12);
        fd=open("GPATODO.DAT",O_RDONLY|O_BINARY);
        if (fd==(-1)) return;
        lseek(fd,(ofs*sizeof(LONG))+sizeof(LONG),SEEK_SET);
        read(fd,&ofs,sizeof(LONG));
        if (ofs!=0L) {
            lseek(fd,ofs,SEEK_SET);
            read(fd,&m,sizeof(INT));
            for (i=0;i<m;i++) {
                read(fd,&ad,sizeof(ALARMDEF));
                G_als[G_numals]=MALLOC(sizeof(ALARMDEF));
                if (G_als[G_numals]==NULL) {
                    close(fd);
                    return;
                }
                memcpy(G_als[G_numals],&ad,sizeof(ALARMDEF));
                G_numals++;
            }
        }
        close(fd);
    }
    lm=m;
    ly=y;
    G_calmod=0;
}
INT calendar(void)
{
	INT i,xit=0,dr=0;
	INT d,m,y,td;
    INT lm,ly;
	CHAR dt[10];
    strcpy(dt,datestr(MINDATE)); d=getday(dt); m=getmon(dt); y=getyear(dt);
	orddfrom(&y,&m,&d);
    strcpy(dt,datestr(TIMEM)); i=atoi(dt);
	td=d;
    loadmon(y,m);
	while (!xit) {
		prcald(G_form.items[G_form.curitem].pos.x,G_form.items[G_form.curitem].pos.y,y,m,d,td,i,dr);
        dr=0;
        lm=m;
        ly=y;
		switch (sendmsg("INPUT1",'i')) {
			case F10 :
				xit=1;
				break;
			case PGDN : y++; break;
			case PGUP : y--; break;
			case DOWN : m++; break;
			case UP   : m--; break;
			case RGT  : d++; break;
			case LEFT : d--; break;
			case CR   : editday(G_form.items[G_form.curitem].pos.x,G_form.items[G_form.curitem].pos.y,y,m,d,td,i); dr=1; break;
		}
		if (d>daypm(m,y)) { d=1;  m++; } 
		if (d<1)      { m--; d=daypm(m,y); } 
		if (m>12)     { m=1;  y++; } 
		if (m<1)      { m=12; y--; } 
		if (y<94)       y=94;
		if (y>150)      y=150;
        if ((lm!=m)||(ly!=y)) {
            savemon(ly,lm);
            loadmon(y,m);
        }
	}
    savemon(ly,lm);
	RETURNV(1);
}
INT backup(void)
{
    INT err=0;
    if (G_modified) {
        sendmsg("OUTPUT1",'A',7);
        sendmsg("OUTPUT1",'S',1);
        sendmsg("OUTPUT1",'o',0,10,"%s",isdefstr("DATAMOD1"));
        sendmsg("OUTPUT1",'A',0);
        sendmsg("OUTPUT1",'o',0,13,"%s",isdefstr("DATAMOD2"));
    }
    while (err==0) {
        switch (sendmsg("INPUT1",'i')) {
            case 'y' : case 'Y' : err=1; break;
            case 'n' : case 'N' : err=2; break;
            default  : beep();
        }
    }
    if (err==2) return(1);
    err=0;
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,16,"%s",isdefstr("INSERTDP"));
    sendmsg("OUTPUT1",'A',0);
    switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }
    sendmsg("OUTPUT1",'o',0,18,"%s",isdefstr("BACKUPPW"));
    switch (sendmsg("DISK",'T',G_backup,"*.*")) {
        case 0 :
            err=1;
            break;
        case 2 :
            if (!sendmsg("DISK",'C',"*.*",G_database,G_backup)) err=2;
            break;
        default :
            if (!sendmsg("DISK",'D',"*.*",G_backup)) {
                err=3;
            } else {
                if (!sendmsg("DISK",'C',"*.*",G_database,G_backup)) err=4;
            }
    }
    beep();
    switch (err) {
        case 0 :
            sendmsg("OUTPUT1",'o',0,18,"%s",isdefstr("BACKUPCO"));
            sendmsg("INPUT1",'i');
            break;
        case 1 :
            sendmsg("OUTPUT1",'o',0,18,"%s",isdefstr("DATAERRO"));
            break;
        case 2 :
        case 4 :
            sendmsg("OUTPUT1",'o',0,18,"%s",isdefstr("WRITEERR"));
            break;
        case 3 :
            sendmsg("OUTPUT1",'o',0,18,"%s",isdefstr("DELERROR"));
            break;
    }
    if (err) {
        switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }
        sendmsg("OUTPUT1",'R');
        G_form.curitem=-1;
    }
    return(1);
}
INT cabackup(void)
{
    INT err=0;
    if (G_modified) {
        beep();
        sendmsg("OUTPUT1",'S',1);
        sendmsg("OUTPUT1",'A',1);
        sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("BACKUPYN"));
    }
    while (err==0) {
        switch (sendmsg("INPUT1",'i')) {
            case 'y' : case 'Y' : err=1; break;
            case 'n' : case 'N' : err=2; break;
            default  : beep();
        }
    }
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");

    if (err==2) return(1);
    err=0;
    beep();
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("INSERTDP"));
    switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }

    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");
   
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("BACKUPPW"));

    sendmsg("DISK",'C',"cap.cfg","",G_backup);
    switch (sendmsg("DISK",'T',G_backup,"*.*")) {
        case 0 :
            err=1;
            break;
        case 2 :
            if (!sendmsg("DISK",'C',"*.*",G_database,G_backup)) err=2;
            break;
        default :
            if (!sendmsg("DISK",'D',"*.*",G_backup)) {
                err=3;
            } else {
                if (!sendmsg("DISK",'C',"*.*",G_database,G_backup)) err=4;
            }
    }
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");

    beep();
    sendmsg("OUTPUT1",'A',1);
    switch (err) {
        case 0 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("BACKUPCO"));
            sendmsg("INPUT1",'i');
            break;
        case 1 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("DATAERRO"));
            break;
        case 2 :
        case 4 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("WRITEERR"));
            break;
        case 3 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("DELERROR"));
            break;
    }
    if (err) {
        switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }
        sendmsg("OUTPUT1",'R');
        G_form.curitem=-1;
    }
    return(1);
}

INT carestor(void)
{
    INT err=0;
    beep();
    sendmsg("OUTPUT1",'S',1);
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("RESTORYN"));
    
    while (err==0) {
        switch (sendmsg("INPUT1",'i')) {
            case 'y' : case 'Y' : err=1; break;
            case 'n' : case 'N' : err=2; break;
            default  : beep();
        }
    }
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");

    if (err==2) return(1);
    err=0;
    beep();
    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("INSERTDP"));

    switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }

    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");

    sendmsg("OUTPUT1",'A',1);
    sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("RESTORPW"));

    switch (sendmsg("DISK",'T',G_backup,"*.*")) {
        case 0 :
            err=1;
            break;
        case 2 :
            err=1;
            break;
        default :
            if (!sendmsg("DISK",'C',"*.*",G_backup,G_database)) err=4;
    }
    sendmsg("OUTPUT1",'A',0);
    sendmsg("OUTPUT1",'o',0,22,"%s","                                                              ");

    beep();
    sendmsg("OUTPUT1",'A',1);
    switch (err) {
        case 0 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("RESTORCO"));
            sendmsg("INPUT1",'i');
            break;
        case 1 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("DATAERRO"));
            break;
        case 2 :
        case 4 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("WRITEERR"));
            break;
        case 3 :
            sendmsg("OUTPUT1",'o',0,22,"%s",isdefstr("DELERROR"));
            break;
    }
    if (err) {
        switch (sendmsg("INPUT1",'i')) { case F10 : case ESC : return(1); }
        sendmsg("OUTPUT1",'R');
        G_form.curitem=-1;
    }
    return(1);
}

