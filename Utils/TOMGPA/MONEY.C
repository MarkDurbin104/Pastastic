/****************************************************************************
* Project     : GPA
* File        : money.c
* Description : add,subb etc. for money values
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:15:46  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/money.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:15:46   JGRAY
*  
* 
****************************************************************************/
#define MONEY_C
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>

#include "gpasizes.h"
#include "types.h"
#include "fldproc.h"
#include "money.h"
#include "message.h"
#include "control.h"
#include "config.h"

//************************************************************
//S RETURN the addition of two moneys
//P char string money 1
//P char string money 2
//R pointer to resultant addition

CHAR *addm(CHAR *a,CHAR *b)
{
    static CHAR retval[LENOFMONEY];
    CHAR *e;
    INT i;
    double d;
    ENTRY(1570);
    d=strtod(a,&e);
    d+=strtod(b,&e);
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++)
        {
        if (retval[i]=='.')
            {
            retval[i]=0;
            break;
            }
        }
    RETURNV(retval);
}

//************************************************************
//S RETURN the subtraction of two moneys
//P char string money 1
//P char string money 2
//R char str pointer to result of subtracting money 2 from money 1

CHAR *subm(CHAR *a,CHAR *b)
{
    static CHAR retval[LENOFMONEY];
    CHAR *e;
    INT i;
    double d;
    ENTRY(1580);
    d=strtod(a,&e);
    d-=strtod(b,&e);
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++)
        {
        if (retval[i]=='.')
            {
            retval[i]=0;
            break;
            }
        }
    RETURNV(retval);
}

//************************************************************
//S RETURN the division of two moneys
//P char string pointer to money (1) to be divided into
//P char string pointer to money (2) to divide into it
//R char str pointer to result of dividing money 1 by money 2

CHAR *divm(CHAR *a,CHAR *b)
{
    static CHAR retval[LENOFMONEY];
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

//************************************************************
//S RETURN the multiplication of a money and an INT
//P string pointer of number to multiply
//P small int number to multiply money by
//R char string pointer to result

CHAR *mulm(CHAR *a,INT b)
{
    static CHAR retval[LENOFMONEY];
    CHAR *e;
    INT i;
    double d;
    ENTRY(1600);

    d=strtod(a,&e);
    d*=b;
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++)
        {
        if (retval[i]=='.')
            {
            retval[i]=0;
            break;
            }
        }
    RETURNV(retval);
}

//************************************************************
//S RETURN a money rounded to an INT
//D uses float numbers and formatted float to identify a decimal place
//P char string number to be rounded
//P integer no. of place to allow rounded
//R pointer to static location of rounded result string

CHAR *rndm(CHAR *a,INT b)
{
    static CHAR retval[LENOFMONEY];
    CHAR *e;
    INT i;
    double d;
    ENTRY(1610);

    if (b<2)
        {
        strcpy(retval,a);
        RETURNV(retval);
        }
    d=strtod(a,&e);
    if (d>=0.0)
        d+=b/2;
    else
        d-=b/2;     // adjust for -ive values
    d/=b;
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++)
        {
        if (retval[i]=='.')
            {
            retval[i]=0;
            break;
            }
        }
    d=strtod(retval,&e);
    d*=b;
    sprintf(retval,"%lf",d);
    for (i=0;i<strlen(retval);i++)
        {
        if (retval[i]=='.')
            {
            retval[i]=0;
            break;
            }
        }
    RETURNV(retval);
}

//************************************************************
//S format string
//P char string value
//P char string format
//P integer length of reply
//R char string address of formatted output

CHAR *formatstr(CHAR *s,CHAR *fmt,INT len)
{
    INT i,j;
    CHAR val[LENOFVLTMP];
    static CHAR tmp[LENOFFSTMP];
    INT neg=0;
    ENTRY(1620);

    while ((*s==' ')&&(*s))
        s++;
    memset(tmp,0,MAXOFFSTMP);           // if we only work with the first 40 bytes why are they 80 long?
    memset(val,0,MAXOFVLTMP);
    if (s[0]=='-')
        neg=1;
    j=0;
    for (i=strlen(fmt)-1;i>0;i--)
        {
        if (fmt[i]=='9')
            val[j++]='0';
        if (fmt[i]=='~')
            {
            val[j++]='0';
            break;
            }
        }
    if ((i==0)||(j<=strlen(&s[neg])))
        strcpy(val,&s[neg]);
    else
        strcpy(&val[j-strlen(&s[neg])],&s[neg]);

    j=strlen(val)-1;
    for (i=strlen(fmt)-1;i>0;i--)
        {
        if (j<0) break;
        if (chkfmt('F',fmt[i])||(fmt[i]=='~'))
            tmp[i]=val[j--];
        else
            tmp[i]=fmt[i];
        }
    if (neg)
        {
        tmp[i]=fmt[0];
        if (fmt[0]=='(')
            tmp[strlen(fmt)]=')';
        if (fmt[0]=='[')
            tmp[strlen(fmt)]=']';
        if (fmt[0]=='{')
            tmp[strlen(fmt)]='}';
        }
    else
        {
        i++;
        }
    if (len==0)
        RETURNV(&tmp[i]);
    strcpy(val,&tmp[i]);
    if (len>=strlen(val))
        {
        sprintf(tmp,"%*.*s",len,len,val);
        }
    else
        {
        memset(val,'*',MAXOFVLTMP);
        val[len]=0;
        strcpy(tmp,val);
        }
    RETURNV(tmp);
}

//************************************************************
//S RETURN a money with all required puctuation
//D special code to cater for zero blanking if set
//P char pointer to string integer number 
//R pointer to formatted string

CHAR *mstr(CHAR *s,INT len)
{
    ENTRY(1630);
    if ((G_blankoz)&&(atol(s)==0L))
        RETURNV(formatstr(" ","XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",len));
    RETURNV(formatstr(s,G_moneyf,len));
}
// **************************************************************************
// money.c <end-of-file>

