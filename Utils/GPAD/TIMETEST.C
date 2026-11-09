// TIMETEST.C
// A test of timer hooking under 32bit mode
#include <stdio.h>
#include <dos.h>
#include <windows.h>

void ttimer(void)
{
	disable();
	sound(20);
	delay(1000);
	nosound();
	enable();
}

void tsound(void)
{
	sound(20);
	delay(1000);
	nosound();
}

unsigned short int buffer[32];

#define ON
#ifdef ON
int SetTimerCallback()
{
	union REGS inregs,outregs;
	struct SREGS	sregs;
	void	*vptr();

	vptr = &ttimer
	inregs.w.ax=0x0303;
	inregs.x.esi=OFFSETOF(&ttimer);
	sregs.ds=SELECTOROF(&ttimer);
	inregs.x.edi=OFFSET(&buffer);
	sregs.es=SEGMENT(&buffer);
	int386x(0x31,&inregs,&outregs,&sregs);
	if (outregs.x.cflag)
	{
		printf ("Timer interrupt installation failed");
	}
	else
	{
		printf ("Timer interrupt installed");
	}
	return (outregs.x.cflag);
}
#endif

main()
{
	printf ("Program start");
	printf ("Size, ttimer  %d",sizeof(&ttimer));
	return(1);
}
