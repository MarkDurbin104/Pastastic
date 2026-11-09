#ifndef LANG_H
#define LANG_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef LANG_C
#define PUBLIC 
#define INIT 1
#else
#define PUBLIC extern
#define INIT 0
#endif

// PUBLIC SYMBOLS S

PUBLIC void            swaplang     (void);
PUBLIC CHAR 		  *langtext		(INT idx);
PUBLIC CHAR 		  *langstr      (CHAR *name,CHAR *s);
PUBLIC void 		  adddevname	(CHAR *n);
PUBLIC void 		  addlangname	(CHAR *n);
PUBLIC void 		  restoreform   (void);
PUBLIC INT             justbutt     (PFORM form);

// PUBLIC SYMBOLS E

#ifdef LANG_C

typedef struct {
	CHAR d[10];
	CHAR t[80];
	CHAR f[80];
	INT  n;
} LANGMAP;

LANGMAP G_langmaps[10];
INT     G_numlm=0;
CHAR    G_langs[10][10];
CHAR    G_devs[30][10];
INT     G_numdn=0;

#endif // def LANG_C

#endif // ndef LANG_H
