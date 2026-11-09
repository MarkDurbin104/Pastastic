#define SCA2DEV_C
#include <stdio.h>
#include <stdarg.h>
#include "types.h"
#include "sca2dev.h"

//___________________________________________________________________________

// sca2dev control routine
int sca2_control(char type,va_list ap)
{
    int retval=0;
    switch(type) {
        case 'i' : // INPUT                 - Return the character size
            retval=1;
            break;
        case 'o' : // OUTPUT                - int x,int y,char *fmt(as in printf)...
            retval=1;
            break;
        case 'R' : // RESET                 - no params
            retval=1;
            break;
        case 'A' : // SET ATTRIBUTE         - int a
            retval=1;
            break;
        case 'C' : // CURSOR                - int xorigin,int xoffset,int y,int length
            retval=1;
            break;
        case 'B' : // DRAW BOX              - int x,int y,int x1,int y1
            retval=1;
            break;
        case 'L' : // DRAW LINE             - int x,int y,int x1,int y1
            retval=1;
            break;
        case 'X' : // SET WRITE MODE TO XOR - int x=TRUE/FALSE
            retval=1;
            break;
        case 'S' : // SET CHARATER SIZE     - int size
            retval=1;
            break;
        case 'l' : // SHOW THE SHIFT LIGHTS - int shiftstat
            retval=1;
            break;
        case 'I' : // INITIALISE DEVICE     - no params
            retval=1;
            break;
        case 'E' : // END        DEVICE     - no params
            retval=1;
            break;
        case 'D' : // DRAW LOGO             - int x,int y
            retval=1;
            break;
        case 's' : // SINK  A FIELD         - int x,int y,int len
            retval=1;
            break;
        case 'r' : // RAISE A FIELD         - int x,int y,int len
            retval=1;
            break;
        case 'p' : // POSITION OF CURSOR    - int x,int pos,char *string
            retval=1;
            break;
        case 'F' : // LOAD FONT             - char *fontfilenameRESET                 - no params
            retval=1;
            break;
    }
    return(retval);
}
//___________________________________________________________________________
