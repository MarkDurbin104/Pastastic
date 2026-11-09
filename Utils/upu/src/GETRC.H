
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


BOOL    ReadRCFile  (CHAR *name1,CHAR *name2,CHAR **buffer,INT *fl,INT *f1l);
CHAR *  GetToken    (CHAR *buffer,INT *len);
CHAR *  GetNTokens  (CHAR *buffer,INT *numb,CHAR **params,CHAR **capofs);
CHAR *  StringVal   (CHAR *origstr,BOOL keepcrs);
CHAR *  ReadDialog  (CHAR *laststr,CHAR *buffer,DIALOGREC *dialog,WORD *nc,CONTROLREC * cont);
void    ParseTokens (CHAR *buffer,WORD *nd,DLGPTR **dlg,STRLIST **psl);
CHAR *  SkipDialog  (CHAR *token,INT *nc);
CHAR *  FindDCaption(CHAR *token);

