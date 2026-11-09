#include <conio.h>
#include <stdio.h>
int markval;
char keys[241];
main() {
	int i;
	char k=0,j=0;
	keys[  1]='A'; keys[144]='B'; keys[  9]='C'; keys[ 80]='D'; keys[ 16]='E';
	keys[ 48]='F'; keys[112]='G'; keys[  5]='H'; keys[ 32]='I'; keys[  2]='J';
	keys[  6]='K'; keys[  3]='L'; keys[224]='M'; keys[192]='N'; keys[ 64]='O';
	keys[ 12]='P'; keys[ 13]='Q'; keys[240]='R'; keys[  4]='S'; keys[208]='T';
	keys[128]='U'; keys[ 10]='V'; keys[ 11]='W'; keys[  7]='X'; keys[  8]='Y';
	keys[ 15]='Z';
	while (k!=27) {
		switch(k=getch()) {
			case 0 : {
				switch(k=getch()) {
					case 30 : {
						markval|=1;
						j+=1;
					} break;
					case 31 : {
						markval|=2;
						j+=1;
					} break;
					case 32 : {
						markval|=4;
						j+=1;
					} break;
					case 33 : {
						markval|=8;
						j+=1;
					} break;
				}
			} break;
			case 'a' :
			case 'A' : {
					markval|=16;
					j++;
			} break;
			case 's' :
			case 'S' : {
					markval|=32;
					j++;
			} break;
			case 'd' :
			case 'D' : {
					markval|=64;
					j++;
			} break;
			case 'f' :
			case 'F' : {
					markval|=128;
					j++;
			} break;
		}
		if (j<4) for (i=0;i<800;i++) if (kbhit()) break;
		if (!kbhit()) {
			printf("%c",keys[markval]);
			markval=0;
			j=0;
		}
	}
	return(1);
}
