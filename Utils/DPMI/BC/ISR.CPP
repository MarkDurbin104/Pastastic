#include <stdio.h>
#include <conio.h>

#ifndef __DPMI32__
#error Must be compiled for 32-bit DPMI.  Use BCC32 -WX
#endif

#pragma inline

#define INTERRUPT 0x08

typedef unsigned char  uchar;
typedef unsigned short ushort;
typedef unsigned long  ulong;

struct fword {
  ulong  offset;
  ushort selector;
};

ulong ticks=0;

fword oldhandler;
unsigned short dataseg;

extern "C" void handler( void );

void setvect( uchar vector, ushort sel, ulong ofs ) {
  asm {
    push ds
    push edx
    push ax
    mov  edx,ofs
    mov  ax,sel
    mov  ds,ax
    mov  ah,0x25
    mov  al,vector
    int  0x21
    pop  ax
    pop  edx
    pop  ds
  }
}

void getvect( uchar vector, ushort *sel, ulong *ofs ) {
  ushort tempsel;
  ulong  tempofs;
  asm {
    push es
    mov ah,0x35
    mov al,vector
    int 0x21
    mov ax,es
    pop es
    mov tempsel,ax
    mov tempofs,ebx
  }
  *sel = tempsel;
  *ofs = tempofs;
}

int main(void) {
  ushort sel;
  ulong  ofs;

  dataseg=_DS;

  getvect( INTERRUPT, &oldhandler.selector, &oldhandler.offset );
  printf("interrupt %02X is at %04X:%08lX\n",INTERRUPT,
                                             oldhandler.selector,
                                             oldhandler.offset );
  setvect( INTERRUPT, _CS, (unsigned long)&handler );
  printf("new handler installed, press any key to quit\n");

  while (!kbhit()) {
    printf("%cTimer ticks: %lu",13,ticks);
  }
  printf("\n");

  printf("removing handler\n");
  setvect( INTERRUPT, oldhandler.selector, oldhandler. offset );

  return 0;
}
