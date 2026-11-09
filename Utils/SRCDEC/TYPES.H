#ifndef TYPES_H     // entry sentry
#define TYPES_H

// --------------------------------------------------------------------------
//                               MACROS
// --------------------------------------------------------------------------
#define STRDUP  strdup 
#define MALLOC  malloc 
#define CALLOC  calloc 
#define REALLOC realloc
#define FREE    free   

// --------------------------------------------------------------------------
//                               DEFINES
// --------------------------------------------------------------------------
#define FALSE    0
#define TRUE     1

#define LINESIZE 255

#define IDENT    0x1001
#define ARITH    0x1002
#define BOOLT    0x1003
#define OCURLY   0x1004
#define CCURLY   0x1005
#define OPAREN   0x1006
#define CPAREN   0x1007
#define PUNCT    0x1008
#define ASSIGN   0x1009
#define AASSIGN  0x100A
#define ENDOFST  0x100B

// --------------------------------------------------------------------------



// --------------------------------------------------------------------------
//                               TYPE DEF'S
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// INT type definition - a machine width signed integer 16 or 32 bit.
// --------------------------------------------------------------------------
typedef int  INT;

// --------------------------------------------------------------------------
// UINT type definition - a machine width unsigned integer 16 or 32 bit.
// --------------------------------------------------------------------------
typedef unsigned int  UINT;

// --------------------------------------------------------------------------
// CHAR type definition - signed character 8 bit.
// --------------------------------------------------------------------------
typedef char CHAR;

// --------------------------------------------------------------------------
// UCHAR type definition - unsigned character 8 bit.
// --------------------------------------------------------------------------
typedef unsigned char UCHAR;

// --------------------------------------------------------------------------
// BOOL type definition - boolean i.e. TRUE or FALSE (as defined above)
// --------------------------------------------------------------------------
typedef INT BOOL;

// --------------------------------------------------------------------------
// LINE type definition - a line of source code
// --------------------------------------------------------------------------
typedef struct {
    CHAR *line;             // the line of source text
    void *next;             // the next line
    void *prev;             // the previous line
} LINE;

// --------------------------------------------------------------------------
// SRCBUF type definition - a buffer for the lines of source code in 1 file
// --------------------------------------------------------------------------
typedef struct {
    CHAR *  filename;       // the source file name
    LINE *  firstline;      // the first line in the linked list of lines
    LINE *  lastline;       // the last line in the linked list of lines
    INT     numblines;      // the number of lines
} SRCBUF;

#endif  // ndef TYPES_H
// --------------------------------------------------------------------------
//                               END OF FILE
// --------------------------------------------------------------------------
