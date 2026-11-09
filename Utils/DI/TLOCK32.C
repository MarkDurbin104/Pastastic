#include <windows.h>

BOOL FAR PASCAL _export checkTimeLock32(void)
{
    return 1;
}
void FAR PASCAL _export shutDown(void)
{
    ;
}

