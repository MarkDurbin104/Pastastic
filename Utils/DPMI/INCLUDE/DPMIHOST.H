//
// (c) Copyright 1992, Qualitas, Inc.  All Rights Reserved
//
// dpmihost.h - definition for DPMIhost class
//

#include "dpmi.h"
#include "dpmierr.h"

//
// The DPMIhost class abstracts the detection of a DPMI host, and provides
// methods that access host parameters and make the initial entry to 
// protected mode.  
//
// Example:
//
//	#include "dpmihost.h"
//
//	void main(void)
//	{
//		DPMIhost dpmi;
//
//		if (dpmi.getStatus() == DPMIok)
//		{
//			dpmi.enterProtectedMode();
//
//
//			. . . 
//
//
//		}
//		else
//			cout << "DPMI host not present\n";
//
//	}
//
//
class DPMIhost
{
public:
	
	DPMIhost(void);			// Constructor

					// Use this member to verify detection
					// and validity of DPMI host in system
	DPMIerr	getStatus() {return status;};

					// This member is only for INITIAL
					// switch into protected mode
	boolean	enterProtectedMode(uChar bitness=16);

					// Retrieves version info
	void	getVersion(uChar *major, uChar *minor)
		{ *major=majorVersion;
		  *minor=minorVersion;
		};
	uChar	getProcessor(void)	// Returns processor code x=2,3,4
		{ return processor;};	//   as in 80x86

	uChar	getSelectorDelta(void)	// Returns delta between consecutive
		{ return selectorDelta;};//selectors

protected:
	uChar 	majorVersion;
	uChar 	minorVersion;
	uShort 	flags;
	uChar 	processor;
	uChar 	selectorDelta;
	uShort	nPrivateDataParas;
	void	(far* entryAddress)();
	DPMIerr	status;
};
