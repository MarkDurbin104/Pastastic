#ifndef SRCDEC_H
#define SRCDEC_H

CHAR *G_funcs[1000];
INT  G_numfunc=0;

CHAR *G_reswords[]= {
    "sizeof","if","switch","while","for","return",NULL // "delete",
};
BOOL    isresword           (CHAR *word);
BOOL    isfunction          (CHAR *word,LINK *funcs);
BOOL    isident             (CHAR c);
BOOL    isarith             (CHAR c);
BOOL    isboolean           (CHAR c);
CHAR *  gettoken            (CHAR *l,INT toknum);
CHAR *  extract_token       (CHAR *l);
void    parse_line          (CHAR l[]);
void    save_line           (CHAR *line,SRCBUF *sb);
INT     loadfile            (CHAR *name,SRCBUF *sb,BOOL incfile);
CHAR *  next_token          (SRCBUF *sb);
void    freefilebuf         (SRCBUF *sb);
void    listfile            (SRCBUF *sb);
INT     tokentype           (CHAR *token);
void    collect_funcnames   (SRCBUF *s,LINK **funcs);
void    addtolist           (CHAR *str,CHAR **list,INT *numitem);
void    parse_tokens        (SRCBUF *s,LINK *funcs);

#endif // SRCDEC_H

