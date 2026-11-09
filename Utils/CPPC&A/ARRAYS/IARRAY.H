//=============================================================
//  MATHEMATICAL LIBRARY
//      iarray.h
//
//      An array of integers
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef IARRAY_H
#define IARRAY_H

#include "srtarray.h"
#include "randgen.h"

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  IntArrayPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class IntArrayPtr : public ArrayPtr
    {
    friend class IntArray;

    public:

        //-----------------
        // copy constructor
        //-----------------

        IntArrayPtr(const IntArrayPtr & aptr);
        IntArrayPtr(const ArrayPtr & aptr);

        //---------------------
        // assignment operators
        //---------------------

        IntArrayPtr & operator = (const IntArrayPtr & aptr);
        IntArrayPtr & operator = (const Index & i);
        IntArrayPtr & operator = (int i);

        //------------------------
        // increment and decrement
        //------------------------

        IntArrayPtr & operator ++ ();
        IntArrayPtr & operator -- ();

        //------------------
        // get pointer value
        //------------------

        operator int * () const;

        //------------
        // dereference
        //------------

        int & operator * ();

    protected:

        //------------
        // constructor
        //------------

        IntArrayPtr(char * base, size_t esize, const Range & r);
    };

//------------
// constructor
//------------

inline IntArrayPtr::IntArrayPtr(char * base,
                                size_t esize,
                                const Range & r)
    : ArrayPtr(base,esize,r)
    {
    // empty
    }

//-----------------
// copy constructor
//-----------------

