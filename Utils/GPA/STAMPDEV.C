#define STAMPDEV_C
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <dos.h>
#include "types.h"
#include "control.h"
#include "message.h"
#include "stampdev.h"
#include "config.h"

//#define PORT1			3
//#define PORT2			6
#define PORT1			4
#define PORT2			5
#define STX 			2
#define ETX 			3
#define NAK 			0x15
#define ACK 			6
#define STAMP_SER		0x80
#define STAMP_CNT		0x81
#define STAMP_PRNT		0x82
#define STAMP_STAT		0x83
#define STAMP_RES		0x84
#define STAMP_VOID		0x85
#define STAMP_WSER		0x86
#define STAMP_MULT		0x87

INT G_stpos=0;
UINT crca[16]={
	0x0000,0x1081,0x2102,0x3183,0x4204,0x5285,0x6306,0x7387,
	0x8408,0x9489,0xA50A,0xB58B,0xC60C,0xD68D,0xE70E,0xF78F
};
UINT crcb[16]={
	0x0000,0x1189,0x2312,0x329B,0x4624,0x57AD,0x6536,0x74BF,
	0x8C48,0x9DC1,0xAF5A,0xBED3,0xCA6C,0xDBE5,0xE97E,0xF8F7
};
INT G_curport=(-1);

