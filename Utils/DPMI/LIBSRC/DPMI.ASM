
;;  Copyright (c) 1992, Qualitas, Inc.	All Rights Reserved
;;
;;  dpmi.asm - Source code for Qualitas DPMI library
;;

	include dpmi.inc

	.286p
	.model SMALL, C

	.data

;; data required by fix-up routines

codePara	dw	?
dataPara	dw	?
fixupSel	dw	?
previous21	dd	?

	.code

	extrn	 malloc:near

;;======================================================================
;; Function: Release Time Slice
;;
;; Synopsis:
;;
;;	void DPMIReleaseTimeSlice(void);
;;
;; Description:
;;
;;	DPMI clients call this function to indicate an idle state to the
;;	DPMI host.  This enables multitasking DPMI hosts to schedule other
;;	clients. Installing this call inside idle loops can result in
;;	significant improvement of system throughput.
;;
;; DPMI reference: INT 2Fh AX=1680h

DPMIReleaseTimeSlice PROC C
	mov	ax, 1680h
	int	2fh
	ret
DPMIReleaseTimeSlice ENDP

;;======================================================================
;; Function: Get CPU Mode
;;
;; Synopsis:
;;
;;	int DPMIGetCPUMode(void);
;;
;; Description:
;;
;;	This function may be used by mode sensitive applications to determine
;;	the current processor operating mode. Clients must verify the
;;	presence of a DPMI host prior to making this call. The function
;;	returns zero if executing in protected mode, and returns non-zero
;;	if running in real or virtual 86 mode.
;;
;; DPMI reference: INT 2Fh AX=1686h

DPMIGetCPUMode PROC C
	mov	ax, 1686h
	int	2Fh
	ret
DPMIGetCPUMode ENDP

;;======================================================================
;; Function: Obtain Mode Switch Entry Point
;;
;; Synopsis:
;;
;;	int DPMIObtainSwitchEntryPoint(
;;		uShort *flags,			;; 32-bitness flag
;;		uChar *processor,		;; processor type
;;		uChar *majorVersion,		;; major version #
;;		uChar *minorVersion,		;; minor version #
;;		uShort *nPrivateDataParas,	;; size of host data
;;		void (far* *entryAddress)());	;; switch entry point
;;
;; Description:
;;
;;	This call determines if a DPMI host is present, and if so, returns
;;	necessary information on how to invoke it.  The function returns
;;	zero if a DPMI host was found; otherwise it returns non-zero.
;;
;;	All arguments are pointers to locations to store return values.
;;	The flags argument is non-zero if the DPMI host supports 32-bit
;;	applications.  The processor argument is written as 2 (80286),
;;	3 (80386), 4 (80486), or 5 (future). The version arguments indicate
;;	the version numbers of the DPMI host (For DPMI 0.9, major version is
;;	zero, and minor version is 90).  The nPrivateDataParas argument
;;	receives the number of paragraphs of memory that the host requires
;;	for each client.  If this is non-zero, the client must provide
;;	this much memory prior to calling the mode switch entry point, and
;;	the memory must be paragraph aligned.
;;
;;	The value written at the entryAddress argument is the far address
;;	to call to make the initial switch into protected mode. See also,
;;	DPMIEnterProtectedMode.
;;
;; DPMI reference: INT 2Fh AX=1687h

DPMIObtainSwitchEntryPoint PROC C USES SI DI,	\
	flags:PTR,		\
	processor:PTR,		\
	majorVersion:PTR,	\
	minorVersion:PTR,	\
	nPrivateDataParas:PTR,	\
	entryAddress:PTR

	mov	ax, 1687h		; test for presence of DPMI host
	int	2Fh

	or	ax, ax			; ax == 0 means host responded
	jnz	noHost

	mov	ax, bx			; save flags in ax

	ldptr	bx, flags
	mov	[bx], ax
	ldptr	bx, processor
	mov	[bx], cl
	ldptr	bx, majorVersion
	mov	[bx], dh
	ldptr	bx, minorVersion
	mov	[bx], dl
	ldptr	bx, nPrivateDataParas
	mov	[bx], si
	ldptr	bx, entryAddress
	mov	[bx], di
	mov	[bx+2], es

	xor	ax, ax
noHost:
	ret
DPMIObtainSwitchEntryPoint ENDP

;;======================================================================
;; Function: Enter Protected Mode
;;
;; Synopsis:
;;
;;	int DPMIEnterProtectedMode(
;;		void (far *switchEntryPoint)(), ;; mode switch entry point
;;		uShort bitness, 		;; 0/16 or 1/32
;;		uShort nPrivateDataParas,	;; number of paras required
;;		uShort NearFar);		;; Near (0) or far (1)
;;						;; allocate of HPDA
;;
;;
;; Description:
;;
;;	This function is used to make the initial switch into protected
;;	mode.  The switchEntryPoint argument is the value returned in the
;;	entryAddress argument of ObtainSwitchEntryPoint.  The bitness argument
;;	is 0 or 16 to indicate that the calling client is 16-bit, and is
;;	1 or 32 to indicate that the calling client is 32-bit.	The
;;	nPrivateDataParas argument is obtained from the function
;;	DPMIObtainSwitchEntryPoint.
;;
;;	If the call returns zero, the client is then running in protected
;;	mode.  The segment registers CS, DS, and SS contain selectors that
;;	address the same linear memory as they did in real mode at the
;;	time of the call.  The selector in ES addresses the programs PSP,
;;	and the corresponding descriptor has a limit of 0xFF.  If running
;;	on a 32-bit processor, FS and GS are zero.
;;
;; DPMI reference: calling the mode switch entry point
;;
;; Version 1.0 Error returns:
;;
;;	8011h	descriptor unavailable
;;	8012h	insufficient memory
;;	8021h	32-bit clients not supported

DPMIEnterProtectedMode PROC C \
	switchEntryPoint:FAR PTR,	\
	bitness:uShort, 		\
	nPrivateDataParas:uShort,	\
	NearFar:uShort

	cmp	NearFar,1		; Izit Near (0) or Far (1)?
	je	short enter_far 	; Jump if Far

; Ensure the amount requested fits in a near ptr (64KB)

	mov	bx, nPrivateDataParas	; Get size of HPDA in paras

	cmp	bx,0FFFh		; Izit smaller than 64KB?
	jae	short enter_far 	; Jump if not

; If we allocate from the near heap, we'll get back a (char *) pointer
; on a byte (probably word) boundary.  We must add in another para to
; account for this so as to ensure we can round up the (char *) pointer
; to a para boundary.

	inc	bx			; Add to account for rounding

	shl	bx,4-0			; Convert from paras to bytes

	push	bx			; Pass as argument
	call	malloc			; Request allocation from near heap
					; Return AX = (char *)
	add	sp,2			; Strip from the stack

	and	ax,ax			; Did it work?
	jz	short enter_far 	; Jump if not

	add	ax,16-1 		; Round up to para boundary
	shr	ax,4-0			; Convert from bytes to paras
	mov	bx,ds			; Get segment of near heap
	add	ax,bx			; Add to get segment of HPDA

	jmp	short enter_com 	; Join common code

enter_far:
	mov	ah, 48h 		;; get the required memory block
	mov	bx, nPrivateDataParas
	int	21h
	jc	@@fail
enter_com:
	mov	es, ax
	mov	ax, bitness
	cmp	ax, 16
	je	short enter16
	cmp	ax, 0
	je	short enter16
	cmp	ax, 32
	je	short enter32
	cmp	ax, 1
	je	short enter32
	jmp	short @@fail
enter16:
	mov	ax, 0
	jmp	short enterPM
enter32:
	mov	ax, 1
	jmp	short enterPM

enterPM:
	call	switchEntryPoint	;;   switch into protected mode
	jc	@@fail

	call	_fixup			;; re fixup this exe
	call	_installHandlers	;; install default exception handlers
	xor	ax, ax
	jmp	short @@exit
@@fail:
	mov	ax, 1
@@exit:
	ret
DPMIEnterProtectedMode ENDP

;;======================================================================
;; Function: Allocate Descriptors
;;
;; Synopsis:
;;
;;	int DPMIAllocateDescriptors(
;;		uShort howMany, 	;; how many descriptors to allocate
;;		selector_t *baseSel);	;; receives selector of first desc
;;
;; Description:
;;
;;	This function allocates one or more LDT descriptors. The howMany
;;	argument is the number of descriptors to allocate, and the
;;	selector of the first allocated descriptor is written to the
;;	address pointed to by the baseSel argument.  When more than one
;;	descriptor  is allocated, they are consecutive, i.e., the
;;	difference between them is obtained by calling DPMIGetSelectorDelta.
;;
;;	At the time of allocation, each descriptor is of type DATA with
;;	a base and limit of zero.  It is the client's responsibility to
;;	set up the descriptors with meaningful values.
;;
;; DPMI reference: INT 31h AX=0000h
;;
;; Version 1.0 Error returns:
;;
;;	8011h	descriptor unavailable.

DPMIAllocateDescriptors PROC C	\
	howMany:uShort, 	\
	baseSel:PTR

	mov	ax, 0000h
	mov	cx, howMany
	int	31h
	jc	@@fail

	ldptr	bx, baseSel
	mov	[bx], ax
	xor	ax, ax
	jmp	short @@exit
@@fail:
	mov	ax, 1
@@exit:
	ret
DPMIAllocateDescriptors ENDP

;;======================================================================
;; Function: Free Descriptor
;;
;; Synopsis:
;;
;;	int DPMIFreeDescriptor(
;;		selector_t sel);	;; Selector of descriptor to free
;;
;; Description:
;;
;;	This function returns the specified descriptor to the DPMI host.
;;
;; DPMI reference: INT 31h AX=0001h
;;
;; Version 1.0 Error returns:
;;
;;	8022h	invalid selector

