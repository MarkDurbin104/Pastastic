#include <stdio.h>
#include <memory.h>
#include <stdlib.h>
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>

typedef          char  CHAR;  
typedef          short INT16; 
typedef          int   INT;   
typedef          long  LONG;  
typedef unsigned char  UCHAR; 
typedef unsigned short UINT16;
typedef unsigned int   UINT;  
typedef unsigned long  ULONG;

INT Find1InBuf(UCHAR *a,UCHAR *buf,INT len)
{
    INT i=0;
    UCHAR *b=a;
    while ((i<len)&&(memcmp(a,buf,2))) {
        buf++;
        i++;
    }
    return i;
}

void Compare(UCHAR *b1,INT l1,UCHAR *b2,INT l2)
{
    INT r1,r2;
    INT i;
    while ((l1>0)&&(l2>0)) {
        r1=Find1InBuf(b1,b2,l2);
        if (r1) {
            r2=Find1InBuf(b2,b1,l1);
            if (r1<r2) {
                printf("<<-");
                for (i=0;i<r1;i++) printf("%c",*(b2+i));
                b2+=r1+1;
                l2-=r1+1;
                b1++;
                l1--;
                printf("\n");
            } else {
                printf(">>-");
                for (i=0;i<r2;i++) printf("%c",*(b1+i));
                b1+=r2+1;
                l1-=r2+1;
                b2++;
                l2--;
                printf("\n");
            }
        } else {
            l1--;
            l2--;
            b1++;
            b2++;
        }
    }
    if (l1!=0) {
        for (i=0;i<l1;i++) printf("%c",*(b1+i));
    } else if (l2!=0) {
        for (i=0;i<l2;i++) printf("%c",*(b2+i));
    }
}
INT main(INT argc,CHAR *argv[])
{
    INT fd1,fd2;
    UCHAR *a,*b;
    INT len1,len2;

    if (argc<3) {
        printf("DIFF FILE1 FILE2\n");
        return 1;
    }
    if ((fd1=open(argv[1],O_RDONLY|O_BINARY))==(-1)) {
        printf("%s - Can't Open File\n",argv[1]);
        return 1;
    }
    if ((fd2=open(argv[2],O_RDONLY|O_BINARY))==(-1)) {
        close(fd1);
        printf("%s - Can't Open File\n",argv[2]);
        return 1;
    }
    len1=filelength(fd1);
    len2=filelength(fd2);
    if ((a=malloc(len1))==NULL) {
        close(fd1);
        close(fd2);
        printf("%s - Not enough memory\n",argv[1]);
        return 1;
    }
    if ((b=malloc(len2))==NULL) {
        close(fd1);
        close(fd2);
        free(a);
        printf("%s - Not enough memory\n",argv[2]);
        return 1;
    }
    if (read(fd1,a,len1)!=len1) {
        close(fd1);
        close(fd2);
        free(a);
        free(b);
        printf("%s - Error reading file\n",argv[1]);
        return 1;
    }
    if (read(fd2,b,len2)!=len2) {
        close(fd1);
        close(fd2);
        free(a);
        free(b);
        printf("%s - Error reading file\n",argv[2]);
        return 1;
    }
    close(fd1);
    close(fd2);
    Compare(a,len1,b,len2);
    free(a);
    free(b);
    return 0;
}
