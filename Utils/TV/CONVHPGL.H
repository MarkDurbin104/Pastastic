/*-----------------------------Defines------------------------------------*/
#define bufend		8192
#define	PIC_EOI		0x20
#define	PIC_MASK	0x21
#define COMM_DATA	0x03F8
#define	COMM_IER	0x03F9
#define	COMM_MCR	0x03FC
#define	COMM_STAT	0x03FD
#define	COMM_INT	0x0C
#define	INT_MASK	0x10
#define DEGREE 180.0/M_PI

/*-----------------------------Variables----------------------------------*/
/*extern	int						oldvectseg;
extern	int						oldvectofs;
extern	char					buffer[bufend+1];
extern	char					*buf;
extern	int						point1,point2;*/
extern	int		GraphDriver,GraphMode;
extern	double	far	*ylook;
extern	double	far	*xlook;
extern	double	far	*alook;
extern	double	aspect;
extern	int		maxx,maxy;
extern	int		G_xcur,G_ycur;
extern	int		G_chord_tol;
extern	int		G_chawid;
extern	int		G_chahgt;
extern	char	far	*G_labbuf;
extern	int		G_charslnt;
extern	int		G_font;
extern	int		G_fill;
extern	int		G_onechar;
extern	int		G_pmask;
extern	int		G_emask;
extern	int		G_smask;
extern	int		G_afont;
extern	int		G_cfont;
extern	int		G_labwid;
extern	char	G_lterm;
extern	int		G_labhgt;
extern	int		G_labdir;
extern	int		G_lspace;
extern	int		G_llines;
extern	int		G_rotation;
extern	int		origx,origy;
extern	int		lorigx,lorigy;
extern	int		G_p1x;
extern	int		G_p1y;
extern	int		G_p2x;
extern	int		G_p2y;
extern	int		G_w1x;
extern	int		G_w2y;
extern	int		G_w1x;
extern	int		G_w2y;
extern	int		G_colour;
extern	int		G_linetype;
extern	int		penup;
extern		int	maxcordx;
extern		int	mincordx;
extern		int	maxcordy;
extern		int	mincordy;
extern	int		rxpos,rypos;
extern	int		nolines;
extern	int		nopolys;
extern	struct	arguments {
				int		no;
				int		orig[2];
				int		ag[50];
			} argus ;
extern	struct	farguments {
				int		no;
				double	ag[50];
			} arguf;
extern	char	far	*argut;
extern	char	seperator;
extern	char	terminator1;
extern	char	terminator2;
extern	struct	characters {
	    					char	nopts[93];
				unsigned	char	xy[93][16];
		       } charset[1] ;
extern	int		txpos;
extern	int		typos;
extern	int		wwidth;
extern	int		wlength;
extern	char	far	*textlns;
extern	int		maxtext;
extern	int		coords[500][2];
extern	int		nocds;
extern	long	divisor;
extern	long	plotsize[5];

/*-----------------------------Declarations--------------------------------*/

	void	interrupt	introutine(void);
	void				setcomms(void);
	void				restcomms(void);
	int					lookrx(void);
	int 				getrx(void);
	void				getvector(void);
	void				setvector(void);
	int					txchr(char outchr);
	int					txstr(char *string);
	int					txint(int number);
	int  				readinfile(char *filnam);
	void 				interpln(char *currentln);
	int  				readintext(char *filnam);
	int  				writeoutfile(char *filnam);
	int  				readindata(char *filnam);
	int  				findcomma(char *currentln);
	void 				getints(char *curln);
	void 				getchrs(char *curln);
	void 				gettxt(char *curln);
	void 				getflts(char *curln);
	void 				grafix(void);
	void 				chord(int x,int y,int x1,int y1,int ca,int n);
	void 				arcabs(int x,int y,int a,int tol);
	void 				arcrel(int x,int y,int a,int tol);
	void 				dpoly(int fill,int x,int y,int xr,int yr,
								int n,int rot,int st,int ed,int a,int z);
	void 				dslice(int fill,int x,int y,int xr,int yr,
								int n,int rot,int st,int ed,int a,int z);
	int  				rotapoly(int x,int y,int np,int *pp,double a,
								double z);
	void 				setuplook(void);
	int  				putfstr(int x,int y,int x1,int y1,int h,int w,
								int a,char *txt,int font,int rot);
	int  				putvstr(int x,int y,int x1,int y1,int h,int w,
								int a,char *txt,int font,int rot);
	void 				setupchar(void);
	void 				setdefaults(void);
	void 				drect(int fill,int x,int y,int x1,int y1);
	void 				ddrawpoly(int fill,unsigned int np,int far *polyp);
