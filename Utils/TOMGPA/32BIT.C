/****************************************************************************
* Project     : GPA
* File        : 32bit.c
* Description : Dummy function entry points
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:44  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/32bit.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:44   JGRAY
*  
* 
****************************************************************************/
#include <windows.h>

int FAR PASCAL LibMain(HINSTANCE h,WORD w,WORD c,LPSTR l)
{
    return(1);
}
BOOL WINAPI DllEntryPoint(HINSTANCE h,DWORD d,LPVOID l)
{
    return(1);
}

// **************************************************************************
// 32bit.c <end-of-file>

