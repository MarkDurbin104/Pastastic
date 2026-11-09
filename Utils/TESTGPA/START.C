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
#include <malloc.h>
#endif

#include "keydef.h"
#include "realprot.h"
#include "start.h"
int G_resetmintick=0;
int G_waitforkey=0;
int G_beensetup=0;
int G_errorlog[ENDOFBUF+1];
int G_errorkp=0;
int G_pushing=0;            // Flag to disable key buffering during pushkey

FPTR G_protectedcrit=NULL;       // call back address to protected mode

#ifdef PLAYBACK
long G_savedat[100];
int G_numsavedat=0;
int G_saveingdat=0;
int G_forceexit=0;
int G_hadakeypress=0;
char G_savedatfile[20];
#define READPLANE(a)  outpw(0x3CE,(unsigned int)(((a)<<8)|4));
long scrcrc(void)
{
    long ret=0L;
    int  x,y,plane;
   	unsigned long *scr;
    for (plane=0;plane<4;plane++) {
    	scr=(unsigned long *)MK_FP(__SegA000,0x0000)+(19*20);
   	    READPLANE(plane);                           // select plane
        for (y=19;y<480;y++) {                      // for every line ( excluding top 19 )
            for (x=0;x<20;x++) {                    // for every long in x direction
                ret^=*(scr++);      // hide on screen flag
            }
        }
    }
    if (G_saveingdat) G_savedat[G_numsavedat++]=ret;
    return ret;
}
#endif
//**********************************************
void beep(void)
{
    sound(500);
    delay(200);
    nosound();
}

#define TEMPSOLUTION
// Not enogh time to get string displayed to screen so we do a simple
// fail under windows for the time being.  Tom 1/6/95

#ifdef TEMPSOLUTION
//**************************************************
// critical error handler   MUST BE IN LOCKED MEMORY!!
    // This is only called from a Windows DOS box.
    // Just 'Fail' the operation for now - AL set to 3

void interrupt criticalerrorhandler(void)
{
    asm {
    mov al,3
    pop bp
    pop di
    pop si
    pop ds
    pop es
    pop dx
    pop cx
    pop bx
    pop bx
    iret
    }
}

#else
//**************************************************
// critical error handler   MUST BE IN LOCKED MEMORY!!
void interrupt (*oldcriticalerror)();
void interrupt criticalerrorhandler(void)
{
    int AX=_AX;     // Get status values
    int DI=_DI;
    int err=0;
    int length,segment,off;
    char    diskerrmsg[] = "Disk error";
    char    retryfail[] = "Retry or Fail R/F";

     // if disk I/O error handle, else ignore.
    if (!(AX & 0x8000))         //AH bit 7 set 0 indicates an I/O error
    {
        if (AX & 0x0380)   // Test if Ignore, Retry Abort allowed
        {
                // save screen area
                // put up message line (change to a box?)
            beep();

            // don't save region, taks up valuable real memory
//            savemsgregion();


            enable();
            // now need to output text to screen which is in VGA
            // 640x480 graphics video mode


                // wait for key press
            while (err==0) {
            	while (*G_kpstart==*G_kpend) {
                    // wait for keyboard input
                }
           		switch (G_keybuf[*G_kpstart]) {
                    case 'r' : case 'R' : err=1; break;
                    case 'f' : case 'F' : err=2; break;
                    default  : beep();
                }
                (*G_kpstart)++;
                if (*G_kpstart==ENDOFBUF) *G_kpstart=0;
            }
            disable();

            // we haven't saved it so we can't restore
//            restmsgregion();

                // set value of AL and continue
            switch (err) {
                case 1:
                    _AL=0x01;
                    break;
                case 2:
                default:
                    _AL=0x03;
            }
            // note we pop value of ax to bx as we do not want to destroy ax
            asm {
                leave
                pop di
                pop si
                pop ds
                pop es
                pop dx
                pop cx
                pop bx
                pop bx
                iret
            }
        }
    }
    else
    {
        _AL=0x01;                   // probably the printer, just retry
        outp(0x20,0x20);            // signal EOI
        enable();
    }
}
// End of critical error code
//***************************************************************
#endif

