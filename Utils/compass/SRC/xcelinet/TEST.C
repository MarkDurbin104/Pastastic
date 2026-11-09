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

    while (!kbhit()) {
        if (Exists("PORTSEMA.004")) {
            printf("Port in use ! Requesting...\n");
            if (!Exists("PORTSEMA.001")) fclose(fopen("PORTSEMA.001","w"));
        }
        printf("Wait for available...\n");
        while ((!Exists("PORTSEMA.003"))&&(!kbhit())) delay(500);
        printf("Available - Taking Port for 5 seconds\n");
        if (!Exists("PORTSEMA.002")) fclose(fopen("PORTSEMA.002","w"));
        if (Exists("PORTSEMA.001")) unlink("PORTSEMA.001");
        printf("Taken Port\n");
        delay(5000);
        printf("Releasing Port\n");
        if (Exists("PORTSEMA.002")) unlink("PORTSEMA.002");
        printf("Waiting 5 seconds...\n");
        delay(5000);
    }
    getch();
    return 1;
}

