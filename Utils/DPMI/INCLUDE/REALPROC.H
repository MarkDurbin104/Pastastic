//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// realproc.h - definitions for RealProcedure class
//
// The RealProcedure class provides a simple means of calling far functions
// in real mode.  The class is based on DPMI function 0x301, Call Real
// Procedure with Far Return.
//
// The constructor for the class accepts the procedure address and the count
// of bytes to copy to the real mode stack.  Callers may then invoke the
// the RealProcedure with normal function calling syntax.  
//
// This small model implementation makes some simplifying assumptions.  The 
// constructor assumes that the protected mode code and data segments 
// are accessible from real mode (i.e., are below address 1 MB), and that 
// the real procedure uses the same code and data segment.  All RealProcedures
// are called on a statically allocated stack within the data segment. 
// Therefore, there is no need to convert near pointers or copy data between
// address spaces, as would be necessary in a generalized real procedure
// calling facility.
//
// RealProcedures can return values.  The cast operator methods provide a
// means to extract return values from the real mode call structure associated
// with the RealProcedure object.  Casting the return value of a RealProcedure
// call causes the appropriate cast operator to compute the return value
// based on the return type and the register state recorded by the DPMI host
// when the real call returned. Types in addition to those provided
// may be implemented in derived classes if necessary.
//
// Example:
//
//	long theRealFunction(char *s, long l, short s)
//	{
//		return l+s+strlen(s);
//	}
//
//	void test(void)
//	{
//		RealProcedure rFunc(theRealFunction, 
//				sizeof(char*)+sizeof(long)+sizeof(short));
//
//		long result;
//
//		result = (long)rFunc("abcdefgh", 0x100L, 0x10);
//
//		...
//	}
//
#include "dpmi.h"

class RealProcedure
{
public:
	RealProcedure(void far *procAddress, int nArgBytes=0);	
	RealProcedure& operator()(...);

	operator char()
	  {return (char)(dRegs.drEAX.s & 0xff);};
	operator int() 
	  {return (int)dRegs.drEAX.s;};
	operator long()
	  {return (long)(dRegs.drEAX.s)|((uLong)dRegs.drEDX.s << 16);};

protected:
	uShort argSize;
	dpmiRegs_t dRegs;
};



