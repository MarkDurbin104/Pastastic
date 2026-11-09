////////////////////////////////////////////////////////////////
//  PERSISTENCE LIBRARY
//      datafile.h
//
//      Defines a file type for disk-based data files
//
//      Copyright 1992 Scott Robert Ladd
//      All rights reserved
////////////////////////////////////////////////////////////////

#ifndef DATAFILE_H
#define DATAFILE_H

#include "persist.h"
#include "stdio.h"

//-------------------------------------------------------------
//  DataFile
//      The base class for binary data files
//-------------------------------------------------------------

enum FileMode
    {
    FM_NEW,
    FM_EXISTING,
    FM_APPEND,
    FM_TEMPORARY
    };

struct RecordHeader
    {
    size_t RecSize;
    Signature RecSig;
    };

class DataFileBase
    {
    public:
        // constructor
        DataFileBase(const char * name = NULL, 
                     FileMode m        = FM_TEMPORARY,
                     size_t bufsiz     = 0);

        // destructor
        ~DataFileBase();

        // set error reporting object
        static Boolean SetErrOut(const ErrReporter & er);

    protected:
        // data members
        FileMode Mode;
        char *   FileName;
        FILE *   Data;
        char *   Buffer;
        size_t   BufferSize;
        char     DosMode[4];

        // error reporting mechanisms
        static ErrReporter * ErrOut;

        static void ReportError(const String & msg);
    };

//-------------------------------------------------------------
//  DataFileInput
//      A file for the sequential input of information
//-------------------------------------------------------------

class DataFileInput : virtual public DataFileBase
    {
    public:
        DataFileInput(const char * name = NULL, 
                      size_t bufsiz     = 0);

        DataBlock Read() const;

        Boolean Rewind();
        Boolean Skip();
    };

inline DataFileInput::DataFileInput(const char * name, 
                                          size_t bufsiz)
    : DataFileBase(name,FM_EXISTING,bufsiz)
    {
    // a shell for calling the base class constructor
    }

//-------------------------------------------------------------
//  DataFileOutput
//      A file for the sequential output of information
//-------------------------------------------------------------

class DataFileOutput : virtual public DataFileBase
    {
    public:
        DataFileOutput(const char * name = NULL, 
                       size_t bufsiz     = 0,
                       FileMode m        = FM_NEW);

        Boolean Write(const DataBlock & db);
    };

inline DataFileOutput::DataFileOutput(const char * name, 
                                      size_t bufsiz,
                                      FileMode m)
    : DataFileBase(name,m,bufsiz)
    {
    // void
    }

//-------------------------------------------------------------
//  DataFilePtr
//      A type used to locate information in a data file
//-------------------------------------------------------------

// type of a data file ptr
typedef long DataFilePtr;

// constants
extern const DataFilePtr DFP_MARKER;
#define DFP_ERROR DFP_MARKER

extern const Signature SIG_DELETED;

//-------------------------------------------------------------
//  DataFile
//      Defines a random access, I/O file
//-------------------------------------------------------------

struct DataFileHdr
    {
    DataFilePtr FirstEmpty;
    };

struct IORecordHeader : public RecordHeader
    {
    size_t Size;
    DataFilePtr NextDeleted;
    };

typedef void (* DFCompFunc)(DataFilePtr ptr, const DataBlock & db);

class DataFile : public DataFileBase
    {
    public:
        // constructor
        DataFile(const char * name, 
                 FileMode m    = FM_EXISTING, 
                 size_t bufsiz = 0);

        // write a record
        DataFilePtr Write(const DataBlock & db);

        // read a record
        DataBlock Read() const;

        // commit data to disk
        Boolean Commit();

        // delete a record
        Boolean Delete();

        // move to next record
        Boolean Skip();

        // return to beginning of file
        Boolean Rewind();

        // remove blanks and wasted space
        Boolean Compact(DFCompFunc func = NULL);

        // go to  position in file
        DataFilePtr Seek(DataFilePtr pos) const;

        // get current file position
        DataFilePtr CurrentPtr() const;

    protected:
        DataFileHdr Hdr;
    };

// get current file position
inline DataFilePtr DataFile::CurrentPtr() const
    {
    return ftell(Data);
    }

#endif
