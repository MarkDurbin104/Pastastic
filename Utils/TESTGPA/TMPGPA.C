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

extern long G_vars[50];

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
//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   int funcname(void);

int             myvoid      (void);
int            actcomit     (void);
int            actbgntx     (void);
int            actrlbck     (void);
int            logsumme     (void);
int            wsnummer     (void);
int            gewfrmt      (void);
int            geldfrmt     (void);
int            myscale      (void);

//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"
FILE *trans_file_fp;
//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------

int myvoid (void)
{
  if(strcmp(G_form.name,"serve")==0) {
    voidlog(0);
  }
  return(1);
}

int actcomit(void)
{
   sendmsg("DBM",MESSAGE_CT);
   return(1);
}
int actbgntx(void)
{
   sendmsg("DBM",MESSAGE_BT);
   return(1);
}
int actrlbck(void)
{
   sendmsg("DBM",MESSAGE_RB);
   return(1);
}

int logsumme(void)
{
  PUSHS(logtotal(0));
  return(1);
}

int wsnummer(void)
{
  PUSHN(1234);
  return(1);
}

int gewfrmt(void)
{
   double f;
   char tmp[32];
   f=(double)G_vars[0]/1000;
   sprintf(tmp,"%.3f",f);
   PUSHS(tmp);
   return(1);
}

int geldfrmt(void)
{
   double f;
   char tmp[32];
   f=(double)G_vars[0]/100;
   sprintf(tmp,"%.2f",f);
   PUSHS(tmp);
   return(1);
}

int myscale(void)
{
  PUSHN(sendmsg("SCALE",MESSAGE_i));
  return(1);
}
