//============================================================
//  DYNAMIC STRING CLASS
//      str.cxx
//
//      Provides a general dynamic string class.
//
//      Copyright 1991, 1992 Scott Robert Ladd
//      All Rights Reserved
//============================================================

#include "str.h"
#include "iomanip.h"
#include "string.h"
#include "stdlib.h"
#include "stdio.h"
#include "stdarg.h"
#include "ctype.h"
#include "limits.h"

//-------------------------------------------------------------
//  String class
//-------------------------------------------------------------

// class-global constant initialization
size_t String::AllocIncr = 8;

ErrReporter * String::ErrOut = NULL;

// error reporting function
void String::ErrorHandler(StrError err)
    {
    if (ErrOut != NULL)
        {
        switch (err)
            {
            case SE_ALLOC :
                ErrOut->Fatal("String allocation failure");
                break;

            case SE_TOO_LONG :
                ErrOut->Fatal("String exceeded character limit");
                break;

            case SE_INVALID :
                ErrOut->Fatal("String invalid parameters");
            }
        }
    }

// Assign an exception handler
void String::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

// calculate the allocation size for a string
inline size_t String::CalcSiz(size_t needed)
    {
    size_t x;

    x = ((needed + AllocIncr) / AllocIncr) * AllocIncr;

    return x;
    }

// constructor
String::String()
    {
    Len = 0;
    Siz = 0;
    Txt = NULL;
    }

