//=============================================================
//  MATHEMATICAL CLASS LIBRARY
//      array.cxx
//
//      Defines the base class upon which all array classes
//      are based. Also defined is the array pointer type
//      that provides efficient access to elements in array 
//      objects.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "array.h"
#include "string.h"

#ifdef __ZTC__
#include "iostream.hpp"
#else
#include "iostream.h"
#endif

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  Array class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//---------------------
// error handler object
//---------------------

static const String ErrMsg("Array"); 

ErrReporter * Array::ErrOut = new DosErrReporter(&ErrMsg);

//------------------------
// function to call ErrOut
//------------------------

void Array::ReportError(const String & msg)
    {
    if (ErrOut != NULL)
        ErrOut->Fatal(msg);
    }

//----------------------------
// assign a new error reporter
//----------------------------

void Array::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

//-------------
// constructors
//-------------

Array::Array(const Range & r, 
             size_t        elemSize,
             ElemCreate    create, 
             ElemDestroy   destroy)
    : IndexRange(r)
    {
    if (r.GetMagnitude() > UINT_MAX / elemSize)
        ReportError("capacity exceeded in construction");

    BufferSize = elemSize * r.GetMagnitude();

    Buffer = (char *)new char[BufferSize];

    if (Buffer == NULL)
        ReportError("unable to allocate buffer");

    ElementSize = elemSize;
    DestroyFunc = destroy;

    if (create != NULL)
        {
        for (size_t n = 0; n < r.GetMagnitude(); ++n)
            create((void *)(Buffer + n * elemSize));
        }

    Count = IndexRange.GetMagnitude();
    }

Array::Array(const Array & a1, const Array & a2)
    : IndexRange(a1.IndexRange + a2.IndexRange)
    {
    if (a1.ElementSize != a2.ElementSize)
        ReportError("construction using incompatible array types");

    BufferSize = a1.ElementSize * IndexRange.GetMagnitude();

    Buffer = (char *)new char[BufferSize];

    if (Buffer == NULL)
        ReportError("unable to allocate buffer");

    ElementSize = a1.ElementSize;
    DestroyFunc = a1.DestroyFunc;

    memcpy(Buffer,
           a1.Buffer,
           a1.BufferSize);

    memcpy(Buffer + a1.BufferSize,
           a2.Buffer,
           a2.BufferSize);
    }

Array::Array(const Array & a, const Index & first, const Index & last)
    : IndexRange((int)first,(int)last)
    {
    if ((Range(first) == a.IndexRange)
    &&  (Range(last)  == a.IndexRange))
        {
        BufferSize = a.ElementSize * IndexRange.GetMagnitude();

        Buffer = (char *)new char[BufferSize];

        if (Buffer == NULL)
            ReportError("unable to allocate buffer");

        ElementSize = a.ElementSize;
        DestroyFunc = a.DestroyFunc;

        memcpy(Buffer,
               a.Buffer + (unsigned int)first * ElementSize,
               ((unsigned int)last - (unsigned int)first) * ElementSize);
        }
    else
        ReportError("construction with incompatible indexes");
    }

//--------------------
// assignment operator
//--------------------

Array & Array::operator = (const Array & a)
    {
    Kill();
    IndexRange = a.IndexRange;

    Copy(a);
    return *this;
    }

//-------------------------
// element access functions
//-------------------------

void * Array::GetElement(const Index & i)
    {
    void * result;

    if (IndexRange == Range(i))
        result = (void *)(Buffer + ElementSize * (unsigned int)i);
    else
        ReportError("invalid index");

    return result;
    }

const void * Array::ReadElement(const Index & i) const
    {
    const void * result;

    if (IndexRange == Range(i))
        result = (const void *)(Buffer + ElementSize * (unsigned int)i);
    else
        ReportError("invalid index");

    return result;
    }

//--------------------------------
// function to delete all elements
//--------------------------------

void Array::Kill()
    {
    if (DestroyFunc != NULL)
        {
        for (size_t n = 0; n < IndexRange.GetMagnitude(); ++n)
            DestroyFunc((void *)(Buffer + n * ElementSize));
        }

    delete [BufferSize] Buffer;
    }

//-------------------------
// copies elements from "a"
//-------------------------

void Array::Copy(const Array & a)
    {
    BufferSize = a.BufferSize;

    Buffer = (char *)new char[BufferSize];

    if (Buffer == NULL)
        ReportError("unable to allocate buffer");

    memcpy(Buffer, a.Buffer, BufferSize);

    IndexRange  = a.IndexRange;
    ElementSize = a.ElementSize;
    DestroyFunc = a.DestroyFunc;
    Count       = a.Count;
    }

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  ArrayPtr class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//------------
// constructor
//------------

ArrayPtr::ArrayPtr(char * base, size_t esize, const Range & r)
    : ElemRange(r)
    {
    ElemSize  = esize;
    ElemFirst = base;
    ElemLast  = ElemFirst + ElemSize * (ElemRange.GetMagnitude() - 1);
    ElemPtr   = ElemFirst;
    }

//-----------------
// copy constructor
//-----------------

ArrayPtr::ArrayPtr(const ArrayPtr & aptr)
    : ElemRange(aptr.ElemRange)
    {
    ElemSize  = aptr.ElemSize;
    ElemFirst = aptr.ElemFirst;
    ElemLast  = aptr.ElemLast;
    ElemPtr   = aptr.ElemPtr;
    }

//---------------------
// assignment operators
//---------------------

ArrayPtr & ArrayPtr::operator = (const ArrayPtr & aptr)
    {
    ElemSize  = aptr.ElemSize;
    ElemRange = aptr.ElemRange;
    ElemFirst = aptr.ElemFirst;
    ElemLast  = aptr.ElemLast;
    ElemPtr   = aptr.ElemPtr;

    return *this;
    }

ArrayPtr & ArrayPtr::operator = (const Index & i)
    {
    if (ElemRange == Range(i))
        ElemPtr = ElemFirst + ElemSize * (unsigned int)i;

    return *this;
    }

ArrayPtr & ArrayPtr::operator = (int i)
    {
    ElemRange.Check(i);

    ElemPtr = ElemFirst + ElemSize * i;

    return *this;
    }
