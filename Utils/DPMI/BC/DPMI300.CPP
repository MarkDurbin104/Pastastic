//
// An example of how to call DPMI function 0x300 (simulate real-mode
// interrupt)
//
// This example calls the mouse interrupt (0x33) function 0x9 to
// change the graphics cursor.  It also demonstrates how to allocate
// DOS memory ( < 1Meg ) using DPMI 0x100 and 0x101.
//
// NOTE: Microsoft Windows DPMI server incorrectly implements
//       INT 0x33 function 0x9.  If you try to call it directly
//       (which should work), it will GP fault.  Instead, you
//       must call the interrupt via DPMI 0x300.
//

#if !defined( __DPMI16__ )
#error This program must be compiled for 16-bit DPMI
#endif

#include <stdio.h>
#include <dos.h>
#include <mem.h>
#include <conio.h>

// some usefull typedefs

typedef unsigned long  ulong;
typedef unsigned int   ushort;
typedef unsigned char  uchar;

// this defines the mouse cursor.  The first 32 bytes are a mask
// which is AND'ed with the screen.  The second 32 bytes are a
// mask which is then OR'ed with the screen.  Each mask is
// 16x16 pixels, 1 bit per pixel
//
ushort mouse_graphics[] = { 0xFC3F,0xFC3F,0xFC3F,0xFC3F,
                            0xFC3F,0xFC3F,0x0000,0x0000,
                            0x0000,0x0000,0xFC3F,0xFC3F,
                            0xFC3F,0xFC3F,0xFC3F,0xFC3F,
                            0x0000,0x0180,0x0180,0x0180,
                            0x0180,0x0180,0x0180,0x7E7E,
                            0x7E7E,0x0180,0x0180,0x0180,
                            0x0180,0x0180,0x0180,0x0000 };

// This structure is used by the DPMI 0x300.  It contains the
// registers that will be passed to the real-mode interrupt
//
struct RealRegs {
  ulong   di,si,bp,always_zero,bx,dx,cx,ax;
  ushort  flags,es,ds,fs,gs,ip,cs,sp,ss;
};

RealRegs global_regs = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };

ushort mseg,msel;
short  *realmouse;

int main( void ) {

  asm {
    mov ax,0x13    // set mode 13h
    int 0x10

    mov ax,0       // reset mouse
    int 0x33

    mov ax,1       // show mouse cursor
    int 0x33

    mov  ax,0x100    // allocate 64 bytes of DOS memory
    mov  bx,4
    int  0x31
    jc   alloc_error  // make sure it worked
    mov  mseg,ax
    mov  msel,dx
    jmp  alloc_ok
  }
alloc_error:
  asm {
    mov ax,3
    int 0x10
  }
  printf("could not allocate 64 bytes of DOS memory\n");
  return 0;
alloc_ok:

  // create a pointer to the memory, that we can use from protected
  // mode.  This is used to copy our graphics image to DOS memory

  realmouse = (short *)MK_FP( msel, 0 );

  // Warning!!  the _fmemcpy will result in ES being loaded with
  // the selector we just allocated.  In DPMI 0.9, when you free
  // the memory, the selector is destroyed and a GPF will result
  // if you still have the selector loaded in a segment register

  _fmemcpy( realmouse, mouse_graphics, 64 );

  // set up the register structure for an INT 0x33 call

  global_regs.ax = 9;     // call mouse function 9
  global_regs.bx = 14;    // x hot-spot
  global_regs.cx = 7;     // y hot-spot
  global_regs.es = mseg;  // segment of cursor in DOS memory

  // simulate the interrupt call

  asm {
    mov  ax,0x300
    mov  bl,0x33
    mov  bh,0
    mov  cx,0
    mov  di,seg global_regs
    mov  es,di
    mov  di,offset global_regs
    int  0x31
  }

  while (!kbhit());
  if (!getch()) getch();

  // free up the 64 bytes of DOS memory we allocated

  asm {
    mov  ax,0        // clear ES, just in case it still contains
    mov  es,ax       // the selector we are about to destroy
                     // (which would cause a GP)

    mov  ax,0x101    // free DOS memory
    mov  dx,msel
    int  0x31
    mov ax,3
    int 0x10
  }

  return 0;
}
