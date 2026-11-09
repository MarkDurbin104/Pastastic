#include <windows.h>
#include <stdio.h>
#include <dir.h>
#include <dos.h>

#include "rwnwapi.h"

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

typedef int BOOL;
typedef char CHAR;
#define TRUE  1
#define FALSE 0

BOOL G_portfree=FALSE;

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
BOOL Exists(CHAR *file)
{
    struct ffblk f;
    return (findfirst(file,&f,FILEATTR)!=(-1));
}
//---------------------------------------------------------------------------
//F TestSemaphore
//S DLL exported function returning if the Semaphore is true
//D DLL exported function returning if the Semaphore is true
//R TRUE if Semaphore is true
int  FAR PASCAL _export TestSemaphore(void)
{
    if (Exists("PORTSEMA.001")) {
        return 1;
    }
    if (Exists("PORTSEMA.002")) {
        return 2;
    }
    return 4;
}
void FAR PASCAL _export SignalPortFree(void)
{
    if (!Exists("PORTSEMA.003")) fclose(fopen("PORTSEMA.003","w"));
    if ( Exists("PORTSEMA.004")) unlink("PORTSEMA.004");
}
void FAR PASCAL _export SignalPortInUse(void)
{
    if ( Exists("PORTSEMA.003")) unlink("PORTSEMA.003");
    if (!Exists("PORTSEMA.004")) fclose(fopen("PORTSEMA.004","w"));
}

