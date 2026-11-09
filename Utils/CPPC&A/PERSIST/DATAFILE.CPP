////////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      datafile.cxx
//
//      Defines a file type for disk-based data files
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
////////////////////////////////////////////////////////////////

#include "datafile.h"
#include "string.h"
#include "time.h"

//-------------------------------------------------------------
//  DataFileBase
//      The base class for binary data files
//-------------------------------------------------------------

ErrReporter * DataFileBase::ErrOut = NULL;

Boolean DataFileBase::SetErrOut(const ErrReporter & er)
    {
    if (ErrOut != NULL)
        delete ErrOut;

    ErrOut = new ErrReporter(er);

    if (ErrOut == NULL)
        return BOOL_FALSE;
    else
        return BOOL_TRUE;
    }

void DataFileBase::ReportError(const String & msg)
    {
    if (ErrOut != NULL)
        ErrOut->Fatal(msg);
    }

DataFileBase::DataFileBase(const char * name, 
                           FileMode m,
                           size_t bufsize) 
    {
    // store file name
    if (name == NULL)
        FileName = new char[64];
    else
        FileName = new char[strlen(name) + 1];

    if (FileName == NULL)
        ReportError("cannot allocate memory for file name");

    if (name == NULL)
        {
        if (NULL == tmpnam(FileName))
            ReportError("cannot generate temp file name");
        }
    else
        strcpy(FileName,name);

    // generate DosMode string
    Mode = m;

    DosMode[1] = 'b';
    DosMode[2] = 0;

    switch (Mode)
        {
        case FM_NEW:
        case FM_TEMPORARY:
            DosMode[0] = 'w';
            DosMode[2] = '+';
            DosMode[3] = 0;
            break;

        case FM_EXISTING:
            DosMode[0] = 'r';
            DosMode[2] = '+';
            DosMode[3] = 0;
            break;

        case FM_APPEND:
            DosMode[0] = 'a';
            break;

        default:
            ReportError("invalid file mode");
        }

    BufferSize = bufsize;

    int failed;

    // open file
    Data = fopen(FileName,DosMode);

    if (Data == NULL)
        ReportError("cannot open file");

    // create buffer (if needed)
    if (BufferSize == 0)
        {
        // unbuffered file
        Buffer = NULL;

        failed = setvbuf(Data,NULL,_IONBF,0);
        }
    else
        {
        // buffered file
        Buffer = new char[BufferSize];

        if (Buffer == NULL)
            failed = 1;
        else
            failed = setvbuf(Data,Buffer,_IOFBF,BufferSize);
        }

    if (failed)
        ReportError("cannot set file buffer");
    }

DataFileBase::~DataFileBase()
    {
    // close up!
    fclose(Data);

    // delete buffer if allocated
    if (Buffer != NULL)
        delete Buffer;

    // if temp file, delete it!
    if (Mode == FM_TEMPORARY)
        remove(FileName);

    // delete file name buffer (if any)
    if (FileName != NULL)
        delete FileName;
    }

//-------------------------------------------------------------
//  DataFileInput
//      A file for the sequential input of information
//-------------------------------------------------------------

DataBlock DataFileInput::Read() const
    {
    if (feof(Data))
        return NULL_BLOCK;

    RecordHeader hdr;
    size_t res;

    // read record header
    res = fread(&hdr,sizeof(RecordHeader),1,Data);

    if (res == 0)
        return NULL_BLOCK;

    // allocate buffer to hold data
    void * buf = (void *)new char[hdr.RecSize];

    if (buf == NULL)
        return NULL_BLOCK;

    // read data
    res = fread(buf,hdr.RecSize,1,Data);

    if (res == 0)
        return NULL_BLOCK;

    // create an DataBlock
    DataBlock result(hdr.RecSig,hdr.RecSize,buf);

    // delete the data buffer
    delete buf;

    // outa here
    return result;
    }

Boolean DataFileInput::Rewind()
    {
    rewind(Data);

    return BOOL_TRUE;
    }