// return the amount of free disk space on the current drive
unsigned long getfreediskspace(void) 
{
    unsigned long freespace;
    int numsecperc; // sectors per cylinder
    int numavailc;  // number of available cylinders
    int numbpers;   // nuymber of bytes per sector
    int drive;      // current drive number 0=A: 1=B: 2=C: etc..

    _AX=0x1900;     // get current drive
    geninterrupt(0x21);
    drive=_AX;
    drive&=0x00FF;  // drive in AL

    drive++;         // drive number for get disk free space
                     // is 1=A: 2=B: 3=C: etc.. (Typical!)
    _AX=0x3600;      // get disk free space
    _DX=drive;       
    geninterrupt(0x21);
    numsecperc=_AX;
    numavailc =_BX;
    numbpers  =_CX;
    freespace=(unsigned long)numsecperc*(unsigned long)numavailc*(unsigned long)numbpers;
    return(freespace);
}

int movebp(int *bp)
{
    int tmp=*bp;
    (*bp)++;
    if (*bp==ENDOFBUF) *bp=0;
    return(tmp);
}
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
	unsigned char s,gss;
    gss=(*G_shiftstat)&(CAPSL|NUML|SCROLLL);
	if (ss!=gss) {
		ss=gss;
        s=0;
		if ((gss&CAPSL  )!=0) s|=4;
		if ((gss&NUML   )!=0) s|=2;
		if ((gss&SCROLLL)!=0) s|=1;

        if (sendkbdata(0xED)) {
            sendkbdata(s);
        }
        sendkbdata(0xF4);
	}
}
void placekey(int k)
{
    if (!k) return;
    G_errorlog[movebp(&G_errorkp)]=k;
	G_keybuf[movebp((int *)G_kpend)]=k;
#ifdef RECORDING
	G_keyrbuf[G_kprend++]=k;
#endif // def RECORDING
}

void insertk(int *buf,int s,int p,int key)
{
    int i,j,k;
    static int tmp[ENDOFBUF+1];
    if (s!=p) {
        i=0;
        j=p;
        while (j!=s) {
            tmp[i++]=buf[j--];
            if (j<0) j=ENDOFBUF-1;
        }
        j=p;
        for (k=0;k<i;k++) {
            j--;
            if (j<0) j=ENDOFBUF-1;
            buf[j]=tmp[k];
        }
    }
    buf[p]=key;
}
void pushkey(int k)
{
//	G_keybuf[movebp((int *)G_kpend)]=k;
    static int pushpoint=(-1);
    G_pushing=1;
    (*G_kpstart)--;
    if (*G_kpstart<0) *G_kpstart=ENDOFBUF-1;
    if (pushpoint==(-1)) pushpoint=*G_kpstart;
    insertk((int *)G_keybuf,*G_kpstart,pushpoint,k);
    if (k==KBDPUSHEND) {
        G_pushing=0;
        pushpoint=(-1);
    }
}

