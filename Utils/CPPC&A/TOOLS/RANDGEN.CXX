//=============================================================
//  MATHEMATICAL CLASS LIBRARY
//      Random Number Generator (randgen.cxx)
//
//      The RandGen class defines a psuedo-random number
//      generator that uses the linear congruential method.
//
//      -------------------------------------------------------
//      08-Jan-1992  1.00  Original version
//      -------------------------------------------------------
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "randgen.h"

//--------------------------------------------------------
// NOTE:
//      This generator depends upon overflow. It will NOT
//      work correctly in an environment where shorteger
//      arithmetic can generate an overflow exception.
//--------------------------------------------------------

unsigned short RandGen::operator () (unsigned short lim)
    {
    // get next seed value
    Seed = Seed * 5709421UL + 1UL;

    // return value from 0 to (lim - 1)
    return (unsigned short)((Seed >> 16UL) % lim);
    }
