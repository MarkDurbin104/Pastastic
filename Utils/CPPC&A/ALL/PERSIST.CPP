//////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      persist.cxx
//
//      Defines a class for handling type-independant data.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
//////////////////////////////////////////////////////////////

#include "persist.h"
#include "string.h"

ErrReporter * DataBlock::ErrOut = NULL;

const DataBlock NULL_BLOCK;

//-----------------------------------------------------------
//  DataBlock
//      A dynamically-allocated piece of memory
//-----------------------------------------------------------

void DataBlock::ReportError()
    {
    if (ErrOut != NULL)
        ErrOut->Fatal("memory allocation failure");
    }

void DataBlock::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

DataBlock::DataBlock(Signature sig, size_t sz, const void * data)
    {
    BufferSize = sz;
    BlockSig   = sig;

    BufferPtr = (void *)new char[sz];

    if (BufferPtr == NULL)
        ReportError();
        
    if (data == NULL)
        memset(BufferPtr,0,sz);
    else
        memcpy(BufferPtr,data,sz);
    }

DataBlock::DataBlock(const DataBlock & db)
    {
    BufferSize = db.BufferSize;
    BlockSig   = db.BlockSig;

    BufferPtr  = (void *)new char[BufferSize];

    if (BufferPtr == NULL)
        ReportError();
        
    memcpy(BufferPtr,db.BufferPtr,BufferSize);
    }

void DataBlock::operator = (const DataBlock & db)
    {
    BufferSize = db.BufferSize;
    BlockSig   = db.BlockSig;

    if (BufferPtr != NULL)
        delete BufferPtr;

    BufferPtr = (void *)new char[BufferSize];

    if (BufferPtr == NULL)
        ReportError();
        
    memcpy(BufferPtr,db.BufferPtr,BufferSize);
    }


//-------------------------------------------------------
//  KeyString
//      A KeyBlock that uses a String
//-------------------------------------------------------

const Signature KeyString::Sig = SYS_SIG_BASE + 1;

KeyString::operator DataBlock() const
    {
    return DataBlock(Sig,(size_t)(KStr.Length() + 1), 
                     ((const void *)((const char *)KStr)));
    }

