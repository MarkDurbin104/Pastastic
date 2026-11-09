//====================================================
//  MATHEMATICAL LIBRARY
//      range.h
//
//      A class that defines a subrange of int values.
//      Defining the preprocessor symbol RANGE_CHK_OFF
//      will remove all range checking code.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//====================================================

#ifndef RANGE_H
#define RANGE_H

#include "limits.h"
#include "err_rptr.h"
#include "switch.h"

class Range
    {
    public:
        //-------------
        // constructors
        //-------------

        Range(int rmin, int rmax);
        Range(int rmax);
        Range(const Range & r);

        //--------------------
        // assignment operator
        //--------------------

        Range & operator = (const Range & r);

        #ifndef RANGE_CHK_OFF
        //--------------------------
        // set error reporter object
        //--------------------------

        static void SetErrOut(const ErrReporter & er);
        #endif

        //-----------
        // add ranges
        //-----------

        friend Range operator + (const Range & r1, const Range & r2);

        //--------------------
        // comparison operator
        //--------------------

        int operator == (const Range & r) const;
        int operator != (const Range & r) const;

        //--------------------------------
        // information retrieval functions
        //--------------------------------

        int GetMin() const;
        int GetMax() const;
        unsigned int GetMagnitude() const;

        //-------------------------------
        // report error if 'n' is invalid
        //-------------------------------

        void Check(int n) const;

        //-------------------------------------
        // check for 'n' or range within bounds
        //-------------------------------------

        int Includes(int n) const;
        int Includes(const Range & r) const;

        int Excludes(int n) const;
        int Excludes(const Range & r) const;

        //-------------------------
        // range checking functions
        //-------------------------

        static void CheckOn();
        static void CheckOff();

        static Switch GetCheck();

    protected:
        //---------------------------
        // minimum and maximum values
        //---------------------------

        int Minimum;
        int Maximum;

        //--------------------------
        // number of values in range
        //--------------------------

        unsigned int Magnitude;

        #ifndef RANGE_CHK_OFF
        //--------------------
        // error output object
        //--------------------

        static ErrReporter * ErrOut;

        static void ReportError(const String & msg);

        //----------------------
        // range-checking switch
        //----------------------

        static Switch RangeCheck;
        #endif
    };

//-------------
// constructors
//-------------

inline Range::Range(const Range & r)
    {
    Minimum   = r.Minimum;
    Maximum   = r.Maximum;
    Magnitude = r.Magnitude;
    }

//--------------------
// assignment operator
//--------------------

inline Range & Range::operator = (const Range & r)
    {
    Minimum   = r.Minimum;
    Maximum   = r.Maximum;
    Magnitude = r.Magnitude;

    return *this;
    }

//--------------------
// comparison operator
//--------------------

inline int Range::operator == (const Range & r) const
    {
    return ((Minimum == r.Minimum) && (r.Maximum == r.Maximum));
    }

inline int Range::operator != (const Range & r) const
    {
    return ((Minimum != r.Minimum) || (r.Maximum != r.Maximum));
    }

//--------------------------------
// information retrieval functions
//--------------------------------

inline int Range::GetMin() const
    {
    return Minimum;
    }

inline int Range::GetMax() const
    {
    return Maximum;
    }

inline unsigned int Range::GetMagnitude() const
    {
    return Magnitude;
    }

//-------------------------------------
// check for 'n' or range within bounds
//-------------------------------------

inline int Range::Includes(int n) const
    {
    return ((n >= Minimum) && (n <= Maximum));
    }

inline int Range::Includes(const Range & r) const
    {
    return ((Minimum <= r.Minimum) && (Maximum >= r.Maximum));
    }

inline int Range::Excludes(int n) const
    {
    return ((n < Minimum) || (n > Maximum));
    }

inline int Range::Excludes(const Range & r) const
    {
    return ((Minimum > r.Minimum) || (Maximum < r.Maximum));
    }

//-------------------------
// range checking functions
//-------------------------

inline void Range::CheckOn()
    {
    #ifndef RANGE_CHK_OFF
        RangeCheck = ON;
    #endif
    }

inline void Range::CheckOff()
    {
    #ifndef RANGE_CHK_OFF
        RangeCheck = OFF;
    #endif
    }

inline Switch Range::GetCheck()
    {
    #ifndef RANGE_CHK_OFF
        return RangeCheck;
    #else
        return OFF;
    #endif
    }

#endif
