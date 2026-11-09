#ifndef DISK_H    // stop multiple includes

#define DISK_H

#ifdef PUBLIC
#undef PUBLIC
#endif
#ifdef INIT
#undef INIT
#endif

#ifdef DISK_C
#define PUBLIC
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif
//-------------------------PUBLIC Prototypes & Variables------------------\



//------------------------------------------------------------------------/
#ifdef DISK_C
//------------------------PRIVATE Prototypes & Variables------------------\



//------------------------------------------------------------------------/
#endif  //  def DISK_C
#endif  //  ndef DISK_H
