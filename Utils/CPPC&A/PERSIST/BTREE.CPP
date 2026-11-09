///////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      btree.cxx
//
//      A btree class for indexing.
//
//      Copyright 1992 by Scott Robert Ladd
//      All rights reserved
///////////////////////////////////////////////////////////////

#include "btree.h"
#include "stdlib.h"
#include "string.h"

//-------------------------------------------------------------
//  BTreeErrorBase
//      Base class providing error reporting for BTree classes
//-------------------------------------------------------------

ErrReporter * BTreeErrorBase::ErrOut = NULL;

void BTreeErrorBase::ReportError(BTreeError err)
    {
    if (ErrOut != NULL)
        {
        switch (err)
            {
            case BTE_ALLOC:
                ErrOut->Fatal("memory allocation failure");
                break;

            case BTE_TOOSMALL:
                ErrOut->Fatal("cannot create zero-size table");
                break;

            case BTE_CORRUPTED:
                ErrOut->Fatal("corrupted");
                break;

            default:
                ErrOut->Fatal("unknown");
                break;
            }
        }
    }

void BTreeErrorBase::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);
    }

//----------------------------------------------------------
//  PageKey
//      A character string optimized for use with BTrees
//----------------------------------------------------------

// constructors
PageKey::PageKey()
    {
    Max = 0;
    Len = 0;
    Txt = NULL;
    }

PageKey::PageKey(size_t maxlen, const char * str)
    {
    Max = maxlen;

    // allocate buffer
    Txt = new char [Max];

    if (Txt == NULL)
        ReportError(BTE_ALLOC);

    // copy string
    strncpy(Txt,str,Max);
    
    // make sure there's a terminating NULL
    Txt[Max - 1] = 0;

    Len = strlen(Txt); 
    }

PageKey::PageKey(size_t maxlen, const String & str)
    {
    Max = maxlen;

    // allocate buffer
    Txt = new char [Max];

    if (Txt == NULL)
        ReportError(BTE_ALLOC);

    // copy string
    strncpy(Txt,(const char *)str,Max);
    
    // make sure there's a terminating NULL
    Txt[Max - 1] = 0;

    Len = strlen(Txt); 
    }

PageKey::PageKey(const PageKey & pgkey)
    {
    Max = pgkey.Max;
    Len = pgkey.Len;

    if (pgkey.Txt == NULL)
        Txt = NULL;
    else
        {
        // allocate buffer
        Txt = new char [Max];

        if (Txt == NULL)
            ReportError(BTE_ALLOC);

        // copy string
        strcpy(Txt,pgkey.Txt);
        }
    }

// destructor
PageKey::~PageKey()
    {
    if (Txt != NULL)
        delete [] Txt;
    }

// assignment
void PageKey::operator = (const PageKey & pgkey)
    {
    // delete existing buffer
    if (Txt != NULL)
        delete [] Txt;

    // assign values
    Max = pgkey.Max;
    Len = pgkey.Len;

    if (pgkey.Txt == NULL)
        Txt = NULL;
    else
        {
        // allocate buffer
        Txt = new char [Max];

        if (Txt == NULL)
            ReportError(BTE_ALLOC);

        // copy string
        strcpy(Txt,pgkey.Txt);
        }
    }

// compare two keys
int PageKey::Compare(const PageKey & pgkey)
    {
    return strcmp(Txt,pgkey.Txt);
    }

//-------------------------------------------------------------
//  Page
//      A page in a BTree
//-------------------------------------------------------------

// create a new page
Page::Page(size_t ord, size_t ksize)
    {
    size_t n;

    Hdr.FilePtr   = PFP_NULL;
    Hdr.ParentPtr = PFP_NULL;
    Hdr.Order     = ord;
    Hdr.MaxKeys   = ord - 1;
    Hdr.MinKeys   = ord / 2;
    Hdr.NoOfKeys  = 0;
    Hdr.KeySize   = ksize;

    if (Hdr.Order == 0)
        {
        Key = NULL;
        Ptr = NULL;
        Lnk = NULL;

        return;
        }

    // allocate key array
    Key = new PageKey [Hdr.MaxKeys];

    if (Key == NULL)
        ReportError(BTE_ALLOC);

    // allocate record pointer array
    Ptr = new DataFilePtr [Hdr.MaxKeys];

    if (Ptr == NULL)
        ReportError(BTE_ALLOC);

    // set pointers to nothing
    for (n = 0; n < Hdr.MaxKeys; ++n)
        Ptr[n] = DFP_ERROR;

    // allocate page pointer array
    Lnk = new PageFilePtr [Hdr.Order];

    if (Lnk == NULL)
        ReportError(BTE_ALLOC);

    /// fill page indexes with "empty" values
    for (n = 0; n < Hdr.Order; ++n)
        Lnk[n] = PFP_NULL;
    }

Page::Page(const Page & pg)
    {
    Hdr = pg.Hdr;

    // allocate key array
    Key = new PageKey [Hdr.MaxKeys];

    if (Key == NULL)
        ReportError(BTE_ALLOC);

    for (size_t n = 0; n < Hdr.MaxKeys; ++n)
        Key[n] = pg.Key[n];

    // allocate record pointer array
    Ptr = new DataFilePtr [Hdr.MaxKeys];

    if (Ptr == NULL)
        ReportError(BTE_ALLOC);

    memcpy(Ptr,pg.Ptr,
           Hdr.MaxKeys * sizeof(DataFilePtr));

    // allocate page pointer array
    Lnk = new PageFilePtr [Hdr.Order];

    if (Lnk == NULL)
        ReportError(BTE_ALLOC);

    // fill page indexes with source values
    memcpy(Lnk,pg.Lnk,
           Hdr.Order * sizeof(PageFilePtr));
    }

