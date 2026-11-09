#define MENUTYPE 1
#define FORMTYPE 2

#define MENU_EXT   ".tdu"
#define FORM_EXT   ".tdr"
#define FID_EXT    ".tdx"
#define MID_EXT    ".tdi"

typedef struct { /* 21 bytes - used to display box of options to amend */
		char text[11];
		char *valc;
		int  vali;
		char wid;
		char type;         /* n-numeric,c-char,x-set on/off using X,r-run sub-func */
		char x_group;      /* for X flags - only one within each group can be set */
		char runno;
} boxitem;

typedef struct { /* 7 Bytes */
	unsigned char  mh_line;		/* 1+ */
	unsigned char xpos;
	char textlen;
	char *text;      /* 0-79 */
} menuhdr;

typedef struct { /* 24 bytes */
	unsigned char  ml_line;		/* 1+ */
	int  access;
	int  chain_to;
	unsigned char  ypos;
	int  ml_attr;
	char mne;
	char textlen;
	char *text;      /* 0-79 */
	char promptlen;
	char *prompt;    /* 0-79 */
	char helplen;
	char *help;      /* 0-79 */
} menuln;

typedef struct {  /* 10 bytes */
	char nummh;
	menuhdr **mh;
	char numml;
	menuln **ml;
} menu;

typedef struct { /* 6 bytes */
	unsigned char  hlpno;		/* 1/2 */
	char helplen;
	char *help;      /* 0-79 */
} entryhelp;

typedef struct opt { /* 7 Bytes */
	unsigned char  optno;		/* 1+ */
	char mne;
	char textlen;
	char *text;
} option;

typedef struct { /* 43 */
/*	int  sequence;*/
	char seqname[15];
	char type;
	char rflen;
	char *rng_fmt; /* 0-29 */
	char vflen;
	char *vld_fmt; /* 0-29 */
	char vcase;
	char just;
	char sflen;
	char *scf_fmt; /* 0-29 */
	char pflen;
	char *prf_fmt; /* 0-29 */
	char errlen;
	char *errstr;  /* 0-79 */
} validation;

typedef struct { /* 17 bytes */
	unsigned char  lnkno;		/* 0+ */
	unsigned char  storeid;
	unsigned char  st_fldid;
	unsigned char  st_key;
	char disp_type;
	unsigned char  x_displace;
	unsigned char  st_width;
	char val_ex;
	validation *val;
	char numopt;
	option **op;
} fldlink;

typedef struct { /* 47 bytes */
	unsigned char  fldno;		/* 1+ */
	char scope;
	char just;
	int  attr;
	char fldtype;
	unsigned char  xpos;
	unsigned char  top;
	unsigned char  bottom;
	unsigned char  width;
	unsigned char  nocols;
	unsigned char  nolnks;
	fldlink **lnk;
	char seqname[15];
/*	int  sequence;*/
	unsigned char  offset;
	char deflen;
	char *deftext;
	char textlen;
	char *text;
	char nohelp;
	entryhelp **eh;
} field;

typedef struct { /* 7 bytes */
	unsigned char scrnseq;
	unsigned char formid;
	char nofld;
	field **fld;
} screen;

typedef struct {     /* 5 bytes */
	char   noscrn;
	screen **scrn;
} form;

typedef struct { /*  15 bytes */
	int  dispno;
	int  bg_attr;
	char disp_type;
	union {
		menu m;
		form f;
	} ds;
} display;

typedef struct {			/* 6 bytes - index record structure */
	int dispno;
	long foffs;
} fidx;

typedef struct {			/* 23 bytes - used when creating a tablefield */
	unsigned char  fldno;
	unsigned char  xpos;
	unsigned char  len;
} link;

extern fidx  G_irec;					/* index record */
extern long  G_cursize;					/* current size of form record in memory */
extern display G_dsp;					/* display record */
extern form   *G_frm;					/* form and menu pointers for G_dsp */
extern menu   *G_mnu;
extern int  G_noflds;					/* total no of fields displayed in form/menu */
extern int  G_nohdr;					/* no of menu header lines */
extern char G_scrno;                    /* current screen number */
extern char G_lnkno;					/* selected link no */
extern unsigned char G_offset;			/* current max offset into array */
extern unsigned char G_clft,G_crgt,G_ctop,G_cbot;		/* current selected area */
extern int  G_ident;						/* display no for forms */
extern int  G_curfile,G_curfield;			/* data store array pointers */

/* function prototypes */
extern void fintitles(int w);
extern void mintitles(int scrnfld);
extern int  ml_opt(int scrnfld);
extern void drawfrmbk(int w);
extern int  boxover(int lft, int top, int rgt, int numbox,boxitem **item,char flag);
extern void err_beep(void);
extern void freefrm(form *f,char flag);
extern int  loadmenu(char *fil,int dispno);
extern int  savemenu(char *fil,display *rec,char delete);
extern int  loadform(char *fil,int dispno);
extern int  saveform(char *fil,display *rec,char delete);
extern int  mnudef(int item);
extern int  stcpy(char * dest,char * src);
extern int  edtextxy(int x,int y,char *ln,int nochrs,int bcol,int col,int w);
extern void freemnu(menu *m,char flag);
extern void free_item(boxitem **item,int noitem,char flag);
extern void okfbut(void);
extern void canfbut(void);
extern int  print_form(int det_flag);
extern void unselect_flds(int w);
extern int flfldlen(void);
extern int  create_table(int w);
extern int  delete_table(int w);
extern int  fld_attr(void);
extern int  tabf_attr(void);
extern int  link_opt(void);
extern int  redrawtbl(int fldno);
extern int  val_attr(void);
extern int  opt_attr(void);
extern void df(int w);
extern int  addfld(int fldno);
extern void reordfld(void);
extern void reordoffs(void);
extern int  readnxtfrm(int fd);
extern int  writefrm(display *d,int fd,int id,char iflag);
