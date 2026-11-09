#include	<stdlib.h>
#include	<mem.h>

#include	"int32.h"

extern	char	_interrupt32Thunk [];
extern	int	_interrupt32ThunkSize;
extern	int	_I32TdsLoadLabel;
extern	int	_I32TcallLabel;
extern	int	_I32TchainCmp;
extern	int	_I32TchainLabel;
extern	int	_I32TchainOffset;
extern	int	_I32TchainSel;

static int interrupt32ThunkSize =	(int)&_interrupt32ThunkSize;
static int I32TdsLoadLabel =		(int)&_I32TdsLoadLabel;
static int I32TcallLabel =		(int)&_I32TcallLabel;
static int I32TchainCmp =		(int)&_I32TchainCmp;
static int I32TchainLabel =		(int)&_I32TchainLabel;
static int I32TchainOffset =		(int)&_I32TchainOffset;
static int I32TchainSel =		(int)&_I32TchainSel;

#define adjust(where,what) (*(char**)(thunk + (where))) += (what)
#define stampDD(where,what) *(void**)(thunk + (where)) = (what)
#define stampDW(where,what) *(unsigned short *)(thunk + (where)) = (what)

void *	_makeInt32Thunk (void *proc, void *dsLoc, unsigned short chainSel, unsigned long chainOffset)
{
	char	*thunk;

	thunk = (char *)malloc (interrupt32ThunkSize);
	if	(thunk)
	{
		memcpy (thunk, _interrupt32Thunk, interrupt32ThunkSize);
		stampDD	(I32TdsLoadLabel, dsLoc);
		stampDD	(I32TcallLabel,   (char *)(((char *)proc) - (thunk + I32TcallLabel + 4)));
		adjust	(I32TchainCmp, 	  ((unsigned long)thunk) - ((unsigned long)_interrupt32Thunk));
		adjust	(I32TchainLabel,  ((unsigned long)thunk) - ((unsigned long)_interrupt32Thunk));
		stampDD	(I32TchainOffset, (void *)chainOffset);
		stampDW	(I32TchainSel, 	  chainSel);
	}

	return thunk;
}