String::String(const String & str)
    {
    Len = str.Len;
    Siz = str.Siz;

    if (str.Txt == NULL)
        Txt = NULL;
    else
        {
        Txt = new char[Siz];

        if (Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(Txt,str.Txt,Len + 1);
        }
    }

String::String(const char * cstr)
    {
    if ((cstr == NULL) || (cstr[0] == '\x00'))
        {
        Len = 0;
        Siz = 0;
        Txt = NULL;
        }
    else
        {
        Len = strlen(cstr);
        Siz = CalcSiz(Len);

        Txt = new char [Siz];

        if (Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(Txt,cstr,Len + 1);
        }
    }

String::String(size_t count, char fillCh)
    {
    if (count == 0)
        ErrorHandler(SE_INVALID);

    Siz = CalcSiz(count);
    Len = count;

    Txt = new char[Siz];

    if (Txt == NULL)
        ErrorHandler(SE_ALLOC);

    memset(Txt,fillCh,count);

    Txt[count] = '\x00';
    }

String::String(size_t maxsize, const char * format, ... )
    {
    // allocate temporary buffer
    char * buffer = new char[maxsize];

    if (buffer == NULL)
        ErrorHandler(SE_ALLOC);

    // initialize argument list
    va_list args;
    
    va_start(args,format);

    // format items into buffer based on format
    Len = vsprintf(buffer,format,args);

    // end argument list processing
    va_end(args);

    // calculate require Txt length
    Siz = CalcSiz(Len);

    // allocate Txt
    Txt = new char[Siz];

    if (Txt == NULL)
        ErrorHandler(SE_ALLOC);

    // duplicate data from buffer
    strcpy(Txt,buffer);

    // delete buffer
    delete buffer;
    }

// destructor
String::~String()
    {
    if (Txt != NULL)
        delete Txt;
    }

// assignment method
String String::operator = (const String & str)
    {
    Len = str.Len;
    Siz = str.Siz;

    if (Txt != NULL)
        delete Txt;

    if (Siz == 0)
        Txt = NULL;
    else
        {
        Txt = new char[Siz];

        if (Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(Txt,str.Txt,Len + 1);
        }

    return *this;
    }

// concatenation methods
String operator + (const String & str1,
                   const String & str2)
    {
    String temp;

    unsigned long totalLen = str1.Len + str2.Len;

    if (totalLen == 0)
        return temp;

    if (totalLen > UINT_MAX)
        String::ErrorHandler(SE_TOO_LONG);

    temp.Len = 0;
    temp.Siz = String::CalcSiz((size_t)totalLen);
    temp.Txt = new char[temp.Siz];

    if (temp.Txt == NULL)
        String::ErrorHandler(SE_ALLOC);

    temp.Txt[0] = '\000';

    if (str1.Txt != NULL)
        {
        memcpy(temp.Txt,str1.Txt,str1.Len);
        temp.Len = str1.Len;
        }

    if (str2.Txt != NULL)
        {
        memcpy(&temp.Txt[temp.Len],str2.Txt,str2.Len + 1);
        temp.Len += str2.Len;
        }

    return temp;
    }

// concatenation methods
String operator + (const String & str, char ch)
    {
    String temp;

    if (str.Txt == NULL)
        {
        temp.Len = 1;
        temp.Siz = String::AllocIncr;
        temp.Txt = new char [temp.Siz];

        if (temp.Txt == NULL)
            String::ErrorHandler(SE_ALLOC);

        temp.Txt[0] = ch;
        temp.Txt[1] = '\000';
        }
    else
        {
        if (str.Len == UINT_MAX)
            String::ErrorHandler(SE_TOO_LONG);

        temp.Len = str.Len + 1;

        if (temp.Len == str.Siz)
            temp.Siz = str.Siz + String::AllocIncr;
        else
            temp.Siz = str.Siz;

        temp.Txt = new char[temp.Siz];

        if (temp.Txt == NULL)
            String::ErrorHandler(SE_ALLOC);

        memcpy(temp.Txt,str.Txt,str.Len);

        temp.Txt[str.Len]  = ch;
        temp.Txt[temp.Len] = '\000';
        }

    return temp;
    }

StrCompVal String::Compare(const String & str,
                           StrCompMode caseChk) const
    {
    // handle special cases where one string is empty
    if (Txt == NULL)
        if (str.Txt == NULL)
            return SC_EQUAL;
        else
            return SC_LESS;

    if (str.Txt == NULL)
        return SC_GREATER;

    // compare the # of characters in the shorter string
    size_t count;

    if (str.Len < Len)
        count = str.Len;
    else
        count = Len;

    // working variables
    char   c1, c2;
    size_t i;

    if (caseChk == SM_IGNORE)
        {
        // case insensitive comparison
        for (i = 0; i < count; ++i)
            {
            c1 = (char)tolower(Txt[i]);
            c2 = (char)tolower(str.Txt[i]);

            // if characters differ
            if (c1 != c2)
                {
                // select appropriate result
                if (c1 < c2)
                    return SC_LESS;
                else
                    return SC_GREATER;
                }
            }
        }
    else
        {
        for (i = 0; i < count; ++i)
            {
            c1 = Txt[i];
            c2 = str.Txt[i];

            // if characters differ
            if (c1 != c2)
                {
                // select appropriate result
                if (c1 < c2)
                    return SC_LESS;
                else
                    return SC_GREATER;
                }
            }
        }

    // at this point, no differences were found
    if (Len == str.Len)
        return SC_EQUAL;
    else
        {
        // is lengths differ, shorter string < longer one
        if (Len < str.Len)
            return SC_LESS;
        else
            return SC_GREATER;
        }
    }

// substring search methods
Boolean String::Find(const BoyerMoore & bm, size_t & pos) const
    {
    size_t i, j, patlen;

    // store pattern length locally (it gets used a lot)
    patlen = bm.GetPatternLen();

    // i is the index into the target
    i = patlen;

    while (i <= Len)
        {
        // j is an index into pattern
        j = patlen;

        // while corresponding characters match
        while (bm[j - 1] == Txt[i - 1])
            {
            if (j > 1)
                {
                // move left one character for next comparison
                --j;
                --i;
                }
            else
                {
                // we've reached the beginning of the pattern
                // pattern found!
                pos = i - 1;
                return BOOL_TRUE;
                }
            }

        // move target index by delta value of 
        // mismatched character
        i += bm.GetDelta(Txt[i - 1]);
        }

    return BOOL_FALSE;
    }

Boolean String::Find(const String & str,
                     size_t & pos,
                     StrCompMode caseChk) const
    {
    // uses the brute force method
    if (Len < str.Len)
        return BOOL_FALSE;

    // duplicate buffers
    char * target = new char[Len + 1];

    if (target == NULL)
        ErrorHandler(SE_ALLOC);

    strcpy(target,Txt);

    char * pattern = new char[str.Len + 1];

    if (pattern == NULL)
        ErrorHandler(SE_ALLOC);

    strcpy(pattern,str.Txt);

    // create return value variable
    Boolean result;

    // convert to all lowercase if case-insensitive search
    if (caseChk == SM_IGNORE)
        {
        strlwr(target);
        strlwr(pattern);
        }

    // calculate last position in *this where str could be
    size_t end = Len - str.Len;
    size_t p, t;

    // start at the beginning of ttarget
    pos = 0;

    for (;;)
        {
        p = 0;   // beginning of pattern
        t = pos; // beginning of search position in target

        // while characters match 
        // and we're not at the end of the strings

        while ((pattern[p] == target[t])
            && (pattern[p] != 0) 
            && (target[t]  != 0))
            {
            // move to next character
            ++t;
            ++p;
            }

        // if we've reached the end of pattern
        //     we've found pattern in target
 
        if (pattern[p] == 0)
            {
            result = BOOL_TRUE;
            break;
            }

        // if we've reached the end of target
        // or we've searched far enough
        //     pattern has not been found

        if ((target[t] == 0) || (pos >= end))
            {
            result = BOOL_FALSE;
            break;
            }

        // keep looking, starting at the mismatch

        ++pos;
        }

    // delete temporary buffers
    delete target;
    delete pattern;

    // outa here
    return result;
    }

// substring deletion method
void String::Delete(size_t pos, size_t count)
    {
    if (Txt == NULL)
        return;

    size_t newLen, i;

    // error if deleting outside of string
    if ((pos + count - 1) > Len)
        ErrorHandler(SE_INVALID);

    // length of new string
    newLen = Len - count;

    if ((Siz - newLen) > AllocIncr)
        {
        // allocation size has changed
        // calculate new size

        Siz = CalcSiz(newLen);

        // create new buffer

        char * temp = new char[Siz];

        if (temp == NULL)
            ErrorHandler(SE_ALLOC);

        // copy characters into new buffer
        char * tptr = temp;

        for (i = 0; i <= Len; ++i)
            {
            // when count is reached, skip deleted characters
            if (i == pos)
                i += count;

            *tptr = Txt[i];
            ++tptr;
            }

        // delete old buffer
        delete Txt;

        // assign new buffer
        Txt = temp;
        }
    else
        {
        // just "slide" characters down
        for (i = pos + count; i <= Len; ++i)
            Txt[i] = Txt[i + count];
        }

    Len = newLen;
    }

// substring insertion methods
void String::Insert(size_t pos, char ch)
    {
    if (pos > Len)
        ErrorHandler(SE_INVALID);

    if (Txt == NULL)
        {
        // an empty string == ch
        Len = 1;
        Siz = AllocIncr;

        Txt = new char [Siz];

        if (Txt == NULL)
            String::ErrorHandler(SE_ALLOC);

        Txt[0] = ch;
        Txt[1] = '\000';
        }
    else
        {
        size_t newLen = Len + 1;
        size_t i;

        if (newLen == Siz)
            {
            // need a larger buffer
            Siz += AllocIncr;

            // create temporary buffer
            char * temp = new char[Siz];
            char * tptr = temp;

            if (temp == NULL)
                ErrorHandler(SE_ALLOC);

            // copy in old buffer, inserting ch when needed
            for (i = 0; i <= Len; ++i)
                {
                if (i == pos)
                    {
                    *tptr = ch;
                    ++tptr;
                    }

                *tptr = Txt[i];
                ++tptr;
                }

            // delete old buffer
            delete Txt;

            // assign new buffer and length
            Txt = temp;
            Len = newLen;
            }
        else
            {
            // slide characters right
            for (i = newLen; i > pos; --i)
                Txt[i] = Txt[i-1];

            // insert character
            Txt[pos] = ch;

            // adjust length
            Len = newLen;
            }
        }
    }

void String::Insert(size_t pos, const String & str)
    {
    if (str.Txt == NULL)
        return;

    if (pos > Len)
        ErrorHandler(SE_INVALID);

    if (Txt == NULL)
        {
        // empty string = str
        *this = str;
        }
    else
        {
        // calculate new length
        unsigned long totalLen = str.Len + Len;

        if (totalLen > UINT_MAX)
            ErrorHandler(SE_TOO_LONG);

        size_t i, j;

        // if new  length > current size
        if (totalLen > Siz)
            {
            // allocate new buffer
            Siz = CalcSiz((size_t)totalLen);

            char * temp = new char [Siz];
            char * tptr = temp;

            // copy buffers from source strings
            for (i = 0; i <= Len; ++i)
                {
                if (i == pos)
                    {
                    for (j = 0; j < str.Len; ++j)
                        {
                        *tptr = str.Txt[j];
                        ++tptr;
                        }
                    }

                *tptr = Txt[i];
                ++tptr;
                }

            // delete old buffer
            delete Txt;

            // assign new buffer
            Txt = temp;
            }
        else
            {
            // slide section old buffer to right
            for (i = Len + str.Len; i > pos + str.Len; --i)
                Txt[i] = Txt[i - str.Len];

            // insert new string
            for (i = 0; i < str.Len; ++i)
                Txt[pos + i] = str.Txt[i];
            }

        Len = (size_t)totalLen;
        }
    }

// substring retrieval method
String String::Cut(size_t start, size_t count) const
    {
    if ((start + count) > Len)
        ErrorHandler(SE_INVALID);

    String temp;

    if ((start < Len) && (count > 0))
        {
        temp.Len = count;
        temp.Siz = CalcSiz(count);
        temp.Txt = new char[temp.Siz];

        if (temp.Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(temp.Txt,&Txt[start],count);

        temp.Txt[count] = '\000';
        }

    return temp;
    }

String String::CutHead(size_t count) const
    {
    if (count > Len)
        ErrorHandler(SE_INVALID);

    String temp;

    if (count > 0)
        {
        temp.Len = count;
        temp.Siz = CalcSiz(count);
        temp.Txt = new char[temp.Siz];

        if (temp.Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(temp.Txt,Txt,count);

        temp.Txt[count] = '\000';
        }

    return temp;
    }

String String::CutTail(size_t count) const
    {
    if (count > Len)
        ErrorHandler(SE_INVALID);

    String temp;

    if (count > 0)
        {
        temp.Len = count;
        temp.Siz = CalcSiz(count);
        temp.Txt = new char[temp.Siz];

        if (temp.Txt == NULL)
            ErrorHandler(SE_ALLOC);

        memcpy(temp.Txt,&Txt[Len - count - 1],count);

        temp.Txt[count] = '\000';
        }

    return temp;
    }

// case-modification methods
void String::ToUpper()
    {
    if (Txt != NULL)
        strupr(Txt);
    }

void String::ToLower()
    {
    if (Txt != NULL)
        strlwr(Txt);
    }

String String::AsUpper() const
    {
    String temp = *this;

    if (temp.Txt != NULL)
        strupr(temp.Txt);

    return temp;
    }

String String::AsLower() const
    {
    String temp = *this;

    if (temp.Txt != NULL)
        strlwr(temp.Txt);

    return temp;
    }

// stream I/O functions

istream & operator >> (istream & strm, String & str)
    {
    static char buf[128];

    if ((str.Txt == NULL) || (str.Len == 0))
        {
        strm >> setw(128) >> buf;

        #ifdef __ZTC__
            str = (const char *)buf;
        #else
            str = buf;
        #endif
        }
    else
        strm >> setw(str.Len) >> str.Txt;


    return strm;
    }

//-------------------------------------------------------------
//  BoyerMoore class
//-------------------------------------------------------------

const size_t BoyerMoore::DeltaSize = 256;

ErrReporter * BoyerMoore::ErrOut = NULL;

// report an error
void BoyerMoore::ReportError()
    {
    if (ErrOut != NULL)
        ErrOut->Fatal("Boyer-Moore allocation failure");
    }

// Assign an exception handler
void BoyerMoore::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

BoyerMoore::BoyerMoore(const String & pat)
    : Pattern(pat)
    {
    // allocate delta table
    Delta = new size_t [DeltaSize];

    if (Delta == NULL)
        ReportError();
   
    // clear table
    size_t i;

    // get length of pattern
    size_t patlen = Pattern.Length();

    for (i = 0; i < DeltaSize; ++i)
        Delta[i] = patlen;

    // set table values
    for (i = 1; i < patlen; ++i)
        Delta[(size_t)Pattern[i - 1]] = patlen - i;

    // set value for last pattern character
    Delta[(size_t)Pattern[patlen - 1]] = 1;
    }

BoyerMoore::BoyerMoore(const BoyerMoore & bm)
    : Pattern(bm.Pattern)
    {
    // allocate delta table
    Delta = new size_t [DeltaSize];

    if (Delta == NULL)
        ReportError();

    // copy contents of source
    memcpy(Delta,bm.Delta,DeltaSize * sizeof(char));
    }

void BoyerMoore::operator = (const BoyerMoore & bm)
    {
    Delta = bm.Delta;
    }
