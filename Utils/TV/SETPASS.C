#include <stdio.h>
#include <string.h>
main(int argc,char **argv) {
	int i;
	unsigned char t[50];
	if (argc<2) {
		printf("setpass PASSWORD\n");
	}
	else {
		for (i=0;i<strlen(argv[1]);i++) {
			t[i]=(((argv[1][i]^0x55)<<3)^0xAA)>>1;
		}
		t[i]=0;
		fprintf(stdout,"@passwd \"%s\"\n",t);
	}
	return(1);
}
