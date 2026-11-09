#ifndef DRVSERV_H
#define DRVSERV_H
void print(unsigned char far *s)
{
	while(*s) {
	    _AX=0x0E00|*(s++);
		asm {
 			MOV  bx,7
		    PUSH bp
		    INT  0x10
		    POP  bp
		}
	}
}
void printx(int x)
{
	UCHAR tmp[5]="0000";
	UCHAR far *t;
	char i;

	t=tmp+4;

	for (i=3;i>=0;i--) {
		t--;
		*(t)+=(x&15);
		if (*t>57) *(t)+=7;
		x>>=4;
	}
	while ((*t)&&(*t=='0')) t++;
	if (!*t) t--;
	print(t);
}
void prat(char *fmt,...)
{
	static char s[81]="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ1234ABCDEFGHIJKLMNOPQRSTUVWXYZ12340123456789";
	void *ap;
//	va_list ap;

    va_start(ap,fmt);
    vsprintf(s,fmt,ap);
    va_end(ap);

	print(s);
}
#endif // ndef DRVSERV_H

