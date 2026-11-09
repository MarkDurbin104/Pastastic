#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include "types.h"
#include "fldproc.h"
#include "money.h"
#include "message.h"
#include "control.h"
#include "config.h"
// RETURN the addition of two moneys
CHAR *addm(CHAR *a,CHAR *b)
{
    static CHAR retval[30];
    CHAR *e;
    INT i;
    double d;
	ENTRY(1570);
    d=strtod(a,&e);
    d+=strtod(b,&e);
    
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    RETURNV(retval);
}
// RETURN the subtraction of two moneys
CHAR *subm(CHAR *a,CHAR *b)
{
    static CHAR retval[30];
    CHAR *e;
    INT i;
    double d;
	ENTRY(1580);

    d=strtod(a,&e);
    d-=strtod(b,&e);

    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    RETURNV(retval);
}
// RETURN the division of two moneys
CHAR *divm(CHAR *a,CHAR *b)
{
    static CHAR retval[30];
    CHAR *e;
    INT i;
    double d;
	ENTRY(1590);

    d=strtod(a,&e);
    d/=strtod(b,&e);

    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    RETURNV(retval);
}
// RETURN the multiplication of a money and an INT
CHAR *mulm(CHAR *a,INT b)
{
    static CHAR retval[30];
    CHAR *e;
    INT i;
    double d;
	ENTRY(1600);

    d=strtod(a,&e);
    d*=b;

    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    RETURNV(retval);
}
// RETURN a money rounded to an INT
CHAR *rndm(CHAR *a,INT b)
{
    static CHAR retval[30];
    CHAR *e;
    INT i;
    double d;
	ENTRY(1610);

    if (b<2) {
        strcpy(retval,a);
        RETURNV(retval);
    }
    d=strtod(a,&e);
    if (d>=0.0) d+=b/2; else d-=b/2;     // adjust for -ive values
    d/=b;
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    d=strtod(retval,&e);
    d*=b;
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++) {
        if (retval[i]=='.') {
            retval[i]=0;
            break;
        }
    }
    RETURNV(retval);
}
CHAR *formatstr(CHAR *s,CHAR *fmt,INT len)
{
    INT i,j;
    CHAR val[80];
    static CHAR tmp[80];
    INT neg=0;
	ENTRY(1620);

    while ((*s==' ')&&(*s)) s++;

    memset(tmp,0,40);
    memset(val,0,40);
    if (s[0]=='-') neg=1;
    j=0;
    for (i=strlen(fmt)-1;i>0;i--) {
        if (fmt[i]=='9') val[j++]='0';
        if (fmt[i]=='~') {
            val[j++]='0';
            break;
        }
    }
    if ((i==0)||(j<=strlen(&s[neg])))
        strcpy(val,&s[neg]);
    else
        strcpy(&val[j-strlen(&s[neg])],&s[neg]);

    j=strlen(val)-1;
    for (i=strlen(fmt)-1;i>0;i--) {
        if (j<0) break;
		if (chkfmt('F',fmt[i])||(fmt[i]=='~'))
            tmp[i]=val[j--];
        else
            tmp[i]=fmt[i];
    }
    if (neg) {
        tmp[i]=fmt[0];
        if (fmt[0]=='(') tmp[strlen(fmt)]=')';
        if (fmt[0]=='[') tmp[strlen(fmt)]=']';
        if (fmt[0]=='{') tmp[strlen(fmt)]='}';
    }
    else {
        i++;
    }

    if (len==0) RETURNV(&tmp[i]);

    strcpy(val,&tmp[i]);

    if (len>=strlen(val)) {
        sprintf(tmp,"%*.*s",len,len,val);
    }
    else {
        memset(val,'*',40);
        val[len]=0;
        strcpy(tmp,val);
    }

    RETURNV(tmp);
}

// RETURN a money with all required puctuation
CHAR *mstr(CHAR *s,INT len)
{
	ENTRY(1630);
	RETURNV(formatstr(s,G_moneyf,len));
}