UINT calccrc(UCHAR *s)
{
	LONG crc=0L;
	UCHAR c;
	INT xit=0;
	if (*s==STX) s++;
	while (!xit) {
		c=*s;
		c^=(CHAR)(crc&0xFF);
		crc>>=8;
		crc^=(crca[c>>4]^crcb[c&15]);
		if (*(s++)==ETX) xit=1;
	}
	return((UINT)(crc&0xFFFF));
}
INT sendstr(CHAR *s)
{
	static CHAR tmp[100];
	CHAR *d;
	UINT c,l=4;
	d=tmp;
	*(d++)=STX;
	while (*s) { *(d++)=*(s++); l++; }
	*(d++)=ETX;
	c=calccrc((UCHAR *)tmp);
	*(d++)=(c>>8)&0xFF;
	*(d++)=(c   )&0xFF;
	*d=0;
	return(sendmsg("COMM",MESSAGE_Ol,G_curport,tmp,l));
}
CHAR *verifystr(UCHAR *s)
{
	UINT c,i;
	UCHAR *a;
	while ((*s)&&(*s!=STX)) s++;
	a=s;
	c=calccrc(s);
	while ((*a)&&(*a!=ETX)) a++;
	*a=0;
	a++;
	i=(*(a++)&0xFF);
	i<<=8;
	i|=(*a&0xFF);
	if (c!=i) *(s+1)=0;
	return((CHAR *)s+1);
}
INT receivestr(CHAR **s,INT l)
{
	if (sendmsg("COMM",MESSAGE_i,G_curport,*s,l,ETX,2)) {
		*s=verifystr((UCHAR *)*s);
		if (**s!=0) return(1);
	}
	return(0);
}
INT getserial(CHAR *t)
{
	CHAR tmp[20];
	CHAR *r;
	r=tmp;
	sprintf(tmp,"%c",STAMP_SER);
	if (sendstr(tmp)) {
		if (receivestr(&r,20)) {
			if (*r==ACK) {
				r++;
				strcpy(t,r);
				return(1);
			}
		} 
	}
	t[0]=0;
	return(0);
}
INT getcount(void)
{
	CHAR tmp[20];
	CHAR *r;
	r=tmp;
	sprintf(tmp,"%c",STAMP_CNT);
	if (sendstr(tmp)) {
		if (receivestr(&r,20)) {
			if (*r==ACK) {
				r++;
				return(atoi(r));
			}
		} 
	}
	return(0);
}
INT prstamp(INT val,INT cnt)
{
	CHAR tmp[30];
	CHAR tmp1[20],try=5;
	INT ret=0;
	CHAR *r;
	CHAR d1,d2,d3;
	UCHAR c=0;
	r=tmp;
	d1=((val>99)?((val%1000)/100)+'0':'*');
	d2=((val> 9)?((val%100) /10 )+'0':'*');
	d3=((val> 0)?((val%10)      )+'0':'*');
	sprintf(tmp,"%c%d%c%c%c  ;%02d",STAMP_PRNT,5,d1,d2,d3,cnt);
	if (sendstr(tmp)) {
//		delay(200);
		while (cnt) {
			c++;
			r=tmp;
			*r=0;
			try=8;
			while (try) { if (receivestr(&r,20)) try=0; else try--; }
			if (*r!=ACK) return(ret);
			sprintf(tmp1,"%c%c%c  %02d",d1,d2,d3,c);
			*(r+8)=0;
			if (strcmp(tmp1,r+1)) return(ret);
			ret+=val;
			cnt--;
		}
		return(ret);
	}
	return(ret);
}
INT prmulti(INT val,INT cnt,INT split)
{
	CHAR tmp[40];
	CHAR tmp1[20];
	CHAR *r,try=5;
	INT ret=0;

	CHAR d1,d2,d3,d4,d5,d6;
	UCHAR c=0,mc,omc;
	r=tmp;
	if (val>split) {
		omc=val/split;
		val%=split;
		d1=((split>99)?((split%1000)/100)+'0':'*');
		d2=((split> 9)?((split%100) /10 )+'0':'*');
		d3=((split> 0)?((split%10)      )+'0':'*');
		d4=((val>99)?((val%1000)/100)+'0':'*');
		d5=((val> 9)?((val%100) /10 )+'0':'*');
		d6=((val> 0)?((val%10)      )+'0':'*');
		sprintf(tmp,"%c%d%c%c%c  ;%02d:%d%c%c%c  ;%02d:",STAMP_MULT,5,d1,d2,d3,cnt*omc,5,d4,d5,d6,cnt);
	} else {
		return(prstamp(val,cnt));
	}
	if (sendstr(tmp)) {
//		delay(200);
		while (cnt) {
			mc=omc;
			c=0;
			while (mc) {
				c++;
				try=8;
				while (try) if (receivestr(&r,20)) try=0; else try--;
				if (*r!=ACK) return(ret);
				sprintf(tmp1,"%c%c%c  %02d",d1,d2,d3,c);
				if (strcmp(tmp1,r+1)) return(ret);
				ret+=split;
				mc--;
			}
			c=1;
			try=8;
			while (try) if (receivestr(&r,20)) try=0; else try--;
			if (*r!=ACK) return(ret);
			sprintf(tmp1,"%c%c%c  %02d",d4,d5,d6,c);
			if (strcmp(tmp1,r+1)) return(ret);
			ret+=val;
			cnt--;
		}
		return(ret);
	}
	return(ret);
}
INT getstat(LONG *stat)
{
	CHAR tmp[20];
	CHAR *r;
	INT to=3;
	while (to) {
		*stat=0x01000000L;
		sprintf(tmp,"%c",STAMP_STAT);
		r=tmp;
		if (sendstr(tmp)) {
			if (receivestr(&r,20)) {
				if (*r==ACK) {
					*stat=0L;
					r++;
					if (*r) *stat =(LONG)(*(r++)&0xBD)<<16; else return(0); 
					if (*r) *stat|=(LONG)(*(r++)&0xBF)<<8;  else return(0);
					if (*r) *stat|=(LONG)(*r    &0xBF);     else return(0);
					return(1);
				}
			} 
		}
		to--;
	}
	return(0);
}
INT resetsp(void)
{
	CHAR tmp[20];
	CHAR *r;
	LONG s;
	INT to;
	r=tmp;
	sprintf(tmp,"%c",STAMP_RES);
	if (sendstr(tmp)) {
		if (receivestr(&r,20)) {
			if (*r==ACK) {
				to=30; while ((!getstat(&s))&&(to)) to--;
				return(1);
			}
		} 
	}
	to=30; while ((!getstat(&s))&&(to)) to--;
	return(0);
}
INT voidstmp(void)
{
	CHAR tmp[20];
	CHAR *r;
	r=tmp;
	sprintf(tmp,"%c",STAMP_VOID);
	if (sendstr(tmp)) {
		if (receivestr(&r,20)) {
			if (*r==ACK) return(1);
		} 
	}
	return(0);
}
INT putserial(CHAR *t)
{
	CHAR tmp[20];
	CHAR *r;
	UCHAR c=0;
	INT i;

	r=tmp;
	for (i=0;i<5;i++) c+=t[i];
	sprintf(tmp,"%c%s%c",STAMP_WSER,t,c);
	if (sendstr(tmp)) {
		if (receivestr(&r,20)) {
			if (*r==ACK) return(1);
		} 
	}
	return(0);
}
INT opstamp(INT val,INT cnt)
{
	LONG s;

	getstat(&s);
	s&=0x01FFFFFFL;
	delay(100);
	if (s!=0L) {
		if (G_curport==PORT1) {
			G_curport=PORT2;
		} else {
			G_curport=PORT1;
		}
		return(0);
	}
	return(prmulti(val,cnt,500));
}
// stamp control routine
INT stamp_control(INT type,va_list ap)
{
    INT retval=0;
	static INT beeninit=0;
	CHAR *t;
	LONG *stat,s;
	INT val,cnt;
 	INT sc,ec;
    switch (type) {
        case 'I' :                      // init
			if (!beeninit) {
				beeninit=1;
            	sendmsg("COMM",MESSAGE_I,PORT1,9600,8,'n',1);
            	sendmsg("COMM",MESSAGE_I,PORT2,9600,8,'n',1);
				G_curport=PORT2;
				resetsp();
				G_curport=PORT1;
				resetsp();
			}
			retval=1;
            break;
        case 'RI' :                      // init
            sendmsg("COMM",MESSAGE_I,PORT1,9600,8,'n',1);
            sendmsg("COMM",MESSAGE_I,PORT2,9600,8,'n',1);
			G_curport=PORT2;
			resetsp();
			G_curport=PORT1;
			resetsp();
			retval=1;
            break;
        case 'E' :                      // end
			G_curport=(-1);
			retval=1;
            break;
		case 'S' :						// get Serial no.
			if (G_curport==(-1)) return(0);
			t=va_arg(ap,CHAR *);
			retval=getserial(t);
			break;
		case 'C' :						// get Count
			if (G_curport==(-1)) return(0);
			retval=getcount();
			break;
		case 'O' :						// Output a stamp
			if (G_curport==(-1)) return(0);
			G_stpos=0;
			val=va_arg(ap,INT);
			cnt=va_arg(ap,INT);
			if (val==0) {
				retval=0;
				if (voidstmp()) {
				   	delay(1000);
					if (resetsp()) {
						retval=prstamp(1,1);
					}
				}
			} else {
				sc=opstamp(val,cnt);
				if (sc!=(val*cnt)) {
					if (cnt==1) {
						retval=(val*cnt)-sc;
						ec=opstamp(retval,cnt);
					} else {
						if ((sc%val)==0) {
							cnt-=sc/val;
							ec=opstamp(val,cnt);
						} else {
							retval=(val*cnt)-sc;
							ec=opstamp(retval,1);
						}
					}
					sc+=ec;
				}
				retval=sc;
			}
//			sendmsg("INPUT1",MESSAGE_i);
			break;
		case 'i' :						// Input status
			if (G_curport==(-1)) return(0);
			stat=va_arg(ap,LONG *);
			retval=getstat(stat);
			break;
		case 'R' :						// Reset printer
			if (G_curport==(-1)) return(0);
			retval=resetsp();
			break;
		case 'V' :						// Void stamp
			if (G_curport==(-1)) return(0);
			retval=voidstmp();
			break;
		case 'W' :						// Write serial no.
			if (G_curport==(-1)) return(0);
			t=va_arg(ap,CHAR *);
			retval=putserial(t);
			break;
        case 'S1' :                        // Select printer 1
            if (G_curport==(-1)) return(0);
		    G_curport=PORT1;
            retval=1;
            break;
        case 'S2' :                        // Select printer 1
            if (G_curport==(-1)) return(0);
		    G_curport=PORT2;
            retval=1;
            break;
        case 'GS' :
			val=va_arg(ap,INT);
			if (val==1) {
				val=G_curport;
				G_curport=PORT1;
			} else {
				val=G_curport;
				G_curport=PORT2;
			}
			if (!beeninit) {
	        	sendmsg("COMM",MESSAGE_I,G_curport,9600,8,'n',1);
			}
			getstat(&s);
			s&=0x01FFFFFFL;
			if (s==0L) {
				retval=0;
			} else {
				if ((s&0x011C0000L)==0L) {
					retval=1;
				} else {
					if ((s&0x01000000L)!=0L) {
						retval=2;
					} else {
						sound(5000); delay(50);
						sound(4000); delay(50);
						sound(3000); delay(50);
						sound(4000); delay(50);
						sound(5000); delay(50);
						nosound();
						resetsp();
						sound(5000); delay(50);
						sound(4000); delay(50);
						sound(3000); delay(50);
						sound(4000); delay(50);
						sound(5000); delay(50);
						nosound();
						getstat(&s);
						s&=0x01FFFFFFL;
						if (s==0L) {
							retval=0;
						} else {
							retval=1;
						}
					}
				}
			}
			G_curport=val;
            break;
    }
    RETURNV(retval);
}
