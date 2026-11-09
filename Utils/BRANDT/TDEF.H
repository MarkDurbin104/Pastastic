#define	MEMLIMT		100000L			/* limit before swapping to disk */
#define NOLEV		2000			/* maximum no. of levels */
#define	WID			10				/* Width of paper in G_maxx's */
#define	HGT			10				/* Height of paper in G_maxy's */
#define WINX		100				/* left window margin min(100) */
#define WINY		20				/* top window margin min(15) */
#define CLICKRATE	3000			/* no of counts for double click */
#define NOUNDOS		50				/* no of undo's allowed before deletion*/
#define OUTPUT_EXT	"tdo"			/* level output file extension */
#define DICT_EXT	"tdd"			/* dictionary output file extension */
#define STORE_EXT	"tds"			/* store output file extension */
#define IQ outportb					/* defines for crunchy bit of code */
#define OQ inport
#define QQ strcmp
#define QZ for
#define ZQ if
#define QI return
#define DONGLE 2					/* Type of DONGLE 0-none 1-lans 2-pma */
#define MAX_LINK 10					/* NOT MINE */
#define MAX_FIELD 40				/* NOT MINE */

#define mid(a,b) (min(a,b)+((max(a,b)-min(a,b))/2))
typedef struct { /* used in output of cdl */
	char cmd;
	char fil;
	int  key;
	int  seq;
	char oper[30];
	char vc[4];
	int  vi[4];
} cdll;

typedef struct { /* 71 Bytes */             /* Load file struct */
	int		stid;
	char	type;                           /* C,S,R */
	char	name[15];
	int		len;
	char	desc[41];
	char	nofld;
	struct field { /* 61 Bytes */           /* Per field */
		int		ofs;
		int		len;
		char	type;
		char	name[15];
		char	desc[41];
	} **flds;
	char	nokey;
	struct key { /* 5 Bytes */              /* per key */
		char	noparts;
		struct keypt { /* 2 Bytes */        /* per part */
			char	fld;
			char	fldordr;
		} **keypts;
	} **keys;
} file;

typedef struct { /* 59 Bytes */            /* per dictionary entry */
	char	name[15];                      /* Loaded as needed */
	int		len;
	char	type;
	char	desc[41];
} dict;

typedef struct { /* 6 bytes */        	/* sequences name/no xref */
	char	*name;
	int		seq;
} seqs;

typedef struct { /* 8 Bytes */			/* from / to on a line */
	int x1;
	int x2;
	int y1;
	int y2;
} linpts;

typedef struct { /* 2 Bytes */
	unsigned int		TYPE	: 2;   /* line type (straight=1 ...) */
	unsigned int		TXTON	: 1;	/* Text on/off (1/0) */
	unsigned int		DIR		: 1;	/* Start direction horiz/vert 1/0 */
	unsigned int		LCOL	: 4;	/* Line colour */
	unsigned int		TCOL	: 4;	/* Text colour */
	unsigned int		NOPNT	: 4; 	/* Number of changes of direction (max 16) */
} mixbit;
typedef struct { /* 2 Bytes */			/* temporary start/pos of line */
	char	dir;
	char	pos;
} marker;

typedef struct { /* 4 Bytes */		/* an x/y co-ord */
	int	x;
	int	y;
} point;

typedef struct { /* 16 Bytes */		/* An elem on screen */
	int		xpos;					/* Centre of elem */
	int		ypos;					/* Top of elem */
	char	type;					/* Type of elem */
	char	*text;					/* Text in elem */
	int		ident;					/* unique id */
	char	colour;					/* Line/Text colours (4 bits each) */
	int		level;					/* Level below this one (in general) */
	char 	deled;					/* Undo number (0-50) */
} shape;

typedef struct { /* 23 Bytes */     /* A line */
	int		from;					/* Elem from */
	int		to;						/* Elem To */
	char	*text;					/* Text of Elem */
	point	tpos;					/* Text x/y */
	mixbit	flags;					/* See mixbit */
	point	pos;					/* start x/y */
	int far *points;				/* Points after start */
	char 	deled;					/* Undo number (0-50) */
	int		ident;                  /* unique id */
} join;

