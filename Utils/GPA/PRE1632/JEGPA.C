#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <stdio.h>
#include <io.h>
#include <bios.h>
#include <ctype.h>
#include "gpa.h"

//--------------------------------------------------------------------------
//                  FUNCTION DECLAIRATIONS
//--------------------------------------------------------------------------
// ALL functions MUST be declaired   --   int funcname(void);

int             caklf       (void);
int             cainfo      (void);
char           *cagetvar    (char *);
int             cavernum    (void);
//--------------------------------------------------------------------------
//                  ACTION / FUNCTION  Mapping
//--------------------------------------------------------------------------
#include "gpafunc.h"

//--------------------------------------------------------------------------
//                  FUNCTION DEFINITIONS
//--------------------------------------------------------------------------
int caklf(void)
{
	char tmp[80];
   int size;
   char wrkdate[8];
   int wkday;
   static attrib=1;

   strcpy(wrkdate,cagetvar("WRKDATE"));

   wkday=atoi(cagetvar("WRKDAY"))+3;
   if (atoi(cagetvar("WRKDAY")) >= 4) {
       wkday++;
       if (atoi(cagetvar("WRKDAY")) >= 11) {
           wkday++;
       }
   }
   if (wkday>=7) {
      wkday=wkday-7;
   }

   if (atol(cagetvar("WRKDATE")) != atol(cagetvar("CURDATE"))) {
      attrib=attrib^1;
   }  else {
      attrib=1;
   }
//                       1         2         3
//              1234567890123456789012345678901  
//             "CA WEEK:00 DAY:0 DDD 00/00/00",
   sprintf(tmp,"CA WEEK:%2s DAY:%s %3s %c%c/%c%c/%c%c",
         cagetvar("WRKWK"),cagetvar("WRKDAY"),G_days[wkday],
         wrkdate[4],wrkdate[5], wrkdate[2],wrkdate[3],wrkdate[0],wrkdate[1]);
	size=sendmsg("OUTPUT1",'i');
	sendmsg("OUTPUT1",'A',attrib);
	sendmsg("OUTPUT1",'S',1);
	sendmsg("OUTPUT1",'o',49,1,"%30s",tmp);
	sendmsg("OUTPUT1",'A',0);
   sendmsg("OUTPUT1",'S',size);

//                       1         2         3         4         5
//              12345678901234567890123456789012345678901234567890123456789  
//             "VERSION: 030694 - STOCK UNIT:00  REM IN:00  REM OUT:00",
   sprintf(tmp,"VERSION: %6s - STOCK UNIT:%2s  REM IN:%2s  REM OUT:%2s",
         cagetvar("VERSION"), cagetvar("STKCUR"),cagetvar("RICUR"),cagetvar("ROCUR"));
	size=sendmsg("OUTPUT1",'i');
	sendmsg("OUTPUT1",'A',1);
	sendmsg("OUTPUT1",'S',1);
	sendmsg("OUTPUT1",'o',24,24,"%55s",tmp);
	sendmsg("OUTPUT1",'A',0);
   sendmsg("OUTPUT1",'S',size);

//   sprintf(tmp,"%3d",atoi(cagetvar("CATXNNUM")));
//	  size=sendmsg("OUTPUT1",'i');
//	  sendmsg("OUTPUT1",'A',1);
//	  sendmsg("OUTPUT1",'S',1);
//	  sendmsg("OUTPUT1",'o',70,23,"%4s",tmp);
//   sendmsg("OUTPUT1",'A',0);
//   sendmsg("OUTPUT1",'S',size);

   return(1);
}

// Return the VALUE associated with the VARIABLE
char *cagetvar(char *name)
{
   return(&(G_buff[G_nbuf[(0-isaction(name))-1].o+1]));
}

int cainfo(void)
{
    sendmsg("INPUT1",'A',9,caklf);
    return(1);
}

int cavernum(void)
{
   FILE *actfile;
   struct ftime acttime;

   actfile=fopen("cap\\capturei.dat", "r");
   if (actfile == NULL) {
      sprintf(&(G_buff[G_nbuf[(0-isaction("CAVERNUM"))-1].o+1]), "0x%x", 0);
	   return (0);
   }

   getftime(fileno(actfile), &acttime);
   fclose(actfile);
   sprintf(&(G_buff[G_nbuf[(0-isaction("VERSION"))-1].o+1]), "%02d%02d%02d",
               acttime.ft_day, acttime.ft_month, acttime.ft_year+1980-1900);
   return(1);
}
