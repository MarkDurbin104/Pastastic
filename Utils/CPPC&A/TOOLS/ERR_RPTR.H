//=============================================================
//  MATHEMATICAL LIBRARY
//      err_rptr.cxx
//
//      A class defining an object for reporting warnings and
//      errors
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
//=============================================================

#ifndef ERR_RPTR_H
#define ERR_RPTR_H

class ErrReporter;

#include "stddef.h"
#include "iostream.h"
#include "str.h"

//-------------------------------------------------------------
//  ErrReporter
//      Base class for error reporting
//-------------------------------------------------------------

class ErrReporter
    {
    public:
        ErrReporter(const String * lead);

        ~ErrReporter();

        virtual void Warning(const String & msg);
        virtual void Fatal(const String & msg);

    protected:
        virtual void MsgOut(const String & msg);

        String * Leader;
    };

//-------------------------------------------------------------
//  DosErrReporter
//      Class for reporting objects in DOS text-based program
//-------------------------------------------------------------

class DosErrReporter : public ErrReporter
    {
    public:
        DosErrReporter(const String * lead = NULL,
                            ostream * strm = NULL);

        virtual void Warning(const String & msg);
        virtual void Fatal(const String & msg);

    protected:
        virtual void MsgOut(const String & msg);

    private:
        ostream * Destination;
    };

#endif
