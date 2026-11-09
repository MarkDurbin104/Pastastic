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

#include "err_rptr.h"
#include "stdlib.h"
#include "string.h"

ErrReporter::ErrReporter(const String * lead)
    {
    if (lead == NULL)
        Leader = NULL;
    else
        Leader = new String(*lead);
    }

ErrReporter::~ErrReporter()
    {
    // delete leader if it was allocated
    if (Leader != NULL)
        delete Leader;
    }

void ErrReporter::Warning(const String & msg)
    {
    // does nothing!
    }

void ErrReporter::Fatal(const String & msg)
    {
    // does nothing!
    }

void ErrReporter::MsgOut(const String & msg)
    {
    // does nothing!
    }

DosErrReporter::DosErrReporter(const String * lead, 
                                    ostream * strm)
    : ErrReporter(lead)
    {
    if (strm == NULL)
        Destination = &cerr;
    else
        Destination = strm;
    }

void DosErrReporter::Warning(const String & msg)
    {
    *Destination << "\nWARNING - ";

    MsgOut(msg);
    }

void DosErrReporter::Fatal(const String & msg)
    {
    *Destination << "\nFATAL ERROR - ";

    MsgOut(msg);

    exit(EXIT_FAILURE);
    }

void DosErrReporter::MsgOut(const String & msg)
    {
    if (Leader == NULL)
        *Destination << msg << endl;
    else
        *Destination << *Leader << ": " << msg << endl;
    }