// buffer a keypress
void bufferkey(int k)
{
	G_exticker=0;
    if (!(*G_disabletill)) placekey(k);
}
void interrupt apifunc(void)
{
    APIBUF *b;
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
        case INACTIVETIME : G_intacttime =MK_FP(seg,ofs); break;
        case FILEZIP      : break;
        case FILEUNZIP    : break;
        case PUSHKEYPRESS :
            disable();
            pushkey(seg);
            enable();
            break;
        case UPDATEFLAGS :
            if (seg) {
                if (seg==1) *G_shiftstat|=NUML; else *G_shiftstat&=~NUML;
            }
            setflags();
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
            G_intacttime =&(b->inacttime);
            G_shutdown   =&(b->shutdown);
            G_debug      =&(b->debug);
            memcpy(G_scanmap,&L_scanmap,0x7F*5*sizeof(int));
            G_beensetup=1;
            break;
        case BACKUPDBM  :
            break;
        case RESTOREDBM :
            break;
        case SETCRITCALLBACK :
            G_protectedcrit=MK_FP(seg,ofs);
            // Now hook the critical error handler

            // Test - doesn't work !!!
            printf("\ncallback address %04X:%04X \n",seg,ofs);
            enable();
            (G_protectedcrit)();
        	asm add sp, 4

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

    *G_intacttime=0L;
    if (!G_enabled) {
        (oldkeyb)();
        return;
    }

    disable();
    k=inp(0x60);
#ifdef PLAYBACK
    if ((k&0x80)==0) {
        if (!G_waitforkey) {
            G_kprstart=G_kprend;
        } else {
            G_resetmintick=1;
        }
    }    
#endif
    if ((!G_pushing)&&(!G_waitforkey)) {
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
#ifdef PLAYBACK
    G_hadakeypress=1;
#endif
            switch (kpress) {
                case KLSFT  : *G_shiftstat|=LSHIFT;                           break;
                case KRSFT  : *G_shiftstat|=RSHIFT;                           break;
                case KCTRL  : *G_shiftstat|=CTRL;                             break;
                case KALT   : *G_shiftstat|=ALT;                              break;
                case KCAPL  : if ((ul&1)!=0) { *G_shiftstat^=CAPSL;   ul&=0xFE; } break;
                case KNUML  : if ((ul&2)!=0) { *G_shiftstat^=NUML;    ul&=0xFD; } break;
                case KSCRL  : if ((ul&4)!=0) { *G_shiftstat^=SCROLLL; ul&=0xFB; } bufferkey(-254); break;
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
                    if ((G_extnext)&&(k==PRNTSCR)) {
                        bufferkey(PRNTSCRKEY);
                    } else {
                        if (kpress!=0) bufferkey(kpress);
                    }
            }
        }
        G_extnext=(k==EXTENDED);
        if ((*G_shiftstat&(LSHIFT|RSHIFT|CTRL))==(LSHIFT|RSHIFT|CTRL)) {
            *G_shutdown=1;
            G_enabled=0;
        }
    }
    G_waitforkey=0;
    stat=inp(0x61);
    outp(0x61,stat|0x80);
    outp(0x61,stat);
    outp(0x20,0x20);            // signal EOI
    enable();
}
void interrupt ticker(void)
{
	int i;
#ifdef PLAYBACK
    static int minitick=0;
#endif
	(oldtick)();
	(*G_ticker)++;
    (*G_exticker)++;
    (*G_intacttime)++;
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
    if (G_resetmintick) { minitick=100; G_resetmintick=0; }
    if ((G_beensetup)&&(!G_waitforkey)) {
        minitick++;
        if ((!G_hadakeypress)&&(minitick>546)&&(G_kprstart==G_kprend)&&(*G_kpstart==*G_kpend)) {
            G_forceexit=1;
            *G_shutdown=1;
            G_enabled=0;
        }
        if ((minitick>100)&&(G_kprstart!=G_kprend)&&(*G_kpstart==*G_kpend)) {
            disable();
            if (G_saveingdat==2) {
                G_saveingdat=1;
                scrcrc();
            }
            minitick=100;
            switch (G_keyrbuf[G_kprstart]) {
                case 10000 :
                    if (G_saveingdat==1) {
                        G_saveingdat=2;
                        G_kprstart+=2;
                        minitick=60;
                    } else {
                        if (G_keyrbuf[++G_kprstart]) {
                            minitick=100-((G_keyrbuf[G_kprstart++]*182)/10);
                        } else {
                            G_kprstart++;
                            G_waitforkey=1;
                        }
                    }
                    break;
                case KCAPL :   // CAPS LOCK
                    *G_shiftstat^=CAPSL;                     
                    setflags();
                    G_kprstart++;                            
                    break;
                case KNUML :   // NUM LOCK
                    *G_shiftstat^=NUML;                      
                    setflags();
                    G_kprstart++;
                    break;
                case KSCRL :   // SCROLL LOCK
                    *G_shiftstat^=SCROLLL;
                    setflags();
                    G_kprstart++;
                    break;
                case PRSCR :
                    bufferkey(PRNTSCRKEY);
                    G_kprstart++;
                    break;
                default :
                    bufferkey(G_keyrbuf[G_kprstart++]);
            }
            *G_intacttime=0L;
            enable();
        }
    }
#endif // def PLAYBACK
}
#ifdef RECORDING
void finrecorder(void)
{
    int fd;
    char file[80];
    memset(file,0,80);
	strcpy(file,getenv("RECORDER"));
    if (file!=NULL) {
        strcat(file,"\\KEYS.GPA");
        fd=open(file,O_RDWR|O_BINARY|O_TRUNC|O_CREAT,S_IREAD|S_IWRITE);
        if (fd!=(-1)) {
            write(fd,&G_keyrbuf,G_kprend*sizeof(int));
            close(fd);
        }
	}
}
#endif // def RECORDING

