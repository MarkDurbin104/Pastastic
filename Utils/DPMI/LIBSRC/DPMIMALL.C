//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// dpmimall.c - second level DPMI memory calls
//

#include <dos.h>
#include "dpmi.h"


//======================================================================
// Function: Allocate memory and selector
//
// Synopsis:
//
//	void far *DPMImalloc(uShort size, struct DPMImemory_t *mem)
//
// Description:
//
//	This is a higher level call that allocates a block of memory
//	whose size is given by the size argument (size == 0 is taken
//	to mean 64 KB), and allocates a descriptor to map it.  The 
//	caller provides a pointer to a DPMImemory_t struct that records
//	the memory handle and selector.  The function returns a far
//	pointer to offset zero of the allocated block.
//
void far *DPMImalloc(uShort size, struct DPMImemory_t *mem)
{
	uLong lSize;
	uLong base;
	
	lSize = size ? (uLong)size : 0x10000L;

	if (DPMIAllocateDescriptors(1, &mem->sel) != 0)
	{
		mem->handle = 0;
		return 0;
	}

	if (DPMIAllocateMemory(lSize, &base, &mem->handle) != 0)
	{
		DPMIFreeDescriptor(mem->sel);
		return 0;
	}


	DPMISetSegmentBase(mem->sel, base);
	DPMISetSegmentLimit(mem->sel, lSize-1);

	return (void far *)MK_FP(mem->sel, 0);
}


//======================================================================
// Function: Free memory and selector
//
// Synopsis:
//
//	void DPMIfree(struct DPMImemory_t *mem)
//
// Description:
//
//	This function frees the memory block and selector allocated 
//	by DPMImalloc.
//
void DPMIfree(struct DPMImemory_t *mem)
{
	DPMIFreeMemory(mem->handle);
	DPMIFreeDescriptor(mem->sel);
}



//======================================================================
// Function: Resize memory and selector
//
// Synopsis:
//
//	boolean DPMIresize(uShort newSize, struct DPMImemory_t *mem)
//
// Description:
//
//	This function attempts to resize the memory block whose handle
//	is found in the structure pointed to by the mem argument to
//	the size indicated by the newSize argument. (As with DPMImalloc,
//	newSize==0 is taken to mean 64 KB.) If successful, the limit
//	of the corresponding descriptor is set accordingly.
//
//	The function returns TRUE if the resize operation is successful,
//	otherwise false.
//
boolean DPMIresize(uShort newSize, struct DPMImemory_t *mem)
{
	uLong lSize;
	uLong base;
		
		
	lSize = newSize ? (uLong)newSize : 0x10000L; 
	
	if (DPMIResizeMemory(&mem->handle, lSize, &base) != 0)
		return FALSE;
	
	DPMISetSegmentBase(mem->sel, base);
	DPMISetSegmentLimit(mem->sel, lSize-1);

	return TRUE;
}