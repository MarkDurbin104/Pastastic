//=============================================================
//  MATHEMATICAL LIBRARY
//      darray.h
//
//      An array of doubles
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef DARRAY_H
#define DARRAY_H

#include "srtarray.h"
#include "randgen.h"

class IntArray;

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  DblArrayPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class DblArrayPtr : public ArrayPtr
    {
    friend class DblArray;

    public:

        //-----------------
        // copy constructor
        //-----------------

        DblArrayPtr(const DblArrayPtr & aptr);
        DblArrayPtr(const ArrayPtr & aptr);

        //---------------------
        // assignment operators
        //---------------------

        DblArrayPtr & operator = (const DblArrayPtr & aptr);
        DblArrayPtr & operator = (const Index & i);
        DblArrayPtr & operator = (int i);

        //------------------------
        // increment and decrement
        //------------------------

        DblArrayPtr & operator ++ ();
        DblArrayPtr & operator -- ();

        //------------------
        // get pointer value
        //------------------

        operator double * () const;

        //------------
        // dereference
        //------------

        double & operator * ();

    protected:

        //------------
        // constructor
        //------------

        DblArrayPtr(char * base, size_t esize, const Range & r);
    };

//------------
// constructor
//------------

inline DblArrayPtr::DblArrayPtr(char * base,
                                size_t esize,
                                const Range & r)
    : ArrayPtr(base,esize,r)
    {
    // empty
    }

//-----------------
// copy constructor
//-----------------

