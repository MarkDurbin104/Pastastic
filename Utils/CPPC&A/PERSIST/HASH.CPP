///////////////////////////////////////////////////////////////
//  HASH TABLE LIBRARY
//      hash.cxx
//      
//      Defines the abstract base class for implementing a
//      hash table.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#include "hash.h"
#include "iostream.h"
#include "iomanip.h"
#include "stdlib.h"

//-----------------------------------------------------------
//  HashErrorBase
//      Base class providing error reporting for hash classes
//-----------------------------------------------------------

ErrReporter * HashErrorBase::ErrOut = NULL;

void HashErrorBase::ReportError(HashError herr)
    {
    if (ErrOut != NULL)
        {
        switch (herr)
            {
            case HE_ALLOC:
                ErrOut->Fatal("memory allocation failure");
                break;

            case HE_ZEROSIZE:
                ErrOut->Fatal("cannot create zero-size table");
                break;

            case HE_CORRUPTED:
                ErrOut->Fatal("corrupted");
                break;

            case HE_BADTYPES:
                ErrOut->Fatal("mismatched types");
                break;

            case HW_TOOSMALL:
                ErrOut->Warning("# buckets is very small");
                break;

            case HW_DUPEKEY:
                ErrOut->Warning("duplicate key ignored");
                break;

            default:
                ErrOut->Fatal("unknown");
                break;
            }
        }
    }

void HashErrorBase::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

//-----------------------------------------------------------
//  HashEntryStr
//      A HashEntry containing a KeyString
//-----------------------------------------------------------

HashKeyType HashEntryStr::GetKeyType() const
    {
    return KEY_STRING;
    }

size_t HashEntryStr::Hash(size_t buckets) const
    {
    unsigned long n = 0;
    const String & str = Key.GetString();
    size_t len = str.Length();

    for (size_t i = 0; i < len; ++i)
        {
        n <<= 1;
        n += str[i];
        }

    return size_t(n % (unsigned long)buckets);
    }

int HashEntryStr::KeyEquals(const HashEntryBase * e) const
    {
    if (KEY_STRING != e->GetKeyType())
        ReportError(HE_BADTYPES);

    return (Key == ((const HashEntryStr *)e)->Key);
    }

//-----------------------------------------------------------
//  HashTableBase
//      Base class for all hash tables
//-----------------------------------------------------------

HashTableBase::HashTableBase(size_t buckets)
    {
    // verify number of buckets
    if (buckets == 0)
        ReportError(HE_ZEROSIZE);

    if (buckets < 9)
        ReportError(HW_TOOSMALL);        

    // store number of buckets
    NoOfBuckets = buckets;

    // allocate Table
    Table = new HashBucket * [NoOfBuckets];

    if (Table == NULL)
        ReportError(HE_ALLOC);

    // assign empty buckets to table
    for (size_t b = 0; b < NoOfBuckets; ++b)
        {
        Table[b] = new HashBucket;

        if (Table[b] == NULL)
            ReportError(HE_ALLOC);
        }
    }

HashTableBase::~HashTableBase()
    {
    // delete buckets
    for (size_t b = 0; b < NoOfBuckets; ++b)
        delete Table[b];

    // delete table
    delete[] Table;
    }

Boolean HashTableBase::AddEntry(HashEntryBase * newe)
    {
    if (newe == NULL)
        return BOOL_FALSE;

    size_t bucket = newe->Hash(NoOfBuckets);

    return Table[bucket]->AddEntry(newe);
    }

Boolean HashTableBase::DelEntry(const HashEntryBase * dele)
    {
    if (dele == NULL)
        return BOOL_FALSE;

    size_t bucket = dele->Hash(NoOfBuckets);

    return Table[bucket]->DelEntry(dele);
    }

Boolean HashTableBase::IsDupe(const HashEntryBase * dupe)
    {
    if (dupe == NULL)
        return BOOL_FALSE;

    size_t bucket = dupe->Hash(NoOfBuckets);

    return Table[bucket]->IsDupe(dupe);
    }

const HashEntryBase * HashTableBase::FindEntry(const HashEntryBase * finde)
    {
    if (finde == NULL)
        return NULL;

    size_t bucket = finde->Hash(NoOfBuckets);

    return Table[bucket]->FindEntry(finde);
    }

Boolean HashTableBase::Traverse()
    {
    Boolean result;

    for (size_t n = 0; n < NoOfBuckets; ++n)
        {
        result = Table[n]->Traverse(*this,&HashTableBase::TravCallback);

        if (result == BOOL_FALSE)
            break;
        }

    return result;
    }

