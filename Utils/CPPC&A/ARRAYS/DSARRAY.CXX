//======================================================
//  MATHEMATICAL LIBRARY
//      dsarray.cxx
//
//      A variation of the DblArray used for rudimentary
//      statistical analysis.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//======================================================

#include "dsarray.h"
#include "math.h"
#include "float.h"

double DblStatArray::Min() const
    {
    DblArrayConstPtr ptr = MakeConstPtr();

    double result = *ptr;

    for (;;)
        {
        if (ptr.IsLast())
            break;

        ++ptr;

        if (*ptr < result)
            result = *ptr;
        }

    return result;
    }

double DblStatArray::Max() const
    {
    DblArrayConstPtr ptr = MakeConstPtr();

    double result = *ptr;

    for (;;)
        {
        if (ptr.IsLast())
            break;

        ++ptr;

        if (*ptr > result)
            result = *ptr;
        }

    return result;
    }

void DblStatArray::MinMax(double & minimum, double & maximum) const
    {
    DblArrayConstPtr ptr = MakeConstPtr();

    maximum = *ptr;
    minimum = *ptr;

    for (;;)
        {
        if (ptr.IsLast())
            break;

        ++ptr;

        if (*ptr < minimum)
            minimum = *ptr;

        if (*ptr > maximum)
            maximum = *ptr;
        }
    }

double DblStatArray::RangeOf() const
    {
    double minimum, maximum;

    MinMax(minimum,maximum);

    return ::fabs(maximum - minimum);
    }

double DblStatArray::Sum() const
    {
    double result = 0.0;

    DblArrayConstPtr ptr = MakeConstPtr();

    for (;;)
        {
        result += *ptr;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

double DblStatArray::Product() const
    {
    double result = 1.0;

    DblArrayConstPtr ptr = MakeConstPtr();

    for (;;)
        {
        result *= *ptr;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    return result;
    }

double DblStatArray::Mean() const
    {
    return Sum() / (double)Count;
    }

double DblStatArray::Median() const
    {
    DblStatArray temp(*this);

    int middle = (IndexRange.GetMin() + IndexRange.GetMax()) / 2;

    temp.Sort();

    return temp[middle];
    }

double DblStatArray::MedianSort()
    {
    int middle = (IndexRange.GetMin() + IndexRange.GetMax()) / 2;

    Sort();

    return Read(middle);
    }

double DblStatArray::Variance() const
    {
    double temp, result = 0.0;

    double m = Mean();

    DblArrayConstPtr ptr = MakeConstPtr();

    for (;;)
        {
        temp = *ptr - m;

        result += temp * temp;

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    result /= ((double)(Count - 1));

    return result;
    }

double DblStatArray::AvgDeviation() const
    {
    double result = 0.0;
    double m = Mean();

    DblArrayConstPtr ptr = MakeConstPtr();

    for (;;)
        {
        result += fabs(*ptr - m);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    result /= (double)Count;

    return result;
    }

double DblStatArray::Skew() const
    {
    double result;
    double sd = StdDeviation();

    if (sd == 0.0)
        result = 0.0;
    else
        {
        double temp;
        double m  = Mean();

        DblArrayConstPtr ptr = MakeConstPtr();

        for (;;)
            {
            temp = (*ptr - m) / sd;

            result += (temp * temp * temp);

            if (ptr.IsLast())
                break;

            ++ptr;
            }

        result /= ((double)(Count - 1));
        }

    return result;
    }

double DblStatArray::Kurt() const
    {
    double result = 0.0;
    double sd = StdDeviation();

    if (sd == 0.0)
        result = 0.0;
    else
        {
        double temp;
        double m  = Mean();

        DblArrayConstPtr ptr = MakeConstPtr();

        for (;;)
            {
            temp = (*ptr - m) / sd;
            result += (temp * temp * temp * temp);

            if (ptr.IsLast())
                break;

            ++ptr;
            }

        result /= (double)Count;
        result -= 3.0;
        }

    return result;
    }

void DblStatArray::Moment(double & mean,
                          double & avgdev,
                          double & stddev,
                          double & var,
                          double & skew,
                          double & kurt) const
    {
    double temp, tempsqr, cnt;

    cnt  = (double)Count;
    mean = Mean();

    var    = 0.0;
    avgdev = 0.0;

    DblArrayConstPtr ptr = MakeConstPtr();

    for (;;)
        {
        temp = *ptr - mean;

        var    += temp * temp;
        avgdev += fabs(temp);

        if (ptr.IsLast())
            break;

        ++ptr;
        }

    var    /= cnt - 1.0;
    avgdev /= cnt;
    stddev  = sqrt(var);

    if (stddev == 0.0)
        {
        skew = 0.0;
        kurt = 0.0;
        }
    else
        {
        ptr.SetFirst();

        skew = 0.0;
        kurt = 0.0;

        for (;;)
            {
            temp = (*ptr - mean) / stddev;

            tempsqr = temp * temp;

            kurt += (tempsqr * tempsqr);
            skew += (tempsqr * temp);

            if (ptr.IsLast())
                break;

            ++ptr;
            }

        skew /= cnt - 1.0;
        kurt /= cnt;
        kurt -= 3.0;
        }
    }

double DblStatArray::ZScore(const Index & i) const
    {
    double result = 0.0;

    double sd = StdDeviation();

    if (sd == 0.0)
        result = 0.0;
    else
        result = (Read(i) - Mean()) / sd;

    return result;
    }

double DblStatArray::ZScore(int i) const
    {
    double result = 0.0;

    double sd = StdDeviation();

    if (sd == 0.0)
        result = 0.0;
    else
        result = (Read(i) - Mean()) / sd;

    return result;
    }

DblStatArray DblStatArray::ZScore() const
    {
    DblStatArray result(IndexRange);

    double sd = StdDeviation();

    if (sd == 0.0)
        result.Fill(0.0);        
    else
        {
        DblArrayConstPtr  src = MakeConstPtr();
        DblArrayPtr      dest = result.MakePtr();

        double m  = Mean();

        for (;;)
            {
            *dest = (*src - m) / sd;

            if (src.IsLast())
                break;

            ++src;
            ++dest;
            }
        }

    return result;
    }

double DblStatArray::Correlation(const DblStatArray & dsa)
    {
    if (IndexRange != dsa.IndexRange)
        ReportError("Incompatible arrays in Correlation");

    DblArrayConstPtr ptr1 = MakeConstPtr();
    DblArrayConstPtr ptr2 = dsa.MakeConstPtr();

    double result = 0.0;

    double  m1 = Mean();
    double  m2 = dsa.Mean();
    double sd1 = StdDeviation();
    double sd2 = dsa.StdDeviation();

    if ((sd1 == 0.0) || (sd2 == 0.0))
        {
        if (sd1 == sd2)
            result = 1.0;
        else
            result = 0.0;
        }
    else
        {
        for (;;)
            {
            result += ((*ptr1 - m1) / sd1) * ((*ptr2 - m2) / sd2);

            if (ptr1.IsLast())
                break;

            ++ptr1;
            ++ptr2;
            }

        result /= Count;
        }

    return result;
    }
