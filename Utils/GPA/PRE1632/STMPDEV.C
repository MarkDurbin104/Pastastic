#define STAMPDEV_C
#include <stdio.h>
#include <stdarg.h>
#include "types.h"
#include "stampdev.h"

//___________________________________________________________________________

// stampdev control routine
int stamp_control(int type,va_list ap)
{
    int retval=0;
    switch(type) {
        case 'R' : 
            retval=1;
            break;
        case 'o' : 
            retval=1;
            break;
        case 'i' : 
            retval=1;
            break;
        case 'I' : 
            retval=1;
            break;
        case 'S' : 
            retval=1;
            break;
        case 'A' : 
            retval=1;
            break;
        case 'b' : 
            retval=1;
            break;
        case 'E' : 
            retval=1;
            break;
        case 'F' : 
            retval=1;
            break;
        case 'B' : 
            retval=1;
            break;
        case 'L' : 
            retval=1;
            break;
        case 'M' : 
            retval=1;
            break;
    }
    return(retval);
}
//___________________________________________________________________________
