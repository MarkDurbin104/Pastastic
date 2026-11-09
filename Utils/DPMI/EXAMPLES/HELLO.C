//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// Simple example of accessing DPMI library
//
#include <stdio.h>
#include <dos.h>
#include "dpmi.h"

void main(void)
{
	int    dpmiStat;		// status return
	uShort flags;			// 32-bitness flag
	uChar  processor;		// processor type
	uChar  majorVersion;		// major version number
	uChar  minorVersion;		// minor version number
	uShort nPrivateParas;		// size of host data
	void (far* entryAddress)();	// switch entry point
	struct freeMem_t freeMem;	// memory info structure

// The first call to the DPMI library is a query to detect the presence
// of a DPMI host, and if found, to return information required to
// make the initial entry into protected mode.

	dpmiStat=DPMIObtainSwitchEntryPoint(&flags, &processor, &majorVersion,
			&minorVersion, &nPrivateParas, &entryAddress);

	if (dpmiStat != 0)
	{
		fprintf(stderr, "no DPMI host available\n");
		exit(1);
	}
	else
	{
		printf("Host information:\n");
		printf("\tFlags:\t\t%04x\n", flags);
		printf("\tVersion:      %d.%d\n", majorVersion, minorVersion);
		printf("\tProcessor:    80%d86\n", processor);
		printf("\tPrivate data:\t%d paragraphs\n", nPrivateParas);
		printf("\tEntry address:\t%04x:%04x\n", FP_SEG(entryAddress),
			FP_OFF(entryAddress));
	}

// If the DPMIObtainSwitchEntryPoint call succeeds, calling
// DPMIEnterProtectedMode switches the processor to protected mode.

	DPMIEnterProtectedMode(entryAddress, 16, nPrivateParas , 0 );

// Detect the current mode with DPMIGetCPUMode() -

	if (DPMIGetCPUMode() == 0)
		printf("\nHello from Protected Mode!\n\n");

	else
	{
		fprintf(stderr, "entry to protected mode failed\n");
		exit(1);
	}

// Once in protected mode, you can use any of the DPMI library calls

	DPMIGetFreeMemory(&freeMem);
	printf("Largest free memory block: 0x%08lx (%ld) bytes\n",
		freeMem.largestFree, freeMem.largestFree);
}
