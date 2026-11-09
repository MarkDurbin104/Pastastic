/***********************************************************************
*
*   File:           eccodefs.h
*
*   Purpose:        Basic definitions
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 11-21-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\ECCODEFS.H_V  $
*  
*     Rev 1.1   03 Jan 1991 15:59:18   AJW
*  Extended LOCATION type.
*  
*     Rev 1.0   10 Dec 1990 11:54:38   PJE
*  Initial revision.
*
***********************************************************************/
#ifndef ECCODEFS_H
#define ECCODEFS_H

/* basic types */

typedef unsigned int    uint;
typedef unsigned char   byte;
typedef unsigned int    word;
typedef unsigned long   ulong;
typedef unsigned char   uchar;
typedef int             (*pfnint)();    /* ptr to function returning int */
typedef int             BOOLEAN;
typedef long            DATE;
typedef long            TIME;

/* location of code */

typedef enum { PC, CT, BOP , BOTH} LOCATION;

/* status codes */

typedef enum { PASSED, FAILED, SKIPPED } STATUS;

/* error codes */

typedef enum {
    PROMPT_ERR,
    ERROR_ERR,
    WN_ERR,
    TITLE_ERR,
    MENUDEF_ERR
} ERRORCODE;

typedef struct {
    pfnint  fn;
    BOOLEAN selected;
    int     status;
    int     type;
} TEST_REC;

/* masks for exit keys */

#define ENTER_MASK      0x0001      /* Enter key    */
#define VOID_MASK       0x0002      /* VOID or Esc  */
#define EXIT_MASK       0x0004      /* EXIT or F10  */
#define HELP_MASK       0x0008      /* HELP or F1   */
#define N0_MASK         0x0010      /* 0 key        */
#define N1_MASK         0x0020      /* 1 key        */
#define N2_MASK         0x0040      /* 2 key        */
#define N3_MASK         0x0080      /* 3 key        */
#define N4_MASK         0x0100      /* 4 key        */
#define N5_MASK         0x0200      /* 5 key        */
#define N6_MASK         0x0400      /* 6 key        */
#define N7_MASK         0x0800      /* 7 key        */
#define N8_MASK         0x1000      /* 8 key        */
#define N9_MASK         0x2000      /* 9 key        */
#define ANY_MASK        0x8000      /* any key okay */

/* delay count */

#define SHORT_DELAY     90          /* 5 seconds */

/*
*   timeout for SKIPPING unattended tests, e.g., keyboard
*   and video tests
*/
#define IDLE_TIME        360L         /* 20 seconds   */

#ifdef bell
#undef bell
#endif
#define bell()   ((Location == CT) ? kbd_buzz() : beep_vv(BPBELL, BPBELL))

#endif  /* ECCODEFS_H */

