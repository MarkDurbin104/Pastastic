/***********************************************************************
*
*   File:           dvtlog.c
*
*   Purpose:        Logging of errors for DVT
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 12-6-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\DVTLOG.C_V  $
*  
*     Rev 1.2   03 Jan 1991 17:18:38   AJW
*  Removed drive A: from ERRORS.LOG file name
*  .
*  
*     Rev 1.1   02 Jan 1991 10:08:00   AJW
*  Added log_error prototype.
*  
*     Rev 1.0   10 Dec 1990 10:58:26   PJE
*  Initial revision.
*
***********************************************************************/
#include <dos.h>
#include <stdio.h>
#include <fcntl.h>
#include <vv_sys.h>

#include "eccodefs.h"
#include "globals.h"

int log_error (char *message);

/***********************************************************************
*
*   Function:   log_error
*
*   Purpose:    logs an error message to the error log
*
*   Arguments:  message string
*
*   Returns:    TRUE if logged ok
*               FALSE if unable to log
*
***********************************************************************/
int log_error (char *message)
{
    FILE *fp;
    char timestp[9];
    char datestp[9];
    int result = TRUE;

    fp = fopen ("ERRORS.LOG", "a+t");     //  AJW  "A:\ERRORS.LOG"
    if (fp != NULL)
    {
        /* timestamp and print message */

        date_get(datestp, "MM/DD/YY");
        time_get(timestp, "HH:MM:SS");

        fprintf (fp, "%-8.8s %-8.8s I:%04d %-54.54s\n",
            datestp, timestp, Iteration, message);

        fflush  (fp);
        fclose  (fp);
    } else
    {
        bell();                 /* just emit a tone to indicate error */
        result = FALSE;
    }
    return (result);
}
