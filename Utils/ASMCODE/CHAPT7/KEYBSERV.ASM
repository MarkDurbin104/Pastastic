;
;       Program KeybServ ( Chapter 7 )
;
	option  oldmacros
	page    55,132
	NAME    KeybServ
	INCLUDE EXTENDA.INC
BiosDat segment at 40h
	org     17h
KbdFl1  db      ?
KbdFl2  db      ?
	org     96h
KbdFl3  db      ?
BiosDat ends

	CODESEG KeybServ
	DATASEG

	CLpublic <IsKbdEnh, GnumLock, GCapsLock, SNumLock, SCapsLock>
	CLstatic

$define FALSE   0000h
$define TRUE    0001h
KbdRDF  db      00h                     ; Read Character function number
KbdGSF  db      01h                     ; Get Status function number
KbdGFF  db      02h                     ; Get Flag function number
IndEnh  db      0
CNumL   equ     20h
CCapL   equ     40h

	WORKFUNCS

ChecKbd proc    near
;
;       This procedure checks whether an enhanced keyboard is being used.
;       All registers are preserved after returning from the procedure.
;       Result: The variable IndEnh (byte) is non-zero.
;
	push    es                      ; Save the segment register
	push    ax                      ; Save the accumulator register
	mov     ax,BiosDat              ; Address of BIOS data segment
	mov     es,ax                   ; Now ES points to the BIOS data
	mov     al,es:KbdFl3            ; Take the KEYBOARD FLAG 3 ( [0496h] )
	mov     IndEnh,al               ; Store it into the memory
	and     IndEnh,10h              ; Bit 5 - sign of the enhanced keyboard
	pop     ax                      ; Restore the accumulator
	pop     es                      ; Restore the segment register
	ret                             ; Return to the caller
ChecKbd endp

GetFl12 proc    near
;
;       This procedure extracts the keyboard flags 1 and 2
;       ( bytes 417h and 418h) from the BIOS data area and puts them
;       into AX register (AH - flag 1 , AL - flag 2).
;       All registers except the AX register are preserved after returning
;       from the procedure.
;
	push    es                      ; Save the segment register
	mov     ax,BiosDat              ; Address of BIOS data segment
	mov     es,ax                   ; Now ES points to the BIOS data
	mov     ah,es:KbdFl1            ; Take the KEYBOARD FLAG 1 ( [0417h] )
	mov     al,es:KbdFl2            ; Take the KEYBOARD FLAG 2 ( [0418h] )
	pop     es                      ; Restore the segment register
	ret                             ; Return to the caller
GetFl12 endp

PutFl12 proc    near
;
;       This procedure writes the values from the AX register
;       (AH - flag 1, AL - flag 2) into the keyboard flags 1 and 2
;       ( bytes 417h and 418h) in the BIOS data area.
;       All registers are preserved after returning from this procedure.
;
	push    es                      ; Save the segment register
	push    ax                      ; Save the work register
	mov     ax,BiosDat              ; Address of BIOS data segment
	mov     es,ax                   ; Now ES points to the BIOS data
	pop     ax                      ; Restore the work register
	mov     es:KbdFl1,ah            ; Put the KEYBOARD FLAG 1 ( [0417h] )
	mov     es:KbdFl2,al            ; Put the KEYBOARD FLAG 2 ( [0418h] )
	pop     es                      ; Restore the segment register
	ret                             ; Return to the caller
PutFl12 endp

	ENDWORK

	CLfunc  log IsKbdEnh
	CLcode
	mov     ax,FALSE                ; Set the keyboard type to STANDARD
	call    ChecKbd
	cmp     IndEnh,0                ; Is enhanced keyboard present?
	je      IsKbdEnhR               ; If not - return
	mov     ax,TRUE                 ; Set the keyboard type to ENHANCED
IsKbdEnhR:
	CLret   ax                      ; AX contains the value to be returned

	CLfunc  log GNumLock
	CLcode
	mov     dx,FALSE                ; Set the NumLock indicator to OFF
	call    GetFl12                 ; Get the Keyboard Flags
	test    ah,CNumL                ; Is the NumLock state on? (bit 5)
	jz      GNumLockR               ; If not - return
	mov     dx,TRUE                 ; Set the NumLock indicator to ON
GNumLockR:
	CLret   dx                      ; DX contains the value to be returned

	CLfunc  log GCapsLock
	CLcode
	mov     dx,FALSE                ; Set the CapsLock indicator to OFF
	call    GetFl12                 ; Get the Keyboard Flags
	test    ah,CCapL                ; Is the CapsLock state on?  (bit 6)
	jz      GCapsLockR              ; If not - return
	mov     dx,TRUE                 ; Set the CapsLock indicator to ON
GCapsLockR:
	CLret   dx                      ; DX contains the value to be returned

	CLfunc  log SNumLock <int SnlP>
	CLcode

	call    GetFl12                 ; Get the Keyboard Flags
	and     ah,not CNumL            ; Clear the NumLock state (bit 5)
	mov     dx,SnlP                 ; Copy the parameter to returned value
	cmp     dx,1                    ; Is it request for setting?
	jne     SNumLockR               ; If not - return
	or      ah,CNumL                ; Set the NumLock state (bit 5)
SNumLockR:
	call    PutFl12                 ; Write the Keyboard Flags
	CLret   dx                      ; DX contains the value to be returned

	CLfunc  log SCapslock <int SCplP>
	CLcode
	call    GetFl12                 ; Get the Keyboard Flags
	and     ah,not CCapL            ; Clear the CapsLock state (bit 6)
	mov     dx,SCplP                ; Copy the parameter to returned value
	cmp     dx,1                    ; Is this a request for setting?
	jne     SCapsLockR              ; If not - return
	or      ah,CCapL                ; Set the CapsLock state (bit 6)
SCapsLockR:
	call    PutFl12                 ; Write the Keyboard Flags
	CLret   dx                      ; DX contains the value to be returned

		END
