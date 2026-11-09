;
;       Program ScrDemo ( Chapter 11 )
;
	page    55,132
NewFunc equ     0E0h
CheckIn equ     0                       ; subfunction "check installation"
InAct   equ     0                       ; this value indicates "INACTIVE"
Act     equ     1Ch                     ; this value indicate "ACTIVE"

_Text   segment para public 'CODE'
	assume  cs:_Text
;====================  Resident data =====================================      
ActInd  db      Act                     ; activity indicator; if 0 - inactive
NumTick dw      0                       ; number of timer ticks since last key
MaxTick equ     546 ; 5460                      ; 5460 ticks = 5 minutes
BlankId db      0                       ; screen blank indicator; if 0 - not blankedA
Blanked equ     13h                     ; signature "screen is blanked"
;=====================  Resident code ====================================
NewInt9 proc    near                    ; additional handler for interrupt 09h
	mov     NumTick,0               ; key pressed - clear ticks counter
	cmp     BlankId,Blanked         ; is screen blanked?
	jne     ToOld9                  ; if not - nothing to do
	mov     BlankId,0               ; clear blank indicator
;===    Save register used      
	mov     SaveAX9,ax
	mov     SaveBX9,bx
;---    Restore VGA screen
	mov     ax,1200h                ; function 12h - set alternate function
	mov     bl,36h                  ; subfunction 32h - Enable/Disable refresh
	int     10h                     ; BIOS video service call
;===    Restore registers
	mov     bx,SaveBX9
	mov     bx,SaveBX9
;===    Pass the control to the standard handler of the interrupt 09h   
ToOld9:
	db      0EAh                    ; this is code for JMP FAR
OldOff9 dw      0                       ; here will be ofsset
OldSeg9 dw      0                       ; here will be segment
SaveAX9 dw      ?
SaveBX9 dw      ?
NewInt9 endp
;===
Handler proc    near                    ; additional handler for interrupt 1Ch
	cmp     ah,NewFunc              ; additional function of INT 1Ch?
	je      Addf                    ; new handler for that function
	cmp     ActInd,Act              ; is activity indicator set?
	je      Process                 ; if so, continue work
	jmp     ToOld1C                 ; if not, pass control to old handler
;===    Check whether the screen is already blanked
Process:cmp     BlankId,Blanked         ; is screen blanked?
	je      ToOld1C                 ; if so - nothing to do
;===    Has the time gone?
	inc     NumTick                 ; increase ticks counter
	cmp     NumTick,MaxTick         ; is it time to blank screen
	jl      ToOld1C                 ; if not, procced to standard handler
;===    Blank the screen        
	mov     BlankId,Blanked         ; set blank indicator
	mov     NumTick,0               ; clear ticks counter
;---    save registers
	mov     SaveAXC,ax
	mov     SaveBXC,bx
;---    Blank VGA screen        
	mov     ax,1201h                ; function 12h - set alternate function
	mov     bl,36h                  ; subfunction 32h - Enable/Disable refresh
	int     10h                     ; BIOS video service call
;---    Restore registers       
	mov     bx,SaveBXC
	mov     ax,SaveAXC
;===    Pass the control to the standard handler of the interrupt 1Ch   
ToOld1C:
	db      0EAh                    ; this is code for JMP FAR
OldOffC dw      0                       ; here will be ofsset
OldSegC dw      0                       ; here will be segment
;===    Process additional function of interrupt 1Ch
Addf:   mov     ah,CheckIn              ; value to be returned into AH
	mov     al,NewFunc
	iret                            ; return from handler   
SaveAXC dw      ?
SaveBXC dw      ?
	
Handler endp
;===    Installation part of the program
Start:  push    cs
	pop     ds                      ; DS = CS - data and code are the same 
;===    check whether the program is alrady installed
	mov     ah,NewFunc              ; new funtion of INT 1Ch
	mov     al,CheckIn              ; AL - installation check
	int     1Ch                     ; call interrupt 1Ch - timer tick
	cmp     ah,Checkin              ; does AH contain function number?
	je      Already                 ; if YES, handler is already installed
;===    installation part       
Install:mov     ax,351Ch                ; function 35h - Get Interrupt Vector
	int     21h                     ; DOS service call
	mov     cs:OldOffC,bx           ; save offsett of old handler for 1Ch
	mov     cs:OldSegC,es           ; save segment of old handler for 1Ch
	mov     al,09h                  ; AL - interrupt number, AH keeps 35h
	int     21h                     ; DOS service call
	mov     cs:OldOff9,bx           ; save offsett of old handler for 09h
	mov     cs:OldSeg9,es           ; save segment of old handler for 09h
	cli                             ; caution! critical part of program
	mov     dx,offset Handler       ; address of handler
	mov     ax,251Ch                ; function 25h - Set new handler
	int     21h                     ; DOS service call
	mov     dx,offset NewInt9       ; address of new INT 09 handler
	mov     al,09h                  ; AL - interrupt number, AH keeps 25h
	int     21h                     ; DOS service call
	sti                             ; critical part finishes here
;===    output the message "program is installed"
	mov     ActInd,Act              ; set activity indicator (TSR "ON")
	lea     dx,BegMsg               ; DX - address of message
	mov     ah,09h                  ; function 09 - output string
	int     21h                     ; DOS service call
;===    calculate the size of the resident part 
	lea     dx,INSTALL
	add     dx,110h                 ; PSP length plus 16 byte (insurance) 
	mov     cx,4                    ; set counter for shift
	shr     dx,cl                   ; 4 bits to the right - divide by 16
	mov     ax,3100h                ; 31h - terminate and state resident
	int     21h                     ; DOS service call
;===    Process situation "Resident part is already installed"
Already:mov     ah,09h                  ; function 09 - output text string
	lea     dx,AlrMsg               ; DS:DX - address of initial message
	int     21h                     ; DOS service call
;===    Exit program    
	mov     ax,4C01h                ; function 4Ch - terminate process
	int     21h                     ; DOS service call
;===    Data for non-resident part of the program
CR      equ     0Ah
LF      equ     0Dh
EndMsg  equ     24h
BegMsg  db      CR,LF,'Resident screen blanker - demo version '
CRLF    db      CR,LF,EndMsg
AlrMsg  db      CR,LF,'Error - program is already installed',CR,LF,EndMsg
_text   ends
	end     Start
