// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// segment.cpp - member functions for AbstractSegment and related classes
//

#include "dpmi.h"
#include "segment.h"

boolean addProp(selector_t selector, SegmentProp_t prop);
boolean removeProp(selector_t selector, SegmentProp_t prop);

//
// Constructor for Block class
//
Block::Block(uLong requestedSize)
{
	if (DPMIAllocateMemory(size=requestedSize, &base, &handle) != 0)
	{
		size = 0;
		base = 0;
		handle = 0;
	}
}

//
// Destructor for Block class
//
Block::~Block(void)
{
	DPMIFreeMemory(handle);
}


//
// Resize a Block
//
boolean Block::setSize(uLong requestedSize)
{
	if (DPMIResizeMemory(&handle, requestedSize, &base) != 0)
		return FALSE;
	else
	{
		size = requestedSize;
		return TRUE;
	}
}

//
// Get segment size from DPMI host
// 
uLong AbstractSegment::segmentSize(void)
{
	uLong s;
	
	if (DPMIGetSegmentLimit(selector, &s) == 0)
		return s+1;
	else
		return 0;
}

//
// Get segment base from DPMI host
//
uLong AbstractSegment::segmentBase(void)
{
	uLong b;
	
	if (DPMIGetSegmentBase(selector, &b) == 0)
		return b;
	else
		return 0;
}

//
// Query DPMI host for segment properties
//
boolean AbstractSegment::queryProp(SegmentProp_t prop)
{
	uChar arb;
	uChar arb386;
	
	if (DPMIGetSegmentAttributes(selector, &arb, &arb386) != 0)
		return FALSE;
	
	else switch (prop)
	{
	case present:
		if (arb & 0x80)
			return TRUE;
		else
			return FALSE;

	case executable:
		if (arb & 0x8)
			return TRUE;
		else
			return FALSE;

	case readable:
	case writable:
		if (arb & 0x2)
			return TRUE;
		else
			return FALSE;
	case big:
		if (arb386 & 0x40)
			return TRUE;
		else
			return FALSE;
	default:
		return FALSE;
	}
}

//
// Constructor for Segment
//
Segment::Segment(void)
{
	if (DPMIAllocateDescriptors(1, &selector) != 0)
		selector = 0;
}

//
// Constructor for Segment - specific descriptor method
//
Segment::Segment(selector_t specific)
{
	struct descriptor_t descriptor;

	if (DPMIAllocateSpecificDescriptor(specific) != 0)
		selector = 0;
	else
	{// 386MAX does not set up specific descriptors
		selector = specific;
		DPMIGetDescriptor(selector, &descriptor);
		descriptor.descArb &= ~0x60;
		descriptor.descArb |= 0x82 + ((theCodeSel & 3) << 5);
		DPMISetDescriptor(selector, &descriptor);
	}
}

//
// Constructor for Segment - alias descriptor method
//
Segment::Segment(AbstractSegment& segment) 
{
	if (DPMIAllocateDescriptors(1, &selector) != 0)
		selector = 0;
	else
	{
		resize((uShort)segment.segmentSize());
		move(segment.segmentBase());
	}
}

//
// Destructor for Segment
//
Segment::~Segment(void)
{
	DPMIFreeDescriptor(selector);
}


//
// Add property to Segment
//
boolean Segment::operator+(SegmentProp_t prop)
{
	return addProp(selector, prop);
}

//
// Remove property from Segment
//
boolean Segment::operator-(SegmentProp_t prop)
{
	return removeProp(selector, prop);
}

//
// Resize a Segment
//
boolean Segment::resize(uShort newSize)
{
	uLong size;
	
	if (newSize == 0)
		size = 0x10000;
	else
		size = newSize;
	

	if (DPMISetSegmentLimit(selector, size-1) == 0)
		return TRUE;
	else
		return FALSE;
}

