#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <fcntl.h>

typedef unsigned short uint;
#define ERR_CODE       -1
#define _Big5Page0Total 441
#define _Big5Page1Total 5401
#define _Big5Page2Total 7652
#define _Set0BLast     537
#define _CharsInASet   191
#define _MagicNum1     314
#define _MagicNum2     282
#define _Big5Page0      0
#define _Big5Page1      _Big5Page0Total
#define _Big5Page2      (_Big5Page1 + _Big5Page1Total)
#define _Big5Max        (_Big5Page2 + _Big5Page2Total)
/* 5401 */
unsigned string[80];
uint Big5CodeToNum(uint code);
int SymbolIndex(void);
int CatrigeCharCode(uint b5number);
int AlphaSymbol(uint b5number);
uint Big5NumToCode(uint Big5Num);

char sendcmd;

char compchi;

uint chinese;
int index;
uint b5code;
char setname[3]={"\0"};
void nwritestring(unsigned char *str);

/*
void main(void)
{
    uint bcode;
//  bcode=Big5NumToCode(554);
//  printf("%4x\n",bcode);
}
*/

int CatrigeCharCode(uint b5number)
{
    if (index == 1) { /* two bytes alpha_symbol */
	if (b5number < _Big5Page0Total)
	    return(AlphaSymbol(b5number));
	}
    if (b5number > _Big5Page0Total) return((int)(b5number-_MagicNum2));
    return ((int)(b5number-_MagicNum1));
}

int AlphaSymbol(uint b5number)
{
    if (b5number>=234 && b5number <= 243) {
	return((int)(b5number - 186)); /* digits */
	}
    else
    if (b5number >= 266 && b5number <= 291) {
	return((int)(b5number - 201)); /* Upper case alpha */
	}
    else
    if (b5number >= 292 && b5number <= 317) {
	return((int)(b5number - 195)); /* lower case alpha */
	}
    else
    switch (b5number) {
	case   9: return(0x21);
	case  70: return(0x22);
	case  75: return(0x23);
	case 160: return(0x24);
	case 165: return(0x25);
	case  76: return(0x26);
	case  68: return(0x27);
	case  29: return(0x28);
	case  30: return(0x29);
	case  77: return(0x2a);
	case 109: return(0x2b);
	case   1: return(0x2c);
	case 110: return(0x2d);
	case   4: return(0x2e);
	case 156: return(0x2f);
	case   7: return(0x3a);
	case   6: return(0x3b);
	case 115: return(0x3c);
	case 117: return(0x3d);
	case 116: return(0x3e);
	case   8: return(0x3f);
	case 166: return(0x40);
	case  37: return(0x5b);
	case 157: return(0x5c);
	case  38: return(0x5d);
	case  51: return(0x5e);
	case  99: return(0x5f);
	case  67: return(0x60);
	case  33: return(0x7b);
	case  21: return(0x7c);
	case  34: return(0x7d);
	case 129: return(0x7e);
	}
    return ERR_CODE;
}

int SecondByteRange(uint *val)
{
    if ( (*val >= 0x0040) && (*val < 0x007f) ) {
	*val -= 0x0040;
	return 1;
	}
    else
    if ( (*val >=0x00a1) && (*val < 0x00ff) ) {
	*val -= 0x0062;
	return 1;
	}
    else return ERR_CODE;
}
int FirstByteRange(uint val)
{
    if ((val >= 0xa1) && (val <= 0xa3)) return 1;  /* SPCFONT */
    if ((val >= 0xa4) && (val <= 0xc6)) return 2;  /* STDFONT 5401 */
    if ((val >= 0xc9) && (val <= 0xf9)) return 3;  /* STDFONT 7652 */
    return ERR_CODE;
}
/******************************************************************************
 *              Big5CodeToNum()                                               *
 ******************************************************************************/
uint Big5CodeToNum(uint Big5Code)
{
   uint Big5Num=ERR_CODE, Byte1, Byte2;

   if ( (Big5Code != (uint)0) && (Big5Code != (uint)ERR_CODE) ) {
       Byte1 = Big5Code >> 8;
       Byte2 = Big5Code & 0x00ff;
       if (SecondByteRange(&Byte2)==ERR_CODE) Big5Num=ERR_CODE;
       else
       switch(FirstByteRange(Byte1)) {
	   case 1: /* SPCFONT */
	       Big5Num = (Byte1 - 0x00a1) * 157 + Byte2;
	       if ( Big5Num >= _Big5Page1 ) Big5Num = ERR_CODE;
	       break;
	   case 2: /* STDFONT 5401 */
	       Big5Num = (Byte1 - 0xa4) * 157 + Byte2 + _Big5Page1;
	       if ( Big5Num >= _Big5Page2 ) Big5Num = ERR_CODE;
	       break;
	   case 3: /* STDFONT 7652 */
	       Big5Num = (Byte1 - 0xc9) * 157 + Byte2 + _Big5Page2;
	       if ( Big5Num >= _Big5Max ) Big5Num = ERR_CODE;
	       break;
	   default:
	       Big5Num = ERR_CODE;
	   }
       }
    return Big5Num;
}
uint Big5NumToCode(uint Big5Num)
{
   uint Big5Code, Byte1, Byte2;

   if (Big5Num < _Big5Page1)
   {
      Byte1 = (Big5Num / 157) + 0x00a1;
      Byte2 = Big5Num % 157;
   }
   else if (Big5Num < _Big5Page2)
   {
      Big5Num -= _Big5Page1;
      Byte1 = (Big5Num / 157) + 0x00a4;
      Byte2 = Big5Num % 157;
   }
   else if (Big5Num < _Big5Max)
   {
      Big5Num -= _Big5Page2;
      Byte1 = (Big5Num / 157) + 0x00c9;
      Byte2 = Big5Num % 157;
   }
   if (Byte2 < 63)
   {
      Byte2 += 0x0040;
   }
   else
   {
      Byte2 += 0x0062;
   }

   Big5Code = (Byte1 << 8) | Byte2;

   return(Big5Code);
}
