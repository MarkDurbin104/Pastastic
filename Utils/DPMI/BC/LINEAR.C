/*---------------------------------------------------------------------------*/
/*                                                                           */
/*   LINEAR.C - An example of how to map a range of physical memory into     */
/*              your process space so that it can be addressed via a 32-bit  */
/*              near offset from DS.                                         */
/*                                                                           */
/*   Copyright (c) 1994 by Borland International                             */
/*   All Rights Reserved.                                                    */
/*                                                                           */
/*   This source code is hereby released into the public domain.             */
/*   Written by Jeffrey J. Peters                                            */
/*                                                                           */
/*   *** WARNING *** This example is *NOT* guaranteed to work under any      */
/*                   DPMI server except the one that Borland provides in     */
/*                   the DOS PowerPack.  It will definitely *NOT* work       */
/*                   under Windows, NT, Chicago, or OS/2.                    */
/*                                                                           */
/*---------------------------------------------------------------------------*/

#ifndef __DPMI32__
  #error This example is for DPMI32 only.
#endif

#include <dos.h>
#include <stdio.h>
#include <conio.h>

typedef unsigned long  bits32;
typedef unsigned short bits16;
typedef unsigned char  bits08;

#define PAGESIZE 0x1000   // page size is always 4k
// #define MONOCHROME     // uncomment this line if you have a mono card too.

// Assembly macros so bcc32 doesn't need to call tasm32 (for speed)
#define LAR_EAX_EBX  {__emit__ (0x0F); __emit__(0x02); __emit__(0xC3);}
#define LSL_EAX_EBX  {__emit__ (0x0F); __emit__(0x03); __emit__(0xC3);}
#define PUSH_BX      {__emit__ (0x53);}
#define POP_BX       {__emit__ (0x5B);}

bits32 hMem;    // This holds the DPMI handle to the address space we will
                // allocate.

bits32 AllocAndMapMemory (bits32 ConvMemAddr, bits32 Pages, bits32 *hMemBlk)
{
  static bits32 offset;
  static bits32 Len;
  Len = Pages * 0x1000;

  _AX = 0x0504;          // DPMI 0504h: Allocate Linear Memory Block
  _EBX = 0;              // let DPMI pick the address
  _ECX = Len;            // length in bytes
  _EDX = 0;              // uncommitted
  geninterrupt (0x31);   // call DPMI
  if (_FLAGS&1)
  {
    *hMemBlk = 0;
    return 0;
  }
  offset = _EBX;         // DPMI returns the new linear address
  *hMemBlk = _ESI;       // DPMI returns the handle to this memory block

  _AX = 0x0508;          // DPMI 0508h: Map Device in Memory Block
  // _ESI is already set
  _EBX = 0;              // start at offset 0 into our memory block
  _ECX = Pages;          // the number of pages to map
  _EDX = ConvMemAddr;    // the target address range to be mapped in
  geninterrupt (0x31);   // call DPMI
  if (_FLAGS&1)
  {
    *hMemBlk = 0;
    return 0;
  }
  return offset;
}

bits32 GetLimit (bits16 sel)
{
  _EBX = 0;
  _BX = sel;
  LSL_EAX_EBX;
  return _EAX;
}

void SetLimit (bits16 sel, bits32 off)
{
  static bits16 h,l;
  h = (bits16)(off >> 16);
  l = (bits16)(off & 0xFFFF);
  _AX = 8;                      // DPMI 0008h: Set Selector Limit
  _BX = sel;
  _CX = h;
  _DX = l;
  geninterrupt (0x31);          // call DPMI
}

bits32 GetBase (bits16 s)
{
  bits16 upr, lwr;

  PUSH_BX;                     // save EBX accross this function
  _EBX = 0;
  _EAX = 0;
  _BX = s;
  _AX = 6;                    // DPMI 0006h: Get Selector Base Address
  geninterrupt (0x31);        // call DPMI
  POP_BX;                     // restore EBX
  if (_FLAGS&1)
    return -1;
  upr = _CX;
  lwr = _DX;
  return ((bits32)upr)*0x10000L+lwr;
}

void *CreateMemoryAlias (bits32 mem, bits32 len)
{
  bits32 linear, length;
  length = (len + PAGESIZE -1) / PAGESIZE;
  linear = AllocAndMapMemory (mem, len, &hMem);      // Allocate address space
                                                     // and map in our memory.

  SetLimit (_DS, GetLimit (_DS)+(length*PAGESIZE));  // increase DS's limit
  return (void *)(linear - GetBase (_DS));
}

void DeleteMemoryAlias (void)
{
  _ESI = hMem;
  _ESI = _ESI >> 16;
  _EDI = hMem;                   // SI:DI gets 32-bit hMem
  _AX = 0x0502;                  // DPMI 0502h: Free Memory Block
  geninterrupt (0x31);           // call DPMI
}

void GraphTest (void *);
#pragma argsused
int main (int argc, char *argv[])
{
  bits08 *p;                // pointer to the base of this memory
  bits08 *GraphicsMemory;   // this will hold a pointer to A0000

#ifdef MONOCHROME
  bits16 *MonoMemory;       // this will hold a pointer to B0000
#endif

  bits16 *VGAMemory;        // this will hold a pointer to B8000
  int i,j,k;

  // This maps 128k of conventional memory from A0000 to BFFFF into our
  // processes address space so that it's addressable via DS.
  p = (bits08 *)CreateMemoryAlias (0x000A0000, 0x00020000);

  GraphicsMemory = (bits08 *) p;

#ifdef MONOCHROME
  MonoMemory     = (bits16 *) (p + 0x00010000);
#endif

  VGAMemory      = (bits16 *) (p + 0x00018000);

  for (k=0;k<256;k++)
    for (i=0;i<80*25;i++)
      VGAMemory[i] = ((VGAMemory[i]) & 0xFF00) | (VGAMemory[i]+1) & 0x00FF;

#ifdef MONOCHROME
  for (k=0;k<256;k++)
    for (i=0;i<80*25;i++)
      MonoMemory[i] = ((MonoMemory[i]) & 0xFF00) | (MonoMemory[i]+1) & 0x00FF;
#endif

  printf ("Press any key to preform graphics test...\n");
  getch ();
  GraphTest (GraphicsMemory);

  DeleteMemoryAlias ();         // clean up before leaving
  return 0;
}

void GraphTest (void *offset)
{
  bits32 *ptr = (bits32 *) offset;
  int j,k;

  _AX = 0x0013;          // BIOS: 320x200x256 graphics mode
  geninterrupt (0x10);

  for (k=0;k<256;k++)
    for (j=0;j<(320*200)/4;j++)
    {
      ptr[j] = (bits32) (j%16 + k ) % 16;
    }

  getch ();

  _AX = 0x0003;          // BIOS: 80x25 text mode
  geninterrupt (0x10);
}
