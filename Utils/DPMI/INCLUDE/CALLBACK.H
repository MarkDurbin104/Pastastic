//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// callback.h - definitions for CallBack class
//

#include "dpmi.h"

// The CallBack class provides a means for implementing real mode 
// call backs in a DPMI environment.  A CallBack is a real mode
// address (paragraph:offset) allocated by a DPMI host, which,
// when called, transfers control to a specified entry point in
// protected mode.
//
// The constructor for the class requires as an argument the
// address of the call back handler, i.e., the protected mode function
// to be called from real mode.  
//
// After creation, a program obtains the actual real mode call back
// address via the getCallBackAddress member.  This address, when
// called from real mode, invokes the call back handler.
//
// The class automatically dispatches to the call back handler such that
// DS==SS, and normal small model operation is possible.
//
// The contents of the dpmiRegs structure on the handler's stack reflect
// the real mode register state at the time of the callback.  Any 
// modifications to this state are realized when the handler returns to
// real mode.  The class automatically configures the return CS:IP and
// SS:SP.
//
// CallBacks are not reentrant.
//
// Example:
//
//
//	#include "callback.h"
//	#include "realfunc.h"
//
//	CallBack* pCallBack;
//
//	void myCallBackHandler(dpmiRegs dRegs)
//	{
//
//		. . .
//	}
//
//	void far myRealFunction(void (far *cbAddress)())
//	{
//		. . .
//
//		(*cbAddress)();		// invoke call back handler
//
//	}
//
//	void main(void)
//	{
//		. . . normal enter protected mode code . . .
//
//		pCallBack = new CallBack(myCallBackHandler);
//
//
//		RealProcedure rp(myRealFunction, sizeof(void far*));
//
//
//		rp(pCallBack->getCallBackAddress());
//
//	}

class CallBack
{
public:
	CallBack(void (*cbHandler)(dpmiRegs_t));
	~CallBack(void);
	void far *getCallBackAddress() {return cbAddr;};
	
protected:
	int cbNumber;
	void far *cbAddr;
	dpmiRegs_t cbRegs;
};