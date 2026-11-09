//
// (c) Copyright 1992, Qualitas, Inc.  All Rights Reserved
//
// dpmihost.h - member functions for DPMIhost class
//
#include <dos.h>
#include "dpmihost.h"

//
// DPMIhost constructor
//
// Locates the mode switch entry point, and stores host information
//
DPMIhost::DPMIhost(void)
{
	int dpmiStat;

	majorVersion=minorVersion=0;
	processor=0;

	dpmiStat=DPMIObtainSwitchEntryPoint(&flags, &processor, &majorVersion,
			&minorVersion, &nPrivateDataParas, &entryAddress);

	if (dpmiStat == 0)
		status = DPMIok;
	else
		status = DPMInotOk;

}

//
// Enter protected mode - this member makes the initial switch into
// protected mode.  If the return value is TRUE, the caller is then
// running in protected mode.
//
boolean DPMIhost::enterProtectedMode(uChar bitness)
{
	int dpmiStat;

	if ((bitness != 16) && (bitness != 32))
		return FALSE;

	if ((bitness == 32) && ((flags & 1) == 0))
		return FALSE;

	dpmiStat=DPMIEnterProtectedMode(entryAddress, (bitness==32)?1:0,
			nPrivateDataParas , 0 );

	if (dpmiStat == 0)
	{
		selectorDelta = DPMIGetSelectorDelta();
		status = DPMIok;
	}
	else
		status = DPMInotOk;

	return (status == DPMIok) ? TRUE:FALSE;
}




















