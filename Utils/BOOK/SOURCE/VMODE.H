/*
 *   VMODE.H - Video mode functions
 */

#ifndef _VMODE_H_
#define _VMODE_H_

#if defined( __cplusplus )
extern "C" {
#endif

int  getvideomode( void );
void setvideomode( int mode );

#if defined( __cplusplus )
}
#endif

#endif