inline DblArrayPtr::DblArrayPtr(const DblArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

inline DblArrayPtr::DblArrayPtr(const ArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

//---------------------
// assignment operators
//---------------------

inline DblArrayPtr & DblArrayPtr::operator = (const DblArrayPtr & aptr)
    {
    this->ArrayPtr::operator = (aptr);

    return *this;
    }

inline DblArrayPtr & DblArrayPtr::operator = (const Index & i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

inline DblArrayPtr & DblArrayPtr::operator = (int i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

//------------------------
// increment and decrement
//------------------------

inline DblArrayPtr & DblArrayPtr::operator ++ ()
    {
    this->ArrayPtr::operator ++ ();

    return *this;
    }

inline DblArrayPtr & DblArrayPtr::operator -- ()
    {
    this->ArrayPtr::operator -- ();

    return *this;
    }

//------------------
// get pointer value
//------------------

inline DblArrayPtr::operator double * () const
    {
    return (double *)ElemPtr;
    }

//------------
// dereference
//------------

inline double & DblArrayPtr::operator * ()
    {
    return *((double *)ElemPtr);
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  DblArrayConstPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class DblArrayConstPtr : public ArrayPtr
    {
    friend class DblArray;

    public:

        //-----------------
        // copy constructor
        //-----------------

        DblArrayConstPtr(const DblArrayConstPtr & aptr);
        DblArrayConstPtr(const ArrayPtr & aptr);

        //---------------------
        // assignment operators
        //---------------------

        DblArrayConstPtr & operator = (const DblArrayConstPtr & aptr);
        DblArrayConstPtr & operator = (const Index & i);
        DblArrayConstPtr & operator = (int i);

        //------------------------
        // increment and decrement
        //------------------------

        DblArrayConstPtr & operator ++ ();
        DblArrayConstPtr & operator -- ();

        //------------------
        // get pointer value
        //------------------

        operator const double * () const;

        //------------
        // dereference
        //------------

        const double & operator * ();

    protected:
        DblArrayConstPtr(char * base, size_t esize, const Range & r);
    };

//------------
// constructor
//------------

inline DblArrayConstPtr::DblArrayConstPtr(char * base,
                                          size_t esize,
                                          const Range & r)
    : ArrayPtr(base,esize,r)
    {
    // empty
    }

//-----------------
// copy constructor
//-----------------

inline DblArrayConstPtr::DblArrayConstPtr(const DblArrayConstPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

inline DblArrayConstPtr::DblArrayConstPtr(const ArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

//---------------------
// assignment operators
//---------------------

inline DblArrayConstPtr & DblArrayConstPtr::operator = (const DblArrayConstPtr & aptr)
    {
    this->ArrayPtr::operator = (aptr);

    return *this;
    }

inline DblArrayConstPtr & DblArrayConstPtr::operator = (const Index & i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

inline DblArrayConstPtr & DblArrayConstPtr::operator = (int i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

//------------------------
// increment and decrement
//------------------------

inline DblArrayConstPtr & DblArrayConstPtr::operator ++ ()
    {
    this->ArrayPtr::operator ++ ();

    return *this;
    }

inline DblArrayConstPtr & DblArrayConstPtr::operator -- ()
    {
    this->ArrayPtr::operator -- ();

    return *this;
    }

//------------------
// get pointer value
//------------------

inline DblArrayConstPtr::operator const double * () const
    {
    return (const double *)ElemPtr;
    }

//------------
// dereference
//------------

inline const double & DblArrayConstPtr::operator * ()
    {
    return *((const double *)ElemPtr);
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  DblArray class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class DblArray : public SortableArray
    {
    protected:

        //----------------------------------------
        // default value assigned to array members
        //----------------------------------------

        static double InitValue;

    public:

        //-------------
        // constructors
        //-------------

        DblArray(const Range & r);
        DblArray(const DblArray & da);
        DblArray(const IntArray & ia);
        DblArray(const double * a, int len);

        // concatenate
        DblArray(const DblArray & a1,
                 const DblArray & a2);

        // subrange
        DblArray(const DblArray & a,
                 const Index & first,
                 const Index & last);

        //---------------------
        // conversion operators
        //---------------------

        operator double * ();

        //--------------------
        // assignment operator
        //--------------------

        DblArray & operator = (const DblArray & da);

        //------------------------------
        // create an approprite ArrayPtr
        //------------------------------

        DblArrayPtr MakePtr();

        DblArrayConstPtr MakeConstPtr() const;

        //-------------------------
        // reference array elements
        //-------------------------

        double & operator [] (const Index & i);
        double & operator [] (int i);

        //--------------------
        // read array elements
        //--------------------

        const double & Read(const Index & i) const;
        const double & Read(int i) const;

        //----------------
        // unary operators
        //----------------

        DblArray operator + ();
        DblArray operator - ();

        //----------------
        // basic operators
        //----------------

        DblArray operator + (const DblArray & da);
        DblArray operator + (double n);

        DblArray operator - (const DblArray & da);
        DblArray operator - (double n);

        DblArray operator * (const DblArray & da);
        DblArray operator * (double n);

        DblArray operator / (const DblArray & da);
        DblArray operator / (double n);

        //--------------------------------
        // short-hand assignment operators
        //--------------------------------

        DblArray & operator += (const DblArray & da);
        DblArray & operator += (double n);

        DblArray & operator -= (const DblArray & da);
        DblArray & operator -= (double n);

        DblArray & operator *= (const DblArray & da);
        DblArray & operator *= (double n);

        DblArray & operator /= (const DblArray & da);
        DblArray & operator /= (double n);

        //---------------------
        // comparison operators
        //---------------------

        // compare complete array contents for equality

        int Equals(const DblArray & da) const;

        // compare array elements

        friend IntArray operator <  (const DblArray &da1,
                                     const DblArray &da2);

        friend IntArray operator <= (const DblArray &da1,
                                     const DblArray &da2);

        friend IntArray operator == (const DblArray &da1,
                                     const DblArray &da2);

        friend IntArray operator != (const DblArray &da1,
                                     const DblArray &da2);

        friend IntArray operator >= (const DblArray &da1,
                                     const DblArray &da2);

        friend IntArray operator >  (const DblArray &da1,
                                     const DblArray &da2);

        //-------------------------
        // fill functions and types
        //-------------------------

        typedef double (* DA_FillRecFunc)(double);
        typedef double (* DA_FillByFunc)(const Index & i);

        static void SetInit(double d);

        void Fill(double d = InitValue);

        void FillArithmetic(double first, double incr);
        void FillGeometric(double first,  double mult);
        void FillRecursive(double first,  DA_FillRecFunc func);

        void FillRandom(RandGen & rg);
        void FillRandomBounded(double low, double high, RandGen & rg);

        void FillBy(DA_FillByFunc func);

        //------------------------
        // trigonometric functions
        //------------------------

        // cosine

        DblArray & cos();
        friend DblArray cos(const DblArray & da);

        DblArray & cosh();
        friend DblArray cosh(const DblArray & da);

        DblArray & acos();
        friend DblArray acos(const DblArray & da);

        // sine

        DblArray & sin();
        friend DblArray sin(const DblArray & da);

        DblArray & sinh();
        friend DblArray sinh(const DblArray & da);

        DblArray & asin();
        friend DblArray asin(const DblArray & da);

        // tangent

        DblArray & tan();
        friend DblArray tan(const DblArray & da);

        DblArray & tanh();
        friend DblArray tanh(const DblArray & da);

        DblArray & atan();
        friend DblArray atan(const DblArray & da);

        DblArray & atan2(const DblArray & den);

        friend DblArray atan2(const DblArray & num,
                                 const DblArray & den);

        //----------------------
        // logarithmic functions
        //----------------------

        // natural logarithm

        DblArray & log();
        friend DblArray log(const DblArray & da);

        // natural exponentiation

        DblArray & exp();
        friend DblArray exp(const DblArray & da);

        // base-10 logarithm

        DblArray & log10();
        friend DblArray log10(const DblArray & da);

        // exponentiation

        friend DblArray pow(const DblArray & da,
                               double p);

        DblArray & pow(double p);

        DblArray & pow(const DblArray & p);

        friend DblArray pow(const DblArray & da,
                               const DblArray & p);

        // square root

        DblArray & sqroot();
        friend DblArray sqroot(const DblArray & da);

        //---------------
        // sign functions
        //---------------

        // absolute value

        DblArray & abs();
        friend DblArray abs(const DblArray & da);

        //---------------------
        // power of 2 functions
        //---------------------

        // multiply by power of 2

        friend DblArray ldexp(const DblArray & da,
                                 int p);

        DblArray & ldexp(int p);

        DblArray & ldexp(const IntArray & p);

        friend DblArray ldexp(const DblArray & da,
                                 const IntArray & p);

        // get fraction and power of 2

        DblArray & frexp(IntArray & pow2);

        friend DblArray frexp(const DblArray & da,
                                 IntArray & pow2);

        //-------------------
        // rounding functions
        //-------------------

        // round toward negative infinity

        DblArray & floor();
        friend DblArray floor(const DblArray & da);

        // round toward positive infinity

        DblArray & ceil();
        friend DblArray ceil(const DblArray & da);

        //------------------------
        // miscellaneous functions
        //------------------------

        // compute remainder

        friend DblArray fmod(const DblArray & da,
                             double div);

        DblArray & fmod(double div);

        DblArray & fmod(const DblArray & div);

        friend DblArray fmod(const DblArray & da,
                             const DblArray & div);

        // get frantional and integer parts

        DblArray & modf(DblArray & ipart);

        friend DblArray modf(const DblArray & da,
                             DblArray & ipart);

        //------------------------------------------
        // functions required by Sortable base class
        //------------------------------------------

        virtual int  IsBefore(const Index & i1, const Index & i2);
        virtual void Exchange(const Index & i1, const Index & i2);

    protected:

        //-----------------------
        // set new array elements
        //-----------------------

        static void Set(double * d);

        //---------------------------------------
        // err exit function for friend functions
        //---------------------------------------

        static void FriendErrExit(const char * msg);
    };

//-------------
// constructors
//-------------

inline DblArray::DblArray(const Range & r)
    : SortableArray(r,sizeof(double),(ElemCreate)DblArray::Set)
    {
    // empty
    }

inline DblArray::DblArray(const DblArray & da)
    : SortableArray(da)
    {
    // does nothing else
    }

inline DblArray::DblArray(const DblArray & a1,
                                const DblArray & a2)
    : SortableArray(a1,a2)
    {
    // does nothing else
    }

inline DblArray::DblArray(const DblArray & a,
                                const Index & first,
                                const Index & last)
    : SortableArray(a,first,last)
    {
    // does nothing else
    }

//--------------------
// assignment operator
//--------------------

inline DblArray & DblArray::operator = (const DblArray & da)
    {
    this->Array::operator = (da);

    return *this;
    }

//------------------------------
// create an approprite ArrayPtr
//------------------------------

inline DblArrayPtr DblArray::MakePtr()
    {
    return DblArrayPtr(Buffer,ElementSize,IndexRange);
    }

inline DblArrayConstPtr DblArray::MakeConstPtr() const
    {
    return DblArrayConstPtr(Buffer,ElementSize,IndexRange);
    }

//-------------------------
// reference array elements
//-------------------------

inline double & DblArray::operator [] (const Index & i)
    {
    return *((double *)(GetElement(i)));
    }

inline double & DblArray::operator [] (int i)
    {
    return *((double *)(GetElement(i)));
    }

//--------------------
// read array elements
//--------------------

inline const double & DblArray::Read(const Index & i) const
    {
    return *((const double *)(ReadElement(i)));
    }

inline const double & DblArray::Read(int i) const
    {
    return *((const double *)(ReadElement(i)));
    }

//----------------
// unary operators
//----------------

inline DblArray DblArray::operator + ()
    {
    return *this;
    }

//---------------
// fill functions
//---------------

inline void DblArray::SetInit(double d)
    {
    InitValue = d;
    }

//---------------------------------------
// err exit function for friend functions
//---------------------------------------

inline void DblArray::FriendErrExit(const char * msg)
    {
    ReportError(msg);
    }

#endif
