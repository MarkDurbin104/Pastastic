//============================================================================
// Module        | DATASET.H
// Description   | Structure definitions and access functions
//               | for a data schema mantenance program
//               | 
// Author        | Automatically generated from dataset.cdf by CGEN
// Copyright (c) | Unisys Limited
//               | 22 Southwark Bridge Road
//               | London SE1 9HB
//============================================================================
// Mod History   | By  | Modifications Made
//============================================================================
// 14/02/1996    | MJD | Initial Version
//============================================================================
#ifndef DATASET_H // entry sentry
#define DATASET_H

#ifdef INIT
# undef INIT
#endif
#ifdef PUBLIC
# undef PUBLIC
#endif

#ifdef DATASET_C
# define INIT(a) =a
# define PUBLIC
#else
# define INIT(a)
# define PUBLIC extern
#endif // DATASET_C

#ifndef MALLOC
#define FREE    free
#define MALLOC  malloc
#define REALLOC realloc
#define STRDUP  strdup
#define PTRCHECK(a) (a!=NULL)
#endif // MALLOC
//============================================================================
//                                DEFINITIONS                                
//============================================================================

#define TRUE  1 // used for boolean operations
#define FALSE 0 // used for boolean operations

//============================================================================
//                              TYPE DEFINITIONS                              
//============================================================================
//============================================================================
// CHAR type definition - signed character (8 bits)
typedef char CHAR;
//============================================================================
// UCHAR type definition - unsigned character (8 bits)
typedef unsigned char UCHAR;
//============================================================================
// SPTR type definition - pointer to signed characters (8 bits) i.e. string
typedef CHAR * SPTR;
//============================================================================
// USPTR type definition - pointer to unsigned characters (8 bits)
typedef UCHAR * USPTR;
//============================================================================
// INT type definition - signed integer (machine width i.e. 16 or 32 bits)
typedef int INT;
//============================================================================
// UINT type definition - unsigned integer (machine width i.e. 16 or 32 bits)
typedef unsigned int UINT;
//============================================================================
// INT16 type definition - signed integer (16 bits)
typedef short INT16;
//============================================================================
// UINT16 type definition - unsigned integer (16 bits)
typedef unsigned short UINT16;
//============================================================================
// LONG type definition - signed integer (32 bits)
typedef long LONG;
//============================================================================
// ULONG type definition - unsigned integer (32 bits)
typedef unsigned long ULONG;
//============================================================================
// BOOL type definition - Boolean type can be of either TRUE or FALSE
typedef int BOOL;
//============================================================================
// COUNTER type definition - Used for all counters
typedef int COUNTER;
//============================================================================
// COLUMN type definition - a column in a dataset
typedef struct {
    SPTR   name;      // the column name
    SPTR   version;   // the column version
    SPTR   inbase;    // the base version in which this column resides
    SPTR   type;      // the column type
    SPTR   datatype;  // the column data type
    SPTR   size;      // the column size
    SPTR   descript;  // description of this column
    SPTR   comment;   // comment for this version-base
} COLUMN;
//============================================================================
// COLUMNPTR type definition - a pointer to a column structure
typedef COLUMN * COLUMNPTR;
//============================================================================
// INDEX type definition - an index to a dataset
typedef struct {
    SPTR   name;      // the index name
    SPTR   version;   // the index version
    SPTR   inbase;    // the base version in which this index resides
    UINT   numcol;    // the number of columns in the index
    SPTR   colname;   // the column names in the index
    SPTR   descript;  // description of this index
    SPTR   comment;   // comment for this version-base
} INDEX;
//============================================================================
// INDEXPTR type definition - a pointer to an index structure
typedef INDEX * INDEXPTR;
//============================================================================
// DATASET type definition - a dataset in a database
typedef struct {
    SPTR        name;      // the dataset name
    SPTR        version;   // the dataset version
    SPTR        inbase;    // the base version in which this dataset resides
    BOOL        active;    // TRUE if dataset is currently active
    UINT        numcol;    // the number of columns in the dataset
    COLUMNPTR   column;    // the columns in the dataset
    INDEXPTR    primidx;   // the primary index
    UINT        numidx;    // the number of indexes
    INDEXPTR    index;     // the indexs in this dataset (one is the primary)
    SPTR        descript;  // description of this dataset
    SPTR        comment;   // comment for this version-base
} DATASET;
//============================================================================
// DATASETPTR type definition - a pointer to an dataset structure
typedef DATASET * DATASETPTR;
//============================================================================
// DATABASE type definition - a database
typedef struct {
    SPTR         name;        // the database name
    SPTR         password;    // the database password
    SPTR         currver;     // the current database version
    SPTR         currbase;    // the current database base version
    UINT         numdataset;  // the number of datasets in the database
    DATASETPTR   dataset;     // the datasets in the database
    SPTR         descript;    // description of this database
} DATABASE;
//============================================================================
//                             PUBLIC PROTOTYPES                             
//============================================================================

