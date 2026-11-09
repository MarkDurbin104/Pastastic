// (C) Copyright 1992 Qualitas, Inc.  All rights reserved.
//
// xcept.cpp - example usage of exception class in DPMI class library
//

#include <iostream.h>
#include <iomanip.h>
#include "dpmihost.h"
#include "exceptio.h"
#include "segment.h"


ExceptionHandler* pNPhandler;
MemorySegment* pMemSeg;

// Handler for Segment-Not-Present exceptions
//
// This handler serves to illustrate how to implement exception handlers.
// In order to run on a local stack, it is critical to call the enter
// member of the ExceptionHandler class immediately upon entry to the 
// handler.  
//
// Although this example does not do so, it is possible to modify the
// values in the excFrame structure (fault CS:IP, flags, SS:SP). By
// doing so it is possible for the exception handler to alter the main 
// thread of execution.
//
void handleNotPresentException(dpmiRegs_t regs, excFrame ef)
{
	cout << "Segment not present: selector=" << hex << ef.excError
	     << "\n";
	cout << "Fault address is " << ef.excCS << ":" << ef.excIP << "\n";
	cout << " ax=" << regs.drEAX.s << " bx=" << regs.drEBX.s;
	cout << " cx=" << regs.drECX.s << " dx=" << regs.drEDX.s;
	cout << " si=" << regs.drESI.s << " di=" << regs.drEDI.s << "\n";
	cout << " ds=" << regs.drDS << " es=" << regs.drES;
	cout << " ss=" << ef.excSS  << " sp=" << ef.excSP << "\n";

	*pMemSeg + present;		// make it present
}

// This function illustrates the use of exception handlers.  It creates
// an handler for exception 0xB - segment not present.  It then creates
// a memory segment, and makes it not present.  Attempting to access the
// not present segment results in an exception.  The DPMI host invokes
// the installed exception handler, which makes the memory segment
// present.  When it returns, the faulting instruction completes
// successfully.
//
void TestExceptions(void)
{
	char far *p;

	pNPhandler = new ExceptionHandler(0xB, handleNotPresentException);
						// install the handler

	pMemSeg = new MemorySegment(0x100);	// allocate a memory block
	*pMemSeg - present;			// make it not present
	
	p = (char far *)pMemSeg->ptrTo();	// get a pointer to the memory

	*p = 0x77;				// touch it to cause fault
	if (pMemSeg->queryProp(present))
		cout << "Success\n";
}

//
// entry point for the example program
//
void main(void)
{
	DPMIhost dpmi;

	if (dpmi.getStatus() == DPMIok)
	{
		dpmi.enterProtectedMode(16);
		TestExceptions();
	}
	else
		cout << "DPMI host not present\n";
}