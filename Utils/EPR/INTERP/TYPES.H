#ifndef TYPES_H     // entry sentry
#define TYPES_H

// --------------------------------------------------------------------------
//                               MACROS
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
//                               DEFINES
// --------------------------------------------------------------------------
// BOOLEEN
#define FALSE    0
#define TRUE     1

// STRING SIZE
#define LINESIZE 255

// TOKEN TYPES
#define NUMBT    0x01
#define IDENT    0x02
#define ARITH    0x03
#define BOOLT    0x04
#define OCURLY   0x05
#define CCURLY   0x06
#define OPAREN   0x07
#define CPAREN   0x08
#define PUNCT    0x09
#define ASSIGN   0x0A
#define AASSIGN  0x0B
#define ENDOFST  0x0C
#define BLANK    0x0D

// ELEMENT TYPES
#define NUMBER   0x0001
#define STRING   0x0002
// --------------------------------------------------------------------------



// --------------------------------------------------------------------------
//                               TYPE DEF'S
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// INT type definition - a machine width signed integer 16 or 32 bit.
// --------------------------------------------------------------------------
typedef int  INT;

// --------------------------------------------------------------------------
// INT16 type definition - signed integer 16 bit.
// --------------------------------------------------------------------------
typedef short  INT16;

// --------------------------------------------------------------------------
// UINT type definition - a machine width unsigned integer 16 or 32 bit.
// --------------------------------------------------------------------------
typedef unsigned int  UINT;

// --------------------------------------------------------------------------
// LONG type definition - long integer - 32 bit.
// --------------------------------------------------------------------------
typedef long LONG;

// --------------------------------------------------------------------------
// ULONG type definition - unsigned long integer - 32 bit.
// --------------------------------------------------------------------------
typedef unsigned long ULONG;

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
// NUMB type definition - all floating point numbers 
// --------------------------------------------------------------------------
typedef float NUMB;

// --------------------------------------------------------------------------
// DELEM type definition - the definition of an individual data element
// --------------------------------------------------------------------------
typedef struct {
    CHAR    *name;          // the element name
    INT     type;           // the element type (NUMBER or STRING)
} DELEM;

// --------------------------------------------------------------------------
// EVALUE type definition - the definition of an data element value
// --------------------------------------------------------------------------
typedef union {
    CHAR    *str;           // the element as a string
    NUMB    numb;           // the element as a number
} EVALUE;

// --------------------------------------------------------------------------
// DSTRUCT type definition - the definition of a data structure
// --------------------------------------------------------------------------
typedef struct {
    CHAR    *name;          // the data structure name
    INT     numbelem;       // the number of elements in the data structure
    DELEM   *elements;      // the elements in the data structure
    INT     evsize;         // the data structure size in bytes
    EVALUE  **evalues;       // the element values
    INT     numbev;         // the number of element values
} DSTRUCT;

// --------------------------------------------------------------------------
// DSTRUCT type definition - the definition of a data structure
// --------------------------------------------------------------------------
typedef struct {
    INT     numstruct;     // the number of data structures
    DSTRUCT *structs;      // the data structures
} DSTRUCTS;

#endif  // ndef TYPES_H
// --------------------------------------------------------------------------
//                               END OF FILE
// --------------------------------------------------------------------------
