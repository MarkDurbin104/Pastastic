#ifndef WIN_H

#define WIN_H

#ifdef PUBLIC           
#undef PUBLIC
#endif
#ifdef INIT           
#undef INIT
#endif

#ifdef WIN_C
#define PUBLIC 
#define INIT(a) = a
#else
#define PUBLIC extern
#define INIT(a) 
#endif

// PUBLIC SYMBOLS S

#define OKBUTT  0x8000
#define YEBUTT  0x4000
#define NOBUTT  0x2000
#define CABUTT  0x1000
#define ABBUTT  0x0800
#define REBUTT  0x0400
#define IGBUTT  0x0200
#define FABUTT  0x0100

typedef unsigned int uint;

typedef void (*LBFPTR)   (int,int,int);
typedef char *(*LBNFPTR) (int);
typedef void (*BFPTR)    (int,int);
typedef void (*WFPTR)    (int,int);
typedef void (*SBFPTR)   (int,int,int);
typedef void (*ODBFPTR)  (int,int,int,int);
typedef void (*MFPTR)    (void);
typedef void (*MBFPTR)   (unsigned int);
typedef void (*TBFPTR)   (unsigned int);

typedef struct {
    int *id;
    int x;
	int y;
	int x1;
	int y1;
	int t;
	char *ti;
	WFPTR f;
} WINDITEM;

typedef struct {
    int *id;
    int x;
	int y;
	int x1;
	int y1;
	int t;
	void *uf;
	BFPTR f;
} BUTTITEM;

typedef struct {
    int *id;
    int x;
	int y;
	int l;
    int *ni;
	LBNFPTR nf;
	LBFPTR f;
	int item;
	int w;
} LBOXITEM;

typedef struct {
    int *id;
    uint x;
	uint y;
	uint x1;
	uint y1;
	uint p;
	uint *l;
	uint pl;
	SBFPTR f;
} SBARITEM;

typedef struct {
    int *id;
    int x;
	int y;
	int l;
	int w;
	char *t;
	TBFPTR f;
	int rw;
} TBOXITEM;

typedef struct {
    char name[20];
    char col;
    char type;
    void *item;
    int x;
    int x1;
} MENUITEM;

typedef struct {
    char *n;
    char *s;
    unsigned int b;
    MBFPTR  f;
} MBOXITEM;

typedef struct {
    int  type;
    void *item;
} DBOXITEM;

#define M_BUTT0  0x0000
#define M_BUTT1  0x0001
#define M_BUTT2  0x0002
#define M_BUTT3  0x0003
#define M_BUTT4  0x0004
#define M_BUTT5  0x0005
#define M_BUTT6  0x0006
#define M_BUTT7  0x0007
#define M_MOVIN  0x0010
#define M_MOVOT  0x0011
#define M_MOVE   0x0012
#define M_UPDATE 0x0020
#define M_CANCEL 0x0021
#define M_PAINT  0x1000
#define M_HIDE   0x1001
#define M_KBHIT  0x2000
#define M_KBEND  0x2001
#define M_STOP   0x4001
#define M_DELETE 0x4002

#define SBLNUP   1
#define SBLNDN   2
#define SBPGUP   3
#define SBPGDN   4
#define SBONCT   5

#define TXTDRAW  0
#define OWNDRAW  1

#define DBOXLAST 0
#define DBOXWIND 1
#define DBOXBUTT 2
#define DBOXTBOX 3
#define DBOXEBOX 4
#define DBOXLBOX 5
#define DBOXSBAR 6

#define OTWIN    0
#define INWIN    1

PUBLIC int      G_sysfw INIT(8);
PUBLIC int      G_sysfh INIT(16);

PUBLIC int  win       (int x,int y,int x1,int y1,int t,char *ti,WFPTR f);
PUBLIC int  button    (int x,int y,int x1,int y1,int t,void *uf,BFPTR f);
PUBLIC int  listbox   (int x,int y,int l,int *ni,LBNFPTR nf,LBFPTR f,int item,int w);
PUBLIC int  scrollbar (uint x,uint y,uint x1,uint y1,uint p,uint *l,uint pl,SBFPTR f);
PUBLIC int  textbox   (int x,int y,int l,int w,char *t,TBFPTR f,int rw);
PUBLIC void wind      (WINDITEM *wn);
PUBLIC void butt      (BUTTITEM *bt);
PUBLIC void lbox      (LBOXITEM *lb);
PUBLIC void sbar      (SBARITEM *sb);
PUBLIC void tbox      (TBOXITEM *tb);
PUBLIC int  mbox      (MBOXITEM *mb);
PUBLIC int  dbox      (DBOXITEM *db);
PUBLIC int  menu      (MENUITEM *mn,int w);
PUBLIC void activate  (int w);
PUBLIC void poll      (void);
PUBLIC void sendmsg   (int i,int st);
PUBLIC void setcursor (int s);
PUBLIC int  wnypos    (int w);
PUBLIC int  wnxpos    (int w);
PUBLIC void setsnap   (int w,int xs,int ys);
PUBLIC void setbstate (int b,int s);
PUBLIC void dumpst    (void);
PUBLIC void error     (char *s);
PUBLIC void setupwin  (int maxx,int maxy);
PUBLIC int  getkey    (void);
PUBLIC void windown   (void);
PUBLIC void tcursor   (int onoff,int x,int y,int l);
PUBLIC void restore   (void);
PUBLIC void hideall   (void);
PUBLIC void saveid    (int id);



