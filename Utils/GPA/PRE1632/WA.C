#include <conio.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>
#include <dos.h>

extern int rxstr    (int p,char *s,int maxlen,unsigned char eot,int over,int to);
extern int txstr    (int p,char *s);
extern int initport (int port,int r,int b,char p,int s);
void prat(int x,int y,char *fmt,...);
typedef unsigned char uchar;
typedef unsigned int  uint;
#define STX 			2
#define ETX 			3
#define NAK 			0x15
#define ACK 			6
int baud[]={150,300,600,1200,2400,4800,9600};
int G_baud=1200;
int G_curport=0;
#define GRAMS           0
#define THOZ            1
#define G_PER_10TH_OZ   2.835
#define G_PER_100TH_OZ  0.2835
#define ETX 			3

int G_otype=GRAMS;

char *binary(uchar c)
{
	static char tmp[10];
	int i;
	for (i=0;i<8;i++) tmp[i]='0'+((c&(0x80>>i))!=0);
	tmp[i]=0;
	return(tmp);
}
void prat(int x,int y,char *fmt,...)
{
	char str[80];
	va_list ap;
	gotoxy(x+1,y+2);
    va_start(ap,fmt);
    vsprintf(str,fmt,ap);
    va_end(ap);
	cprintf("%s",str);
}
// check rx'ed string format
int checkstr(char *r)
{
    static char cmps[]="\n99LB 99.9OZ\rX@\r";
    int i;
	prat(1,10,"%s   ",r);
	prat(1,11,"%s   ",cmps);
	prat(1,12,"   ",r);
    for (i=0;i<16;i++) {
        switch (cmps[i]) {
            case '9' :
                if ((r[i]<'0')||(r[i]>'9')) return(0);
                break;
            case 'X' :
                if ((r[i]<'A')||(r[i]>'Z')) return(0);
                break;
            default :
                if (r[i]!=cmps[i]) return(0);
        }
    }
	prat(1,12,"OK!",r);
    return(1);
}
// scale input routine
int sca_input(void)
{
    char tmp[20];
    char tmp1[5];
    char retry=0;
    int grams=0;
    int thoz=0;
    double res;

    do {
	    if (!txstr(G_curport,"W\r")) {
			prat(40,1,"Tx Failed");
			return(-1);
		}
	    if (!rxstr(G_curport,tmp,19,ETX,0,0)) {
			return(-2);
		}
        if (!checkstr(tmp)) {
			tmp[13]='A';
		} else {
        	sprintf(tmp1,"%c%c",tmp[1],tmp[2]);
        	res=atof(tmp1)*160;
        	sprintf(tmp1,"%c%c%c",tmp[6],tmp[7],tmp[9]);
        	res+=atof(tmp1);
        	thoz=(int)res;
        	grams=(int)(res*G_PER_10TH_OZ);
		}
        retry++;
    } while ((tmp[13]!='H')&&(tmp[13]!='J')&&(tmp[13]!='Z')&&(retry<10));
    if (G_otype==GRAMS) return(grams);
    return(thoz);
} 
// scale input routine
int sca_hinput(void)
{
    char tmp[20];
    char tmp2[20];
    char tmp1[5];
    char retry=0;
    int grams=0;
    int thoz=0;
    double res;

    do {
	    if (!txstr(G_curport,"T\r")) return(-1);
	    rxstr(G_curport,tmp2,8,ETX,0,0);
	    if (!txstr(G_curport,"W\r")) return(-1);
	    if (!rxstr(G_curport,tmp,19,ETX,0,0)) return(-2);
	    if (!txstr(G_curport,"N\r")) return(-1);
	    rxstr(G_curport,tmp2,8,ETX,0,0);
        sprintf(tmp1,"%c%c",tmp[1],tmp[2]);
        res=atof(tmp1)*1600.0;
        sprintf(tmp1,"%c%c%c%c",tmp[6],tmp[7],tmp[9],tmp[10]);
        res+=atof(tmp1);
        thoz=(int)res;
        grams=(int)((res*G_PER_100TH_OZ)+0.5);
        retry++;
    } while ((tmp[14]!='H')&&(tmp[14]!='J')&&(tmp[14]!='Z')&&(retry<10));
    txstr(G_curport,"W\r");
    rxstr(G_curport,tmp2,19,ETX,0,0);
    if (G_otype==GRAMS) return(grams);
    return(thoz);
} 
// scale reset routine
int sca_reset(void)
{
    char tmp[20];
    int i;
    for (i=0;i<3;i++) {
        if (!txstr(G_curport,"Z\r")) return(0);
        delay(500);
        if (!rxstr(G_curport,tmp,19,ETX,0,0)) return(0);
        if (checkstr(tmp)) return(1);
    }
    return(0);
} 
int main(int argc,char *argv[])
{
	int k,r;
	int xit=0;
	long l;
	char tmp[80];
	G_curport=0;
	if (argc<2) G_baud=1200; else G_baud=atoi(argv[1]);
	initport(G_curport,G_baud,7,'e',1);
    delay(300);
    rxstr(G_curport,tmp,19,ETX,0,0);
    sca_reset();
	clrscr();
	prat(1,20,"ihr");
	while (!xit) {
		k=getch();
		switch (k) {
			case 27 :
				xit=1;
				break;
			case 'i' :
				r=sca_input();
				prat(1,2,"Input %d",r);
				break;
			case 'h' :
				r=sca_hinput();
				prat(1,4,"Input %d",r);
				break;
			case 'r' :
				r=sca_reset();
				prat(1,10,"Reset %d",r);
				break;
			case '0' :
			case '1' :
			case '2' :
			case '3' :
			case '4' :
			case '5' :
			case '6' :
			case '7' :
				G_curport=k-'0';
				prat(1,16,"Using G_curport %d Baud %d",G_curport,G_baud);
				initport(G_curport,G_baud,7,'e',1);
				break;
		}
	}
	return(0);
}
