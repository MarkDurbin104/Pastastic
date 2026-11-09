//=============================================================
//  MATHEMATICAL LIBRARY
//      darray.cxx
//
//      An array of doubles
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "darray.h"
#include "iarray.h"
#include "string.h"
#include "stdlib.h"
#include "limits.h"
#include "math.h"

//----------------------------------------
// default value assigned to array members
//----------------------------------------

double DblArray::InitValue = 0.0;

//-------------
// constructors
//-------------

DblArray::DblArray(const IntArray & ia)
    : SortableArray(ia.GetRange(),
                    sizeof(double),
                    (ElemCreate)NULL)
    {
    Index i(IndexRange);

    for (;;)
        {
        (*this)[i] = (double)ia.Read(i);

        if (i.IsMax())
            break;

        ++i;
        }
    }

DblArray::DblArray(const double * a, int len)
    : SortableArray(Range(0,len - 1),
                    sizeof(double),
                    (ElemCreate)NULL)
    {
    memcpy(Buffer,a,BufferSize);
    }

//---------------------
// conversion operators
//---------------------

DblArray::operator double * ()
    {
    double * result;

    result = new double[BufferSize];

    if (result == NULL)
        ReportError("unable to allocate memory for double []");

    memcpy(result,Buffer,BufferSize);

    return result;
    }

//----------------
// unary operators
//----------------

