/****************************************************************************
* Project     : GPA
* File        : extrdpmi.h
* Description : 
* 
* $Revision:   1.1  $  $Date:   Nov 01 1995 16:06:46  $  $Author:   JGRAY  $
*
* $Log:   I:/pvcs/gpa/h/extrdpmi.h_v  $
 * 
 *    Rev 1.1   Nov 01 1995 16:06:46   JGRAY
 *  
* 
****************************************************************************/
#ifndef EXTRDPMI_H    // stop multiple includes

#define EXTRDPMI_H

#ifdef PUBLIC
#undef PUBLIC
#endif

#ifdef INIT
#undef INIT
#endif

#ifdef EXTRDPMI_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S


PUBLIC void *   DPMIFUNC MK_FP       (UINT16 seg,UINT16 ofs,INT len);
//PUBLIC UINT16 DPMIFUNC FP_OFS      (void *);
//PUBLIC UINT16 DPMIFUNC FP_SEG      (void *);
PUBLIC void     DPMIFUNC freeblks    (void);

// PUBLIC SYMBOLS E

#ifdef EXTRDPMI_C

//------------------------PRIVATE Prototypes & Variables-------------------

#define PAGESIZE    0x1000   // page size is 4k
#define MAXMEMHAND  1000     // 1000 DPMI handles

// Assembly macros because I haven't got tasm32.exe
#define LAR_EAX_EBX  {__emit__ (0x0F); __emit__(0x02); __emit__(0xC3);}
#define LSL_EAX_EBX  {__emit__ (0x0F); __emit__(0x03); __emit__(0xC3);}
#define PUSH_BX      {__emit__ (0x53);}
#define POP_BX       {__emit__ (0x5B);}

INT     G_memh[MAXMEMHAND];
INT     G_nummh=0;

INT     getlowmem     (INT addr,INT np,INT *h);
INT     getlimit      (UINT16 sel);
void    setlimit      (UINT16 sel,INT off);
INT     getbase       (UINT16 s);
void *  makeptr       (INT mem,INT len,INT *h);
void    freememhand   (INT h);

#endif  //  def EXTRDPMI_C

#endif  //  ndef EXTRDPMI_H
// **************************************************************************
// extrdpmi.h <end-of-file>

