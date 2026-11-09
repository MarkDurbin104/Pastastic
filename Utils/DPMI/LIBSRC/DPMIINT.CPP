//
// (c) Copyright 1992, Qualitas, Inc.  All Rights Reserved
//
// dpmiint.cpp - member functions for InterruptHandler and 
// 		RealInterruptHandler classes
//
#include <dos.h>
#include "dpmiint.h"

boolean dispatchInitialized=FALSE;

extern "C" {
	void initDispatch(void);
	void (_interrupt *setDispatch(int ord, void (*)(dpmiRegs_t), 
					int, void (**)(dpmiRegs_t)))();
	void callHandler(dpmiRegs_t *, void far *);
};


//
// InterruptHandler class
//
// 	Constructor
//
InterruptHandler::InterruptHandler(uChar ord, void (*isrAddress)(dpmiRegs_t))
{
	selector_t codeAlias;
	uShort far *pFixup;

	if (!dispatchInitialized)
	{
		initDispatch();
		dispatchInitialized = TRUE;
	}
	ordinal = ord;
	mode = 1;

	// get the current vector for the interrupt from DPMI;

	DPMIGetProtInterruptVector(ord,
			(void (_interrupt **)())&previousVector);

	// assume (since this is a small model implementation) that
	// the vector being set up is in the same code segment

	DPMISetProtInterruptVector(ord, 
		(void (_interrupt (*)()))
			setDispatch(ord, isrAddress, 1, &prevDispatch));
}

//
//  This constructor is provided only as a base constructor for the
//  RealInterruptHandler class.  
//
InterruptHandler::InterruptHandler(uChar ord)
{
	ordinal = ord;
}

//
// Destructor
//
InterruptHandler::~InterruptHandler(void)
{
	if (FP_SEG(previousVector) == theCodeSel)
	  setDispatch(ordinal, prevDispatch, 1, &prevDispatch);

	if (previousVector)
		DPMISetProtInterruptVector(ordinal, 
					(void (_interrupt*)())previousVector);
}


//
//
// Call to previous handler
// 
// The previous handler is called after setting up the register as in
// the passed structure.  Care is taken to maintain the internal
// dispatch tables.
//
// This method is inherited and used by the RealInterruptHandler class.
//
void InterruptHandler::callPrevious(dpmiRegs_t& dRegs)
{
	void (*saveDispatch)(dpmiRegs_t);

	if (FP_SEG(previousVector) == theCodeSel)
	{
	    setDispatch(ordinal, prevDispatch, mode, &saveDispatch);
	    callHandler(&dRegs, previousVector);
	    setDispatch(ordinal, saveDispatch, mode, &prevDispatch);
	}
	else
	    callHandler(&dRegs, previousVector);
}


//
//
//  Constructor for real mode interrupt handler
//
RealInterruptHandler::RealInterruptHandler(uChar ord,void (*isr)(dpmiRegs_t)):
		InterruptHandler(ord)
{
	if (!dispatchInitialized)
	{
		initDispatch();
		dispatchInitialized = TRUE;
	}

	DPMIGetRealInterruptVector(ord, (void (far* *)())&previousVector);
	DPMISetRealInterruptVector(ord,
			(void (far *)())setDispatch(ord, isr, 0, &prevDispatch));
	mode = 0;
}

//
//  Destructor for real mode interrupt handler
//
RealInterruptHandler::~RealInterruptHandler(void)
{
	uLong codeBase;
	uShort codePara;

	DPMIGetSegmentBase(theCodeSel, &codeBase);
	codePara = codeBase >> 4;

	DPMITestDisableInts();

	if (FP_SEG(previousVector) == codePara)
	  setDispatch(ordinal, prevDispatch, 0, &prevDispatch);

	DPMISetRealInterruptVector(ordinal,(void (far*)())previousVector);

	previousVector=0;
}
