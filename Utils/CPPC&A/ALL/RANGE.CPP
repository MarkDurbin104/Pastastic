//=============================================================
//  MATHEMATICAL LIBRARY
//      range.cxx
//
//      A class that defines a subrange of int values.
//      Defining the preprocessor symbol RANGE_CHK_OFF
//      will remove all range checking code.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "range.h"
#include "limits.h"

#ifndef RANGE_CHK_OFF
    #include "stdlib.h"

    //--------------------
    // error output object
    //--------------------

    static const String ErrMsg("Range");

    ErrReporter * Range::ErrOut = new DosErrReporter(&ErrMsg);

    //----------------------
    // range-checking switch
    //----------------------

    Switch Range::RangeCheck = OFF;

    //------------------------
    // function to call ErrOut
    //------------------------

    void Range::ReportError(const String & msg)
        {
        if (ErrOut != NULL)
            ErrOut->Fatal(msg);
        }

    //--------------------------------
    // function to create a new ErrOut
    //--------------------------------

    void Range::SetErrOut(const ErrReporter & er)
        {
        if (ErrOut != NULL)
            delete ErrOut;

        ErrOut = new ErrReporter(er);

        if (ErrOut == NULL)
            exit(EXIT_FAILURE);
        }
#endif

//-------------
// constructors
//-------------

Range::Range(int rmin, int rmax)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (rmax < rmin)
                ReportError("maximum < minimum");
            }
    #endif

    Minimum = rmin;
    Maximum = rmax;

    if (Minimum < 0)
        {
        if (Maximum < 0)
            Magnitude = (unsigned int)(Minimum - Maximum);
        else
            Magnitude = (unsigned int)(-Minimum) + (unsigned int)Maximum;
        }
    else
        Magnitude = Maximum - Minimum;

    ++Magnitude;
    }

Range::Range(int rmax)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (rmax <= 1)
                ReportError("invalid construction");
            }
    #endif

    Minimum   = 1;
    Maximum   = rmax;
    Magnitude = rmax + 1;
    }

//-----------
// add ranges
//-----------

Range operator + (const Range & r1, const Range & r2)
    {
    #ifndef RANGE_CHK_OFF
        if (Range::RangeCheck == ON)
            {
            if ((unsigned int)(INT_MAX - r1.Maximum) < r2.Magnitude)
                Range::ReportError("addition out-of-range");
            }
    #endif

    Range result(r1.Minimum,r1.Maximum + r2.Magnitude);

    return result;
    }

//-------------------------------
// report error if 'n' is invalid
//-------------------------------

void Range::Check(int n) const
    {
    #ifndef RANGE_CHK_OFF
        if ((RangeCheck == ON) 
        && ((n < Minimum) || (n > Maximum)))
            ReportError("value out-of-bounds");
    #endif
    }
