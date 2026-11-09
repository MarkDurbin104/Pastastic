/*
 *   EMS.H - EMS Memory Interface Functions
 */

#ifndef _EMS_H_
#define _EMS_H_

#if defined( __cplusplus )
extern "C" {
#endif

int    EMS_installed( void );
char * EMS_pgframeaddr( int physical_pg );
int    EMS_alloc( int npages );
void   EMS_free( int EMShandle );
int    EMS_mappage( int hand, int lpage, int ppage );

#if defined( __cplusplus )
}
#endif

#endif
