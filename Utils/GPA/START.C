// #define PLAYBACK 1
// #define RECORDING 1
#include <dos.h>
#include <time.h>
#include <memory.h>
#include <stdio.h>
#include <string.h>
#include <conio.h>
#include <direct.h>
#include <process.h>
#include "keynames.h"
#if defined(RECORDING) || defined(PLAYBACK)
#include <stdlib.h>       
#include <io.h>
#include <fcntl.h>
#include <sys\types.h>
#include <sys\stat.h>
#endif

#ifdef PLAYBACK
#include <malloc.h>
#endif

#include "keydef.h"
#include "start.h"
int G_beensetup=0;
int G_errorlog[ENDOFBUF+1];
int G_errorkp=0;
int sendkbdata(unsigned char d)
{
    int to,retry=3;
    disable();
    while (retry) {
        to=32000;
        while (((inp(0x64)&2)==2)&&(to)) to--;
        if (to) {
            outp(0x60,d);
            enable();
            delay(10);
            return(1);
        }
        retry--;
    }
    enable();
    return(0);
}
void setflags(void)
{
	static unsigned char ss=0;
    int to;
	unsigned char s=0,gss;
    gss=*G_shiftstat;
	if (ss!=(gss&(CAPSL|NUML|SCROLLL))) {
		ss=(gss&(CAPSL|NUML|SCROLLL));
		if ((gss&CAPSL  )!=0) s|=4;
		if ((gss&NUML   )!=0) s|=2;
		if ((gss&SCROLLL)!=0) s|=1;

        if (sendkbdata(0xED)) {
            sendkbdata(s);
        }
        sendkbdata(0xF4);
	}
}
// buffer a keypress
void bufferkey(int k)
{
    int i;
    static int tk=0;
    static int tkb[20];
	G_exticker=0;
    if (G_enabled==2) {
        tkb[tk++]=k;
        if (tk==20) G_enabled=1;
        return;
    }
    if (tk) {
        for (i=0;i<tk;i++) {
            G_errorlog[G_errorkp++]=k;
        	if (G_errorkp>ENDOFBUF) G_errorkp=0;
    		G_keybuf[(*G_kpend)++]=tkb[i];
        	if (*G_kpend>ENDOFBUF) *G_kpend=0;
#ifdef RECORDING
    		G_keyrbuf[ G_kprend   ]=tkb[i];
    		G_ticrbuf[(G_kprend)++]=*G_ticker;
        	if (G_kprend>ENDOFBUF) G_kprend=0;
#endif // def RECORDING
        }
        tk=0;
    }
    if (!k) return;
    if (!(*G_disabletill)) {
        G_errorlog[G_errorkp++]=k;
       	if (G_errorkp>ENDOFBUF) G_errorkp=0;
		G_keybuf[(*G_kpend)++]=k;
    	if (*G_kpend>ENDOFBUF) *G_kpend=0;
#ifdef RECORDING
		G_keyrbuf[ G_kprend   ]=k;
		G_ticrbuf[(G_kprend)++]=*G_ticker;
    	if (G_kprend>ENDOFBUF) G_kprend=0;
#endif // def RECORDING
	}
}
void interrupt apifunc(void)
{
    APIBUF *b;
#ifdef RECORDING
    int i;
    long l;
#endif // def RECORDING
    unsigned int func=_AX;
    unsigned int seg =_CX;
    unsigned int ofs =_BX;
    switch (func) {
        case KBDSWITCHOFF : G_enabled    =0;G_beensetup=0; break;
        case KBDSWITCHON  : G_enabled    =1;G_beensetup=1; break;
        case KBDSETBUFFER : G_keybuf     =MK_FP(seg,ofs); break;
        case KBDSETSTART  : G_kpstart    =MK_FP(seg,ofs); break;
        case KBDSETEND    : G_kpend      =MK_FP(seg,ofs); break;
        case KBDSETLOOP   : G_kloop      =MK_FP(seg,ofs); break;
        case KBDSETSCAN   : G_scanmap    =MK_FP(seg,ofs); break;
        case KBDDISABLE   : G_disabletill=MK_FP(seg,ofs); break;
        case TICKCOUNTER  : G_ticker     =MK_FP(seg,ofs); break;
        case TICKEXITCTR  : G_exticker   =MK_FP(seg,ofs); break;
        case PUSHKEYPRESS :
            if (seg!=5000) {
                G_enabled=2;
                bufferkey(seg);
            } else {
                G_enabled=1;
                bufferkey(0);
            }
            break;
        case UPDATEFLAGS :
            setflags();
#ifdef RECORDING
            if ((G_type!='C')&&(G_fd!=(-1))) {
                while (G_kprstart!=G_kprend) {
               	    i=G_keyrbuf[ G_kprstart   ];
               	    l=G_ticrbuf[(G_kprstart)++];
               	    if (G_kprstart>ENDOFBUF) G_kpstart=0;
                    write(G_fd,&i,sizeof(int));
                    write(G_fd,&l,sizeof(long));
                }
            }
#endif // def RECORDING
            break;
        case KBDSETAPIBUF :
            b=MK_FP(seg,ofs);
            memset(b,0,sizeof(APIBUF));
            G_scanmap    = (b->scan);
            G_keybuf     = (b->buf);
            G_kpstart    =&(b->start);
            G_kpend      =&(b->end);
            G_kloop      = (b->loop);    
            G_disabletill=&(b->disabletill);
            G_ticker     =&(b->ticker);
            G_exticker   =&(b->exticker);
            G_shutdown   =&(b->shutdown);
            G_debug      =&(b->debug);
            memcpy(G_scanmap,&L_scanmap,0x7F*5*sizeof(int));
            G_beensetup=1;
            break;
    }
}
// keyboard interrupt routine
void interrupt mykeyb(void)
{
    static unsigned char ul=0x0F;
    unsigned char stat;
    int kpress,mappos;
    int k;

    if ((*G_shiftstat&(LSHIFT|RSHIFT|ALT))==(LSHIFT|RSHIFT|ALT)) {
        *G_shutdown=0;
        G_enabled=1;
    }
    if (!G_enabled) {
        (oldkeyb)();
        return;
    }

    disable();

    k=inp(0x60);
    kpress=G_scanmap[((k&0x7F)*5)+0];
    if (k&0x80) {
        switch (kpress) {
            case KLSFT  : *G_shiftstat&=~(LSHIFT);                break;
            case KRSFT  : *G_shiftstat&=~(RSHIFT);                break;
            case KCTRL  : *G_shiftstat&=~(CTRL);                  break;
            case KALT   : *G_shiftstat&=~(ALT);                   break;
            case KCAPL  : ul|=1;                                  break;
            case KNUML  : ul|=2;                                  break;
            case KSCRL  : ul|=4;                                  break;
        }
    }
    else {
        switch (kpress) {
            case KLSFT  : *G_shiftstat|=LSHIFT;                           break;
            case KRSFT  : *G_shiftstat|=RSHIFT;                           break;
            case KCTRL  : *G_shiftstat|=CTRL;                             break;
            case KALT   : *G_shiftstat|=ALT;                              break;
            case KCAPL  : if ((ul&1)!=0) { *G_shiftstat^=CAPSL;   ul&=0xFE; } break;
            case KNUML  : if ((ul&2)!=0) { *G_shiftstat^=NUML;    ul&=0xFD; } break;
            case KSCRL  : if ((ul&4)!=0) { *G_shiftstat^=SCROLLL; ul&=0xFB; } break; // LANGUAGE bufferkey(-254); break;
            default :
                if (kpress==INS) {
                    if ((ul&8)!=0) { *G_shiftstat^=INSL; ul&=0xF7; }
                }
                mappos=0;
                if (!G_extnext) {
                    if ((*G_shiftstat&(LSHIFT|RSHIFT))!=0) mappos=1;
                    if (  ((G_scanmap[(k*5)+4]==1)&&((*G_shiftstat&CAPSL)!=0))
                      ||  ((G_scanmap[(k*5)+4]==2)&&((*G_shiftstat&NUML )!=0)))
                        mappos^=1;
                }
                if ((*G_shiftstat&CTRL)!=0) mappos=2;
                if ((*G_shiftstat&ALT)!=0)  mappos=3;
                kpress=G_scanmap[(k*5)+mappos];
                if (kpress==DOUB0) {
                    bufferkey('0');
                    kpress='0';
                }
                if (kpress==TREB0) {
                    bufferkey('0');
                    bufferkey('0');
                    kpress='0';
                }
                if (kpress!=0) bufferkey(kpress);
        }
    }
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);            // signal EOI
    enable();

    G_extnext=(k==EXTENDED);
    if ((*G_shiftstat&(LSHIFT|RSHIFT|CTRL))==(LSHIFT|RSHIFT|CTRL)) {
        *G_shutdown=1;
        G_enabled=0;
    }
    if (G_beensetup==1) {
        if ((*G_shiftstat&(ALT|CTRL))==(ALT|CTRL)) {
            if ((*G_shiftstat&CAPSL)==CAPSL)
                *G_debug=1;
            else
                *G_debug=0;
        }
    }
}
void interrupt ticker(void)
{
	int i;
	(oldtick)();
	(*G_ticker)++;
    (*G_exticker)++;
   	for (i=0;i<32;i++) {
       	if (G_kloop[i].func!=NULL) {
			G_kloop[i].lt++;
			if (G_kloop[i].pri==G_kloop[i].lt) {
				G_kloop[i].lt=0;
				G_kloop[i].td=1;
			}
       	}
   	}
#ifdef PLAYBACK
    if ((G_beensetup)&&(G_type!='C')&&(G_fd!=(-1))) {
        if ((G_kprstart!=G_kprend)&&(*G_ticker>=G_ticrbuf[G_kprstart].tc))
            bufferkey(G_ticrbuf[G_kprstart++].kp);
    }
#endif // def PLAYBACK
}
#ifdef RECORDING
void finrecorder(void)
{
    int i;
    long l;
    if ((G_type!='C')&&(G_fd!=(-1))) {
        while (G_kprstart!=G_kprend) {
            i=G_keyrbuf[ G_kprstart   ];
            l=G_ticrbuf[(G_kprstart)++];
            if (G_kprstart>ENDOFBUF) G_kpstart=0;
            write(G_fd,&i,sizeof(int));
            write(G_fd,&l,sizeof(long));
        }
    }
    close(G_fd);
}
void setrecorder(void)
{
    char str[100],*t;
    G_type='C';
    memset(G_file,0,80);
	strcpy(str,getenv("RECORDER"));
    if (str!=NULL) {
        t=strtok(str," ");
        if (t!=NULL) {
            strcpy(G_file,t);
            t=strtok(NULL," ");
            if (t!=NULL) {
                G_type=*t;
            } else {
                G_type='F';
            }
            switch (G_type) {
                case 'F' :
                    G_fd=open(G_file,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
                    if (G_fd==(-1)) G_type='C';
                case 'A' :
                    G_fd=open(G_file,O_RDWR|O_BINARY|O_CREAT,S_IREAD|S_IWRITE);
                    if (G_fd==(-1)) G_type='C'; else lseek(G_fd,0L,SEEK_END);
            }
        } 
	}
}
#endif // def RECORDING

#ifdef PLAYBACK
void finplayback(void)
{
    if (G_ticrbuf!=NULL) {
        free(G_ticrbuf);
    }
}
#endif // def PLAYBACK
#ifdef PLAYBACK
void setplayback(void)
{
    char str[100],*t;
    unsigned int i;
	strcpy(str,getenv("RECORDER"));
    if (str!=NULL) {
        t=strtok(str," ");
        if (t!=NULL) {
            strcpy(G_file,t);
            t=strtok(NULL," ");
            if (t!=NULL) {
                G_type=*t;
            } else {
                G_type='A';
            }
            switch (G_type) {
                case 'F' :
                    G_fd=open(G_file,O_RDONLY|O_BINARY);
                    if (G_fd==(-1)) G_type='C';
                    else {
                        i=(unsigned int)filelength(G_fd);
                        G_ticrbuf=malloc(i);
                        if (G_ticrbuf==NULL) {
                            G_type='C';
                        } else {
                            G_kprend=read(G_fd,G_ticrbuf,i);
                            close(G_fd);
                        }
                    }
            }
        } 
	}
}
#endif // def PLAYBACK

char *keyname(int k)
{
    static char tmp[10];

    if (k<33) {
        strcpy(tmp,G_keyname[k+176]);
    }
    else {
        tmp[0]=(char)k;
        tmp[1]=0;
        if (k==127) strcpy(tmp,G_keyname[199]);
    }
    return(tmp);
}
void buildkeylist(void)
{
    int i=G_errorkp;
    int j;
    i++;
    printf("\n-----------------------------------KEY LIST-------------------------------\n");
    for (j=0;j<ENDOFBUF;j++) {
        printf("%-8.8s",keyname(G_errorlog[i++]));
        if (i>ENDOFBUF) i=0;
        if ((j%10)==9) printf("\n");
    }
    printf("\n----------------------------------TIME STAMPS-----------------------------\n");
}

#pragma argsused
int main(int argc,char *argv[])
{
    int ret=0;
    time_t e,s;
    char curdir[100];
    char gpapath[100],*t;
	curdir[0]='\\';
	getcurdir(0,&curdir[1]);
    strcpy(gpapath,argv[0]);
	t=strrchr(gpapath,'\\');
	if (t!=NULL) {
		t++;
		strcpy(t,"GPA.BIN");
	} else {
		strcpy(gpapath,".\GPA.BIN");
	}
#ifdef PLAYBACK
    setplayback();
#endif // def PLAYBACK

#ifdef RECORDING
    setrecorder();
#endif // def RECORDING
#ifndef TEXTMODE
    G_shiftstat=MK_FP(0x0040,0x0017);
    G_scanmap     = L_scanmap;
    G_keybuf      = L_keybuf;
    G_kpstart     =&L_kpstart;
    G_kpend       =&L_kpend;
    G_kloop       = L_kloop;
    G_disabletill =&L_disabletill;
    G_ticker      =&L_ticker;
    G_exticker    =&L_exticker;
    G_shutdown    =&L_shutdown;
    G_debug       =&L_debug;

    s=time(NULL);

    oldkeyb=getvect(0x09);
    oldtick=getvect(0x1C);
    oldi62v=getvect(0x62);
    setvect(0x62,apifunc);
    setvect(0x1C,ticker);
    setvect(0x09,mykeyb);
#endif    
    if (argc>1) {
        if ((argv[1][0]=='1')&&(argv[1][1]==0)) {
            if (argc==3) {
                ret=spawnl(P_WAIT,"TD","TD",gpapath,argv[2],NULL);
            } else {
                ret=spawnl(P_WAIT,"TD","TD",gpapath,NULL);
            }
        } else {
            unlink("ERROR.LOG");
            fclose(stdout);
            fopen("ERROR.LOG","w");
            ret=spawnl(P_WAIT,gpapath,gpapath,argv[1],NULL);
            buildkeylist();
            e=time(NULL);
            printf("\nStart %s\nEnd   %s\n---------------------------------GPA ERROR LOG-----------------------------",ctime(&s),ctime(&e));
            fclose(stdout);
        }
    } else {
#ifndef TEXTMODE
        unlink("ERROR.LOG");
        fclose(stdout);
        fopen("ERROR.LOG","w");
#endif
        ret=spawnl(P_WAIT,gpapath,gpapath,NULL);
#ifndef TEXTMODE
        buildkeylist();
        e=time(NULL);
        printf("\n");
        printf("Start %s",ctime(&s));
        printf("End   %s",ctime(&e));
        printf("---------------------------------GPA ERROR LOG-----------------------------");
        fclose(stdout);
#endif
    }

#ifndef TEXTMODE
    setvect(0x62,oldi62v);
    setvect(0x09,oldkeyb);
    setvect(0x1C,oldtick);
    if (G_beensetup) {
        _AX=3;
        geninterrupt(0x10);
    	chdir(curdir);
        if (argv[1][0]!='1') {
            fprintf(stderr,"An Error has Occured while running GPA.\nTo safeguard your data, the system files\n");
            fprintf(stderr,"have been closed and the application terminated.\nAn error report has been prepared.\n");
            fprintf(stderr,"To print the error report:\n\n"
                "    switch on your printer,\n"
                "    insert some paper\n"
                "    and then press a key.\n"
                "    To Ignore Error Press [ESC]\n");
            if (getch()!=27) {
                system("copy ERROR.LOG PRN: > nul");
            } else {
                fprintf(stderr,"The File ERROR.LOG should be copied to a safe place\n");
                fprintf(stderr,"Before re-running GPA.\n");
            }
        }
    }
#endif
#ifdef RECORDING
    finrecorder();
#endif // def RECORDING

#ifdef PLAYBACK
    finplayback();
#endif // def PLAYBACK

    return(ret);
}

