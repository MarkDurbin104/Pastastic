#include <stdio.h>
#include <conio.h>

int main(void)
{
    FILE *fp;
    printf("Press ESCAPE to shutdown any other key to continue\n");
    if (getch()==27) {
        fp=fopen("C:\\SHUTDOWN.NOW","w");
		  fclose(fp);
	 }
    fp=fopen("C:\\EXECDONE.FLG","w");
    fclose(fp);
}