Boolean DataFileInput::Skip()
    {
    RecordHeader hdr;
    size_t res;

    // read record header
    res = fread(&hdr,sizeof(RecordHeader),1,Data);

    if (res == 0)
        return BOOL_FALSE;

    // skip data
    if (0 != fseek(Data,hdr.RecSize,SEEK_CUR))
        return BOOL_FALSE;

    return BOOL_TRUE;
    }

//-------------------------------------------------------------
//  DataFileOutput
//      A file for the sequential output of information
//-------------------------------------------------------------

Boolean DataFileOutput::Write(const DataBlock & db)
    {
    RecordHeader hdr;

    hdr.RecSig  = db.GetSignature();
    hdr.RecSize = db.GetSizeOf();

    // store record header
    size_t n = fwrite(&hdr,sizeof(RecordHeader),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // store data
    n = fwrite(db.GetBufferPtr(),hdr.RecSize,1,Data);

    if (n == 0)
        return BOOL_FALSE;

    return BOOL_TRUE;
    }

//-------------------------------------------------------------
//  DataFile
//      Defines a random access, I/O file
//-------------------------------------------------------------

const DataFilePtr DFP_MARKER  = -1;
const Signature   SIG_DELETED = 0xFFFFFFFF;

// constructor
DataFile::DataFile(const char * name, 
                   FileMode m,
                   size_t bufsiz)
    : DataFileBase(name,m,bufsiz)
    {
    size_t n;

    if ((m == FM_NEW) || (m == FM_TEMPORARY))
        {
        Hdr.FirstEmpty = DFP_MARKER;

        n = fwrite(&Hdr,sizeof(DataFileHdr),1,Data);

        if (n == 0)
            ReportError("cannot create file header");
        }
    else
        {
        n = fread(&Hdr,sizeof(DataFileHdr),1,Data);

        if (n == 0)
            ReportError("cannot read file header");
        }
    }

// write a record
DataFilePtr DataFile::Write(const DataBlock & db)
    {
    // search for first open record that can hold this one
    IORecordHeader rechdr;
    DataFilePtr ptr;
    int res;
    size_t n;

    if (Hdr.FirstEmpty == DFP_MARKER)
        {
        // append new data to end of file
        res = fseek(Data,0,SEEK_END);

        if (res)
            return DFP_ERROR;

        ptr = ftell(Data);

        rechdr.Size = db.GetSizeOf();
        }
    else
        {
        // start with first empty record
        DataFilePtr prev = DFP_MARKER;

        ptr = Hdr.FirstEmpty;

        for (;;)
            {
            // set file pointer
            res = fseek(Data,ptr,SEEK_SET);

            if (res)
                return DFP_ERROR;

            // read record header
            n = fread(&rechdr,sizeof(IORecordHeader),1,Data);

            if ((n == 0) || (rechdr.RecSig != SIG_DELETED))
                return DFP_ERROR;

            // is it big enough?
            if (rechdr.Size >= db.GetSizeOf())
                {
                // go to previous record
                if (prev == DFP_MARKER)
                    {
                    // change entry in header
                    Hdr.FirstEmpty = rechdr.NextDeleted;

                    // go to beginning of file
                    fseek(Data,0,SEEK_SET);

                    // write new header
                    n = fwrite(&Hdr,sizeof(DataFileHdr),1,Data);

                    if (n == 0)
                        return DFP_ERROR;
                    }
                else
                    {
                    // adjust chain by putting next in prev
                    res = fseek(Data,prev,SEEK_SET);

                    if (res)
                        return DFP_ERROR;

                    // read previous record's header
                    IORecordHeader prevhdr;

                    n = fread(&prevhdr,sizeof(IORecordHeader),1,Data);

                    if (n == 0)
                        return DFP_ERROR;

                    // change next deleted reference
                    prevhdr.NextDeleted = rechdr.NextDeleted;

                    // rewrite prev. header
                    res = fseek(Data,prev,SEEK_SET);

                    if (res)
                        return DFP_ERROR;

                    // read previous record's header
                    n = fwrite(&prevhdr,sizeof(IORecordHeader),1,Data);

                    if (n == 0)
                        return DFP_ERROR;
                    }
                
                // set pointer to beginning of ptr record
                fseek(Data,ptr,SEEK_SET);
                break;
                }

            // save pointer
            prev = ptr;

            if (rechdr.NextDeleted == DFP_MARKER)
                {
                // append new data to end of file
                res = fseek(Data,0,SEEK_END);

                if (res)
                    return DFP_ERROR;

                ptr = ftell(Data);        

                rechdr.Size = db.GetSizeOf();

                break;
                }
            else
                ptr  = rechdr.NextDeleted;
            }
        }

    rechdr.RecSig      = db.GetSignature();
    rechdr.RecSize     = db.GetSizeOf();
    rechdr.NextDeleted = DFP_MARKER;

    // store signature
    n = fwrite(&rechdr,sizeof(IORecordHeader),1,Data);

    if (n == 0)
        return DFP_ERROR;

    // store data
    n = fwrite(db.GetBufferPtr(),rechdr.RecSize,1,Data);

    if (n == 0)
        return DFP_ERROR;

    // return location data was written to
    return ptr;
    }

// read a record
DataBlock DataFile::Read() const
    {
    if (feof(Data))
        return NULL_BLOCK;

    size_t n;

    IORecordHeader rechdr;

    for (;;)
        {
        // read record header
        n = fread(&rechdr,sizeof(IORecordHeader),1,Data);

        // this may indicate end-of-file
        if (n == 0)
            return NULL_BLOCK;

        // return null for deleted record
        if (rechdr.RecSig == SIG_DELETED)
            fseek(Data,rechdr.Size,SEEK_CUR);
        else
            break;
        }

    // allocate buffer to hold data
    void * buf = (void *)new char[rechdr.RecSize];

    if (buf == NULL)
        return NULL_BLOCK;

    // read data
    n = fread(buf,rechdr.RecSize,1,Data);

    if (n == 0)
        return NULL_BLOCK;

    // create an DataBlock
    DataBlock result(rechdr.RecSig,rechdr.RecSize,buf);

    // skip over any "waste" characters
    if (rechdr.RecSize < rechdr.Size)
        fseek(Data,rechdr.Size - rechdr.RecSize, SEEK_CUR);

    // delete the data buffer
    delete buf;

    // outa here
    return result;
    }

// force file data to disk
Boolean DataFile::Commit()
    {
    if (Buffer != NULL)
        {
        int res = fflush(Data);

        if (res)
            return BOOL_FALSE;
        }

    return BOOL_TRUE;
    }

// delete a record
Boolean DataFile::Delete()
    {
    size_t n;
    int res;
    IORecordHeader rechdr;

    // save this position
    DataFilePtr curptr = ftell(Data);

    // make sure we're not in the header
    if (curptr < sizeof(DataFileHdr))
        return BOOL_FALSE;

    // read header
    n = fread(&rechdr,sizeof(IORecordHeader),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // mark as deleted
    if (rechdr.RecSig != SIG_DELETED)
        {
        // update record header
        rechdr.RecSig      = SIG_DELETED;
        rechdr.NextDeleted = Hdr.FirstEmpty;

        // write record header
        res = fseek(Data,curptr,SEEK_SET);

        if (res)
            return BOOL_FALSE;

        n = fwrite(&rechdr,sizeof(IORecordHeader),1,Data);

        if (n == 0)
            return BOOL_FALSE;

        // modify header
        Hdr.FirstEmpty = curptr;

        res = fseek(Data,0,SEEK_SET);

        if (res)
            return BOOL_FALSE;

        n = fwrite(&Hdr,sizeof(DataFileHdr),1,Data);

        if (n == 0)
            return BOOL_FALSE;
        }

    // move back to start of deleted record
    res = fseek(Data,curptr,SEEK_SET);

    if (res)
        return BOOL_FALSE;
    else
        return BOOL_TRUE;
    }

// remove blanks and wasted space
Boolean DataFile::Compact(DFCompFunc func)
    {
    if (BOOL_FALSE == Commit())
        return BOOL_FALSE;

    // generate temporary file name
    char tname[32];

    sprintf(tname,"%lx.TMP",time(NULL));

    // open temporary file
    FILE * newfile = fopen(tname,"wb");

    if (newfile == NULL)
        return BOOL_FALSE;

    // read and copy header
    int res = fseek(Data,0,SEEK_SET);

    if (res)
        return BOOL_FALSE;

    size_t n = fread(&Hdr,sizeof(DataFileHdr),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    n = fwrite(&Hdr,sizeof(DataFileHdr),1,newfile);

    if (n == 0)
        return BOOL_FALSE;

    // read each record
    for (;;)
        {
        IORecordHeader rechdr;
        DataFilePtr ptr;
        char * buf;

        // read record header
        n = fread(&rechdr,sizeof(IORecordHeader),1,Data);

        if (n == 0)
            break;

        if (rechdr.RecSig == SIG_DELETED)
            {
            // skip deleted records
            res = fseek(Data,rechdr.Size,SEEK_CUR);

            if (res)
                return BOOL_FALSE;
            }
        else
            {
            // allocate buffer to hold data
            buf = new char[rechdr.Size];

            if (buf == NULL)
                return BOOL_FALSE;

            // read data
            n = fread(buf,rechdr.Size,1,Data);

            if (n == 0)
                return BOOL_FALSE;

            // get output position in new file
            ptr = ftell(newfile);

            // write header to new file
            rechdr.Size = rechdr.RecSize;

            n = fwrite(&rechdr,sizeof(IORecordHeader),1,newfile);

            if (n == 0)
                return BOOL_FALSE;

            // write data to new file
            n = fwrite(buf,rechdr.Size,1,newfile);

            if (n == 0)
                return BOOL_FALSE;

            // call function
            if (func != NULL)
                func(ptr,DataBlock(rechdr.RecSig,rechdr.Size,buf));

            // delete buffer
            delete buf;
            }
        }

    // close files
    fclose(newfile);
    fclose(Data);

    // delete old file
    remove(FileName);

    // rename new file
    rename(tname,FileName);

    // open newly-compacted file
    Data = fopen(FileName,DosMode);

    if (Data == NULL)
        return BOOL_FALSE;

    // read file header
    n = fread(&Hdr,sizeof(DataFileHdr),1,Data);

    if (n == 0)
        return BOOL_FALSE;
    else
        return BOOL_TRUE;
    }

// go to  position in file
DataFilePtr DataFile::Seek(DataFilePtr pos) const
    {
    // make sure position is outside of header
    if (pos < sizeof(DataFileHdr))
        return DFP_ERROR;

    // get current position
    DataFilePtr ptr = ftell(Data);

    // move to new position
    int res = fseek(Data,pos,SEEK_SET);

    // check for error
    if (res)
        {
        // try to restore previous position
        fseek(Data,ptr,SEEK_SET);

        ptr = DFP_ERROR;
        }

    // done
    return ptr;
    }

// move to next record
Boolean DataFile::Skip()
    {
    IORecordHeader rechdr;
    int res;
    size_t n;

    // read record header
    n = fread(&rechdr,sizeof(IORecordHeader),1,Data);

    if (n == 0)
        return BOOL_FALSE;

    // skip data
    res = fseek(Data,rechdr.Size,SEEK_CUR);

    if (res)
        return BOOL_FALSE;
    else
        return BOOL_TRUE;
    }

// return to beginning of file
Boolean DataFile::Rewind()
    {
    int res = fseek(Data,sizeof(DataFileHdr),SEEK_SET);

    if (res)
        return BOOL_FALSE;
    else
        return BOOL_TRUE;
    }
