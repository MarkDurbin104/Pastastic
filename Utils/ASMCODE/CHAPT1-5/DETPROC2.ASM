;
;       Program DetProc2 ( Chapter 3 )
;
page 55,132
;       This  program  tells  you what microprocessor has
;       your computer.   You  can  use  this  program  to
;       organize  quite  sophisticated  batch-files which
;       work  in  different  ways   depending   on   your
;       microprocessor    type.    The   program   passes
;       information to the another using the DOS  feature
;       called  Return  Code  and also puts message for a
;       user.   The  meanings  of  return  codes  are  as
;       follows:
;
;       0 - you have an i8086/i8088 processor;
;       1 - you have an i80186/i80188 processor;
;       2 - you have an i80286 processor;
;       3 - you have an i80386 processor;
;
.model  small
.stack
.data
MsgText db      'You have an '
ProcId1 db      'i80'
Procid2 db      'xxx'
	db      ' microprocessor.'
	db      '$'
i86     db      '86 '
i186    db      '186'
i286    db      '286'
i386    db      '386'
.code   
.startup
	push    ds              ; push data segment register onto stack
	pop     es              ; both ES an DS now point to DATA segment
;===    Try to clear bit 15 (to put 0 into it)
	mov     dx,0            ; Zero in DX
	push    dx              ; Store DX onto stack
	popf                    ; Read stored value into flags
	pushf                   ; Store flags onto stack
	pop     dx              ; Read stored flags into DX
	shl     dh,1            ; If bit 15 is set, CF=1
	jb      Less286         ; 8086 or 80186
;===    Processor is 286 or above
	mov     dx,7000h        ; Bits 12-14 of DX are set
	push    dx              ; Store DX onto stack
	popf                    ; Read stored value into flags
	pushf                   ; Store flags onto stack
	pop     ax              ; Read stored flags into DX
	and     ax,dx           ; If bits 12-14 are not copied
	jz      Is286           ;    processor is 80286
;===    Processor 386 or above
	lea     si,i386         ; Address of text "386" to build up message
	mov     al,3            ; Set return code to 3
	jmp     Finish          ;    and exit the program
;===    Processor is 8086 or 80186
Less286:lea     si,i86          ; Address of text "86 "  to build up message
	mov     ax,1            ; Set return code to 0
	mov     cx,32           ; Shift counter = 32
	shl     ax,cl           ; Shift AX to the left 32 times
				;    80186/80186 does not fulfil this well
				;    so if AX isn't zero, processor is 80186/80188
;===    This is the end of program
Finish: push    ax              ; Save the return code
	mov     cx,3            ; Length of processor identifier
	cld                     ; Set increasing addresses for MOVSB
	lea     di,ProcId2      ; Target for processor ident
rep     movsb                   ; Insert the processor identifier
				;     into the message text
	lea     dx,MsgText      ; Address of message text
	mov     ah,9            ; Service 09 - output string
	int     21h             ; Dos service call
	pop     ax              ; Restore the return code
	mov     ah,4Ch          ; Service 4Ch - terminate
	int     21h             ; Dos service call
;===    Processor is 80286
Is286:  lea     si,i286         ; Address of text "286" to build up message
	mov     al,2            ; Set return code to 2
	jmp     Finish          ;    and exit the program
	end
