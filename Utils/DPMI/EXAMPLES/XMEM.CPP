// (C) Copyright 1992 Qualitas, Inc.  All rights reserved.
//
// xmem.cpp - example usage of memory classes in DPMI class library
//

#include <iostream.h>
#include <iomanip.h>
#include "dpmihost.h"
#include "segment.h"

//
// Function to output AbstractSegment and derived classes
//
ostream& operator << (ostream& str, AbstractSegment& s)
{
	void far *p=s.ptrTo();

	str.fill('0');
	str << "Segment: selector=" << setw(4) << hex << FP_SEG(p);
	str << " Base=" << setw(8) << s.segmentBase();
	str << " Size=" << setw(8) << s.segmentSize();

	if (s.queryProp(present))
		str << " present";
	else
		str << " not present";

	if (s.queryProp(executable))
	{
		str << " code";
		if (s.queryProp(readable))
			str << " readable";
		else
			str << " execute_only";
	}
	else
	{
		str << " data";
		if (s.queryProp(readable))
			str << " writable";
		else
			str << " read_only";
	}


	if (s.queryProp(big))
		str << " big";


	if (s.queryProp(expandDown))
		str << " expand_down";


	str << "\n";
	return str;
}


#define MAXMEMSEG 512
//
// This function illustrates the use of the MemorySegment class for 
// allocating 64 KB blocks of memory from DPMI.
//
void AllocateMemory(void)
{
	int i;
	uLong totmem;

	// declare an array of pointers to MemorySegment
	MemorySegment* pMemSegs[MAXMEMSEG];

	cout << "Memory Allocation Test\n";

	for (i=0, totmem=0; i < MAXMEMSEG ; i++)
	{
		// allocate a new 64 KB MemorySegment (arg==0 means 64 KB)
		pMemSegs[i] = new MemorySegment(0);

		// if the pointer to the segment is zero,the allocation failed
		if (pMemSegs[i]->ptrTo() == 0)
			break;
		else
		{	//output the segment information
			cout << *pMemSegs[i];

			totmem += 0x10000;	// tally total memory alloc'ed
		}
	}
	cout << "Total Memory Allocated: " << dec << totmem << " bytes\n";

	// free the MemorySegments - releases memory to DPMI host
	for (--i; i >= 0; i--)
		delete pMemSegs[i];
}


//
// This function illustrates the use of the Segment class for creating
// a window on an arbitrary region of the linear address space.
//
void PeekMemory(void)
{
	Segment s;				// create a segment
	uChar far *pSeg = (uChar far *)s.ptrTo();//   and a pointer to it
	s.resize(0x80);				// set its size to 128 bytes

	uLong linearAddress;			// address to examine
	
	while (1)
	{
		cout << "\nEnter linear address to examine (0 to end): ";
		cin >> hex >> linearAddress;

		if (linearAddress == 0)
			break;

		s.move(linearAddress);		// position the segment

		int i=0;
		do				// display segment data
		{
			cout << hex << setw(2) << (int)pSeg[i] << " ";
			i++;
			if ((i % 16) == 0) cout << "\n";

		} while (i < 128);
		cout << "\n";
	};
}


void ShowProperties(void)
{
	Segment s;
	cout << "\nTest Segment Properties\n";
	cout << " Default properties:\n " << s;

	s-present;
	cout << " Make it not present:\n " << s;

	s+executable;
	cout << " Make it a code segment:\n " << s;

	s-executable; s+present; s-writable;
	cout << " Make it present read-only data:\n " << s;
}

// 
// This function illustrates other members and derived classes of 
// AbstractSegment
//
void ShowMisc(void)
{
	// DOSMemory class allocates memory from DOS

	cout << "\nTest other memory classes\n";

	DOSMemory d(0x10);		// create a 0x10 paragraph block
	cout << " A 0x10 paragraph DOSMemory block:\n " << d;

	// Resize it to 8 paragraphs
	d.resize(8);
	cout << " DOSMemory block resized to 8 paragraphs:\n " << d;

	// Create an alias to this using an alternate Segment constructor

	Segment aliasToDOSMemory(d); aliasToDOSMemory+executable;
	cout << " A code alias to that segment:\n " << aliasToDOSMemory;

	// Create a specific descriptor

	Segment specific(0xf);
	cout << " Specific descriptor 0xFh:\n " << specific;

	// Create a CommonRealSegment at paragraph 0xb800

	CommonRealSegment crs(0xb800);
	cout << " A common real segment at paragraph 0xb800:\n " << crs;

	// Create a Huge Segment that maps the low megabyte:

	HugeSegment h(0x100000); h.move(0);
	cout << " A huge segment spanning the low 1 MB:\n " << h;
}


void main(void)
{
	DPMIhost dpmi;

	if (dpmi.getStatus() == DPMIok)
	{
		dpmi.enterProtectedMode();
		AllocateMemory();
		PeekMemory();
		ShowProperties();
		ShowMisc();
	}
	else
		cout << "DPMI host not present\n";
}