Page::~Page()
    {
    // delete old buffers
    delete [] Key;
    delete [] Ptr;
    delete [] Lnk;
    }

void Page::operator = (const Page & pg)
    {
    Hdr = pg.Hdr;

    // allocate key array
    if (Key != NULL)
        delete [] Key;

    Key = new PageKey [Hdr.MaxKeys];

    if (Key == NULL)
        ReportError(BTE_ALLOC);

    for (size_t n = 0; n < Hdr.MaxKeys; ++n)
        Key[n] = pg.Key[n];

    // allocate record pointer array
    if (Ptr != NULL)
        delete [] Ptr;

    Ptr = new DataFilePtr [Hdr.MaxKeys];

    if (Ptr == NULL)
        ReportError(BTE_ALLOC);

    memcpy(Ptr,pg.Ptr,
           Hdr.MaxKeys * sizeof(DataFilePtr));

    // allocate page pointer array
    if (Lnk != NULL)
        delete [] Lnk;

    Lnk = new PageFilePtr [Hdr.Order];

    if (Lnk == NULL)
        ReportError(BTE_ALLOC);

    // fill page indexes with source values
    memcpy(Lnk,pg.Lnk,Hdr.Order * sizeof(PageFilePtr));
    }

//----------------------------------------------------------
//  PageFile
//      A file that contains btree pages
//----------------------------------------------------------

const PageFilePtr PFP_NULL = -1;

// use existing page file
PageFile::PageFile(const String & name)
    : DataFileBase(name,FM_EXISTING)
    {
    size_t n;

    n = fread(&Hdr,sizeof(PageFileHdr),1,Data);

    if (n == 0)
        ReportError("unable to create header in new page file");
    }

// create new page file
PageFile::PageFile(const String & name, 
                         size_t   ord, 
                         size_t   ksize)
    : DataFileBase(name,FM_NEW)
    {
    Hdr.Order     = ord;
    Hdr.KeySize   = ksize;
    Hdr.RootPtr   = PFP_NULL;
    Hdr.FirstDead = PFP_NULL;

    size_t n = fwrite(&Hdr,sizeof(PageFileHdr),1,Data);

    if (n == 0)
        ReportError("unable to create header in new page file");

    // create Root page
    Page root(Hdr.Order,Hdr.KeySize);

    // store root
    Write(root);

    // save root address
    Hdr.RootPtr = root.Hdr.FilePtr;
    }

