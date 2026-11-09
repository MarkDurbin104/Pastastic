;;
;; (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
;;
;; dpmi.inc - include file for DPMI.ASM

;;
;; basic typedefs
;;


ifdef ??version				;; if Borland
if  ??version lt 0300h			;; if TASM 2.0
	uChar	    equ BYTE
	uShort	    equ WORD
	uLong	    equ DWORD
	selector_t  equ WORD
else					;; else TASM 3.0 
	uChar	    typedef BYTE
	uShort	    typedef WORD
	uLong	    typedef DWORD
	selector_t  typedef WORD
endif
else					;; else MASM 6.0
	uChar	    typedef BYTE
	uShort	    typedef WORD
	uLong	    typedef DWORD
	selector_t  typedef WORD
endif

;;
;; descriptor structure
;;
descriptor_t	    STRUC   
	descLimit	    DW	    ?
	descBaseLo	    DW	    ?
	descBaseMid	    DB	    ?
	descArb		    DB	    ?
	descArb386	    DB	    ?
	descBaseHi	    DB	    ?
descriptor_t	    ENDS

;;
;; structure returned by DPMI Query Free Memory service
;;
freeMem_t	    STRUC   
	largeFree	    DD	    ?
	maxUnlocked	    DD	    ?
	maxLocked	    DD	    ?
	lineaize	    DD	    ?
	nUnlockedPages	    DD	    ?
	nFreePages	    DD	    ?
	nPhysicalPages	    DD	    ?
	freeLinearSpace	    DD	    ?
	pageFreeSize	    DD	    ?
	reserved	    DD	    3 DUP ( ? )
freeMem_t	    ENDS

;;
;; 16-bit DPMI exception frame
;;
excFrame	    STRUC   
	excErr   DW	    ?
	excIP    DW	    ?
	excCS    DW	    ?
	excFlags DW	    ?
	excSP    DW	    ?
	excSS    DW	    ?
excFrame	    ENDS

;;
;; Register structure for raw mode switch
;;
rawModeRegs_t	    STRUC   
	rawDS    DW	    ?
	rawES    DW	    ?
	rawSS    DW	    ?
	rawCS    DW	    ?
rawModeRegs_t	    ENDS

;;
;; Model sensitive macro to allow port to LARGE model (someday ...)
;;
ldptr	MACRO reg, ptrloc, segreg

IF @DataSize			;; if not small model
  ifb <segreg>
  	lds	reg, ptrloc
  else
	l&segreg reg, ptrloc	;;	load far ptr
  endif

ELSE				;; else small model
	mov	reg, ptrloc	
  ifnb <segreg>
  	push	ds
	pop	segreg
  endif

ENDIF
	ENDM


;; Load and store long macros
;;

ldlong	MACRO hi, lo, mem
	mov	lo, word ptr mem
	mov	hi, word ptr mem.2
	ENDM

stlong	MACRO mem, hi, lo
	mov	word ptr mem, lo
	mov	word ptr mem.2, hi
	ENDM

public C DPMIReleaseTimeSlice
public C DPMIGetCPUMode
public C DPMIObtainSwitchEntryPoint
public C DPMIEnterProtectedMode
public C DPMIAllocateDescriptors
public C DPMIFreeDescriptor
public C DPMIParaToSelector
public C DPMIGetSelectorDelta
public C DPMIGetSegmentBase
public C DPMISetSegmentBase
public C DPMIGetSegmentLimit
public C DPMISetSegmentLimit
public C DPMIGetSegmentAttributes
public C DPMISetSegmentAttributes
public C DPMICreateAlias
public C DPMIGetDescriptor
public C DPMISetDescriptor
public C DPMIAllocateSpecificDescriptor
public C DPMIAllocateDOSMemory
public C DPMIFreeDOSMemory
public C DPMIResizeDOSMemory 
public C DPMIGetRealInterruptVector
public C DPMISetRealInterruptVector
public C DPMIGetExceptionVector
public C DPMISetExceptionVector
public C DPMIGetProtInterruptVector
public C DPMISetProtInterruptVector
public C DPMIIssueRealInterrupt
public C DPMICallRealProcedure
public C DPMICallRealInterruptProcedure
public C DPMIAllocateRealCallBack
public C DPMIFreeRealCallBack
public C DPMIGetStateSaveRestoreProcs
public C DPMISaveOrRestoreState
public C DPMIGetRawSwitchProc
public C DPMIDoRawSwitch
public C DPMIGetVersion
public C DPMIGetFreeMemory
public C DPMIAllocateMemory
public C DPMIFreeMemory
public C DPMIResizeMemory
public C DPMILockRegion
public C DPMIUnlockRegion
public C DPMIMarkRealRegionPageable
public C DPMIRelockRealRegion
public C DPMIGetPageSize
public C DPMINominatePages
public C DPMIDiscardPageContents
public C DPMIMapPhysicalRegion
public C DPMITestDisableInts
public C DPMITestEnableInts
public C DPMITestInts
public C DPMIGetVendorEntryPoint
public C DPMISetWatchpoint
public C DPMIClearWatchpoint
public C DPMIGetWatchpointState
public C DPMIResetWatchpoint
public C getCS
public C getDS
