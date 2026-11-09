//
// (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
//
// dpmi.h - header file for Qualitas DPMI Library
//


#ifndef __BORLANDC__
#define MK_FP(s,o) ((void far *)(((unsigned long)s << 16)|(unsigned short)o))
#endif

#ifndef __DPMI__
#define __DPMI__ 1

#define theCodeSel getCS()
#define theDataSel getDS()

// basic typedefs

typedef unsigned char	uChar;
typedef unsigned int	uShort;
typedef unsigned long	uLong;
typedef unsigned short	selector_t;
typedef enum {TRUE=1, FALSE=0} boolean;

// structure for LDT descriptor management

struct descriptor_t
{
	uShort descLimit;	// descriptor limit
	uShort descBaseLo;	// low word of linear base
	uChar  descBaseMid;	// middle byte of linear base
	uChar  descArb; 	// access rights/type byte
	uChar  descArb386;	// extended attributes byte (386+)
	uChar  descBaseHi;	// high byte of linear base
};


union reg			// single long register
{	uLong l;
	uShort s;
};


struct dpmiRegs_t		// DPMI register passing structure
{
	union reg drEDI;
	union reg drESI;
	union reg drEBP;
	union reg drRESV;
	union reg drEBX;
	union reg drEDX;
	union reg drECX;
	union reg drEAX;
	uShort drFlags;
	uShort drES;
	uShort drDS;
	uShort drFS;
	uShort drGS;
	uShort drIP;
	uShort drCS;
	uShort drSP;		// NOTE: When SS:SP is input as 0:0,
	uShort drSS;		// the DPMI host attempts to provide a
};				// small stack for the call.


// structure to receive data from DPMI memory query call

struct freeMem_t
{
	uLong largestFree;
	uLong maxUnlocked;
	uLong maxLocked;
	uLong linearSize;
	uLong nUnlockedPages;
	uLong nFreePages;
	uLong nPhysicalPages;
	uLong freeLinearSpace;
	uLong pageFileSize;
	uLong reserved[3];
};


// structure to define stack frame for processor exception handlers

struct excFrame
{
	uShort excError;	// Error code
	uShort excIP;		// IP of fault address
	uShort excCS;		// CS of fault address
	uShort excFlags;	// flags at exception point
	uShort excSP;		// SP at exception point
	uShort excSS;		// SS at exception point
};


// structure to pass state of registers for raw mode switch

struct rawModeRegs_t
{
	uShort rawDS;
	uShort rawES;
	uShort rawSS;
	uShort rawCS;
};

// types required for DPMI debug watchpoint interface


enum watchSize			// size of watchpoint
{
	wByte = 1,
	wWord = 2,
	wLong = 4
};

enum watchType			// type of watchpoint
{
	wExecute = 0,
	wWrite = 1,
	wReadWrite =2
};


struct DPMImemory_t		// used for DPMImalloc, DPMIresize, DPMIfree
{
	uLong handle;
	selector_t sel;
};



