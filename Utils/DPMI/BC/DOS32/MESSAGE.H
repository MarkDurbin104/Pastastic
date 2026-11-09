#ifndef MESSAGE_H
#define MESSAGE_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef MESSAGE_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC int 		asigndev		(char *name,char *group,char mode);
PUBLIC int 		sendmsg			(char *group,int mtype,...);
PUBLIC int 		initdevices		(void);
PUBLIC void 	closedevices	(void);
PUBLIC void 	prdevlist		(void);

#define OUTGRP  "OUTPUT1"
#define INPGRP  "INPUT1"
#define DISKGRP "DISK1"
#define LANGRP  "LAN1"
#define BDMGRP  "DBM1"

#define OUTMSGBASE   100	
#define OUTINPT     (OUTMSGBASE+ 0)
#define OUTOUTT     (OUTMSGBASE+ 1)
#define OUTATTR     (OUTMSGBASE+ 2)
#define OUTCURS     (OUTMSGBASE+ 3)
#define OUTDBOX     (OUTMSGBASE+ 4)
#define OUTLINE     (OUTMSGBASE+ 5)
#define OUTSXOR     (OUTMSGBASE+ 6)
#define OUTSIZE     (OUTMSGBASE+ 7)
#define OUTLITS     (OUTMSGBASE+ 8)
#define OUTINIT     (OUTMSGBASE+ 9)
#define OUTEND	    (OUTMSGBASE+10)
#define OUTLOGO     (OUTMSGBASE+11)
#define OUTSINK     (OUTMSGBASE+12)
#define OUTRAZE     (OUTMSGBASE+13)

#define INMSGBASE    200	
#define ININPUT     (INMSGBASE+ 0)
#define INFLUSH     (INMSGBASE+ 1)
#define ININIT	    (INMSGBASE+ 2)
#define INEND	    (INMSGBASE+ 3)
#define INHIT	    (INMSGBASE+ 4)
#define INRPLCE     (INMSGBASE+ 5)
#define INPOKE	    (INMSGBASE+ 6)
#define INPEEK	    (INMSGBASE+ 7)
#define INERASE     (INMSGBASE+ 8)
#define INRECRD     (INMSGBASE+ 9)
#define INPLAY	    (INMSGBASE+10)
#define INADKLF     (INMSGBASE+11)
#define INDLKLF     (INMSGBASE+12)

#define DSKMSGBASE   300	
#define DSKCOPYF    (DSKMSGBASE+ 0)
#define DSKGENUF    (DSKMSGBASE+ 1)
#define DSKDELF	    (DSKMSGBASE+ 2)
#define DSKFINDF    (DSKMSGBASE+ 3)
#define DSKSETDI    (DSKMSGBASE+ 4)
#define DSKRETDI    (DSKMSGBASE+ 5)
#define DSKFORMAT   (DSKMSGBASE+ 6)
#define DSKPUTDI    (DSKMSGBASE+ 7)
#define DSKGETDI    (DSKMSGBASE+ 8)
#define DSKNEWDD    (DSKMSGBASE+ 9)
#define DSKDATECK   (DSKMSGBASE+10)
#define DSKINIT	    (DSKMSGBASE+11)
#define DSKEND	    (DSKMSGBASE+12)

#define DBMMSGBASE   400	
#define DBMINIT     (DBMMSGBASE+ 0)
#define DBMEXIT     (DBMMSGBASE+ 1)     
#define DBMRINIT    (DBMMSGBASE+ 2)    
#define DBMEXIST    (DBMMSGBASE+ 3)     
#define DBMCREAT    (DBMMSGBASE+ 4)    
#define DBMDELET    (DBMMSGBASE+ 5)    
#define DBMOPEN     (DBMMSGBASE+ 6)     
#define DBMCLOSE    (DBMMSGBASE+ 7)     
#define DBMCLSAL    (DBMMSGBASE+ 8)  
#define DBMNOREC    (DBMMSGBASE+ 9)    
#define DBMRECNO    (DBMMSGBASE+10)    
#define DBMREAD     (DBMMSGBASE+11)     
#define DBMWRITE    (DBMMSGBASE+12)     
#define DBMDLREC    (DBMMSGBASE+13)    
#define DBMSRCH     (DBMMSGBASE+14)     
#define DBMSRCHP    (DBMMSGBASE+15)     
#define DBMGET      (DBMMSGBASE+16)     
#define DBMBLANK    (DBMMSGBASE+17)     
#define DBMEMPTY    (DBMMSGBASE+18)     
#define DBMPUT      (DBMMSGBASE+19)     
#define DBMDUP      (DBMMSGBASE+20)     
#define DBMRMDUP    (DBMMSGBASE+21)    
#define DBMDELGP    (DBMMSGBASE+22)    
#define DBMFLUSH    (DBMMSGBASE+23)     
#define DBMGTREC    (DBMMSGBASE+24)    
#define DBMPTREC    (DBMMSGBASE+25)    
#define DBMTXREC    (DBMMSGBASE+26)     
#define DBMRXREC    (DBMMSGBASE+27)  
#define DBMCREC     (DBMMSGBASE+28)  
#define DBMGETS     (DBMMSGBASE+29)  
#define DBMSETS     (DBMMSGBASE+30)  
#define DBMGETC     (DBMMSGBASE+31) 
#define DBMSETC     (DBMMSGBASE+32) 

// PUBLIC SYMBOLS E

#ifdef MESSAGE_C

DEVTABLE 	*G_device=NULL;
DEVHEADER 	*G_devtab[30];
int 	  	G_numdt=0;

int 		finddg		(char *name,char *group);
int 		finddev		(char *name,int idx);
int 		devinlist	(char *name);
int 		adddev		(char *name,char *group,int ofs);

#endif // def MESSAGE_C

#endif // ndef MESSAGE_H
