//=============================================================
//  MATHEMATICAL LIBRARY
//      index.cxx
//
//      Defines a data type used for indexing arrays
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "index.h"

//-------------
// constructors
//-------------

Index::Index(const Range & r, int i)
    : Range(r)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if ((i < Minimum) || (i > Maximum))
                ReportError("assignment out of range");
            }
    #endif

    Value = i;
    }

//------------
// conversions
//------------

Index::operator unsigned int () const
    {
    unsigned long result;

    if (Minimum < 0)
        {
        result = (unsigned int)(-Minimum);

        if (Value < 0)
            result -= (unsigned int)(-Value);
        else
            result += (unsigned int)Value;
        }
    else
        result = (unsigned long)Value - (unsigned long)Minimum;

    return (unsigned int)result;
    }

//---------------------
// assignment operators
//---------------------

Index & Index::operator = (int i)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if ((i < Minimum) || (i > Maximum))
                ReportError("assignment out of range");
            }
    #endif

    Value = i;

    return *this;
    }

Index & Index::operator = (const Index & i)
    {
    this->Range::operator = (i);

    Value = i.Value;

    return *this;
    }

//---------------
// math operators
//---------------

Index Index::operator + (int i)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (i < 0)
                {
                if ((Value - Minimum) < -i)
                    ReportError("underflow in addition");
                }
            else
                {
                if ((Maximum - Value) < i)
                    ReportError("overflow in addition");
                }
            }
    #endif

    Index result(*this);

    result.Value += i;

    return result;
    }

Index Index::operator - (int i)
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (i > 0)
                {
                if ((Value - Minimum) < i)
                    ReportError("underflow in subtraction");
                }
            else
                {
                if ((Maximum - Value) < -i)
                    ReportError("overflow in subtraction");
                }
            }
    #endif

    Index result(*this);

    result.Value -= i;

    return result;
    }

//------------------------
// increment and decrement
//------------------------

Index & Index::operator ++ ()
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (Value == Maximum)
                ReportError("overflow on increment");
            }
    #endif

    ++Value;

    return *this;
    }

Index & Index::operator -- ()
    {
    #ifndef RANGE_CHK_OFF
        if (RangeCheck == ON)
            {
            if (Value == Minimum)
                ReportError("underflow on decrement");
            }
    #endif

    --Value;

    return *this;
    }
