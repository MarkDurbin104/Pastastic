#include <stdio.h>
#include <conio.h>

int main(void)
{
    FILE *fp;
    while (!kbhit()) {
        fp=fopen("C:\\SEMAFORE.001","r");
        if (fp!=NULL) {
            printf("Found");
            fclose(fp);
            unlink("C:\\SEMAFORE.001");
            fp=fopen("C:\\SEMAFORE.002","w");
            fclose(fp);
        }
    }
    getch();
    return 1;
}

