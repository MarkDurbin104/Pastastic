//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// exception.h - header for ExceptionHandler class 
//
// The ExceptionHandler class allows easy creation of handlers for
// processor exceptions under DPMI.  The exception frame structure,
// excFrame, is passed in as an argument, and its fields may be
// modified by the handler.  In addition, a structure containing the 
// register state at time of the exception is passed in as an argument, 
// and its fields may be read and modified, except for the fields
// which correspond to fields in the exception frame (namely cs, ip, 
// ss, sp, and flags).
//
// The constructor hooks the requested exception and maintains the
// previous value of the exception vector.  The destructor unhooks
// the vector, restoring it to the previous value.
//
// The class library provides exception dispatching so that DS==SS when
// the handler executes.
//
// Do not declare static ExceptionHandlers, because the processor
// is not running in protected mode at start up time.  It is recommended
// to declare a static ExceptionHandler*, and initialize it by dynamically
// creating an ExceptionHandler with the new operator.
//
// Example:
//
//	#include "dpmihost.h"
//	#include "exception.h"
//		
//	. . .
//
//	ExceptionHandler* pGP;
//
//	void myGPhandler(dpmiRegs_t dRegs, excFrame ef)
//	{
//
//		cout << hex << "General protection fault at " << ef.excCS 
//		     << ":" << ef.excIP "\n";
//
//		. . . body of handler . . .
//
//	}
//
//	void main(void)
//	{
//		. . . normal enter protected mode calls . . .
//			
//		pGP = new ExceptionHandler(0xD, myGPhandler);
//
//		. . .
//			
//		delete pGP;
//	}
//

#include "dpmi.h"

class ExceptionHandler 
{
public:
	ExceptionHandler(uChar ord, void (*handler)(dpmiRegs_t, excFrame));
	~ExceptionHandler(void);

	void callPrevious(dpmiRegs_t&, excFrame&);

protected:
	uChar ordinal;
	void far* previousVector;
	void (*prevDispatch)(dpmiRegs_t, excFrame);
};
