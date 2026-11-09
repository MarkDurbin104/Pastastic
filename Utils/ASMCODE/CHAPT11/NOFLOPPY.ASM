;       Program NoFloppy ( Chapter 11 )
;
	page    55,132
_Text   segment para public 'CODE'
	assume  cs:_Text
ToOld:                                  ;=== Passing control to the old handler
		db      0EAh            ; This is code for JMP FAR
OldOff          dw      0               ; Here will be ofsset
OldSeg          dw      0               ; Here will be segment

InActive        equ     0
Active          equ     13h
ActInd          db      0
PresInd         dw      1951            ; This code is an indicator of presence

Handler label   byte                    ; Beginning of new handler for INT 13
	cmp     ActInd,Active           ; Is the active mode set?
	jne     ToOld                   ; If not, jump to the olf handler
	cmp     dl,79h                  ; Is the floppy disk requested?
	ja      ToOld                   ; If not, jump to the old handler

	cmp     ah,03h                  ; Function 03 - write sector
	je      WriSec                  ;    new handler for function 03
	cmp     ah,0Bh                  ; Function 0B - write long sector
	je      WriSecL                 ;    new handler for function 0Bh
;       cmp     ah,0Fh                  ; Function 0Fh - write buffer
;       je      WriBuf                  ;    new handler for function 0Fh
	jmp     ToOld                   ; Others processed by old handler

WriSec:
WriSecL:
WriBuf:

	mov     ah,04h                  ; Function 04h - verify sector
	jmp     ToOld                   ; Pass this fiunction to the handler

;
;       End of new handler for interrupt 13h
;


;
;       NON - RESIDENT PART OF THE PROGRAM
;
ParmInd db      0
PspAddr dw      ?
Start:
	mov     PspAddr,es              ; Save address of PSP

	mov     ax,3513h                ; Get handler's address
	int     21h                     ;    ES - segment, BX - offset
	mov     ax,es:[bx-2]            ; Vector points to this handler ?
	cmp     ax,cs:PresInd
	je      Already                 ; If not - put message end exit  ========
Install:                                ; Installation starts here
	push    cs
	pop     ds
	mov     ah,09
	lea     dx,BegMsg
	int     21h
	mov     cs:OldOff,bx            ; Save offsett of old handler
	mov     cs:OldSeg,es            ; Save segment of old handler
	mov     ax,cs                   ; Command segment of this program
	mov     ds,ax                   ;    into DX (for setting handler)
	cli                             ; Caution! critical part of program
	mov     dx,offset Handler       ; Address of handler
	mov     ax,2513h                ; Function 25h - Set new handler
	int     21h                     ; Dos service call
	sti                             ; Critical part finishes here
	mov     ActInd,Active           ; Set activity ON
	lea     dx,Loaded               ; DX - address of message
	mov     ah,09h                  ; Function 09 - output string
	int     21h                     ; DOS service call
	lea     dx,INSTALL
	add     dx,15
	mov     cx,4                    ; Set counter for shift
	shr     dx,cl                   ; 4 bits to the right - divide by 16
	add     dx,16                   ; Add size of PSP
	mov     ax,3100h                ; Terminate and
	int     21h                     ;     state resident

NormExit:
	mov     al,00h                  ; Return code = 0
	jmp     FullExit                ; Print message and leave the program

ErrExit:
	mov     al,01h                  ; Return code = 1
FullExit:
	push    ax                      ; Save return code
	mov     ah,09h                  ; Function 09 - output string
	int     21h                     ; DOS service call
	pop     ax                      ; Restore return code
	mov     ah,4Ch                  ; Function 4Ch - stop, return code AL
	int     21h                     ; DOS service call

Already:
	push    cs                      ; Copy the value of CS
	pop     ds                      ;     into the register DS
	mov     ax,PspAddr              ; Addres of PSP into AX
	mov     es,ax                   ; ES now contains the segment of PSP
	mov     bl,byte ptr es:[80h]    ; Get length of parameters
	cmp     bl,1                    ; Are there parameters?
	jle     NoParm                  ; If not, set the indicater "NoParm"
	mov     bx,82h                  ; BX - the beginning of parameters
	cmp     byte ptr es:[bx],'/'
	jne     CheckS
