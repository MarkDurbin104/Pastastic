//=============================================================
//  MATHEMATICAL CLASS LIBRARY
//      Random Number Generator (randgen.h)
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

#ifndef _RANDGEN_H
#define _RANDGEN_H

#include "stddef.h"
#include "time.h"

//-----------------
// class definition
//-----------------

class RandGen
    {
    public:
        // constructor
        RandGen(unsigned long initSeed = (unsigned long)time(NULL));

        // set seed value
        void SetSeed(unsigned long newSeed = (unsigned long)time(NULL));

        // get a psuedo-random number from 0 to (lim - 1)
        unsigned short operator () (unsigned short lim);

    private:
        unsigned long Seed;
    };

//----------------------------
// inline function definitions
//----------------------------

inline RandGen::RandGen(unsigned long initSeed)
    {
    Seed = initSeed;
    }

inline void RandGen::SetSeed(unsigned long newSeed)
    {
    Seed = newSeed;
    }

#endif
