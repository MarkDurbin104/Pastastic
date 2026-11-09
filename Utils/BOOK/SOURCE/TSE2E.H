/*
 *   TSE2E.H - Tseng 4000 Mode 2Eh Functions
 */

#ifndef _TSE2E_H_
#define _TSE2E_H_

#if defined( __cplusplus )
extern "C" {
#endif

void get_pixels_2e( unsigned char *pixels, int npixels,
                    int x, int y );
void put_pixels_2e( unsigned char *pixels, int npixels,
                    int x, int y );

#if defined( __cplusplus )
}
#endif

#endif
