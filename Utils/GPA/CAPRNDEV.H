#ifndef PRNDEV_H

#define PRNDEV_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef PRNDEV_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S
#ifdef PRNDEV_C
LONG prn_control(INT type,va_list ap);
#endif

PUBLIC DEVHEADER dev_prn 
#if INIT
= {
	DEVSIG,
    "Printer Device Copyright (c) Unisys Ltd 1992 Version 1.01",
    "OUTPUT02","PRN","IOCR",NULL,NULL,prn_control,NULL,
	DEVSIG
}
#endif
;

#define PP_DRAFT       0
#define PP_LETTER      1
#define PP_GRAPH       2
#define PP_HIGHG       3

// PUBLIC SYMBOLS E
#ifdef PRNDEV_C

#define PRS_STARTUP    0
#define PRS_PGSETUP    1
#define PRS_MICROX     2
#define PRS_NORMX      3
#define PRS_MICROY     4
#define PRS_NORMY      5
#define PRS_ATTRON1    6
#define PRS_ATTRON2    7
#define PRS_ATTRON3    8
#define PRS_ATTRON4    9
#define PRS_ATTRON5   10
#define PRS_ATTRON6   11
#define PRS_ATTRON7   12
#define PRS_ATTRON8   13
#define PRS_ATTRON9   14
#define PRS_ATTROFF1  15
#define PRS_ATTROFF2  16
#define PRS_ATTROFF3  17
#define PRS_ATTROFF4  18
#define PRS_ATTROFF5  19
#define PRS_ATTROFF6  20
#define PRS_ATTROFF7  21
#define PRS_ATTROFF8  22
#define PRS_ATTROFF9  23
#define PRS_SIZE1     24
#define PRS_SIZE2     25
#define PRS_SIZE3     26
#define PRS_FORMFEED  27
#define PRS_LINEFEED  28
#define PRS_MICROYR   29
#define PRS_MICROXR   30
#define PRS_10CPI     31
#define PRS_12CPI     32
#define PRS_15CPI     33
#define PRS_USER0     34
#define PRS_USER1     35
#define PRS_USER2     36
#define PRS_USER3     37
#define PRS_USER4     38
#define PRS_USER5     39
#define PRS_USER6     40
#define PRS_USER7     41
#define PRS_USER8     42
#define PRS_USER9     43
#define PRS_SETPORT   44
#define PRS_SETFILE   45
#define PRS_PGTYPE1   46
#define PRS_PGTYPE2   47
#define PRS_PGTYPE3   48
#define PRS_PGTYPE4   49
#define PRS_PGTYPE5   50
#define PRS_PGTYPE6   51
#define PRS_PGTYPE7   52
#define PRS_PGTYPE8   53
#define PRS_PGTYPE9   54
#define PRS_GDIRECT   55
#define PRS_FACING    56
#define PRS_ORIENT    57
#define PRS_FACESTR   58
#define PRS_LISTLEN   59    // << -- set this to last PRS_... + 1

INT  G_seqlen[PRS_LISTLEN]; 
INT *G_sequence[PRS_LISTLEN];  
CHAR *G_keywords[]= {  
    "STARTUP" ,"PGSETUP" ,
    "MICROX"  ,"NORMX"   ,
    "MICROY"  ,"NORMY"   ,
    "ATTRON"  ,"ATTROFF" ,
    "SIZE"    ,"FORMFEED",
    "LINEFEED","RMICROY" ,
    "RMICROX" ,"10CPI"   ,
    "12CPI"   ,"15CPI"   ,
    "USER0"   ,"USER1"   ,
    "USER2"   ,"USER3"   ,
    "USER4"   ,"USER5"   ,
    "USER6"   ,"USER7"   ,
    "USER8"   ,"USER9"   ,
    "PORT"    ,"FILE"    ,
    "PGTYPE1" ,"PGTYPE2" ,
    "PGTYPE3" ,"PGTYPE4" ,
    "PGTYPE5" ,"PGTYPE6" ,
    "PGTYPE7" ,"PGTYPE8" ,
    "PGTYPE9" ,"GDIRECT" ,
    "FACING"  ,"ORIENT"  ,
    "FACESTR" ,
    NULL
};
INT             G_ppcurx=0;
INT             G_ppcury=0;
INT             G_ppmaxx=80;
INT             G_ppmaxy=66;
INT             G_pprnsize=1;
INT             G_pprnattr=1;
INT             G_pprnmode=0;

INT             prn_shutdown    (void);
INT             prn_startup     (void);

#endif  //  def PRNDEVICE

#endif  //  ndef PRNDEV_H

