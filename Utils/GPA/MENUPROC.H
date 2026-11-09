#ifndef MENUPROC_H    // stop multiple includes

#define MENUPROC_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef MENUPROC_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

//-------------------------PUBLIC Prototypes & Variables-------------------
// PUBLIC SYMBOLS S

PUBLIC void         drawmenu    (void);
PUBLIC INT          runmenu     (void);
PUBLIC void 		menucur		(void);

// PUBLIC SYMBOLS E
#ifdef MENUPROC_C

//------------------------PRIVATE Prototypes & Variables-------------------

#endif  //  def MENUPROC_C

#endif  //  ndef MENUPROC_H