PUBLIC BOOL save_column     (FILE *fp,COLUMN *cs);
PUBLIC BOOL save_index      (FILE *fp,INDEX *is);
PUBLIC BOOL save_dataset    (FILE *fp,DATASET *ds);
PUBLIC BOOL save_database   (FILE *fp,DATABASE *ds);
PUBLIC BOOL load_column     (FILE *fp,COLUMN *cs);
PUBLIC BOOL load_index      (FILE *fp,INDEX *is);
PUBLIC BOOL load_dataset    (FILE *fp,DATASET *ds);
PUBLIC BOOL load_database   (FILE *fp,DATABASE *ds);
PUBLIC void prnt_column     (COLUMN *cs,INT depth);
PUBLIC void prnt_index      (INDEX *is,INT depth);
PUBLIC void prnt_dataset    (DATASET *ds,INT depth);
PUBLIC void prnt_database   (DATABASE *ds,INT depth);
PUBLIC void free_column     (COLUMN *cs);
PUBLIC void free_index      (INDEX *is);
PUBLIC void free_dataset    (DATASET *ds);
PUBLIC void free_database   (DATABASE *ds);
PUBLIC BOOL apnd_column     (COLUMN **c_base,UINT *numelem,COLUMN *new_c);
PUBLIC BOOL apnd_index      (INDEX **i_base,UINT *numelem,INDEX *new_i);
PUBLIC BOOL apnd_dataset    (DATASET **d_base,UINT *numelem,DATASET *new_d);
PUBLIC BOOL apnd_database   (DATABASE **d_base,UINT *numelem,DATABASE *new_d);
PUBLIC BOOL inst_column     (COLUMN **c_base,UINT *numelem,COLUMN *new_c,UINT offset);
PUBLIC BOOL inst_index      (INDEX **i_base,UINT *numelem,INDEX *new_i,UINT offset);
PUBLIC BOOL inst_dataset    (DATASET **d_base,UINT *numelem,DATASET *new_d,UINT offset);
PUBLIC BOOL inst_database   (DATABASE **d_base,UINT *numelem,DATABASE *new_d,UINT offset);
PUBLIC BOOL delt_column     (COLUMN **c_base,UINT *numelem,UINT offset);
PUBLIC BOOL delt_index      (INDEX **i_base,UINT *numelem,UINT offset);
PUBLIC BOOL delt_dataset    (DATASET **d_base,UINT *numelem,UINT offset);
PUBLIC BOOL delt_database   (DATABASE **d_base,UINT *numelem,UINT offset);
PUBLIC COLUMN   *new_column  (SPTR new_name,SPTR new_version,SPTR new_inbase,SPTR new_type,SPTR new_datatype,SPTR new_size,SPTR new_descript,SPTR new_comment);
PUBLIC INDEX    *new_index   (SPTR new_name,SPTR new_version,SPTR new_inbase,UINT new_numcol,SPTR new_colname,SPTR new_descript,SPTR new_comment);
PUBLIC DATASET  *new_dataset (SPTR new_name,SPTR new_version,SPTR new_inbase,BOOL new_active,UINT new_numcol,COLUMNPTR new_column,INDEXPTR new_primidx,UINT new_numidx,INDEXPTR new_index,SPTR new_descript,SPTR new_comment);
PUBLIC DATABASE *new_database(SPTR new_name,SPTR new_password,SPTR new_currver,SPTR new_currbase,UINT new_numdataset,DATASETPTR new_dataset,SPTR new_descript);
PUBLIC INT dataset_column_idx(DATASET *ds,SPTR name);
PUBLIC COLUMNPTR dataset_column(DATASET *ds,SPTR name);
PUBLIC INT dataset_index_idx(DATASET *ds,SPTR name);
PUBLIC INDEXPTR dataset_index(DATASET *ds,SPTR name);
PUBLIC INT database_dataset_idx(DATABASE *ds,SPTR name);
PUBLIC DATASETPTR database_dataset(DATABASE *ds,SPTR name);
//============================================================================


//============================================================================
//                             PRIVATE PROTOTYPES                             
//============================================================================

#ifdef DATASET_C

BOOL write_fixed(FILE *fp,void *buf,INT len);
BOOL write_varib(FILE *fp,CHAR *s);
BOOL read_fixed(FILE *fp,void *buf,INT len);
BOOL read_varib(FILE *fp,CHAR **s);

#endif

//============================================================================
//                              GLOBAL VARIABLES                              
//============================================================================

PUBLIC CHAR * G_testvar    INIT(NULL); // Just a test to see if it works
PUBLIC INT    G_testvar123 INIT(0);    // Just another test to see if it works


#endif //DATASET_H
//============================================================================
//                                END OF FILE                                
//============================================================================