//-----------------------------------------------------------
//  HashBucket
//      Base class for buckets
//-----------------------------------------------------------

HashBucket::~HashBucket()
    {
    if (First != NULL)
        {
        HashEntryBase * e, * enext;

        e = First;

        while (e != NULL)
            {
            enext = e->Next;

            delete e;

            e = enext;
            }
       }
    }

Boolean HashBucket::AddEntry(HashEntryBase * newe)
    {
    if (newe == NULL)
        return BOOL_FALSE;

    if (First == NULL)
        First = newe;
    else
        {
        HashEntryBase * e = First;

        // search for last entry in list
        while (e != NULL)
            {
            // watch for duplicate keys
            if (e->KeyEquals(newe))
                {
                ReportError(HW_DUPEKEY);
                return BOOL_FALSE;
                }
        
            if (e->Next == NULL)
                {
                // link entry to end of list
                e->Next = newe; 
                newe->Prev = e; 

                break;
                }

            e = e->Next;
            }
        }

    return BOOL_TRUE;
    }

Boolean HashBucket::DelEntry(const HashEntryBase * dele)
    {
    if (dele == NULL)
        return BOOL_FALSE;

    HashEntryBase * e = First;

    // search for key in list
    while (e != NULL)
        {
        // if key found, delete it
        if (e->KeyEquals(dele))
            {
            if ((e->Prev == NULL) && (e->Next == NULL))
                First = NULL;
            else
                {                    
                // remove entry from list
                if (e->Prev == NULL)
                    First = e->Next;
                else
                    e->Prev->Next = e->Next;

                if (e->Next != NULL)
                    e->Next->Prev = e->Prev;
                }

            // delete entry
            delete e;

            // a success!
            return BOOL_TRUE;
            }

        e = e->Next;
        }

    return BOOL_FALSE;
    }

Boolean HashBucket::IsDupe(const HashEntryBase * dupe)
    {
    if ((dupe == NULL) || (First == NULL))
        return BOOL_FALSE;

    HashEntryBase * e = First;

    // search for key in list
    while (e != NULL)
        {
        // if key found, return it
        if (e->KeyEquals(dupe))
            return BOOL_TRUE;

        e = e->Next;
        }

    return BOOL_FALSE;
    }

const HashEntryBase * HashBucket::FindEntry(const HashEntryBase * finde)
    {
    if ((finde == NULL) || (First == NULL))
        return NULL;

    HashEntryBase * e = First;

    // search for key in list
    while (e != NULL)
        {
        // if key found, return it
        if (e->KeyEquals(finde))
            return e;

        e = e->Next;
        }

    return NULL;
    }

Boolean HashBucket::Traverse(const HashTableBase & table,
                             HashTravFunc func)
    {
    Boolean result;

    HashEntryBase * e = First;

    while (e != NULL)
        {
        result = (table.*func)(e);

        if (result == BOOL_FALSE)
            break;

        e = e->Next;
        }
        
    return result;
    }

//-----------------------------------------------------------
//  HashTableStrDB
//      Core class for hash tables
//-----------------------------------------------------------

Boolean HashTableStrDB::Insert(const KeyString & key, 
                               const DataBlock & data)
    {
    // create new HashEntryStrDB
    HashEntryStrDB * entry = new HashEntryStrDB(key,data);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    // insert into table
    return AddEntry(entry);
    }

Boolean HashTableStrDB::Delete(const KeyString & key)
    {
    // create new HashEntryStr
    HashEntryStr * entry = new HashEntryStr(key);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    // insert into table
    Boolean result = DelEntry(entry);

    delete entry;

    return result;
    }

DataBlock HashTableStrDB::LookUp(const KeyString & key)
    {
    // create new HashEntryStr
    HashEntryStr * entry = new HashEntryStr(key);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    const HashEntryStrDB * e = 
            (const HashEntryStrDB *)FindEntry(entry);

    delete entry;

    if (e == NULL)
        return NULL_BLOCK;
    else
        return e->Data;
    }

Boolean HashTableStrDB::Enumerate(HashEnumFuncStrDB func)
    {
    if (func == NULL)
        return BOOL_FALSE;

    EnumCallback = func;

    return Traverse();
    }

Boolean HashTableStrDB::TravCallback(const HashEntryBase * e) const
    {
    if (e == NULL)
        return BOOL_FALSE;
    else
        {
        HashEntryStrDB * e2 = (HashEntryStrDB *)e;

        return EnumCallback(e2->Key, e2->Data);
        }
    }
