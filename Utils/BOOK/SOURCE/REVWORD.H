/*
 *   REVWORD.H - Functions to reverse byte orders
 */

#ifndef _REVWORD_H_
#define _REVWORD_H_

#if defined( __cplusplus )
extern "C" {
#endif

unsigned short rev_word( unsigned short );
unsigned long rev_dword( unsigned long );

#if defined( __cplusplus )
}
#endif

#endif
