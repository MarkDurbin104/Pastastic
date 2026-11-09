//
// (C) Copyright 1992 Qualitas, Inc.  All rights reserved.
//
// xreal.cpp  -  example usage of RealProcedure, RealInterrupt, and
// 		 CallBack classes in DPMI class library
//

#include <iostream.h>
#include <iomanip.h>
#include <dos.h>
#include "dpmihost.h"
#include "dpmiint.h"
#include "realproc.h"
#include "callback.h"
#include "realint.h"

//
// This function can run in either real or protected mode. The
// example program invokes it in both ways to illustrate RealProcedure usage.
//
void far whatMode(void)
{
	if (DPMIGetCPUMode() == 0)
		cout << "Currently running in protected mode\n";
	else
		cout << "Currently running in real/V86 mode\n";
}

//
//  This function must run only in real mode.  It uses the INT 67h vector
//  in the real mode interrupt vector table to locate the system EMS 
//  driver, if any.  Attempting to run this in protected mode would 
//  result in a general protection exception.
//
uShort far findEMS(const char* deviceName)
{
	int i;

	// get EMS vector
	void far* far* pVector = (void far* far*)MK_FP(0, 0x67*4);

	// device name should be at offset 0xA in that para
	char far *pDevice = (char far *)MK_FP(FP_SEG(*pVector), 0xA);

	// compare 8 character strings
	for (i=0; i < 8; i++)
		if (deviceName[i] != pDevice[i])
			break;
	if (i == 8)
		return FP_SEG(*pVector);	// matched string
	else					//   so return paragraph
		return 0;			// didn't find device
}

void TestRealProcs(void)
{
	RealProcedure rWhatMode((void far *)whatMode, 0);

	whatMode();
	rWhatMode();

	RealProcedure rFindEMS((void far *)findEMS, sizeof(char*));

	uShort EMSpara = (int)rFindEMS("EMMXXXX0");
	if (EMSpara != 0)
	{
		cout << "Found EMS at real paragraph " << hex << EMSpara;
		cout << "\n";
	}
	else
		cout << "EMS device not found\n";
}

////////////////  Real Mode CallBack Example //////////////////////////
//
// The example presented here illustrates the mechanics of real mode
// call backs. The protected mode caller invokes real mode software interrupt
// 99h, for which a handler has been installed.  The real mode
// int 99h handler makes a call back to a protected mode call back handler,
// which outputs a message and changes the value of the SI register.  The
// example illustrates that a register changed in the call back handler
// can be passed back through the real mode interrupt handler to the
// original caller.

RealInterruptHandler* p99Handler;	// pointer to RealInterruptHandler obj
CallBack *pCB99;			// pointer to CallBack object
void (far *cb99addr)();			// real mode callback address

//
// The call back handler - runs in protected mode - called back by real
// mode int 99h handler.  This handler negates the value of the SI register.
//
void CallBack99Handler(dpmiRegs_t iFrame)
{
	cout << "Handling callback from real mode int 99h handler"
	     << "  si=" << dec << iFrame.drESI.s << "\n";

	iFrame.drESI.s = -iFrame.drESI.s;
}

//
// The real mode int 99h handler - installed by the original protected mode
// caller.  The protected mode caller generates an real mode int 99h using
// the DPMI library call.
//
void HandleRealInt99(dpmiRegs_t iFrame)
{
	uShort regSI;

	cout << "In real int 99h handler\n";

	regSI = iFrame.drESI.s;

	_asm mov si, regSI

	(*cb99addr)();		// call back to protected mode handler

	_asm mov regSI, si

	iFrame.drESI.s = regSI;
}

//
// The call back test driver - installs a real mode software int 99h 
// handler - generates a real int 99h - real mode int 99h handler calls 
// back to the call back handler.  This example also shows how to use
// the RealInterrupt class.
//
void TestCallBack(void) 	
{
	dpmiRegs_t rRegs;


	// install real mode int 99h handler
	p99Handler = new RealInterruptHandler(0x99, HandleRealInt99);

	// install call back handler
	pCB99 = new CallBack(CallBack99Handler);

	// get real mode paragraph:offset to call back to
	cb99addr = (void (far*)())pCB99->getCallBackAddress();

	// create a RealInterrupt for real interrupt 0x99

	RealInterrupt real99(0x99);

	// set up a register structure to invoke the real int 0x99
	rRegs.drESI.s = 99; rRegs.drSP=rRegs.drSS=0; rRegs.drFlags=0x3202;

	// Issue int 0x99 in real mode
	real99(rRegs);

	cout << "On return from int 99, si=" << dec 
	     << (int)rRegs.drESI.s << "\n";

	delete p99Handler;	// unhook real int 99h
	delete pCB99;		// release call back to DPMI host
}

void main(void)
{
	DPMIhost dpmi;

	if (dpmi.getStatus() == DPMIok)
	{
		dpmi.enterProtectedMode();
		TestRealProcs();
		TestCallBack();
	}
	else
		cout << "DPMI host not present\n";
}