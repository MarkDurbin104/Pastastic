//=============================================================
//  MATHEMATICAL LIBRARY                            
//      index.h
//
//      Defines a data type used for indexing arrays
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef INDEX_H
#define INDEX_H

#include "range.h"

class Index : public Range
    {
    public:

        //-------------
        // constructors
        //-------------

        Index(int imin, int imax);
        Index(const Range & r);
        Index(const Range & r, int i);
        Index(const Index & i);

        //------------
        // conversions
        //------------

        operator int() const;          // returns exact value
        operator unsigned int() const; // returns zero-based value

        //-------------
        // value checks
        //-------------

        int IsMin() const;
        int IsMax() const;

        //---------------------
        // explicit assignments
        //---------------------

        void SetMin();
        void SetMax();

        //---------------------
        // assignment operators
        //---------------------

        Index & operator = (int n);
        Index & operator = (const Index & i);

        //---------------
        // math operators
        //---------------

        Index operator + (const Index & i);
        Index operator - (const Index & i);

        Index operator + (int i);
        Index operator - (int i);

        //--------------------
        // shorthand operators
        //--------------------

        Index & operator += (const Index & i);
        Index & operator -= (const Index & i);

        Index & operator += (int n);
        Index & operator -= (int n);

        //------------------------
        // increment and decrement
        //------------------------

        Index & operator ++ ();
        Index & operator -- ();

        //---------------------
        // comparison operators
        //---------------------

        int operator >  (const Index & i) const;
        int operator >= (const Index & i) const;
        int operator == (const Index & i) const;
        int operator != (const Index & i) const;
        int operator <= (const Index & i) const;
        int operator <  (const Index & i) const;

        int operator >  (int i) const;
        int operator >= (int i) const;
        int operator == (int i) const;
        int operator != (int i) const;
        int operator <= (int i) const;
        int operator <  (int i) const;

    protected:

        //--------------------
        // current index value
        //--------------------

        int Value;
    };

//-------------
// constructors
//-------------

inline Index::Index(int imin, int imax)
    : Range(imin,imax)
    {
    Value = Minimum;
    }

inline Index::Index(const Range & r)
    : Range(r)
    {
    Value = Minimum;
    }

inline Index::Index(const Index & i)
    : Range(i)
    {
    Value = i.Value;
    }

//------------
// conversions
//------------

inline Index::operator int () const
    {
    return Value;
    }

//-------------
// value checks
//-------------

inline int Index::IsMin() const
    {
    return (Value == Minimum);
    }

inline int Index::IsMax() const
    {
    return (Value == Maximum);
    }

//---------------------
// explicit assignments
//---------------------

inline void Index::SetMin()
    {
    Value = Minimum;
    }

inline void Index::SetMax()
    {
    Value = Maximum;
    }

//---------------
// math operators
//---------------

inline Index Index::operator + (const Index & i)
    {
    return *this + i.Value;
    }

inline Index Index::operator - (const Index & i)
    {
    return *this - i.Value;
    }

//--------------------
// shorthand operators
//--------------------

inline Index & Index::operator += (const Index & i)
    {
    return *this += i.Value;
    }

inline Index & Index::operator -= (const Index & i)
    {
    return *this -= i.Value;
    }

inline Index & Index::operator += (int i)
    {
    return *this = *this + i;
    }

inline Index & Index::operator -= (int i)
    {
    return *this = *this - i;
    }

//---------------------
// comparison operators
//---------------------

inline int Index::operator > (const Index & i) const
    {
    return (Value > i.Value);
    }

inline int Index::operator >= (const Index & i) const
    {
    return (Value >= i.Value);
    }

inline int Index::operator == (const Index & i) const
    {
    return (Value == i.Value);
    }

inline int Index::operator != (const Index & i) const
    {
    return (Value != i.Value);
    }

inline int Index::operator <= (const Index & i) const
    {
    return (Value <= i.Value);
    }

inline int Index::operator < (const Index & i) const
    {
    return (Value < i.Value);
    }

inline int Index::operator > (int i) const
    {
    return (Value > i);
    }

inline int Index::operator >= (int i) const
    {
    return (Value >= i);
    }

inline int Index::operator == (int i) const
    {
    return (Value == i);
    }

inline int Index::operator != (int i) const
    {
    return (Value != i);
    }

inline int Index::operator <= (int i) const
    {
    return (Value <= i);
    }

inline int Index::operator < (int i) const
    {
    return (Value < i);
    }

#endif
