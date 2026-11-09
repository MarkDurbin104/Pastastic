					/*	ENABLE/DISABLE SECTIONS OF THE PROGRAM		*/
#define CPNO	0   /*	print part No. on console					*/
#define WPNO	0   /*	print part No. on console at top level		*/
/*#define PPNO	0   /*	print part No. on parallel port				*/
#define SPNO	2   /*	print part No. on serial port SPNO			*/
#define CPNPE   0	/*	print number of parts expected on console	*/
#define WPNPE   0	/*	print number of parts expected on window	*/
#define ONPPN   0	/*	output number of parts left with part No.	*/
#define DENPE   0	/*	decrement number of parts expected			*/
#define JOADK   0	/*	join output and decrement/increment keys	*/
#define AROUT   0	/*	allow reenstatment of out parts				*/
#define DOUTP   0	/*	dim image of out parts						*/
#define SLEFP   0	/*	save all left parts on exit					*/
#define INCNP   0	/*	increment number of parts insted			*/
#define FRONT   0	/*	print front screen message					*/
#define BSCRL   0	/*	scroll the bar down the screen				*/
#define DEMOM   0	/*	print demo message 							*/
#define VT100   0	/*	allow vt100 terminal emulation				*/
#define VTINT   0	/*	allow vt100 to interrupt view				*/
#define TEXTW   0	/*	allow text in window						*/
#define PSCRD   0	/*	allow screen dump to parallel port			*/
/*#define SSCRD   0	/*	allow screen dump to serial port(SPNO)		*/
/*#define MOUSE   0 /*  enable mouse								*/

					/* PARAMETERS									*/
#define SEPERATORS ",. \t\n\r\0" /* possible parameter seperators	*/
#define CURSTEP 20	/* the scroll/pan pixel step size				*/
#define MAXZOOM 0	/* the number of zoom levels 					*/
#define BACKCOL 1	/* the window outline colour					*/
#define QUICK	1	/* 1 quick scroll 0 slow scroll	2 dots scroll	*/

					/* MACRO'S										*/
#define SAVEMSTO(s)		movedata(0xB000,0x0000,FP_SEG(s),FP_OFF(s),4000);
#define LOADMSFROM(s) 	movedata(FP_SEG(s),FP_OFF(s),0xB000,0x0000,4000);
#define SAVECSTO(s)		movedata(0xB800,0x0000,FP_SEG(s),FP_OFF(s),4000);
#define LOADCSFROM(s) 	movedata(FP_SEG(s),FP_OFF(s),0xB800,0x0000,4000);

extern	int		GraphDriver,GraphMode;
extern	double	aspect;
extern	int		maxx,maxy;
extern	int		pickno;
extern	int		G_notosel;
extern	char	G_partnumb[66][20];
extern	int		G_numbparts[2][66];
extern	char	maxlevel[66];
extern	char	G_omitlev;
extern	char	G_steplev;
extern	char	G_onlylev;
extern	int		difx[66];
extern	int		dify[66];
extern	int		minx[66];
extern	int		miny[66];
extern	int		curposx,curposy;
extern	int		nopolys[66];
extern	int		maxpoints[66];
extern	int		maxnopps;
extern	int		nofiles;
extern	int		G_swap[66];
extern	int		crossbdn;
extern	int		G_level1;
extern	int		G_winpos[36];
extern	int		G_tno;
extern	char	far	*textlns[64];
extern	int		maxtext[64];
extern	int		textpos[64];
extern  char	overtext;
extern	int		textcol;
extern	int		G_hno;
extern	char	helplns[2000];
extern	int		maxhelp;
extern	int		helppos;
extern  char	overhelp;
extern	int		helpcol;
extern	char    bars[51][10];
extern	int screen[2000];
extern	int terminal[2160];
extern	struct pnts {
		unsigned	char	typacol;
		unsigned	char	ltafs;
		unsigned	int		nopts;
		int	far	*base;
	} far **polp[66];
extern	char bitmap[4][1000];
extern	char copyimg[2000];
extern	char copymsg[30];
extern	int pickno;
extern	int G_zoom;
extern	int colours[16];
extern	char chpos[10];
extern	char noln[9][2];
extern	char p[129][2];
extern	char G_filename[80];
extern	struct text_info scrsave;
extern	struct term_info {
			char	type[6];
			int		baud;
			char	bits;
			char	parity;
			char	stop;
			char	handshake[9];
		} G_term;
extern	int		termx;
extern	int		termy;
extern	int		termattr;
extern	int		interm;
extern	int		locecho;
extern	int far *scr;

void drawdiag(int diagno,int xp,int yp,int zoom,int interp);
void adjdiag(int diagno,int xp,int yp,int zoom);
void grafix(void);
int  readindata(int diagno,char *filnam);
void drawmini(int diagno,int crbdn);
int  loadfiles(char *filnam);
int  cursor(int cpos);
int  getkeys(void);
void blancdisp(void);
int  setup(void);
void startup(char *filename);
void reset(void);
void setupterm(void);
void switchscr(void);
int  prtv(int x,int y,int zoom,int col);
int  pltv(int x,int y,int zoom);
void setcur(void);
int selafile(char *path);
void farfreepolys(void);
void dela(int mili);
void placrx(char ch);

