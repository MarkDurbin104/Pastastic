//===========================================================================
// Module        : DUCT.H (declairations for DUCT.C)
// Synopsys      : resolve conflicts between duct and feature
// Description   : This module is used by the generated graphics sub-system
//               : To resolve any conflict between nodes that have been
//               : placed too close together on a diagram for easy reading
// Copyright (c) : Unisys Ltd. 1995
// Date          : 6th August 1995
//===========================================================================
// Date      Id   Modification history
//===========================================================================
// 06/08/95  MJD  Initial entry
//===========================================================================

#ifndef DUCT_H
#define DUCT_H

//===========================================================================
//                             Definitions
//===========================================================================

#ifdef INIT
#undef INIT
#endif
#ifdef EXTERN
#undef EXTERN
#endif

#ifdef DUCT_C        
#define INIT(a) =a      // initialise if included from feature.c
#define EXTERN          // set as internal if included from feature.c
#else
#define INIT(a)         // don't initialise if not included from feature.c
#define EXTERN extern   // set as external if not included from feature.c
#endif

//===========================================================================
//                        Global variables
//===========================================================================

EXTERN DUCT *       G_ducts       INIT( NULL ); // an array of ducts
EXTERN INT          G_numbducts   INIT( 0    ); // the number of ducts in the array

//===========================================================================
//                           Macros
//===========================================================================

#define NUMDUCT       (G_numbducts)       // macro to access the number of ducts
#define DUCTFROM(a)   (G_ducts[a].from)   // macro to access the duct from feature number
#define DUCTTO(a)     (G_ducts[a].to)     // macro to access the duct to feature number
#define DUCTBOUND(a)  (G_ducts[a].bound)  // macro to access the duct bounding parameter
#define DUCTVISIB(a)  (G_ducts[a].visib)  // macro to access the duct visibility flag
//===========================================================================
//                           Fuction prototypes
// See DUCTS.C for descriptions
//===========================================================================
EXTERN void resolve_duct_nap_conflicts (void);
EXTERN NUMB angle                      (COORD *a,COORD *b);
EXTERN void space_ducts                (void);
EXTERN void move_point_in_line         (INT lidx,COORD *point,NUMB offset,NUMB range);

#endif // ndef DUCT_H

//===========================================================================
//                           End of file
//===========================================================================

