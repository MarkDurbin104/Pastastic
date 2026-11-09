#include <stdio.h>
#include <fcntl.h>
#include <io.h>

unsigned char G_chardefs[1708];
unsigned int G_charofs[97];

main() {
	int fd,i;
	FILE *fp;
	fd=open("litt.chr",O_RDONLY|O_BINARY);
	read(fd,G_chardefs,0x90); read(fd,G_charofs,192); read(fd,G_chardefs,96);
	G_charofs[96]=read(fd,G_chardefs,1706);
	close(fd);
	fp=fopen("tdchars.h","w");
	fprintf(fp,"unsigned char G_chardefs[1708]={");
	for (i=0;i<1707;i++) {
		if (!(i%14)) fprintf(fp,"\n	");
		fprintf(fp,"0x%02X,",G_chardefs[i]);
	}
	fprintf(fp,"0x%02X};\n",G_chardefs[i]);
	fprintf(fp,"unsigned int  G_charofs[97]={");
	for (i=0;i<96;i++) {
		if (!(i%10)) fprintf(fp,"\n	");
		fprintf(fp,"0x%04X,",G_charofs[i]);
	}
	fprintf(fp,"0x%04X};\n",G_charofs[i]);
	fclose(fp);
	return(1);
}