// write a page
Boolean PageFile::Write(Page & pg, Boolean root)
    {
    size_t n;
    int res;

    // confirm that this page belongs in this file
    if ((Hdr.Order   != pg.Hdr.Order) 
    ||  (Hdr.KeySize != pg.Hdr.KeySize))
        return BOOL_FALSE;

    // if this page has never been written
    // find a spot to write it
    if (pg.Hdr.FilePtr == PFP_NULL)
        {
        if (Hdr.FirstDead != PFP_NULL)
            {
            // write this record to first dead one in list
            pg.Hdr.FilePtr = Hdr.FirstDead;

            // find record where the new page will be written
            res = fseek(Data,Hdr.FirstDead,SEEK_SET);

            if (res)
                return BOOL_FALSE;

            // set first dead to next dead record in list
            n = fread(&Hdr.FirstDead,sizeof(PageFilePtr),1,Data);

            if (n == 0)
                return BOOL_FALSE;
            }
        else // append to end of file!
            {
            // look for end of file
            res = fseek(Data,0,SEEK_END);

            if (res)
                return BOOL_FALSE;

            // and get a pointer to it
            pg.Hdr.FilePtr = ftell(Data);
            }
        }

    // construct block of memory
    size_t keysize = (pg.Hdr.MaxKeys * Hdr.KeySize);
    size_t ptrsize = (pg.Hdr.MaxKeys * sizeof(DataFilePtr));
    size_t lnksize = (pg.Hdr.Order   * sizeof(PageFilePtr));

    size_t bufsize = sizeof(PageHeader)
                        + keysize + ptrsize + lnksize;

    char * buffer = new char [bufsize];

    if (buffer == NULL)
        return BOOL_FALSE;

    char * bufptr = buffer;

    // copy page header to buffer
    memcpy(bufptr,&pg.Hdr,sizeof(PageHeader));

    bufptr += sizeof(PageHeader);

    memset(bufptr,0,keysize);

    // copy keys to buffer
    for (n = 0; n < pg.Hdr.MaxKeys; ++n)
        {
        if (!pg.Key[n].IsEmpty())
            strcpy(bufptr,(const char *)(pg.Key[n]));

        bufptr += Hdr.KeySize;
        }

    // copy data record pointers
    memcpy(bufptr,pg.Ptr,ptrsize);

    bufptr += ptrsize;

    // copy page links
    memcpy(bufptr,pg.Lnk,lnksize);

    // write buffer to file
    res = fseek(Data,pg.Hdr.FilePtr,SEEK_SET);

    if (res)
        return BOOL_FALSE;

    n = fwrite(buffer,bufsize,1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // delete buffer
    delete [] buffer;

    // update root pointer in header, if this is a new root
    if (root)
        Hdr.RootPtr = pg.Hdr.FilePtr;

    // make sure header is current
    Flush();

    return BOOL_TRUE;
    }

// read a page
Boolean PageFile::Read(PageFilePtr ptr, Page & pg)
    {
    size_t n;
    int    res;

    // locate requested record
    res = fseek(Data,ptr,SEEK_SET);

    if (res)
        return BOOL_FALSE;

    // create a blank page
    Page temp(Hdr.Order,Hdr.KeySize);

    n = fread(&temp.Hdr,sizeof(PageHeader),1,Data);

    // be sure that this header matches the expected values
    if ((n == 0)
    ||  (temp.Hdr.Order   != Hdr.Order)
    ||  (temp.Hdr.KeySize != Hdr.KeySize)
    ||  (temp.Hdr.FilePtr != ptr))
        return BOOL_FALSE;

    // allocate a buffer to hold incoming keys
    size_t bufsize = temp.Hdr.KeySize * temp.Hdr.MaxKeys;

    char * buffer = new char [bufsize];

    if (buffer == NULL)
        return BOOL_FALSE;

    // read keys from file
    n = fread(buffer,bufsize,1,Data);

    if (n == 0)
        return BOOL_FALSE;

    char * bufptr = buffer;

    // move keys into page
    for (n = 0; n < temp.Hdr.MaxKeys; ++n)
        {
        if (*bufptr == 0)
            temp.Key[n] = PageKey();
        else
            temp.Key[n] = PageKey(temp.Hdr.KeySize,bufptr);

        bufptr += temp.Hdr.KeySize;
        }

    // read data record pointers
    n = fread(temp.Ptr,temp.Hdr.MaxKeys * sizeof(DataFilePtr),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // read page links
    n = fread(temp.Lnk,temp.Hdr.Order * sizeof(PageFilePtr),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    pg = temp;

    return BOOL_TRUE;
    }

// delete a page
Boolean PageFile::Delete(PageFilePtr ptr)
    {
    // locate record to be deleted
    int res = fseek(Data,ptr,SEEK_SET);

    if (res)
        return BOOL_FALSE;

    // stored the previous head of the deleted list
    size_t n = fwrite(&Hdr.FirstDead,sizeof(PageFilePtr),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // update header
    Hdr.FirstDead = ptr;

    Flush();

    return BOOL_TRUE;
    }

// commit data & header
Boolean PageFile::Flush()
    {
    // rewrite header
    rewind(Data);

    size_t n = fwrite(&Hdr,sizeof(PageFileHdr),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // empty any buffers
    fflush(Data);

    return BOOL_TRUE;
    }

//-------------------------------------------------------------
//  BTreeFile
//      A DataFile that uses a BTree for indexing
//-------------------------------------------------------------

// initialization of static class constants
const String BTreeFile::TreeFileExt(".BFT");
const String BTreeFile::DataFileExt(".BFD");

// use existing files
BTreeFile::BTreeFile(const String & basename)
    : DataFileName(MakeFileName(basename,DataFileExt)),
      TreeFileName(MakeFileName(basename,TreeFileExt)),
      Root(0,0)
    {
    // create data file object
    Data = new DataFile(DataFileName,FM_EXISTING);

    if (Data == NULL)
        ReportError(BTE_ALLOC);

    // create tree file object
    Tree = new PageFile(TreeFileName);

    if (Tree == NULL)
        ReportError(BTE_ALLOC);

    // create root page
    Boolean result = Tree->ReadRoot(Root);

    if (result == NULL)
        ReportError(BTE_CORRUPTED);

    Locked = BOOL_FALSE;
    }

// create new files
BTreeFile::BTreeFile(const String & basename,
                             size_t ord,
                             size_t ksize)
    : DataFileName(MakeFileName(basename,DataFileExt)),
      TreeFileName(MakeFileName(basename,TreeFileExt)),
      Root(0,0)
    {
    // create data file object
    Data = new DataFile(DataFileName,FM_NEW);

    if (Data == NULL)
        ReportError(BTE_ALLOC);

    // create tree file object
    Tree = new PageFile(TreeFileName,ord,ksize);

    if (Tree == NULL)
        ReportError(BTE_ALLOC);

    // create root page
    Boolean result = Tree->ReadRoot(Root);

    if (result == NULL)
        ReportError(BTE_ALLOC);

    Locked = BOOL_FALSE;
    }

// destructor
BTreeFile::~BTreeFile()
    {
    // delete files
    delete Data;
    delete Tree;
    }

// write a record
Boolean BTreeFile::Write(const PageKey & key,
                         const DataBlock & db)
    {
    if (Locked)
        return BOOL_FALSE;

    // write the data record
    DataFilePtr dataptr = Data->Write(db);

    if (dataptr == DFP_ERROR)
        return BOOL_FALSE;

    // store the key in a page
    return InsertKey(key,dataptr);
    }

// read a record
DataBlock BTreeFile::Read(const PageKey & key)
    {
    if (Locked)
        return NULL_BLOCK;

    Page   inspage(0,0);
    size_t inspos;

    Boolean result = Search(Root,key,inspage,inspos);

    if (result == BOOL_TRUE)
        {
        // seek data record
        Data->Seek(inspage.Ptr[inspos]);

        // read data record
        return Data->Read();
        }
    else
        return NULL_BLOCK;
    }

// delete a record
Boolean BTreeFile::Delete(const PageKey & delkey)
    {
    if (Locked)
        return BOOL_FALSE;

    Page   delpage(0,0);
    size_t delpos;

    Boolean found = Search(Root,delkey,delpage,delpos);

    if (!found)
        return BOOL_FALSE;

    // delete data record associated with deleted key
    Data->Seek(delpage.Ptr[delpos]);

    Data->Delete();

    if (delpage.Lnk[0] == PFP_NULL) // is this a leaf page?
        {
        // remove key from leaf
        --delpage.Hdr.NoOfKeys;

        for (size_t n = delpos; n < delpage.Hdr.NoOfKeys; ++n)
            {
            delpage.Key[n] = delpage.Key[n + 1];
            delpage.Ptr[n] = delpage.Ptr[n + 1];
            }

        delpage.Key[delpage.Hdr.NoOfKeys] = PageKey();
        delpage.Ptr[delpage.Hdr.NoOfKeys] = DFP_MARKER;

        // write page to disk
        if (BOOL_FALSE == Tree->Write(delpage))
            return BOOL_FALSE;

        // adjust tree
        if (delpage.Hdr.NoOfKeys < delpage.Hdr.MinKeys)
            return AdjustTree(delpage);

        }
    else // delpage is internal
        {
        // replace deleted key with immediate successor
        Page sucpage(0,0);

        // find successor
        if (BOOL_FALSE == Tree->Read(delpage.Lnk[delpos + 1],sucpage))
            return BOOL_FALSE;

        while (sucpage.Lnk[0] != PFP_NULL)
            {
            if (BOOL_FALSE == Tree->Read(sucpage.Lnk[0],sucpage))
                return BOOL_FALSE;
            }

        // first key is the "swappee"
        delpage.Key[delpos] = sucpage.Key[0];
        delpage.Ptr[delpos] = sucpage.Ptr[0];

        // deleted swapped key from sucpage
        --sucpage.Hdr.NoOfKeys;

        for (size_t n = 0; n < sucpage.Hdr.NoOfKeys; ++n)
            {
            sucpage.Key[n] = sucpage.Key[n + 1];
            sucpage.Ptr[n] = sucpage.Ptr[n + 1];
            sucpage.Lnk[n + 1] = sucpage.Lnk[n + 2];
            }

        sucpage.Key[sucpage.Hdr.NoOfKeys] = PageKey();
        sucpage.Ptr[sucpage.Hdr.NoOfKeys] = DFP_MARKER;
        sucpage.Lnk[sucpage.Hdr.NoOfKeys + 1] = PFP_NULL;

        // write pages to disk
        if (BOOL_FALSE == Tree->Write(delpage))
            return BOOL_FALSE;

        if (BOOL_FALSE == Tree->Write(sucpage))
            return BOOL_FALSE;
       
        // adjust tree for leaf node
        if (sucpage.Hdr.NoOfKeys < sucpage.Hdr.MinKeys)
            return AdjustTree(sucpage);
        }

    return BOOL_TRUE;
    }

// enumerate all records
Boolean BTreeFile::InOrder(BTreeEnumFunc func)
    {
    // lock the file so changes can't be made
    Locked = BOOL_TRUE;

    // save the address of the function to call
    EnumFunc = func;

    // recurse the tree
    Boolean result = RecurseTraverse(Root);

    // unlock the file
    Locked = BOOL_FALSE;

    return result;
    }

// search for a node
Boolean BTreeFile::Search(const    Page & pg,
                          const PageKey & searchkey,
                                   Page & keypage,
                                 size_t & pos)
    {
    Boolean result;

    pos = 0;

    int comp;

    for (;;)
        {
        if (pos == pg.Hdr.NoOfKeys)
            {
            result = BOOL_FALSE;
            goto getpage;
            }

        comp = pg.Key[pos].Compare(searchkey);

        if (comp == 0)
            {
            keypage = pg;
            result  = BOOL_TRUE;
            break;
            }
        else
            {
            if (comp < 0)
                {
                ++pos;
                }
            else
                {
                // I know this is a label -- so shoot me!
                getpage:

                // if we're in a leaf page, key wasn't found
                if (pg.Lnk[pos] == PFP_NULL)
                    {
                    keypage = pg;
                    result  = BOOL_FALSE;
                    }
                else
                    {
                    // dynamically allocate to save stack space
                    Page nextpg(pg.Hdr.Order,
                                pg.Hdr.KeySize);

                    result = Tree->Read(pg.Lnk[pos],nextpg);

                    if (result)
                        {
                        // recursively search new page
                        result = Search(nextpg,searchkey,keypage,pos);
                        }
                    }

                break;
                }
            }
        }

    return result;
    }

Boolean BTreeFile::InsertKey(const PageKey & inskey,
                                 DataFilePtr dataptr)
    {
    Page   inspage(0,0);
    size_t inspos;

    Boolean found = Search(Root,inskey,inspage,inspos);

    if (found)
        {
        // delete old data record
        Data->Seek(inspage.Ptr[inspos]);

        Data->Delete();

        // store new data record pointer
        inspage.Ptr[inspos] = dataptr;

        // rewrite modified page
        if (BOOL_FALSE == Tree->Write(inspage))
            return BOOL_FALSE;
        }
    else
        {
        if (inspage.Hdr.NoOfKeys == inspage.Hdr.MaxKeys)
            {
            // temporary arrays
            PageKey     * tempkeys = new PageKey[inspage.Hdr.MaxKeys + 1];
            DataFilePtr * tempptrs = new DataFilePtr[inspage.Hdr.MaxKeys + 1];

            // copy entries from inspage to temporaries
            size_t nt = 0; // index into temporaries
            size_t ni = 0; // index into inspage

            tempkeys[inspos] = PageKey(inskey);
            tempptrs[inspos] = dataptr;

            while (ni < inspage.Hdr.MaxKeys)
                {
                if (ni == inspos)
                    ++nt;

                tempkeys[nt] = inspage.Key[ni];
                tempptrs[nt] = inspage.Ptr[ni];

                ++ni;
                ++nt;
                }

            // generate a new leaf node
            Page sibpage(inspage.Hdr.Order,inspage.Hdr.KeySize);

            sibpage.Hdr.ParentPtr = inspage.Hdr.ParentPtr;

            // clear # of keys in pages
            inspage.Hdr.NoOfKeys = 0;
            sibpage.Hdr.NoOfKeys = 0;

            // copy appropriate keys from temp to pages
            for (ni = 0; ni < inspage.Hdr.MinKeys; ++ni)
                {
                inspage.Key[ni] = tempkeys[ni];
                inspage.Ptr[ni] = tempptrs[ni];

                ++inspage.Hdr.NoOfKeys;
                }

            for (ni = inspage.Hdr.MinKeys + 1; ni <= inspage.Hdr.MaxKeys; ++ni)
                {
                sibpage.Key[ni - 1 - inspage.Hdr.MinKeys] = tempkeys[ni];
                sibpage.Ptr[ni - 1 - inspage.Hdr.MinKeys] = tempptrs[ni];

                ++sibpage.Hdr.NoOfKeys;
                }

            // Fill any remaining entries in inspage with null.
            // Note that sibpage is initialized to null values
            // by the constructor.

            for (ni = inspage.Hdr.MinKeys; ni < inspage.Hdr.MaxKeys; ++ni)
                {
                inspage.Key[ni] = PageKey();
                inspage.Ptr[ni] = DFP_MARKER;
                }

            // write pages
            if (BOOL_FALSE == Tree->Write(inspage))
                return BOOL_FALSE;

            if (BOOL_FALSE == Tree->Write(sibpage))
                return BOOL_FALSE;

            // promote key and pointer
            if (inspage.Hdr.ParentPtr == PFP_NULL)
                {
                // we need to create a new root
                PromoteRoot(tempkeys[inspage.Hdr.MinKeys],
                            tempptrs[inspage.Hdr.MinKeys],
                            inspage,
                            sibpage);
                }
            else
                {
                Page parpage(0,0);

                if (BOOL_FALSE == Tree->Read(inspage.Hdr.ParentPtr,parpage))
                    return BOOL_FALSE;

                // promote into parent
                PromoteInternal(parpage,
                                tempkeys[inspage.Hdr.MinKeys],
                                tempptrs[inspage.Hdr.MinKeys],
                                sibpage.Hdr.FilePtr);
                }

            delete [] tempkeys;
            delete [] tempptrs;
            }
        else // simply insert new key and data ptr
            {
            for (size_t n = inspage.Hdr.NoOfKeys; n > inspos; --n)
                {
                inspage.Key[n] = inspage.Key[n - 1];
                inspage.Ptr[n] = inspage.Ptr[n - 1];
                }

            inspage.Key[inspos] = inskey;
            inspage.Ptr[inspos] = dataptr;

            ++inspage.Hdr.NoOfKeys;

            if (BOOL_FALSE == Tree->Write(inspage))
                return BOOL_FALSE;
            }
        }

    // refresh root in memory
    return Tree->ReadRoot(Root);
    }

Boolean BTreeFile::PromoteInternal(         Page & inspage,
                                   const PageKey & inskey,
                                       DataFilePtr dataptr,
                                       PageFilePtr pagelnk)
    {
    if (inspage.Hdr.NoOfKeys == inspage.Hdr.MaxKeys)
        {
        // temporary arrays
        PageKey     * tempkeys = new PageKey[inspage.Hdr.MaxKeys + 1];
        DataFilePtr * tempptrs = new DataFilePtr[inspage.Hdr.MaxKeys + 1];
        PageFilePtr * templnks = new PageFilePtr[inspage.Hdr.Order   + 1];

        // copy entries from inspage to temporaries
        size_t nt = 0; // index into temporaries
        size_t ni = 0; // index into inspage

        templnks[0] = inspage.Lnk[0];

        size_t inspos = 0;

        // find insertion position
        while ((inspos < inspage.Hdr.MaxKeys) 
          && (inspage.Key[inspos].Compare(inskey) < 0))
            {
            ++inspos;
            }

        // store new info
        tempkeys[inspos]     = PageKey(inskey);
        tempptrs[inspos]     = dataptr;
        templnks[inspos + 1] = pagelnk;

        // copy existing keys
        while (ni < inspage.Hdr.MaxKeys)
            {
            if (ni == inspos)
                ++nt;

            tempkeys[nt]     = inspage.Key[ni];
            tempptrs[nt]     = inspage.Ptr[ni];
            templnks[nt + 1] = inspage.Lnk[ni + 1];

            ++ni;
            ++nt;
            }

        // generate a new leaf node
        Page sibpage(inspage.Hdr.Order,inspage.Hdr.KeySize);

        sibpage.Hdr.ParentPtr = inspage.Hdr.ParentPtr;

        // clear # of keys in pages
        inspage.Hdr.NoOfKeys = 0;
        sibpage.Hdr.NoOfKeys = 0;

        inspage.Lnk[0] = templnks[0];

        // copy appropriate keys from temp to pages
        for (ni = 0; ni < inspage.Hdr.MinKeys; ++ni)
            {
            inspage.Key[ni]     = tempkeys[ni];
            inspage.Ptr[ni]     = tempptrs[ni];
            inspage.Lnk[ni + 1] = templnks[ni + 1];

            ++inspage.Hdr.NoOfKeys;
            }

        sibpage.Lnk[0] = templnks[inspage.Hdr.MinKeys + 1];

        for (ni = inspage.Hdr.MinKeys + 1; ni <= inspage.Hdr.MaxKeys; ++ni)
            {
            sibpage.Key[ni - 1 - inspage.Hdr.MinKeys] = tempkeys[ni];
            sibpage.Ptr[ni - 1 - inspage.Hdr.MinKeys] = tempptrs[ni];
            sibpage.Lnk[ni - inspage.Hdr.MinKeys]     = templnks[ni + 1];

            ++sibpage.Hdr.NoOfKeys;
            }

        // Fill any remaining entries in inspage with null.
        // Note that sibpage is initialized to null values
        // by the constructor.

        for (ni = inspage.Hdr.MinKeys; ni < inspage.Hdr.MaxKeys; ++ni)
            {
            inspage.Key[ni]     = PageKey();
            inspage.Ptr[ni]     = DFP_MARKER;
            inspage.Lnk[ni + 1] = PFP_NULL;
            }

        // write pages
        if (BOOL_FALSE == Tree->Write(inspage))
            return BOOL_FALSE;

        if (BOOL_FALSE == Tree->Write(sibpage))
            return BOOL_FALSE;

        // update child parent links
        Page child(0,0);

        for (ni = 0; ni <= sibpage.Hdr.NoOfKeys; ++ni)
            {
            if (BOOL_FALSE == Tree->Read(sibpage.Lnk[ni],child))
                return BOOL_FALSE;

            child.Hdr.ParentPtr = sibpage.Hdr.FilePtr;

            if (BOOL_FALSE == Tree->Write(child))
                return BOOL_FALSE;
            }

        // promote key and pointer
        if (inspage.Hdr.ParentPtr == PFP_NULL)
            {
            // we need to create a new root
            PromoteRoot(tempkeys[inspage.Hdr.MinKeys],
                        tempptrs[inspage.Hdr.MinKeys],
                        inspage,
                        sibpage);
            }
        else
            {
            Page parpage(0,0);

            if (BOOL_FALSE == Tree->Read(inspage.Hdr.ParentPtr,parpage))
                return BOOL_FALSE;

            // promote into parent
            PromoteInternal(parpage,
                            tempkeys[inspage.Hdr.MinKeys],
                            tempptrs[inspage.Hdr.MinKeys],
                            sibpage.Hdr.FilePtr);
            }

        delete [] tempkeys;
        delete [] tempptrs;
        delete [] templnks;
        }
    else // simply insert new key and data ptr
        {
        size_t inspos = 0;

        // find insertion position
        while ((inspos < inspage.Hdr.NoOfKeys) 
          && (inspage.Key[inspos].Compare(inskey) < 0))
            {
            ++inspos;
            }

        // shift any keys right
        for (size_t n = inspage.Hdr.NoOfKeys; n > inspos; --n)
            {
            inspage.Key[n]     = inspage.Key[n - 1];
            inspage.Ptr[n]     = inspage.Ptr[n - 1];
            inspage.Lnk[n + 1] = inspage.Lnk[n];
            }

        // store new info
        inspage.Key[inspos]     = PageKey(inskey);
        inspage.Ptr[inspos]     = dataptr;
        inspage.Lnk[inspos + 1] = pagelnk;

        ++inspage.Hdr.NoOfKeys;

        if (BOOL_FALSE == Tree->Write(inspage))
            return BOOL_FALSE;
        }

    return BOOL_TRUE;
    }

Boolean BTreeFile::PromoteRoot(const PageKey & inskey,
                                 DataFilePtr   dataptr,
                                        Page & lesspage,
                                        Page & grtrpage)
    {
    // create new root page
    Page newroot(Root.Hdr.Order,Root.Hdr.KeySize);

    // insert key into new root
    newroot.Key[0] = inskey;
    newroot.Ptr[0] = dataptr;

    newroot.Lnk[0] = lesspage.Hdr.FilePtr;
    newroot.Lnk[1] = grtrpage.Hdr.FilePtr;

    newroot.Hdr.NoOfKeys = 1;

    // write new root to tree file
    if (Tree->Write(newroot,BOOL_TRUE))
        {
        lesspage.Hdr.ParentPtr = newroot.Hdr.FilePtr;
        grtrpage.Hdr.ParentPtr = newroot.Hdr.FilePtr;

        // rewrite pages
        if (Tree->Write(lesspage))
            return Tree->Write(grtrpage);
        }

    return BOOL_FALSE;
    }

Boolean BTreeFile::AdjustTree(Page & pg)
    {
    if (pg.Hdr.ParentPtr == PFP_NULL)
        return BOOL_TRUE;

    Page parpage(0,0);
    Page sibless(0,0);
    Page sibgrtr(0,0);

    // get parent page
    if (BOOL_FALSE == Tree->Read(pg.Hdr.ParentPtr,parpage))
        return BOOL_FALSE;

    // find pointer to pg in parent
    for (size_t n = 0; parpage.Lnk[n] != pg.Hdr.FilePtr; ++n)
        ;

    // read sibling pages
    if (n < parpage.Hdr.NoOfKeys)
        {
        if (BOOL_FALSE == Tree->Read(parpage.Lnk[n + 1],sibgrtr))
            return BOOL_FALSE;
        }

    if (n > 0)
        {
        if (BOOL_FALSE == Tree->Read(parpage.Lnk[n - 1],sibless))
            return BOOL_FALSE;
        }

    // decide to redistribute or concatenate
    if (sibless.Hdr.NoOfKeys > sibgrtr.Hdr.NoOfKeys)
        {
        --n;

        if (sibless.Hdr.NoOfKeys > sibless.Hdr.MinKeys)
            return Redistribute(n,sibless,parpage,pg);
        else
            return Concatenate(n,sibless,parpage,pg);
        }
    else
        {
        if (sibgrtr.Hdr.NoOfKeys > sibgrtr.Hdr.MinKeys)
            return Redistribute(n,pg,parpage,sibgrtr);
        else
            return Concatenate(n,pg,parpage,sibgrtr);
        }
    }

Boolean BTreeFile::Redistribute(size_t keypos,
                                Page & lesspage,
                                Page & parpage,
                                Page & grtrpage)
    {
    // note: this function is ONLY called for leaf nodes!
    size_t n;
    
    if (lesspage.Lnk[0] == PFP_NULL) // working with leaves
        {
        if (lesspage.Hdr.NoOfKeys > grtrpage.Hdr.NoOfKeys)
            {
            // slide a key from lesser to greater
            // move keys in greater to the left by one
            for (n = grtrpage.Hdr.NoOfKeys; n > 0; --n)
                {
                grtrpage.Key[n] = grtrpage.Key[n - 1];
                grtrpage.Ptr[n] = grtrpage.Ptr[n - 1];
                }
    
            // store parent separator key in greater page
            grtrpage.Key[0] = parpage.Key[keypos];
            grtrpage.Ptr[0] = parpage.Ptr[keypos];
    
            // increment greater page's key count
            ++grtrpage.Hdr.NoOfKeys;
    
            // decrement lessor page's key count
            --lesspage.Hdr.NoOfKeys;
    
            // move last key in less page to parent as separator
            parpage.Key[keypos] = lesspage.Key[lesspage.Hdr.NoOfKeys];
            parpage.Ptr[keypos] = lesspage.Ptr[lesspage.Hdr.NoOfKeys];
    
            // clear last key in less page
            lesspage.Key[lesspage.Hdr.NoOfKeys] = PageKey();
            lesspage.Ptr[lesspage.Hdr.NoOfKeys] = DFP_MARKER;
            }
        else
            {
            // slide a key from greater to lessor
            // add parent key to lessor page
            lesspage.Key[lesspage.Hdr.NoOfKeys] = parpage.Key[keypos];
            lesspage.Ptr[lesspage.Hdr.NoOfKeys] = parpage.Ptr[keypos];
    
            // increment lessor page's key count
            ++lesspage.Hdr.NoOfKeys;
    
            // insert in parent the lowest key in greater page
            parpage.Key[keypos] = grtrpage.Key[0];
            parpage.Ptr[keypos] = grtrpage.Ptr[0];
    
            // decrement # of keys in greater page
            --grtrpage.Hdr.NoOfKeys;
    
            // move keys in greater page to left
            for (n = 0; n < grtrpage.Hdr.NoOfKeys; ++n)
                {
                grtrpage.Key[n] = grtrpage.Key[n + 1];
                grtrpage.Ptr[n] = grtrpage.Ptr[n + 1];
                }
    
            // make last key blank
            grtrpage.Key[n]    = PageKey();
            grtrpage.Ptr[n]    = DFP_MARKER;
            }
        }
    else
        {
        if (lesspage.Hdr.NoOfKeys > grtrpage.Hdr.NoOfKeys)
            {
            // slide a key from lesser to greater
            // move keys in greater to the left by one
            for (n = grtrpage.Hdr.NoOfKeys; n > 0; --n)
                {
                grtrpage.Key[n] = grtrpage.Key[n - 1];
                grtrpage.Ptr[n] = grtrpage.Ptr[n - 1];
                grtrpage.Lnk[n + 1] = grtrpage.Lnk[n];
                }

            grtrpage.Lnk[1] = grtrpage.Lnk[0];
    
            // store parent separator key in greater page
            grtrpage.Key[0] = parpage.Key[keypos];
            grtrpage.Ptr[0] = parpage.Ptr[keypos];
            grtrpage.Lnk[0] = lesspage.Lnk[lesspage.Hdr.NoOfKeys];

            // update child link
            Page child(0,0);

            if (BOOL_FALSE == Tree->Read(grtrpage.Lnk[0],child))
                return BOOL_FALSE;

            child.Hdr.ParentPtr = grtrpage.Hdr.FilePtr;

            if (BOOL_FALSE == Tree->Write(child))
                return BOOL_FALSE;
    
            // increment greater page's key count
            ++grtrpage.Hdr.NoOfKeys;
    
            // decrement lessor page's key count
            --lesspage.Hdr.NoOfKeys;
    
            // move last key in less page to parent as separator
            parpage.Key[keypos] = lesspage.Key[lesspage.Hdr.NoOfKeys];
            parpage.Ptr[keypos] = lesspage.Ptr[lesspage.Hdr.NoOfKeys];
    
            // clear last key in less page
            lesspage.Key[lesspage.Hdr.NoOfKeys] = PageKey();
            lesspage.Ptr[lesspage.Hdr.NoOfKeys] = DFP_MARKER;
            lesspage.Lnk[lesspage.Hdr.NoOfKeys + 1] = PFP_NULL;
            }
        else
            {
            // slide a key from greater to lessor
            // add parent key to lessor page
            lesspage.Key[lesspage.Hdr.NoOfKeys] = parpage.Key[keypos];
            lesspage.Ptr[lesspage.Hdr.NoOfKeys] = parpage.Ptr[keypos];
            lesspage.Lnk[lesspage.Hdr.NoOfKeys + 1] = grtrpage.Lnk[0];
    
            // update child link
            Page child(0,0);

            if (BOOL_FALSE == Tree->Read(grtrpage.Lnk[0],child))
                return BOOL_FALSE;

            child.Hdr.ParentPtr = lesspage.Hdr.FilePtr;

            if (BOOL_FALSE == Tree->Write(child))
                return BOOL_FALSE;
    
            // increment lessor page's key count
            ++lesspage.Hdr.NoOfKeys;
    
            // insert in parent the lowest key in greater page
            parpage.Key[keypos] = grtrpage.Key[0];
            parpage.Ptr[keypos] = grtrpage.Ptr[0];
    
            // decrement # of keys in greater page
            --grtrpage.Hdr.NoOfKeys;
    
            // move keys in greater page to left
            for (n = 0; n < grtrpage.Hdr.NoOfKeys; ++n)
                {
                grtrpage.Key[n] = grtrpage.Key[n + 1];
                grtrpage.Ptr[n] = grtrpage.Ptr[n + 1];
                grtrpage.Lnk[n] = grtrpage.Lnk[n + 1];
                }

            grtrpage.Lnk[n] = grtrpage.Lnk[n + 1];
    
            // make last key blank
            grtrpage.Key[n]     = PageKey();
            grtrpage.Ptr[n]     = DFP_MARKER;
            grtrpage.Lnk[n + 1] = PFP_NULL;
            }
        }

    // write pages
    if (Tree->Write(lesspage))
        {
        if (Tree->Write(parpage))
            {
            if (Tree->Write(grtrpage))
                {
                if (parpage.Hdr.ParentPtr == PFP_NULL)
                    Root = parpage;

                return BOOL_TRUE;
                }
            }
        }

    return BOOL_FALSE;
    }

Boolean BTreeFile::Concatenate(size_t keypos,
                               Page & lesspage,
                               Page & parpage,
                               Page & grtrpage)
    {
    size_t n, ng;

    // move separator key from parent into lesspage
    lesspage.Key[lesspage.Hdr.NoOfKeys] = parpage.Key[keypos];
    lesspage.Ptr[lesspage.Hdr.NoOfKeys] = parpage.Ptr[keypos];
    lesspage.Lnk[lesspage.Hdr.NoOfKeys + 1] = grtrpage.Lnk[0];

    ++lesspage.Hdr.NoOfKeys;

    // delete separator from parent
    --parpage.Hdr.NoOfKeys;

    for (n = keypos; n < parpage.Hdr.NoOfKeys; ++n)
        {
        parpage.Key[n] = parpage.Key[n + 1];
        parpage.Ptr[n] = parpage.Ptr[n + 1];
        parpage.Lnk[n + 1] = parpage.Lnk[n + 2];
        }

    // clear unused key in parent
    parpage.Key[n]     = PageKey();
    parpage.Ptr[n]     = DFP_MARKER;
    parpage.Lnk[n + 1] = PFP_NULL;

    // copy keys from grtrpage to lesspage
    ng = 0;
    n  = lesspage.Hdr.NoOfKeys;

    while (ng < grtrpage.Hdr.NoOfKeys)
        {
        ++lesspage.Hdr.NoOfKeys;

        lesspage.Key[n] = grtrpage.Key[ng];
        lesspage.Ptr[n] = grtrpage.Ptr[ng];
        lesspage.Lnk[n + 1] = grtrpage.Lnk[ng + 1];

        ++ng;
        ++n; 
        }

    // delete greater page
    Tree->Delete(grtrpage.Hdr.FilePtr);

    // is this a leaf page?
    if (lesspage.Lnk[0] != PFP_NULL)
        {
        // adjust child pointers to point to less page
        Page child(0,0);

        for (n = 0; n <= lesspage.Hdr.NoOfKeys; ++n)
            {
            if (BOOL_FALSE == Tree->Read(lesspage.Lnk[n],child))
                return BOOL_FALSE;

            child.Hdr.ParentPtr = lesspage.Hdr.FilePtr;
        
            if (BOOL_FALSE == Tree->Write(child))
                return BOOL_FALSE;
            }
        }

    // write less page and parent
    if (parpage.Hdr.NoOfKeys == 0)
        {
        // note: only the root page can ever be deleted to 0 keys
        Tree->Delete(parpage.Hdr.FilePtr);

        lesspage.Hdr.ParentPtr = PFP_NULL;

        if (BOOL_FALSE == Tree->Write(lesspage,BOOL_TRUE))
            return BOOL_FALSE;

        Root = lesspage;
        }
    else
        {
        if (BOOL_FALSE == Tree->Write(lesspage))
            return BOOL_FALSE;

        if (BOOL_FALSE == Tree->Write(parpage))
            return BOOL_FALSE;

        // reset root page, if necessary
        if (parpage.Hdr.ParentPtr == PFP_NULL)
            Root = parpage;

        // if parent is too small, adjust tree!
        if (parpage.Hdr.NoOfKeys < parpage.Hdr.MinKeys)
            return AdjustTree(parpage);
        }

    return BOOL_TRUE;
    }   

Boolean BTreeFile::RecurseTraverse(const Page & pg)
    {
    size_t n;
    Page * p = new Page(0,0);
    DataBlock * db = new DataBlock;

    // sequence through keys in page, recursively processing links
    for (n = 0; n < pg.Hdr.NoOfKeys; ++n)
        {
        // follow each link before processing page
        if (pg.Lnk[n] != PFP_NULL)
            {
            if (BOOL_FALSE == Tree->Read(pg.Lnk[n],*p))
                return BOOL_FALSE;

            RecurseTraverse(*p);
            }

        // if ptr does not point to anything, don't read a record!
        if (pg.Ptr[n] != DFP_MARKER)
            {
            Data->Seek(pg.Ptr[n]);

            *db = Data->Read();

            if (db->IsNull())
                return BOOL_FALSE;

            EnumFunc(pg.Key[n],*db);
            }
        }

    // handle greatest subtree link
    if (pg.Lnk[n] != PFP_NULL)
        {
        if (BOOL_FALSE == Tree->Read(pg.Lnk[n],*p))
            return BOOL_FALSE;

        if (BOOL_FALSE == RecurseTraverse(*p))
            return BOOL_FALSE;
        }

    // delete temporaries
    delete db;
    delete p;

    return BOOL_TRUE;
    }
    
// create file name from base and extension
String BTreeFile::MakeFileName(const String & basename, 
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

