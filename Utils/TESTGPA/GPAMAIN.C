//SYSDOC GPAMAIN.DOC
#define GPA_C

#include <string.h>
#include <conio.h>
#include <stdio.h>
#include <memory.h>
#include <malloc.h>
#include <dos.h>
#include <direct.h>
#include <io.h>
#include <fcntl.h>
#include <stdlib.h>
#include <time.h>
#include <conio.h>
#include <process.h>

#include "types.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "dst.h"
#include "menuproc.h"
#include "fldproc.h"
#include "formhand.h"
#include "translog.h"
#include "actionc.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "arith.h"
#include "lang.h"
#include "ossdev.h"

#ifdef __DPMI32__
#include "extrdpmi.h"
#endif

extern unsigned _stklen=8192;
extern LONG G_forvars;
CHAR *G_workbuff;     // for use by the Pkware libraries

char **G_argv;
int  G_argc;

typedef struct {
    ULONG  EDI,ESI,EBP,reserved,EBX,EDX,ECX,EAX;
    UINT16 flags,ES,DS,FS,GS,IP,CS,SP,SS;
} RM_REGS;
typedef union  REGS  REG;
typedef struct SREGS SREG;

int G_ctr=0;
//************************************************************
//F outputrep
//S Output the GPAFUNC.LST data
//D Outputs the action names and user function names
void outputrep(void)
{
	FILE *fp;
	INT i;
	ENTRY(490);
	if ((fp=fopen("GPAFUNC.LST","w"))!=NULL) {
		i=0;
		while (G_actmap[i].name!=NULL) fprintf(fp,"G %s\n",G_actmap[i++].name);
		i=0;
		while (G_ufunc[i].name!=NULL) fprintf(fp,"U %s\n",G_ufunc[i++].name);
		fclose(fp);
	}
	RETURN;
}
//************************************************************
//F prps
//S Print the printer status (printer flag)
INT prps(void)
{
	ENTRY(491);
    sendmsg("OUTPUT2",MESSAGE_GS);
	RETURNV(0);
}
//************************************************************
//F prw
//S Print the weight at x=G_weightat[0],y=G_weightat[1]
//D If weigh machine attached read the scale and then display
//D the weight.
INT prw(void)
{
	static INT lw=(-1),etop=(-1);
//	static INT mja=0,mna=0,oserv=0;
	INT w=0;
//	INT c=0,a=0,b=0;
	INT ft=G_form.type;
	CHAR tmp[10];
	ENTRY(492);
	if (!G_weighton) RETURNV(1);
	
	w=G_scaleout; //sendmsg("INPUT2",MESSAGE_i);
	G_form.type=F_NORM;
	if (w==0) {
		if (etop>=0) {
			if ((++etop)>=5) {
				etop=(-1);
				exit2top();
			}
		}
	} else {
		etop=0;
	}
	if (w!=lw) {
		if (lw==0) {
			sendmsg("INPUT1",MESSAGE_P,(-61));
			sendmsg("INPUT1",MESSAGE_P,5000);
		}
	   	lw=w;
	   	sendmsg("INPUT1",MESSAGE_rt);
	}
	sendmsg("OUTPUT1",MESSAGE_A,0);
	if (w>0) {
		output(G_weightat[0],G_weightat[1]+2,G_dispwgt,strlen(G_dispwgt),"X",2,0);
		sprintf(tmp,"%d",w);
		output(G_weightat[0],G_weightat[1],tmp,7,"W",G_weightat[2],0);
	} else {
		sendmsg("OUTPUT1",MESSAGE_S,1);
		sendmsg("OUTPUT1",MESSAGE_o,G_weightat[0],G_weightat[1]+2,"%*.*s",strlen(G_dispwgt),strlen(G_dispwgt),"");
		sendmsg("OUTPUT1",MESSAGE_o,G_weightat[0],G_weightat[1]  ,"%*.*s",strlen(G_dispwgt),strlen(G_dispwgt),"");
	}
/*
	c=(INT)sendmsg("OUTPUT4",MESSAGE_GA);
	if ((c&2)!=2) {
		if (mna==0) mna++;
		if (mna==1) {
			mna++;
			if (isform("minoralm")!=(-1L)) {
				while ((sendmsg("OUTPUT4",MESSAGE_GA)&2)!=2) {
					if (G_exit2top) G_exit2top=0;
					runaction("minoralm");
				}
				mna=0;
			}
		}
	}
	if (mna==0) {
		if ((c&1)!=1) {
			if (mja==0) mja++;
			if (mja==1) {
				mja++;
				if (isform("majoralm")!=(-1L)) {
					while ((sendmsg("OUTPUT4",MESSAGE_GA)&1)!=1) {
						if (G_exit2top) G_exit2top=0;
						runaction("majoralm");
					}
					mja=0;
				}
			}
		}
		if (mja==0) {
			a=(INT)sendmsg("STAMP",MESSAGE_GS,1);
			b=(INT)sendmsg("STAMP",MESSAGE_GS,2);
			c=(INT)sendmsg("PRN",MESSAGE_GS);
			if (((a!=0)&&(b!=0))||(c>0)) {
				if (oserv==0) oserv++;
				if (oserv==1) {
					oserv++;
					if (isform("oservice")!=(-1L)) {
						while ((sendmsg("PRN",MESSAGE_GS)!=0)
							|| ((sendmsg("STAMP",MESSAGE_GS,1))
							&&  (sendmsg("STAMP",MESSAGE_GS,2)))) {
							if (G_exit2top) G_exit2top=0;
							runaction("oservice");
						}
						oserv=0;
					}
				}
			} else {
				if (!strcmp(G_form.name,"oservice")) {
					exit2top();
					sendmsg("INPUT1",MESSAGE_P,13);
    				sendmsg("INPUT1",MESSAGE_P,5000);
				}
			}
		}
	}
*/
	G_form.type=(CHAR)ft;
    RETURNV(1);
}
//************************************************************
//F prc
//S Print the coins at x=G_coinat[0],y=G_coinat[1]
//D 
INT prc(void)
{
	static INT lc=(-1);
	INT c=0,a=0;
	INT ft=G_form.type;
	CHAR tmp[10];
	ENTRY(494);
	if (!G_coinon) RETURNV(1);

	G_form.type=F_NORM;
	if (sendmsg("8255",MESSAGE_GS,2)==0) {
		sendmsg("OUTPUT1",MESSAGE_A,0);
		output(0,0,G_exact,strlen(G_exact),"X",1,0);
	} else {
		sendmsg("OUTPUT1",MESSAGE_S,1);
		sendmsg("OUTPUT1",MESSAGE_A,0);
		sendmsg("OUTPUT1",MESSAGE_o,0,0,"%*.*s",strlen(G_exact),strlen(G_exact),"");
	}
	c=(INT)sendmsg("OUTPUT4",MESSAGE_GC,&a,&a,&a,&a,&a);
	if (c!=lc) { lc=c; sendmsg("INPUT1",MESSAGE_rt); }
	if (c>0) {
		output(G_coinat[0]-2,G_coinat[1],G_moneys,1,"X",G_coinat[2],0);
		sprintf(tmp,"%d",c);
		output(G_coinat[0],G_coinat[1],tmp,5,"M",G_coinat[2],0);
	} else {
		sendmsg("OUTPUT1",MESSAGE_o,G_coinat[0]-2,G_coinat[1],"%*.*s",11,11,"");
	}
	G_form.type=(CHAR)ft;
    RETURNV(1);
}
#ifdef __DPMI16__
void setfilemax (void);
#pragma startup setfilemax 64 // priority at startup
//************************************************************
//F setfilemax
//S set the maximum DOS file handles
//D 
void setfilemax (void)
{
    asm { //;   If default number of file handles have changed then tell DOS
		mov     _nfile, _NFILE_
		cmp     _nfile, 20
		jbe     NoChange

		cmp     [_osmajor], 3   ;// Check for >= DOS 3.3
		jb      NoChange
		ja      DoChange
		cmp     [_osminor], 1Eh
		jb      NoChange
    } DoChange:
    asm {
		mov     ax, 5801h      //; Set last fit allocation
		mov     bx, 2
		int     21h
		jc      BadInit

		mov     ah, 67h        //; Expand handle table
		mov     bx, _nfile
		int     21h
		jc      BadInit

		mov     ax, 5801h      //; Set first fit allocation
    	mov     bx, 0
		int     21h
		jnc     NoChange

    } BadInit:
		abort ();

    NoChange:
    return;
}
#endif
//************************************************************
//F main
//S GPA runtime    Usage - "GPA system_name"
//D Output the GPAFUNC.LST report, check input parameters, get
//D working directory, init devices, read configuration, initialize
//D datastores, load forms, load actions, load keyboard, load font,
//D load text. Call form processing and wait for exit.  Tidy up
//D and return.
//P argc
//P argv
int main(int argc,char *argv[]) 
{
    INT i,x,y,b;
//    UINT a;
    CHAR *t;
    static CHAR str[100];
//    memset(G_funclog,0,sizeof(G_funclog));
	ENTRY(500);
#ifdef __TURBOC__
#ifdef __DPMI32__
    COLVIDMEM=MK_FP(0xA000,0x0000,0x00020000);
    MONOVIDMEM=COLVIDMEM+0x00010000;
    TEXTVIDMEM=COLVIDMEM+0x00018000;
#else
    COLVIDMEM=MK_FP(__SegA000,0x0000);
    COLVIDSEG=__SegA000;
    MONOVIDMEM=MK_FP(__SegB000,0x0000);
    TEXTVIDMEM=MK_FP(__SegB800,0x0000);
#endif
    G_sstart=farcoreleft();
#endif //def __TURBOC__
	outputrep();

    G_criterrscrnbuf=(CHAR *)MALLOC(CE_BYTEWIDTH*CE_HEIGHT*4);    // Screen save memory buffer
    setprotmodeint();

    t=getenv("GPACFG");
    if (t!=NULL) {
	    strcpy(str,t);
        if (argc>=2) {
		    t=strrchr(argv[1],'.');
		    if (t==NULL) strcpy(str,argv[1]);
	    }
    } else {
        if (argc<2) {
		    printf("GPA Config\n");
		    RETURNV(-1);
	    } else {
		    t=strrchr(argv[1],'.');
		    if (t==NULL) strcpy(str,argv[1]);
	    }
    }
    G_curdir[0]='\\';
#ifdef __TURBOC__
   	getcurdir(0,&G_curdir[1]);
#else
	getcwd(&G_curdir[1],78);
#endif 
	t=strrchr(str,'\\');
	if (t!=NULL) {
		*t=0;
		t++;
		strcpy(G_cfgdir,str);
	} else {
		t=str;
		strcpy(G_cfgdir,G_curdir);
	}
	chdir(G_cfgdir);

//    i=MEMinitSwapFile("SWAPFILE.GPA",0x400000L);
 	if (!initdevices()) {
        printf("Can't initialise devices (None Found!)\n");
    	chdir(G_curdir);
        RETURNV(1);
	}
	if (!readconfig(t)) {
        printf("Error reading config file %s\n",t);
		RETURNV(0);
	}
    G_workbuff=(CHAR *)MALLOC(35256U);      // malloc memory for backup
                      // In here to see if it fixes backup bug - Tom 23/1/95

    loadsdata(G_system);
    if (!sendmsg("DBM",MESSAGE_I,G_system)) {
        printf("Can't initialise Datastores for %s %d\n",G_system,G_sstat[0].err);
    	chdir(G_curdir);
        RETURNV(1);
    }
#ifndef TEXTMODE
    fclose(stdin);    // FREE UP 3 FILE DECRIPTORS (The things you have to do?)
#endif
    fclose(stderr);   // Dont close stdout or stdprn the're used
    fclose(stdaux);
    if (!sendmsg("OUTPUT1",MESSAGE_I)) {
		printf("Can't load screen device\n");
    	chdir(G_curdir);
		RETURNV(0);
	}
    if (argc<3) strcpy(G_form.name,"logon"); else strcpy(G_form.name,argv[2]); 
    G_form.items=NULL;
    if (!loadform(&G_form)) {
        printf("Can't load form logon for %s\n",G_system);
    	chdir(G_curdir);
        RETURNV(1);
    }
    if (!loadactions(G_system)) {
        printf("Can't load actions for %s\n",G_system);
    	chdir(G_curdir);
        RETURNV(1);
    }
//    sendmsg("OUTPUT1",MESSAGE_GP,G_defpal);
    if (!sendmsg("INPUT1",MESSAGE_I)) {
		printf("Can't load keyboard mapping\n");
    	chdir(G_curdir);
		RETURNV(0);
	}
    if (G_numlockon) sendmsg("INPUT1",MESSAGE_NL,G_numlockon);

//	for (G_lang=G_numlang-1;G_lang>=0;G_lang--) {
//		readlang(G_lang);
//    	freetext();
//    	loadtext(G_system);
//		sendmsg("OUTPUT1",MESSAGE_F,G_fontfile);
//		G_scanmap=readkeys();
//		addlangname(G_name);
//	}
//	G_lang=0;
    if (sendmsg("OUTPUT1",MESSAGE_F,G_fontfile)==0) {
		sendmsg("OUTPUT1",MESSAGE_E);
		sendmsg("INPUT1",MESSAGE_E);
        printf("Can't Load font %s\n",G_fontfile);
    	chdir(G_curdir);
        RETURNV(1);
    }
 	sendmsg("OUTPUT1",MESSAGE_0);

//    if (!readoffdet()) {
//        sendmsg("OUTPUT1",MESSAGE_E);
//        sendmsg("INPUT1",MESSAGE_E);
//        sendmsg("DBM",MESSAGE_E);
//        printf("No office details found in [%s]\n",G_offdets);
//    	chdir(G_curdir);
//        RETURNV(1);
//    }

    G_nocache=!(atoi(G_cache));

    if (atoi(G_cache)==23) bd[0]=(-1);
    
    sendmsg("DISK",MESSAGE_I);

	for (i=0;i<4;i++) G_exitkeys[i]=NULL;
    if (!loadtext(G_system)) {
        sendmsg("OUTPUT1",MESSAGE_E);
        sendmsg("INPUT1",MESSAGE_E);
        sendmsg("DBM",MESSAGE_E);
        sendmsg("DISK",MESSAGE_E);
        printf("Can't load text for %s\n",G_system);
    	chdir(G_curdir);
        RETURNV(1);
    }
    G_netok=(INT)sendmsg("LAN",MESSAGE_I,G_position);
    sendmsg("COMM",MESSAGE_SI);
    sendmsg("SCALE",MESSAGE_I);

//    sendmsg("COM4",MESSAGE_I,GRAPHIC);
//    sendmsg("COM4",MESSAGE_i,9600,8,'N',1);
//    sendmsg("COM4",MESSAGE_b,26,60);

    sendmsg("OUTPUT2",MESSAGE_I);
//    sendmsg("PRN",MESSAGE_I,STANDARD);
//    sendmsg("PRN",MESSAGE_b,80,60);
//    sendmsg("PRN2",MESSAGE_I,STANDARD);
//    sendmsg("PRN2",MESSAGE_b,80,60);
//    sendmsg("PRN3",MESSAGE_I,GRAPHIC);
//    sendmsg("PRN3",MESSAGE_b,80,60);

	sendmsg("INPUT2",MESSAGE_I);
    sendmsg("INPUT3",MESSAGE_I);
	sendmsg("OUTPUT4",MESSAGE_I);

//    sendmsg("COM1",MESSAGE_I,TRANSLATE);
//    sendmsg("COM1",MESSAGE_i,9600,8,'N',1);
//    sendmsg("COM1",MESSAGE_b,40,9);
//    sendmsg("OUTPUT2",MESSAGE_S,1);


    if (sendmsg("INPUT1",MESSAGE_H)) {	// if key pressed - wait for another
		sendmsg("INPUT1",MESSAGE_i);
		while (!sendmsg("INPUT1",MESSAGE_H)) {
			b=0;
			sendmsg("INPUT3",MESSAGE_i,&x,&y,&b);
			if ((b==2)&&((x>=290)&&(x<=295))&&((y>=60)&&(y<=65))) {
				while (b!=0) sendmsg("INPUT3",MESSAGE_i,&x,&y,&b);
				sendmsg("OUTPUT1",MESSAGE_AN,21,2,5,5,"CYCLE.BMP");
				sendmsg("OUTPUT1",MESSAGE_SC,35,2,4,2,5,"CREDITS.BMP");
			}
		}
		sendmsg("INPUT1",MESSAGE_i);
	}
    if (G_form.type==F_MENU) {
        orderform(&G_form,1);
        runmenu();
    }
    else {
        orderform(&G_form,0);
        if (!initform(&G_form)) {
			sendmsg("OUTPUT4",MESSAGE_E);
            sendmsg("LAN",MESSAGE_E);
            sendmsg("INPUT1",MESSAGE_E);
            sendmsg("SCALE",MESSAGE_E);
            sendmsg("DISK",MESSAGE_E);
	        sendmsg("DBM",MESSAGE_E);
            sendmsg("OUTPUT1",MESSAGE_E);
            sendmsg("OUTPUT2",MESSAGE_E);
		    sendmsg("COMM",MESSAGE_SE);
            printf("Can't init form logon for %s\n",G_system);
        	chdir(G_curdir);
            RETURNV(1);
        }
        do {
			G_exit2top=0;
			G_exit2mrk=0;
			G_uid=0;
            sendmsg("OUTPUT1",MESSAGE_R);
			prdate();
		    sendmsg("INPUT1",MESSAGE_A,9,prdate);
		    sendmsg("INPUT1",MESSAGE_A,9,prps);
			if (G_weighton) sendmsg("INPUT1",MESSAGE_A,36,prw);
			if (G_coinon  ) sendmsg("INPUT1",MESSAGE_A,9,prc);
            sendmsg("OUTPUT1",MESSAGE_SP,G_palentry);
            if (!runform(2)) {
				sendmsg("OUTPUT4",MESSAGE_E);
                sendmsg("LAN",MESSAGE_E);
                sendmsg("INPUT1",MESSAGE_E);
                sendmsg("SCALE",MESSAGE_E);
                sendmsg("DISK",MESSAGE_E);
    		    sendmsg("DBM",MESSAGE_E);
                sendmsg("OUTPUT1",MESSAGE_E);
                sendmsg("OUTPUT2",MESSAGE_E);
			    sendmsg("COMM",MESSAGE_SE);
                printf("Can't run form logon for %s\n",G_system);
            	chdir(G_curdir);
                RETURNV(1);
            }
			if (G_weighton) sendmsg("INPUT1",MESSAGE_D,prw);
			if (G_coinon  ) sendmsg("INPUT1",MESSAGE_D,prc);
		    sendmsg("INPUT1",MESSAGE_D,prdate);
		    sendmsg("INPUT1",MESSAGE_D,prps);
			G_luid=G_uid;
			sprintf(str,"%d",(INT)G_uid);
			sendmsg("LAN",MESSAGE_l,str);
        } while (bd[0]!=(-1));
        sendmsg("DBM",MESSAGE_ca);
        clrform(&G_form);
    }
	sendmsg("OUTPUT4",MESSAGE_E);
    sendmsg("INPUT3",MESSAGE_E);
    sendmsg("INPUT2",MESSAGE_E);
    sendmsg("PRN",MESSAGE_E);
    sendmsg("PRN2",MESSAGE_E);
    if (G_refson) printf("E");
    sendmsg("OUTPUT1",MESSAGE_R);
    sendmsg("OUTPUT1",MESSAGE_SP,G_defpal);
    sendmsg("OUTPUT1",MESSAGE_E);
    sendmsg("COMM",MESSAGE_SE);
	if (G_refson) printf("A");
    sendmsg("LAN",MESSAGE_E);
    if (G_refson) printf("B");
    sendmsg("DISK",MESSAGE_E);
    if (G_refson) printf("C");
    sendmsg("SCALE",MESSAGE_E);
    if (G_refson) printf("D");
    sendmsg("DBM",MESSAGE_E);
    if (G_refson) printf("F");
    sendmsg("INPUT1",MESSAGE_E);
    if (G_refson) printf("G\n");
    if (G_refson) printf("1");
    freeform(&G_form);
    if (G_refson) printf("2");
//    for (i=0;i<G_numn;i++) printf("%s %d\n",G_anamebuf[i].n,G_anamebuf[i].i);
    if (G_workbuff) {
        FREE(G_workbuff);       // allocated for backup
    }
    if (G_workbuff) {
        FREE(G_criterrscrnbuf);
    }
    freeactions();
    if (G_refson) printf("3");
//    freetext();
    if (G_refson) printf("0");
    if (G_ridxbuf!=NULL) { FREE(G_ridxbuf); G_ridxbuf=NULL; }
    if (G_refson) printf("1");
    freeformidx();
    if (G_refson) printf("2");
	if (G_refson) prdevlist();
 	closedevices();
	clrconfig();
    if (((G_nummall+G_numstrd)-G_numfree!=0L)&&(G_refson)) {
        printf("f=%ld m=%ld r=%ld s=%ld %ld free's missing\n",G_numfree,G_nummall,G_numreal,G_numstrd,(G_nummall+G_numstrd)-G_numfree);
        printf("Errors in f=%ld m=%ld r=%ld s=%ld\n",G_numfreeerr,G_nummallerr,G_numrealerr,G_numstrderr);
    }
 	arithend();
	if (G_refson) printf("Max mem %lu Max Block %lu Current %lu\n",G_maxmem,G_maxblk,G_curmem);
	chdir(G_curdir);
#ifdef __DPMI32__
    freeblks();
#endif
//    MEMcloseSwapFile(1);
//    for (a=1000;a<65535U;a++) {
//        for (i=0;i<sizeof(G_funclog)/sizeof(int);i++) {
//            if (G_funclog[i]==a) printf("%4d0 %-6u\n",i,G_funclog[i]);
//        }
//    }
    
//    for (a=0;a<16;a++) {
//        printf("    0x%02X,0x%02X,0x%02X \/\/ %d\n",*(G_defpal+a*3),*(G_defpal+a*3+1),*(G_defpal+a*3+2),a);
//    }
    RETURNV(0);
}
//************************************************************
// End of file - gpamain.c


