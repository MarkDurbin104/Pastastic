//======================================================
//  MATHEMATICAL LIBRARY
//      dsarray.h
//
//      A variation of the DblArray used for rudimentary
//      statistical analysis.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//======================================================

#ifndef DSARRAY_H
#define DSARRAY_H

#include "darray.h"
#include "math.h"

//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//
//  DblStatArray class
//
//-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

class DblStatArray : public DblArray
    {
    public:

        //-------------
        // constructors
        //-------------

        DblStatArray(const Range & r);
        DblStatArray(const DblArray & da);
        DblStatArray(const DblStatArray & dsa);
        DblStatArray(const IntArray & ia);

        // concatenate
        DblStatArray(const DblStatArray & a1,
                     const DblStatArray & a2);

        // subrange
        DblStatArray(const DblStatArray & a,
                     const Index & first,
                     const Index & last);

        //--------------------
        // assignment operator
        //--------------------

        DblStatArray & operator = (const DblStatArray & da);

        //---------------------------------------
        // mathematical and statistical functions
        //---------------------------------------

        // minimum, maximum, and range determination
        double Min() const;
        double Max() const;

        void MinMax(double & minimum, double & maximum) const;

        double RangeOf() const;

        // series calculations
        double Sum() const;
        double Product() const;

        // calculate moments of distribution
        double Mean() const;
        double Median() const;
        double MedianSort();

        double Variance() const;

        double StdDeviation() const;
        double AvgDeviation() const;

        double Skew() const;
        double Kurt() const;

        // calculate several values at once
        void Moment(double & mean,
                    double & avgdev,
                    double & stddev,
                    double & var,
                    double & skew,
                    double & kurt) const;

        // calculate standardized scores (z-scores)
        double ZScore(const Index & i) const;
        double ZScore(int i) const;

        DblStatArray ZScore() const;

        // calculate Pearson's coefficient of correlation
        // for a pair of arrays
        double Correlation(const DblStatArray & dsa);
    };

//-------------
// constructors
//-------------

inline DblStatArray::DblStatArray(const Range & r)
    : DblArray(r)
    {
    // empty
    }

inline DblStatArray::DblStatArray(const DblArray & da)
    : DblArray(da)
    {
    // empty
    }

inline DblStatArray::DblStatArray(const DblStatArray & dsa)
    : DblArray(dsa)
    {
    // empty
    }

inline DblStatArray::DblStatArray(const IntArray & ia)
    : DblArray(ia)
    {
    // empty
    }

inline DblStatArray::DblStatArray(const DblStatArray & a1,
                                  const DblStatArray & a2)
    : DblArray(a1,a2)
    {
    // does nothing else
    }

inline DblStatArray::DblStatArray(const DblStatArray & a,
                                  const Index & first,
                                  const Index & last)
    : DblArray(a,first,last)
    {
    // does nothing else
    }

//--------------------
// assignment operator
//--------------------

inline DblStatArray & DblStatArray::operator = (const DblStatArray & da)
    {
    this->DblArray::operator = (da);

    return *this;
    }

//-------------------
// standard deviation
//-------------------

inline double DblStatArray::StdDeviation() const
    {
    return sqrt(Variance());
    }

#endif
