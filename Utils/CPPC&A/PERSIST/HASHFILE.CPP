////////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      hashfile.cxx
//
//      Defines a file type for disk-based data files that are
//      indexed via a hash table.
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
////////////////////////////////////////////////////////////////

#include "hashfile.h"
#include "string.h"

//-------------------------------------------------------------
//  HashFileEntry
//      An entry in a HashFileBucket
//-------------------------------------------------------------

const Signature HashFileEntry::Sig = SYS_SIG_BASE + 4;

HashFileEntry::HashFileEntry(const DataBlock & db)
    {
    // check sinature
    if (db.GetSignature() != Sig)
        ReportError(HE_BADTYPES);

    // get pointer to data
    const char * ptr = (const char *)db.GetBufferPtr();

    // get file pointer
    DataPtr = *((const DataFilePtr *)ptr);

    // move to beginning of string
    ptr += sizeof(DataFilePtr);

    // create key string
    Key = KeyString(String(ptr));
    }

HashFileEntry::operator DataBlock() const
    {
    // get reference to string
    const String & keystr = Key.GetString();

    // calculate size of block
    size_t sz = sizeof(DataFilePtr) + keystr.Length() + 1;

    // allocate memory
    char * buf = new char [sz];

    if (buf == NULL)
        ReportError(HE_ALLOC);

    // store data ptr 
    *((DataFilePtr *)buf) = DataPtr;

    // store string
    strcpy(buf + sizeof(DataFilePtr),(const char *)keystr);

    // create data block
    DataBlock db(Sig,sz,buf);

    // delete buffer
    delete buf;

    return db;
    }

//-------------------------------------------------------------
//  HashFileBucket
//      A bucket for a HashFile
//-------------------------------------------------------------

const Signature HashFileBucket::Sig = SYS_SIG_BASE + 3;
static const int DummyData = 0;
const DataBlock HashFileBucket::EntryEnd(HashFileBucket::Sig,
                                         sizeof(DummyData),
                                         &DummyData);

Boolean HashFileBucket::WriteEntries(DataFileOutput & file) const
    {
    HashFileEntry * e = (HashFileEntry *)First;

    while (e != NULL)
        {
        if (BOOL_FALSE == file.Write(*e))
            return BOOL_FALSE;

        e = (HashFileEntry *)(e->Next);
        }

    file.Write(EntryEnd);

    return BOOL_TRUE;
    }

Boolean HashFileBucket::ReadEntries(const DataFileInput & file)
    {
    HashFileEntry * e = NULL;
    DataBlock db;

    for (;;)
        {
        db = file.Read();

        if (db.IsNull())
            return BOOL_FALSE;

        // NOTE: possibly store # of entries in size ?!?
        if ((Sig == db.GetSignature()) 
        &&  (sizeof(DummyData) == db.GetSizeOf()))
            break;

        e = new HashFileEntry(db);

        if (BOOL_FALSE == AddEntry(e))
            return BOOL_FALSE;
        }

    return BOOL_TRUE;
    }

//-------------------------------------------------------------
//  HashFileTable
//      The type of HashTable used by HashFile
//-------------------------------------------------------------

Boolean HashFileTable::Insert(const KeyString & key, DataFilePtr ptr)
    {
    // create new HashEntryStrDB
    HashFileEntry * entry = new HashFileEntry(key,ptr);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    // insert into table
    return AddEntry(entry);
    }

Boolean HashFileTable::Delete(const KeyString & key)
    {
    // create new HashEntryStr
    HashEntryStr * entry = new HashEntryStr(key);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    // insert into table
    return DelEntry(entry);
    }

Boolean HashFileTable::IsDupeKey(const KeyString & key)
    {
    // create new HashEntryStr
    HashEntryStr * entry = new HashEntryStr(key);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    // insert into table
    return IsDupe(entry);
    }

DataFilePtr HashFileTable::LookUp(const KeyString & key)
    {
    // create new HashEntryStr
    HashEntryStr * entry = new HashEntryStr(key);

    if (entry == NULL)
        ReportError(HE_ALLOC);

    const HashFileEntry * e = (const HashFileEntry *)FindEntry(entry);

    if (e == NULL)
        return DFP_ERROR;
    else
        return e->DataPtr;
    }

Boolean HashFileTable::Enumerate(HashFileEnumFunc func)
    {
    if (func == NULL)
        return BOOL_FALSE;

    EnumCallback = func;

    return Traverse();
    }

Boolean HashFileTable::TravCallback(const HashEntryBase * e) const
    {
    if (e == NULL)
        return BOOL_FALSE;
    else
        {
        HashFileEntry * e2 = (HashFileEntry *)e;

        return EnumCallback(e2->Key, e2->DataPtr);
        }
    }

//-------------------------------------------------------------
//  HashFile
//      A file storing data by key, using a hash table
//-------------------------------------------------------------

const String HashFile::HashFileExt(".HFH");
const String HashFile::DataFileExt(".HFD");

const Signature HashFile::HashHdrSig = SYS_SIG_BASE + 5;