typedef struct { /* 22 Bytes */		/* A level */
	join	*G_cont;					/* All the lines */
	shape	*G_elem;					/* All the Elements */
	int 	x;      					/* Current cursor x/y */
	int		y;
	int		upper;  					/* Level above me */
	int		modified;					/* If level has been modified */
	int		old;   						/* Swapping oldness counter */
	int		inout;						/* On disk ? 0-in mem */
	long	ofs;  						/* Offset on disk */
} level;

typedef struct { /* 10 Bytes */		/* cut/paste pad */
	int		nc;						/* Number of lines */
	int		ne;   					/* Number of elems */
	join	*cont;					/* The lines */
	shape	*elem;					/* The elems */
} pad;

typedef struct  { /* 19 bytes */    /* Variable store */
	char	name[14];
	char	type;
	int		len;
	int		ofs;                    /* ofset into array - constant */
	int 	no;                     /* var number eg i101 */
} vartype;

typedef struct  { /* 19 bytes */	/* Field variable */
	char	name[14];
	char	type;
	int		len;
} fldvar;

typedef struct { /* 6 Bytes */     /* Structure of all vars */
	int		novar;
	vartype	**vars;
} vardata;
typedef struct { /* 6 Bytes */     /* Structure of all fields for one file */
	int		nofld;
	fldvar	**flds;
} flddata;
typedef struct { /* 10 Bytes */    /* Structure of all files */
	int		nofiles;
	char	**files;				/* File names */
	flddata	**cont;                 /* File gumph */
} fldata;
typedef struct {					/* This isn't mine either */ /* oh no it's not */
	unsigned char  xpos;
	unsigned char ypos;
	char select;
	char type;						/* Field type */
	char ftype;                     /* Table field type */
	char len;                       /* TOTAL Length of field */
	char flen;                      /* Length of data part of field only */
	char val[83];                   /* Text / fno.ffield text / b.b header text CR seperated */
} frmflds;
typedef struct {					/* Literals */
	int  l;                         /* Number */
	char t;                         /* Type */
	void *v;                        /* Values */
} lits;
typedef struct {                    /* Messages */
	int  m;                         /* Message number */
	char n[14];                     /* Name */
	int  l;                         /* Length of t -1=composite */
	char *t;                        /* PSD type text */
} msgs;
typedef struct {                    /* Composite flow */
	int  mno;						/* message number			*/
	int noms;                       /* number of mesg in flow */
	int *msgs;                      /* message numbers of mesgs in flow */
} cflow;
typedef struct {                    /* PSD in traversal order */
	int		i;                      /* item number */
	int		x;                      /* x and y co-ords */
	int		y;
} eltab;