//
// Change the base of a Segment
//
boolean Segment::move(uLong newBase)
{
	if (DPMISetSegmentBase(selector, newBase) == 0)
		return TRUE;
	else
		return FALSE;
}

//
// Constructor for CommonRealSegment
// 
CommonRealSegment::CommonRealSegment(uShort paragraph)
{
	if (DPMIParaToSelector(paragraph, &selector) != 0)
		selector = 0;
}



//
// Constructor for DOSMemory
//
DOSMemory::DOSMemory(uShort nParas)
{
	uShort maxParas;
	uShort paraBase;

	if (DPMIAllocateDOSMemory(nParas, &paraBase, &selector, &maxParas)!=0)
		selector = 0;
}

//
// Destructor for DOSMemory
//
DOSMemory::~DOSMemory(void)
{
	DPMIFreeDOSMemory(selector);
}

//
// Resize a DOSMemory
//
boolean DOSMemory::resize(uShort nParas)
{
	uShort maxParas;

	if (DPMIResizeDOSMemory(selector, nParas, &maxParas) != 0)
		return FALSE;
	else
		return TRUE;
}


//
// Constructor for MemorySegment
//
MemorySegment::MemorySegment(uShort s) : Block(s==0 ? 0x10000L:(uLong)s)
{
	if (base == 0)
	{
		if (selector)
			DPMIFreeDescriptor(selector);
		selector = 0;
	}
	else
	{
		DPMISetSegmentBase(selector, base);
		DPMISetSegmentLimit(selector, size-1);
	}
}


//
// Constructor for MemorySegment - specific descriptor method
//
MemorySegment::MemorySegment(uShort s, selector_t sel):
			Block(s==0 ? 0x10000L:(uLong)s), Segment(sel)
{
	DPMISetSegmentBase(selector, base);
	DPMISetSegmentLimit(selector, size-1);
}


//
// Get size of memory segment
//
uLong MemorySegment::segmentSize(void)
{
	return blockSize();
}

//
// Resize a memory segment
//
boolean MemorySegment::resize(uShort newSize)
{

	uLong lSize = newSize ? newSize:0x10000L;

	if (DPMIResizeMemory(&handle, lSize, &base) != 0)
		return FALSE;

	if (DPMISetSegmentLimit(selector, lSize-1) != 0)
	{
		DPMIResizeMemory(&handle, size, &base);
		return FALSE;
	}
	else
	{
		size = lSize;
		return TRUE;
	}
}

//
// Constructor for HugeSegment
//
HugeSegment::HugeSegment(uLong requestedSize)
{
	int i;
	selector_t sel;

	if (requestedSize == 0)
	{
		abstractSize = 0;
		nDescriptors = 0;
		selector = 0;
		return;
	}
	

	// compute the number of descriptors required to span the 
	// requested size

	nDescriptors = (requestedSize-1)/0x10000 + 1;
	
	if (DPMIAllocateDescriptors(nDescriptors, &selector) != 0)
	{
		abstractSize = 0;
		nDescriptors = 0;
		selector = 0;
		return;
	}

	abstractSize = requestedSize;


	// loop for each descriptor, sets limit and base

	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
	{
		if (requestedSize > 0x10000)
			DPMISetSegmentLimit(sel, 0xffff);
		else
			DPMISetSegmentLimit(sel, requestedSize-1);

		requestedSize -= 0x10000;
	}
}

//
// Destructor for HugeSegmnet - frees each descriptor
//
HugeSegment::~HugeSegment(void)
{
	int i;
	selector_t sel;
	
	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
		DPMIFreeDescriptor(sel);
}

//
// Change the base of a HugeSegment
//
boolean HugeSegment::move(uLong newBase)
{
	int i;
	selector_t sel;
	
	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
	{
		if (DPMISetSegmentBase(sel, newBase) != 0)
			return FALSE;

		newBase += 0x10000;
	};

	return TRUE;
}

