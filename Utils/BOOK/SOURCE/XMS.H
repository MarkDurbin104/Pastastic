/*
 *   XMS.H - XMS Memory Interface Functions
 */

#ifndef _XMS_H_
#define _XMS_H_

/*
 * note - this struct is packing sensitive!
 */

struct XMSmovestruct
{
   unsigned long  nbytes;
   unsigned short srchandle;
   unsigned long  srcoffset;
   unsigned short dsthandle;
   unsigned long  dstoffset;
};

#if defined( __cplusplus )
extern "C" {
#endif

int       XMS_installed( void );
unsigned  XMS_alloc( int nKBytes );
void      XMS_free( unsigned XMShand );
int       XMS_move( XMSmovestruct *ms );

#if defined( __cplusplus )
}
#endif

#endif
