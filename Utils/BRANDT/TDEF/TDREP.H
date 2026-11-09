
/* TDREP.H   definitions for the report compiler */

/* Command Codes */

#define NBCMDS  18
#define FILES	0
#define RANGE	1
#define SORT	2
#define EXPR	3
#define CALL	4
#define DATE    5
#define ELSE    6
#define IF      7
#define FNAMEOF 8
#define NAMEOF  9
#define P       10
#define PAGE    11
#define READ    12
#define RESET   13
#define SET     14
#define TOTAL   15
#define TOTALS  16
#define LF		17

/* Parameter Codes */

#define TEXT		0
#define OPERATOR	1
#define FILEP		2
#define FIELD		3
#define CONST		5
#define PARM		6
#define LITER		7
#define VSPEC		8
#define TSPEC		9
#define IFNO		10
#define FFIELD		11
#define TSP			12
#define KNO			13
#define SDIREC		14

/* Syntax Error Codes */

#define NBERRCODES		18
#define OPILL			0
#define FILEILL         1
#define FIELDILL        2
#define UNKNOWNITEM     3
#define NO_FLD_SPEC		4
#define UNEXPECTED_PARM 5
#define FILEEXP			6
#define EXCEED_NEST     7
#define INVALIDKNO      8
#define NEEDSDIREC		9
#define CONSTILL        10
#define COMNOTFIN		11
#define NO_EXPR			12
#define UNKNOWNTSPEC	13
#define VSPECERR		14
#define PRIMITIVEILL	15
#define OPERATORILL		16
#define PAREN_UNFIN		17

/* CONST types */
#define C_INT		0
#define C_LONG		1
#define C_FLOAT		2
#define C_DOUBLE	3
#define C_TEXT		4

/* OP types */
#define O_eq	 	 0
#define O_lt         1
#define O_gt         2
#define O_le         3
#define O_ge         4
#define O_ne         5
#define O_pl         6
#define O_mi         7
#define O_dv         8
#define O_ml         9
#define O_pc         10
#define O_ob         11
#define O_cb         12
#define O_nt         13
#define O_lo         14
#define O_la         15
#define O_bo         16
#define O_ba         17
#define O_ca         18

struct order{
	int xpos;
	int ypos;
	int xp,yp;
	struct order *next;
	struct order *prev;
	void *point;
};

struct text{
	int xpos;
	int ypos;
	char *text;
	struct text *next;
	struct text *prev;
};

struct com{
	int code;
	char *text;
	char *ctext;
	int xpos;
	int ypos;
	int xscr;
	int yscr;
	struct param *parm;
	struct com *next;
	struct com *prev;
	struct fld_spec *spec;
};

struct fld_spec{
	int type;
	int just;
	int padding;
	int zero;
	int attr;
	int width;
	int dec_width;
};

struct param{
	int code;
	char typecode;
	int soe;
	char *text;
	int xpos;
	int ypos;
	struct param *next;
	struct param *prev;
};

struct commands{
	int code;
	char *text;
};

struct param *delete_parm( struct com *cmd, struct param *cursor);
void cancellbut(int xpos, int ypos, char *str);
void syntax_err( int code);
int resolve_text( struct param *parm);
struct param *syntxck_FILES( struct com *cmd);
struct param *syntxck_RANGE( struct com *cmd);
struct param *syntxck_SORT( struct com *cmd);
struct param *syntxck_EXPR( struct com *cmd);
struct param *syntxck_CALL( struct com *cmd);
struct param *syntxck_DATE( struct com *cmd);
struct param *syntxck_ELSE( struct com *cmd);
struct param *syntxck_IF( struct com *cmd);
struct param *syntxck_NAMEOF( struct com *cmd);
struct param *syntxck_P( struct com *cmd);
struct param *syntxck_READ( struct com *cmd);
struct param *syntxck_RESET( struct com *cmd);
struct param *syntxck_SET( struct com *cmd);
struct param *syntxck_TOTAL( struct com *cmd);
struct param *syntxck_TOTALS( struct com *cmd);
int syntxck_expr( struct com *cmd, struct param *parm, int level);
int getcode( struct param *parm);
struct param *syntax_check( struct com *cmd);
void freeall(void);
int deletecmd(void);
void freecom( struct com *cmd);
void free_text(struct text *item);
int save_request(void);
void draw_reportwin(char *choice);
void save_rep(void);
void load_rep(void);
int oktosave(void);
void print_report(void );
void gen_cmdtext( struct com *cmd, int isheader);
void draw_subrep(int onoff );
struct param *addtext_parm( int keypress, struct com *cmd);
int move_txt( struct text *point, int start, int end);
int edit_text( struct text *head, int start, int end);
int add_text(int x, int y, char *ln, int nochrs,int bcol,int col );
void highlight_com( struct com *cmd, int offon, struct param *old, struct param *new);
void write_com( struct com *cmd);       /*write up the command*/
void draw_reptext( struct com *start, struct com *current, struct text *firstt);
int edtextxy(int x,int y,char *ln,int nochrs,int bcol,int col,int w);
void printxy( int x, int y, char *text);
