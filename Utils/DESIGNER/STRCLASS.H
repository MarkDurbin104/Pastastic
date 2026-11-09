#ifndef STRCLASS_H
#define STRCLASS_H

_CLASSDEF(Str)
class Str
{
    protected:
        int len;
        char init;
        char *string;
    public:
        int Len() { return len-1; }
        ~Str() { delete string; }
        Str();
        Str(char *);
        Str(const char *);
        Str(Str &);
        Str& operator =  (Str &);
        Str& operator =  (char *);
        Str& operator =  (const char *);
        Str operator +  (Str &);
        Str operator +  (char *);
        Str operator +  (const char *);
//        char operator [] (int);
        int  operator == (Str &);
        int  operator == (char *);
        int  operator == (const char *);
        int  operator != (Str &);
        int  operator != (char *);
        int  operator != (const char *);
        operator char *();
};

#endif