extern	void	grafix(void);
extern	void	drelem(int type,int x,int y,shape *a,int dotext);
extern	void	drcont(int type,int x,int y,join *e,int dotext);
extern	void	savediag(char *fil);
extern	void	loaddiag(char *fil);
extern	void	loadicons(void);
extern	file	*loadfile(char *fil,int stno);
extern	int		savefile(char *fil,file *rec);
extern	void 	cls(void);
extern	void 	markpoints(void);
extern	int		addelem(void);
extern	void	redraw(int quick);
extern	int		inbox(int x1,int y1,int x2,int y2);
extern	int		movecur(void);
extern	void	tmpdraw(void);
extern	int		movecurl(int amount);
extern	int		movecurr(int amount);
extern	int		movecuru(int amount);
extern	int		movecurd(int amount);
extern	int		findelem(void);
extern	int		findcont(void);
extern	int		findtext(void);
extern	int		intextxy(int x,int y,char *ln,int nochrs,int bcol,int col);
extern	void	moveelem(void);
extern	int		changeelem(int im);
extern	void	drawline(void);
extern	int		addcont(join *t);
extern	int		addlev(void);
extern	void	linto(int type,int x,int y);
extern	void	movto(int type,int x,int y);
extern	int		putpix(int x,int y,int col,int mode);
extern	void	moving(int x,int y);
extern	void	dstoredef(int item);
extern	void	setupscr(file *t);
extern	int 	selelem(int res);
extern	int 	setcur(void);
extern	void	button(int x,int y,char *name,int onoff,int high);
extern	int		popup(int x,int y,int w,int h,char *q,int def,char *items);
extern	int 	pulldn(int x,int y,char *items);
extern	void 	headings(int x,char *items);
extern	int	 	inhead(int x,char *items);
extern	void 	imbox(int x,int y,int item);
extern	void	arrow(int t,int x1,int y1,int x2,int y2);
extern	int		updatecur(int imon);
extern	int		curfunc(int cur);
extern	void	uplev(void);
extern	void	intitles(void);
extern	void	dln(int x,int y,int ix,int iy,int ih,int iw);
extern	int		tedit(int x,int y,int c,int l,int bcol,char *lns);
extern	void	textelem(void);
extern	void	putdict(void);
extern	int		getdict(char *name);
extern	void	closedict(void);
extern	int		opendict(void);
extern	int		retdict(int pos);
extern	int		nextdict(void);
extern	int		prevdict(void);
extern	int		firstdict(void);
extern	int		lastdict(void);
extern	int		dictsize(void);
extern	void 	msgdef(int item);
extern	void	setupmsg(int item);
extern	void	prvbox(int pos,fldvar **fv,int noln);
extern	void	okmbut(void);
extern	void	canmbut(void);
extern	int		chkline(int f,int t);
extern	void	delelem(int item);
extern	void	delcont(int item);
extern	void	undo(void);
extern	char 	*filename(int stno);
extern	void	psddef(int item);
extern	int		addvar(char *name,char type,int len);
extern	void	addfile(file *b);
extern	void	printpsdln(int x,int y,char *text,int col);
extern	int		tpsdelem(int level,int item);
extern	void	getsubsels(int item);
extern	void	getsidsels(int item);
extern	void	getrsidsels(int item);
extern	int		frmdef(int item);
extern	int		mnudef(int item);
extern	void	repdef(int item);
extern	int		QD(void);
extern	int		colmen(char *bc,char *fc);
extern	int		prdiag(int mag,int dir);
extern  int     intcmp(int *a,int *b);
extern	void	markkey(file *t,int i,int col);
extern	void	pnxit(char *s,int code);
extern	int		addseq(char *name,int seqno);
extern	long	chkofs(char *c);
extern	void	chkfont(void);
extern	void	outtxtxy(int x,int y,char *c);
extern	void	outcxy(int x,int y,char c);
extern	void	outixy(int x,int y,int i);
extern	int		twid(char *c);
extern	int		varcmp(char **a,char **b);
extern	void	setupfldvar(void);
extern	void	loadfiledat(void);
extern	void	CreateImFile(void);
extern	void	addpsdln(int from,int to);
extern	void	importdef(int item);
extern	void	alignprn(void);
extern	void	markfordel(void);
extern	void	cutit(void);
extern	void	paste(void);
extern	int		saveit(void);
extern	void	startup(void);
extern	void	disptext(int x,int y,int c,int l,int ch,int cw,int cp,int bcol,int fcol,int just,int noln,char **ln);
extern	void	posibox(int y,int ch,int cw,char **ln,int just,int cp,int l);
extern	void	negibox(int y,int ch,int cw,char **ln,int just,int cp);
extern	int		pdeltext(int y,int ch,int cw,char **ln,int just,int cp,int *l);
extern	void	ndeltext(int y,int ch,int cw,char **ln,int just,int cp);
extern	void	inpchr(char k,int y,int ch,char **ln,int *noln);
extern	void	delchr(int y,int ch,char **ln,int *noln);
extern	int		temprec(file *b,int fd);
extern	char	*tpsdln(char *text);
extern	void	puticon(int x,int y,int icon,int mode,int col);
extern	void	outseqs(void);
extern	void	prscr(void);
extern	void	setlevelto(int newlev);
extern	void	addnewvars(char *text);
extern	long	corepr(void);
extern	int		keychk(void);
extern	void	colmenu(void);
extern	void	chkmpos(void);
extern	void	shutdown(void);
extern	int		seqcmp(seqs *a,seqs *b);
extern	int		addpsdelem(int x,int y,int type,char *text,int len,int root,int id);
extern	void	readin(void);
extern	void	getlevin(int newlev);
extern	void	putlevout(int oldlev);
extern	int		getuplev(void);
extern	void	checkifput(void);
extern	int		addutln(char *ln,int len);
extern	int		conv(char *fil);
extern	void	setuppsd(int item);
extern	void	okpbut(void);
extern	void	canpbut(void);
extern	int		combox(void);
extern	int		oprbox(void);
extern	int		filbox(void);
extern	int		fldbox(void);
extern	int		addto(int itype,int ypos);
extern	void	prln(void);
extern	void	buildln(int item);
extern	int		chktab(eltab *a,eltab *b);
extern	void	traversepsd(void);
extern	void	prnpsd(char *text);
extern	int		getlegs(int item,int pos);
extern	char	prfile(file *t);
extern	int		valid(char *str);
extern	int		findlast(char *str,int len);
extern	void	cdlln(char *text,int type,int item);
extern	char	*extractlit(char *text,int no);
extern	void	prseqln(FILE *fp,char *text);
extern	void	prmsgln(FILE *fp,char *text);
extern	char	*extractelm(char *text,int no);
extern	char	*getpname(int pid);
extern	int		findifRorW(int levl,int stid);
extern	void	sepoutif(char *text,int item,int pos);
extern	char	*psdotok(char *text,int len);
extern	char	*psdtok(char *text);
extern	void	utlln(char *text);
extern	void	sepoutut(char *text);
extern	void	getvalue(void);
extern	void	xouttxtxy(int x,int y,char *c);
extern	void	xoutcxy(int x,int y,char c);
extern	void	xoutixy(int x,int y,int i);
extern	void	xrectangle(int lft,int top,int rgt,int bottom);
extern	int		psdlen(char *ln);
extern	int		pnexit(FILE *printer);
extern	void	prlines(FILE *p);
extern	void 	modyfldinln(char *buf,int f1,int f2);
extern	void 	swapflds(int f1,int f2);
extern	int		findfld(char *buf,int f);
extern	int		fldinuse(int f);
extern	void	drdict(int pos);
extern	void	fetchdict(void);
extern	void	eddict(void);
extern	int		fldseq(char *name);
extern	int		swapfflds( int from, int to);
extern	void	swaprflds( int from, int to);
extern	int		findrfld( int findfield);

