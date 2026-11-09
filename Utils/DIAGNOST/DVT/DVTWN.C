/***********************************************************************
*
*   File:           dvtwn.c
*
*   Purpose:        DVT window support
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
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTWN.C_V  $
*  
*     Rev 1.1   24 Jan 1991 12:00:56   PJE
*  Added confirm_option function which pops up a confirmation window.
*  
*     Rev 1.0   10 Dec 1990 10:10:30   PJE
*  Initial revision.
*
***********************************************************************/

/**************
 Include Files            
***************/

#include <vv_sys.h>

#include "eccodefs.h"
#include "bpokeys.h"
#include "globals.h"
#include "dvtmsgs.h"

/***********************************************************************
*
*   Function:   clear_all_windows
*
*   Purpose:    clears all windows
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void clear_all_windows()
{
    static char *func = "clear_all_windows";
    INIT_MODULE(func);

    if (wn_isup(title_wnp))
        wn_clr(title_wnp);

    if (wn_isup(wnp))
        wn_clr(wnp);

    if (wn_isup(inst_wnp))
        wn_clr(inst_wnp);

    csr_hide();

    EXIT_MODULE(func);
}


/***********************************************************************
*
*   Function:   clear_window
*
*   Purpose:    clears the general purpose window in the middle
*               of the screen
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
void clear_window()
{
    static char *func = "clear_window";
    INIT_MODULE(func);

    if (wn_isup(wnp))
        wn_clr(wnp);

    csr_hide();
    
    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   disp_title
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int disp_title (char *title)
{
    static char *func = "disp_title";
    INIT_MODULE(func);

    if (!wn_isup(title_wnp))
        wn_up(title_wnp);

    wn_clr(title_wnp);          /* clear the window first */

    if (title != NULL)
        v_stpl (0, CENTER_TEXT, title, title_wnp);

    v_line ( 1, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, title_wnp);

    csr_hide();
    
    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   disp_prompt
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int disp_prompt (char *prompt1, char *prompt2)
{
    static char *func = "disp_prompt";
    INIT_MODULE(func);

    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   exit_on_mask
*
*   Purpose:    waits for a specified set of keys before exiting
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int exit_on_mask (uint mask)
{
    static char *func = "exit_on_mask";
    int key;
    BOOLEAN allow_exit = FALSE;

    INIT_MODULE(func);

    do
    {
        if (Burn_In)                /* don't hang if burning in */
        {
            key = key_or_timeout(IDLE_TIME);    /* 20 seconds */
        } else
        {
            key = ki();
        }
        if (mask & ANY_MASK)
            allow_exit = TRUE;
        else
            switch (key)
            {
                case ENTER_KEY:
                    if (mask & ENTER_MASK)
                        allow_exit = TRUE;
                    break;
                case VOID_KEY:
                    if (mask & VOID_MASK)
                        allow_exit = TRUE;
                    break;
                case EXIT_KEY:
                    if (mask & EXIT_MASK)
                        allow_exit = TRUE;
                    break;
                case HELP_KEY:
                    if (mask & HELP_MASK)
                        allow_exit = TRUE;
                    break;
                case '0':
                    if (mask & N0_MASK)
                        allow_exit = TRUE;
                    break;
                case '1':
                    if (mask & N1_MASK)
                        allow_exit = TRUE;
                    break;
                case '2':
                    if (mask & N2_MASK)
                        allow_exit = TRUE;
                    break;
                case '3':
                    if (mask & N3_MASK)
                        allow_exit = TRUE;
                    break;
                case '4':
                    if (mask & N4_MASK)
                        allow_exit = TRUE;
                    break;
                case '5':
                    if (mask & N5_MASK)
                        allow_exit = TRUE;
                    break;
                case '6':
                    if (mask & N6_MASK)
                        allow_exit = TRUE;
                    break;
                case '7':
                    if (mask & N7_MASK)
                        allow_exit = TRUE;
                    break;
                case '8':
                    if (mask & N8_MASK)
                        allow_exit = TRUE;
                    break;
                case '9':
                    if (mask & N9_MASK)
                        allow_exit = TRUE;
                    break;
                case 0:                     /* special case */
                    allow_exit = TRUE;
                    break;
                default:
                    break;
        }
        if (!allow_exit)
            bell();
    }
    while (!allow_exit);

    EXIT_MODULE(func);
    return (key);
}

/***********************************************************************
*
*   Function:   disp_error
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    key used to exit
*
***********************************************************************/
int disp_error (char *error1, char *error2, uint mask)
{
    int key;
    static char *func = "disp_error";
    INIT_MODULE(func);

    if (!wn_isup(error_wnp))
        wn_up(error_wnp);

    wn_clr(error_wnp);

    v_line    (0, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, error_wnp);
    if (error1 != NULL)
        v_stattpl (1, CENTER_TEXT, error1, LURGENT, STATT, error_wnp);
    if (error2 != NULL)
        v_stattpl (2, CENTER_TEXT, error2, LURGENT, STATT, error_wnp);

    key = exit_on_mask(mask);
    wn_dn(error_wnp);

    csr_hide();

    EXIT_MODULE(func);
    return (key);

}

/***********************************************************************
*
*   Function:   disp_exit
*
*   Purpose:    This function puts up 2 lines in the inst window
*               and waits for a specified set of keys
*
*   Arguments:  
*
*   Returns:    exit key used
*
***********************************************************************/
int disp_exit (char *exit1, char *exit2, uint mask)
{
    int key;
    static char *func = "disp_exit";
    INIT_MODULE(func);

    if (!wn_isup(inst_wnp))
        wn_up(inst_wnp);

    wn_clr(inst_wnp);

    v_line    (0, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, inst_wnp);
    if (exit1 != NULL)
        v_stattpl (1, CENTER_TEXT, exit1, LNORMAL, STATT, inst_wnp);
    if (exit2 != NULL)
        v_stattpl (2, CENTER_TEXT, exit2, LNORMAL, STATT, inst_wnp);

    key = exit_on_mask(mask);

    csr_hide();

    EXIT_MODULE(func);
    return (key);
}

/***********************************************************************
*
*   Function:   disp_inst
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int disp_inst (char *inst1, char *inst2)
{
    static char *func = "disp_inst";
    INIT_MODULE(func);

    if (!wn_isup(inst_wnp))
        wn_up(inst_wnp);

    wn_clr(inst_wnp);

    v_line    (0, 0, screen_cols, RIGHT, LNORMAL, LINE_SLNP, inst_wnp);
    if (inst1 != NULL)
        v_stattpl (1, CENTER_TEXT, inst1, LNORMAL, STATT, inst_wnp);
    if (inst2 != NULL)
        v_stattpl (2, CENTER_TEXT, inst2, LNORMAL, STATT, inst_wnp);

    csr_hide();

    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   screen_up
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int screen_up ()
{
    static char *func = "screen_up";
    INIT_MODULE(func);

    /* put the windows up */

    if (!wn_isup(title_wnp))
        wn_up(title_wnp);

    if (!wn_isup(inst_wnp))
        wn_up(inst_wnp);

    if (!wn_isup(wnp))
        wn_up(wnp);

    csr_hide();

    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   screen_down
*
*   Purpose:    
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
int screen_down()
{
    static char *func = "screen_down";
    INIT_MODULE(func);

    if (wn_isup(title_wnp))
        wn_dn(title_wnp);

    if (wn_isup(inst_wnp))
        wn_dn(inst_wnp);

    if (wn_isup(wnp))
        wn_dn(wnp);

    csr_hide();

    EXIT_MODULE(func);
}

/***********************************************************************
*
*   Function:   confirm_option
*
*   Purpose:    Gets confirmation from user on option
*
*   Arguments:  string message
*
*   Returns:    TRUE        to proceed
*               FALSE       to abort
*
***********************************************************************/
BOOLEAN confirm_option (char *message)
{
    WINDOWPTR confirm_wnp;
    BOOLEAN proceed = NO;
    int key;

    confirm_wnp = wn_def (9, 5, 6, 70, LNORMAL, BDR_DLNP);
    if (confirm_wnp != NULLP)
    {
        wn_up (confirm_wnp);
        v_stpl (0, CENTER_TEXT, message, confirm_wnp);
        v_stpl (2, CENTER_TEXT, text[TXT_PROCEED], confirm_wnp);
        v_stpl (3, CENTER_TEXT, text[TXT_ABORT], confirm_wnp);

        do
        {
            key = ki();
            if ((key != VOID_KEY) && (key != ENTER_KEY))
                bell();
        }
        while ((key != VOID_KEY) && (key != ENTER_KEY));

        wn_dn (confirm_wnp);
        wn_free (confirm_wnp);

        if (key == ENTER_KEY) proceed = YES;
    }
    return (proceed);
}
