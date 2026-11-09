///////////////////////////////////////////////////////////////
//  HASH TABLE LIBRARY
//      hash.h
//      
//      Defines the abstract base class for implementing a
//      hash table.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#ifndef HASH_H
#define HASH_H

#include "persist.h"

//-----------------------------------------------------------
//  HashErrorBase
//      Base class providing error reporting for hash classes
//-----------------------------------------------------------

enum HashError
    {
    HE_ALLOC,     // fatal:   memory allocation failure
    HE_ZEROSIZE,  // fatal:   created bucket w/ zero buckets
    HE_CORRUPTED, // fatal:   table / list has been corrupted
    HE_BADTYPES,  // fatal:   mismatched data types
    HW_TOOSMALL,  // warning: about very small table sizes
    HW_DUPEKEY    // warning: about duplicate keys
    };

class HashErrorBase
    {
    public:
        static void SetErrOut(const ErrReporter & er);

    protected:
        static ErrReporter * ErrOut;

        static void ReportError(HashError herr);
    };

//-----------------------------------------------------------
//  HashEntryBase
//      Base class for entries in buckets (linked lists)
//-----------------------------------------------------------

enum HashKeyType
    {
    KEY_STRING,
    KEY_LONG,
    KEY_OTHER1,
    KEY_OTHER2
    };

struct HashEntryBase : public HashErrorBase
    {
    HashEntryBase * Prev;
    HashEntryBase * Next;

    HashEntryBase();

    virtual HashKeyType GetKeyType() const = 0;

    virtual size_t Hash(size_t buckets) const = 0;

    virtual int KeyEquals(const HashEntryBase * entry) const = 0;
    };

inline HashEntryBase::HashEntryBase()
    {
    Prev = NULL;
    Next = NULL;
    }

//-----------------------------------------------------------
//  HashEntryStr
//      A HashEntry containing a KeyString
//-----------------------------------------------------------

struct HashEntryStr : public HashEntryBase
    {
    KeyString Key;

    HashEntryStr(const KeyString & k);
    HashEntryStr(const HashEntryStr & e);

    virtual HashKeyType GetKeyType() const;

    virtual size_t Hash(size_t buckets) const;

    virtual int KeyEquals(const HashEntryBase * entry) const;

    protected:
        HashEntryStr();        
    };

inline HashEntryStr::HashEntryStr()
    {
    // void
    }

inline HashEntryStr::HashEntryStr(const KeyString & k)
    : Key(k)
    {
    // void
    }

inline HashEntryStr::HashEntryStr(const HashEntryStr & e)
    : Key(e.Key)
    {
    // void
    }

//-----------------------------------------------------------
//  HashEntryStrDB
//      A HashEntry containing a KeyString and a DataBlock
//-----------------------------------------------------------

struct HashEntryStrDB : public HashEntryStr
    {
    DataBlock Data;

    HashEntryStrDB(const KeyString & k, const DataBlock & db);
    };

inline HashEntryStrDB::HashEntryStrDB(const KeyString & k, 
                                      const DataBlock & db)
    : HashEntryStr(k)
    {
    Data = db;
    }

//-----------------------------------------------------------
//  HashTableBase
//      Base class for all hash tables
//-----------------------------------------------------------

class HashBucket;

class HashTableBase : public HashErrorBase
    {
    public:
        HashTableBase(size_t buckets);
        ~HashTableBase();

    protected:
        Boolean AddEntry(HashEntryBase * newe);
        Boolean DelEntry(const HashEntryBase * dele);
        Boolean IsDupe(const HashEntryBase * dupe);

        const HashEntryBase * FindEntry(const HashEntryBase * finde);

        Boolean Traverse();

        virtual Boolean TravCallback(const HashEntryBase * e) const = 0; 

        // data elements
        size_t NoOfBuckets;

        HashBucket * * Table;
    };

//-----------------------------------------------------------
//  HashTravFunc
//      Function type used when traversing hash table entries
//-----------------------------------------------------------

typedef Boolean (HashTableBase::*HashTravFunc)(const HashEntryBase * e) const; 

//-----------------------------------------------------------
//  HashBucket
//      Base class for buckets
//-----------------------------------------------------------

class HashBucket : virtual public HashErrorBase
    {
    public:
        HashBucket();
        ~HashBucket();

        Boolean AddEntry(HashEntryBase * newe);
        Boolean DelEntry(const HashEntryBase * dele);
        Boolean IsDupe(const HashEntryBase * dupe);

        const HashEntryBase * FindEntry(const HashEntryBase * finde);

        Boolean Traverse(const HashTableBase & table,
                         HashTravFunc func);

    protected:
        HashEntryBase * First;
    };

inline HashBucket::HashBucket()
    {
    First = NULL;
    }

//-----------------------------------------------------------
//  HashEnumFuncStrDB
//      Function to retrieve all records in table
//-----------------------------------------------------------

typedef Boolean (* HashEnumFuncStrDB)(const KeyString & k,
                                      const DataBlock & db);

//-----------------------------------------------------------
//  HashTableStrDB
//      A HashTable indexed by Strings
//-----------------------------------------------------------

class HashTableStrDB : private HashTableBase
    {
    public:
        HashTableStrDB(size_t buckets);

        Boolean Insert(const KeyString & key, const DataBlock & db);
        Boolean Delete(const KeyString & key);

        DataBlock LookUp(const KeyString & key);

        Boolean Enumerate(HashEnumFuncStrDB func);

    protected:
        virtual Boolean TravCallback(const HashEntryBase * e) const; 

        HashEnumFuncStrDB EnumCallback;
    };

inline HashTableStrDB::HashTableStrDB(size_t buckets)
    : HashTableBase(buckets)
    {
    // void
    }

#endif
