#include <dos.h>
#include <stdlib.h>
#include <stdio.h>

void interrupt (*oldi13)(void);

struct REGPACK  G_regs[1000];
int      G_numgr=0;
void interrupt int13(void)
{
	asm pusha
	asm push es
	asm push ds
	G_regs[G_numgr].r_ax=_AX;
	G_regs[G_numgr].r_bx=_BX;
	G_regs[G_numgr].r_cx=_CX;
	G_regs[G_numgr].r_dx=_DX;
	G_regs[G_numgr].r_bp=_BP;
	G_regs[G_numgr].r_si=_SI;
	G_regs[G_numgr].r_di=_DI;
	G_regs[G_numgr].r_ds=_DS;
	G_regs[G_numgr].r_es=_ES;
	if ((_DL&0x80)!=0x80) G_numgr++;
	asm pop ds
	asm pop es
	asm popa
	(oldi13)();
}

int main(void)
{
	int i;
	FILE *fp;
	oldi13=getvect(0x13);
    setvect(0x13,int13);
	system("format a: /U");
    setvect(0x13,oldi13);
	fp=fopen("int13.opt","w");
	if (fp==NULL) fp=stdout;
	fprintf(fp,"_AX_ _BX_ _CX_ _DX_ _BP_ _SI_ _DI_ _DS_ _ES_\n");
	printf("_AX_ _BX_ _CX_ _DX_ _BP_ _SI_ _DI_ _DS_ _ES_\n");
	for (i=0;i<G_numgr;i++) {
		fprintf(fp,"%04X %04X %04X %04X %04X %04X %04X %04X %04X\n"
			,G_regs[i].r_ax,G_regs[i].r_bx,G_regs[i].r_cx,G_regs[i].r_dx,
	 		 G_regs[i].r_bp,G_regs[i].r_si,G_regs[i].r_di,
			 G_regs[i].r_ds,G_regs[i].r_es);
		printf("%04X %04X %04X %04X %04X %04X %04X %04X %04X\n"
			,G_regs[i].r_ax,G_regs[i].r_bx,G_regs[i].r_cx,G_regs[i].r_dx,
	 		 G_regs[i].r_bp,G_regs[i].r_si,G_regs[i].r_di,
			 G_regs[i].r_ds,G_regs[i].r_es);
	}
	fclose(fp);
	return(0);
}