SkipSep:
	inc     bx
	jmp     CheckLet
CheckS: cmp     byte ptr es:[bx],'-'
	je      SkipSep
CheckLet:
	cmp     byte ptr es:[bx],'?'
	je      Help
	and     byte ptr es:[bx],0DFh   ; Force the first letter uppercase
	cmp     byte ptr es:[bx],'H'
	je      Help
	cmp     byte ptr es:[bx],'O'    ; Is the first letter 'O'
	jne     InvParm                 ; If not - missing or invalid
	and     byte ptr es:[bx+1],0DFh ; Force the second letter uppercase
	cmp     byte ptr es:[bx+1],'N'  ; Is the second letter 'N'?
	je      TurnOn                  ; If not, check "OFF"
	cmp     byte ptr es:[bx+1],'F'  ; Is the second letter 'F'?
	jne     InvParm                 ; If not - invalid parameter
	and     byte ptr es:[bx+2],0DFh ; Force the second letter uppercase
	cmp     byte ptr es:[bx+2],'F'  ; Is the second letter 'N'
	jne     InvParm                 ;
	mov     ParmInd,InActive        ;
	lea     dx,MakeOff              ;
	jmp     Switch                  ;

TurnOn:
	lea     dx,MakeOn               ;
	mov     ParmInd,Active          ;
Switch:
	mov     ax,3513h                ; Get handler's address
	int     21h                     ;    ES - segment, BX - offset
	mov     al,Parmind              ;
	mov     byte ptr es:[bx-3],al   ;
	jmp     NormExit
NoParm:
	mov     ax,3513h                ; Get handler's address
	int     21h                     ;    ES - segment, BX - offset
	cmp     byte ptr es:[bx-3],Active
	jne     IsOff                   ;
	lea     dx,MakeOn               ;
	jmp     NormExit                ;
IsOff:  lea     dx,MakeOff              ;
	jmp     NormExit                ;
Help:   lea     dx,HelpTxt
	jmp     NormExit

InvParm:
	lea     dx,Invalid              ; DX := addres of message text
	jmp     ErrExit

CR      equ     0Ah
LF      equ     0Dh
EndMsg  equ     24h
BegMsg  db      CR,LF,'Floppy disk security system version 1.0',CR,LF
	db      'Copyright (C) 1992 V.B.Maljugin,  Russia, Voronezh',CR,LF
CRLF    db      CR,LF,EndMsg
Invalid db      'Error - invalid parameters',CR,LF,EndMsg
Loaded  db      'Floppy disk security system is installed!',CR,LF,EndMsg
MakeOn  db      'Floppy disk security system is now on',CR,LF,EndMsg
MakeOff db      'Floppy disk security system is now off',CR,LF,EndMsg
HelpTxt db      CR,LF
	db      CR,LF,'Program NoFloppy - Floppy Disk Security System        '
	db      CR,LF,'Use it to surprise people who would like to share     '
	db      CR,LF,'the information from your hard disk. ',CR,LF
	db      CR,LF,'Usage:',CR,LF,'======',CR,LF
	db      CR,LF,'NoFloppy [on | off | /? | /h | -? | -h] ',CR,LF
	db      CR,LF,'Parameters:',CR,LF,'-----------',CR,LF
	db      CR,LF,'on  - make the security system active                 '
	db      CR,LF,'off - make the security system inactive               '
	db      CR,LF,'rest of list - output this text                       '
	db      CR,LF,'                                                      '
	db      CR,LF,'Call program without parameter to report its          '
	db      CR,LF,'current state.                                        '
	db      CR,LF,'                                                      '
	db      CR,LF,'Note: first progam call shouldn''t contain parameters '
	db      CR,LF,'                                               '
	db      CR,LF,EndMsg
_text   ends
	end     Start