// create file name from base and extension
String HashFile::MakeFileName(const String & basename, 
                              const String & ext)
    {
    String name;

    if (basename.Length() < 8)
        name = basename;
    else
        name = basename.CutHead(8);

    name += ext;

    return name;
    }

size_t HashFile::GetBuckets(const String & hashname)
    {
    DataFileInput * file = new DataFileInput(hashname);

    size_t result = 0;

    if (file != NULL)
        {
        DataBlock db = file->Read();

        if ((db.GetSignature() == HashHdrSig) 
        && (db.GetSizeOf() == sizeof(size_t)))
            result = *((size_t *)db.GetBufferPtr());
        }

    delete file;

    return result;
    }

// constructors
// existing hash file
HashFile::HashFile(const String & basename, 
                         size_t   bufsize)
    : DataFile(MakeFileName(basename,DataFileExt),FM_EXISTING,bufsize), 
      HashFileTable(GetBuckets(MakeFileName(basename,HashFileExt))),
      HashFileName(MakeFileName(basename,HashFileExt))
    {
    // read hash table
    DataFileInput * file = new DataFileInput(HashFileName);

    if (file == NULL)
        DataFileBase::ReportError("can't open input hash file");

    // ignore hash file header
    file->Skip();

    // get hash table entries
    Boolean result;

    for (size_t b = 0; b < NoOfBuckets; ++b)
        {
        // get bucket entries
        result = ((HashFileBucket *)Table[b])->ReadEntries(*file);

        if (result == BOOL_FALSE)
            DataFileBase::ReportError("can't read bucket entries");
        }

    delete file;
    }

// new hash file
HashFile::HashFile(      size_t   buckets, 
                   const String & basename, 
                         size_t   bufsize)
    : DataFile(MakeFileName(basename,DataFileExt),FM_NEW,bufsize), 
      HashFileTable(buckets),
      HashFileName(MakeFileName(basename,HashFileExt))
    {
    // void
    }

// has file from data file
HashFile::HashFile(      size_t     buckets, 
                         DataFile & file,
                   const String &   basename,
                         ReHashFunc getKey,
                         size_t     bufsize)
    : DataFile(MakeFileName(basename,DataFileExt),FM_NEW,bufsize),
      HashFileTable(buckets),
      HashFileName(MakeFileName(basename,HashFileExt))
    {
    if (getKey == NULL)
        DataFile::ReportError("invalid rehash function");

    file.Rewind();

    DataBlock db;

    for (;;)
        {
        // read record from original file
        db = file.Read();

        // assume a NULL block indicates end-of-input
        if (db.IsNull())
            break;

        // write record to HashFile
        Write(getKey(db),db);

        // Note: Duplicate keys will be lost in the conversion!
        //       Also, no error checking is done on Write,
        //       since it returns an error on duplicate keys
        }
    }

// destructor
HashFile::~HashFile()
    {
    // create hash output file
    DataFileOutput * file = new DataFileOutput(HashFileName);

    if (file == NULL)
        DataFileBase::ReportError("can't create output hash file");

    // save hash table
    Boolean result;

    // store # of buckets
    file->Write(DataBlock(HashHdrSig,sizeof(size_t),&NoOfBuckets));

    for (size_t b = 0; b < NoOfBuckets; ++b)
        {
        // write bucket entries
        result = ((HashFileBucket *)Table[b])->WriteEntries(*file);

        if (result == BOOL_FALSE)
            DataFileBase::ReportError("can't write bucket entries");
        }

    delete file;
    }

// write a record
Boolean HashFile::Write(const KeyString & key,
                        const DataBlock & db)
    {
    // check for (and delete) duplicate key
    if (IsDupeKey(key))
        {
        if (BOOL_FALSE == HashFile::Delete(key))
            return BOOL_FALSE;
        }

    // store data
    DataFilePtr ptr = DataFile::Write(db);

    if (ptr == DFP_ERROR)
        return BOOL_FALSE;

    // add key and pointer to hash table
    Boolean result = Insert(key,ptr);

    return result;
    }

// read a record
DataBlock HashFile::Read(const KeyString & key)
    {
    // get pointer to record via key in hash table
    DataFilePtr ptr = LookUp(key);

    if (ptr == DFP_ERROR)
        return NULL_BLOCK;

    // set file pointer
    if (BOOL_FALSE == DataFile::Seek(ptr))
        return NULL_BLOCK;

    // read record at pointer
    DataBlock db(DataFile::Read());

    return db;
    }

// delete a record
Boolean HashFile::Delete(const KeyString & key)
    {
    // get pointer to record via key lookup in hash table
    DataFilePtr ptr = LookUp(key);

    if (ptr == DFP_ERROR)
        return BOOL_FALSE;

    // set file pointer
    if (BOOL_FALSE == DataFile::Seek(ptr))
        return BOOL_FALSE;

    // delete record
    Boolean result = DataFile::Delete();

    if (result == BOOL_TRUE)
        {
        // delete key from hash table
        result = HashFileTable::Delete(key);
        }

    // done
    return result;
    }