//
// Resize a huge segment - short size specified
//
boolean HugeSegment::resize(uShort newShortSize)
{
	// call long resize
	return resize(newShortSize ? (uLong)newShortSize : (uLong)0x10000L);
}


//
// Resize a huge segment - long size specified
//
boolean HugeSegment::resize(uLong newSize)
{
	selector_t sel;
	int i;
	int newDescCount;


	newDescCount = (newSize-1)/0x10000 + 1;

	if (newDescCount > nDescriptors)	// cannot grow 
		return FALSE;

	if (newDescCount < nDescriptors)
	{
		// release descriptors no longer needed

		sel=selector+(nDescriptors-1)*DPMIGetSelectorDelta();

		for (i=nDescriptors-newDescCount; i > 0; i--)
		{
			DPMIFreeDescriptor(sel);
			sel -= DPMIGetSelectorDelta();
		}
	}

	nDescriptors = newDescCount;
	abstractSize = newSize;


	// for each descriptor, reset base and size

	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
	{
		if (newSize > 0x10000)
			DPMISetSegmentLimit(sel, 0xffff);
		else
			DPMISetSegmentLimit(sel, newSize-1);

		newSize -= 0x10000;
	}

	return TRUE;
}


//
// Add property to HugeSegmnet
//
boolean HugeSegment::operator+(SegmentProp_t prop)
{
	selector_t sel;
	int i;
	
	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
		if (addProp(sel, prop) != TRUE)
			return FALSE;
		
	return TRUE;
}



//
// Remove property from HugeSegmnet
//
boolean HugeSegment::operator-(SegmentProp_t prop)
{
	selector_t sel;
	int i;
	
	for (i=0,sel=selector;i<nDescriptors; i++,sel+=DPMIGetSelectorDelta())
		if (removeProp(sel, prop) != TRUE)
			return FALSE;
		
	return TRUE;
}


boolean addProp(selector_t selector, SegmentProp_t prop)
{
	uChar arb;
	uChar arb386;

	if (DPMIGetSegmentAttributes(selector, &arb, &arb386) != 0)
		return FALSE;
	
	else switch (prop)
	{
	case present:
		arb |= 0x80; break;

	case executable:
		arb |= 0x8; break;

	case readable:
	case writable:
		arb |= 0x2; break;

	case big:
		arb386 |= 0x40; break;
		
	default:
		return FALSE;
	}
	
	if (DPMISetSegmentAttributes(selector, arb, arb386) != 0)
		return FALSE;
	else
		return TRUE;
}



boolean removeProp(selector_t selector, SegmentProp_t prop)
{
	uChar arb;
	uChar arb386;

	if (DPMIGetSegmentAttributes(selector, &arb, &arb386) != 0)
		return FALSE;
	
	else switch (prop)
	{
	case present:
		arb &= ~0x80; break;

	case executable:
		arb &= ~0x8; break;

	case readable:
	case writable:
		arb &= ~0x2; break;

	case big:
		arb386 &= ~0x40; break;
		
	default:
		return FALSE;
	}
	
	if (DPMISetSegmentAttributes(selector, arb, arb386) != 0)
		return FALSE;
	else
		return TRUE;
}

//
// Constructor for HugeMemorySegment
//
HugeMemorySegment::HugeMemorySegment(uLong requestedSize) :
			Block(requestedSize), 
			HugeSegment(requestedSize)
{
	HugeSegment::move(base);
}

//
// Resize HugeMemorySegment - short arg
//
boolean HugeMemorySegment::resize(uShort newShortSize)
{
	return resize(newShortSize ? (uLong)newShortSize : (uLong)0x10000L);
}


//
// Resize HugeMemorySegment - long arg
//
boolean HugeMemorySegment::resize(uLong newSize)
{
	uLong oldSize = size;

	if (Block::setSize(newSize) == FALSE)
		return FALSE;

	if (HugeSegment::resize(newSize) == FALSE)
	{
		Block::setSize(oldSize);
		return FALSE;
	}
	else
		return TRUE;
}
		