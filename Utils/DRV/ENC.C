#include <stdio.h>

int main(int argc,char *argv[])
{
	FILE *fpi,*fpo;
	char enc=0x5A,t=0x5A,c,dec=0;
	if (argc<3) return(1);
	if ((fpi=fopen(argv[1],"rb"))==NULL) return(1);
	if ((fpo=fopen(argv[2],"wb"))==NULL) return(1);
	while ((c=fgetc(fpi))!=EOF) {
		if (!dec) if (c==0x5A) { dec=1; c=fgetc(fpi); } else { fputc(t,fpo); dec=2; }
		if (dec==1) {
			c&=0xFF;
			t=(c^enc)&0xFF;
			enc=t;
			fputc(t,fpo);
		} else {
			c&=0xFF;
			t=(c^enc)&0xFF;
			enc=c;
			fputc(t,fpo);
		}
	}
	fclose(fpo);
	fclose(fpi);
	return(0);
}
