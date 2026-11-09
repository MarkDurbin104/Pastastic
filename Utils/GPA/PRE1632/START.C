#include <dos.h>
#include <stdio.h>
#include <process.h>
#include "keydef.h"
#include "start.h"

void setflags(void)
{
	static unsigned char ss=0;
	unsigned char s=0;
	if (ss!=*G_shiftstat) {
		ss=*G_shiftstat;
		if ((*G_shiftstat&CAPSL  )!=0) s|=4;
		if ((*G_shiftstat&NUML   )!=0) s|=2;
		if ((*G_shiftstat&SCROLLL)!=0) s|=1;
  		while ((inp(0x64)&0x2)==2);
		outp(0x60,0xED);
  		while ((inp(0x64)&0x2)==2);
		outp(0x60,s);
	}
}
// buffer a keypress
void bufferkey(int k)
{
	G_exticker=0;
    if (!G_disabletill) {
		G_keybuf[*G_kpend++]=k;
    	if (*G_kpend>ENDOFBUF) *G_kpend=0;
	}
}
void interrupt apifunc(void)
{
    unsigned int func=_AX;
    unsigned int seg =_CX;
    unsigned int ofs =_BX;
    switch (func) {
        case KBDSWITCHOFF : G_enabled    =0;              break;
        case KBDSWITCHON  : G_enabled    =1;              break;
        case KBDSETBUFFER : G_keybuf     =MK_FP(seg,ofs); break;
        case KBDSETSTART  : G_kpstart    =MK_FP(seg,ofs); break;
        case KBDSETEND    : G_kpend      =MK_FP(seg,ofs); break;
        case KBDSETLOOP   : G_kloop      =MK_FP(seg,ofs); break;
        case KBDSETSCAN   : G_scanmap    =MK_FP(seg,ofs); break;
        case KBDDISABLE   : G_disabletill=MK_FP(seg,ofs); break;
        case TICKCOUNTER  : G_ticker     =MK_FP(seg,ofs); break;
        case TICKEXITCTR  : G_exticker   =MK_FP(seg,ofs); break;
    }
}
// keyboard interrupt routine
void interrupt mykeyb(void)
{
    unsigned char stat;
    int kpress,mappos;
    int k;

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
        }
    }
    else {       
        switch (kpress) {
            case KLSFT  : *G_shiftstat|=LSHIFT;                   break;
            case KRSFT  : *G_shiftstat|=RSHIFT;                   break;
            case KCTRL  : *G_shiftstat|=CTRL;                     break;
            case KALT   : *G_shiftstat|=ALT;                      break;
            case KCAPL  : *G_shiftstat^=CAPSL;                    break;
            case KNUML  : *G_shiftstat^=NUML;                     break;
            case KSCRL  : *G_shiftstat^=SCROLLL; bufferkey(-254); break;
            default :
                if (kpress==INS) {
                    *G_shiftstat^=INSL;
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
    outp(0x20,0x20);
    G_extnext=(k==EXTENDED);
    enable();
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
}
int main(int argc,char *argv[])
{
    int ret;

    printf("Setting up Vectors/Variables ");

    G_shiftstat=(unsigned char *)0x00400017L;
    G_scanmap     = L_scanmap;
    G_keybuf      = L_keybuf;
    G_kpstart     =&L_kpstart;
    G_kpend       =&L_kpend;
    G_kloop       = L_kloop;
    G_shiftstat   =&L_shiftstat;
    G_disabletill =&L_disabletill;
    G_ticker      =&L_ticker;
    G_exticker    =&L_exticker;

    oldkeyb=getvect(0x09);
    oldtick=getvect(0x1C);
    oldi62v=getvect(0x62);
    setvect(0x62,apifunc);
    setvect(0x1C,ticker);
    setvect(0x09,mykeyb);

    printf("Here we go... ");
    if (argc==2)
        ret=spawnl(P_WAIT,"\\bc\\bin\\TD","TD","GPA.EXE",NULL);
    else
        ret=spawnl(P_WAIT,"\\src\\gpa\\bit1632\\GPA.EXE","GPA.EXE",NULL);

    printf(" ... we're Back! Restoring vectors...");

    setvect(0x62,oldi62v);
    setvect(0x09,oldkeyb);
    setvect(0x1C,oldtick);

    printf("Done.\n");

    return(ret);
}

