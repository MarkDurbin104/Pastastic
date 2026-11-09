#ifdef __cplusplus
extern "C" {
#endif

typedef int INT;
typedef int BOOL;
typedef char CHAR;

typedef struct {
    WORD x,y,w,h;
    WORD fontsize;
    CHAR ident[256];
    CHAR caption[256];
    CHAR fontname[256];
    INT  index;
} DIALOGREC;

typedef struct {
    CHAR type ;
    WORD offset[6];
    CHAR caption[256];
    CHAR caption2[256];
    INT  index;
    CHAR *bufofs;
} CONTROLREC;

typedef struct dlgptr {
    CHAR *offset;
    CHAR *ident;
    WORD len;
    INT  numc;
    struct dlgptr *next;
} DLGPTR;


typedef struct strlist {
  CHAR *str;
  WORD len;
  CHAR *str2;
  WORD len2;
  struct strlist *next;
} STRLIST;

typedef struct fstrlist {
  CHAR *str;
  struct fstrlist *next;
} FSTRLIST;

#define TRUE  1
#define FALSE 0

#define MAXSTRLEN   512
#define TRUE        1
#define FALSE       0
#define MALLOC      malloc
#define FREE        free
#define STRDUP      strdup

#define STRING      1
#define BEGIN       2
#define END         3
#define DIALOG      4
#define ICON        5
#define BITMAP      6
#define STRINGTABLE 7

// WORD FAR PASCAL _export GetStrings      (CHAR *name);

#ifdef __cplusplus
}
#endif

