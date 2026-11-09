#include <stdio.h>
#include <ctype.h>
#include <conio.h>
#include <alloc.h>
#include <dos.h>
#include <mem.h>

char *G_buf;
void padd(char *a)
{
	static char *oa=(char *)0xFFFFFFFFL;
	if (a!=oa+1) {
		printf("\n%Fp  ",a);
	}
	oa=a;
	printf("%02X %c ",(*a)&0xFF,isprint(*a)?*a:'.');
}
int main(int argc)
{
	char *m=(char *)0L;
	char *tmp;
	unsigned int i;
	FILE *fp;
	G_buf=malloc(0xBA60);
	tmp=malloc(0xBA60);
	if (argc==1) {
		memcpy(G_buf,m,0xBA60);
		memset(tmp,0,0xBA60);
	} else {
		fp=fopen("mem.map","rb");
		fread(G_buf,1,0xBA60,fp);
		fread(tmp  ,1,0xBA60,fp);
		fclose(fp);
	}
	directvideo=1;
	while (!kbhit()) {
		for (i=0;i<0xBA60;i++) {
			if ((m[i]!=G_buf[i])&&(tmp[i]==0)) {
				padd(&m[i]);
				tmp[i]=1;
			}
		}
	}
	fp=fopen("mem.map","wb");
	fwrite(G_buf,1,0xBA60,fp);
	fwrite(tmp  ,1,0xBA60,fp);
	fclose(fp);
	return(0);
}