inline IntArrayPtr::IntArrayPtr(const IntArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

inline IntArrayPtr::IntArrayPtr(const ArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

//---------------------
// assignment operators
//---------------------

inline IntArrayPtr & IntArrayPtr::operator = (const IntArrayPtr & aptr)
    {
    this->ArrayPtr::operator = (aptr);

    return *this;
    }

inline IntArrayPtr & IntArrayPtr::operator = (const Index & i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

inline IntArrayPtr & IntArrayPtr::operator = (int i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

//------------------------
// increment and decrement
//------------------------

inline IntArrayPtr & IntArrayPtr::operator ++ ()
    {
    this->ArrayPtr::operator ++ ();

    return *this;
    }

inline IntArrayPtr & IntArrayPtr::operator -- ()
    {
    this->ArrayPtr::operator -- ();

    return *this;
    }

//------------------
// get pointer value
//------------------

inline IntArrayPtr::operator int * () const
    {
    return (int *)ElemPtr;
    }

//------------
// dereference
//------------

inline int & IntArrayPtr::operator * ()
    {
    return *((int *)ElemPtr);
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  IntArrayPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class IntArrayConstPtr : public ArrayPtr
    {
    friend class IntArray;

    public:

        //-----------------
        // copy constructor
        //-----------------

        IntArrayConstPtr(const IntArrayConstPtr & aptr);
        IntArrayConstPtr(const ArrayPtr & aptr);

        //---------------------
        // assignment operators
        //---------------------

        IntArrayConstPtr & operator = (const IntArrayConstPtr & aptr);
        IntArrayConstPtr & operator = (const Index & i);
        IntArrayConstPtr & operator = (int i);

        //------------------------
        // increment and decrement
        //------------------------

        IntArrayConstPtr & operator ++ ();
        IntArrayConstPtr & operator -- ();

        //------------------
        // get pointer value
        //------------------

        operator const int * () const;

        //------------
        // dereference
        //------------

        const int & operator * ();

    protected:
        IntArrayConstPtr(char * base, size_t esize, const Range & r);
    };

//------------
// constructor
//------------

inline IntArrayConstPtr::IntArrayConstPtr(char * base,
                                          size_t esize,
                                          const Range & r)
    : ArrayPtr(base,esize,r)
    {
    // empty
    }

//-----------------
// copy constructor
//-----------------

inline IntArrayConstPtr::IntArrayConstPtr(const IntArrayConstPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

inline IntArrayConstPtr::IntArrayConstPtr(const ArrayPtr & aptr)
    : ArrayPtr(aptr)
    {
    // empty
    }

//---------------------
// assignment operators
//---------------------

inline IntArrayConstPtr & IntArrayConstPtr::operator = (const IntArrayConstPtr & aptr)
    {
    this->ArrayPtr::operator = (aptr);

    return *this;
    }

inline IntArrayConstPtr & IntArrayConstPtr::operator = (const Index & i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

inline IntArrayConstPtr & IntArrayConstPtr::operator = (int i)
    {
    this->ArrayPtr::operator = (i);

    return *this;
    }

//------------------------
// increment and decrement
//------------------------

inline IntArrayConstPtr & IntArrayConstPtr::operator ++ ()
    {
    this->ArrayPtr::operator ++ ();

    return *this;
    }

inline IntArrayConstPtr & IntArrayConstPtr::operator -- ()
    {
    this->ArrayPtr::operator -- ();

    return *this;
    }

//------------------
// get pointer value
//------------------

inline IntArrayConstPtr::operator const int * () const
    {
    return (const int *)ElemPtr;
    }

//------------
// dereference
//------------

inline const int & IntArrayConstPtr::operator * ()
    {
    return *((const int *)ElemPtr);
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  IntArray class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class IntArray : public SortableArray
    {
    protected:

        //----------------------------------------
        // default value assigned to array members
        //----------------------------------------

        static int InitValue;

    public:

        //-------------
        // constructors
        //-------------

        IntArray(const Range & r);
        IntArray(const IntArray & ia);

        IntArray(const int * a, int len);

        // concatenate
        IntArray(const IntArray & a1,
                 const IntArray & a2);

        // subrange
        IntArray(const IntArray & a,
                 const Index & first,
                 const Index & last);

        //------------
        // conversions
        //------------

        operator int * ();

        //--------------------
        // assignment operator
        //--------------------

        IntArray & operator = (const IntArray & ia);

        //------------------------------
        // create an approprite ArrayPtr
        //------------------------------

        IntArrayPtr MakePtr();

        IntArrayConstPtr MakeConstPtr() const;

        //-------------------------
        // element access operators
        //-------------------------

        int & operator [] (const Index & i);
        int & operator [] (int i);

        //-------------------------------
        // functions for reading elements
        //-------------------------------

        const int & Read(const Index & i) const;
        const int & Read(int i) const;

        //----------------
        // unary operators
        //----------------

        IntArray operator + ();
        IntArray operator - ();

        IntArray operator ~ ();
        IntArray operator ! ();

        //----------------
        // basic operators
        //----------------

        IntArray operator + (const IntArray & ia);
        IntArray operator + (int n);

        IntArray operator - (const IntArray & ia);
        IntArray operator - (int n);

        IntArray operator * (const IntArray & ia);
        IntArray operator * (int n);

        IntArray operator / (const IntArray & ia);
        IntArray operator / (int n);

        IntArray operator % (const IntArray & ia);
        IntArray operator % (int n);

        //----------------
        // shift operators
        //----------------

        IntArray operator << (const IntArray & ia);
        IntArray operator << (int n);

        IntArray operator >> (const IntArray & ia);
        IntArray operator >> (int n);

        //--------------------
        // bit-level operators
        //--------------------

        IntArray operator & (const IntArray & ia);
        IntArray operator & (int n);

        IntArray operator | (const IntArray & ia);
        IntArray operator | (int n);

        IntArray operator ^ (const IntArray & ia);
        IntArray operator ^ (int n);

        //--------------------
        // shorthand operators
        //--------------------

        IntArray & operator += (const IntArray & ia);
        IntArray & operator += (int n);

        IntArray & operator -= (const IntArray & ia);
        IntArray & operator -= (int n);

        IntArray & operator *= (const IntArray & ia);
        IntArray & operator *= (int n);

        IntArray & operator /= (const IntArray & ia);
        IntArray & operator /= (int n);

        IntArray & operator %= (const IntArray & ia);
        IntArray & operator %= (int n);

        //--------------------------
        // shorthand shift operators
        //--------------------------

        IntArray & operator <<= (const IntArray & ia);
        IntArray & operator <<= (int n);

        IntArray & operator >>= (const IntArray & ia);
        IntArray & operator >>= (int n);

        //------------------------------
        // shorthand bit-level operators
        //------------------------------

        IntArray & operator &= (const IntArray & ia);
        IntArray & operator &= (int n);

        IntArray & operator |= (const IntArray & ia);
        IntArray & operator |= (int n);

        IntArray & operator ^= (const IntArray & ia);
        IntArray & operator ^= (int n);

        //---------------------
        // comparison functions
        //---------------------

        // compare complete array contents for equality

        int Equals(const IntArray & ia) const;

        // compare array elements

        friend IntArray operator <  (const IntArray &ia1,
                                     const IntArray &ia2);

        friend IntArray operator <= (const IntArray &ia1,
                                     const IntArray &ia2);

        friend IntArray operator == (const IntArray &ia1,
                                     const IntArray &ia2);

        friend IntArray operator != (const IntArray &ia1,
                                     const IntArray &ia2);

        friend IntArray operator >= (const IntArray &ia1,
                                     const IntArray &ia2);

        friend IntArray operator >  (const IntArray &ia1,
                                     const IntArray &ia2);

        //---------------
        // fill functions
        //---------------

        typedef int (* IA_FillRecFunc)(int);
        typedef int (* IA_FillByFunc)(const Index & i);

        static void SetInit(int i);

        void Fill(int i = InitValue);

        void FillArithmetic(int first, int incr);
        void FillGeometric(int first,  int mult);
        void FillRecursive(int first,  IA_FillRecFunc func);

        void FillRandom(RandGen & rg);
        void FillRandomBounded(int low, int high, RandGen & rg);

        void FillBy(IA_FillByFunc func);

        //------------------------
        // absolute value function
        //------------------------

        IntArray & abs();

        friend IntArray abs(const IntArray & ia);

        //------------------------------------------
        // functions required by Sortable base class
        //------------------------------------------

        virtual int  IsBefore(const Index & i1, const Index & i2);
        virtual void Exchange(const Index & i1, const Index & i2);

    private:

        //-------------------------------------
        // sets the initial value of an element
        //-------------------------------------

        static void Set(int * i);

        //---------------------------------------
        // err exit function for friend functions
        //---------------------------------------

        static void FriendErrExit(const char * msg);
    };

//-------------
// constructors
//-------------

inline IntArray::IntArray(const Range & r)
    : SortableArray(r,sizeof(int),(ElemCreate)IntArray::Set)
    {
    // does nothing
    }

inline IntArray::IntArray(const IntArray & ia)
    : SortableArray(ia)
    {
    // does nothing
    }

inline IntArray::IntArray(const IntArray & a1,
                          const IntArray & a2)
    : SortableArray(a1,a2)
    {
    // does nothing else
    }

inline IntArray::IntArray(const IntArray & a,
                          const Index & first,
                          const Index & last)
    : SortableArray(a,first,last)
    {
    // does nothing else
    }

//--------------------
// assignment operator
//--------------------

inline IntArray & IntArray::operator = (const IntArray & ia)
    {
    this->SortableArray::operator = (ia);

    return *this;
    }

//------------------------------
// create an approprite ArrayPtr
//------------------------------

inline IntArrayPtr IntArray::MakePtr()
    {
    return IntArrayPtr(Buffer,ElementSize,IndexRange);
    }

inline IntArrayConstPtr IntArray::MakeConstPtr() const
    {
    return IntArrayConstPtr(Buffer,ElementSize,IndexRange);
    }

//-------------------------
// element access operators
//-------------------------

inline int & IntArray::operator [] (const Index & i)
    {
    return *((int *)(GetElement(i)));
    }

inline int & IntArray::operator [] (int i)
    {
    return *((int *)(GetElement(i)));
    }

//-------------------------------
// functions for reading elements
//-------------------------------

inline const int & IntArray::Read(const Index & i) const
    {
    return *((const int *)(ReadElement(i)));
    }

inline const int & IntArray::Read(int i) const
    {
    return *((const int *)(ReadElement(i)));
    }

//----------------
// unary operators
//----------------

inline IntArray IntArray::operator + ()
    {
    return *this;
    }

//---------------
// fill functions
//---------------

inline void IntArray::SetInit(int d)
    {
    InitValue = d;
    }

//---------------------------------------
// err exit function for friend functions
//---------------------------------------

inline void IntArray::FriendErrExit(const char * msg)
    {
    ReportError(msg);
    }

#endif
