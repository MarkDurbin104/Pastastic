//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// dpmiint.h - definitions for InterruptHandler classes
//
// The InterruptHandler and RealInterruptHandler classes provide a 
// means to install and manage interrupt handlers in a DPMI environment.
//
// Example:
//
//
//	#include "dpmiint.h"
//
//	InterruptHandler* pKeyHandler;
//
//	void KeybdIntHandler(dpmiRegs_t iFrame)
//	{
//
//		pKeyHandler->callPrevious(iFrame);  // invoke previous
//						     //  (if desired)
//							
//		 . . . body of handler . . . 
//
//	}
//
//
//	void main(void)
//	{
//		. . . enter protected mode . . .
//
//		pKeyHandler = new InterruptHandler(9, KeybdIntHandler);
//
//		. . . body of program . . .
//
//		delete pKeyHandler;
//		. .  .
//	}
//
// Notes:
//
//	* The class automatically dispatches to the handler such that
//	  DS == SS (normal small model operation)
//	* The handler may change registers by modifying members of the
//	  dpmiRegs_t structure (see dpmi.h).
//	* Usage guidelines apply equally to RealInterruptHandlers
//	

#include "dpmi.h"

class InterruptHandler 
{
public:
	InterruptHandler(uChar ord, void (*isr)(dpmiRegs_t));
	~InterruptHandler(void);
	void callPrevious(dpmiRegs_t&);

protected:
	InterruptHandler(uChar ord);
	uChar ordinal;
	void far* previousVector;
	void (*prevDispatch)(dpmiRegs_t);
	int mode; //0=real 1=prot
};


class RealInterruptHandler : public InterruptHandler
{
public:
	RealInterruptHandler(uChar ord, void (*isr)(dpmiRegs_t));
	~RealInterruptHandler(void);
};
