//=============================================================
//  MATHEMATICAL LIBRARY
//      iarray.cxx
//
//      An array of integers
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "iarray.h"
#include "string.h"
#include "stdlib.h"

//----------------------------------------
// default value assigned to array members
//----------------------------------------

int IntArray::InitValue = 0;

//-------------
// constructors
//-------------

IntArray::IntArray(const int * a, int len)
    : SortableArray(Range(0,len - 1),sizeof(int))
    {
    memcpy(Buffer,a,BufferSize);
    }

//---------------------
// conversion operators
//---------------------

IntArray::operator int * ()
    {
    int * result;

    result = new int[BufferSize];

    if (result == NULL)
        ReportError("cannot allocate memory for int []");

    memcpy(result,Buffer,BufferSize);

    return result;
    }

//----------------
// unary operators
//----------------

IntArray IntArray::operator - ()
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr = -(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator ~ ()
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr = ~(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator ! ()
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr = !(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//----------------
// basic operators
//----------------

IntArray IntArray::operator + (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: +");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest += *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator + (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr += n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator - (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: -");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest -= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator - (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr -= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator * (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: *");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest *= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator * (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr *= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator / (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: /");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest /= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator / (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr /= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator % (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: %");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest %= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator % (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr %= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//----------------
// shift operators
//----------------

IntArray IntArray::operator << (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: <<");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest <<= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator << (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr <<= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator >> (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: >>");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest >>= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator >> (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr >>= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//--------------------
// bit-level operators
//--------------------

IntArray IntArray::operator & (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: &");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest &= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator & (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr &= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator | (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: |");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest |= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator | (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr |= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

IntArray IntArray::operator ^ (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: ^");

    IntArray result(*this);

    IntArrayPtr dest = result.MakePtr();

    IntArrayConstPtr src = ia.MakeConstPtr();

    for (;;)
        {
        *dest ^= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

IntArray IntArray::operator ^ (int n)
    {
    IntArray result(*this);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr ^= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//--------------------
// shorthand operators
//--------------------

IntArray & IntArray::operator += (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: +=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest += *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator += (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest += n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator -= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: -=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest -= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator -= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest -= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator *= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: *=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest *= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator *= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest *= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator /= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: /=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest /= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator /= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest /= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator %= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: %=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest %= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator %= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest %= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

//--------------------------
// shorthand shift operators
//--------------------------

IntArray & IntArray::operator <<= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: <<=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest <<= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator <<= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest <<= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator >>= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: >>=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest >>= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator >>= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest >>= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

//------------------------------
// shorthand bit-level operators
//------------------------------

IntArray & IntArray::operator &= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: &=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest &= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator &= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest &= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator |= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: |=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest |= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator |= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest |= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

IntArray & IntArray::operator ^= (const IntArray & ia)
    {
    if (IndexRange != ia.IndexRange)
        ReportError("incompatible arrays: ^=");

    IntArrayPtr      dest = MakePtr();
    IntArrayConstPtr src  = ia.MakeConstPtr();

    for (;;)
        {
        *dest ^= *src;

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return *this;
    }

IntArray & IntArray::operator ^= (int n)
    {
    IntArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest ^= n;

        if (dest.IsLast())
            break;

        ++dest;
        }

    return *this;
    }

//---------------------
// comparison functions
//---------------------

int IntArray::Equals(const IntArray & ia) const
    {
    int result = 1;

    if (IndexRange == ia.IndexRange)
        {
        IntArrayConstPtr left  = MakeConstPtr();
        IntArrayConstPtr right = ia.MakeConstPtr();

        for (;;)
            {
            if (*left != *right)
                {
                result = 0;
                break;
                }

            if (left.IsLast())
                break;

            ++left;
            ++right;
            }
        }
    else
        result = 0;

    return result;
    }

IntArray operator < (const IntArray & ia1,
                     const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: <");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left < *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

IntArray operator <= (const IntArray & ia1,
                     const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: <=");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left <= *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

IntArray operator == (const IntArray & ia1,
                      const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: ==");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left == *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

IntArray operator != (const IntArray & ia1,
                      const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: !=");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left != *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

IntArray operator >= (const IntArray & ia1,
                      const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: >=");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left >= *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

IntArray operator > (const IntArray & ia1,
                     const IntArray & ia2)
    {
    if (ia1.IndexRange != ia2.IndexRange)
        IntArray::FriendErrExit("incompatible arrays: >");

    IntArray result(ia1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    IntArrayConstPtr left  = ia1.MakeConstPtr();
    IntArrayConstPtr right = ia2.MakeConstPtr();

    for (;;)
        {
        *dest = *left > *right;

        if (dest.IsLast())
            break;

        ++dest;
        ++left;
        ++right;
        }

    return result;
    }

//---------------
// fill functions
//---------------

void IntArray::Fill(int n)
    {
    IntArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }
    }

void IntArray::FillArithmetic(int first, int incr)
    {
    int value;

    IntArrayPtr ptr = MakePtr();

    value = first;

    *ptr = value;

    if (!ptr.IsLast())
        {
        ++ptr;

        for (;;)
            {
            value += incr;

            *ptr = value;

            if (ptr.IsLast())
                break;

            ++ptr;
            }
        }
    }

void IntArray::FillGeometric(int first,  int mult)
    {
    int value;

    IntArrayPtr ptr = MakePtr();

    value = first;

    *ptr = value;

    if (!ptr.IsLast())
        {
        ++ptr;

        for (;;)
            {
            value *= mult;

            *ptr = value;

            if (ptr.IsLast())
                break;

            ++ptr;
            }
        }
    }

void IntArray::FillRecursive(int first, IA_FillRecFunc func)
    {
    int value;

    IntArrayPtr ptr = MakePtr();

    value = first;

    *ptr = value;

    if (!ptr.IsLast())
        {
        ++ptr;

        for (;;)
            {
            value = func(value);

            *ptr = value;

            if (ptr.IsLast())
                break;

            ++ptr;
            }
        }
    }

void IntArray::FillRandom(RandGen & rg)
    {
    IntArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = (int)rg(INT_MAX);

        if (ptr.IsLast())
            break;

        ++ptr;
        }
    }

void IntArray::FillRandomBounded(int low, int high,
                                 RandGen & rg)
    {
    if (high <= low)
        ReportError("high bound <= low bound");

    int x = high - low + 1;

    IntArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = (int)(rg(x)) + low;

        if (ptr.IsLast())
            break;

        ++ptr;
        }
    }

void IntArray::FillBy(IA_FillByFunc func)
    {
    Index i(IndexRange);

    for (;;)
        {
        (*this)[i] = func(i);

        if (i.IsMax())
            break;

        ++i;
        }
    }

//-------------------------
// absolute value functions
//-------------------------

IntArray & IntArray::abs()
    {
    IntArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::abs(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

IntArray abs(const IntArray & ia)
    {
    IntArray result(ia);

    IntArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr = ::abs(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//------------------------------------------
// functions required by Sortable base class
//------------------------------------------

int IntArray::IsBefore(const Index & i1, const Index & i2)
    {
    return ((*this)[i1] < (*this)[i2]);
    }

void IntArray::Exchange(const Index & i1, const Index & i2)
    {
    int temp = (*this)[i1];

    (*this)[i1] = (*this)[i2];
    (*this)[i2] = temp;
    }

//-----------------------
// set new array elements
//-----------------------

void IntArray::Set(int * i)
    {
    *i = 0;
    }
