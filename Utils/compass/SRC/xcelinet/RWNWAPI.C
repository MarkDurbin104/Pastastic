#include <windows.h>

#include "rwnwapi.h"

#pragma warn -par
//---------------------------------------------------------------------------
//F LibMain
//S 16 bit DLL entry point 
//D 16 bit DLL entry point 
//P handle instance - not used
//P param           - not used
//P param           - not used
//P args            - not used
//R Always TRUE     
int FAR PASCAL LibMain (HINSTANCE h, WORD a, WORD b, LPSTR s)
{
    return TRUE;
}
//---------------------------------------------------------------------------
//F WEP
//S 16 bit DLL Windows Exit Point
//D 16 bit DLL Windows Exit Point
//P param - not used
//R Always TRUE     
int FAR PASCAL WEP (int nParameter)
{
    return 1;
}
#pragma warn +par
//---------------------------------------------------------------------------
//F RWNodeRequest
//S stub DLL exported function 
//D stub DLL exported function 
APIDECL WORD RWNENTRY RWNodeRequest(WORD wRequest)
{
    WORD retval=0;
    switch (wRequest) {
        case XR_STATUS      :
            retval=1;
            break;
        case XR_REINIT      :
            retval=2;
            break;
        case XR_REMOVE      :
            retval=3;
            break;
        case XR_CONNECT1    :
            retval=4;
            break;
        case XR_CONNECT2    :
            retval=5;
            break;
        case XR_CANCEL      :
            retval=6;
            break;
        case XR_ENABLE_AA   :
            retval=7;
            break;
        case XR_DISABLE_AA  :
            retval=0x10;
            break;
        case XR_RELEASE_PORT:
            retval=0x20;
            break;
        default :
            retval=0xFFFF;
    }
    return retval;
}









