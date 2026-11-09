#include <dos.h>
#include <stdio.h>
#include <conio.h>

// return the amount of free disk space on the current drive
long getfreediskspace(void) 
{
    long freespace;
    int numsecperc; // sectors per cylinder
    int numavailc;  // number of available cylinders
    int numbpers;   // nuymber of bytes per sector
    int drive;      // current drive number 0=A: 1=B: 2=C: etc..

    _AX=0x1900;     // get current drive
    geninterrupt(0x21);
    drive=_AX;
    drive&=0x00FF;  // drive in AL

    drive++;         // drive number for get disk free space
                     // is 1=A: 2=B: 3=C: etc.. (Typical!)
    _AX=0x3600;      // get disk free space
    _DX=drive;       
    geninterrupt(0x21);
    numsecperc=_AX;
    numavailc =_BX;
    numbpers  =_CX;
    freespace=(long)numsecperc*(long)numavailc*(long)numbpers;
    return(freespace);
}
int main(/*int argc,char *argv[]*/)
{
    printf("Disk Space = %ld Bytes\n",getfreediskspace());
    return 1;
}