extern	int				G_sx;    		/* start coords when moving a thing */
extern	int				G_sy;
extern	int				G_mx;           /* mouse coords in relation to  G_sx */
extern	int				G_my;
extern	int				G_cpos;         /* Char position for text in elem box (dodgy this one) */
extern	int				G_driver;       /* Style of graphics screen */
extern	int				G_mode;         /* Mode of screen */
extern	int				G_maxx;         /* Total screen x pixels */
extern	int				G_maxy;         /* Guess */
extern	linpts			G_line;			/* current bit of line being drawn */
extern	int				G_selected[300];/* Selected elements */
extern	pad				G_ubuf[NOUNDOS];/* cut and paste (not used) */
extern	int				G_noulev;       /* as above */
extern	int				G_wid[25];      /* width / height of elems */
extern	int				G_hgt[25];
extern	char			*G_proctypes;   /* process types eg m/p/s */
extern	int				G_nowlev;       /* Current level */
extern	int				G_newlev;       /* Highest level youve used */
extern	int				G_nolev;        /* Highest level malloced */
extern	int				G_inpsd;        /* is this level a psd */
extern	char			*G_lused;       /* level is available/PSD/DFD */
extern	int				*G_noelem;      /* list of ints for no of elems on each level */
extern	int				*G_nocont;		/* as above for lines */
extern	int				*G_nowelem;     /* number malloced elems */
extern	int				*G_nowcont;     /* as above */
extern	level 			*lev;			/* pointer to all levels */
extern	int				G_xpos;         /* current screen x,y pos */
extern	int				G_ypos;
extern	int				G_xtos;         /* top / bottom of scroll bars */
extern	int				G_ytos;         /* on x/y axis */
extern	int				G_xbos;
extern	int				G_ybos;
extern	int				G_elemt;        /* Element type currently being used */
extern	int				G_ident;        /* Ian nicked this var */
extern	int				G_sident;       /* Unused */
extern	int				G_lsel;         /* Line selected */
extern	int				G_tcol;        /* Current text/line col */
extern	int				G_lcol;
extern	int				G_snapto;
extern	int				G_noselc;	/* number of selected elems */
extern	marker			G_partln;	/* see marker */
extern	char			G_cellname[8];
extern	unsigned long	G_icon[36][33];
extern	char			G_used[4];     /* level is available/PSD/DFD */
extern	char			G_icontype[6][9]; /* The variable icons for a level */
extern	char			G_iconselc[5][9]; /* Which element to draw for an icon */
extern	char			G_levtype;       /* Type of level you are currently on */
extern	int				G_nodict;        /* number of dictionary entries */
extern	int				G_dictfd;		/* the dict file pointer */
extern	dict			G_dictent;		/* currently loaded dictionary entry */
extern	fldata			G_file;         /* In memory list of files (see fldata) */
extern	int				QG;             /* Dongle type */
extern	int				G_dongin;       /* whether dongle is in */
extern	vardata			G_varib;        /* The variables */
extern	seqs			*G_seqs;        /* The seqs */
extern	int				G_noseqs;       /* number of abover */
extern	char			comtype[33];    /* type of Commands for cdl */
extern	char			*cmd[46];       /* All cdl commands */
extern	char			*command[35];   /* verbose commands */
extern	char			*operator[26];
extern	char			*G_const[26];   /* constants variables */
extern	frmflds			G_fflds[MAX_FIELD];
extern	char			G_fldtypes[16];
extern	level 			G_cutbuf;       /* cut & paste */
extern	int				G_scx,G_scy,G_pwid,G_ltype;      /* as above */
extern	unsigned char	*G_scr[85];     /* screen buffer for printing */
extern	int				G_szpbuf;       /* size of above */
extern	int				G_dpl;          /* dots per line 18 per char */
extern	int				G_dpp;          /* dots per page 15 per line */
extern	int				G_sGinc;        /* current Shared string no */
extern	int				G_sLinc;        /* current Local string no */
extern	int				G_sinc;         /* current Global string no */
extern	int				G_iGinc;        /* ints */
extern	int				G_iLinc;
extern	int				G_iinc;
extern	int				G_dGinc;        /* doubles */
extern	int				G_dLinc;
extern	int				G_dinc;
extern	int				G_fGinc;        /* floats */
extern	int				G_fLinc;
extern	int				G_finc;
extern	int				G_lGinc;        /* Longs */
extern	int				G_lLinc;
extern	int				G_linc;
extern	int				G_vn[1000];     /* used for extract */
extern	lits			*G_lit;         /* the lits */
extern	int				G_nolit;        /* the number of lits */
extern	msgs			*G_msg;         /* messages */
extern	int				G_nomsg;
extern	cflow			*G_cpm;         /* composite */
extern	int				G_nocpm;
extern	int				G_upl;          /* The upper level */
extern	int				G_upe;          /* The upper elem */
extern	char			**G_utl;        /* The list of until lines PSD style*/
extern	int				G_noutl;
extern	eltab			*G_tab;         /* see eltab */
extern	char			G_cmd[300];     /* the current PSD command */
extern	char			G_nocmd;        /* number of cmds in line */
extern	char			G_currentfl;    /* Current file 0=variable */
extern	char			G_comofs;       /* command ofs of top of currently displayed cmds in command table */
extern	char			G_opofs;        /* as above with ops */
extern	char			G_comdused;     /* Has any cmd been used */
extern	char			G_cmdtype;      /* cmd type that was used */
extern	int				G_lnptr;        /* index into G_cmd */
extern	int				G_noitems;      /* number of items currently in PSD box */
extern	char			G_v;            /* used during CDL gen. var type */
extern	int				G_i;			/* as above but var ofs */
extern	int				G_crntlev[32];  /* stack of levels for PSD travesal */
extern	int				G_crntrep[32];  /* as above ish */
extern	int				G_now;          /* as above ish */
extern	int				G_doingut;      /* doing until flag */
extern	cdll			cdl;            /* see cdll */
extern	int				G_storeid;      /* current store selected */
extern	int				G_inform;       /* in PSD off a form */
extern	char			G_tbltype[5][MAX_LINK];  /* Ians */
extern	int				G_tblno;           /* Ians */

#ifndef MOUSE
#define MOUSE
extern  int				msex,msey,mseb;		/* mouse x,y,button stat */
extern	int				G_curarray[32];     /* current cursor array */

extern  void  setmousexto(int newx);
extern  void  setmouseyto(int newy);
extern  int   mousecur(int onoff);
extern  int   setupmouse(int x,int y,int xmin,int xmax,int ymin,int ymax);
extern  int   mousetrap(int step);
extern  int   mousestat(int step);
extern	void  mousecuroffin(int x,int y,int x1,int y1);
extern	void  setmcurto(int type);
#endif
