/*
 *   VGA12.H - VGA Mode 12h Functions
 */

#ifndef _VGA12_H_
#define _VGA12_H_

#if defined( __cplusplus )
extern "C" {
#endif

void get_pixels_12( unsigned char *pixels, int npixels,
                    int x, int y );
void put_pixels_12( unsigned char *pixels, int npixels,
                    int x, int y );

#if defined( __cplusplus )
}
#endif

#endif
