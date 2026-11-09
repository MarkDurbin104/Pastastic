;
;       Program UserHand ( Chapter 6 )
;
	page    55,132
CODE    SEGMENT PARA
	ASSUME  CS:CODE
ToOld:                  ;=== Passing control to the old handler
	db      0EAh    ; This is code for JMP FAR
OldOff  dw      0       ; Here will be ofsset
OldSeg  dw      0       ; Here will be segment

Handler label   byte            ; Start of new handler for INT 21
	cmp     ah,30h          ; Check function number
	jne     ToOld           ; If not a function 30h - to old handler
	mov     ax,0107h        ; Function 30h - Return the version number
	iret                    ; Return from handler

INSTALL:                        ; Installation starts here
	mov     ax,3521h        ; Get handler's address
	int     21h             ;    ES - segment, BX - offset
	cmp     bx,offset Handler ; Vector points to this handler ?
	je      already         ; If so - put message end exit
	mov     cs:OldOff,bx    ; Save offsett of old handler
	mov     cs:OldSeg,es    ; Save segment of old handler
	mov     ax,cs           ; Command segment of this program
	mov     ds,ax           ;    into DX (for setting handler)

	mov     dx,offset Handler      ; Address of handler
	mov     ax,2521h        ; Function 25h - Set new handler
	int     21h             ; Dos service call

	lea     dx,INSTALL
	add     dx,15
	mov     cx,4            ; Set counter for shift
	shr     dx,cl           ; 4 bits to the right - divide by 16
	add     dx,16           ; Add size of PSP in paragraphs
	mov     ax,3100h        ; Terminate and
	int     21h             ;     state resident

already:
	push    cs              ; Copy the value of CS
	pop     ds              ;     into the register DS
	lea     dx,loaded       ; DX := addres of message text
	mov     ax,0900h        ; Function 09 - output string
	int     21h             ; DOS service call
	mov     ax,4C01h        ; Function 4Ch - stop (return code 01)
	int     21h             ; DOS service call
loaded  db      'User handler is already loaded!',10,13,'$'
CODE    ENDS
END     INSTALL
