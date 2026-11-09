/*********************************************************************
* Module Header
*
*  Identification:   PDFAPI.H - Library API Include File
*  Copyright (c) 1993 Symbol Technologies, Inc.
*
* Edit History:      
*  $Log$
*
*  Description:      Main include file for PDF encoder API.
*
**********************************************************************/
#ifndef  __PDFAPI_H__
#define  __PDFAPI_H__

#ifndef  __PDFTYPES_H__
#include "pdftypes.h"
#endif

#define  MAXROW      90    /* upper row limit */
#define  MAXCOL      30    /* upper column limit */

#define  ERR_NOERROR              0 /* successful completion */
#define  ERR_NULLDATASOURCE      -4 /* no input routine specified */
#define  ERR_INVALIDINPUTOBJECT  -5 /* PDFObject corrupt */
#define  ERR_TOOMANYCW           -7 /* re-size of barcode cannot contain data */
#define  ERR_NOTINPUTDEVICE      -8 /* PDFObject was not input type */
#define  ERR_NOTOUTPUTDEVICE     -9 /* PDFObject was not output type */
#define  ERR_NOFILTERSELECTED   -10 /* PDFSetOutput never called */
#define  ERR_TOOMUCHDATA        -11 /* input data length exceed barcode */
#define  ERR_NOACTIVEBARCODE    -12 /* attempt to print/query without barcode */
#define  ERR_MPCBTOOMUCH        -14 /* barcode too small for MPDF info */
#define  ERR_TOOMANYMPDF        -16 /* too many barcodes for MPDF */
#define  ERR_ECCEXCEEDSCAPACITY -17 /* barcode too small for ECC specified */
#define  ERR_MPDFBUFFERFUNC     -18 /* failure in MPDF buffering function */

#define  STATUS_NOMOREBARCODES    0
#define  STATUS_ENCODEOK          1
#define  STATUS_RENDEROK          ERR_NOERROR

typedef struct {
   uchar rows, cols;       /* data rows and columns for barcode */
   uint16 width, height;   /* width and height of barcode (in elements) */
   Bool truncated;         /* TRUE if barcode is truncated */
   uint16 mod_height;      /* module ratio - multiple of X dimension */
   uchar ecc_level;        /* error correction level 0-8 */
   uint16 pad_cw;          /* padding codewords applied to barcode */
   uint16 mpdf_cw;         /* MPDF codewords applied to barcode */
   uint16 data_cw;         /* data codewords applied to barcode */
   uint16 ecc_cw;          /* error correction codewords applied to barcode */
   uint32 size_estimate;   /* number of bytes required to render image */
} PDFDetailRec;

/*
   Output filter for compatability with older printer drivers:

      PDFSetOutput( output_dump, 0, [STRIP_ROWINDICATORS] | [DUMP_CODEWORDS] );
*/
#define  STRIP_ROWINDICATORS  0x0001
#define  DUMP_CODEWORDS       0x0002
extern OutFilter output_dump;

/*
   File/Memory/Function Object Creation
*/
void MakeMemoryObject( PDFObject *obj, ObjIO inout, void Far *base );
void MakeCallbackObject( PDFObject *Obj, ObjIO inout, PDFCALLBACK *func, uint32 lParam );
void MakeFileObject( PDFObject *obj, ObjIO inout, void *fp );
/*
   Standard PDF417 API Routine Prototypes
*/
Bool PDFSetAspect( const char *str );
Bool PDFSetModuleAspect( int aspect );
Bool PDFSetRowCol( int rows, int cols );
void PDFSetDimType( DimType type );
Bool PDFSetECCPercent( int percentage );
Bool PDFSetECCLevel( int level );
void PDFTruncate( Bool flag );
void PDFAbort( void );
void PDFSetDefaults( void );
/*
   Image driver (output filter) control
*/
Bool PDFOutputFilter( OutFilter *func, uint32 lparam, uint16 wparam );
void PDFSetFilterWord( uint16 w );
void PDFSettFilterLong( uint32 l );

#define  PDFSetCallbackParam( obj, lparam )  obj.access.func.app_arg = lparam

//int PDFEnumSizes( int *rows, int *cols );

int PDFEncode( PDFObject *in, long length );
void PDFGetDetails( PDFDetailRec *rec );
int PDFMakeImage( PDFObject *out, uint32 *size );

/*
   Macro PDF Routine Prototypes
*/
Bool MPDFDisable( void );
Bool MPDFEnable( void );   /* will clear/disable all optional fields */
Bool MPDFTimeStamp( Bool flag, uint32 time );
Bool MPDFFileSize( Bool flag );
Bool MPDFFileID( char *fid );       /* NULL will generate random id */
Bool MPDFFileName( char *fname );   /* NULL will disable */
Bool MPDFSenderID( char *sid );     /* NULL will disable */
Bool MPDFAddresseeID( char *aid );  /* NULL will disable */
Bool MPDFBlockCount( Bool flag, BufferFunc *func );
Bool MPDFChecksum( Bool flag, BufferFunc *func );

uint32 MPDFQueryBlockCount( void ); /* valid only if BlockCount enabled */

#endif
