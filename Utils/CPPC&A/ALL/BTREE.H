///////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      btree.h
//
//      A btree class for indexing.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#ifndef BTREE_H
#define BTREE_H

#include "datafile.h"

//-------------------------------------------------------------
//  BTreeErrorBase
//      Base class providing error reporting for BTree classes
//-------------------------------------------------------------

enum BTreeError
    {
    BTE_ALLOC,     // fatal: memory allocation failure
    BTE_TOOSMALL,  // fatal: created bucket w/ zero buckets
    BTE_CORRUPTED  // fatal: table / list has been corrupted
    };

class BTreeErrorBase
    {
    public:
        static void SetErrOut(const ErrReporter & er);

    protected:
        static ErrReporter * ErrOut;

        static void ReportError(BTreeError err);
    };

//----------------------------------------------------------
//  PageKey
//      A character string optimized for use with BTrees
//----------------------------------------------------------

class PageKey : public BTreeErrorBase
    {
    public:
        // constructors
        PageKey();
        PageKey(size_t maxlen, const char * str);
        PageKey(size_t maxlen, const String & str);
        PageKey(const PageKey & pgkey);

        // destructor
        ~PageKey();

        // assignment
        void operator = (const PageKey & pgkey);

        // interrogation
        size_t GetMax() const;
        size_t GetLen() const;

        // get pointer
        operator const char * () const;

        // is this an "empty" key?
        Boolean IsEmpty() const;

        // compare two keys
        int Compare(const PageKey & pgkey);

    private:
        char * Txt; // pointer to buffer containing text
        size_t Len; // number of characters in Txt
        size_t Max; // maximum # of characters in Txt
    };

// interrogation
inline size_t PageKey::GetMax() const
    {
    return Max;
    }

inline size_t PageKey::GetLen() const
    {
    return Len;
    }

// get pointer
inline PageKey::operator const char * () const
    {
    return Txt;
    }

// is this an "empty" key?
inline Boolean PageKey::IsEmpty() const
    {
    if (Txt == NULL)
        return BOOL_TRUE;
    else
        return BOOL_FALSE;
    }

//-------------------------------------------------------------
//  Page
//      A page in a BTree
//-------------------------------------------------------------

typedef long PageFilePtr;

struct PageHeader
    {
    PageFilePtr FilePtr;   // ptr to location in PageFile
    PageFilePtr ParentPtr; // ptr to parent in PageFile

    size_t      Order;     // maximum # of page links in page
    size_t      MaxKeys;   // maximum # of keys in page
    size_t      MinKeys;   // minimum # of keys in page
    size_t      NoOfKeys;  // actual  # of keys in page
    size_t      KeySize;   // maximum # of characters in a key
    };

struct Page : private BTreeErrorBase
    {
    PageHeader    Hdr; // header information
    PageKey     * Key; // key array [MaxKeys]
    DataFilePtr * Ptr; // rec  index array [MaxKeys]
    PageFilePtr * Lnk; // page index array [Order]

    // construct a new, empty page
    Page(size_t ord, size_t ksize);

    // construct a copy of a page
    Page(const Page & p);

    // destructor
    ~Page();

    // assignment operator
    void operator = (const Page & page);
    };

//----------------------------------------------------------
//  PageFile
//      A file that contains btree pages
//----------------------------------------------------------

extern const PageFilePtr PFP_NULL;

struct PageFileHdr
    {
    size_t KeySize;
    size_t Order;

    PageFilePtr RootPtr;
    PageFilePtr FirstDead;
    };

class PageFile : public DataFileBase
    {
    public:
        // use existing page file
        PageFile(const String & name);

        // create new page file
        PageFile(const String & name, 
                       size_t   ord, 
                       size_t   ksize);

        // destructor
        ~PageFile();

        // get root page
        Boolean ReadRoot(Page & pg);

        // write a page
        Boolean Write(Page & pg, Boolean root = BOOL_FALSE);

        // read a page
        Boolean Read(PageFilePtr ptr, Page & pg);

        // delete a page
        Boolean Delete(PageFilePtr ptr);

        // commit data & header
        Boolean Flush();

    private:
        // header record
        PageFileHdr Hdr;
    };

// destructor
inline PageFile::~PageFile()
    {
    Flush();
    }

// get root page
inline Boolean PageFile::ReadRoot(Page & pg)
    {
    return Read(Hdr.RootPtr, pg);
    }

//-------------------------------------------------------------
//  BTreeFile
//      A DataFile that uses a BTree for indexing
//-------------------------------------------------------------

typedef void (* BTreeEnumFunc)(const   PageKey & str,
                                  const DataBlock & db);

class BTreeFile : private BTreeErrorBase
    {
    public:
        // constructors
        // use existing files
        BTreeFile(const String & basename);

        // create new files
        BTreeFile(const String & basename,
                          size_t ord,
                          size_t ksize);

        // destructor
        ~BTreeFile();

        // write a record
        Boolean Write(const PageKey & key,
                      const DataBlock & db);

        // read a record
        DataBlock Read(const PageKey & key);

        // delete a record
        Boolean Delete(const PageKey & key);

        // enumerate all records
        Boolean InOrder(BTreeEnumFunc func);
        
    private:
        // data members
        DataFile * Data; // file containing DataBlocks
        PageFile * Tree; // file containing tree pages

        Boolean    Locked; // set to True during InOrder

        Page       Root; // root page (always in memory)

        String     DataFileName; // name of data file
        String     TreeFileName; // name of tree file

        BTreeEnumFunc EnumFunc; // function called by Traverse

        // search for a node
        Boolean Search(const    Page & pg, 
                       const PageKey & searchkey, 
                                Page & keypage,
                              size_t & pos);

        // insert node into leaf
        Boolean InsertKey(const PageKey & inskey,
                              DataFilePtr dataptr);

        // promote a key into a parent node
        Boolean PromoteInternal(         Page & pg,
                                const PageKey & inskey,
                                    DataFilePtr dataptr,
                                    PageFilePtr pagelnk);

        // promote a key by creating a new root
        Boolean PromoteRoot(const PageKey & inskey,
                              DataFilePtr   dataptr,
                                     Page & lesspage,
                                     Page & grtrpage);

        // adjust tree if leaf has shrunk in size
        Boolean AdjustTree(Page & leafpg);

        // redistribute keys among siblings and parent
        Boolean Redistribute(size_t keypos,
                             Page & lesspage,
                             Page & parpage,
                             Page & grtrpage);

        // concatenate sibling pages
        Boolean Concatenate(size_t keypos,
                            Page & lesspage,
                            Page & parpage,
                            Page & grtrpage);

        // recursive traversal function used by InOrder
        Boolean RecurseTraverse(const Page & pg);

        // file extensions for hash and data file
        static const String TreeFileExt;
        static const String DataFileExt;

        // create file name from base and extension
        static String MakeFileName(const String & basename,
                                   const String & ext);
    };

#endif
