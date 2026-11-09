;       Program CursKeep ( Chapter 11 )
;
	page    55,132
NewFunc equ     0E0h
CheckIn equ     51h                     ; subfunction "check installation"

_Text   segment para public 'CODE'
	assume  cs:_Text
;====================  Resident data =====================================      
NumFun  db      ?
SaveAX  dw      ?
SaveBX  dw      ?
SaveCX  dw      ?
SaveDX  dw      ?
;=====================  Resident code ====================================
Handler proc    near                    ; additional handler for interrupt 10h
	cmp     ah,NewFunc              ; additional function of INT 10h?
	je      Addf                    ; new handler for that function
Process:pushf
	mov     NumFun,ah               ; save number of function called
	cmp     ah,1                    ; is it function "Set Cursor Type"
	jne     VidCall                 ; if not call standard handler
	cmp     cl,8                    ; is cursor end line greater than 7
	jb      VidCall                 ; if not, call standard handler
	mov     cl,7                    ;   else replace cursor end line with 7
	shr     ch,1                    ;   else divide its value by 2
VidCall:call    dword ptr OldHand       ; call BIOS video interrupt
	cmp     NumFun,0                ; was it function "Set Video Mode"?
	je      ModCurs                 ; if it was, reprogram cursor type
	cmp     NumFun,11h              ; was it function "Load Character Set"?
	je      ModCurs                 ; if it was, reprogram cursor type
	iret                            ; return from interrupt handler
ModCurs:pushf
	mov     SaveAX,ax               ; save AX in memory, without using stack
	mov     SaveBX,bx               ; save BX in memory, without using stack
	mov     SaveCX,cx               ; save CX in memory, without using stack
	mov     SaveDX,dx               ; save DX in memory, without using stack
	
	mov     ah,03h                  ; function 03 - get cursor position
	mov     bx,0
	pushf
	call    dword ptr OldHand       ; call BIOS video interrupt

	mov     ah,ch
	and     ah,1Fh
	cmp     ah,6
	jb      ModCL
	and     ch,07h
	or      ch,06h
ModCL:  mov     cl,07h  
	mov     ah,01h                  ; function 01 - get cursor position
	pushf
	call    dword ptr OldHand       ; call BIOS video interrupt
	mov     dx,SaveDX
	mov     cx,SaveCX               ; restore AX from memory
	mov     bx,SaveBX
	mov     ax,SaveAX               ; restore CX from memory
	popf
NoMod:  iret                            ; return from interrupt handler
;===    Pass the control to the standard handler of the interrupt 10h   
ToOld10:jmp     dword ptr OldHand
OldHand dw      ?,?
OldOff  equ     OldHand[+0]
OldSeg  equ     OldHand[+2]
;===    Process additional function of interrupt 10h
Addf:   cmp     al,CheckIn              ; is installation check required?
	jne     ToOld10
Inst:   xchg    ah,al                   ; value to be returned into AX
	iret                            ; return from handler   
Handler endp

;===    Installation part of the program
BegInst label   byte
ComSeg  dw      ?
PSPAddr dw      ?
Start:  mov     PSPAddr,es              ; save address of PSP
	mov     sp,0F000h               ; set the stack
;===    Free the environment memory block
	mov     es,es:[2Ch]             ; address of environment block into ES 
	mov     ah,49h                  ; function 49h - free memory block
	int     21h                     ; DOS service call
;===
	mov     es,PspAddr              ; set ES to point to PSP
	mov     ComSeg,cs               ; save current command segment
	mov     ds,ComSeg               ; DS = CS - data and code are the same 
;===    check whether the program is alrady installed
	mov     ah,NewFunc              ; new funtion of INT 10h
	mov     al,CheckIn              ; AL - installation check
	int     10h                     ; call interrupt 10h - timer tick
	cmp     ah,Checkin              ; does AH contain function number?
	je      Already                 ; if YES, handler is already installed
;===    modifying IVT
	mov     ax,3510h                ; function 35h - Get Interrupt Vector
	int     21h                     ; DOS service call
	mov     OldOff,bx               ; save offsett of old handler for 10h
	mov     OldSeg,es               ; save segment of old handler for 10h
	mov     dx,offset Handler       ; address of handler
	mov     ax,2510h                ; function 25h - Set new handler
	int     21h                     ; DOS service call
;===    output the message "program is installed"
	lea     dx,BegMsg               ; DX - address of message
	mov     ah,09h                  ; function 09 - output string
	int     21h                     ; DOS service call
;===    calculate the size of the resident part 
	lea     dx,BegInst
	add     dx,110h                 ; PSP length plus 16 byte (insurance) 
	mov     cx,4                    ; set counter for shift
	shr     dx,cl                   ; 4 bits to the right - divide by 16
	mov     ax,3100h                ; 31h - terminate and state resident
	int     21h                     ; DOS service call
;===    Normal exit from program (return code 0)
NormEx: mov     al,0                    ; return code into AL
FullEx: mov     ah,4Ch                  ; function 4Ch - terminate process
	int     21h                     ; DOS service call
;===    Process situation "Resident part is already installed"
Already:mov     ah,09h                  ; function 09 - output text string
	lea     dx,AlrMsg
	int     21h                     ; DOS service call
	mov     al,1
	jmp     FullEx
;===    Data for non-resident part of the program
CR      equ     0Ah
LF      equ     0Dh
EndMsg  equ     24h 
BegMsg  db      CR,LF,'      The resident CGA-compatible cursor keeper.       '
	db      CR,LF,'Copyright (C) 1992 V.B.Maljugin,    Russia,    Voronezh'
CRLF    db      CR,LF,EndMsg
AlrMsg  db      CR,LF,'Program has been already installed!',CR,LF,EndMsg
_text   ends
	end     Start
