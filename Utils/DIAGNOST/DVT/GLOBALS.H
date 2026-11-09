/***********************************************************************
*
*   File:           globals.h
*
*   Purpose:        declarations for global variables
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
*   $Log:   F:\BPO\DVT\VCS\GLOBALS.H_V  $
*  
*     Rev 1.1   14 Dec 1990 11:35:58   PJE
*  Changes angled brackets in include to double quotes
*  
*     Rev 1.0   10 Dec 1990 11:53:04   PJE
*  Initial revision.
*
***********************************************************************/
#ifndef GLOBALS_H
#define GLOBALS_H

#include "eccodefs.h"
#include <vv_form.h>

/*  define globals as extern or declaration depending on context */

#undef GLOBAL
#ifdef MAIN_MODULE
#define GLOBAL
#else
#define GLOBAL extern
#endif

GLOBAL  WINDOW title_wn;                    /* window for title */
GLOBAL  WINDOW inst_wn;                     /* window for prompts */
GLOBAL  WINDOW error_wn;                    /* popup window for errors */
GLOBAL  WINDOW wn;                          /* middle of screen window */

GLOBAL  WINDOWPTR title_wnp;                /* pointers to the windows */
GLOBAL  WINDOWPTR inst_wnp;
GLOBAL  WINDOWPTR error_wnp;
GLOBAL  WINDOWPTR wnp;

GLOBAL  MFORMPTR mainmnp;                   /* main menu pointer    */
GLOBAL  int screen_cols;                    /* screen columns       */
GLOBAL  LOCATION Location;                  /* BOP | CT             */

GLOBAL  Burn_In;                            /* flag indicating burnin   */
GLOBAL  Disable_Print;                      /* flag indicating print    */
GLOBAL  Iteration;                          /* loop counter             */

#endif /* GLOBALS_H */
