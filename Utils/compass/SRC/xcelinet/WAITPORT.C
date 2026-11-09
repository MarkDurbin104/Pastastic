#include <conio.h>
#include <stdio.h>
#include <dir.h>
#include <dos.h>

#define FILEATTR      FA_ARCH|FA_HIDDEN|FA_NORMAL|FA_RDONLY|FA_SYSTEM

typedef int BOOL;
typedef char CHAR;
#define TRUE  1
#define FALSE 0

int Exists(CHAR *file)
{
    struct ffblk f;
    return (findfirst(file,&f,FILEATTR)!=(-1));
}
int main(void)
{
    if (Exists("PORTSEMA.001")) unlink("PORTSEMA.001");
    if (Exists("PORTSEMA.002")) unlink("PORTSEMA.002");

    if (Exists("PORTSEMA.004")) {
        printf("Serial Port in use ! Requesting...\n");
        if (!Exists("PORTSEMA.001")) fclose(fopen("PORTSEMA.001","w"));
    }
    printf("Waiting for Serial port to become available...\n");
    while (!Exists("PORTSEMA.003")) {
        if ((kbhit())&&(getch()==27)) {
            printf("Aborting Wait for Serial port\n");
            if (Exists("PORTSEMA.001")) unlink("PORTSEMA.001");
            return 2;
        }
        delay(500);
    }
    printf("Available - Taking Control of Serial Port\n");
    if (!Exists("PORTSEMA.002")) fclose(fopen("PORTSEMA.002","w"));
    if (Exists("PORTSEMA.001")) unlink("PORTSEMA.001");
    printf("Taken Control of Serial Port\n");
    return 1;
}


