#include	<stdio.h>
#include	<dos.h>

#include	"int32.h"

typedef	unsigned long	uint32;
typedef	void		(*vfp)	(void);

unsigned short fooDS;

long	int21Cnt;

typedef struct	Int21Regs
{
	uint32	ebp;
	uint32	edi;
	uint32	esi;
	uint32	 ds;
	uint32	 es;
	uint32	edx;
	uint32	ecx;
	uint32	ebx;
	uint32	eax;
	uint32	eip;
	uint32	 cs;
	uint32	flags;
}	Int21Regs;

Int21Regs	regs [10000];

int cdecl foo (uint32	ebp,
	       uint32	edi,
	       uint32	esi,
	       uint32	 ds,
	       uint32	 es,
	       uint32	edx,
	       uint32	ecx,
	       uint32	ebx,
	       uint32	eax,
	       uint32	eip,
	       uint32	 cs,
	       uint32	flags)
{
	if	(int21Cnt < 10000)
	{
		Int21Regs	*r;

		r = &regs [int21Cnt];
		r->ebp	= ebp;
		r->edi	= edi;
		r->esi	= esi;
		r-> ds	=  ds;
		r-> es	=  es;
		r->edx	= edx;
		r->ecx	= ecx;
		r->ebx	= ebx;
		r->eax	= eax;
		r->eip	= eip;
		r-> cs	=  cs;
		r->flags= flags;
		int21Cnt++;
	}

	return 1;
}

void main (void)
{
	vfp		thunk;
	int		i;
	union	REGS	inregs;
	unsigned short	old21CS;
	unsigned long	old21EIP;

	fooDS = _DS;

	inregs.x.eax	= 0x204;
	inregs.x.ebx	= 0x21;
	int386 (0x31, &inregs, &inregs);
	old21CS		= (unsigned short)inregs.x.ecx;
	old21EIP	= 		  inregs.x.edx;

       	thunk = _makeInt32Thunk (foo, &fooDS, old21CS, old21EIP);

	inregs.x.eax	= 0x205;
	inregs.x.ebx	= 0x21;
	inregs.x.ecx	= _CS;
	inregs.x.edx	= thunk;
	int386 (0x31, &inregs, &inregs);

	printf ("This is a test.\n");
	printf ("There are three printfs.\n");
	printf ("How many int 21's, I wonder?\n");

	inregs.x.eax	= 0x205;
	inregs.x.ebx	= 0x21;
	inregs.x.ecx	= old21CS;
	inregs.x.edx	= old21EIP;
	int386 (0x31, &inregs, &inregs);

	printf ("\nInterrupt 21h log:\n\n");

	for	(i = 0; i < int21Cnt; i++)
	{
		printf ("EAX = %08lx  EBX = %08lx  ECX = %08lx  EDX = %08lx\n"
			"EDI = %08lx  ESI = %08lx  EBP = %08lx\n"
			"EIP = %08lx   CS = %08x   DS = %08x   ES = %08x\n",
			regs [i].eax,
			regs [i].ebx,
			regs [i].ecx,
			regs [i].edx,
			regs [i].edi,
			regs [i].esi,
			regs [i].ebp,
			regs [i].eip,
			regs [i]. cs,
			regs [i]. ds,
			regs [i]. es);
		printf ("-------------------------------------------------------\n");
	}
}

