//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// realproc.h - member functions for RealProcedure class
//
#include <dos.h>
#include "realproc.h"
#define RPStackSize 512

//
// Constructor
//
RealProcedure::RealProcedure(void far *function, int nArgBytes)
{
	uLong codeBase;
	uLong dataBase;

	DPMIGetSegmentBase(theCodeSel, &codeBase);
	DPMIGetSegmentBase(theDataSel, &dataBase);

	argSize = (nArgBytes+1) & ~1;

	dRegs.drFlags = 0x3202;
	dRegs.drIP = FP_OFF(function);
	dRegs.drCS = codeBase >> 4;
	dRegs.drDS = dRegs.drSS = dRegs.drES = dataBase >> 4;
}

//
// Call operator - this member automatically invokes the DPMI service
// for calling real procedures. The argument size is given when the
// object is constructed.  This member returns a reference to RealProcedure,
// which can be casted to extract desired values from the real mode
// call structure.  Note: because there is only one real mode call structure
// per RealProcedure, a RealProcedure is not reentrant.
// 
RealProcedure& RealProcedure::operator()(...)
{
	uChar RealProcedureStack[RPStackSize];
	int nArgBytes = argSize;
	dpmiRegs_t far *dRegsPtr=(dpmiRegs_t far *)MK_FP(theDataSel, &dRegs);
	dRegs.drSP = (uShort)&RealProcedureStack[RPStackSize];
	
	_asm lea	bx, [bp+4]
	_asm mov	cx, nArgBytes
	_asm add	bx, cx
	_asm shr	cx, 1
	_asm jcxz	argsPushed

pushArgs:
	_asm push	ss:[bx]
	_asm sub	bx, 2
	_asm loop	pushArgs

argsPushed:
	_asm mov	ax, 0301h
	_asm xor	bh, bh
	_asm mov	cx, nArgBytes
	_asm les	di, dRegsPtr
	_asm int	31h
	_asm add	sp, nArgBytes

	return *this;
}
