#include <stdio.h>
#include <stdlib.h>
#include <process.h>
#include <windows.h>

int main(void)
{
    FILE *fp;
    unlink("G:\\upu\\src\\reboot.now");
//    ExitWindows(EW_RESTARTWINDOWS,0);
    spawnl(P_WAIT,"c:\\command.com","command.com","/cG:\\upu\\src\\test.bat",NULL);
//    system("G:\\upu\\src\\test.bat");
    if ((fp=fopen("G:\\upu\\src\\reboot.now","r"))!=NULL) {
        fclose(fp);
        unlink("G:\\upu\\src\\reboot.now");
        return ExitWindows(EW_REBOOTSYSTEM,0);
    }

    return 1;
}