DPMIFreeDescriptor PROC C	\
	sel:selector_t

	mov	ax, 0001h
	mov	bx, sel
	int	31h
	jc	@@exit

	xor	ax, ax
@@exit:
	ret
DPMIFreeDescriptor ENDP

;;======================================================================
;; Function: Create Descriptor to Address Real Segment
;;
;; Synopsis:
;;
;;	int DPMIParaToSelector(
;;		uShort para,		;; paragraph to map
;;		selector_t *sel);	;; selector to address paragraph
;;
;; Description:
;;
;;	This function creates a data descriptor whose base corresponds
;;	to the real mode paragraph specified by the para argument.  The
;;	function writes the selector of the created descriptor at the
;;	address pointed to by the sel argument.  The descriptor limit
;;	is 64 KB.
;;
;;	The function is intended to be used only for commonly accessed
;;	regions of the low megabyte, for example, paragraphs 40h, A000h,
;;	and B800h. Descriptors allocated by this function should not be
;;	modified or freed.  Multiple calls to this function with the same
;;	input return the same selector.
;;
;; DPMI reference: INT 31h AX=0002h
;;
;; Version 1.0 Error returns:
;;
;;	8011h	descriptor unavailable

DPMIParaToSelector PROC C	\
	para:uShort,		\
	sel:PTR

	mov	ax, 0002h
	mov	bx, para
	int	31h
	jc	@@exit

	ldptr	bx, sel
	mov	[bx], ax
	xor	ax, ax
@@exit:
	ret
DPMIParaToSelector ENDP

;;======================================================================
;; Function: Get Selector Delta
;;
;; Synopsis:
;;
;;	uShort DPMIGetSelectorDelta(void);
;;
;; Description:
;;
;;	The return value of this function is the difference between
;;	consecutive selectors.
;;
;; DPMI reference: INT 31h AX=0003h

DPMIGetSelectorDelta PROC C
	mov	ax, 0003h
	int	31h
	ret
DPMIGetSelectorDelta ENDP

;;======================================================================
;; Function: Get Segment Base
;;
;; Synopsis:
;;
;;	int DPMIGetSegmentBase(
;;		selector_t sel, 	;; selector of segment to get base of
;;		uLong *base);		;; location to receive base of segment
;;
;; Description:
;;
;;	This function retrieves the base of the segment specified by the
;;	sel argument.  The linear base of the segment is written at the
;;	address pointed to by the base argument.
;;
;; DPMI reference: INT 31h AX=0006h
;;
;; Version 1.0 Error returns:
;;
;;	8022h	invalid selector

DPMIGetSegmentBase PROC C	\
	sel:selector_t, 	\
	base:PTR

	mov	ax, 0006h
	mov	bx, sel
	int	31h
	jc	@@exit

	ldptr	bx, base
	stlong	[bx], cx, dx

	xor	ax, ax
@@exit:
	ret
DPMIGetSegmentBase ENDP

;;======================================================================
;; Function: Set Segment Base
;;
;; Synopsis:
;;
;;	int DPMISetSegmentBase(
;;		selector_t sel, 	;; selector of segment to set base of
;;		uLong base);		;; new value for base
;;
;; Description:
;;
;;	This function sets the base of the segment specified by the sel
;;	argument to the value of the base argument.
;;
;; DPMI reference: INT 31h AX=0007h
;;
;; Version 1.0 Error returns:
;;
;;	8022h	invalid selector
;;	8025h	invalid linear address

DPMISetSegmentBase PROC C	\
	sel:selector_t, 	\
	base:uLong

	mov	ax, 0007h
	mov	bx, sel
	ldlong	cx, dx, base
	int	31h
	jc	@@exit

	xor	ax, ax
@@exit:
	ret
DPMISetSegmentBase ENDP

;;======================================================================
;; Function: Get Segment Limit
;;
;; Synopsis:
;;
;;	int DPMIGetSegmentLimit(
;;		selector_t sel, 	;; selector of segment to get limit of
;;		uLong *limit);		;; location to receive limit
;;
;; Description:
;;
;;	This function retrieves retrieves the limit of the segment
;;	specified by the sel argument, and writes it at the address
;;	pointed to by the limit argument.  The function is implemented
;;	not by a DPMI call, but with the LSL instruction.
;;
;;
;; DPMI reference: Not a true DPMI function, but included for completeness.
;;

DPMIGetSegmentLimit PROC C	\
	sel:selector_t, 	\
	limit:PTR

	mov	ax, 0400h	;; check processor type
	int	31h
	cmp	cl, 2		;; 2 means 286
	je	@@is286
.386p
	movzx	eax, sel
	lsl	eax, eax
	jnz	@@fail
	ldptr	bx, limit
	mov	[bx], eax
	xor	ax, ax
	jmp	short @@exit
.286p
@@is286:
	mov	ax, sel
	lsl	ax, ax		;; get segment limit
	jnz	@@fail		;; zf=0 if cannot access

	ldptr	bx, limit
	stlong	[bx], 0, ax
	xor	ax, ax
	jmp	short @@exit
@@fail:
	mov	ax, 1
@@exit:
	ret
DPMIGetSegmentLimit ENDP

;;======================================================================
;; Function: Set Segment Limit
;;
;; Synopsis:
;;
;;	int DPMISetSegmentLimit(
;;		selector_t sel, 	;; selector of segment to set limit of
;;		uLong limit);		;; desired segment limit
;;
;;
;; Description:
;;
;;	This function sets the limit of the segment specified by the
;;	sel argument to the value given by the limit argument.
;;
;; DPMI reference: INT 31h AX=0008h
;;
;; Version 1.0 Error returns:
;;
;;	8021h	invalid value
;;	8022h	invalid selecotr
;;	8023h	invalid linear address

DPMISetSegmentLimit PROC C	\
	sel:selector_t, 	\
	limit:uLong

	mov	ax, 0008h
	mov	bx, sel
	ldlong	cx, dx, limit
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMISetSegmentLimit ENDP

;;======================================================================
;; Function: Get Segment Attributes
;;
;; Synopsis:
;;
;;	int DPMIGetSegmentAttributes(
;;		selector_t sel, 	;; selector of segment to get attribs
;;		uChar *arb,		;; receives access rights/type byte
;;		uChar *arb386); 	;; receives extended access byte(386+)
;;
;;
;; Description:
;;
;;	This function gets the attributes of the segment specified by the
;;	sel argument. The location pointed to by the arb argument receives
;;	the 6th byte of the descriptor, and the location pointed to by
;;	the arb386 argument returns the 8th byte of the descriptor.  This
;;	function is implemented with the LAR instruction.
;;
;; DPMI reference: Not a true DPMI function, but included for completeness.
;;

DPMIGetSegmentAttributes PROC C \
	sel:selector_t, 	\
	arb:PTR,		\
	arb386:PTR

	mov	ax, 0400h		;; check processor type
	int	31h
	cmp	cl, 2			;; 2 means 286
	je	@@is286
.386p
	movzx	eax, sel
	lar	eax, eax
	jnz	@@fail			;; zf=0 means cannot access descriptor

	shr	eax, 8
	ldptr	bx, arb386
	mov	[bx], ah
	jmp	short getArb
.286p
@@is286:
	ldptr	bx, arb386
	mov	byte ptr [bx], 0

getArb:
	lar	ax, sel
	jnz	@@fail
	ldptr	bx, arb
	mov	[bx], ah

	xor	ax, ax
	jmp	short @@exit
@@fail:
	mov	ax, 1
@@exit:
	ret
DPMIGetSegmentAttributes ENDP

;;======================================================================
;; Function: Set Segment Attributes
;;
;; Synopsis:
;;
;;	int DPMISetSegmentAttributes(
;;		selector_t sel, 	;; selector of segment to set attribs
;;		uChar arb,		;; access rights/type byte
;;		uChar arb386);		;; extended access byte (386+)
;;
;;
;; Description:
;;
;;	This function sets the attributes of the segment specified by
;;	the sel argument.  The arb argument is the 6th byte of the
;;	descriptor, and the arb386 argument is the 8th byte of the
;;	descriptor.  Attempts to set privilege levels more privileged
;;	than the client level will fail.
;;
;; DPMI reference: INT 31h AX=0009h
;;
;; Version 1.0 Error returns:
;;
;;	8021h	invalid value
;;	8022h	invalid selector
;;	8025h	invalid linear address

DPMISetSegmentAttributes PROC C \
	sel:selector_t, 	\
	arb:uChar,		\
	arb386:uChar

	mov	ax, 0009h
	mov	bx, sel
	mov	cl, arb
	mov	ch, arb386
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMISetSegmentAttributes ENDP

;;======================================================================
;; Function: Create Alias Descriptor
;;
;; Synopsis:
;;
;;	int DPMICreateAlias(
;;		selector_t sel, 	;; selector to create alias for
;;		selector_t *alias);	;; receives selector of alias segment
;;
;;
;; Description:
;;
;;	This function creates a descriptor with the same base and limit
;;	as the descriptor specified by the sel argument.  It writes the
;;	selector of the alias descriptor at the address pointed to by
;;	the alias argument.  The descriptor that this function creates is
;;	of type data.  The DPMI host does not maintain an association
;;	between the aliased descriptors.
;;
;; DPMI reference: INT 31h AX=000Ah
;;
;; Version 1.0 Error returns:
;;
;;	8011h	descriptor unavailable
;;	8022h	invalid selector

DPMICreateAlias PROC C	\
	sel:selector_t, \
	aliasSel:PTR

	mov	ax, 000Ah
	mov	bx, sel
	int	31h
	jc	@@exit

	ldptr	bx, aliasSel
	mov	[bx], ax
	xor	ax, ax
@@exit:
	ret
