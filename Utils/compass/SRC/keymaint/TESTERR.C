#include <stdio.h>
#include <conio.h>

int main(void)
{
    int k;
    printf("Enter error level required (0-9)\n");
    k=getch();
    printf("ERRORLEVEL %d",k-'0');
    return k-'0';
}