#ifdef __cplusplus
extern "C" {
#endif

//////////////////////////////////////////////////////////////////////
///////////////// DPMI Library Function Prototypes ///////////////////
//////////////////////////////////////////////////////////////////////


// Note on return values:
//
//	Unless indicated otherwise, the functions in the DPMI library
//	return zero to indicate success, and non-zero to indicate failure.
//	This is consistent with the DPMI 0.9 specification, which did not
//	specify a detailed set of error return values.	The DPMI 1.0
//	specification, however, includes specific error return values
//	for each function.  Some version 0.9 hosts have adopted the
//	version 1.0 error returns, and they are as indicated below.
//	However, when running on a version 0.9 host, it is not safe to
//	assume that specific error return values will be available.

//======================================================================
// Function: Release Time Slice
//
// Synopsis:
//
	void DPMIReleaseTimeSlice(void);
//
// Description:
//
//	DPMI clients call this function to indicate an idle state to the
//	DPMI host.  This enables multitasking DPMI hosts to schedule other
//	clients. Installing this call inside idle loops can result in
//	significant improvement of system throughput.
//
// DPMI reference: INT 2Fh AX=1680h


//======================================================================
// Function: Get CPU Mode
//
// Synopsis:

	int DPMIGetCPUMode(void);
//
// Description:
//
//	This function may be used by mode sensitive applications to determine
//	the current processor operating mode. Clients must verify the
//	presence of a DPMI host prior to making this call. The function
//	returns zero if executing in protected mode, and returns non-zero
//	if running in real or virtual 86 mode.
//
// DPMI reference: INT 2Fh AX=1686h


//======================================================================
// Function: Obtain Mode Switch Entry Point
//
// Synopsis:

	int DPMIObtainSwitchEntryPoint(
		uShort *flags,			// 32-bitness flag
		uChar *processor,		// processor type
		uChar *majorVersion,		// major version #
		uChar *minorVersion,		// minor version #
		uShort *nPrivateDataParas,	// size of host data
		void (far* *entryAddress)());	// switch entry point

// Description:
//
//	This call determines if a DPMI host is present, and if so, returns
//	necessary information on how to invoke it.  The function returns
//	zero if a DPMI host was found; otherwise it returns non-zero.
//
//	All arguments are pointers to locations to store return values.
//	The flags argument is non-zero if the DPMI host supports 32-bit
//	applications.  The processor argument is written as 2 (80286),
//	3 (80386), 4 (80486), or 5 (future). The version arguments indicate
//	the version numbers of the DPMI host (For DPMI 0.9, major version is
//	zero, and minor version is 90).  The nPrivateDataParas argument
//	receives the number of paragraphs of memory that the host requires
//	for each client.  If this is non-zero, the client must provide
//	this much memory prior to calling the mode switch entry point, and
//	the memory must be paragraph aligned.
//
//	The value written at the entryAddress argument is the far address
//	to call to make the initial switch into protected mode. See also,
//	DPMIEnterProtectedMode.
//
// DPMI reference: INT 2Fh AX=1687h

//======================================================================
// Function: Enter Protected Mode
//
// Synopsis:
//
	int DPMIEnterProtectedMode(
		void (far *switchEntryPoint)(), // mode switch entry point
		uShort bitness, 		// 0/16 or 1/32
		uShort nPrivateDataParas,	// number of paras required
		uShort NearFar);		// Near (0) or far (1)
						// allocate of HPDA


// Description:
//
//	This function is used to make the initial switch into protected
//	mode.  The switchEntryPoint argument is the value returned in the
//	entryAddress argument of ObtainSwitchEntryPoint.  The bitness argument
//	is 0 or 16 to indicate that the calling client is 16-bit, and is
//	1 or 32 to indicate that the calling client is 32-bit.	The
//	nPrivateDataParas argument is obtained from the function
//	DPMIObtainSwitchEntryPoint.
//
//	If the call returns zero, the client is then running in protected
//	mode.  The segment registers CS, DS, and SS contain selectors that
//	address the same linear memory as they did in real mode at the
//	time of the call.  The selector in ES addresses the programs PSP,
//	and the corresponding descriptor has a limit of 0xFF.  If running
//	on a 32-bit processor, FS and GS are zero.
//
// DPMI reference: calling the mode switch entry point
//
// Version 1.0 Error returns:
//
//	8011h	descriptor unavailable
//	8012h	insufficient memory
//	8021h	32-bit clients not supported

//======================================================================
// Function: Allocate Descriptors
//
// Synopsis:

	int DPMIAllocateDescriptors(
		uShort howMany, 	// how many descriptors to allocate
		selector_t *baseSel);	// receives selector of first desc

// Description:
//
//	This function allocates one or more LDT descriptors. The howMany
//	argument is the number of descriptors to allocate, and the
//	selector of the first allocated descriptor is written to the
//	address pointed to by the baseSel argument.  When more than one
//	descriptor  is allocated, they are consecutive, i.e., the
//	difference between them is obtained by calling DPMIGetSelectorDelta.
//
//	At the time of allocation, each descriptor is of type DATA with
//	a base and limit of zero.  It is the client's responsibility to
//	set up the descriptors with meaningful values.

// DPMI reference: INT 31h AX=0000h
//
// Version 1.0 Error returns:
//
//	8011h	descriptor unavailable.


//======================================================================
// Function: Free Descriptor
//
// Synopsis:

	int DPMIFreeDescriptor(
		selector_t sel);	// Selector of descriptor to free

// Description:
//
//	This function returns the specified descriptor to the DPMI host.
//
// DPMI reference: INT 31h AX=0001h
//
// Version 1.0 Error returns:
//
//	8022h	invalid selector

//======================================================================
// Function: Create Descriptor to Address Real Segment
//
// Synopsis

	int DPMIParaToSelector(
		uShort para,		// paragraph to map
		selector_t *sel);	// selector to address paragraph

// Description:
//
//	This function creates a data descriptor whose base corresponds
//	to the real mode paragraph specified by the para argument.  The
//	function writes the selector of the created descriptor at the
//	address pointed to by the sel argument.  The descriptor limit
//	is 64 KB.
//
//	The function is intended to be used only for commonly accessed
//	regions of the low megabyte, for example, paragraphs 40h, A000h,
//	and B800h. Descriptors allocated by this function should not be
//	modified or freed.  Multiple calls to this function with the same
//	input return the same selector.
//
// DPMI reference: INT 31h AX=0002h
//
// Version 1.0 Error returns:
//
//	8011h	descriptor unavailable


//======================================================================
// Function: Get Selector Delta
//
// Synopsis:

	uShort DPMIGetSelectorDelta(void);

// Description:
//
//	The return value of this function is the difference between
//	consecutive selectors.
//
// DPMI reference: INT 31h AX=0003h


//======================================================================
// Function: Get Segment Base
//
// Synopsis:

	int DPMIGetSegmentBase(
		selector_t sel, 	// selector of segment to get base of
		uLong *base);		// location to receive base of segment

// Description:
//
//	This function retrieves the base of the segment specified by the
//	sel argument.  The linear base of the segment is written at the
//	address pointed to by the base argument.
//
// DPMI reference: INT 31h AX=0006h
//
// Version 1.0 Error returns:
//
//	8022h	invalid selector

//======================================================================
// Function: Set Segment Base
//
// Synopsis:

	int DPMISetSegmentBase(
		selector_t sel, 	// selector of segment to set base of
		uLong base);		// new value for base

// Description:
//
//	This function sets the base of the segment specified by the sel
//	argument to the value of the base argument.
//
// DPMI reference: INT 31h AX=0007h
//
// Version 1.0 Error returns:
//
//	8022h	invalid selector
//	8025h	invalid linear address

//======================================================================
// Function: Get Segment Limit
//
// Synopsis:

	int DPMIGetSegmentLimit(
		selector_t sel, 	// selector of segment to get limit of
		uLong *limit);		// location to receive limit

// Description:
//
//	This function retrieves retrieves the limit of the segment
//	specified by the sel argument, and writes it at the address
//	pointed to by the limit argument.  The function is implemented
//	not by a DPMI call, but with the LSL instruction.
//
//
// DPMI reference: Not a true DPMI function, but included for completeness.
//

//======================================================================
// Function: Set Segment Limit
//
// Synopsis:

	int DPMISetSegmentLimit(
		selector_t sel, 	// selector of segment to set limit of
		uLong limit);		// desired segment limit


// Description:
//
//	This function sets the limit of the segment specified by the
//	sel argument to the value given by the limit argument.
//
// DPMI reference: INT 31h AX=0008h
//
// Version 1.0 Error returns:
//
//	8021h	invalid value
//	8022h	invalid selecotr
//	8023h	invalid linear address

//======================================================================
// Function: Get Segment Attributes
//
// Synopsis:

	int DPMIGetSegmentAttributes(
		selector_t sel, 	// selector of segment to get attribs
		uChar *arb,		// receives access rights/type byte
		uChar *arb386); 	// receives extended access byte(386+)


// Description:
//
//	This function gets the attributes of the segment specified by the
//	sel argument. The location pointed to by the arb argument receives
//	the 6th byte of the descriptor, and the location pointed to by
//	the arb386 argument returns the 8th byte of the descriptor.  This
//	function is implemented with the LAR instruction.
//
// DPMI reference: Not a true DPMI function, but included for completeness.
//

//======================================================================
// Function: Set Segment Attributes
//
// Synopsis:

	int DPMISetSegmentAttributes(
		selector_t sel, 	// selector of segment to set attribs
		uChar arb,		// access rights/type byte
		uChar arb386);		// extended access byte (386+)


// Description:
//
//	This function sets the attributes of the segment specified by
//	the sel argument.  The arb argument is the 6th byte of the
//	descriptor, and the arb386 argument is the 8th byte of the
//	descriptor.  Attempts to set privilege levels more privileged
//	than the client level will fail.
//
// DPMI reference: INT 31h AX=0009h
//
// Version 1.0 Error returns:
//
//	8021h	invalid value
//	8022h	invalid selector
//	8025h	invalid linear address

//======================================================================
// Function: Create Alias Descriptor
//
// Synopsis:

	int DPMICreateAlias(
		selector_t sel, 	// selector to create alias for
		selector_t *alias);	// receives selector of alias segment


// Description:
//
//	This function creates a descriptor with the same base and limit
//	as the descriptor specified by the sel argument.  It writes the
//	selector of the alias descriptor at the address pointed to by
//	the alias argument.  The descriptor that this function creates is
//	of type data.  The DPMI host does not maintain an association
//	between the aliased descriptors.
//
// DPMI reference: INT 31h AX=000Ah
//
// Version 1.0 Error returns:
//
//	8011h	descriptor unavailable
//	8022h	invalid selector

//======================================================================
// Function: Get Raw LDT Descriptor
//
// Synopsis:

	int DPMIGetDescriptor(
		selector_t sel, 			// descriptor to get
		struct descriptor_t *descriptor);	// struct to receive


// Description:
//	This function copies the contents of the LDT descriptor specified
//	by the sel argument to the structure pointed to by the descriptor
//	argument.
//
// DPMI reference: INT 31h AX=000Bh
//
// Version 1.0 Error returns:
//
//	8022h	invalid selector

//======================================================================
// Function: Set Raw LDT Descriptor
//
// Synopsis:

	int DPMISetDescriptor(
		selector_t sel, 			// descriptor to set
		struct descriptor_t *descriptor);	// descriptor contents


// Description:
//
//	This function copies the contents of the structure pointed to
//	by the descriptor argument to the LDT entry specified by the
//	sel argument.  If the present bit is set, the
//
// DPMI reference: INT 31h AX=000Ch
//
// Version 1.0 Error returns:
//
//	8021h	invalid value
//	8022h	invalid selector
//	8025h	invalid linear address

//======================================================================
// Function: Allocate Specific LDT Descriptor
//
// Synopsis:

	int DPMIAllocateSpecificDescriptor(
		selector_t sel);	// selector of descriptor to allocate


// Description:
//	This function allocates a specific LDT descriptor in the range
//	04h to 7Ch. It is intended for use only with DOS extended applications
//	that require compatibility with pre-DPMI environments.
//
// DPMI reference: INT 31h AX=000Dh
//
// Version 1.0 Error returns:
//
//	8011h	descriptor unavailable
//	8022h	invalid selector

//======================================================================
// Function: Allocate DOS Memory Block
//
// Synopsis:

	int DPMIAllocateDOSMemory(
		uShort nParas,		// number of paragraphs to allocate
		uShort *para,		// receives para of alloc'ed block
		selector_t *sel,	// receives selector of alloc'ed block
		uShort *maxParas);	// receives max avail in fail case


// Description:
//
//	This function allocates a block of memory from DOS.  The block so
//	allocated is guaranteed to reside below 1 MB, and thus be addressable
//	by real mode code.  The desired size of the block is specified by
//	the nParas argument, which should be set to the number of paragraphs
//	(16 bytes each) for the block.	The DPMI host provides both a
//	paragraph address (which is written at the address pointed to by the
//	para argument),and a selector (which is written at the address
//	pointed to by the sel argument.
//
//	If the requested size of the block is greater than 64 KB (4096 paras),
//	the DPMI host creates a set of descriptors sufficient to span the
//	allocated region, with consecutive selectors and bases that differ
//	by 64 KB.
//
//	In the case where there is insufficient memory to satisfy the request,
//	the DPMI host writes the maximum number of paragraphs available to
//	the address pointed to by the maxParas argument.
//
//
// DPMI reference: INT 31h AX=0100h
//
// Error returns (valid for version 0.9)
//
//	0007h	memory control blocks damaged
//	0008h	insufficient memory


//======================================================================
// Function: Free DOS Memory Block
//
// Synopsis:

	int DPMIFreeDOSMemory(
		selector_t sel);	// selector of block to free

// Description:
//
//	This function frees a DOS memory block allocated by the function
//	DPMIAllocateDOSMemory.	The argument is the selector of the
//	block to be freed. If the DOS block is larger than 64 KB, all of
//	the descriptors that were allocated for the block are freed.d
//
// DPMI reference: INT 31h AX=0101h
//
// Error returns (valid for version 0.9):
//
//	0007h	memory control blocks damaged
//	0009h	incorrect memory segment specified

//======================================================================
// Function: Resize DOS Memory Block
//
// Synopsis:

	int DPMIResizeDOSMemory(
		selector_t sel, 	// selector of block to resize
		uShort nParas,		// desired size of block in paras
		uShort *maxParas);	// receives max paras available


// Description:
//
//	This function changes the size of a block that was allocated with
//	the function DPMIAllocateDOSMemory.  The nParas argument specifies
//	the desired new size of the block, in paragraphs.  The sel argument
//	is the selector of the block to be resized.
//
//	In the case where there is insufficient memory to satisfy the request,
//	the DPMI host writes the maximum number of paragraphs available to
//	the address pointed to by the maxParas argument.
//
// DPMI reference: INT 31h AX=102h
//
// Error returns (valid for version 0.9):
//
//	0007h	memory control blocks damaged
//	0008h	insufficient memory
//	0009h	incorrect memory segment

//======================================================================
// Function: Get Real Mode Interrupt Vector
//
// Synopsis:

	void DPMIGetRealInterruptVector(
		uChar vector,			// vector number to get
		void (far* *realIsr)());	// receives real vector


// Description:
//
//	This function retrieves the real mode paragraph:offset address of
//	the real mode interrupt handler specified by the vector argument.
//	The handler address is written to the address pointed to by the
//	realIsr argument.
//
//
// DPMI reference: INT 31h AX=0200h
//

//======================================================================
// Function: Set Real Mode Interrupt Vector
//
// Synopsis:

	void DPMISetRealInterruptVector(
		uChar vector,			// vector number to set
		void (far *realIsr)()); 	// new real vector


// Description:
//
//	This function sets the real mode interrupt vector specified by the
//	vector argument to the value in the realIsr argument.  The handler
//	address in realIsr must be a real mode paragraph:offset address.
//
//	Note: Do not declare the handler as _interrupt. Doing so forces the
//	DS register to be loaded upon entry to the handler, but the result
//	will be the protected mode selector, not the real mode paragraph.
//	Thus, references to the default data segment from the real mode
//	handler will fail unless other measures are taken to load DS
//	correctly.
//
// DPMI reference: INT 31h AX=0201h
//

//======================================================================
// Function: Get Processor Exception Vector
//
// Synopsis:

	int DPMIGetExceptionVector(
		uChar exception,		// exception number to get
		void (far* *excHandler)());	// receives handler address


// Description:
//
//	This function retrieves the address of the exception handler
//	specified by the exception argument (range 0-1Fh).  The handler
//	address is written to the address pointed to by the
//	excHandler argument.
//
// DPMI reference: INT 31h AX=0202h
//
// Version 1.0 Error returns:
//
//	8021h	invalid value

//======================================================================
// Function: Set Processor Exception Vector
//
// Synopsis:

	int DPMISetExceptionVector(
		uChar exception,		// exception number to set
		void (far *excHandler)());	// new handler address


// Description:
//
//	This function sets the exception vector specified by the
//	exception argument to the value in the excHandler argument.
//
//	The exception handler is defined as follows:
//
//		void _saveregs _far excHandler(struct excFrame);
//
//	The exception handler may modify the fields of the excFrame structure.
//	When the handler returns, the DPMI host uses the new values from
//	the structure to restart the faulting client.


// DPMI reference: INT 31h AX=0203h
//
// Version 1.0 Error returns:
//
//	8021h	invalid value
//	8022h	invalid selector

//======================================================================
// Function: Get Protected Mode Interrupt Vector
//
// Synopsis:

	void DPMIGetProtInterruptVector(
		uChar vector,			// interrupt vector to get
		void (_interrupt **protIsr)()); // receives interrupt vector


// Description:
//
//	This function retrieves the protected mode interrupt vector
//	specified by the vector argument.  The selector:offset address of
//	the current interrupt handler is written to the address pointed to
//	by the protIsr argument.
//
// DPMI reference: INT 31h AX=0204h
//

//======================================================================
// Function: Set Protected Mode Interrupt Vector
//
// Synopsis:

	int DPMISetProtInterruptVector(
		uChar vector,			// interrupt vector to set
		void (_interrupt *protIsr)());	// new handler address


// Description:
//
//	This function sets the address of the protected mode interrupt
//	handler for the vector specified by the vector arugment.  The
//	protIsr argument is the selector:offset of the desired new
//	handler.
//
//	Note that for hardware interrupts, the handler is invoked on the
//	DPMI host's stack, and DS != SS.  This makes usage of near pointers
//	unreliable and is not recommended.
//
// DPMI reference: INT 31h AX=0205h
//
// Version 1.0 Error returns:
//
//	8022h	invalid selector

//======================================================================
// Function: Issue Real Mode Interrupt
//
// Synopsis:

	int DPMIIssueRealInterrupt(
		uChar vector,			// interrupt to issue
		uShort nArgBytes,		// number of bytes of args
		struct dpmiRegs_t *regs);	// real mode register state


// Description:
//
//	This function switches to real mode and issues the interrupt
//	specified by the vector argument.  Prior to issuing the interrupt,
//	the DPMI host loads the processor registers with the contents of
//	the structure pointed to by the regs argument.	When the interrupt
//	handler returns, the DPMI host updates the register structure to
//	reflect changes caused by the interrupt handler.
//
//	The CS:IP field of the real call structure is ignored, because the
//	execution address is determined by the real mode interrupt vector.
//
// DPMI reference: INT 31h AX=0300h
//
// Version 1.0 Error returns:
//
//	8012h	linear memory unavailable
//	8013h	physical memory unavailable
//	8014h	backing store unavailable
//	8021h	invalid value

//======================================================================
// Function: Call Real Mode Procedure with Far Return
//
// Synopsis:

	int DPMICallRealProcedure(
		uShort nArgBytes,		// number of bytes of args
		struct dpmiRegs_t *regs,	// real mode register state
		...);				// function arguments

// Description:
//
//	This function causes the DPMI host to switch to real mode, push
//	zero or more argument bytes on the stack, and call the far function
//	indicated by the CS:IP fields of the real call structure pointed
//	to by the regs argument.  The number of argument bytes to push is
//	given by the nArgBytes argument, and the function arguments should
//	follow the pointer to the real call structure in the arugment list.
//	The real function must return on the same stack on which it was
//	called.
//
//	The DPMI host reloads the register structure with the register
//	current register state when the far function returns.
//
// DPMI reference: INT 31h AX=0301h
//
// Version 1.0 Error returns:
//
//	8012h	linear memory unavailable
//	8013h	physical memory unavailable
//	8014h	backing store unavailable
//	8021h	invalid value

//======================================================================
// Function: Call Real Mode Procedure with IRET
//
// Synopsis:

	int DPMICallRealInterruptProcedure(
		uShort nArgBytes,		// number of bytes of args
		struct dpmiRegs_t *regs,	// real mode register state
		...);				// function arguments.


// Description:
//
//	This function is identical to DPMICallRealProcedure, except that
//	it is used to call a real function that returns with an IRET
//	instead of a RETF.
//
// DPMI reference: INT 31h AX=0302h
//
// Version 1.0 Error returns:
//
//	8012h	linear memory unavailable
//	8013h	physical memory unavailable
//	8014h	backing store unavailable
//	8021h	invalid value

//======================================================================
// Function: Allocate Real Mode Callback
//
// Synopsis:

	int DPMIAllocateRealCallBack(
		struct dpmiRegs_t *regs,	// address of static reg state
		void (far *handler)(),		// prot mode callback handler
		void (far* *cbAddr)()); 	// receives real callback addr

// Description:
//
//	This function allocates a real mode callback from the DPMI host.
//	A real mode callback is a real mode address (paragraph:offset) that
//	a real mode caller uses to invoke a protected mode callback
//	handler.  This provides a mechanism for calling protected mode
//	from real mode.
//
//	The cbAddr argument points to the location to receive the real mode
//	callback address.  When called, the DPMI host passes control to
//	the protected mode address specified by the handler argument.
//
//	The protected mode handler  is passed (in ES:DI) a pointer to the
//	real mode call structure whose address is passed  to this function
//	in the regs argument.  Therefore, this structure should be statically
//	allocated.  The DPMI host is responsible for loading the structure
//	with the register state at the time of the callback prior to passing
//	it to the protected mode callback handler. The handler is also
//	passed (in DS:SI) the protected mode address of the real mode stack.
//
//	The DPMI host uses the register state in the call structure
//	to restart the real mode caller.  It is the responsibility of the
//	protected mode handler to locate the real mode return address on
//	the real mode stack, and store it in the CS:IP fields of the call
//	structure in order to effect a return from the callback.
//
// DPMI reference: INT 31h AX=0303h
//
// Version 1.0 Error returns:
//
//	8015h	callback unavailable

//======================================================================
// Function: Free Real Mode Callback
//
// Synopsis:

	int DPMIFreeRealCallBack(
		void (far *cbAddr)());		// callback to free


// Description:
//
//	This function frees a real mode callback allocated by
//	DPMIAllocateRealCallBack.  The cbAddr is the callback
//	address to be freed.
//
// DPMI reference: INT 31h AX=0303h
//
// Version 1.0 Error returns:
//
//	8024h	invalid callback address

//======================================================================
// Function: Get State Save/Restore Procedure Addresses
//
// Synopsis:

	void DPMIGetStateSaveRestoreProcs(
		uShort *stateSize,		// size of state info
		void (far* *realProc)(),	// receives real save/rst proc
		void (far* *protProc)());	// receives prot save/rst proc

// Description:
//
//	This function retrieves information from the DPMI host that
//	is required for saving and restoring the client state when
//	using the raw mode switch function.
//
//	The DPMI specification requires that clients save their state
//	prior to making a raw mode switch, and subsequently restore it.
//	This function provides the size of the state information, and
//	the both the protected mode and real mode addresses of functions
//	to call to save and restore the client state.
//
//	The size of the state information, in bytes, is stored at the
//	address pointed to by the stateSize argument.  The address of the
//	far procedure to call from real mode to save or restore the client
//	state is stored at the address pointed to by the realProc argument.
//	The address of the far procedure to call from protected mode to
//	save and restore the client state is stored at the address pointed
//	to by the protProc argument.
//
//	The state save/restore procedures are called with AL=0 to save the
//	state, and AL=1 to restore the state.  In both cases, ES:DI points
//	to the state information buffer.
//
//
// DPMI reference: INT 31h AX=0305h

//======================================================================
// Function: Save Or Restore Client State for Raw Switch
//
// Synopsis:

	void DPMISaveOrRestoreState(
		int saveRestore,		// 0=save 1=restore
		uChar *stateBuffer,		// pointer to state buffer
		void (far *procAddr)());	// procedure to call

// Description:
//
//	This function invokes the save/restore procedure whose address
//	is specified by the procAddr argument.	The stateBuffer argument
//	points to the buffer to supply or receive the client state. Its
//	size is determined by calling DPMIGetStateSaveRestoreProcs. The
//	saveRestore argument is zero to perform state save, or one to
//	perform a state restore.


//======================================================================
// Function: Get Raw Switch Procedure Addresses
//
// Synopsis:

	void DPMIGetRawSwitchProc(
		void (far* *realToProt)(),	// real to prot switch addr
		void (far* *protToReal)());	// prot to real switch addr

// Description:
//
//	This function retrieves information from the DPMI host that
//	is required for raw mode switching.  The address (paragraph:offset)
//	of the real to protected mode service is stored at the address
//	pointed to by the realToProt argument.	The address (selector:offset)
//	of the protected to real mode service is stored at the address
//	pointed to by the protToReal argument.
//
// DPMI reference: INT 31h AX=0306h
//

//======================================================================
// Function: Do Raw Mode Switch
//
// Synopsis:

	void DPMIDoRawSwitch(
		void (far *switchAddr)(),	// switch service address
		struct rawModeRegs_t *rawRegs); // new register values

// Description:
//
//	This function invokes the raw switch service.  The switchAddr
//	argument is obtained from DPMIGetRawSwitchProc, and specifies
//	the address of the switch service to invoke.  When the function
//	returns, the processor will be in the alternate mode.
//
//	The rawRegs argument points to the structure containing the register
//	contents to be put in effect after the mode switch is effected.
//	The values in the structure MUST be aliases for the currently active
//	segment registers.  In other words, when switching from protected
//	to real mode, each segment register value in the structure must
//	be the paragraph equivalent of the current protected mode descriptor
//	value.	Likewise, when switching from real to protected mode, each
//	segment register value in the structure must be the selector that
//	maps the current paragraph in each segment register. These
//	requirements imply that this routine must execute only in the low
//	1 MB of the address space, and that the stack must also be in the
//	low 1 MB.
//
// DPMI reference: invoking the raw mode switch services


//======================================================================
// Function: Get DPMI Host Version Information
//
// Synopsis:
//
	void DPMIGetVersion(
		uChar *major,		// receives major version number
		uChar *minor,		// receives minor version number
		uChar *processor,	// receives processor code
		uShort *flags,		// receives flags
		uChar *masterPIC,	// receives virtual master PIC base
		uChar *slavePIC);	// receives virtual slave PIC base

// Description:
//
//	This function retrieves version information from the DPMI host.
//	For version 0.9, the major version is zero and the minor version
//	is 90 (5Ah).  The processor codes are as follows:
//
//		2 => 80286, 3 => 80386, 4 => 80486 5-FFh => future
//
//	The bits of the flags word have the following meanings:
//
//		Bit	Meaning
//		 0	0 = 16-bit host,
//			1 = 32-bit host
//		 1	0 = DOS runs in virtual 86 mode,
//			1 = DOS runs in real
//		 2	0 = no virtual memory support
//			1 = virtual memory supported
//
// DPMI reference: INT 31h AX=0400h

//======================================================================
// Function: Get Free Memory Information
//
// Synopsis:

	void DPMIGetFreeMemory(
		struct freeMem_t *freeMem); // receives free mem info


// Description:
//
//	This function retrieves free memory information from the DPMI
//	host.  The freeMem argument is a pointer to the structure to
//	receive the free memory information. Only the first field
//	(largestFree) of the free memory structure is guaranteed to be
//	supported.  The other values are set to 0xffffffff if the
//	item is unavailable.
//
// DPMI reference: INT 31h AX=0500h

//======================================================================
// Function: Allocate Memory Block
//
// Synopsis:

	int DPMIAllocateMemory(
		uLong nBytes,		// size of block to allocate
		uLong *base,		// receives linear base of block
		uLong *handle); 	// receives block handle

// Description:
//
//	This function allocates a memory block.  The nBytes argument
//	specifies the desired size of the block to allocate, in bytes.
//	The linear base address of the block that is allocated is
//	written to the address pointed to by the base argument.  The
//	block handle is written to the address pointed to by the handle
//	argument.  The handle is used to free or resize the block.
//
// DPMI reference: INT 31h AX=0501h
//
// Version 1.0 Error returns:
//
//	8012h	linear memory unavailable
//	8013h	physicl memory unavailable
//	8014h	backing store unavailable
//	8016h	handle unavailable
//	8021h	invalid value

//======================================================================
// Function: Free Memory Block
//
// Synopsis:

	int DPMIFreeMemory(
		uLong handle);		// handle of block to free


// Description:
//
//	This function frees a memory block allocated by DPMIAllocateMemory.
//
// DPMI reference: INT 31h AX=0502h
//
// Version 1.0 Error returns:
//
//	8023h	invalid handle

//======================================================================
// Function: Resize Memory Block
//
// Synopsis:

	int DPMIResizeMemory(
		uLong *handle,		//address of handle of block to resize
		uLong nBytes,		// new desired size in bytes
		uLong *base);		// receives new linear base of block

// Description:
//
//	This function resizes a memory block allocated by DPMIAllocateMemory.
//	The handle argument points to the handle of the block to resize.
//	The nBytes argument is the desired new size of the block, in bytes.
//	The base argument points to the address to receive the new address
//	of the block.  Note that both the block handle and the linear base
//	of the block may be changed by this call.
//
// DPMI reference: INT 31h AX=0503h
//
// Version 1.0 Error returns:
//
//	8012h	linear memory unavailable
//	8013h	physical memory unavailable
//	8014h	backing store unavailable
//	8016h	handle unavailable
//	8021h	invalid value

//======================================================================
// Function: Lock Linear Region of Memory
//
// Synopsis:

	int DPMILockRegion(
		uLong base,		// linear address of region to lock
		uLong nBytes);		// size of region to lock

// Description:
//
//	This function is used to prevent pages from being swapped to disk
//	by a DPMI host that supports virtual memory.  The base argument is
//	the linear address of the start of the region to be locked, and the
//	nBytes argument is the size of the region to lock.  The host maintains
//	a lock count for each page.  If the DPMI host does not support
//	virtual memory, the function has no effect.
//
// DPMI reference: INT 31h AX=0600h
//
// Version 1.0 Error returns:
//
//	8013h	physical memory unavailable
//	8017h	lock count exceeded
//	8025h	invalid linear address

//======================================================================
// Function: Unlock Linear Region of Memory
//
// Synopsis:

	int DPMIUnlockRegion(
		uLong base,		// linear address of region to unlock
		uLong nBytes);		// size of region to unlock

// Description:
//
//	This function decrements the lock count for pages in the specified
//	region.  The base argument is the linear address of the start of the
//	region, and the nBytes argument is the size of the region in bytes.
//	Pages are not unlocked until the lock count is zero.
//
// DPMI reference: INT 31h AX=0601h
//
// Version 1.0 Error returns:
//
//	8002h	invalid state
//	8025h	invalid linear address

//======================================================================
// Function: Mark Real Mode Region as Pageable
//
// Synopsis:

	int DPMIMarkRealRegionPageable(
		uLong base,		// linear address of region to mark
		uLong nBytes);		// size in bytes of region to mark

// Description:
//
//	This function allows memory in the low megabyte of the linear
//	address space to be swapped to disk by a DPMI host that supports
//	virtual memory.  The base argument is the linear address of the
//	start of the region to be made pageable, and the nBytes argument
//	is the size of the region in bytes.
//
// DPMI reference: INT 31h AX=0602h
//
// Version 1.0 Error returns:
//
//	8002h	invalid state
//	8025h	invalid linear address

//======================================================================
// Function: Relock Real Mode Region
//
// Synopsis:

	int DPMIRelockRealRegion(
		uLong base,		// linear address of region to relock
		uLong nBytes);		// size in bytes of region to relock

// Description:
//
//	This function relocks a memory region in the low 1 MB that was marked
//	as pageable by DPMIMarkRealRegionPageable.  The base argument is the
//	linear address of the start of the region to be relocked, and the
//	nBytes argument is the size of the region in bytes.
//
// DPMI reference: INT 31h AX=0603h
//
// Version 1.0 Error returns:
//
//	8002h	invalid state
//	8013h	physical meomory unavailable
//	8025h	invalid linear address

//======================================================================
// Function: Get Size of Processor Page
//
// Synopsis:

	int DPMIGetPageSize(
		uLong *pageSize);


// Description:
//
//	This function is used to determine the processor's page size.
//	The pageSize argument points to the location to receive the
//	page size, in bytes.  16-bit hosts will fail this call.
//
// DPMI reference: INT 31h AX=0604h
//
// Version 1.0 Error returns:
//
//	8001h	unsupported function

//======================================================================
// Function: Nominate Pages as Demand Paging Candidates
//
// Synopsis:

	int DPMINominatePages(
		uLong base,		// base of region to nominate
		uLong nBytes);		// size in bytes of region

// Description:
//
//	This function is used to indicate to the DPMI host that a range
//	of memory should be the most likely to be swapped to disk.  The
//	base argument is the linear address of the start of the region
//	to be nominated, and the nBytes argument is the size of the region,
//	in bytes.  The call is advisory only.
//
// DPMI reference: INT 31h AX=0702h
//
// Version 1.0 Error returns:
//
//	8025h	invalid linear address range

//======================================================================
// Function: Discard Contents of Pages
//
// Synopsis:

	int DPMIDiscardPageContents(
		uLong base,		// base of region to discard
		uLong nBytes);		// size of region in bytes

// Description:
//
//	This function advises the DPMI host to discard the contents of
//	the specified region to avoid unnecessarily saving them on disk.  The
//	base argument is the linear address of the start of the region
//	to be discarded, and the nBytes argument is the size of the region,
//	in bytes.  The call is advisory only.
//
// DPMI reference: INT 31h AX=0703h
//
// Version 1.0 Error returns:
//
//	8025h	invalid linear address

//======================================================================
// Function: Get Linear Address for Physical Region
//
// Synopsis:

	int DPMIMapPhysicalRegion(
		uLong physAddr, 	// physical address to map
		uLong nBytes,		// size of region to map
		uLong *linear); 	// receives linear address of region

// Description:
//
//	This function allows a DPMI client to obtain a linear address that
//	maps to any physical address above 1 MB.  The physAddr argument
//	specifies the physical address of the region to map. The nBytes
//	argument is the size of the region to map, in bytes. The linear
//	argument points to the address to receive the linear address that
//	the DPMI sets up to map the physical region.
//
// DPMI reference: INT 31h AX=0800h
//
// Version 1.0 Error returns:
//
//	8003h	system integrity
//	8021h	invalid value

//======================================================================
// Function: Test Virtual Interrupt State and Disable
//
// Synopsis:

	int DPMITestDisableInts(void);


// Description:
//
//	This function returns the current virtual interrupt enable state,
//	and disables virtual interrupts.  The return value is zero if
//	interrupts were previously disabled, and one if they were enabled.
//
// DPMI reference: INT 31h AX=0900h

//======================================================================
// Function: Test Virtual Interrupt State and Enable
//
// Synopsis:

	int DPMITestEnableInts(void);

// Description:
//
//	This function returns the current virtual interrupt enable state,
//	and enables virtual interrupts.  The return value is zero if
//	interrupts were previously disabled, and one if they were enabled.
//
// DPMI reference: INT 31h AX=0901h


//======================================================================
// Function: Test Virtual Interrupt State
//
// Synopsis:

	int DPMITestInts(void);

// Description:
//
//	This function returns the current virtual interrupt enable state.
//	The return value is zero if interrupts are disabled, and one if
//	they are enabled.
//
//
// DPMI reference: INT 31h AX=0902h

//======================================================================
// Function: Get Vendor Extensions Entry Point
//
// Synopsis:

	int DPMIGetVendorEntryPoint(
		char *extensionID,
		void (far* *extAPIEntry)());

// Description:
//
//	This function retrieves an address that can be used to access
//	vendor specific DPMI extensions.  The extensionID argument points
//	to a null terminated string that identifies the desired set of
//	extensions.  The extAPIEntry argument points to the address where
//	a far pointer to the vendor entry point is to be stored.  The function
//	returns non-zero if the requested vendor extensions are not found.
//
// DPMI reference: INT 31h AX=0A00h and INT 2Fh AX=168Ah
//
// Version 1.0 Error returns:
//
//	8001h	unsupported function

//======================================================================
// Function: Set Debug Watchpoint
//
// Synopsis:

	int DPMISetWatchpoint(
		uLong linear,		// linear address of watchpoint
		enum watchSize size,	// watchpoint size
		enum watchType type,	// watchpoint type
		uShort *watchHandle);	// receives watchpoint handle

// Description:
//
//	This function sets a debug watchpoint using the processor's debug
//	registers.  The linear argument specifies the linear address of the
//	watchpoint.  Arguments watchSize and watchType specify the size
//	and type of the watchpoint.  The watchHandle argument points to the
//	location to receive the watchpoint handle allocated by the DPMI
//	host.  Tripping a watchpoint invokes the exception 1 handler.
//
// DPMI reference: INT 31h AX=0B00h
//
// Version 1.0 Error returns:
//
//	8016h	too many breakpoints
//	8021h	invalid value
//	8025h	invalid linear address

//======================================================================
// Function: Clear Debug Watchpoint
//
// Synopsis:

	int DPMIClearWatchpoint(
		uShort watchHandle);	// handle of watchpoint to free

// Description:
//
//	This function releases the watchpoint handle allocated by
//	DPMISetWatchpoint, and clears the associated debug register.
//	The watchHandle argument is the handle of the watchpoint to free.
//
// DPMI reference: INT 31h AX=0B01h
//
// Version 1.0 Error returns:
//
//	8023h	invalid handle

//======================================================================
// Function: Get Debug Watchpoint State
//
// Synopsis:

	int DPMIGetWatchpointState(
		uShort watchHandle,	//handle of watchpoint to get state of
		uChar *tripped);	// receives state

// Description:
//
//	This function retrieves the state of a watchpoint set by
//	DPMISetWatchpoint.  The watchHandle argument is the handle of
//	watchpoint whose state is to be retrieved.  The tripped argument
//	receives a zero if the watchpoint has not been encountered,
//	and receives a one if the watchpoint has been encountered.
//
// DPMI reference: INT 31h AX=0B02h
//
// Version 1.0 Error returns:
//
//	8023h	invalid handle

//======================================================================
// Function: Reset Debug Watchpoint
//
// Synopsis:

	int DPMIResetWatchpoint(
		uShort watchHandle);	// handle of watchpoint to reset

// Description:
//
//	This function resets the state of a watchpoint allocated by
//	DPMISetWatchpoint.  This sets the watchpoint state to
//	"not encountered".  The watchHandle argument specifies the watchpoint
//	in question.
//
// DPMI reference: INT 31h AX=0B03h
//
// Version 1.0 Error returns:
//
//	8023h	invalid handle




//======================================================================
// Function: Allocate memory and selector
//
// Synopsis:

	void far *DPMImalloc(uShort size, struct DPMImemory_t *mem);

// Description:
//
//	This is a higher level call that allocates a block of memory
//	whose size is given by the size argument (size == 0 is taken
//	to mean 64 KB), and allocates a descriptor to map it.  The
//	caller provides a pointer to a DPMImemory_t struct that records
//	the memory handle and selector.  The function returns a far
//	pointer to offset zero of the allocated block.


//======================================================================
// Function: Free memory and selector
//
// Synopsis:

	void DPMIfree(struct DPMImemory_t *mem);

// Description:
//
//	This function frees the memory block and selector allocated
//	by DPMImalloc.

//======================================================================
// Function: Resize memory and selector
//
// Synopsis:

	boolean DPMIresize(uShort newSize, struct DPMImemory_t *mem);

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
//	Warning: callers of this function must not propagate copies of
//	the DPMImemory_t structure, as the resize operation may modify
//	the block handle.

//======================================================================
// Function: getCS - return current code selector
//
	uShort getCS(void);

//======================================================================
// Function: getDS - return current data selector
//
	uShort getDS(void);

#ifdef __cplusplus
}
#endif

#endif
