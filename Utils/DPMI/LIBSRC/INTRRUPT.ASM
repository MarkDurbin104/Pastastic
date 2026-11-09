;;
;; (c) Copyright 1992, Qualitas, Inc. All Rights Reserved
;;
;; Interrupt dispatching for DPMI class library

;; The basic idea is that there is an entry point for each interrupt
;; (real and protected), for up to 16 callbacks, and for the processor
;; exceptions.  The entry points transfer control to a dispatcher that
;; looks up the actual address of the handler in a table, and calls it
;; after switching to a local stack.   Stacks are allocated in a stack-like
;; manner, i.e., each entry to the dispatcher grabs a new stack, and
;; releases it upon exit.  Only when there are recursive entries to the
;; dispatcher (for any handler) does more than one stack come into play.
;;

nStacks		equ 6
intStackSize 	equ 512

	public C initDispatch
	public C setDispatch
	public C setXDispatch
	public C setCBDispatch
	public C callHandler
	public C callXHandler

.286p
.model	small, C

.data
;;
;; The dispatch tables hold the address of the actual handler
;;
interruptDispatchTable 		label 	word
	realDispatchTable	dw	256 dup (?)
	protDispatchTable	dw	256 dup (?)
	callBackDispatchTable	dw	16 dup (?)
	exceptionDispatchTable	dw	16 dup (?)

interruptStacks		db Nstacks*intStackSize dup (?)
currentStack		dw 0
realCS			dw ?

.code
dataSel		dw	0		;; selector for DGROUP
codeAlias	dw	0		;; data alias of code segment
realDS		dw	0		;; real paragraph of DGROUP

reg	UNION
	l	dd	?
	s	dw	?
reg	ENDS

dpmiRegs_t STRUC			;; the dpmi register structure
	rEDI    reg	    <>
	rESI    reg	    <>
	rEBP    reg	    <>
	rRES	reg	    <>
	rEBX    reg	    <>
	rEDX    reg	    <>
	rECX    reg	    <>
	rEAX    reg	    <>
	rFlags  DW	    ?
	rES	DW	    ?
	rDS	DW	    ?
	rFS	DW	    ?
	rGS	DW	    ?
	rIP	DW	    ?
	rCS	DW	    ?
	rSP	DW	    ?
	rSS	DW	    ?
dpmiRegs_t ENDS


excFrame	    STRUC   		;; 16-bit DPMI exception frame
	excErr	 DW	    ?
	excIP    DW	    ?
	excCS    DW	    ?
	excFlags DW	    ?
	excSP    DW	    ?
	excSS    DW	    ?
excFrame	    ENDS


iFrame	STRUC			;; frame pushed by dispatcher (pusha ...)
	iFes	dw	?
	iFds	dw	?
	iFdi	dw 	?
	iFsi	dw	?
	iFbp	dw	?
	iFxx	dw	?
	iFbx	dw	?
	iFdx	dw	?
	iFcx	dw	?
	iFax	dw	?
	iFnret	dw	?
	iFip	dw	?
	iFcs	dw	?
	iFflags	dw	?
iFrame	ENDS

;;
;; The entry tables hold the code invoked by the DPMI host when a
;; handled event occurs.  Each entry calls the appropriate dispatcher,
;; pushing an identifying return address as it calls.
;;
interruptEntryTable	label	near
	realEntryTable	label	near
	REPT 256
		call dispatchIntr
		nop
	ENDM
	protEntryTable	label	near
	REPT 256
		call dispatchIntr
		nop
	ENDM

callBackEntryTable label near
	REPT 16
		call dispatchCallBack
		nop
	ENDM
exceptionEntryTable label near
	REPT 16
		call dispatchException
		nop
	ENDM

;;
;; set up local information needed for dispatch
;;
initDispatch	PROC  C
	mov	ax, 0ah			;; get data alias for code segment
	mov	bx, cs
	int	31h
	mov	es, ax
	mov	es:[codeAlias], ax
	mov	es:[dataSel], ds

	mov	ax, 6			;; get base of data segment
	mov	bx, ds
	int	31h
	shr	dx, 4
	shl	cx, 12
	or	dx, cx
	mov	es:[realDS], dx

	mov	ax, 6			;; get base of code segment
	mov	bx, cs
	int	31h
	shr	dx, 4
	shl	cx, 12
	or	dx, cx
	mov	realCS, dx

	ret
initDispatch	ENDP	

