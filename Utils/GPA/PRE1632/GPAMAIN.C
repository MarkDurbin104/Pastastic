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

#include "types.h"
#include "config.h"
#include "message.h"
#include "formproc.h"
#include "dst.h"
#include "menuproc.h"
#include "fldproc.h"
#include "formhand.h"
#include "translog.h"
#include "actions.h"
#include "function.h"
#include "control.h"
#include "memory.h"
#include "arith.h"
#include "lang.h"

extern unsigned _stklen=8192;
extern LONG G_forvars;
extern INT  *G_ridxbuf;
#if (M_DEBUG==1)
extern void setbase(void);
#endif
extern void fincalc(void);

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
INT prps(void)
{
	ENTRY(491);
    sendmsg("OUTPUT2",'PS');
	RETURNV(0);
}
INT prw(void)
{
	static INT lw=(-1),etop=(-1);
	static INT mja=0,mna=0,oserv=0;
	INT w=0;
	INT c=0,a=0,b=0;
	INT ft=G_form.type;
	CHAR tmp[10];
	ENTRY(492);
	if (!G_weighton) RETURNV(1);
	
	w=sendmsg("INPUT2",'i');
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
			sendmsg("INPUT1",'P',(-61));
		}
	   	lw=w;
	   	sendmsg("INPUT1",'rt');
	}
	sendmsg("OUTPUT1",'A',0);
	if (w>0) {
		output(G_weightat[0],G_weightat[1]+2,G_dispwgt,strlen(G_dispwgt),"X",2);
		sprintf(tmp,"%d",w);
		output(G_weightat[0],G_weightat[1],tmp,7,"W",G_weightat[2]);
	} else {
		sendmsg("OUTPUT1",'S',1);
		sendmsg("OUTPUT1",'o',G_weightat[0],G_weightat[1]+2,"%*.*s",strlen(G_dispwgt),strlen(G_dispwgt),"");
		sendmsg("OUTPUT1",'o',G_weightat[0],G_weightat[1]  ,"%*.*s",strlen(G_dispwgt),strlen(G_dispwgt),"");
	}
	c=sendmsg("OUTPUT4",'GA');
	if ((c&2)!=2) {
		if (mna==0) mna++;
		if (mna==1) {
			mna++;
			if (isform("minoralm")!=(-1L)) {
				while ((sendmsg("OUTPUT4",'GA')&2)!=2) {
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
					while ((sendmsg("OUTPUT4",'GA')&1)!=1) {
						if (G_exit2top) G_exit2top=0;
						runaction("majoralm");
					}
					mja=0;
				}
			}
		}
		if (mja==0) {
			a=sendmsg("STAMP",'GS',1);
			b=sendmsg("STAMP",'GS',2);
			c=sendmsg("PRN",'GS');
			if (((a!=0)&&(b!=0))||(c>0)) {
				if (oserv==0) oserv++;
				if (oserv==1) {
					oserv++;
					if (isform("oservice")!=(-1L)) {
						while ((sendmsg("PRN",'GS')!=0)
							|| ((sendmsg("STAMP",'GS',1))
							&&  (sendmsg("STAMP",'GS',2)))) {
							if (G_exit2top) G_exit2top=0;
							runaction("oservice");
						}
						oserv=0;
					}
				}
			} else {
				if (!strcmp(G_form.name,"oservice")) {
					exit2top();
					sendmsg("INPUT1",'P',13);
				}
			}
		}
	}
	G_form.type=ft;
    RETURNV(1);
}
INT prc(void)
{
	static INT lc=(-1);
	INT c=0,a=0;
	INT ft=G_form.type;
	CHAR tmp[10];
	ENTRY(494);
	if (!G_coinon) RETURNV(1);

	G_form.type=F_NORM;
	if (sendmsg("8255",'GS',2)==0) {
		sendmsg("OUTPUT1",'A',0);
		output(0,0,G_exact,strlen(G_exact),"X",1);
	} else {
		sendmsg("OUTPUT1",'S',1);
		sendmsg("OUTPUT1",'A',0);
		sendmsg("OUTPUT1",'o',0,0,"%*.*s",strlen(G_exact),strlen(G_exact),"");
	}
	c=sendmsg("OUTPUT4",'GC',&a,&a,&a,&a,&a);
	if (c!=lc) { lc=c; sendmsg("INPUT1",'rt'); }
	if (c>0) {
		output(G_coinat[0]-2,G_coinat[1],G_moneys,1,"X",G_coinat[2]);
		sprintf(tmp,"%d",c);
		output(G_coinat[0],G_coinat[1],tmp,5,"M",G_coinat[2]);
	} else {
		sendmsg("OUTPUT1",'o',G_coinat[0]-2,G_coinat[1],"%*.*s",11,11,"");
	}
	G_form.type=ft;
    RETURNV(1);
}
void memused(INT a)
{
    static LONG u=0L;
    LONG c;
    if (u==0L) {
//        u=memleft();
//        printf("Start with                         %10ld\n",u);
    } else {
        c=memleft();
//        printf("At %02d Used another %10ld Free=%10ld Maxblk=%d\n",a,u-c,c,G_maxblk);
//        G_maxblk=0; // ****************************
        a++;
        u=c;
    }
}
// GPA runtime    Usage - "GPA system_name"
INT main(INT argc,CHAR *argv[]) 
{
    INT i,x,y,b;
    CHAR tmp[100],*t;
	ENTRY(500);
    memused(0);
#ifdef __TURBOC__
	G_sstart=((_SS<<16)|_SP);
#endif
#if (M_DEBUG==1)
	setbase();
#endif
    memused(1);
	outputrep();
    memused(2);
	strcpy(tmp,getenv("GPACFG"));
    if (argc<2) {
		if (tmp==NULL) {
			cleanupblks(0);
			printf("GPA Config\n");
			RETURNV(-1);
		}
	} else {
		t=strrchr(argv[1],'.');
		if (t==NULL) strcpy(tmp,argv[1]);
	}
	G_curdir[0]='\\';
#ifdef __TURBOC__
	getcurdir(0,&G_curdir[1]);
#else
	getcwd(&G_curdir[1],78);
#endif 
    memused(3);
	t=strrchr(tmp,'\\');
	if (t!=NULL) {
		*t=0;
		t++;
		strcpy(G_cfgdir,tmp);
	} else {
		t=tmp;
		strcpy(G_cfgdir,G_curdir);
	}
	chdir(G_cfgdir);
    memused(4);
	if (!readconfig(t)) {
        printf("Error reading config file %s\n",t);
		cleanupblks(0);
		RETURNV(0);
	}
    memused(5);
    if (argc<3) strcpy(G_form.name,"logon"); else strcpy(G_form.name,argv[2]); 
    G_form.items=NULL;
    if (!loadform(&G_form)) {
        printf("Can't load form logon for %s\n",G_system);
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
    }
    memused(6);
    if (!loadactions(G_system)) {
        sendmsg("INPUT1",'E');
        sendmsg("DISK",'E');
        sendmsg("DBM",'E');
        sendmsg("OUTPUT1",'E');
        printf("Can't load actions for %s\n",G_system);
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
    }
    memused(7);
 	if (!initdevices()) {
        printf("Can't initialise devices (None Found!)\n");
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
	}
    memused(8);
    if (!sendmsg("OUTPUT1",'I')) {
		sendmsg("INPUT1",'E');
		printf("Can't load screen device\n");
    	chdir(G_curdir);
		cleanupblks(0);
		RETURNV(0);
	}
    memused(9);
    sendmsg("OUTPUT1",'GP',G_defpal);
    memused(10);
    if (!sendmsg("INPUT1",'I')) {
        sendmsg("DBM",'E');
		printf("Can't load keyboard mapping\n");
    	chdir(G_curdir);
		cleanupblks(0);
		RETURNV(0);
	}
    memused(11);
    if (!sendmsg("DBM",'I',G_system)) {
        printf("Can't initialise Datastores for %s\n",G_system);
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
    }
    memused(12);
	for (G_lang=G_numlang-1;G_lang>=0;G_lang--) {
		readlang(G_langfiles[G_lang]);
        memused(121);
    	freetext();
        memused(122);
    	loadtext(G_system);
        memused(123);
		sendmsg("OUTPUT1",'F',G_fontfile);
        memused(124);
		G_scanmap=readkeys();
        memused(125);
		addlangname(G_name);
        memused(126);
	}
    memused(13);
	G_lang=0;
    sendmsg("OUTPUT1",'F',G_fontfile);
 	sendmsg("OUTPUT1",'0');

    memused(14);
    if (!readoffdet()) {
        sendmsg("OUTPUT1",'E');
        sendmsg("INPUT1",'E');
        sendmsg("DBM",'E');
        printf("No office details found in [%s]\n",G_offdets);
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
    }
    memused(15);

    G_nocache=!(atoi(G_cache));

    if (atoi(G_cache)==23) bd[0]=(-1);
    
    sendmsg("DISK",'I');
    memused(16);

	for (i=0;i<4;i++) G_exitkeys[i]=NULL;
    if (!loadtext(G_system)) {
        sendmsg("INPUT1",'E');
        sendmsg("DBM",'E');
        sendmsg("DISK",'E');
        sendmsg("OUTPUT1",'E');
        printf("Can't load text for %s\n",G_system);
    	chdir(G_curdir);
		cleanupblks(0);
        RETURNV(1);
    }
    memused(17);
    G_netok=sendmsg("LAN",'I',G_position);
    sendmsg("COMM",'SI');
    memused(18);
    sendmsg("SCALE",'I');
    memused(19);

//    sendmsg("COM4",'I',GRAPHIC);
//    sendmsg("COM4",'i',9600,8,'N',1);
//    sendmsg("COM4",'b',26,60);

    memused(20);
    sendmsg("PRN",'I',STANDARD);
    sendmsg("PRN",'b',80,60);
    memused(21);
    sendmsg("PRN2",'I',STANDARD);
    sendmsg("PRN2",'b',80,60);
//    sendmsg("PRN3",'I',GRAPHIC);
//    sendmsg("PRN3",'b',80,60);

    memused(22);
	sendmsg("INPUT2",'I');
    memused(23);
    sendmsg("INPUT3",'I');
    memused(24);
	sendmsg("OUTPUT4",'I');

//    sendmsg("COM1",'I',TRANSLATE);
//    sendmsg("COM1",'i',9600,8,'N',1);
//    sendmsg("COM1",'b',40,9);
//    sendmsg("OUTPUT2",'S',1);


    if (sendmsg("INPUT1",'H')) {	// if key pressed - wait for another
		sendmsg("INPUT1",'i');
		while (!sendmsg("INPUT1",'H')) {
			b=0;
			sendmsg("INPUT3",'i',&x,&y,&b);
			if ((b==2)&&((x>=290)&&(x<=295))&&((y>=60)&&(y<=65))) {
				while (b!=0) sendmsg("INPUT3",'i',&x,&y,&b);
				sendmsg("OUTPUT1",'AN',21,2,5,5,"CYCLE.BMP");
				sendmsg("OUTPUT1",'SC',35,2,4,2,5,"CREDITS.BMP");
			}
		}
		sendmsg("INPUT1",'i');
	}
    memused(25);
    if (G_form.type==F_MENU) {
        memused(26);
        orderform(&G_form,1);
        runmenu();
    }
    else {
        memused(27);
        orderform(&G_form,0);
        memused(28);
        if (!initform(&G_form)) {
			sendmsg("OUTPUT4",'E');
            sendmsg("LAN",'E');
            sendmsg("INPUT1",'E');
            sendmsg("SCALE",'E');
            sendmsg("DISK",'E');
	        sendmsg("DBM",'E');
            sendmsg("OUTPUT1",'E');
            sendmsg("OUTPUT2",'E');
		    sendmsg("COMM",'SE');
            printf("Can't init form logon for %s\n",G_system);
        	chdir(G_curdir);
			cleanupblks(0);
            RETURNV(1);
        }
        memused(29);
        do {
			G_exit2top=0;
			G_exit2mrk=0;
			G_uid=0;
            sendmsg("OUTPUT1",'R');
			prdate();
        memused(30);
		    sendmsg("INPUT1",'A',9,prdate);
        memused(31);
		    sendmsg("INPUT1",'A',18,prps);
        memused(32);
			if (G_weighton) sendmsg("INPUT1",'A',36,prw);
			if (G_coinon  ) sendmsg("INPUT1",'A',9,prc);
        memused(33);
            sendmsg("OUTPUT1",'SP',G_palentry);
        memused(34);
            if (!runform(2)) {
				sendmsg("OUTPUT4",'E');
                sendmsg("LAN",'E');
                sendmsg("INPUT1",'E');
                sendmsg("SCALE",'E');
                sendmsg("DISK",'E');
    		    sendmsg("DBM",'E');
                sendmsg("OUTPUT1",'E');
                sendmsg("OUTPUT2",'E');
			    sendmsg("COMM",'SE');
                printf("Can't run form logon for %s\n",G_system);
            	chdir(G_curdir);
				cleanupblks(0);
                RETURNV(1);
            }
        memused(35);
			if (G_weighton) sendmsg("INPUT1",'D',prw);
			if (G_coinon  ) sendmsg("INPUT1",'D',prc);
		    sendmsg("INPUT1",'D',prdate);
		    sendmsg("INPUT1",'D',prps);
			G_luid=G_uid;
			sprintf(tmp,"%d",G_uid);
			sendmsg("LAN",'l',tmp);
        } while (bd[0]!=(-1));
        memused(30);
        clrform(&G_form);
    }
	sendmsg("OUTPUT4",'E');
    sendmsg("INPUT3",'E');
    sendmsg("INPUT2",'E');
    sendmsg("PRN",'E');
    sendmsg("PRN2",'E');
    if (G_refson) printf("E");
    sendmsg("OUTPUT1",'R');
    sendmsg("OUTPUT1",'SP',G_defpal);
    sendmsg("OUTPUT1",'E');
    sendmsg("COMM",'SE');
	if (G_refson) printf("A");
    sendmsg("LAN",'E');
    if (G_refson) printf("B");
    sendmsg("DISK",'E');
    if (G_refson) printf("C");
    sendmsg("SCALE",'E');
    if (G_refson) printf("D");
    sendmsg("DBM",'E');
    if (G_refson) printf("F");
    sendmsg("INPUT1",'E');
    if (G_refson) printf("G\n");
    fincalc();
    if (G_refson) printf("1");
    freeform(&G_form);
    if (G_refson) printf("2");
//    for (i=0;i<G_numn;i++) printf("%s %d\n",G_anamebuf[i].n,G_anamebuf[i].i);
    freeactions();
    if (G_refson) printf("3");
    freetext();
    if (G_refson) printf("4");
    if (memsig(G_keyspace))  FREE(G_keyspace);
    if (G_refson) printf("5");
    if (memsig(G_log))       FREE(G_log);
    if (G_refson) printf("6");
    if (memsig(G_store))     FREE(G_store);
    if (G_refson) printf("7");
    if (memsig(G_lib))       FREE(G_lib);
    if (G_refson) printf("8");
    if (memsig(G_tname))     FREE(G_tname);
    if (G_refson) printf("9");
    if (memsig(G_anamebuf))  FREE(G_anamebuf);
    if (G_refson) printf("0");
    if (G_ridxbuf!=NULL) FREE(G_ridxbuf);
    if (G_refson) printf("1");
    freeformidx();
    if (G_refson) printf("2");
	if (G_refson) prdevlist();
 	closedevices();
	cleanupblks(G_refson!=0);
	clrconfig();
    if (((G_nummall+G_numstrd)-G_numfree!=0L)&&(G_refson))
        printf("f=%ld m=%ld r=%ld s=%ld %ld free's missing\n",G_numfree,G_nummall,G_numreal,G_numstrd,(G_nummall+G_numstrd)-G_numfree);
 	arithend();
	if (G_refson) printf("Max mem %lu Max Block %lu Current %lu For Variables=%ld\n",G_maxmem,G_maxblk,G_curmem,G_forvars);
	chdir(G_curdir);
    RETURNV(0);
}
