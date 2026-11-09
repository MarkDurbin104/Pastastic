//============================================================
//  DYNAMIC STRING CLASS
//      str.h
//
//      Provides a general dynamic string class.
//
//      Copyright 1991, 1992 Scott Robert Ladd
//      All Rights Reserved
//============================================================

#ifndef STR_H
#define STR_H

class String;
class BoyerMoore;

#include "stddef.h"
#include "iostream.h"
#include "err_rptr.h"
#include "boolean.h"

//-------------------------------------------------------------
//  String class
//-------------------------------------------------------------

enum StrCompVal  
    {
    SC_LESS, 
    SC_EQUAL, 
    SC_GREATER, 
    SC_ERROR
    };

enum StrCompMode 
    {
    SM_SENSITIVE, 
    SM_IGNORE
    };

enum StrError
    {
    SE_ALLOC, 
    SE_TOO_LONG, 
    SE_INVALID
    };

class String
    {
    public:
        // constructor
        String();
        String(const String & str);
        String(const char * cstr);
        String(size_t count,   char fillCh = '\0');
        String(size_t maxsize, const char * format, ... );

        // destructor
        ~String();

        // version number
        static int Version();

        // value return methods
        size_t Length() const;
        size_t Size() const;

        // Assign an exception handler
        static void SetErrOut(const ErrReporter & er);

        // create a c-string from String method
        operator const char * () const;

        // assignment method
        String operator = (const String & str);

        // concatenation methods
        friend String operator + (const String & str1, 
                                  const String & str2);

        friend String operator + (const String & str1, char ch);

        void operator += (const String & str);
        void operator += (char ch);

        // comparison methods
        int operator <  (const String & str) const;
        int operator >  (const String & str) const;
        int operator <= (const String & str) const;
        int operator >= (const String & str) const;
        int operator == (const String & str) const;
        int operator != (const String & str) const;

        StrCompVal Compare(const String & str,
                           StrCompMode caseChk = SM_IGNORE) const;

        // substring search methods
        Boolean Find(const BoyerMoore & bm, size_t & pos) const;

        Boolean Find(const String & str,
                     size_t & pos,
                     StrCompMode caseChk = SM_IGNORE) const;

        // substring deletion method
        void Delete(size_t pos, size_t count);

        // substring insertion methods
        void Insert(size_t pos, char ch);
        void Insert(size_t pos, const String & str);

        // substring retrieval method
        String Cut(size_t start, size_t count) const;
        String CutHead(size_t count) const;
        String CutTail(size_t count) const;

        // character retrieval method
        char operator [] (size_t pos) const;

        // case-modification methods
        void ToUpper();
        void ToLower();

        String AsUpper() const;
        String AsLower() const;

        // stream input/output methods
        friend ostream & operator << (ostream & strm,
                                      const String & str);

        friend istream & operator >> (istream & strm,
                                      String & str);

    private:
        // instance variables
        size_t Siz; // allocated size
        size_t Len; // current length
        char * Txt; // pointer to text

        // error display object
        static ErrReporter * ErrOut;

        // class constant
        static size_t AllocIncr;

        // pointer to error handler
        static void ErrorHandler(StrError err);

        // calc alloc size for needed bytes
        static size_t CalcSiz(size_t needed);
    };

// obtain version number
inline int String::Version()
    {
    return 0x0500;
    }

// value return methods
inline size_t String::Length() const
    {
    return Len;
    }

inline size_t String::Size() const
    {
    return Siz;
    }

// add-assignment operator
inline void String::operator += (const String & str)
    {
    *this = *this + str;
    }

inline void String::operator += (char ch)
    {
    *this = *this + ch;
    }

// create a c-string from String method
inline String::operator const char * () const
    {
    return Txt;
    }

// comparison methods
inline int String::operator <  (const String & str) const
    {
    return (Compare(str) == SC_LESS);
    }

inline int String::operator >  (const String & str) const
    {
    return (Compare(str) == SC_GREATER);
    }

inline int String::operator <= (const String & str) const
    {
    return (Compare(str) != SC_GREATER);
    }

inline int String::operator >= (const String & str) const
    {
    return (Compare(str) != SC_LESS);
    }

inline int String::operator == (const String & str) const
    {
    return (Compare(str) == SC_EQUAL);
    }

inline int String::operator != (const String & str) const
    {
    return (Compare(str) != SC_EQUAL);
    }

// character retrieval method
inline char String::operator [] (size_t pos) const
    {
    if (pos >= Len)
        return '\x00';
    else
        return Txt[pos];
    }

// stream I/O functions

inline ostream & operator << (ostream & strm, const String & str)
    {
    strm << str.Txt;

    return strm;
    }

//-------------------------------------------------------------
//  BoyerMoore class
//-------------------------------------------------------------

class BoyerMoore
    {
    public:
        // constructors
        BoyerMoore(const String & pattern);
        BoyerMoore(const BoyerMoore & bm);

        // destructor
        ~BoyerMoore();

        // assignment operator
        void operator = (const BoyerMoore & bm);

        // get charactre from pattern string
        char operator [] (size_t index) const;

        // get delta value from table
        size_t GetDelta(char ch) const;

        // get length of pattern used to create table
        size_t GetPatternLen() const;

        // Assign an exception handler
        static void SetErrOut(const ErrReporter & er);

    private:

        // error display object
        static ErrReporter * ErrOut;

        // pointer to error handler
        static void ReportError();

        // size of delta table
        static const size_t DeltaSize;

        // pointer to delta table
        size_t * Delta;
        String Pattern;
    };

// destructor
inline BoyerMoore::~BoyerMoore()
    {
    delete Delta;
    }

// get delta value for a given character
inline size_t BoyerMoore::GetDelta(char ch) const
    {
    return Delta[size_t(ch)];
    }

// get length of pattern used to create table
inline size_t BoyerMoore::GetPatternLen() const
    {
    return Pattern.Length();
    }

inline char BoyerMoore::operator [] (size_t index) const
    {
    return Pattern[index];
    };

#endif
