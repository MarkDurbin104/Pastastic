//=============================================================
//  MATHEMATICAL LIBRARY
//      srtarray.cxx
//
//      A variant of the Array class that supports sorting
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#include "srtarray.h"

//-------------------------------------------
// The stackItem class defines a list of left
// and right index values used in iteration.
//-------------------------------------------

//-------------------------
// a structure used by Sort
//-------------------------

struct stackItem
    {
    Index left;
    Index right;

    static Range lrRange;

    stackItem();
    };

Range stackItem::lrRange(0,1);

stackItem::stackItem()
    : left(lrRange), right(lrRange)
    {
    // empty
    }

//-----------------
// sorting function
//-----------------

void SortableArray::Sort()
    {
    //-------------
    // create stack
    //-------------

    stackItem::lrRange = IndexRange;

    const size_t stackSize = CHAR_BIT * sizeof(int);

    stackItem * stack = new stackItem [stackSize];

    if (stack == NULL)
        ReportError("cannot allocate stack for sorting");

    size_t stackPtr = 0;

    //---------------------------------------------
    // size of minimum partition to median-of-three
    //---------------------------------------------

    const int Threshold = 7;

    //-----------------------------------
    // sizes of left and right partitions
    //-----------------------------------

    int lsize, rsize;

    //-----------------------
    // create working indexes
    //-----------------------

    Index l(IndexRange),     // left   partition index
          r(IndexRange),     // right  partition index
          mid(IndexRange),   // middle partition index
          scanl(IndexRange), // index scanning from left
          scanr(IndexRange), // index scanning from right
          pivot(IndexRange); // pivot element index

    //-------------------
    // set initial values
    //-------------------

    l.SetMin();
    r.SetMax();

    //----------
    // main loop
    //----------

    for (;;)
        {
        while (r > l)
            {
            if (((int)r - (int)l) > Threshold)
                {
                //-------------------------------
                // "median-of-three" partitioning
                //-------------------------------

                mid = ((int)l + (int)r) / 2;

                //--------------------------------------------
                // three-sort left, middle, and right elements
                //--------------------------------------------

                if (IsBefore(mid,l))
                    Exchange(mid,l);

                if (IsBefore(r,l))
                    Exchange(r,l);

                if (IsBefore(r,mid))
                    Exchange(r,mid);

                //------------------------
                // set-up for partitioning
                //------------------------

                pivot = r - 1;

                Exchange(mid,pivot);

                scanl = l + 1;
                scanr = r - 2;
                }
            else
                {
                //------------------------
                // set-up for partitioning
                //------------------------

                pivot = r;
                scanl = l;
                scanr = r - 1;
                }

            for (;;)
                {
                //---------------------------------------
                // scan from left for element >= to pivot
                //---------------------------------------

                while (IsBefore(scanl,pivot) && (scanl < r))
                    ++scanl;

                //----------------------------------------
                // scan from right for element <= to pivot
                //----------------------------------------

                while (IsBefore(pivot,scanr) && (scanr > l))
                    --scanr;

                //-----------------------------------
                // if scans have met, exit inner loop
                //-----------------------------------

                if (scanl >= scanr)
                    break;

                //------------------
                // exchange elements
                //------------------
                Exchange(scanl,scanr);

                if (scanl < r)
                    ++scanl;

                if (scanr > l)
                    --scanr;
                }

            //-----------------------
            // exchange final element
            //-----------------------

            Exchange(pivot,scanl);

            //---------------------------------
            // place largest partition on stack
            //---------------------------------

            lsize = (int)scanl - (int)l;
            rsize = (int)r - (int)scanl;

            if (lsize > rsize)
                {
                if (lsize != 1)
                    {
                    ++stackPtr;

                    if (stackPtr == stackSize)
                        ReportError("stack overflow (left)");

                    stack[stackPtr].left  = l;
                    stack[stackPtr].right = scanl - 1;
                    }

                if (rsize != 0)
                    l = scanl + 1;
                else
                    break;
                }
            else
                {
                if (rsize != 1)
                    {
                    ++stackPtr;

                    if (stackPtr == stackSize)
                        ReportError("stack overflow (right)");

                    stack[stackPtr].left  = scanl + 1;
                    stack[stackPtr].right = r;
                    }

                if (lsize != 0)
                    r = scanl - 1;
                else
                    break;
                }
            }

        //-------------------------------
        // iterate with values from stack
        //-------------------------------

        if (stackPtr)
            {
            l = stack[stackPtr].left;
            r = stack[stackPtr].right;

            --stackPtr;
            }
        else
            break;
        }

    delete [stackSize] stack;
    }