#ifdef PLAYBACK
void setplayback(void)
{
    int fd;
    char file[80];
    memset(file,0,80);
	strcpy(file,getenv("RECORDTO"));
    if (file!=NULL) {
        G_saveingdat=1;
        strcpy(G_savedatfile,file);
    }
	strcpy(file,getenv("RECORDER"));
    if (file!=NULL) {
        strcat(file,"\\KEYS.GPA");
        fd=open(file,O_RDONLY|O_BINARY);
        if (fd!=(-1)) {
            G_kprend=(unsigned int)filelength(fd);
            G_kprend/=sizeof(int);
            read(fd,&G_keyrbuf,G_kprend*sizeof(int));
            G_kprstart=0;
            close(fd);
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
    for (j=0;j<=ENDOFBUF;j++) {
        printf("%-8.8s",keyname(G_errorlog[movebp(&i)]));
        if ((j%10)==9) printf("\n");
    }
    printf("\n----------------------------------TIME STAMPS-----------------------------\n");
}

#pragma argsused
int main(int argc,char *argv[])
{
#ifdef PLAYBACK
    FILE *fp;
#endif // def PLAYBACK
    int ret=0;
    time_t e,s;
    unsigned long freedspace;
    int k;
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

#ifndef TEXTMODE
    freedspace=getfreediskspace();
    if (freedspace<(1024L*500L)) {
        textattr(0x0F);
        cprintf("You only have %ld K Bytes free on your hard disk!\r\n\r\n",freedspace/1024L);
        cprintf("If you proceed without releasing some disk space, your system\r\n");
        cprintf("may become unstable and may not save all your transactions.\r\n\r\n");
        textattr(0x07);
        cprintf("If you wish to continue with CAPTURE - PRESS 'C'\r\n");
        cprintf("Press any other key to exit\r\n");
        k=getch();
        if ((k!='C')&&(k!='c')) {
            return(1);
        }
    }

    G_shiftstat=MK_FP(0x0040,0x0017);
    G_scanmap     = L_scanmap;
    G_keybuf      = L_keybuf;
    G_kpstart     =&L_kpstart;
    G_kpend       =&L_kpend;
    G_kloop       = L_kloop;
    G_disabletill =&L_disabletill;
    G_ticker      =&L_ticker;
    G_exticker    =&L_exticker;
    G_intacttime  =&L_intacttime;
    G_shutdown    =&L_shutdown;
    G_debug       =&L_debug;

    s=time(NULL);

    oldkeyb=getvect(0x09);
    oldtick=getvect(0x1C);
    oldi62v=getvect(0x62);
    oldi24v=getvect(0x24);
    setvect(0x62,apifunc);
    setvect(0x1C,ticker);
    setvect(0x09,mykeyb);
    setvect(0x24,criticalerrorhandler);
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
    setvect(0x24,oldi24v);      // DOS will reset this anyway but lets be tidy
    setvect(0x1C,oldtick);
    if (G_beensetup) {
        _AX=3;
        geninterrupt(0x10);
    	chdir(curdir);
#ifdef PLAYBACK
        if ((argv[1][0]!='1')&&(!G_forceexit)) {
#else
        if (argv[1][0]!='1') {
#endif // def PLAYBACK
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
            fprintf(stderr,"\nYour system may now be unstable.\n");
            fprintf(stderr,"Reboot (power off/on) your system before continuing.\n");
        }
    }
#endif
#ifdef RECORDING
    finrecorder();
#endif // def RECORDING

#ifdef PLAYBACK
    if (G_saveingdat) {
        if ((fp=fopen(G_savedatfile,"w"))!=NULL) {
            for (k=0;k<G_numsavedat;k++) {
                fprintf(fp,"Screen %d = %ld\n",k,G_savedat[k]);
            }
            if (G_forceexit) fprintf(fp,"Forced Exit\n");
            fclose(fp);
        }          
    }
#endif // def PLAYBACK

    return(ret);
}

