//=============================================================
//  MATHEMATICAL LIBRARY
//      srtarray.h
//
//      A variant of the Array class that supports sorting
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef SRTARRAY_H
#define SRTARRAY_H

#include "array.h"

class SortableArray : public Array
    {
    public:
        //-----------------
        // sorting function
        //-----------------

        void Sort();

    protected:
        //-------------
        // constructors
        //-------------

        SortableArray(const Range & r,
                      size_t elemsize,
                      ElemCreate  create  = NULL,
                      ElemDestroy destroy = NULL);

        SortableArray(const SortableArray & a);

        // concatenate
        SortableArray(const SortableArray & a1,
                      const SortableArray & a2);

        // subrange
        SortableArray(const SortableArray & a,
                      const Index & first,
                      const Index & last);

        //--------------------
        // assignment operator
        //--------------------

        SortableArray & operator = (const SortableArray & a);

    private:

        //----------------------------------------
        // is the first element before the second?
        //----------------------------------------

        virtual int  IsBefore(const Index & i1, const Index & i2) = 0;

        //----------------------
        // exchange two elements
        //----------------------

        virtual void Exchange(const Index & i1, const Index & i2) = 0;
    };

//-------------
// constructors
//-------------

inline SortableArray::SortableArray(const Range & r,
                                    size_t elemsize,
                                    ElemCreate  create,
                                    ElemDestroy destroy)
    : Array(r,elemsize,create,destroy)
    {
    // does nothing else
    }

inline SortableArray::SortableArray(const SortableArray & a)
    : Array(a)
    {
    // does nothing else
    }

inline SortableArray::SortableArray(const SortableArray & a1,
                                    const SortableArray & a2)
    : Array(a1,a2)
    {
    // does nothing else
    }

inline SortableArray::SortableArray(const SortableArray & a,
                                    const Index & first,
                                    const Index & last)
    : Array(a,first,last)
    {
    // does nothing else
    }

//--------------------
// assignment operator
//--------------------

inline SortableArray & SortableArray::operator = (const SortableArray & a)
    {
    this->Array::operator = (a);

    return *this;
    }

#endif
