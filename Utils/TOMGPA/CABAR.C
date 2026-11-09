#include <stdlib.h>
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <io.h>
#include <ctype.h>
#include "pdfapi.h"

#define BLKASP 3
#define MAGNIF 3
#define DPI    300

unsigned char *G_plbuf[130];
FILE *G_printer;

unsigned char G_cabuf[1034];
int           G_caerror=0;
int G_nfl2bit[11]={0,4,7,10,14,17,20,24,27,30,32};
char *G_base64num="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz.?";
unsigned char G_week=1;
unsigned long G_office;

void BitAssign(unsigned char *buf,int bitpos,unsigned char val,unsigned char bitlen)
{
    unsigned int tb;
    tb=(int)val;
    tb<<=(16-bitlen)-(bitpos%8);
    buf+=bitpos/8;
    *(buf++)|=(unsigned char)((tb>>8)&0xFF);
    *buf    |=(unsigned char)( tb    &0xFF);
}
unsigned char BitGet(unsigned char *buf,int bitpos,unsigned char bitlen)
{
    unsigned int tb;
    buf+=bitpos/8;
    tb=(unsigned int)*(buf++)<<8;
    tb|=(unsigned int)*(buf);
    tb>>=(16-bitlen)-(bitpos%8);
    tb&=(0xFF>>(8-bitlen));
    return((unsigned char)tb);
}
void Set3Bit(unsigned char *buf,int pos,unsigned char val)
{
    BitAssign(buf,pos*3,val,3);
}
unsigned char Get3Bit(unsigned char *buf,int pos)
{
    return BitGet(buf,pos*3,3);
}
void SetBitNum(unsigned char *buf,int bitpos,unsigned long val,unsigned char bitsize)
{
    if (bitsize<=8) {
        BitAssign(buf,bitpos   ,(unsigned char)(val)&0xFF,bitsize);
    } else if (bitsize<=16) {
        BitAssign(buf,bitpos   ,(unsigned char)(val>>8 )&0xFF,8);
        BitAssign(buf,bitpos+8 ,(unsigned char)(val)&0xFF,bitsize-8);
    } else if (bitsize<=24) {
        BitAssign(buf,bitpos   ,(unsigned char)(val>>16)&0xFF,8);
        BitAssign(buf,bitpos+8 ,(unsigned char)(val>>8 )&0xFF,8);
        BitAssign(buf,bitpos+16,(unsigned char)(val)&0xFF,bitsize-16);
    } else {
        BitAssign(buf,bitpos   ,(unsigned char)(val>>24)&0xFF,8);
        BitAssign(buf,bitpos+8 ,(unsigned char)(val>>16)&0xFF,8);
        BitAssign(buf,bitpos+16,(unsigned char)(val>>8 )&0xFF,8);
        BitAssign(buf,bitpos+24,(unsigned char)(val)&0xFF,bitsize-24);
    }
}
unsigned long GetBitNum(unsigned char *buf,int bitpos,unsigned char bitsize)
{
    unsigned long val;
    if (bitsize<=8) {
        val=(unsigned long)BitGet(buf,bitpos    ,bitsize);
    } else if (bitsize<=16) {
        val=(unsigned long)BitGet(buf,bitpos    ,8);
        val<<=8L;
        val|=(unsigned long)BitGet(buf,bitpos+8 ,bitsize-8);
    } else if (bitsize<=24) {
        val=(unsigned long)BitGet(buf,bitpos    ,8);
        val<<=8L;
        val|=(unsigned long)BitGet(buf,bitpos+8 ,8);
        val<<=8L;                               
        val|=(unsigned long)BitGet(buf,bitpos+16,bitsize-16);
    } else {
        val=(unsigned long)BitGet(buf,bitpos    ,8);
        val<<=8L;
        val|=(unsigned long)BitGet(buf,bitpos+8 ,8);
        val<<=8L;
        val|=(unsigned long)BitGet(buf,bitpos+16,8);
        val<<=8L;
        val|=(unsigned long)BitGet(buf,bitpos+24,bitsize-24);
    }
    return val;
}
int GetCALine(int lineno,int *qty,long *val,int ofs)
{
    int valsize,qtysize;

    switch (Get3Bit(G_cabuf+5,lineno)) {
        case 0 : *qty=0; *val=0L; return ofs;

        case 1 : valsize=14; qtysize= 4; break;
        case 2 : valsize=17; qtysize= 4; break;
        case 3 : valsize=20; qtysize= 4; break;
        case 4 : valsize=17; qtysize= 7; break;
        case 5 : valsize=20; qtysize= 7; break;
        case 6 : valsize=20; qtysize=10; break;
        case 7 : valsize=27; qtysize=14; break;
    }
    *qty=(int)GetBitNum(G_cabuf+5,ofs,qtysize);
    *val=GetBitNum(G_cabuf+5,ofs+qtysize,valsize);
    ofs+=valsize+qtysize;
    return ofs;
}
int SetCALine(int lineno,int qty,long val,int ofs)
{
    int valsize,qtysize,blktype;

    if ((qty==0)&&(val==0L)) {
        Set3Bit(G_cabuf+5,lineno,0);
        return ofs;
    }

    if        (qty<16) {
        qtysize=1;
    } else if (qty<128) {
        qtysize=2;
    } else if (qty<1024) {
        qtysize=3;
    } else if (qty<16384) {
        qtysize=4;
    } else {
        G_caerror=1;
        return ofs;
    }
    if        (val<16384L) {
        valsize=1;
    } else if (val<131072L) {
        valsize=2;
    } else if (val<1048576L) {
        valsize=3;
    } else if (val<134217728L) {
        valsize=4;
    } else {
        G_caerror=1;
        return ofs;
    }
    switch (valsize) {
        case 1 :
            switch (qtysize) {
                case 1 : blktype=1; break;
                case 2 : blktype=4; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 2 :
            switch (qtysize) {
                case 1 : blktype=2; break;
                case 2 : blktype=4; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 3 :
            switch (qtysize) {
                case 1 : blktype=3; break;
                case 2 : blktype=5; break;
                case 3 : blktype=6; break;
                case 4 : blktype=7; break;
            }
            break;
        case 4 :
            blktype=7;
            break;
    }
    switch (blktype) {
        case 1 : valsize=14; qtysize= 4; break;
        case 2 : valsize=17; qtysize= 4; break;
        case 3 : valsize=20; qtysize= 4; break;
        case 4 : valsize=17; qtysize= 7; break;
        case 5 : valsize=20; qtysize= 7; break;
        case 6 : valsize=20; qtysize=10; break;
        case 7 : valsize=27; qtysize=14; break;
    }
    if ((ofs+valsize+qtysize)>(sizeof(G_cabuf)*8) ) {
        G_caerror=2;
        return ofs;
    }
    Set3Bit(G_cabuf+5,lineno,blktype);
    SetBitNum(G_cabuf+5,ofs,(long)qty,qtysize);
    SetBitNum(G_cabuf+5,ofs,val,valsize);
    ofs+=valsize+qtysize;
    return ofs;
}

int GetCAQty(int lineno)
{
    return (lineno+G_week)%16;
}
long GetCAVal(int lineno)
{
    return (long)(lineno*(100+G_week));
}
int SetCAQty(int lineno,int qty)
{
    return 1;
}
int SetCAVal(int lineno,long val)
{
    return 1;
}

int SetCALines(int start)
{
    int i,ofs;
    G_caerror=0;
    memset(G_cabuf,0,sizeof(G_cabuf));
    *((long*)G_cabuf)=G_office;
    *(G_cabuf+4)=G_week;

    ofs=1008;
    for (i=start;i<334;i++) {
        ofs=SetCALine(i,GetCAQty(i),GetCAVal(i),ofs);
        if (G_caerror==1) return 0;
        if (G_caerror==2) return -i;
    }
    return ofs;
}
int GetCALines(void)
{
    int i,ofs;
    int qty;
    long val;
    ofs=1008;
    for (i=0;i<334;i++) {
        ofs=GetCALine(i,&qty,&val,ofs);
        SetCAVal(i,val);
        SetCAQty(i,qty);
    }
    return 1;
}
int paktext(char *str,unsigned char *buf,int bitofs,int slen)
{
    while (slen) {
        if ((*str>='0')&&(*str<='9')) {
            BitAssign(buf,bitofs,(*str)-'0',6);
        } else if ((*str>='A')&&(*str<='Z')) {
            BitAssign(buf,bitofs,((*str)-'A')+10,6);
        } else if ((*str>='a')&&(*str<='z')) {
            BitAssign(buf,bitofs,((*str)-'a')+36,6);
        } else if  (*str=='.') {
            BitAssign(buf,bitofs,62,6);
        } else {
            BitAssign(buf,bitofs,63,6);
        }
        bitofs+=6;
        str++;
        slen--;
    }
    return bitofs;
}
int paknumb(char *numb,unsigned char *buf,int bitofs,unsigned int nlen)
{
    if (nlen) {
        if (nlen>10) nlen=10;
        SetBitNum(buf,bitofs,atol(numb),G_nfl2bit[nlen]);
        bitofs+=G_nfl2bit[nlen];
    }
    return bitofs;
}
void BitSet(unsigned char *buf,int bitpos,unsigned char val,unsigned char bitlen)
{
    unsigned int tb;
    if (val) {
        val=0xFF>>(8-bitlen);
        tb=(int)val;
        tb<<=(16-bitlen)-(bitpos%8);
        buf+=bitpos/8;
        *(buf++)|=(unsigned char)((tb>>8)&0xFF);
        *buf    |=(unsigned char)( tb    &0xFF);
    }
}
int buildline(char *l,int mag,int lno)
{
    int i,j,k,m;
    j=0;
    for (i=0;i<strlen(l);i++) {
        if (isdigit(l[i])) j+=(l[i]-'0');
    }
    j*=mag;
    G_plbuf[lno]=malloc((j+7)/8+1);
    if (G_plbuf[lno]==NULL) return(0);
    memset(G_plbuf[lno],0,(j+7)/8+1);
    j=0;
    for (i=0;i<strlen(l);i++) {
        k=l[i]-'0';
        for (m=0;m<k;m++) {
            BitSet(G_plbuf[lno],j,!(i&1),mag);
            j+=mag;
        }
    }
    return(j);
}
int printbar(int x,int y,int mag,int dpi)
{
    char tmp[256];
    int i=0,j,l,m,n;
    FILE *fp;

    x*=dpi;
    y*=dpi;

    if ((fp=fopen("PDF417OP.GPA","r"))==NULL) return(0);
    while (fgets(tmp,255,fp)!=NULL) {
        if (isdigit(tmp[0])) j=buildline(tmp,mag,i++);
    }
    fprintf(G_printer,"%c*t%dR",27,dpi);                 // set DPI
    fprintf(G_printer,"%c*p%dx%dY",27,x,y);              // set x/y pos
    fprintf(G_printer,"      PDF417 POCL Cash Account");
    fprintf(G_printer,"%c*p%dx%dY",27,x,y+dpi/5);       // set x/y pos
    fprintf(G_printer,"%c*r0F",27);                      // turn on graphics
    fprintf(G_printer,"%c*r%ds%dt1A",27,j,i*BLKASP*mag); // set blk size
    for (m=0;m<i;m++) {
        for (n=0;n<BLKASP*mag;n++) {
            fprintf(G_printer,"%c*b%dW",27,((j+7)/8));   // tx 1 line
            for (l=0;l<((j+7)/8);l++) {
                fprintf(G_printer,"%c",G_plbuf[m][l]);
            }
        }
    }
    fprintf(G_printer,"%c*rB",27);                      // turn off graphics
    fprintf(G_printer,"%c*p%dx%dY",27,x,y+(dpi*2)/5+BLKASP*mag*i);   // set x/y pos
    fprintf(G_printer,"   Printed from G.P.A. by Unisys\r\n");
    fprintf(G_printer,"      Office %ld     Week %02d",G_office,G_week);
//    fprintf(G_printer,"%c&l1T",27);                     // ???????
//    fprintf(G_printer,"%cE",27);                        // reset printer
    return(1);
}
void get3at(int x,int y,unsigned char b[])
{
    int i,j,k;
    unsigned char mask=0x80>>(x&7);
    memset(b,0,3);
    x/=8;
    for (i=0;i<4;i++) {
        if ((G_plbuf[y+i][x]&mask)!=0) {
            switch (i) {
                case 0 :
                    b[0]|=0xFC;
                    break;
                case 1 :
                    b[0]|=0x03;
                    b[1]|=0xF0;
                    break;
                case 2 :
                    b[1]|=0x0F;
                    b[2]|=0xC0;
                    break;
                case 3 :
                    b[2]|=0x3F;
                    break;
            }
        }
    }
}
int printebar(int x,int y)
{
    char tmp[256];
    unsigned char a[3];
    int i=0,j,k,l,m,n;
    FILE *fp;

    if ((fp=fopen("PDF417OP.GPA","r"))==NULL) return(0);
    while (fgets(tmp,255,fp)!=NULL) {
        if (isdigit(tmp[0])) j=buildline(tmp,1,i++);
    }
    for (k=i;k<i+4;k++) {
        G_plbuf[k]=malloc((j+7)/8+1);
        if (G_plbuf[k]==NULL) return(0);
        memset(G_plbuf[k],0,(j+7)/8+1);
    }
    fprintf(G_printer,"      PDF417 POCL Cash Account\r\n");
    fprintf(G_printer,"%cU1%cA%c",27,27,8); // unidirectional on linspacing 8
    for (l=0;l<i;l+=4) {
  		fprintf(G_printer,"%c*%c%c%c",27,40,(j*4)%256,(j*4)/256);
        for (m=0;m<j;m++) {
            get3at(m,l,a);
            for (n=0;n<4;n++) {
                for (k=0;k<3;k++) {
       			    switch(a[k]) {
       				    case 26 :
       					    fprintf(G_printer,"%c",24);
       					    break;
       				    case 10 :
       					    fprintf(G_printer,"%c",9);
       					    break;
       				    default :
       					    fprintf(G_printer,"%c",a[k]);
       			    }
                }
            }
        }
		fprintf(G_printer,"\n");
    }
    fprintf(G_printer,"%cU0%cA%c",27,27,10); // unidirectional off linspacing 10
    fprintf(G_printer,"   Printed from G.P.A. by Unisys\r\n");
    fprintf(G_printer,"      Office %ld     Week %02d\r\n",G_office,G_week);
	fprintf(G_printer,"%c",12);
    return(1);
}
int pdf417(int ptype)
{
    int s;
    FILE *fp,*ofp;
    PDFObject IFile, OFile;
    long length;
    G_printer=fopen("lpt1","w");
    if ((ofp=fopen("PDF417OP.GPA","w"))!=NULL) {
        PDFSetDimType(USE_FIXED);
        MakeFileObject(&OFile,PDFOUTPUT,ofp);
        PDFOutputFilter(output_dump,0,0);
        if ((fp=fopen("PDF417.GPA","rb"))!=NULL) {
            length=filelength(fileno(fp));
            MakeFileObject(&IFile,PDFINPUT,fp);
            if ((s=PDFEncode(&IFile,length))>0) s=PDFMakeImage(&OFile,NULL);
            fclose(fp);
            fclose(ofp);
            if (s>=0) {
                if (ptype) {
                    s=printebar(0,0);
                } else {
                    s=printbar(0,0,MAGNIF,DPI);
                }
            }
        } else {
            return(0);
        }
        return(s);
    }
    return(0);
}

int main(int argc,char *argv[])
{
    int i;
    FILE *fp;
    if (argc<3) {
        printf("CABAR WEEKNO OFFICECODE [PRINTER 0=HP(default) 1=EPSON]\n");
        return 1;
    }
    G_week=atoi(argv[1]);
    G_office=atol(argv[2]);

    fp=fopen("PDF417.GPA","wb");
    i=SetCALines(0);
    if (i<0) {
        fwrite(G_cabuf,1,1034,fp);
        i=SetCALines(0-i);
        if (i>0) fwrite(G_cabuf,1,(i+7)/8,fp);
    } else if (i!=0) {
        fwrite(G_cabuf,1,(i+7)/8,fp);
    }
    fclose(fp);
    if (argc==4) return pdf417(atoi(argv[3]));
    return pdf417(0);
}
