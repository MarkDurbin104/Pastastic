/****************************************************************************
* Project     : GPA
* File        : barcode.c
* Description : Program to print barcodes - specified as CLI key words
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 15:13:54  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/c/barcode.c_v  $
* 
*    Rev 1.1   Nov 01 1995 15:13:54   JGRAY
*  
* 
****************************************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BYTEPERLN   1
#define BITPERBAR   1
#define BARWIDTH    13
#define BARHIGHT    3

#define SET_FP_SEG(fp,value)    *((unsigned *)&(fp) + 1) = value
#define SET_FP_OFF(fp,value)    *((unsigned *)&(fp)) = value
// barcode prints black white black white ...
// 0 means thin bar 1 means thick bar (2 times width of thin bar)
// bars last character signifies the character that the code converts to
char    bars[51][11]={            /* bit maps for series 39 bar codes */
    "010101000$",
    "000101010%",
    "010010100*",
    "010001010+",
    "011000100 ",
    "010000101-",
    "110000100.",
    "010100010/",
    "0001101000",
    "1001000011",
    "0011000012",
    "1011000003",
    "0001100014",
    "1001100005",
    "0111000006",
    "0001001017",
    "1001001008",
    "0011001009",
    "100001001A",
    "001001001B",
    "101001000C",
    "000011001D",
    "100011000E",
    "001011000F",
    "000001101G",
    "100001100H",
    "001001100I",
    "000011100J",
    "100000011K",
    "001000011L",
    "101000010M",
    "000010011N",
    "100010010O",
    "001010010P",
    "000000111Q",
    "100000110R",
    "001000110S",
    "000010110T",
    "110000001U",
    "011000001V",
    "111000000W",
    "010010001X",
    "110010000Y",
    "011010000Z"
};
//************************************************************
//S set port 4 bios address

void set_com4_addr(void)
{
    char far *com4addr;             /* far pointer to com4 address  */

    /* set port 4 address in BIOS data area */
    SET_FP_SEG(com4addr, 0x40);
    SET_FP_OFF(com4addr, 0x06);
    *com4addr = 0x10;
    com4addr++;
    *com4addr = 0x03;
}

//************************************************************
//S determine which barcode to use from table for a given char
//P char to seek in table
//R integer table entry number 

unsigned char convert(char c)
{
    int i;
    for (i=0;i<51;i++) 
        if (bars[i][9]==c) return((unsigned char)i);
    return(4);
}

//************************************************************
//S print lo bar to specified file channel
//P FILE ptr : File channel number

void lobar(FILE *p)
{
    int i;
    for (i=0;i<BYTEPERLN*BITPERBAR;i++)
        fputc(0,p);
}

//************************************************************
//S print hi bar to specified file channel
//P FILE ptr : File channel number

void hibar(FILE *p)
{
    int i;
    for (i=0;i<BYTEPERLN*BITPERBAR;i++)
        fputc(255,p);
}

//************************************************************
//S main routine to take key words and print them as barcodes
// keywords supplied on command line
//P standard no. of cli parameters
//P pointer to table of cli parameters
//R integer return reply code

int main(int argc,char *argv[])
{
    FILE *p;
    int i,j,k,h;
    long v;
    char buf[255];
    char buf1[255];
    
    if (argc<2) {
        printf("%s value\n",argv[0]);
        return(0);
    }
    set_com4_addr();                        // set BIOS address for COM4 to 0x310 (ECCO+ Counter terminal COM4 printer) 
    p=fopen("COM4","w");                    /* open printer  */
    fprintf(p,"%c3%c",27,32);               /* 8 dot spacing */

    strcpy(buf1,argv[1]);   // Get data from command line
    i=strlen(buf1);
    buf[0]=convert('*');    // add * at start and end of code sequence
    for (j=0;j<i;j++) 
        buf[j+1]=convert(buf1[j]);
    buf[j+1]=convert('*');
    i+=2;
    for (h=0;h<BARHIGHT;h++) { 
        fputc('\n',p);
        // start of graphics
        fprintf(p,"%c*%c%c%c",27,0,(i*BARWIDTH*BITPERBAR)%256,(i*BARWIDTH*BITPERBAR)/256);
        for (j=0;j<i;j++) {     // for each character in the barcode
            for (k=0;k<9;k++) { // for each line in the character barcode
                if (bars[buf[j]][k]=='0') { // if it's a thin bar
                    if (k&1) {  // white bar line
                        lobar(p);
                    } else {    // black bar line
                        hibar(p);
                    }
                }
                else { // if it's a thick bar
                    if (k&1) { // white bar line
                        lobar(p);
                        lobar(p); // double up
                    } else {   // black bar line
                        hibar(p);
                        hibar(p); // double up
                    }
                }
            }
            lobar(p); // add a space (white bar)
        }
    }
    i-=2;
    // reset line spacing and print the barcode text
    fprintf(p,"%c3%c\n%*.*s%s\n",27,40,(i*10)/12,(i*10)/12," ",argv[1]);
    fclose(p);
    return(1);
}
              
              
// **************************************************************************
// barcode.c <end-of-file>

