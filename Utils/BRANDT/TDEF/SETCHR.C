#include "convhpgl.h"

	struct	characters charset[1];

void setupchar(void){

	charset[0].nopts[33]=7;					/* A */
	charset[0].xy[33][ 0]=(0<<4)|0;
	charset[0].xy[33][ 1]=(0<<4)|8;
	charset[0].xy[33][ 2]=(4<<4)|12;
	charset[0].xy[33][ 3]=(8<<4)|8;
	charset[0].xy[33][ 4]=(8<<4)|0;
	charset[0].xy[33][ 5]=(8<<4)|6;
	charset[0].xy[33][ 6]=(0<<4)|6;

	charset[0].nopts[34]=12;				/* B */
	charset[0].xy[34][ 0]=(0<<4)|0;
	charset[0].xy[34][ 1]=(0<<4)|12;
	charset[0].xy[34][ 2]=(6<<4)|12;
	charset[0].xy[34][ 3]=(8<<4)|10;
	charset[0].xy[34][ 4]=(8<<4)|8;
	charset[0].xy[34][ 5]=(6<<4)|6;
	charset[0].xy[34][ 6]=(0<<4)|6;
	charset[0].xy[34][ 7]=(6<<4)|6;
	charset[0].xy[34][ 8]=(8<<4)|4;
	charset[0].xy[34][ 9]=(8<<4)|2;
	charset[0].xy[34][10]=(6<<4)|0;
	charset[0].xy[34][11]=(0<<4)|0;

	charset[0].nopts[35]=10;				/* C */
	charset[0].xy[35][ 0]=(8<<4)|4;
	charset[0].xy[35][ 1]=(8<<4)|2;
	charset[0].xy[35][ 2]=(6<<4)|0;
	charset[0].xy[35][ 3]=(2<<4)|0;
	charset[0].xy[35][ 4]=(0<<4)|2;
	charset[0].xy[35][ 5]=(0<<4)|10;
	charset[0].xy[35][ 6]=(2<<4)|12;
	charset[0].xy[35][ 7]=(6<<4)|12;
	charset[0].xy[35][ 8]=(8<<4)|10;
	charset[0].xy[35][ 9]=(8<<4)|8;

	charset[0].nopts[36]=7;					/* D */
	charset[0].xy[36][ 0]=(0<<4)|0;
	charset[0].xy[36][ 1]=(0<<4)|12;
	charset[0].xy[36][ 2]=(6<<4)|12;
	charset[0].xy[36][ 3]=(8<<4)|10;
	charset[0].xy[36][ 4]=(8<<4)|2;
	charset[0].xy[36][ 5]=(6<<4)|0;
	charset[0].xy[36][ 6]=(0<<4)|0;

	charset[0].nopts[37]=7;					/* E */
	charset[0].xy[37][ 0]=(8<<4)|12;
	charset[0].xy[37][ 1]=(0<<4)|12;
	charset[0].xy[37][ 2]=(0<<4)|6;
	charset[0].xy[37][ 3]=(6<<4)|6;
	charset[0].xy[37][ 4]=(0<<4)|6;
	charset[0].xy[37][ 5]=(0<<4)|0;
	charset[0].xy[37][ 6]=(8<<4)|0;

	charset[0].nopts[38]=6;					/* F */
	charset[0].xy[38][ 0]=(0<<4)|0;
	charset[0].xy[38][ 1]=(0<<4)|6;
	charset[0].xy[38][ 2]=(6<<4)|6;
	charset[0].xy[38][ 3]=(0<<4)|6;
	charset[0].xy[38][ 4]=(0<<4)|12;
	charset[0].xy[38][ 5]=(8<<4)|12;

	charset[0].nopts[39]=11;				/* G */
	charset[0].xy[39][ 0]=(8<<4)|8;
	charset[0].xy[39][ 1]=(8<<4)|10;
	charset[0].xy[39][ 2]=(6<<4)|12;
	charset[0].xy[39][ 3]=(2<<4)|12;
	charset[0].xy[39][ 4]=(0<<4)|10;
	charset[0].xy[39][ 5]=(0<<4)|2;
	charset[0].xy[39][ 6]=(2<<4)|0;
	charset[0].xy[39][ 7]=(6<<4)|0;
	charset[0].xy[39][ 8]=(8<<4)|2;
	charset[0].xy[39][ 9]=(8<<4)|4;
	charset[0].xy[39][10]=(6<<4)|4;

	charset[0].nopts[40]=6;					/* H */
	charset[0].xy[40][ 0]=(0<<4)|0;
	charset[0].xy[40][ 1]=(0<<4)|12;
	charset[0].xy[40][ 2]=(0<<4)|6;
	charset[0].xy[40][ 3]=(8<<4)|6;
	charset[0].xy[40][ 4]=(8<<4)|12;
	charset[0].xy[40][ 5]=(8<<4)|0;

	charset[0].nopts[41]=6;					/* I */
	charset[0].xy[41][ 0]=(0<<4)|0;
	charset[0].xy[41][ 1]=(8<<4)|0;
	charset[0].xy[41][ 2]=(4<<4)|0;
	charset[0].xy[41][ 3]=(4<<4)|12;
	charset[0].xy[41][ 4]=(8<<4)|12;
	charset[0].xy[41][ 5]=(0<<4)|12;

	charset[0].nopts[42]=8;					/* J */
	charset[0].xy[42][ 0]=(0<<4)|4;
	charset[0].xy[42][ 1]=(0<<4)|2;
	charset[0].xy[42][ 2]=(2<<4)|0;
	charset[0].xy[42][ 3]=(4<<4)|0;
	charset[0].xy[42][ 4]=(6<<4)|2;
	charset[0].xy[42][ 5]=(6<<4)|12;
	charset[0].xy[42][ 6]=(8<<4)|12;
	charset[0].xy[42][ 7]=(4<<4)|12;

	charset[0].nopts[43]=6;					/* K */
	charset[0].xy[43][ 0]=(0<<4)|0;
	charset[0].xy[43][ 1]=(0<<4)|12;
	charset[0].xy[43][ 2]=(0<<4)|6;
	charset[0].xy[43][ 3]=(8<<4)|12;
	charset[0].xy[43][ 4]=(4<<4)|9;
	charset[0].xy[43][ 5]=(8<<4)|0;

	charset[0].nopts[44]=3;					/* L */
	charset[0].xy[44][ 0]=(0<<4)|12;
	charset[0].xy[44][ 1]=(0<<4)|0;
	charset[0].xy[44][ 2]=(8<<4)|0;

	charset[0].nopts[45]=5;					/* M */
	charset[0].xy[45][ 0]=(0<<4)|0;
	charset[0].xy[45][ 1]=(0<<4)|12;
	charset[0].xy[45][ 2]=(4<<4)|8;
	charset[0].xy[45][ 3]=(8<<4)|12;
	charset[0].xy[45][ 4]=(8<<4)|0;

	charset[0].nopts[46]=4;					/* N */
	charset[0].xy[46][ 0]=(0<<4)|0;
	charset[0].xy[46][ 1]=(0<<4)|12;
	charset[0].xy[46][ 2]=(8<<4)|0;
	charset[0].xy[46][ 3]=(8<<4)|12;

	charset[0].nopts[47]=9;					/* O */
	charset[0].xy[47][ 0]=(0<<4)|2;
	charset[0].xy[47][ 1]=(0<<4)|10;
	charset[0].xy[47][ 2]=(2<<4)|12;
	charset[0].xy[47][ 3]=(6<<4)|12;
	charset[0].xy[47][ 4]=(8<<4)|10;
	charset[0].xy[47][ 5]=(8<<4)|2;
	charset[0].xy[47][ 6]=(6<<4)|0;
	charset[0].xy[47][ 7]=(2<<4)|0;
	charset[0].xy[47][ 8]=(0<<4)|2;

	charset[0].nopts[48]=7;					/* P */
	charset[0].xy[48][ 0]=(0<<4)|0;
	charset[0].xy[48][ 1]=(0<<4)|12;
	charset[0].xy[48][ 2]=(6<<4)|12;
	charset[0].xy[48][ 3]=(8<<4)|10;
	charset[0].xy[48][ 4]=(8<<4)|8;
	charset[0].xy[48][ 5]=(6<<4)|6;
	charset[0].xy[48][ 6]=(0<<4)|6;

	charset[0].nopts[49]=12;				/* Q */
	charset[0].xy[49][ 0]=(8<<4)|2;
	charset[0].xy[49][ 1]=(6<<4)|0;
	charset[0].xy[49][ 2]=(2<<4)|0;
	charset[0].xy[49][ 3]=(0<<4)|2;
	charset[0].xy[49][ 4]=(0<<4)|10;
	charset[0].xy[49][ 5]=(2<<4)|12;
	charset[0].xy[49][ 6]=(6<<4)|12;
	charset[0].xy[49][ 7]=(8<<4)|10;
	charset[0].xy[49][ 8]=(8<<4)|2;
	charset[0].xy[49][ 9]=(7<<4)|1;
	charset[0].xy[49][10]=(4<<4)|4;
	charset[0].xy[49][11]=(8<<4)|0;

	charset[0].nopts[50]=9;					/* R */
	charset[0].xy[50][ 0]=(0<<4)|0;
	charset[0].xy[50][ 1]=(0<<4)|12;
	charset[0].xy[50][ 2]=(6<<4)|12;
	charset[0].xy[50][ 3]=(8<<4)|10;
	charset[0].xy[50][ 4]=(8<<4)|8;
	charset[0].xy[50][ 5]=(6<<4)|6;
	charset[0].xy[50][ 6]=(0<<4)|6;
	charset[0].xy[50][ 7]=(2<<4)|6;
	charset[0].xy[50][ 8]=(8<<4)|0;

	charset[0].nopts[51]=14;				/* S */
	charset[0].xy[51][ 0]=(0<<4)|3;
	charset[0].xy[51][ 1]=(0<<4)|2;
	charset[0].xy[51][ 2]=(2<<4)|0;
	charset[0].xy[51][ 3]=(6<<4)|0;
	charset[0].xy[51][ 4]=(8<<4)|2;
	charset[0].xy[51][ 5]=(8<<4)|4;
	charset[0].xy[51][ 6]=(6<<4)|6;
	charset[0].xy[51][ 7]=(2<<4)|6;
	charset[0].xy[51][ 8]=(0<<4)|8;
	charset[0].xy[51][ 9]=(0<<4)|10;
	charset[0].xy[51][10]=(2<<4)|12;
	charset[0].xy[51][11]=(6<<4)|12;
	charset[0].xy[51][12]=(8<<4)|10;
	charset[0].xy[51][13]=(8<<4)|9;

	charset[0].nopts[52]=4;					/* T */
	charset[0].xy[52][ 0]=(4<<4)|0;
	charset[0].xy[52][ 1]=(4<<4)|12;
	charset[0].xy[52][ 2]=(0<<4)|12;
	charset[0].xy[52][ 3]=(8<<4)|12;

	charset[0].nopts[53]=6;					/* U */
	charset[0].xy[53][ 0]=(0<<4)|12;
	charset[0].xy[53][ 1]=(0<<4)|2;
	charset[0].xy[53][ 2]=(2<<4)|0;
	charset[0].xy[53][ 3]=(6<<4)|0;
	charset[0].xy[53][ 4]=(8<<4)|2;
	charset[0].xy[53][ 5]=(8<<4)|12;

	charset[0].nopts[54]=3;					/* V */
	charset[0].xy[54][ 0]=(0<<4)|12;
	charset[0].xy[54][ 1]=(4<<4)|0;
	charset[0].xy[54][ 2]=(8<<4)|12;

	charset[0].nopts[55]=5;					/* W */
	charset[0].xy[55][ 0]=(0<<4)|12;
	charset[0].xy[55][ 1]=(2<<4)|0;
	charset[0].xy[55][ 2]=(4<<4)|6;
	charset[0].xy[55][ 3]=(6<<4)|0;
	charset[0].xy[55][ 4]=(8<<4)|12;

	charset[0].nopts[56]=5;					/* X */
	charset[0].xy[56][ 0]=(0<<4)|12;
	charset[0].xy[56][ 1]=(8<<4)|0;
	charset[0].xy[56][ 2]=(4<<4)|6;
	charset[0].xy[56][ 3]=(0<<4)|0;
	charset[0].xy[56][ 4]=(8<<4)|12;

	charset[0].nopts[57]=5;					/* Y */
	charset[0].xy[57][ 0]=(0<<4)|12;
	charset[0].xy[57][ 1]=(4<<4)|6;
	charset[0].xy[57][ 2]=(4<<4)|0;
	charset[0].xy[57][ 3]=(4<<4)|6;
	charset[0].xy[57][ 4]=(8<<4)|12;

	charset[0].nopts[58]=4;					/* Z */
	charset[0].xy[58][ 0]=(0<<4)|12;
	charset[0].xy[58][ 1]=(8<<4)|12;
	charset[0].xy[58][ 2]=(0<<4)|0;
	charset[0].xy[58][ 3]=(8<<4)|0;
}