DPMICreateAlias ENDP

;;======================================================================
;; Function: Get Raw LDT Descriptor
;;
;; Synopsis:
;;
;;	int DPMIGetDescriptor(
;;		selector_t sel, 			;; descriptor to get
;;		struct descriptor_t *descriptor);	;; struct to receive
;;
;;
;; Description:
;;	This function copies the contents of the LDT descriptor specified
;;	by the sel argument to the structure pointed to by the descriptor
;;	argument.
;;
;; DPMI reference: INT 31h AX=000Bh
;;
;; Version 1.0 Error returns:
;;
;;	8022h	invalid selector

DPMIGetDescriptor PROC C USES DI,	\
	sel:selector_t, 		\
	descriptor:PTR

	mov	ax, 000Bh
	mov	bx, sel
	ldptr	di, descriptor, es
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIGetDescriptor ENDP

;;======================================================================
;; Function: Set Raw LDT Descriptor
;;
;; Synopsis:
;;
;;	int DPMISetDescriptor(
;;		selector_t sel, 			;; descriptor to set
;;		struct descriptor_t *descriptor);	;; descriptor contents
;;
;;
;; Description:
;;
;;	This function copies the contents of the structure pointed to
;;	by the descriptor argument to the LDT entry specified by the
;;	sel argument.  If the present bit is set, the
;;
;; DPMI reference: INT 31h AX=000Ch
;;
;; Version 1.0 Error returns:
;;
;;	8021h	invalid value
;;	8022h	invalid selector
;;	8025h	invalid linear address

DPMISetDescriptor PROC C USES DI, \
	sel:selector_t, 	  \
	descriptor:PTR

	mov	ax, 000Ch
	mov	bx, sel
	ldptr	di, descriptor, es
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMISetDescriptor ENDP

;;======================================================================
;; Function: Allocate Specific LDT Descriptor
;;
;; Synopsis:
;;
;;	int DPMIAllocateSpecificDescriptor(
;;		selector_t sel);	;; selector of descriptor to allocate
;;
;;
;; Description:
;;	This function allocates a specific LDT descriptor in the range
;;	04h to 7Ch. It is intended for use only with DOS extended applications
;;	that require compatibility with pre-DPMI environments.
;;
;; DPMI reference: INT 31h AX=000Dh
;;
;; Version 1.0 Error returns:
;;
;;	8011h	descriptor unavailable
;;	8022h	invalid selector

DPMIAllocateSpecificDescriptor PROC C	\
	sel:selector_t

	mov	ax, 000Dh
	mov	bx, sel
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIAllocateSpecificDescriptor ENDP

