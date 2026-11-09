////////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      hashfile.h
//
//      Defines a file type for disk-based data files that are
//      indexed via a hash table.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
////////////////////////////////////////////////////////////////

#ifndef HASHFILE_H
#define HASHFILE_H

#include "hash.h"
#include "datafile.h"

//-------------------------------------------------------------
//  HashFileEntry
//      An entry in a HashFileBucket
//-------------------------------------------------------------

struct HashFileEntry : public HashEntryStr,
                       public Persistent
    {
    DataFilePtr DataPtr;

    HashFileEntry(const KeyString & key, 
                        DataFilePtr ptr);

    HashFileEntry(const DataBlock & db);

    virtual operator DataBlock() const;

    private:
        static const Signature Sig;
    };

inline HashFileEntry::HashFileEntry(const KeyString & key, 
                                          DataFilePtr ptr)
    : HashEntryStr(key)
    {
    DataPtr = ptr;
    }

//-------------------------------------------------------------
//  HashFileBucket
//      A bucket for a HashFile
//-------------------------------------------------------------

class HashFileBucket : public HashBucket
    {
    public:
        Boolean WriteEntries(DataFileOutput & file) const;

        Boolean ReadEntries(const DataFileInput & file);

    private:
        static const Signature Sig;
        static const DataBlock EntryEnd;
    };

//-----------------------------------------------------------
//  HashEnumFuncStrDB
//      Function to retrieve all records in table
//-----------------------------------------------------------

typedef Boolean (* HashFileEnumFunc)(const KeyString & k,
                                     DataFilePtr ptr);

//-------------------------------------------------------------
//  HashFileTable
//      The type of HashTable used by HashFile
//-------------------------------------------------------------

class HashFileTable : protected HashTableBase
    {
    public:
        // constructor
        HashFileTable(size_t buckets);

        // insert new object
        Boolean Insert(const KeyString & key, DataFilePtr ptr);

        // delete an object
        Boolean Delete(const KeyString & key);

        // check for duplicate key
        Boolean IsDupeKey(const KeyString & key);

        // look up object
        DataFilePtr LookUp(const KeyString & key);

        // list all objects
        Boolean Enumerate(HashFileEnumFunc func);

    protected:
        // callback functions for Enumerate
        virtual Boolean TravCallback(const HashEntryBase * e) const;

        HashFileEnumFunc EnumCallback;
    };

inline HashFileTable::HashFileTable(size_t buckets)
    : HashTableBase(buckets)
    {
    // void
    }

//-------------------------------------------------------------
//  HashFile
//      A file storing data by key, using a hash table
//-------------------------------------------------------------

typedef KeyString (* ReHashFunc)(const DataBlock & db);

class HashFile : private HashFileTable,
                 private DataFile
    {
    public:
        // constructors
        // existing hash file
        HashFile(const String & basename, 
                       size_t   bufsize = 0);

        // new hash file
        HashFile(      size_t   buckets, 
                 const String & basename, 
                       size_t   bufsize = 0);

        // has file from data file
        HashFile(      size_t     buckets,
                       DataFile & file,
                 const String &   basename,
                       ReHashFunc getKey,
                       size_t     bufsize = 0);

        // copy constructor
        HashFile(const HashFile & hfile);

        // destructor
        ~HashFile();

        // write a record
        Boolean Write(const KeyString & key,
                      const DataBlock & db);

        // read a record
        DataBlock Read(const KeyString & key);

        // delete a record
        Boolean Delete(const KeyString & key);

        // commit data to disk
        Boolean Commit();

    private:
        // name of hash file
        String HashFileName;

        // extensions for hash file and data file
        static const String HashFileExt;
        static const String DataFileExt;

        static const Signature HashHdrSig;

        // create file name from base and extension
        static String MakeFileName(const String & basename,
                                   const String & ext);

        // get buckets from hash file
        size_t GetBuckets(const String & hashname);
    };

// commit data to disk
inline Boolean HashFile::Commit()
    {
    return DataFile::Commit();
    }

#endif
