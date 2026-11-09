/* display structure */
typedef struct {
	unsigned int disp_no;      /* display number */
	unsigned int disp_attr;    /* background attr */
	char  disp_type;           /* display type */
	char  ds_delete;           /* 1 to delete , else 0 */
} dsp;

/* menu header line structure */
typedef struct {
	int  mh_delete;           /* 1 to delete , else 0 */
	unsigned int disp_no_hd;   /* menu id */
	unsigned int menhd_line_n; /* menu header line number */
	int   xpos_hd;             /* x-position of line on screen */
	char  disp_txt_hd[80];     /* text for menu header line */
} mhd;

/* menuline structure */
typedef struct {
	int   ml_delete;            /* 1 to delete , else 0 */
	unsigned int disp_no_ml;    /* menu id */
	unsigned int disp_ln_ml;    /* menu line number */
	int access_prv_ml;          /* access level required */
	int action_ml;              /* associated action */
	int ypos_ml;                /* ypos of line on screen */
	int disp_attr_ml;           /* display attr */
	char  dis_mnemonic;         /* mnemonic for item */
	char  disp_txt_ml[80];      /* text for item */
	char  prom_txt_ml[80];      /* prompt for item */
	char  help_txt_ml[80];      /* extra help for item */
} mln;

/* tuple form number structure - directs display number to all forms
    for this screen */
typedef struct {
	unsigned int tuple_id;   /* tuple id / display number 0+ */
	unsigned int tuple_fno;  /* tuple form number 0-12 */
	unsigned int tuple_frm;  /* form id 0+ */
	char  form_name[15];     /* form name for identification */
	char  ft_delete;         /* deleted flag,set on to delete */
} ftp;

/* display entry structure - 1 per form field */
typedef struct {
	unsigned int disp_no_et;  /* form id */
	unsigned int disp_en_et;  /* field number 1+ */
	char  disp_scope;         /* scope - not yet implemented */
	char  just;               /* left/right/centre justification within field */
	int   disp_attr_et;       /* screen attr for field */
	char  dispitem_typ;       /* display field item type (as above) */
	int   xpos;               /* xpos of start of field */
	int   disp_rng_st;        /* ypos of top of field */
	int   disp_rg_end;        /* ypos of bottom of field */
	int   disp_width;         /* width of field/table field */
	int   disp_ncols;         /* no. of columns OF that table field */
	int   disp_lt;            /* no. of linked tables (fields in each column) 0-20 */
	int   action_at;          /* sequence to run on field exit */
	int   disp_glbl_var;      /* offset into array */
	char  default_val[15];    /* default value */
	char  disp_txt_strg[80];  /* text string */
	char  de_delete;          /* deleted flag,set on to delete */
} det;

/* entry help structure - currently 1 or 2 lines per field entry */
typedef struct {
	unsigned int disp_no_eh;    /* form id 0+ */
	unsigned int disp_en_hl;    /* field number 1+ */
	unsigned int hlp_txt_n_hl;  /* help line number 1-2 */
	char  help_txt_hl[80];      /* help text */
	char  eh_delete;            /* deleted flag,set on to delete */
} ehp;

/* display file link structure */
typedef struct {
	unsigned int formid;    /* form id */
	unsigned int fldno;     /* field number 1+ */
	unsigned int lnkno;     /* link number 0+ */
	int   store_id;         /* store id */
	int   st_fldid;         /* field number from store */
	int   key_nb;           /* key number for this record */
	char  disp_type;           /* display type for this field */
	int   xdisplace;           /* x displacement in column */
	int   width;               /* width of this link */
	char  dl_delete;        /* deleted flag,set on to delete */
} lnk;

/* Field Validation file structure - allow for 1 per link */
typedef struct {
	unsigned int formid;     /* form id */
	unsigned int fldno;      /* field number 1+ */
	unsigned int lnkno;      /* link number 0+ */
	int      seq;            /* validation sequence */
	char     type;           /* A-alpha,N-numb,C-alphanum */
	char     rng_fmt[30];    /* range format:"a,b,c-d,e,f-h" or "" */
	char     vld_fmt[30];    /* validation format:"!white","none" or scanf fmt */
	char     v_case;         /* case conversion;U-upp,L-low,N-no conversion */
	char     just;           /* link justification, l,r,c,none */
	char     scf_fmt[30];    /* scanf format:must yield 1 argument or none */
	char     prf_fmt[30];    /* printf format:must use 1 argument */
	char     errstr[80];     /* error text string */
	char     dv_delete;      /* delete flag */
} val;

/* option field link structure - can be multiple occurrences per link */
typedef struct {
	unsigned int   formid;     /* form id */
	unsigned int   fldno;      /* field number 1+ */
	unsigned int   lnkno;      /* link number 0+ */
	unsigned int   optno;      /* option number 1+ */
	char           mne;        /* mnemonic char for this option */
	char           text[30];   /* option text */
	char           do_delete;  /* delete flag */
} opt;

extern FILE *printer;
