/* Demonstrate user exception handling.
   For Phar Lap 286 extender

   Compile with cat286b1.c or cat286b2.c In example
   compile commands, X=1 or 2

   Borland: bcc286 -w-par cat286.c cat286bX.c
   Microsoft :
   286|DOS Extender version 2.5 and later:
   cl -AL -Lp -G2 cat286.c cat286bX.c
   286|DOS Extender versions prior to 2.5
   cl -AL -Lp -G2 cat286.c cat286bX.c llibpe.lib
*/
#include <stdio.h>
#include <conio.h>
#include <string.h>
#include <ctype.h>
#include <stdlib.h>
#include <io.h>

/* flag set on break */
extern int broke;
/* set up exception handlers */
extern void x_init(void);

/* work space */
char tbuf[1024];

main()
  {
/* set up exception handlers */
  x_init();
  printf("Press ^C or ^Break to exit\n");
  while (1)
      {
      int c;
      while (!broke)
        {
        char *p;
        FILE *f;
        printf("File name:");
        if (!fgets(tbuf,sizeof(tbuf),stdin)) break;
        if (broke) break;
        p=strchr(tbuf,'\n');
/* ignore blank line */
        if (p==tbuf) continue;
        if (p) *p='\0';
        if (!access(tbuf,0))
          f=fopen(tbuf,"r");
        else
          f=NULL;
        if (f)
          {
          int c;
/* type file until EOF or break key -- we explicitly check
   for broke flag in this example, but the break interrupt
   (signal) handler could easily do a longjmp() to transfer
   control to some other point in the program. */
          while (broke==0&&(c=getc(f))!=EOF) putchar(c);
          putchar('\n');
          fclose(f);
          }
        else
          printf("Error opening file.\n");
        }
/* if you got here, broke==1 */
     printf("\nQuit? (Y/N) ");
     do
       {
       c=getch();
       if (!c)
         {
         getch();
         continue;
         }
      c=toupper(c);
      } while (c!='N'&&c!='Y');
      printf("%c\n",c);
      if (c=='Y')
        exit(0);
/* reset broke flag */
      broke=0;
      }
    }