DblArray DblArray::operator - ()
    {
    DblArray result(*this);

    DblArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr = -(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//----------------
// basic operators
//----------------

DblArray DblArray::operator + (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: +");

    DblArray result(*this);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray DblArray::operator + (double n)
    {
    DblArray result(*this);

    DblArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr += n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

DblArray DblArray::operator - (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: -");

    DblArray result(*this);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray DblArray::operator - (double n)
    {
    DblArray result(*this);

    DblArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr -= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

DblArray DblArray::operator * (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: *");

    DblArray result(*this);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray DblArray::operator * (double n)
    {
    DblArray result(*this);

    DblArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr *= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

DblArray DblArray::operator / (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: /");

    DblArray result(*this);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray DblArray::operator / (double n)
    {
    DblArray result(*this);

    DblArrayPtr ptr = result.MakePtr();

    for (;;)
        {
        *ptr /= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

//--------------------------------
// short-hand assignment operators
//--------------------------------

DblArray & DblArray::operator += (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: +=");

    DblArrayPtr      dest = MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray & DblArray::operator += (double n)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr += n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray & DblArray::operator -= (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: -=");

    DblArrayPtr      dest = MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray & DblArray::operator -= (double n)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr -= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray & DblArray::operator *= (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: *=");

    DblArrayPtr      dest = MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray & DblArray::operator *= (double n)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr *= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray & DblArray::operator /= (const DblArray & da)
    {
    if (IndexRange != da.IndexRange)
        ReportError("incompatible arrays: /=");

    DblArrayPtr      dest = MakePtr();
    DblArrayConstPtr src  = da.MakeConstPtr();

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

DblArray & DblArray::operator /= (double n)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr /= n;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

//---------------------
// comparison operators
//---------------------

// compare complete array contents for equality

int DblArray::Equals(const DblArray & da) const
    {
    int result = 1;

    if (IndexRange == da.IndexRange)
        {
        DblArrayConstPtr ptr1 = MakeConstPtr();
        DblArrayConstPtr ptr2 = da.MakeConstPtr();

        for (;;)
            {
            if (*ptr1 != *ptr2)
                {
                result = 0;
                break;
                }

            if (ptr1.IsLast())
                break;

            ++ptr1;
            ++ptr2;
            }
        }
    else
        result = 0;

    return result;
    }

// compare array elements

IntArray operator < (const DblArray & da1,
                     const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: <");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

IntArray operator <= (const DblArray & da1,
                      const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: <=");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

IntArray operator == (const DblArray & da1,
                      const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: ==");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

IntArray operator != (const DblArray & da1,
                      const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: !=");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

IntArray operator >= (const DblArray & da1,
                      const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: >=");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

IntArray operator > (const DblArray & da1,
                     const DblArray & da2)
    {
    if (da1.IndexRange != da2.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: >");

    IntArray result(da1.IndexRange);

    IntArrayPtr      dest  = result.MakePtr();
    DblArrayConstPtr left  = da1.MakeConstPtr();
    DblArrayConstPtr right = da2.MakeConstPtr();

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

void DblArray::Fill(double d)
    {
    DblArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest = d;

        if (dest.IsLast())
            break;

        ++dest;
        }
    }

void DblArray::FillArithmetic(double first, double incr)
    {
    double value;

    DblArrayPtr dest = MakePtr();

    value = first;

    *dest = value;

    if (!dest.IsLast())
        {
        ++dest;

        for (;;)
            {
            value += incr;

            *dest = value;

            if (dest.IsLast())
                break;

            ++dest;
            }
        }
    }

void DblArray::FillGeometric(double first,  double mult)
    {
    double value;

    DblArrayPtr dest = MakePtr();

    value = first;

    *dest = value;

    if (!dest.IsLast())
        {
        ++dest;

        for (;;)
            {
            value *= mult;

            *dest = value;

            if (dest.IsLast())
                break;

            ++dest;
            }
        }
    }

void DblArray::FillRecursive(double first, DA_FillRecFunc func)
    {
    double value;

    DblArrayPtr dest = MakePtr();

    value = first;

    *dest = value;

    if (!dest.IsLast())
        {
        ++dest;

        for (;;)
            {
            value = func(value);

            *dest = value;

            if (dest.IsLast())
                break;

            ++dest;
            }
        }
    }

void DblArray::FillRandom(RandGen & rg)
    {
    DblArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest = double(rg(UINT_MAX)) / double(UINT_MAX);

        if (dest.IsLast())
            break;

        ++dest;
        }
    }

void DblArray::FillRandomBounded(double low, double high, RandGen & rg)
    {
    if (high <= low)
        ReportError("high bound <= low bound");

    double range = high - low;

    DblArrayPtr dest = MakePtr();

    for (;;)
        {
        *dest = double(rg(UINT_MAX)) / double(UINT_MAX) * range + low;

        if (dest.IsLast())
            break;

        ++dest;
        }
    }

void DblArray::FillBy(DA_FillByFunc func)
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

//------------------------------------------
// functions required by Sortable base class
//------------------------------------------

int DblArray::IsBefore(const Index & i1, const Index & i2)
    {
    return ((*this)[i1] < (*this)[i2]);
    }

void DblArray::Exchange(const Index & i1, const Index & i2)
    {
    double temp = (*this)[i1];

    (*this)[i1] = (*this)[i2];
    (*this)[i2] = temp;
    }

//-----------------------
// set new array elements
//-----------------------

void DblArray::Set(double * d)
    {
    *d = InitValue;
    }

//------------------------
// trigonometric functions
//------------------------

// cosine

DblArray & DblArray::cos()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::cos(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray cos(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::cos(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::cosh()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::cosh(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray cosh(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::cosh(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::acos()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::acos(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray acos(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::acos(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// sine

DblArray & DblArray::sin()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::sin(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray sin(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::sin(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::sinh()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::sinh(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray sinh(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::sinh(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::asin()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::asin(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray asin(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::asin(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// tangent

DblArray & DblArray::tan()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::tan(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray tan(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::tan(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::tanh()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::tanh(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray tanh(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::tanh(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::atan()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::atan(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray atan(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::atan(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::atan2(const DblArray & den)
    {
    if (IndexRange != den.IndexRange)
        ReportError("incompatible arrays: atan2(1)");

    DblArrayPtr      nptr = MakePtr();
    DblArrayConstPtr dptr = den.MakeConstPtr();

    for (;;)
        {
        *nptr = ::atan2(*nptr,*dptr);

        if (nptr.IsLast())
            break;

        ++nptr;
        ++dptr;
        }

    return *this;
    }

DblArray atan2(const DblArray & num,const DblArray & den)
    {
    if (num.IndexRange != den.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: atan2(2)");

    DblArray result(num.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr nptr = num.MakeConstPtr();
    DblArrayConstPtr dptr = den.MakeConstPtr();

    for (;;)
        {
        *dest = ::atan2(*nptr,*dptr);

        if (dest.IsLast())
            break;

        ++dest;
        ++nptr;
        ++dptr;
        }

    return result;
    }

//----------------------
// logarithmic functions
//----------------------

// natural logarithm

DblArray & DblArray::log()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::log(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray log(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::log(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// natural exponentiation

DblArray & DblArray::exp()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::exp(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray exp(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::exp(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// base-10 logarithm

DblArray & DblArray::log10()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::log10(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray log10(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::log10(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// exponentiation

DblArray & DblArray::pow(double p)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::pow(*ptr,p);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray pow(const DblArray & da, double p)
    {
    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::pow(*src,p);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::pow(const DblArray & p)
    {
    if (IndexRange != p.IndexRange)
        ReportError("incompatible arrays: pow(1)");

    DblArrayPtr      base = MakePtr();
    DblArrayConstPtr pwr  = p.MakeConstPtr();

    for (;;)
        {
        *base = ::pow(*base,*pwr);

        if (base.IsLast())
            break;

        ++base;
        ++pwr;
        }

    return *this;
    }

DblArray pow(const DblArray & da, const DblArray & p)
    {
    if (da.IndexRange != p.IndexRange)
        DblArray::FriendErrExit("incompatible arrays: pow(2)");

    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr base = da.MakeConstPtr();
    DblArrayConstPtr  pwr = p.MakeConstPtr();

    for (;;)
        {
        *dest = ::pow(*base,*pwr);

        if (dest.IsLast())
            break;

        ++dest;
        ++base;
        ++pwr;
        }

    return result;
    }

// square root

DblArray & DblArray::sqroot()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::sqrt(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray sqroot(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::sqrt(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

//---------------
// sign functions
//---------------

// absolute value

DblArray & DblArray::abs()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::fabs(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray abs(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::fabs(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

//---------------------
// power of 2 functions
//---------------------

// multiply by power of 2

DblArray & DblArray::ldexp(int p)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::ldexp(*ptr,p);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray ldexp(const DblArray & da, int p)
    {
    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::ldexp(*src,p);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::ldexp(const IntArray & p)
    {
    if (IndexRange != p.GetRange())
        ReportError("incompatible arrays: ldexp(1)");

    DblArrayPtr      base = MakePtr();
    IntArrayConstPtr pptr = p.MakeConstPtr();

    for (;;)
        {
        *base = ::ldexp(*base,*pptr);

        if (base.IsLast())
            break;

        ++base;
        ++pptr;
        }

    return *this;
    }

DblArray ldexp(const DblArray & da,const IntArray & p)
    {
    if (da.IndexRange != p.GetRange())
        DblArray::FriendErrExit("incompatible arrays: ldexp(2)");

    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr base = da.MakeConstPtr();
    IntArrayConstPtr pptr = p.MakeConstPtr();

    for (;;)
        {
        *dest = ::ldexp(*base,*pptr);

        if (dest.IsLast())
            break;

        ++dest;
        ++base;
        ++pptr;
        }

    return result;
    }

DblArray & DblArray::frexp(IntArray & pow2)
    {
    if (IndexRange != pow2.GetRange())
        DblArray::FriendErrExit("incompatible arrays: frexp(1)");

    DblArrayPtr base = MakePtr();

    Index i = pow2.MakeIndex();

    for (;;)
        {
        *base = ::frexp(*base,&(pow2[i]));

        if (base.IsLast())
            break;

        ++base;
        ++i;
        }

    return *this;
    }

DblArray frexp(const DblArray & da, IntArray & pow2)
    {
    if (da.IndexRange != pow2.GetRange())
        DblArray::FriendErrExit("incompatible arrays: frexp(2)");

    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr base = da.MakeConstPtr();

    Index i = pow2.MakeIndex();

    for (;;)
        {
        *dest = ::frexp(*base,&(pow2[i]));

        if (dest.IsLast())
            break;

        ++dest;
        ++base;
        ++i;
        }

    return result;
    }

//-------------------
// rounding functions
//-------------------

// round toward negative infinity

DblArray & DblArray::floor()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::floor(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray floor(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::floor(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

// round toward positive infinity

DblArray & DblArray::ceil()
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::ceil(*ptr);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray ceil(const DblArray & da)
    {
    DblArray result(da);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::ceil(*src);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

//------------------------
// miscellaneous functions
//------------------------

// compute remainder

DblArray & DblArray::fmod(double div)
    {
    DblArrayPtr ptr = MakePtr();

    for (;;)
        {
        *ptr = ::fmod(*ptr,div);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return *this;
    }

DblArray fmod(const DblArray & da, double div)
    {
    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();

    for (;;)
        {
        *dest = ::fmod(*src,div);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        }

    return result;
    }

DblArray & DblArray::fmod(const DblArray & div)
    {
    if (IndexRange != div.GetRange())
        DblArray::FriendErrExit("incompatible arrays: fmod(1)");

    DblArrayPtr      dest = MakePtr();
    DblArrayConstPtr dptr = div.MakeConstPtr();

    for (;;)
        {
        *dest = ::fmod(*dest,*dptr);

        if (dest.IsLast())
            break;

        ++dest;
        ++dptr;
        }

    return *this;
    }

DblArray fmod(const DblArray & da,
              const DblArray & div)
    {
    if (da.IndexRange != div.GetRange())
        DblArray::FriendErrExit("incompatible arrays: fmod(2)");

    DblArray result(da.IndexRange);

    DblArrayPtr      dest = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();
    DblArrayConstPtr dptr = div.MakeConstPtr();

    for (;;)
        {
        *dest = ::fmod(*src,*dptr);

        if (dest.IsLast())
            break;

        ++dest;
        ++src;
        ++dptr;
        }

    return result;
    }

// get fractional and integer parts

DblArray & DblArray::modf(DblArray & ipart)
    {
    if (IndexRange != ipart.GetRange())
        DblArray::FriendErrExit("incompatible arrays: modf(1)");

    DblArrayPtr fptr = MakePtr();
    DblArrayPtr iptr = ipart.MakePtr();

    for (;;)
        {
        *fptr = ::modf(*fptr,&(*iptr));

        if (fptr.IsLast())
            break;

        ++fptr;
        ++iptr;
        }

    return *this;
    }

DblArray modf(const DblArray & da,DblArray & ipart)
    {
    if (da.IndexRange != ipart.GetRange())
        DblArray::FriendErrExit("incompatible arrays: modf(2)");

    DblArray result(da.IndexRange);

    DblArrayPtr      fptr = result.MakePtr();
    DblArrayConstPtr  src = da.MakeConstPtr();
    DblArrayPtr      iptr = ipart.MakePtr();

    for (;;)
        {
        *fptr = ::modf(*src,&(*iptr));

        if (fptr.IsLast())
            break;

        ++fptr;
        ++src;
        ++iptr;
        }

    return result;
    }
