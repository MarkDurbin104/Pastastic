//===============|========================================================|
//               |                                                        |
// Module        | TYPES.H                                                |
//               |                                                        |
// Project       | Compass In-Unit Trading Project                        |
//               |                                                        |
// Description   | Type definitions for use by COMPKEY.C                  |
//               |                                                        |
// Functions     | None                                                   |
//               |                                                        |
//===============|========================================================|
//               |                                                        |
// Copyright (c) | Unisys Limited                                         |
//               | 22 Southwark Bridge Road                               |
//               | London SE1 9HB                                         |
//               |                                                        |
// Author        | Mark Durbin                                            |
//               | P.S.L.                                                 |
//               | 160 Charles street, Greenhithe, Kent. DA9 9AJ          |
//               |                                                        |
//===============|========================================================|
// Date          | Modifications                                 | By     |
//===============|===============================================|========|
// 23/04/96      | Initial Version                               | MJD    |
//===============|========================================================|
// 03/05/96      | Added BOOL, TRUE and FALSE                    | MJD    |
//===============|========================================================|
//               |                                               |        |
//               |                                               |        |
//               |                                               |        |
//===============|========================================================|


#ifndef __TYPES_H // entry sentry
#define __TYPES_H

typedef char            CHAR;
typedef unsigned char   UCHAR;
typedef unsigned char   BYTE;
typedef short           INT16 ;
typedef unsigned short  UINT16;
typedef int             INT ;
typedef int             BOOL;
typedef unsigned int    UINT;
typedef unsigned int    WORD;
typedef long            LONG;
typedef unsigned long   ULONG;

typedef struct {
    INT width;
    INT height;
    INT number;
} KEYMETRICS;

typedef struct deptstat {
    CHAR    group;
    CHAR    closed;
    CHAR    zeros;
    CHAR    msdigit;
    CHAR    vatrate;
    CHAR    service;
    CHAR    vstat1;
    CHAR    vstat2;
    CHAR    zero_terminator;
} DEPTSTAT;

typedef struct department {
    INT                 dept_number; // key number
    union {
        DEPTSTAT        as_struct;
        CHAR            as_string[9];
    } status;
    CHAR                active[3];
    CHAR                desc[9];
    LONG                osp_code[3];
    INT                 action;
    struct department * next;
} DEPARTMENT;

typedef struct plustat {
    CHAR    prep_area;
    CHAR    kitch_prnt;
    CHAR    plu_type1;
    CHAR    plu_type2;
    CHAR    vat_app;
    CHAR    vstat1;
    CHAR    vstat2;
    CHAR    always;
    CHAR    vstat3;
    CHAR    vstat4;
    CHAR    zero_terminator;
} PLUSTAT;

typedef struct price_look_up {
    LONG                   plu_code;
    union {
        PLUSTAT            as_struct;
        CHAR               as_string[11];
    } status;
    CHAR                   desc1[13];
    CHAR                   desc2[13];
    LONG                   price[6];
    INT                    iosmtab[6];
    INT                    assoc_dept;
    INT                    action;
    struct price_look_up * next;
} PLU;


typedef struct configuration {
    INT  ctrl_centre;
    CHAR cc_desc[16];
    INT  term_id;
    CHAR term_desc[16];
    CHAR term_type[4];
    struct configuration * next;
} CONFIG;

typedef struct ReMACS_PLU {
    LONG plu_code;
    CHAR desc[26];
    LONG edate;
    LONG price[6];
    struct ReMACS_PLU * next;
} REMACSPLU;
typedef struct {
    KEYMETRICS      keys;
    ULONG           *layout;
    DEPARTMENT      *deptlist;
    PLU             *plulist;
    REMACSPLU       *rplulist;
} MAINDS;

typedef struct linkline {
    CHAR *line;
    struct linkline *next;
} LINELINK;




#define TRUE  1 
#define FALSE 0
#endif // __TYPES_H