;;======================================================================
;; Function: Allocate DOS Memory Block
;;
;; Synopsis:
;;
;;	int DPMIAllocateDOSMemory(
;;		uShort nParas,		;; number of paragraphs to allocate
;;		uShort *para,		;; receives para of alloc'ed block
;;		selector_t *sel,	;; receives selector of alloc'ed block
;;		uShort *maxParas);	;; receives max avail in fail case
;;
;;
;; Description:
;;
;;	This function allocates a block of memory from DOS.  The block so
;;	allocated is guaranteed to reside below 1 MB, and thus be addressable
;;	by real mode code.  The desired size of the block is specified by
;;	the nParas argument, which should be set to the number of paragraphs
;;	(16 bytes each) for the block.	The DPMI host provides both a
;;	paragraph address (which is written at the address pointed to by the
;;	para argument),and a selector (which is written at the address
;;	pointed to by the sel argument.
;;
;;	If the requested size of the block is greater than 64 KB (4096 paras),
;;	the DPMI host creates a set of descriptors sufficient to span the
;;	allocated region, with consecutive selectors and bases that differ
;;	by 64 KB.
;;
;;	In the case where there is insufficient memory to satisfy the request,
;;	the DPMI host writes the maximum number of paragraphs available to
;;	the address pointed to by the maxParas argument.
;;
;;
;; DPMI reference: INT 31h AX=0100h
;;
;; Error returns (valid for version 0.9)
;;
;;	0007h	memory control blocks damaged
;;	0008h	insufficient memory

DPMIAllocateDOSMemory PROC C	\
	nParas:uShort,		\
	para:PTR,		\
	sel:PTR,		\
	maxParas:PTR

	mov	ax, 0100h
	mov	bx, nParas
	int	31h
	jc	@@fail

	ldptr	bx, para
	mov	[bx], ax
	ldptr	bx, sel
	mov	[bx], dx

	xor	ax,ax
	jmp	short @@exit
@@fail:
	mov	cx, bx
	ldptr	bx, maxParas
	mov	[bx], cx
@@exit:
	ret
DPMIAllocateDOSMemory ENDP

;;======================================================================
;; Function: Free DOS Memory Block
;;
;; Synopsis:
;;
;;	int DPMIFreeDOSMemory(
;;		selector_t sel);	;; selector of block to free
;;
;;
;; Description:
;;
;;	This function frees a DOS memory block allocated by the function
;;	DPMIAllocateDOSMemory.	The argument is the selector of the
;;	block to be freed. If the DOS block is larger than 64 KB, all of
;;	the descriptors that were allocated for the block are freed.d
;;
;; DPMI reference: INT 31h AX=0101h
;;
;; Error returns (valid for version 0.9):
;;
;;	0007h	memory control blocks damaged
;;	0009h	incorrect memory segment specified

DPMIFreeDOSMemory PROC C	\
	sel:selector_t

	mov	ax, 0101h
	mov	dx, sel
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIFreeDOSMemory ENDP

;;======================================================================
;; Function: Resize DOS Memory Block
;;
;; Synopsis:
;;
;;	int DPMIResizeDOSMemory(
;;		selector_t sel, 	;; selector of block to resize
;;		uShort nParas,		;; desired size of block in paras
;;		uShort *maxParas);	;; receives max paras available
;;
;;
;; Description:
;;
;;	This function changes the size of a block that was allocated with
;;	the function DPMIAllocateDOSMemory.  The nParas argument specifies
;;	the desired new size of the block, in paragraphs.  The sel argument
;;	is the selector of the block to be resized.
;;
;;	In the case where there is insufficient memory to satisfy the request,
;;	the DPMI host writes the maximum number of paragraphs available to
;;	the address pointed to by the maxParas argument.
;;
;; DPMI reference: INT 31h AX=102h
;;
;; Error returns (valid for version 0.9):
;;
;;	0007h	memory control blocks damaged
;;	0008h	insufficient memory
;;	0009h	incorrect memory segment

DPMIResizeDOSMemory PROC C	\
	sel:selector_t, 	\
	nParas:uShort,		\
	maxParas:PTR

	mov	ax, 0102h
	mov	bx, nParas
	mov	dx, sel
	int	31h
	jc	@@fail

	xor	ax, ax
	jmp	short @@exit
@@fail:
	mov	cx, bx
	ldptr	bx, maxParas
	mov	[bx], cx
@@exit:
	ret
DPMIResizeDOSMemory ENDP

;;======================================================================
;; Function: Get Real Mode Interrupt Vector
;;
;; Synopsis:
;;
;;	void DPMIGetRealInterruptVector(
;;		uChar vector,			;; vector number to get
;;		void (far* *realIsr)());	;; receives real vector
;;
;;
;; Description:
;;
;;	This function retrieves the real mode paragraph:offset address of
;;	the real mode interrupt handler specified by the vector argument.
;;	The handler address is written to the address pointed to by the
;;	realIsr argument.
;;
;;
;; DPMI reference: INT 31h AX=0200h
;;

DPMIGetRealInterruptVector PROC C	\
	vector:uChar,			\
	realIsr:PTR

	mov	ax, 0200h
	mov	bl, vector
	int	31h
	ldptr	bx, realIsr
	stlong	[bx], cx, dx

	ret
DPMIGetRealInterruptVector ENDP

;;======================================================================
;; Function: Set Real Mode Interrupt Vector
;;
;; Synopsis:
;;
;;	void DPMISetRealInterruptVector(
;;		uChar vector,			;; vector number to set
;;		void (far *realIsr)()); 	;; new real vector
;;
;;
;; Description:
;;
;;	This function sets the real mode interrupt vector specified by the
;;	vector argument to the value in the realIsr argument.  The handler
;;	address in realIsr must be a real mode paragraph:offset address.
;;
;; DPMI reference: INT 31h AX=0201h
;;

DPMISetRealInterruptVector PROC C	\
	vector:uChar,			\
	realIsr:FAR PTR

	mov	ax, 0201h
	mov	bl, vector
	ldlong	cx, dx, realIsr
	int	31h
	ret
DPMISetRealInterruptVector ENDP

;;======================================================================
;; Function: Get Processor Exception Vector
;;
;; Synopsis:
;;
;;	int DPMIGetExceptionVector(
;;		uChar exception,		;; exception number to get
;;		void (far* *excHandler)());	;; receives handler address
;;
;;
;; Description:
;;
;;	This function retrieves the address of the exception handler
;;	specified by the exception argument (range 0-1Fh).  The handler
;;	address is written to the address pointed to by the
;;	excHandler argument.
;;
;; DPMI reference: INT 31h AX=0202h
;;
;; Version 1.0 Error returns:
;;
;;	8021h	invalid value

DPMIGetExceptionVector PROC C	\
	exception:uChar,	\
	excHandler:PTR

	mov	ax, 0202h
	mov	bl, exception
	int	31h
	jc	@@exit

	ldptr	bx, excHandler
	stlong	[bx], cx, dx

	xor	ax, ax
@@exit:
	ret
DPMIGetExceptionVector ENDP

;;======================================================================
;; Function: Set Processor Exception Vector
;;
;; Synopsis:
;;
;;	int DPMISetExceptionVector(
;;		uChar exception,		;; exception number to set
;;		void (far *excHandler)());	;; new handler address
;;
;;
;; Description:
;;
;;	This function sets the exception vector specified by the
;;	exception argument to the value in the excHandler argument.
;;
;;	The exception handler is defined as follows:
;;
;;		void _saveregs _far excHandler(struct excFrame);
;;
;;	The exception handler may modify the fields of the excFrame structure.
;;	When the handler returns, the DPMI host uses the new values from
;;	the structure to restart the faulting client.
;;
;; DPMI reference: INT 31h AX=0203h
;;
;; Version 1.0 Error returns:
;;
;;	8021h	invalid value
;;	8022h	invalid selector

DPMISetExceptionVector PROC C	\
	exception:uChar,	\
	excHandler:FAR PTR

	mov	ax, 0203h
	mov	bl, exception
	ldlong	cx, dx, excHandler
	int	31h
	jc	@@exit

	xor	ax, ax
@@exit:
	ret
DPMISetExceptionVector ENDP

;;======================================================================
;; Function: Get Protected Mode Interrupt Vector
;;
;; Synopsis:
;;
;;	void DPMIGetProtInterruptVector(
;;		uChar vector,			;; interrupt vector to get
;;		void (far* *protIsr)());	;; receives interrupt vector
;;
;; Description:
;;
;;	This function retrieves the protected mode interrupt vector
;;	specified by the vector argument.  The selector:offset address of
;;	the current interrupt handler is written to the address pointed to
;;	by the protIsr argument.
;;
;; DPMI reference: INT 31h AX=0204h
;;

DPMIGetProtInterruptVector PROC C	\
	vector:uChar,			\
	protIsr:PTR

	mov	ax, 0204h
	mov	bl, vector
	int	31h
	ldptr	bx, protIsr
	stlong	[bx], cx, dx

	ret
DPMIGetProtInterruptVector ENDP

;;======================================================================
;; Function: Set Protected Mode Interrupt Vector
;;
;; Synopsis:
;;
;;	int DPMISetProtInterruptVector(
;;		uChar vector,			;; interrupt vector to set
;;		void (far *protIsr)()); 	;; new handler address
;;
;;
;; Description:
;;
;;	This function sets the address of the protected mode interrupt
;;	handler for the vector specified by the vector arugment.  The
;;	protIsr argument is the selector:offset of the desired new
;;	handler.
;;
;; DPMI reference: INT 31h AX=0205h
;;
;; Version 1.0 Error returns:
;;
;;	8022h	invalid selector

DPMISetProtInterruptVector PROC C	\
	vector:uChar,			\
	protIsr:FAR PTR

	mov	ax, 0205h
	mov	bl, vector
	ldlong	cx, dx, protIsr
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMISetProtInterruptVector ENDP

;;======================================================================
;; Function: Issue Real Mode Interrupt
;;
;; Synopsis:
;;
;;	int DPMIIssueRealInterrupt(
;;		uChar vector,			;; interrupt to issue
;;		uShort nArgBytes,		;; number of bytes of args
;;		struct dpmiRegs_t *regs,	;; real mode register state
;;		...);
;;
;;
;; Description:
;;
;;	This function switches to real mode and issues the interrupt
;;	specified by the vector argument.  Prior to issuing the interrupt,
;;	the DPMI host loads the processor registers with the contents of
;;	the structure pointed to by the regs argument.	When the interrupt
;;	handler returns, the DPMI host updates the register structure to
;;	reflect changes caused by the interrupt handler.
;;
;;	The CS:IP field of the real call structure is ignored, because the
;;	execution address is determined by the real mode interrupt vector.
;;
;; DPMI reference: INT 31h AX=0300h
;;
;; Version 1.0 Error returns:
;;
;;	8012h	linear memory unavailable
;;	8013h	physical memory unavailable
;;	8014h	backing store unavailable
;;	8021h	invalid value

DPMIIssueRealInterrupt PROC C USES DS SI DI,	\
	vector:BYTE,				\
	nArgBytes:uShort,			\
	regs:PTR,				\
	arguments:BYTE

	mov	cx, nArgBytes		;; copy stack arguments
	jcxz	@@doCall
	sub	sp, cx
	mov	di, sp
	lea	si, arguments
	mov	ax, ss
	mov	ds, ax
	mov	es, ax
	cld
	rep movsb
@@doCall:
	mov	ax, 0300h
	xor	bh, bh
	mov	bl, vector
	mov	cx, nArgBytes
	ldptr	di, regs, es
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	add	sp, nArgBytes
	ret
DPMIIssueRealInterrupt ENDP

;;======================================================================
;; Function: Call Real Mode Procedure with Far Return
;;
;; Synopsis:
;;
;;	int DPMICallRealProcedure(
;;		uShort nArgBytes,		;; number of bytes of args
;;		struct dpmiRegs_t *regs,	;; real mode register state
;;		...);				;; function arguments
;;
;; Description:
;;
;;	This function causes the DPMI host to switch to real mode, push
;;	zero or more argument bytes on the stack, and call the far function
;;	indicated by the CS:IP fields of the real call structure pointed
;;	to by the regs argument.  The number of argument bytes to push is
;;	given by the nArgBytes argument, and the function arguments should
;;	follow the pointer to the real call structure in the arugment list.
;;	The real function must return on the same stack on which it was
;;	called.
;;
;;	The DPMI host reloads the register structure with the register
;;	current register state when the far function returns.
;;
;; DPMI reference: INT 31h AX=0301h
;;
;; Version 1.0 Error returns:
;;
;;	8012h	linear memory unavailable
;;	8013h	physical memory unavailable
;;	8014h	backing store unavailable
;;	8021h	invalid value

DPMICallRealProcedure PROC C USES DS SI DI,	\
	nArgBytes:uShort,			\
	regs:PTR,				\
	arguments:BYTE

	mov	cx, nArgBytes		;; copy stack arguments
	jcxz	@@doCall
	sub	sp, cx
	mov	di, sp
	lea	si, arguments
	mov	ax, ss
	mov	ds, ax
	mov	es, ax
	cld
	rep movsb
@@doCall:
	mov	ax, 0301h
	xor	bh, bh
	mov	cx, nArgBytes
	ldptr	di, regs, es
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	add	sp, nArgBytes
	ret
DPMICallRealProcedure ENDP

;;======================================================================
;; Function: Call Real Mode Procedure with IRET
;;
;; Synopsis:
;;
;;	int DPMICallRealInterruptProcedure(
;;		uShort nArgBytes,		;; number of bytes of args
;;		struct dpmiRegs_t *regs,	;; real mode register state
;;		...);				;; function arguments.
;;
;;
;; Description:
;;
;;	This function is identical to DPMICallRealProcedure, except that
;;	it is used to call a real function that returns with an IRET
;;	instead of a RETF.
;;
;; DPMI reference: INT 31h AX=0302h
;;
;; Version 1.0 Error returns:
;;
;;	8012h	linear memory unavailable
;;	8013h	physical memory unavailable
;;	8014h	backing store unavailable
;;	8021h	invalid value

DPMICallRealInterruptProcedure PROC C USES DS SI DI, \
	nArgBytes:uShort,			\
	regs:PTR,				\
	arguments:BYTE

	mov	cx, nArgBytes		;; copy stack arguments
	jcxz	@@doCall
	sub	sp, cx
	mov	di, sp
	lea	si, arguments
	mov	ax, ss
	mov	ds, ax
	mov	es, ax
	cld
	rep movsb
@@doCall:
	mov	ax, 0302h
	xor	bh, bh
	mov	cx, nArgBytes
	ldptr	di, regs, es
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	add	sp, nArgBytes
	ret
DPMICallRealInterruptProcedure ENDP

;;======================================================================
;; Function: Allocate Real Mode Callback
;;
;; Synopsis:
;;
;;	int DPMIAllocateRealCallBack(
;;		struct dpmiRegs_t *regs,	;; address of static reg state
;;		void (far *handler)(),		;; prot mode callback handler
;;		void (far* *cbAddr)()); 	;; receives real callback addr
;;
;; Description:
;;
;;	This function allocates a real mode callback from the DPMI host.
;;	A real mode callback is a real mode address (paragraph:offset) that
;;	a real mode caller uses to invoke a protected mode callback
;;	handler.  This provides a mechanism for calling protected mode
;;	from real mode.
;;
;;	The cbAddr argument points to the location to receive the real mode
;;	callback address.  When called, the DPMI host passes control to
;;	the protected mode address specified by the handler argument.
;;
;;	The protected mode handler  is passed (in ES:DI) a pointer to the
;;	real mode call structure whose address is passed  to this function
;;	in the regs argument.  Therefore, this structure should be statically
;;	allocated.  The DPMI host is responsible for loading the structure
;;	with the register state at the time of the callback prior to passing
;;	it to the protected mode callback handler. The handler is also
;;	passed (in DS:SI) the address of the real mode stack.
;;
;;	The DPMI host uses the register state in the call structure
;;	to restart the real mode caller.  It is the responsibility of the
;;	protected mode handler to locate the real mode return address on
;;	the real mode stack, and store it in the CS:IP fields of the call
;;	structure in order to effect a return from the callback.
;;
;; DPMI reference: INT 31h AX=0303h
;;
;; Version 1.0 Error returns:
;;
;;	8015h	callback unavailable

DPMIAllocateRealCallBack PROC C USES DS SI DI,	\
	regs:PTR,				\
	handler:FAR PTR,			\
	cbAddr:PTR

	push	ds
	mov	ax, 0303h
	ldptr	di, regs, es
	ldlong	ds, si, handler
	int	31h
	jc	@@fail

	pop	ds
	ldptr	bx, cbAddr
	stlong	[bx], cx, dx
	xor	ax, ax
	jmp	short @@exit
@@fail:
	pop	ds
@@exit:
	ret
DPMIAllocateRealCallBack ENDP

;;======================================================================
;; Function: Free Real Mode Callback
;;
;; Synopsis:
;;
;;	int DPMIFreeRealCallBack(
;;		void (far *cbAddr)());		;; callback to free
;;
;;
;; Description:
;;
;;	This function frees a real mode callback allocated by
;;	DPMIAllocateRealCallBack.  The cbAddr is the callback
;;	address to be freed.
;;
;; DPMI reference: INT 31h AX=0303h
;;
;; Version 1.0 Error returns:
;;
;;	8024h	invalid callback address

DPMIFreeRealCallBack PROC C	\
	cbAddr:FAR PTR

	mov	ax, 0304h
	ldlong	cx, dx, cbAddr
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIFreeRealCallBack ENDP

;;======================================================================
;; Function: Get State Save/Restore Procedure Addresses
;;
;; Synopsis:
;;
;;	void DPMIGetStateSaveRestoreProcs(
;;		uShort *stateSize,		;; size of state info
;;		void (far* *realProc)(),	;; receives real save/rst proc
;;		void (far* *protProc)());	;; receives prot save/rst proc
;;
;; Description:
;;
;;	This function retrieves information from the DPMI host that
;;	is required for saving and restoring the client state when
;;	using the raw mode switch function.
;;
;;	The DPMI specification requires that clients save their state
;;	prior to making a raw mode switch, and subsequently restore it.
;;	This function provides the size of the state information, and
;;	the both the protected mode and real mode addresses of functions
;;	to call to save and restore the client state.
;;
;;	The size of the state information, in bytes, is stored at the
;;	address pointed to by the stateSize argument.  The address of the
;;	far procedure to call from real mode to save or restore the client
;;	state is stored at the address pointed to by the realProc argument.
;;	The address of the far procedure to call from protected mode to
;;	save and restore the client state is stored at the address pointed
;;	to by the protProc argument.
;;
;;	The state save/restore procedures are called with AL=0 to save the
;;	state, and AL=1 to restore the state.  In both cases, ES:DI points
;;	to the state information buffer.
;;
;;
;; DPMI reference: INT 31h AX=0305h

DPMIGetStateSaveRestoreProcs PROC C USES SI DI, \
	stateSize:PTR,		\
	realProc:PTR,		\
	protProc:PTR

	mov	ax, 0305h
	int	31h

	mov	dx, bx

	ldptr	bx, stateSize
	mov	[bx], ax
	ldptr	bx, realProc
	stlong	[bx], dx, cx
	ldptr	bx, protProc
	stlong	[bx], si, di

	ret
DPMIGetStateSaveRestoreProcs ENDP

;;======================================================================
;; Function: Save Or Restore Client State for Raw Switch
;;
;; Synopsis:
;;
;;	void DPMISaveOrRestoreState(
;;		int saveRestore,		;; 0=save 1=restore
;;		uChar *stateBuffer,		;; pointer to state buffer
;;		void (far *procAddr)());	;; procedure to call
;;
;; Description:
;;
;;	This function invokes the save/restore procedure whose address
;;	is specified by the procAddr argument.	The stateBuffer argument
;;	points to the buffer to supply or receive the client state. Its
;;	size is determined by calling DPMIGetStateSaveRestoreProcs. The
;;	saveRestore argument is zero to perform state save, or one to
;;	perform a state restore.

DPMISaveOrRestoreState PROC C USES DI,	\
	saveRestore:WORD,		\
	stateBuffer:PTR,		\
	procAddr:FAR PTR

	mov	ax, saveRestore
	ldptr	di, stateBuffer, es
	call	procAddr

	ret
DPMISaveOrRestoreState ENDP

;;======================================================================
;; Function: Get Raw Switch Procedure Addresses
;;
;; Synopsis:
;;
;;	void DPMIGetRawSwitchProc(
;;		void (far* *realToProt)(),	;; real to prot switch addr
;;		void (far* *protToReal)());	;; prot to real switch addr
;;
;; Description:
;;
;;	This function retrieves information from the DPMI host that
;;	is required for raw mode switching.  The address (paragraph:offset)
;;	of the real to protected mode service is stored at the address
;;	pointed to by the realToProt argument.	The address (selector:offset)
;;	of the protected to real mode service is stored at the address
;;	pointed to by the protToReal argument.
;;
;; DPMI reference: INT 31h AX=0306h

DPMIGetRawSwitchProc PROC C USES SI DI, \
	realToProt:PTR, 		\
	protToReal:PTR

	mov	ax,0306h
	int	31h

	mov	dx, bx
	ldptr	bx, realToProt
	stlong	[bx], dx, cx
	ldptr	bx, protToReal
	stlong	[bx], si, di

	ret
DPMIGetRawSwitchProc ENDP

;;======================================================================
;; Function: Do Raw Mode Switch
;;
;; Synopsis:
;;
;;	void DPMIDoRawSwitch(
;;		void (far *switchAddr)(),	;; switch service address
;;		struct rawModeRegs_t *rawRegs); ;; new register values
;;
;; Description:
;;
;;	This function invokes the raw switch service.  The switchAddr
;;	argument is obtained from DPMIGetRawSwitchProc, and specifies
;;	the address of the switch service to invoke.  When the function
;;	returns, the processor will be in the alternate mode.
;;
;;	The rawRegs argument points to the structure containing the register
;;	contents to be put in effect after the mode switch is effected.
;;	The values in the structure MUST be aliases for the currently active
;;	segment registers.  In other words, when switching from protected
;;	to real mode, each segment register value in the structure must
;;	be the paragraph equivalent of the current protected mode descriptor
;;	value.	Likewise, when switching from real to protected mode, each
;;	segment register value in the structure must be the selector that
;;	maps the current paragraph in each segment register. These
;;	requirements imply that this routine must execute only in the low
;;	1 MB of the address space, and that the stack must also be in the
;;	low 1 MB.
;;
;; DPMI reference: invoking the raw mode switch services

DPMIDoRawSwitch PROC C USES SI DI,	\
	switchAddr:FAR PTR,	\
	rawRegs:PTR

	ldptr	di, rawRegs
	mov	ax, [di].rawDS
	mov	cx, [di].rawES
	mov	dx, [di].rawSS
	mov	bx, sp
	mov	si, [di].rawCS
	mov	di, offset @@cont
	push	word ptr switchAddr+2	;; push switch address and retf to it
	push	word ptr switchAddr
	retf
@@cont:
	ret
DPMIDoRawSwitch ENDP

;;======================================================================
;; Function: Get DPMI Host Version Information
;;
;; Synopsis:
;;
;;	void DPMIGetVersion(
;;		uChar *major,		;; receives major version number
;;		uChar *minor,		;; receives minor version number
;;		uChar *processor,	;; receives processor code
;;		uShort *flags,		;; receives flags
;;		uChar *masterPIC,	;; receives virtual master PIC base
;;		uChar *slavePIC);	;; receives virtual slave PIC base
;;
;; Description:
;;
;;	This function retrieves version information from the DPMI host.
;;	For version 0.9, the major version is zero and the minor version
;;	is 90 (5Ah).  The processor codes are as follows:
;;
;;		2 => 80286, 3 => 80386, 4 => 80486 5-FFh => future
;;
;;	The bits of the flags word have the following meanings:
;;
;;		Bit	Meaning
;;		 0	0 = 16-bit host,
;;			1 = 32-bit host
;;		 1	0 = DOS runs in virtual 86 mode,
;;			1 = DOS runs in real
;;		 2	0 = no virtual memory support
;;			1 = virtual memory supported
;;
;; DPMI reference: INT 31h AX=0400h

DPMIGetVersion PROC C USES SI,	\
	major:PTR,	\
	minor:PTR,	\
	processor:PTR,	\
	flags:PTR,	\
	masterPIC:PTR,	\
	slavePIC:PTR

	mov	ax, 0400h
	int	31h

	ldptr	si, major
	mov	[si], ah
	ldptr	si, minor
	mov	[si], al
	ldptr	si, flags
	mov	[si], bx
	ldptr	si, processor
	mov	[si], cl
	ldptr	si, masterPIC
	mov	[si], dh
	ldptr	si, slavePIC
	mov	[si], dl

	ret
DPMIGetVersion ENDP

;;======================================================================
;; Function: Get Free Memory Information
;;
;; Synopsis:
;;
;;	void DPMIGetFreeMemory(
;;		struct freeMem_t *freeMem); ;; receives free mem info
;;
;;
;; Description:
;;
;;	This function retrieves free memory information from the DPMI
;;	host.  The freeMem argument is a pointer to the structure to
;;	receive the free memory information. Only the first field
;;	(largestFree) of the free memory structure is guaranteed to be
;;	supported.  The other values are set to 0xffffffff if the
;;	item is unavailable.
;;
;; DPMI reference: INT 31h AX=0500h

DPMIGetFreeMemory PROC C USES DI,	\
	freeMem:PTR

	mov	ax, 0500h
	ldptr	di, freeMem, es
	int	31h
	ret
DPMIGetFreeMemory ENDP

;;======================================================================
;; Function: Allocate Memory Block
;;
;; Synopsis:
;;
;;	int DPMIAllocateMemory(
;;		uLong nBytes,		;; size of block to allocate
;;		uLong *base,		;; receives linear base of block
;;		uLong *handle); 	;; receives block handle
;;
;; Description:
;;
;;	This function allocates a memory block.  The nBytes argument
;;	specifies the desired size of the block to allocate, in bytes.
;;	The linear base address of the block that is allocated is
;;	written to the address pointed to by the base argument.  The
;;	block handle is written to the address pointed to by the handle
;;	argument.  The handle is used to free or resize the block.
;;
;; DPMI reference: INT 31h AX=0501h
;;
;; Version 1.0 Error returns:
;;
;;	8012h	linear memory unavailable
;;	8013h	physicl memory unavailable
;;	8014h	backing store unavailable
;;	8016h	handle unavailable
;;	8021h	invalid value

DPMIAllocateMemory PROC C USES SI DI,	\
	nBytes:uLong,			\
	base:PTR,			\
	handle:PTR

	mov	ax, 0501h
	ldlong	bx, cx, nBytes
	int	31h
	jc	@@exit

	mov	ax, bx
	ldptr	bx, base
	stlong	[bx], ax, cx
	ldptr	bx, handle
	stlong	[bx], si, di
	xor	ax, ax
@@exit:
	ret
DPMIAllocateMemory ENDP

;;======================================================================
;; Function: Free Memory Block
;;
;; Synopsis:
;;
;;	int DPMIFreeMemory(
;;		uLong handle);		;; handle of block to free
;;
;;
;; Description:
;;
;;	This function frees a memory block allocated by DPMIAllocateMemory.
;;
;; DPMI reference: INT 31h AX=0502h
;;
;; Version 1.0 Error returns:
;;
;;	8023h	invalid handle

DPMIFreeMemory PROC C USES SI DI,	\
	handle:uLong

	mov	ax, 0502h
	ldlong	si, di, handle
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIFreeMemory ENDP

;;======================================================================
;; Function: Resize Memory Block
;;
;; Synopsis:
;;
;;	int DPMIResizeMemory(
;;		uLong *handle,		;;address of handle of block to resize
;;		uLong nBytes,		;; new desired size in bytes
;;		uLong *base);		;; receives new linear base of block
;;
;; Description:
;;
;;	This function resizes a memory block allocated by DPMIAllocateMemory.
;;	The handle argument points to the handle of the block to resize.
;;	The nBytes argument is the desired new size of the block, in bytes.
;;	The base argument points to the address to receive the new address
;;	of the block.  Note that both the block handle and the linear base
;;	of the block may be changed by this call.
;;
;; DPMI reference: INT 31h AX=0503h
;;
;; Version 1.0 Error returns:
;;
;;	8012h	linear memory unavailable
;;	8013h	physical memory unavailable
;;	8014h	backing store unavailable
;;	8016h	handle unavailable
;;	8021h	invalid value

DPMIResizeMemory PROC C USES SI DI,	\
	handle:PTR,			\
	nBytes:uLong,			\
	base:PTR

	mov	ax, 0503h
	ldptr	bx, handle
	ldlong	si, di, [bx]
	ldlong	bx, cx, nBytes
	int	31h
	jc	@@exit

	mov	ax, bx
	ldptr	bx, base
	stlong	[bx], ax, cx
	ldptr	bx, handle
	stlong	[bx], si, di
	xor	ax, ax
@@exit:
	ret
DPMIResizeMemory ENDP

;;======================================================================
;; Function: Lock Linear Region of Memory
;;
;; Synopsis:
;;
;;	int DPMILockRegion(
;;		uLong base,		;; linear address of region to lock
;;		uLong nBytes);		;; size of region to lock
;;
;; Description:
;;
;;	This function is used to prevent pages from being swapped to disk
;;	by a DPMI host that supports virtual memory.  The base argument is
;;	the linear address of the start of the region to be locked, and the
;;	nBytes argument is the size of the region to lock.  The host maintains
;;	a lock count for each page.  If the DPMI host does not support
;;	virtual memory, the function has no effect.
;;
;; DPMI reference: INT 31h AX=0600h
;;
;; Version 1.0 Error returns:
;;
;;	8013h	physical memory unavailable
;;	8017h	lock count exceeded
;;	8025h	invalid linear address

DPMILockRegion PROC C USES SI DI,	\
	base:uLong,			\
	nBytes:uLong

	mov	ax, 0600h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMILockRegion ENDP

;;======================================================================
;; Function: Unlock Linear Region of Memory
;;
;; Synopsis:
;;
;;	int DPMIUnlockRegion(
;;		uLong base,		;; linear address of region to unlock
;;		uLong nBytes);		;; size of region to unlock
;;
;; Description:
;;
;;	This function decrements the lock count for pages in the specified
;;	region.  The base argument is the linear address of the start of the
;;	region, and the nBytes argument is the size of the region in bytes.
;;	Pages are not unlocked until the lock count is zero.
;;
;; DPMI reference: INT 31h AX=0601h
;;
;; Version 1.0 Error returns:
;;
;;	8002h	invalid state
;;	8025h	invalid linear address

DPMIUnlockRegion PROC C USES SI DI,	\
	base:uLong,			\
	nBytes:uLong

	mov	ax, 0601h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIUnlockRegion ENDP

;;======================================================================
;; Function: Mark Real Mode Region as Pageable
;;
;; Synopsis:
;;
;;	int DPMIMarkRealRegionPageable(
;;		uLong base,		;; linear address of region to mark
;;		uLong nBytes);		;; size in bytes of region to mark
;;
;; Description:
;;
;;	This function allows memory in the low megabyte of the linear
;;	address space to be swapped to disk by a DPMI host that supports
;;	virtual memory.  The base argument is the linear address of the
;;	start of the region to be made pageable, and the nBytes argument
;;	is the size of the region in bytes.
;;
;; DPMI reference: INT 31h AX=0602h
;;
;; Version 1.0 Error returns:
;;
;;	8002h	invalid state
;;	8025h	invalid linear address

DPMIMarkRealRegionPageable PROC C USES SI DI,	\
	base:uLong,				\
	nBytes:uLong

	mov	ax, 0602h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIMarkRealRegionPageable ENDP

;;======================================================================
;; Function: Relock Real Mode Region
;;
;; Synopsis:
;;
;;	int DPMIRelockRealRegion(
;;		uLong base,		;; linear address of region to relock
;;		uLong nBytes);		;; size in bytes of region to relock
;;
;; Description:
;;
;;	This function relocks a memory region in the low 1 MB that was marked
;;	as pageable by DPMIMarkRealRegionPageable.  The base argument is the
;;	linear address of the start of the region to be relocked, and the
;;	nBytes argument is the size of the region in bytes.
;;
;; DPMI reference: INT 31h AX=0603h
;;
;; Version 1.0 Error returns:
;;
;;	8002h	invalid state
;;	8013h	physical meomory unavailable
;;	8025h	invalid linear address

DPMIRelockRealRegion PROC C USES SI DI, \
	base:uLong,			\
	nBytes:uLong

	mov	ax, 0603h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIRelockRealRegion ENDP

;;======================================================================
;; Function: Get Size of Processor Page
;;
;; Synopsis:
;;
;;	int DPMIGetPageSize(
;;		uLong *pageSize);
;;
;; Description:
;;
;;	This function is used to determine the processor's page size.
;;	The pageSize argument points to the location to receive the
;;	page size, in bytes.  16-bit hosts will fail this call.
;;
;; DPMI reference: INT 31h AX=0604h
;;
;; Version 1.0 Error returns:
;;
;;	8001h	unsupported function

DPMIGetPageSize PROC C \
	pageSize:PTR

	mov	ax, 0604h
	int	31h
	jc	@@exit

	mov	ax, bx
	ldptr	bx, pageSize
	stlong	[bx], ax, cx
	xor	ax, ax
@@exit:
	ret
DPMIGetPageSize ENDP

;;======================================================================
;; Function: Nominate Pages as Demand Paging Candidates
;;
;; Synopsis:
;;
;;	int DPMINominatePages(
;;		uLong base,		;; base of region to nominate
;;		uLong nBytes);		;; size in bytes of region
;;
;; Description:
;;
;;	This function is used to indicate to the DPMI host that a range
;;	of memory should be the most likely to be swapped to disk.  The
;;	base argument is the linear address of the start of the region
;;	to be nominated, and the nBytes argument is the size of the region,
;;	in bytes.  The call is advisory only.
;;
;; DPMI reference: INT 31h AX=0702h
;;
;; Version 1.0 Error returns:
;;
;;	8025h	invalid linear address range

DPMINominatePages PROC C USES SI DI,	\
	base:uLong,			\
	nBytes:uLong

	mov	ax, 0702h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMINominatePages ENDP

;;======================================================================
;; Function: Discard Contents of Pages
;;
;; Synopsis:
;;
;;	int DPMIDiscardPageContents(
;;		uLong base,		;; base of region to discard
;;		uLong nBytes);		;; size of region in bytes
;;
;; Description:
;;
;;	This function advises the DPMI host to discard the contents of
;;	the specified region to avoid unnecessarily saving them on disk.  The
;;	base argument is the linear address of the start of the region
;;	to be discarded, and the nBytes argument is the size of the region,
;;	in bytes.  The call is advisory only.
;;
;; DPMI reference: INT 31h AX=0703h
;;
;; Version 1.0 Error returns:
;;
;;	8025h	invalid linear address

DPMIDiscardPageContents PROC C USES SI DI,	\
	base:uLong,				\
	nBytes:uLong

	mov	ax, 0703h
	ldlong	bx, cx, base
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIDiscardPageContents ENDP

;;======================================================================
;; Function: Get Linear Address for Physical Region
;;
;; Synopsis:
;;
;;	int DPMIMapPhysicalRegion(
;;		uLong physAddr, 	;; physical address to map
;;		uLong nBytes,		;; size of region to map
;;		uLong *linear); 	;; receives linear address of region
;;
;; Description:
;;
;;	This function allows a DPMI client to obtain a linear address that
;;	maps to any physical address above 1 MB.  The physAddr argument
;;	specifies the physical address of the region to map. The nBytes
;;	argument is the size of the region to map, in bytes. The linear
;;	argument points to the address to receive the linear address that
;;	the DPMI sets up to map the physical region.
;;
;; DPMI reference: INT 31h AX=0800h
;;
;; Version 1.0 Error returns:
;;
;;	8003h	system integrity
;;	8021h	invalid value

DPMIMapPhysicalRegion PROC C USES SI DI,\
	physAddr:uLong, 		\
	nBytes:uLong,			\
	linear:PTR

	mov	ax, 0800h
	ldlong	bx, cx, physAddr
	ldlong	si, di, nBytes
	int	31h
	jc	@@exit

	ldptr	si, linear
	stlong	[si], bx, cx
	xor	ax, ax
@@exit:
	ret
DPMIMapPhysicalRegion ENDP

;;======================================================================
;; Function: Test Virtual Interrupt State and Disable
;;
;; Synopsis:
;;
;;	int DPMITestDisableInts(void);
;;
;; Description:
;;
;;	This function returns the current virtual interrupt enable state,
;;	and disables virtual interrupts.  The return value is zero if
;;	interrupts were previously disabled, and one if they were enabled.
;;
;; DPMI reference: INT 31h AX=0900h

DPMITestDisableInts PROC C
	mov	ax, 0900h
	int	31h
	xor	ah, ah
	ret
DPMITestDisableInts ENDP

;;======================================================================
;; Function: Test Virtual Interrupt State and Enable
;;
;; Synopsis:
;;
;;	int DPMITestEnableInts(void);
;;
;; Description:
;;
;;	This function returns the current virtual interrupt enable state,
;;	and enables virtual interrupts.  The return value is zero if
;;	interrupts were previously disabled, and one if they were enabled.
;;
;; DPMI reference: INT 31h AX=0901h

DPMITestEnableInts PROC C
	mov	ax, 0901h
	int	31h
	xor	ah, ah
	ret
DPMITestEnableInts ENDP

;;======================================================================
;; Function: Test Virtual Interrupt State
;;
;; Synopsis:
;;
;;	int DPMITestInts(void);
;;
;; Description:
;;
;;	This function returns the current virtual interrupt enable state.
;;	The return value is zero if interrupts are disabled, and one if
;;	they are enabled.
;;
;;
;; DPMI reference: INT 31h AX=0902h

DPMITestInts PROC C
	mov	ax, 0902h
	int	31h
	xor	ah, ah
	ret
DPMITestInts ENDP

;;======================================================================
;; Function: Get Vendor Extensions Entry Point
;;
;; Synopsis:
;;
;;	int DPMIGetVendorEntryPoint(
;;		char *extensionID,
;;		void (far* *extAPIEntry)());
;;
;; Description:
;;
;;	This function retrieves an address that can be used to access
;;	vendor specific DPMI extensions.  The extensionID argument points
;;	to a null terminated string that identifies the desired set of
;;	extensions.  The extAPIEntry argument points to the address where
;;	a far pointer to the vendor entry point is to be stored.  The function
;;	returns non-zero if the requested vendor extensions are not found.
;;
;; DPMI reference: INT 31h AX=0A00h and INT 2Fh AX=168Ah
;;
;; Version 1.0 Error returns:
;;
;;	8001h	unsupported function

DPMIGetVendorEntryPoint PROC C USES SI DI,	\
	extensionID:PTR,			\
	extAPIEntry:PTR

	mov	ax, 0A00h
	ldptr	si, extensionID
	int	31h
	jc	@@exit

	ldptr	bx, extAPIEntry
	stlong	[bx], es, di
	xor	ax, ax
@@exit:
	ret
DPMIGetVendorEntryPoint ENDP

;;======================================================================
;; Function: Set Debug Watchpoint
;;
;; Synopsis:
;;
;;	int DPMISetWatchpoint(
;;		uLong linear,		;; linear address of watchpoint
;;		enum watchSize size,	;; watchpoint size
;;		enum watchType type,	;; watchpoint type
;;		uShort *watchHandle);	;; receives watchpoint handle
;;
;; Description:
;;
;;	This function sets a debug watchpoint using the processor's debug
;;	registers.  The linear argument specifies the linear address of the
;;	watchpoint.  Arguments watchSize and watchType specify the size
;;	and type of the watchpoint.  The watchHandle argument points to the
;;	location to receive the watchpoint handle allocated by the DPMI
;;	host.  Tripping a watchpoint invokes the exception 1 handler.
;;
;; DPMI reference: INT 31h AX=0B00h
;;
;; Version 1.0 Error returns:
;;
;;	8016h	too many breakpoints
;;	8021h	invalid value
;;	8025h	invalid linear address

DPMISetWatchpoint PROC C \
	linear:uLong,	\
	wSize:BYTE,	\
	wType:BYTE,	\
	watchHandle:PTR

	mov	ax, 0B00h
	ldlong	bx, cx, linear
	mov	dl, wSize
	mov	dh, wType
	int	31h
	jc	@@exit
	mov	ax, bx
	ldptr	bx, watchHandle
	mov	[bx], ax
	xor	ax, ax
@@exit:
	ret
DPMISetWatchpoint ENDP

;;======================================================================
;; Function: Clear Debug Watchpoint
;;
;; Synopsis:
;;
;;	int DPMIClearWatchpoint(
;;		uShort watchHandle);	;; handle of watchpoint to free
;;
;; Description:
;;
;;	This function releases the watchpoint handle allocated by
;;	DPMISetWatchpoint, and clears the associated debug register.
;;	The watchHandle argument is the handle of the watchpoint to free.
;;
;; DPMI reference: INT 31h AX=0B01h
;;
;; Version 1.0 Error returns:
;;
;;	8023h	invalid handle

DPMIClearWatchpoint PROC C	\
	watchHandle:uShort

	mov	ax, 0B01h
	mov	bx, watchHandle
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIClearWatchpoint ENDP

;;======================================================================
;; Function: Get Debug Watchpoint State
;;
;; Synopsis:
;;
;;	int DPMIGetWatchpointState(
;;		uShort watchHandle,	;;handle of watchpoint to get state of
;;		uChar *tripped);	;; receives state
;;
;; Description:
;;
;;	This function retrieves the state of a watchpoint set by
;;	DPMISetWatchpoint.  The watchHandle argument is the handle of
;;	watchpoint whose state is to be retrieved.  The tripped argument
;;	receives a zero if the watchpoint has not been encountered,
;;	and receives a one if the watchpoint has been encountered.
;;
;; DPMI reference: INT 31h AX=0B02h
;;
;; Version 1.0 Error returns:
;;
;;	8023h	invalid handle

DPMIGetWatchpointState PROC C	\
	watchHandle:uShort,	\
	tripped:PTR

	mov	ax, 0B02h
	mov	bx, watchHandle
	int	31h
	jc	@@exit
	ldptr	bx, tripped
	mov	[bx], al
	xor	ax, ax
@@exit:
	ret
DPMIGetWatchpointState ENDP

;;======================================================================
;; Function: Reset Debug Watchpoint
;;
;; Synopsis:
;;
;;	int DPMIResetWatchpoint(
;;		uShort watchHandle);	;; handle of watchpoint to reset
;;
;; Description:
;;
;;	This function resets the state of a watchpoint allocated by
;;	DPMISetWatchpoint.  This sets the watchpoint state to
;;	"not encountered".  The watchHandle argument specifies the watchpoint
;;	in question.
;;
;; DPMI reference: INT 31h AX=0B03h
;;
;; Version 1.0 Error returns:
;;
;;	8023h	invalid handle

DPMIResetWatchpoint PROC C \
	watchHandle:uShort

	mov	ax, 0B03h
	mov	bx, watchHandle
	int	31h
	jc	@@exit
	xor	ax, ax
@@exit:
	ret
DPMIResetWatchpoint ENDP

;;======================================================================
;; Function: Get Current Code Segment
;;
getCS	PROC C
	mov	ax, cs
	ret
getCS	ENDP

;;======================================================================
;; Function: Get Current Data Segment

getDS	PROC C
	mov	ax, ds
	ret
getDS	ENDP




;;======================================================================
;;
;; The remainder of the source module is comprised of routines that
;; re-fix-up the EXE after entering protected mode
;;

relocCountOffset	equ	6
relocTableStart 	equ	18h

;;======================================================================
;; Read a word from a file
;;   bx is the handle
;;   ax is the offset
;;
;;   Return word in ax
;;
getWord PROC C USES DS BX CX DX
	mov	dx, ax
	mov	ax, 4200h
	xor	cx, cx
	int	21h			;; seek to offset
	push	ax
	mov	dx, sp
	push	ss
	pop	ds
	mov	cx, 2
	mov	ah, 3fh
	int	21h			;; read to word buf on stack
	pop	ax			;; pop word for return
	ret
getWord ENDP

;;======================================================================
;;Read in the fixup table
;;
readFixupTable PROC
	mov	ah, 62h 		;; get psp
	int	21h
	mov	es, bx
	mov	es, es:[2ch]		;; get environment
	xor	bx, bx
chkForEnd:
	cmp	word ptr es:[bx], 0
	je	foundEnvEnd
	inc	bx
	jmp	chkForEnd
foundEnvEnd:
	add	bx, 4
	push	ds
	push	es
	pop	ds
	mov	dx, bx
	mov	ax, 3d00h		;; open this exe file
	int	21h
	pop	ds
	jc	rFTfail
	mov	bx, ax			;; handle to bx

	mov	ax, 0
	call	getWord
	cmp	ax, 'ZM'                ;; quit if not exe signature
	push	ax
	jne	rFTclose
	pop	ax

	mov	ax, relocCountOffset
	call	getWord 		;; get reloc count to cx
	mov	cx, ax

	or	cx, cx
	jnz	getTable
	push	cx
	jmp	rFTclose

getTable:
	mov	ax, relocTableStart
	call	getWord 		;; get start of reloc table

	push	cx			;; save count
	xor	cx, cx
	mov	dx, ax
	mov	ax, 4200h		;; seek to reloc table
	int	21h
	pop	cx
	jc	rFTfail

	shl	cx, 2			;; each entry four bytes
	add	cx, 0fh 		;; round up to para
	shr	cx, 4			;; cx = paras needed for table

	push	cx			;; save para count
	push	bx			;; save handle
	mov	bx, cx			;; get a buffer from DOS
	mov	ah, 48h
	int	21h
	pop	bx
	pop	cx
	jc	rFTfail

	push	ds
	mov	ds, ax
	mov	es, ax			;; es is para of table
	xor	dx, dx
	shl	cx, 4			;; para to byte
	mov	ah, 3fh
	int	21h			;; read reloc table
	pop	ds
	jc	rFTfail

	mov	ax, relocCountOffset
	call	getWord
	push	ax

rFTclose:
	mov	ah, 3eh
	int	21h			;; close the file
	pop	ax			;; pop count of relocs
	jmp	short rFTexit

rFTfail:
	xor	ax, ax
rFTexit:
	ret
readFixupTable ENDP


;;======================================================================
;; Initialize the fixup data area
;;
setupFixup PROC C USES AX BX CX DX
	mov	ax, 0000h		;; get a descriptor
	int	31h
	mov	fixupSel, ax

	mov	dx, 0ffffh
	mov	cx, 0
	mov	bx, ax
	mov	ax, 0008h		;; set limit to 64 kb
	int	31h

	mov	ax, 0006h		;; get segment base
	mov	bx, cs
	int	31h
	shr	dx, 4			;; convert linear base to para
	shl	cx, 12
	or	dx, cx
	mov	codePara, dx

	mov	ax, 0006h		;; get segment base
	mov	bx, ds
	int	31h
	shr	dx, 4			;; convert linear base to para
	shl	cx, 12
	or	dx, cx
	mov	dataPara, dx

	ret
setupFixup ENDP

;;======================================================================
;; Process a fixup
;;
;; es:di points to fixup record
;;
processFixup PROC USES CX ES
	mov	bx, es:[di]		;; pick up fixup rec in ax bx
	mov	dx, es:[di].2
	add	dx, codePara
	mov	ax, dx			;; compute linear address
	shl	ax, 4
	shr	dx, 12
	add	ax, bx
	adc	dx, 0			;; linear addr of fixup in dx:ax
	mov	bx, fixupSel
	mov	cx, dx
	mov	dx, ax
	mov	ax, 7			;; target descriptor to fixup
	int	31h
	mov	es, bx
	mov	ax, es:[0]		;; get fixup target
	cmp	ax, codePara		;; is it a fixup to CS?
	je	fixCode
	cmp	ax, dataPara		;; a fixup to DS?
	jb	newCode
	je	fixData
	jmp	newData

fixCode:
	mov	es:[0], cs
	jmp	pFexit

fixData:
	mov	es:[0], ds
	jmp	pFexit

newCode:
	mov	bx, ax			;; para to selector
	mov	ax, 0002h
	int	31h

	mov	bx, ax			;; create an alias
	mov	ax, 0ah
	int	31h

	mov	bx, ax			;; set arb to code
	lar	cx, ax
	shr	cx, 8
	or	cx, 8

	mov	ax, 9
	int	31h

	mov	es:[0], bx
	jmp	pFexit

newData:
	mov	bx, ax			;; para to selector
	mov	ax, 0002h
	int	31h
	mov	es:[0], ax
	jmp	pFexit

pFexit:
	ret
processFixup ENDP


;;======================================================================
;; Main routine for fixup
;;
;;
_fixup	PROC C	USES DI
	call	readFixupTable		;; rets count in ax, table in es
	or	ax, ax
	jz	fixupExit

	call	setupFixup

	mov	cx, ax
	xor	di, di
nextFU:
	call	processFixup
	add	di, 4
	loop	nextFU

	mov	ax, 1			;; free descriptor
	mov	bx, fixupSel
	int	31h

	mov	ah, 49h
	int	21h
fixupExit:
	ret
_fixup	ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;		Exception handlers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Macro to output a string
puts	MACRO str
	local over, slbl
	jmp	short over
slbl	db	str, '$'
over:
	lea	dx, slbl
	mov	ah, 9
	int	21h
	ENDM

;; Macro to output a hex value
hexOut	MACRO val
	mov	cx, val
	call	putHex
	ENDM

;; Macro to output a string followed by a hex value
putReg	MACRO str, r
	puts	str
	mov	cx, r
	call	putHex
	ENDM

;; Hex output routine
hexdigs db "0123456789ABCDEF"
putHex	PROC USES BX			;; output CX in hex
	mov	bx, cx			;;   use bx as working reg
	shr	bx, 12			;;   top nibble to right
	mov	dl, hexdigs[bx] 	;;   look up character
	mov	ah, 2			;;   send to DOS
	int	21h

	mov	bx, cx			;; original value to bx
	shr	bx, 8			;; 2nd nibble to right
	and	bx, 0fh 		;; mask off unwanted higher nibble
	mov	dl, hexdigs[bx] 	;; look up character
	mov	ah, 2			;; send to DOS
	int	21h

	mov	bx, cx			;; etc.
	shr	bx, 4
	and	bx, 0fh
	mov	dl, hexdigs[bx]
	mov	ah, 2
	int	21h

	mov	bx, cx
	and	bx, 0fh
	mov	dl, hexdigs[bx]
	mov	ah, 2
	int	21h

	ret
putHex	ENDP

;; Exception handler entry points
;;
;; This macro generates the exception handlers, each of which pushes
;; its ordinal value and jumps to the generic handler
;;
	IRP n, <00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F>
_exc&n&Handler:
	push	&n&H
	jmp	near ptr exceptionEntry
	ENDM
;;
;; Exception names - the generic handler uses this table to look up
;; the name of the exception that occurred
;;
x00nm	db	"Divide by Zero$"
x01nm	db	"Trace$"
x02nm	db	"?$"
x03nm	db	"Breakpoint$"
x04nm	db	"Overflow$"
x05nm	db	"Bounds$"
x06nm	db	"Invalid Opcode$"
x07nm	db	"Coprocessor (7)$"
x08nm	db	"Double Fault$"
x09nm	db	"Coprocessor (9)$"
x0anm	db	"Invalid TSS$"
x0bnm	db	"Segment not present$"
x0cnm	db	"Stack$"
x0dnm	db	"General Protection$"
x0enm	db	"Page Fault$"
x0fnm	db	"?$"
x10nm	db	"Coprocessor (16)$"

xNameTable:
	IRP n, <00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F>
	dw	offset x&n&nm
	ENDM

;;
;; Exception entry point table - this table contains the offset of each
;; handler - used to hook the vectors.
;;
xEntryTable:
	IRP n, <00,01,02,03,04,05,06,07,08,09,0A,0B,0C,0D,0E,0F>
	dw	offset _exc&n&Handler
	ENDM

;;
;; Install the default exception handlers for fatal exceptions
;;
_installHandlers PROC USES SI DI
	lea	si, xEntryTable
	xor	di, di
_iHhook:
	IRP n, <0, 1, 2, 3, 4, 5, 7>	;; don't handle these - DPMI is
	  cmp	di, n			;; supposed to pass them through
	  je	_iHnext 		;; to real mode
	ENDM

	mov	ax, 203h		;; set exception handler service
	mov	bx, di
	mov	cx, cs
	mov	dx, cs:[si]
	int	31h

_iHnext:
	add	si, 2
	inc	di
	cmp	di, 10h
	jne	_iHhook

	ret
_installHandlers ENDP


;; This structure defines the register structure in effect while the
;; generic handler runs
;;
eFrame STRUC
	efDS	dw	?
	efES	dw	?
	efDI	dw	?
	efSI	dw	?
	efBP	dw	?
	efXX	dw	?
	efBX	dw	?
	efDX	dw	?
	efCX	dw	?
	efAX	dw	?
	efxNum	dw	?
	efhRIP	dw	?
	efhRCS	dw	?
	efError dw	?
	efXIP	dw	?
	efXCS	dw	?
	efXFl	dw	?
	efXSP	dw	?
	efXSS	dw	?
eFrame ENDS

;;
;; The generic handler - dump registers and exit
;;
exceptionEntry PROC
	pusha					;; build frame
	push	es
	push	ds
	mov	bp, sp

	push	cs				;; ds <- cs
	pop	ds

	mov	bx, [bp].efxNum 		;; get exception number
	shl	bx, 1				;; make it word offset
	add	bx, offset xNameTable		;; look up name of exception
	mov	dx, [bx]

	mov	ah, 9				;; output it to  DOS
	int	21h

	putReg	" Exception at ", [bp].efXCS    ;; dump regs
	putReg	":",efXIP
	putReg	" Error code=", [bp].efError
	puts	<10,13>

	putReg	"SS=", [bp].efXSS
	putReg	" SP=", [bp].efXSP
	putReg	" DS=", [bp].efDS
	putReg	" ES=", [bp].efES
	putReg	" Flags=", [bp].efXFl

	puts	<10,13>
	putReg	"AX=", [bp].efAX
	putReg	" BX=", [bp].efBX
	putReg	" CX=", [bp].efCX
	putReg	" DX=", [bp].efDX
	putReg	" SI=", [bp].efSI
	putReg	" DI=", [bp].efDI
	putReg	" BP=", [bp].efBP
	puts	<10,13>

	mov	[bp].efXCS, cs				;; set frame to exit
	mov	[bp].efXIP, offset bye
	pop	ds
	pop	es
	popa
	add	sp, 2
	retf						;; get off host stack

bye:
	mov	ah, 4Ch 				;; and terminate
	int	21h
exceptionEntry ENDP

	end
