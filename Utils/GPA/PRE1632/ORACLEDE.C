#define ORACLEDEV_C
#include <stdio.h>
#include <stdarg.h>
#include "types.h"
#include "ORACLEdev.h"

//___________________________________________________________________________

// ORACLEdev control routine
int ORACLE_control(char type,va_list ap)
{
    int retval=0;
    switch(type) {
        case 'C' : // INPUT                 - Return the character size
            retval=1;
            break;
        case 'U' : // OUTPUT                - int x,int y,char *fmt(as in printf)...
            retval=1;
            break;
        case 'D' : // RESET                 - no params
            retval=1;
            break;
        case 'T' : // SET ATTRIBUTE         - int a
            retval=1;
            break;
        case 'S' : // CURSOR                - int xorigin,int xoffset,int y,int length
            retval=1;
            break;
        case 'G' : // DRAW BOX              - int x,int y,int x1,int y1
            retval=1;
            break;
        case 'F' : // DRAW LINE             - int x,int y,int x1,int y1
            retval=1;
            break;
        case 'P' : // SET WRITE MODE TO XOR - int x=TRUE/FALSE
            retval=1;
            break;
        case 'R' : // SET CHARATER SIZE     - int size
            retval=1;
            break;
        case 'N' : // SHOW THE SHIFT LIGHTS - int shiftstat
            retval=1;
            break;
        case 'I' : // INITIALISE DEVICE     - no params
            retval=1;
            break;
        case 'E' : // END        DEVICE     - no params
            retval=1;
            break;
        case 'd' : // DRAW LOGO             - int x,int y
            retval=1;
            break;
    }
    return(retval);
}
//___________________________________________________________________________
