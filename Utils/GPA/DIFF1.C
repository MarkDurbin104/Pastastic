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
INT cmp(UCHAR *a,UCHAR *b)
{
    return *a==*b;
}
INT findainb(UCHAR *a,UCHAR *b,INT len)
{

    INT i=0;
    while (len) {
        if (cmp(a,b)) return i;
        i++;
        b++;
        len--;
    }
    return len;
}
INT findallas(UCHAR *a,UCHAR *b,INT len)
{
    INT i=0,k,l;

    k=findainb(a,b,len);
    if (!k) return 0;
    while ((len)&&(i<k)) {
        l=findainb(a,b,len);
        if ((l+i)<k) return 0-(i+l);
        i++;
        a++;
        len--;
    }
    return k;
}
void Compare(UCHAR *b1,INT l1,UCHAR *b2,INT l2)
{
    INT r;
    INT i=min(l1,l2),j;
    while (i) {
        r=findallas(b1,b2,i);
        if (r) {
            if (r>0) {
                for (j=0;j<r;j++) printf("%c",*(b2+j));
                b2+=r;
            } else {
                for (j=0;j<r;j++) printf("%c",*(b1+j));
                b1+=r;
            }
        }
        b1++;
        b2++;
        i++;
    }
    if (l1>l2) {
        for (i=0;i<l1-l2;i++) printf("%c",*(b1+i));
    } else {
        for (i=0;i<l2-l1;i++) printf("%c",*(b2+i));
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
