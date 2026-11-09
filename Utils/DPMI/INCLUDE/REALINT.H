//
// (c) Copyright 1992  Qualitas,Inc. All Rights Reserved
//
// realint.h - definitions for RealInterrupt class
//
// The RealInterrupt class (not to be confused with the
// RealInterruptHandler class) provides a means to issue
// interrupts in real mode.  
// 
// The required argument for the constructor is the number of
// the interrupt to be issued.  Calling the RealInt with a
// dpmiRegs_t structure as an argument translates to invocation
// of the DPMI function that issues the interrupt in real mode.
//
// It is recommended to set the SS:SP fields of the dpmiRegs_t 
// to zero which directs DPMI to allocate a host stack for the
// real mode interrupt handler to run on.  In addition, users 
// should make sure that the flags field of the dpmiRegs_t has
// a safe value.
//
// Initialize the dpmiRegs_t with the desired register contents.
// Upon return from the call, the dpmiRegs_t is updated to 
// reflect the register state changes caused by the real interrupt.
// 
// Example:
//
//	#include "dpmi.h"
//	#include "realint.h"
//
//	void realIntExample(void)
//	{
//		dpmiRegs_t realRegs;
//		RealInterrupt realEMS(0x67);
//
//		realRegs.drSS=0; realRegs.drESP.s=0; // use host stack
//		realRegs.drFlags = 0x3202;	     // safe flags value
//		realRegs.drEAX.s = 0x4000;	     // ah=40 get status
//
//		realEMS(realRegs);		     // issue real int 67h
//		. . .
//	}
//
#include "dpmi.h"

class RealInterrupt {
public:
	RealInterrupt(uChar ord)		// constructor
		{ordinal = ord;};
	void operator()(dpmiRegs_t& rc)		// invocation by call operator
		{DPMIIssueRealInterrupt(ordinal, 0, &rc);};
protected:
	uChar ordinal;
};