;; The SetDispatch routines (setDispatch, setCBDispatch, and setXDispatch)
;; take as arguments the ordinal identifier (e.g. exception number), and the
;; address of the desired handler.  They return the far ptr that serves
;; as the vector to be passed to the DPMI host (this vector points into one
;; of the entry tables.  The handler address is stored in a dispatch table.
;;
;; setDispatch and setXDispatch write back the previous dispatch table
;; contents so that chained handlers can be successfully called through
;; the dispatch mechanism.
;;
setDispatch	PROC C USES SI, intNum:WORD, vector:PTR, RorP:word, pDisp:PTR
	xor	bx, bx
	mov	bl, byte ptr intNum
	cmp	RorP, 0
	jz	skipAdd
	add	bx, 256
skipAdd:
	shl	bx, 1

	mov	ax, vector
	mov	si, pDisp
	mov	cx, interruptDispatchTable[bx]
	mov	[si], cx
	mov	word ptr interruptDispatchTable[bx], ax
	
	shl	bx, 1
	mov	ax, offset interruptEntryTable
	add	ax, bx

	cmp	RorP, 0
	jz	retRealCS

	mov	dx, cs
	ret

retRealCS:
	mov	dx, realCS
	ret
setDispatch	ENDP

;; set call-back dispatch
;;
setCBDispatch	PROC C cbNumber:WORD, vector:PTR
	xor	bx, bx
	mov	bl, byte ptr cbNumber
	shl	bx, 1

	mov	ax, vector
	mov	word ptr callBackDispatchTable[bx], ax
	
	shl	bx, 1
	mov	ax, offset callBackEntryTable
	add	ax, bx

	mov	dx, cs
	ret
setCBDispatch	ENDP

;; set exception dispatch
;;
setXDispatch	PROC C USES SI, xNumber:WORD, vector:PTR, prevDisp:PTR
	xor	bx, bx
	mov	bl, byte ptr xNumber
	shl	bx, 1

	mov	ax, vector
	mov	si, prevDisp
	mov	cx, word ptr exceptionDispatchTable[bx]
	mov	[si], cx
	mov	word ptr exceptionDispatchTable[bx], ax
	
	shl	bx, 1
	mov	ax, offset exceptionEntryTable
	add	ax, bx

	mov	dx, cs
	ret
setXDispatch	ENDP

;;
;; Dispatch interrupt
;;
;; This routine dispatches real and protected mode interrupts (i.e. the
;; code executes in both modes).
;;
dispatchIntr PROC near
	pusha				;; save state build iFrame
	push	ds
	push	es

	mov	bp, sp			
	mov	ax, [bp].iFnret		;; determine which DS to load
	cmp	ax, offset protEntryTable
	ja	loadProtDS

	mov	ds, cs:[realDS]		;; use real DS
	jmp	setupStack

loadProtDS:
	mov	ds, cs:[dataSel]	;; load ds with DGROUP

setupStack:
	inc	currentStack		;; allocate stack 
 	mov	ax, currentStack	

					;; calc new sp
	mov	cx, intStackSize	;;  = currentStack*intStackSize +
	mul	cx			;;    &interruptStacks
	lea	bx, interruptStacks
	add	bx, ax			;; bx is new sp

	mov	ax, sp			;; save this ss:sp in cx:ax
	mov	cx, ss
	mov	dx, ds			;; switch stacks
	mov	ss, dx
	mov	sp, bx
	push	cx			;; save ss:sp
	push	ax

	mov	bp, sp
	les	di, [bp]		;; es:di points to iFrame
					
	push	es:[di].iFcs		;; push a dpmiRegs_t onto stack
	push	es:[di].iFip
	push	0			;; gs
	push	0			;; fs
	push	es:[di].iFds
	push	es:[di].iFes
	push	es:[di].iFflags
	push	0
	push	es:[di].iFax
	push	0
	push	es:[di].iFcx
	push	0
	push	es:[di].iFdx
	push	0
	push	es:[di].iFbx
	push	0
	push	0
	push	0
	push	es:[di].iFbp
	push	0
	push	es:[di].iFsi
	push	0
	push	es:[di].iFdi

	mov	bx, es:[di].iFnret	;; where are we coming from
	sub	bx, offset interruptEntryTable+3
	shr	bx, 1
	call	interruptDispatchTable[bx]

	les	di, [bp]		;; es:di points to iFrame
	
	pop	es:[di].iFdi		;; pop dpmiRegs_t to original stack
	pop	ax
	pop	es:[di].iFsi
	pop	ax
	pop	es:[di].iFbp
	pop	ax
	pop	ax
	pop	ax
	pop	es:[di].iFbx
	pop	ax
	pop	es:[di].iFdx
	pop	ax
	pop	es:[di].iFcx
	pop	ax
	pop	es:[di].iFax
	pop	ax
	pop	es:[di].iFflags
	pop	es:[di].iFes
	pop	es:[di].iFds
	pop	ax
	pop	ax
	pop	es:[di].iFip
	pop	es:[di].iFcs

	push	es			;; switch back to original stack
	pop	ss	
	mov	sp, di

	dec	currentStack
	pop	es			;; restore state and exit
	pop	ds
	popa
	add	sp, 2
	iret
dispatchIntr ENDP

;; Dispatch call-back
;;
dispatchCallBack PROC C  
	pusha				;; save state - set up iFrame
	push	ds
	push	es

	mov	bp, sp
	
	mov	ax, ds:[si]
	mov	es:[di].rIP, ax
	mov	ax, ds:[si].2
	mov	es:[di].rCS, ax 
	add	es:[di].rSP, 4
	
	mov	ds, cs:[dataSel]	;; load ds with DGROUP

	inc	currentStack
 	mov	ax, currentStack	;; cycle stack sequence

					;; calc new sp
	mov	cx, intStackSize	;;  = currentStack*intStackSize +
	mul	cx			;;    &interruptStacks
	lea	bx, interruptStacks
	add	bx, ax			;; bx is new sp

	mov	ax, sp			;; save this ss:sp in cx:ax
	mov	cx, ss
	mov	dx, ds			;; switch stacks
	mov	ss, dx
	mov	sp, bx
	push	cx			;; save ss:sp
	push	ax

	mov	bp, sp
	les	di, [bp]		;; es:di points to iFrame

	mov	dx, es:[di].iFnret
	sub	dx, offset callBackEntryTable+3
	shr	dx, 1

	mov	si, es:[di].iFdi
	mov	es, es:[di].iFes

	mov	cx, size dpmiRegs_t
	mov	bx, cx
	shr	cx, 1
pushRegs:
	sub	bx, 2
	push	es:[si+bx]
	loop	pushRegs

	mov	bx, dx
	call	callBackDispatchTable[bx]	;; call call back handler

	mov	ds, cs:[dataSel]
	les	di, [bp]		;; es:di points to iFrame

	mov	si, es:[di].iFdi	;; es:si points to dpmiRegs_t
	mov	es, es:[di].iFes

	mov	cx, size dpmiRegs_t/2
	xor	bx, bx
popRegs:
	pop	es:[si+bx]
	add	bx, 2
	loop	popRegs


	push	[bp+2]			;; switch back to original stack
	pop	ss	
	mov	sp, di

	dec	currentStack
	pop	es			;; restore state and exit
	pop	ds
	popa
	add	sp, 2
	iret
dispatchCallBack ENDP


;;
;; Dispatch exception
;;
dispatchException PROC
	pusha				;; save state - setup iFrame
	push	ds
	push	es
	mov	bp, sp

	mov	ds, cs:[dataSel]	;; load ds with DGROUP

	inc	currentStack
 	mov	ax, currentStack	;; cycle stack sequence
					;; calc new sp
	mov	cx, intStackSize	;;  = currentStack*intStackSize +
	mul	cx			;;    &interruptStacks
	lea	bx, interruptStacks
	add	bx, ax			;; bx is new sp

	mov	ax, sp			;; save this ss:sp in cx:ax
	mov	cx, ss
	mov	dx, ds			;; switch stacks
	mov	ss, dx
	mov	sp, bx
	push	cx			;; save ss:sp
	push	ax

	mov	bp, sp
	les	di, [bp]		;; es:di points to iFrame

	mov	bx, es:[di].iFnret
	sub	bx, offset exceptionEntryTable+3
	shr	bx, 1
	mov	dx, exceptionDispatchTable[bx]

	mov	bx, size iFrame+ size excFrame - 2
	mov	cx, size excFrame
	shr	cx, 1

pushXFrame:
	sub	bx, 2
	push	es:[di+bx]
	loop	pushXFrame

				;; push dpmiRegs_t to reflect iFrame state
	push	0		;; SS:SP null
	push	0
	push	0		;; CS:IP null
	push	0
	
	push	0		;; gs
	push	0		;; fs
	push	es:[di].iFds
	push	es:[di].iFes
	push	0		;; flags
	push	0
	push	es:[di].iFax
	push	0
	push	es:[di].iFcx
	push	0
	push	es:[di].iFdx
	push	0
	push	es:[di].iFbx
	push	0
	push	0
	push	0
	push	es:[di].iFbp
	push	0
	push	es:[di].iFsi
	push	0
	push	es:[di].iFdi

	push	offset continue
	push	dx
	retn

continue:
	mov	bp, sp
	add	bp, size excFrame + size dpmiRegs_t
	les	di, [bp]		;; es:di points to iFrame

	pop	es:[di].iFdi		;; pop dpmiRegs_t to original stack
	pop	ax
	pop	es:[di].iFsi
	pop	ax
	pop	es:[di].iFbp
	pop	ax
	pop	ax
	pop	ax
	pop	es:[di].iFbx
	pop	ax
	pop	es:[di].iFdx
	pop	ax
	pop	es:[di].iFcx
	pop	ax
	pop	es:[di].iFax
	pop	ax
	pop	es:[di].iFflags
	pop	es:[di].iFes
	pop	es:[di].iFds
	add	sp, 6*2

	mov	bx, size iFrame-2

	pop	es:[di+bx].excErr
	pop	es:[di+bx].excIP
	pop	es:[di+bx].excCS
	pop	es:[di+bx].excFlags
	pop	es:[di+bx].excSP
	pop	es:[di+bx].excSS

	push	[bp+2]			;; switch back to original stack
	pop	ss	
	mov	sp, di

	dec	currentStack
	pop	es			;; restore state and exit
	pop	ds
	popa
	add	sp, 2
	retf
dispatchException ENDP


;;
;;  Call previous interrupt handler - used for both real and protected
;;  mode callPrevious members.
;;
;;  Restores the register state in pRegs, and passes control to the
;;  handler indicated by the handler argument
;;
callHandler PROC C USES SI DI DS ES, pRegs:PTR, handler:FAR PTR
	push	bp
	pushf					; push fake iret frame
	push	cs				;   to regain control
	push	offset cHret			;   after invoking handler

	push	word ptr handler+2		; push handler address
	push	word ptr handler		;   will retf to it

	mov	bx, pRegs			; push regs state as if pusha
	push	[bx].rDS
	push	[bx].rES
	push	[bx].rEAX.s
	push	[bx].rECX.s
	push	[bx].rEDX.s
	push	[bx].rEBX.s
	push	[bx].rRES.s
	push	[bx].rEBP.s
	push	[bx].rESI.s
	push	[bx].rEDI.s

	popa					; restore register state
	pop	es
	pop	ds
	retf					; call handler

cHret:						; handler returns here
	pusha					; capture result state
	push	ds
	push	es

	mov	bp, sp				; restore local frame
	mov	bp, [bp+20]
	mov	bx, pRegs
	push	ss
	pop	ds

	pop	[bx].rES			; pop result state to 
	pop	[bx].rDS			;   register structure
	pop	[bx].rEDI.s
	pop	[bx].rESI.s
	pop	[bx].rEBP.s
	pop	[bx].rRES.s
	pop	[bx].rEBX.s
	pop	[bx].rEDX.s
	pop	[bx].rECX.s
	pop	[bx].rEAX.s

	pop	bp

	ret				
callHandler ENDP

;;
;; Call previous exception handler
;;
callXHandler PROC C USES SI DI DS ES, dRegs:PTR, excFr:PTR, handler:FAR PTR
	push	bp

	mov	bx, excFr
	push	[bx].excSS			;; push the exception frame
	push	[bx].excSP
	push	[bx].excFlags
	push	[bx].excCS
	push	[bx].excIP
	push	[bx].excErr

	push	cs				;; push fake retf frame to
	push	offset cXHret			;;   to regain control after
						;;   invoking handler
	push	word ptr handler+2		;; push handler address
	push	word ptr handler		;;   will retf to it

	mov	bx, dRegs			;; push reg state as if pusha
	push	[bx].rDS
	push	[bx].rES
	push	[bx].rEAX.s
	push	[bx].rECX.s
	push	[bx].rEDX.s
	push	[bx].rEBX.s
	push	[bx].rRES.s
	push	[bx].rEBP.s
	push	[bx].rESI.s
	push	[bx].rEDI.s

	popa					;; restore register state
	pop	es
	pop	ds
	retf					;; call handler

cXHret:
	mov	bp, sp
	mov	bp, [bp+size excFrame]		;; restore bp
	mov	bx, excFr
	pop	[bx].excErr			;; pop any frame changes by
	pop	[bx].excIP			;;   previous handler
	pop	[bx].excCS
	pop	[bx].excFlags
	pop	[bx].excSP
	pop	[bx].excSS

	pop	bp

	ret
callXHandler ENDP

	end