// PUBLIC SYMBOLS E

#ifdef WIN_C

#define IGNORE  0
#define RETRY   1
#define ABORT   2
#define FAIL    3

typedef struct {
    int     id ;
    int     x  ;
    int     y  ;
    int     x1 ;
    int     y1 ;
    int     l  ;
    int     *ni;
    LBFPTR  f  ;
    LBNFPTR nf ;
    int     tp ;
    int     sp ;
    int     otp;
    int     osp;
    int     sb ;
    int     v  ;
} LISTBOX;

typedef struct {
    int          x ;
    int          y ;
    int          x1;
    int          y1;
    unsigned int br;
    unsigned int bs;
    int          wn;
    int          aw;
    int          nb;
    int          bt[16];
    MBFPTR       f;
} MSGBOX;

typedef struct {
    int id;
    int x;
    int y;
    int x1;
    int y1;
    int ax;
    int ay;
    int ax1;
    int ay1;
    int t;
    int act;
    char *ti;
    WFPTR f;
    int   v;
} WINDOW;

typedef struct {
    int id;
    int x;
    int y;
    int x1;
    int y1;
    int t;
    int sst;
    void *uf;
    BFPTR f;
    int   v;
} BUTTON;

typedef struct {
    int id ;
    int x  ;
    int y  ;
    int x1 ;
    int y1 ;
    int p  ;
    int *l ;
    int pl ;
    int b  ;
    SBFPTR f;
    int   v;
} SCRLBAR;

typedef struct {
    int id;
    int x;
    int y;
    int x1;
    int y1;
    MENUITEM *f;
} MENU;

typedef struct {
    int    id ;
    int    x  ;
    int    y  ;
    int    x1 ;
    int    y1 ;
    int    l  ;
    int    w  ;
    char  *t  ;
    TBFPTR f  ;
    int    v  ;
    int    rw ;
    int    ins;
    int    cp ;
    int    lt ;
    char  *str;
} TEXTBOX;

#define M_START  0
#define M_UPBUT  8
#define SELBG   1
#define SELFG   0
#define UNSBG   0 
#define UNSFG   15
#define SBWID   16
#define MAXLB   20
#define MAXBT   50
#define MAXWN   20
#define MAXSB   40
#define MAXMN   10
#define MAXTB   40
#define MAXDBI  20

LISTBOX  G_lb[MAXLB];
WINDOW   G_wn[MAXWN];
BUTTON   G_bt[MAXBT];
SCRLBAR  G_sb[MAXSB];
MENU     G_mn[MAXMN];
TEXTBOX  G_tb[MAXTB];
MSGBOX   G_mb;
int      G_dbidx[MAXDBI];
int      G_numlb=0;
int      G_numwn=0;
int      G_numbt=0;
int      G_numsb=0;
int      G_nummn=0;
int      G_numtb=0;
int      G_sid[100];
int      G_numsid=0;
int      G_mxo  =0;
int      G_myo  =0;
int      G_msx  =0;
int      G_msy  =0;
int      G_numdbi=0;
int      G_dbaw  =0;
int      G_inbox=(-1);
void interrupt (*oldtimer)(void);
unsigned char *G_scradd;
unsigned char G_scrmask;
unsigned char G_cnt;
unsigned char G_tcursor=0;
unsigned char G_tcurlen=16;
unsigned char G_tcurof=0;

