#include <windows.h>
#include <stdio.h>
#include <dir.h>
#include <dos.h>

typedef char CHAR;
typedef int INT;

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM
#define DLLFUNC FAR PASCAL _export

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

void FAR PASCAL _export  Cleanup(void)
{
    unlink("G:\\EXECDONE.FLG");
    unlink("G:\\SHUTDOWN.NOW");
}
INT FAR PASCAL _export DoneExec(void)
{
    if (Exists("G:\\EXECDONE.FLG")) return 1;
    return 0;
}
INT FAR PASCAL _export NeedShut(void)
{
    if (Exists("G:\\SHUTDOWN.NOW")) return 1;
    return 0;
}
