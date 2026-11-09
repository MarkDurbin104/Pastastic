/***********************************************************************
*
*   File:           bpokeys.h
*
*   Purpose:        Header file that defines keycodes for BPO keyboards
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\BPOKEYS.H_V  $
*  
*     Rev 1.1   04 Mar 1991 13:48:58   PJE
*  Corrected values for ENDCUST_KEY and SAMECUST_KEY.
*  
*     Rev 1.0   10 Dec 1990 11:57:42   PJE
*  Initial revision.
*
***********************************************************************/
#include <vv_key.h>

/*  Counter Terminal Keys */

#define HELP_KEY        -(0x3B)
#define SHELP_KEY       -(0x6E)
#define LOCK_KEY        -(0x5D)
#define EXIT_KEY        -(0x44)
#define RECPT_KEY       -(0x1D)
#define CALC_KEY        -(0x38)
#define DEL_KEY         (0x08)
#define VOID_KEY        (0x1B)
#define DISCOUNT_KEY    -(0x3E)
#define ENTER_KEY       (0x0D)
#define ENDCUST_KEY     -(0x73)
#define SAMECUST_KEY    -(0x72)

