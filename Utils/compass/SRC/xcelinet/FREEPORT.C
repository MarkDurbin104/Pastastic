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
    printf("Releasing Serial Port\n");
    if (Exists("PORTSEMA.001")) unlink("PORTSEMA.001");
    if (Exists("PORTSEMA.002")) unlink("PORTSEMA.002");
    return 1;
}


