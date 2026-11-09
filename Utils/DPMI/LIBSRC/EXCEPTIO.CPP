//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// exceptio.cpp - member functions for ExceptionHandler class
//

#include <dos.h>
#include "exceptio.h"

extern "C" {
	void initDispatch(void);
	void (far* setXDispatch(uChar, void (*)(dpmiRegs_t, excFrame),
				void (**)(dpmiRegs_t, excFrame)))();
	void callXHandler(dpmiRegs_t *, excFrame *, void far *);
};

extern boolean dispatchInitialized;

//
//
// ExceptionHandler class
//
// 	Constructor
//
ExceptionHandler::ExceptionHandler(uChar xNum, 
					void (*handler)(dpmiRegs_t,excFrame))
{

	if (!dispatchInitialized)
	{
		initDispatch();
		dispatchInitialized = TRUE;
	}

	// get the current vector for the exception from DPMI

	DPMIGetExceptionVector(xNum, (void (far**)())&previousVector);


	// hook the exception vector

	ordinal = xNum;
	DPMISetExceptionVector(xNum,setXDispatch(xNum,handler,&prevDispatch));
}

//
// destructor
// 
ExceptionHandler::~ExceptionHandler(void)
{

	if (FP_SEG(previousVector) == theCodeSel)
	    setXDispatch(ordinal, prevDispatch, &prevDispatch);

	DPMISetExceptionVector(ordinal, (void (far*)())previousVector);
}

//
// Call the previous exception handler
//
// The register state in dRegs is restored, the exception frame is pushed
// on the stack, and the previous handler is called.  Care is taken to
// maintain the internal dispatching tables correctly.
//
// The exception frame may be altered by the previous handler
//
void ExceptionHandler::callPrevious(dpmiRegs_t& dRegs, excFrame& ef)
{
	void (*saveDispatch)(dpmiRegs_t, excFrame);

	if (FP_SEG(previousVector) == theCodeSel)
	{
	    setXDispatch(ordinal, prevDispatch, &saveDispatch);
	    callXHandler(&dRegs, &ef, previousVector);
	    setXDispatch(ordinal, saveDispatch, &prevDispatch);
	}
	else
	    callXHandler(&dRegs, &ef, previousVector);
}
