/*********************************************************************
* Module Header
*
*  Identification:   pdftypes.h - Define PDFAPI Data Types
*  Copyright (c) 1993 Symbol Technologies, Inc.
*
* Edit History:      
*  $Log$
*
*  Description:       Defines basic data type for API.
*
**********************************************************************/
#ifndef  __PDFTYPES_H__
#define  __PDFTYPES_H__

/*
   Target Specific Data Types
*/
#include "machine.h"

#ifndef FALSE
#define  FALSE 0
#endif
#ifndef TRUE
#define  TRUE !(FALSE)
#endif

#define  LoWord( l )       (uint16)( l )
#define  HiWord( l )       (uint16)( (uint32)l >> 16 )
#define  HiByte( w )       (uchar)( (w) >> 8 )
#define  LoByte( w )       (uchar)( w )
#define  MakeLAddr( p )    (uint32)( (void Far *)&(p) )
#define  MakeLParam(hi,lo) ((uint32)(((uint16)(lo)) | (((uint32)((uint16)(hi))) << 16)))

#define  XDim2Dots(x,dpi)  (uint16)( ((float)(dpi) * (x)) + 0.5)

typedef enum { USE_FIXED, USE_LIMITS } DimType;

typedef enum {
   ROTATE_0   = 0x0000, ROTATE_90 = 0x0100, ROTATE_180 = 0x0200, 
   ROTATE_270 = 0x0300,

   FLIP_NONE = 0x0000, FLIP_VERT = 0x1000, FLIP_HORIZ = 0x2000,

   BIT_INVERT = 0x0080, /* invert 1's and 0's in bitmap */

   I_ROTATION        = 0x0f00,    /* isolate the rotation code */
   I_TRANSFORMATION  = 0x7000,    /* isolate the transformation code */
   I_MASK            = 0x7f00     /* isolate both codes */
} ImageMode;

typedef enum { BUF_OPEN, BUF_WRITE, BUF_REWIND, BUF_READ, BUF_CLOSE } BufCmd;
typedef int BufferFunc( BufCmd cmd, void *buf, int len );

typedef int PDFCALLBACK( void *mem, int len, uint32 lParam );
#define  MakeFunctionObject(pObj,io,pFunc)  MakeCallbackObject(pObj,io,(PDFCALLBACK)pFunc,0l)

typedef enum { PDF_MEMORY, PDF_FUNCTION, PDF_FILE } ObjType;
typedef enum { PDFINPUT, PDFOUTPUT } ObjIO;

typedef struct pdfobject {
   ObjType type;
   ObjIO direction;
   union {
      uchar Far *mem;
      struct {
         PDFCALLBACK *ptr;
         uint32 app_arg;
      } func;
      struct {
         int (*read)( struct pdfobject*, void*, int );
         int (*write)( struct pdfobject*, void*, int );
         void *ptr;
      } file;
   } access;
} PDFObject;

typedef long OutFilter( int cmd, PDFObject *out, void *rec, uint32 l, uint16 w);

#endif
