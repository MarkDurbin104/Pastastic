///////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      persist.h
//
//      Defines a class for handling type-independant data.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
//////////////////////////////////////////////////////////////

#ifndef PERSIST_H
#define PERSIST_H

#include "err_rptr.h"
#include "str.h"
#include "boolean.h"
#include "stddef.h"

//-------------------------------------------------------
//  Signature
//      The data type used as an identification code for
//      blocks of data. This should be a unique value for
//      each object type.
//-------------------------------------------------------

typedef unsigned long Signature;

const Signature USER_SIG_BASE = 0x00000000;
const Signature SYS_SIG_BASE  = 0x80000000;
const Signature USER_SIG_MAX  = SYS_SIG_BASE - 1;

//-----------------------------------------------------------
//  DataBlock
//      Containers store these; objects are created from them
//-----------------------------------------------------------

class DataBlock
    {
    public:
        // constructors
        DataBlock();

        DataBlock(Signature sig, 
                  size_t sz, 
                  const void * data);

        DataBlock(const DataBlock & db);

        // destructor
        ~DataBlock();

        // assignment
        void operator = (const DataBlock & db);

        // interrogation
        Signature    GetSignature() const;
        size_t       GetSizeOf() const;
        const void * GetBufferPtr() const;

        // check for NULL block
        Boolean IsNull() const;

        // change error reporter
        static void SetErrOut(const ErrReporter & er);

    protected:
        Signature BlockSig;
        size_t    BufferSize;
        void *    BufferPtr;

        static ErrReporter * ErrOut;

        static void ReportError();
    };

inline DataBlock::DataBlock()
    {
    BufferSize = 0;
    BufferPtr  = NULL;
    BlockSig   = 0;
    }

inline DataBlock::~DataBlock()
    {
    if (BufferPtr != NULL)
        delete BufferPtr;
    }

inline Signature DataBlock::GetSignature() const
    {
    return BlockSig;
    }

inline size_t DataBlock::GetSizeOf() const
    {
    return BufferSize;
    }

inline const void * DataBlock::GetBufferPtr() const
    {
    return BufferPtr;
    }

inline Boolean DataBlock::IsNull() const
    {
    if (BufferSize == 0)
        return BOOL_TRUE;
    else
        return BOOL_FALSE;
    }

extern const DataBlock NULL_BLOCK;

//-------------------------------------------------------
//  Persistent
//      A characteristic class for persistent objects
//-------------------------------------------------------

class Persistent
    {
    public:
        //****************************************
        // all persistent classes should define a
        // a constructor that converts a DataBlock
        // to an object:
        //
        // Persistent(const DataBlock & db);
        //****************************************

        virtual operator DataBlock() const = 0;
    };

//-------------------------------------------------------------
//  KeyString
//      A key firdl that uses a String
//-------------------------------------------------------------

class KeyString : public Persistent
    {
    public:
        KeyString();
        KeyString(const String & str);
        KeyString(const char * str);
        KeyString(const DataBlock & db);
        KeyString(const KeyString & key);

        const String & GetString() const;

        virtual operator DataBlock() const;

        StrCompVal Compare(const KeyString & key,
                           StrCompMode chkCase = SM_SENSITIVE);

        int operator <  (const KeyString & key) const;
        int operator <= (const KeyString & key) const;
        int operator == (const KeyString & key) const;
        int operator != (const KeyString & key) const;
        int operator >= (const KeyString & key) const;
        int operator >  (const KeyString & key) const;

    protected:
        static const Signature Sig;

    private:
        String KStr;
    };

inline KeyString::KeyString()
    {
    // void
    }

inline KeyString::KeyString(const String & str)
    : KStr(str)
    {
    // void
    }

inline KeyString::KeyString(const char * str)
    : KStr(str)
    {
    // void
    }
    
inline KeyString::KeyString(const DataBlock & db)
    : KStr((const char *)(db.GetBufferPtr()))
    {
    // void
    }

inline KeyString::KeyString(const KeyString & keystr)
    : KStr(keystr.KStr)
    {
    // void
    }

inline const String & KeyString::GetString() const
    {
    return KStr;
    }

inline StrCompVal KeyString::Compare(const KeyString & key,
                                     StrCompMode chkCase)
    {
    return KStr.Compare(key.KStr,chkCase);
    }

inline int KeyString::operator <  (const KeyString & key) const
    {
    return (KStr < key.KStr);
    }

inline int KeyString::operator <= (const KeyString & key) const
    {
    return (KStr <= key.KStr);
    }

inline int KeyString::operator == (const KeyString & key) const
    {
    return (KStr == key.KStr);
    }

inline int KeyString::operator != (const KeyString & key) const
    {
    return (KStr != key.KStr);
    }

inline int KeyString::operator >= (const KeyString & key) const
    {
    return (KStr >= key.KStr);
    }

inline int KeyString::operator >  (const KeyString & key) const
    {
    return (KStr > key.KStr);
    }

//-------------------------------------------------------
//  KeyByString
//      Identifies an object that can be key-identified 
//      by a string
//-------------------------------------------------------

class KeyByString
    {
    public:
        virtual KeyString MakeKey() const = 0;
    };

#endif

