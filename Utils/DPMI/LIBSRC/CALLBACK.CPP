//
// (C) Copyright 1992 Qualitas, Inc.  All rights reserved.
//
// callback.cpp - member functions of CallBack class for Qualitas DPMI library
//
#include <dos.h>
#include "callback.h"

#define nCallBacks 16

extern "C" void (far *setCBDispatch(int, void (*)(dpmiRegs_t)))();

CallBack* activeCallBacks[nCallBacks];
static boolean cbInitialized = FALSE;

//
// Constructor
//
// The constructor allocates a callback and a locked stack from the DPMI host.
//
CallBack::CallBack(void (*cbHandler)(dpmiRegs_t))
{
	if (!cbInitialized)
	{
		int i;
		for (i=0; i < nCallBacks; i++)
			activeCallBacks[i] = 0;
		cbInitialized = TRUE;
	}


	for (cbNumber = 0; cbNumber < nCallBacks; cbNumber++)
		if (activeCallBacks[cbNumber] == 0)
		{
			activeCallBacks[cbNumber] = this;
			break;
		}

	if (cbNumber == nCallBacks)
	{
		cbAddr = 0;
		cbNumber = -1;
		return;
	}

	DPMIAllocateRealCallBack(&cbRegs, 
		setCBDispatch(cbNumber, cbHandler),
				  (void (far**)())&cbAddr);
}

//
// Destructor
//
// Release the callback to DPMI host and deallocate the local stack
//
CallBack::~CallBack(void)
{

	if (cbNumber != -1)
	{
		DPMIFreeRealCallBack((void (far*)())cbAddr);
		activeCallBacks[cbNumber] = 0;
	}
}
