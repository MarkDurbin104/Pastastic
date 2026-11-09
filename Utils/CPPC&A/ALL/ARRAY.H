//=============================================================
//  MATHEMATICAL CLASS LIBRARY
//      array.h
//
//      Defines the base class upon which all array classes
//      are based. Also defined is the array pointer type
//      that provides efficient access to elements in array 
//      objects.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef ARRAY_H
#define ARRAY_H

#include "index.h"
#include "stddef.h"

//------------------------------------
// type definitions for function types
//------------------------------------

typedef void * (* ElemCreate)(void *);
typedef void * (* ElemDestroy)(void *);

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  Array class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class Array
    {
    public:

        //----------------------------
        // assign a new error reporter
        //----------------------------

        static void SetErrOut(const ErrReporter & er);

        //----------------------------
        // create an appropriate index
        //----------------------------

        Index MakeIndex() const;

        //--------------
        // get the range
        //--------------

        Range GetRange() const;

        //-----------------------
        // get number of elements
        //-----------------------

        unsigned int GetCount() const;

        //-----------------------
        // get size of an element
        //-----------------------

        size_t GetElemSize() const;

        //--------------------------------
        // get address of destroy function
        //--------------------------------

        ElemDestroy GetDestroyFunc() const;

    protected:

        //-------------
        // constructors
        //-------------

        // original
        Array(const Range & r,
              size_t elemsize,
              ElemCreate  create  = NULL,
              ElemDestroy destroy = NULL);

        // copy
        Array(const Array & a);

        // concatenate
        Array(const Array & a1, const Array & a2);

        // subrange
        Array(const Array & a, const Index & first, const Index & last);

        //-----------
        // destructor
        //-----------

        ~Array();

        //--------------------
        // assignment operator
        //--------------------

        Array & operator = (const Array & r);

        //-------------------------
        // element access functions
        //-------------------------

        const void * ReadElement(const Index & i) const;
        const void * ReadElement(int i) const;

        void * GetElement(const Index & i);
        void * GetElement(int i);

        //-------------
        // data members
        //-------------

        Range  IndexRange;
        char * Buffer;
        size_t ElementSize;
        size_t BufferSize;

        unsigned int Count;

        //---------------------------------------------
        // pointer to function that destroys an element
        //---------------------------------------------

        ElemDestroy DestroyFunc;

        //---------------------
        // error handler object
        //---------------------

        static ErrReporter * ErrOut;

        static void ReportError(const String & msg);

    private:
        //--------------------------------
        // function to delete all elements
        //--------------------------------

        void Kill();

        //-------------------------
        // copies elements from "a"
        //-------------------------

        void Copy(const Array & a);
    };

//-------------
// constructors
//-------------

inline Array::Array(const Array & a)
    : IndexRange(a.IndexRange)
    {
    Copy(a);
    }

//-----------
// destructor
//-----------

inline Array::~Array()
    {
    Kill();
    }

//----------------------------
// create an appropriate index
//----------------------------

inline Index Array::MakeIndex() const
    {
    return Index(IndexRange);
    }

//--------------
// get the range
//--------------

inline Range Array::GetRange() const
    {
    return IndexRange;
    }

//-----------------------
// get size of an element
//-----------------------

inline size_t Array::GetElemSize() const
    {
    return ElementSize;
    }

//--------------------------------
// get address of destroy function
//--------------------------------

inline ElemDestroy Array::GetDestroyFunc() const
    {
    return DestroyFunc;
    }

//-----------------------
// get number of elements
//-----------------------

inline unsigned int Array::GetCount() const
    {
    return Count;
    }

//-------------------------
// element access functions
//-------------------------

inline void * Array::GetElement(int i)
    {
    return GetElement(Index(IndexRange,i));
    }

inline const void * Array::ReadElement(int i) const
    {
    return ReadElement(Index(IndexRange,i));
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  ArrayPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class ArrayPtr
    {
    public:

        //-----------------
        // copy constructor
        //-----------------

        ArrayPtr(const ArrayPtr & aptr);

        //---------------------
        // assignment operators
        //---------------------

        ArrayPtr & operator = (const ArrayPtr & aptr);
        ArrayPtr & operator = (const Index & i);
        ArrayPtr & operator = (int i);

        //------------------------
        // increment and decrement
        //------------------------

        ArrayPtr & operator ++ ();        // prefix
        ArrayPtr operator ++ (int dummy); // postfix

        ArrayPtr & operator -- ();        // prefix
        ArrayPtr operator -- (int dummy); // postfix

        //-----------------------------
        // set to first or last element
        //-----------------------------

        void SetFirst();
        void SetLast();

        //----------------------
        // value check functions
        //----------------------

        int IsFirst();
        int IsLast();

        //---------------------
        // comparison operators
        //---------------------

        int operator == (const ArrayPtr & aptr);
        int operator != (const ArrayPtr & aptr);

    protected:

        //------------
        // constructor
        //------------

        ArrayPtr(char * base, size_t esize, const Range & r);

        //--------------
        // data elements
        //--------------

        size_t ElemSize;    // bytes per element
        Range  ElemRange;   // range of pointer

        char * ElemFirst;   // address of first element
        char * ElemLast;    // address of last  element

        char * ElemPtr;     // pointer to element
    };

//------------------------
// increment and decrement
//------------------------

inline ArrayPtr & ArrayPtr::operator ++ ()
    {
    // prefix
    if (ElemPtr != ElemLast)
        ElemPtr += ElemSize;

    return *this;
    }

inline ArrayPtr ArrayPtr::operator ++ (int dummy)
    {
    // postfix

    // save current state
    ArrayPtr result(*this);

    // move to next element
    if (ElemPtr != ElemLast)
        ElemPtr += ElemSize;

    // return previous state
    return result;
    }

inline ArrayPtr & ArrayPtr::operator -- ()
    {
    // prefix
    if (ElemPtr != ElemFirst)
        ElemPtr -= ElemSize;

    return *this;
    }

inline ArrayPtr ArrayPtr::operator -- (int dummy)
    {
    // postfix

    // save current state
    ArrayPtr result(*this);

    // move to next element
    if (ElemPtr != ElemFirst)
        ElemPtr -= ElemSize;

    // return previous state
    return result;
    }

//-----------------------------
// set to first or last element
//-----------------------------

inline void ArrayPtr::SetFirst()
    {
    ElemPtr = ElemFirst;
    }

inline void ArrayPtr::SetLast()
    {
    ElemPtr = ElemLast;
    }

//----------------------
// value check functions
//----------------------

inline int ArrayPtr::IsFirst()
    {
    return (ElemPtr == ElemFirst);
    }

inline int ArrayPtr::IsLast()
    {
    return (ElemPtr == ElemLast);
    }

//---------------------
// comparison operators
//---------------------

inline int ArrayPtr::operator == (const ArrayPtr & aptr)
    {
    return (ElemPtr == aptr.ElemPtr);
    }

inline int ArrayPtr::operator != (const ArrayPtr & aptr)
    {
    return (ElemPtr != aptr.ElemPtr);
    }

#endif