unsigned long G_old[128];
unsigned long G_curp[64] = {
	0x7FFFFFFFL,0x3FFFFFFFL,0x1FFFFFFFL,0x0FFFFFFFL,0x07FFFFFFL,0x03FFFFFFL,0x01FFFFFFL,0x00FFFFFFL,
    0x007FFFFFL,0x003FFFFFL,0x001FFFFFL,0x000FFFFFL,0x00FFFFFFL,0x00FFFFFFL,0x187FFFFFL,0x387FFFFFL,
    0x7C3FFFFFL,0xFC3FFFFFL,0xFE1FFFFFL,0xFE1FFFFFL,0xFF3FFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0x80000000L,0xC0000000L,0xA0000000L,0x90000000L,0x88000000L,0x84000000L,0x82000000L,0x81000000L,
    0x80800000L,0x80400000L,0x80200000L,0x83F00000L,0x89000000L,0x99000000L,0xA4800000L,0xC4800000L,
    0x82400000L,0x02400000L,0x01200000L,0x01200000L,0x00C00000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_curpss=0;
unsigned long G_curt[64] = {
	0x11FFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,
    0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0xEFFFFFFFL,0x11FFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0xEE000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,
    0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0x10000000L,0xEE000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_curtss=0x0300;
unsigned long G_curb[64] = {
	0x03FFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,
    0x7BFFFFFFL,0x7BFFFFFFL,0x7BFFFFFFL,0x03FFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0xFC000000L,0x84000000L,0x84000000L,0x84000000L,0x84000000L,0x84000000L,0x84000000L,0x84000000L,
    0x84000000L,0x84000000L,0x84000000L,0xFC000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L

};
unsigned int  G_curbss=0;
unsigned long G_curbw[64] = {
	0x000FFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,
    0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x000FFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0xFFF00000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,
    0x80100000L,0x80100000L,0x80100000L,0xFFF00000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_curbwss=0;
unsigned long G_curbh[64] = {
	0x000FFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,
    0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,
    0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x7FEFFFFFL,0x000FFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0xFFF00000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,
    0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,
    0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0x80100000L,0xFFF00000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_curbhss=0;
unsigned long G_curda[64] = {
	0xFF7FFFFFL,0xFE3FFFFFL,0xFC1FFFFFL,0xF80FFFFFL,0xF007FFFFL,0xE003FFFFL,0xC001FFFFL,0x8000FFFFL,
    0x00007FFFL,0x00007FFFL,0xF80FFFFFL,0xF80FFFFFL,0xF80FFFFFL,0xF80FFFFFL,0xF80FFFFFL,0xF80FFFFFL,
    0x00007FFFL,0x00007FFFL,0x8000FFFFL,0xC001FFFFL,0xE003FFFFL,0xF007FFFFL,0xF80FFFFFL,0xFC1FFFFFL,
    0xFE3FFFFFL,0xFF7FFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0x00800000L,0x01400000L,0x02200000L,0x04100000L,0x08080000L,0x10040000L,0x20020000L,0x40010000L,
    0x80008000L,0xFC1F8000L,0x04100000L,0x04100000L,0x04100000L,0x04100000L,0x04100000L,0x04100000L,
    0xFC1F8000L,0x80008000L,0x40010000L,0x20020000L,0x10040000L,0x08080000L,0x04100000L,0x02200000L,
    0x01400000L,0x00800000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_curdss=0x0800;
unsigned long G_curra[64] = {
	0xFE7FFFFFL,0xFE3FFFFFL,0xFE1FFFFFL,0xFE0FFFFFL,0x0007FFFFL,0x0003FFFFL,0x0001FFFFL,0x0000FFFFL,
    0x0001FFFFL,0x0003FFFFL,0x0007FFFFL,0xFE0FFFFFL,0xFE1FFFFFL,0xFE3FFFFFL,0xFE7FFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
    0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,0xFFFFFFFFL,
	0x01800000L,0x01C00000L,0x01E00000L,0x01F00000L,0xFFB80000L,0xFF9C0000L,0xC00E0000L,0xC0070000L,
    0xC00E0000L,0xFF9C0000L,0xFFB80000L,0x01F00000L,0x01E00000L,0x01C00000L,0x01800000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,
    0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L,0x00000000L
};
unsigned int  G_currss=0x0F07;
unsigned long *G_curs=G_curp;
unsigned int  G_curss=0;

unsigned long G_mask[8]={
    0x00000000L,0x80000000L,0xC0000000L,0xE0000000L,0xF0000000L,0xF8000000L,0xFC000000L,0xFE000000L
};
char *G_buttname[]={"OK","Yes","No","Cancel","Abort","Retry","Ignore","Fail"};

void            pbut        (int x,int y,int x1,int y1,int h);
void            nbut        (int x,int y,int x1,int y1);
void            drbt        (int b,int st);
void            drsb        (int s,uint st);
void            drwn        (int w,int st);
void            drlb        (int l,int st);
void            drmn        (int m,int st);
void            drtb        (int t,int st);
void            drdb        (int d,int st);
void            lbsbfunc    (int s,int mv,int p);
unsigned long   swapbytes   (unsigned long l);
int             itemofs     (int item);
int             getitemid   (int t);
void            delitem     (int item);
void            cursor      (int x,int y);
void            kbpoll      (void);
void            interrupt   ttimer(void);

#endif  //  def WIN_C

#endif  //  ndef WIN_H


