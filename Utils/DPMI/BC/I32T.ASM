.386p
locals


_DATA segment dword public 'DATA' use32
	assume cs:_DATA

dummy	proc near

@@startThunk		label byte

	PUBLIC	__interrupt32Thunk

__interrupt32Thunk	label byte

	push	eax
	push	ebx
	push	ecx
	push	edx
	push	es
	push	ds
	push	esi
	push	edi
	push	ebp

	mov    	ds, word ptr cs:[012345678h]

	PUBLIC	__I32TdsLoadLabel
__I32TdsLoadLabel	EQU $ - @@startThunk - 4

	db	0e8h
	dd	0

	PUBLIC	__I32TcallLabel

__I32TcallLabel		EQU $ - @@startThunk - 4

	pop	ebp
	pop	edi
	pop	esi
	pop	ds
	pop	es
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax

	cmp	dword ptr chainOffset, 0
	PUBLIC	__I32TchainCmp
__I32TchainCmp		EQU $ - @@startThunk - 5
	jne	@@chain
@@iret:
	iret

@@chain:
	jmp	fword ptr [chainOffset]

	PUBLIC	__I32TchainLabel
__I32TchainLabel	EQU $ - @@startThunk - 4

	PUBLIC	__I32TchainOffset
__I32TchainOffset	EQU $ - @@startThunk

chainOffset	label	dword
	dd	0

	PUBLIC	__I32TchainSel
__I32TchainSel		EQU $ - @@startThunk
	dw	0

	PUBLIC	__interrupt32ThunkSize

__interrupt32ThunkSize	EQU $ - @@startThunk

dummy	endp

_DATA ends

end

