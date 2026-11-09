;       Program FSecret ( Chapter 11 )
;
	page    55,132
;
;       This program installs additional handlers for interrupt 13h
;
;       New function 0EFh of interrupt 13h has been added.
;       This function has 3 subfunctions:
;       00 - installation check
;       01 - activates the driver
;       02 - deactivates the driver
;       03 - report the driver state; returns the state in AH (1 - on, 2 - off)  
;       To call new function put its number into the AH register, 
;       the subfunction number into AL and call interrupt 13h
;
NewFunc equ     0E0h
CheckIn equ     0                       ; subfunction "check installation"
IdSwOn  equ     1                       ; subfunction "turn program on"
IdSwOff equ     2                       ; subfunction "turn program off"
RepSt   equ     3                       ; subfunction "report status"
IdUnIn  equ     4                       ; subfunction "get resident PSP address"
InAct   equ     0                       ; this value indicates "INACTIVE"
Act     equ     13h                     ; this value indicates "ACTIVE"

_Text   segment para public 'CODE'
	assume  cs:_Text
;====================  Resident data =====================================      
ActInd  db      Act                     ; activity indicator; if 0 - inactive
ResPSP  dw      ?                       ; addres of resident PSP
ResOff  dw      ?                       ; offset of resident part
ResSeg  dw      ?                       ; segment of resident part
;=====================  Resident code ====================================
Handler proc    near                    ; additional handler for interrupt 13h
	pushf
	cmp     ah,NewFunc              ; additional function of INT 13h?
	je      Addf                    ; new handler for that function
	cmp     ActInd,Act              ; is activity indicator set?
	jne     ToOld13                 ; if so, continue work
;===    Check whether the screen is already blanked
Process:cmp     dl,79h                  ; Is the floppy disk requested?
	ja      ToOld13                 ; If not, jump to the old handler
	cmp     ah,03h                  ; Function 03 - write sector
	je      RepCod                  ;    new handler for function 03
	cmp     ah,0Bh                  ; Function 0B - write long sector
	je      RepCod                  ;    new handler for function 0Bh
	jmp     ToOld13                 ; Others processed by old handler
;===    Process write commands
RepCod: cmp     ActInd,Act              ; Is the active mode set?
	jne     ToOld13                 ; If not, jump to the olf handler
	mov     ah,04h                  ; Function 04h - verify sector
;===    Pass the control to the standard handler of the interrupt 13h   
ToOld13:popf
	db      0EAh                    ; this is code for JMP FAR
OldOff  dw      0                       ; here will be ofsset
OldSeg  dw      0                       ; here will be segment
;===    Process additional function of interrupt 13h
Addf:   cmp     al,CheckIn              ; is installation check required?
	je      Inst
	cmp     al,IdSwOn               ; turn driver ON?
	je      SwOn
	cmp     al,IdSwOff              ; turn driver OFF?
	je      SwOff
	cmp     al,RepSt                ; report status?
	je      Report
	cmp     al,IdUnIn
	je      RetPSP
	jmp     ToOld13                 ; unknown command - pass to old handler
Inst:   mov     ah,CheckIn              ; value to be returned into AH
	jmp     ExHand                  ; exit handler
SwOn:   mov     ActInd,Act              ; set indicator to ACTIVE (ON)
	mov     ah,IdSwOn               ; value to be returned into AH
	jmp     ExHand                  ; exit handler
SwOff:  mov     ActInd,InACt            ; set indicator to INACTIVE (OFF)
	mov     ah,IdSwOff              ; value to be returned into AH
	jmp     ExHand                  ; exit handler
RetPSP: mov     ah,IdUnIn               ; value to be returned into AX
	mov     dx,ResPsp
	mov     es:[bx+0],dx            ; segment address of resident PSP
	mov     dx,OldOff
	mov     es:[bx+2],dx            ; offset addres of old handler
	mov     dx,OldSeg
	mov     es:[bx+4],dx            ; segment address of old handler
	mov     dx,Resoff
	mov     es:[bx+6],dx            ; offset addres of this handler
	mov     dx,ResSeg
	mov     es:[bx+8],dx            ; segment address of this handler
	jmp     ExHand                  ; exit handler
Report: mov     ah,IdSwOff              ; prepare "InActive" code for returning
	cmp     ActInd,Act              ; is activity indicator set?
	jne     ExHand                  ; if not, exit handler
	mov     ah,IdSwOn               ; return "Active" code
ExHand: mov     al,NewFunc              ; return additional signature in AL
	popf
	iret                            ; return from handler   
Handler endp
;===    Installation part of the program
BegInst label   byte
ParmInd db      0
PspAddr dw      ?
ComSeg  dw      ?
ResArea dw      5 dup (?)               ; buufer for subfunction "return PSP"
RetCode db      0
Start:  mov     PspAddr,es              ; save address of PSP
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
	mov     ah,NewFunc              ; new funtion of INT 13h
	mov     al,CheckIn              ; AL - installation check
	int     13h                     ; call interrupt 13h - timer tick
	cmp     ah,Checkin              ; does AH contain function number?
	je      Already                 ; if YES, handler is already installed
;===    output the initial message
	mov     ah,09                   ; function 09 - text string output
	lea     dx,BegMsg               ; DX - address of message
	int     21h                     ; DOS service call
	mov     ResPSP,es               ; save PSP of resident part
;===    modyfying IVT   
	mov     ax,3513h                ; function 35h - Get Interrupt Vector
	int     21h                     ; DOS service call
	mov     OldOff,bx               ; save offsett of old handler for 13h
	mov     OldSeg,es               ; save segment of old handler for 13h
	mov     ResOff,offset Handler   ; save offset of resident part
	mov     ResSeg,ds               ; save segment odf resident part
	cli                             ; caution! critical part of program
	mov     dx,ResOff               ; address of handler
	mov     ax,2513h                ; function 25h - Set new handler
	int     21h                     ; DOS service call
	sti                             ; critical part finishes here
;===    output the message "program is installed"
	mov     ActInd,Act              ; set activity indicator (TSR "ON")
	lea     dx,Loaded               ; DX - address of message
	mov     ah,09h                  ; function 09 - output string
	int     21h                     ; DOS service call
;===    calculate the size of the resident part 
	lea     dx,BegInst              ; address of installation part beginning
	add     dx,110h                 ; PSP length plus 16 byte (insurance) 
	mov     cx,4                    ; set counter for shift
	shr     dx,cl                   ; 4 bits to the right - divide by 16
	mov     ax,3100h                ; 31h - terminate and state resident
	int     21h                     ; DOS service call
;===    Normal exit from program (return code 0)
NormEx: mov     ds,ComSeg               ; restore DS (can be destroyed)
	mov     ah,09h                  ; function 09 - output string
	int     21h                     ; DOS service call
	mov     ah,4Ch                  ; function 4Ch - terminate process
	mov     RetCode,al              ; return code into AL
	int     21h                     ; DOS service call
;===    Process situation "Resident part is already installed"
Already:mov     es,PspAddr              ; addres of PSP into ES
	cmp     byte ptr es:[80h],1     ; are there parameters? 
	jle     NoParm                  ; if not, set the indicator "NoParm"
	mov     bx,82h                  ; BX - beginning of parameter string
	cmp     byte ptr es:[bx],'/'
	jne     CheckS
SkipSep:inc     bx
	jmp     ChkLtr
CheckS: cmp     byte ptr es:[bx],'-'
	je      SkipSep
ChkLtr: cmp     byte ptr es:[bx],'?'
	je      Help
	and     byte ptr es:[bx],0DFh   ; force first letter uppercase
	cmp     byte ptr es:[bx],'H'    ; is first letter 'H'?
	je      Help                    ; if so, process "HELP" 
	cmp     byte ptr es:[bx],'U'    ; is first letter 'U'?
	je      UnInst                  ; if so, process "UNINSTALL"    
	cmp     byte ptr es:[bx],'O'    ; is first letter 'O'?
	jne     InvParm                 ; if not - missing or invalid
	and     byte ptr es:[bx+1],0DFh ; force second letter uppercase
	cmp     byte ptr es:[bx+1],'N'  ; is second letter 'N'?
	je      TurnOn                  ; if so, process "ON"
	cmp     byte ptr es:[bx+1],'F'  ; is second letter 'F'?
	jne     InvParm                 ; if not - invalid parameter
	and     byte ptr es:[bx+2],0DFh ; force third letter uppercase
	cmp     byte ptr es:[bx+2],'F'  ; is third letter 'F'?
	jne     InvParm                 ; if not, process "INVALID PARMS"
	mov     al,IdSwOff              ; code for subfunction "OFF" into AL
	jmp     Switch                  ; switch program state
;===    deinstall new handler   
Uninst: mov     ah,NewFunc              ; AH - code for additional function
;---    get information about the resident part (PSP, segment, offset)
	mov     al,IdUnIn               ; AL - subfunction "deinstallation"
	mov     es,ComSeg               ; ES points to current segment
	mov     bx,offset ResArea       ; ES:BX - buffer for subf. "Return PSP"
;---    get information about current handler of interrupt 13   
	int     13h                     ; call new handler of interrupt 13h
	mov     ax,3513h                ; function 35h - get interrupt vector 
	int     21h                     ; DOS service call
;---    is the resident part of this program last handler of interrupt 13h?     
	mov     ax,es                   ; AX - segment of current handler
	cmp     ax,ResArea[8]           ; segment of resident part 
	jne     Over                    ; if not equal - res. part overriden
	cmp     bx,ResArea[6]           ; compare offsets
	jne     Over                    ; if not equal - res. part overriden 
;---    free memory occupied be the resident part of TSR        
	mov     es,ResArea[0]           ; address of resident PSP into ES
	mov     ah,49h                  ; function 49h - free memory block
	int     21h                     ; DOS service call
;---    make previous handler of interrupt 13 current 
	mov     ds,ResArea[4]           ; DS - segment of old handler
	mov     dx,ResArea[2]           ; dx - offset of old handler
	mov     ax,2513h                ; function 25h - set interrupt vector
	int     21h                     ; DOS service call
	mov     ds,ComSeg               ; restore data segment register
;---    leave program
	lea     dx,UnInMsg              ; DS:DX - point to message "uninstalled"
	jmp     NormEx                  ; leave program
;---    process situation "TSR overriden"
Over:   lea     dx,OverMsg              ; DS:DX - point to message "overriden"
	jmp     NormEx                  ; leave program
;===    Turn the program ON
TurnOn: mov     al,IdSwOn               ; subfunction "Turn ON"
;===    This block switches program state       
Switch: mov     ah,NewFunc              ; AH - code for additional function 
	int     13h                     ; call new handler of interrupt 13h
;===    Process the situation "no parameter"    
NoParm: mov     ah,NewFunc              ; AH - code for additional function
	mov     al,RepSt                ; AL - subfunction "Report Status"
	int     13h                     ; call new handler of interrupt 13h     
	lea     dx,MakeOff              ; DS:DX - addres of message "Turned OFF"
	cmp     ah,IdSwOn               ; is code "Turned ON" returned? 
	jne     FinTst                  ; if not, exit; "OFF" will be output
	lea     dx,MakeOn               ; DS:DX - addres of message "Turned ON"
FinTst: jmp     NormEx                  ; to print message and exit
;===    Output help message     
Help:   lea     dx,BegMsg               ; DS:DX - address of initial message    
Help2:  mov     ah,09h                  ; function 09 - output text string
	int     21h                     ; DOS service call
	lea     dx,ParmTxt              ; DS:DX - address of HELP message
	jmp     NormEx                  ; to print message and exit
;===    Process the sitution "INVALID PARAMETERS"
InvParm:lea     dx,Invalid              ; DS:DX addres of message "Invalid"
	mov     RetCode,1               ; return code = 1
	jmp     Help2                   ; to print message and exit
;===    Data for non-resident part of the program
CR      equ     0Ah
LF      equ     0Dh
EndMsg  equ     24h 
Invalid db      CR,LF,'Can not interprete parameters specified.'
	db      CR,LF,'The valid form of command line is:',CR,LF,EndMsg
BegMsg  db      CR,LF,'The floppy disk security system  version 2.5   29.07.92'
	db      CR,LF,'Copyright (C) 1992 V.B.Maljugin,    Russia,    Voronezh'
CRLF    db      CR,LF,EndMsg
Loaded  db      CR,LF,'Program is installed successfully',CR,LF,EndMsg
MakeOn  db      CR,LF,'The floppy disk guard is now ACTIVE',CR,LF,EndMsg
MakeOff db      CR,LF,'The floppy disk guard is now INACTIVE',CR,LF,EndMsg
HelpTxt db      CR,LF,CR,LF, 'Call: '
ParmTxt db      CR,LF,'FSecret [on | off | u | /? | /h | -? | -h] ',CR,LF
	db      CR,LF,'Parameters:                                           '
	db      CR,LF,'on  - make the floppy disk guard active               '
	db      CR,LF,'off - make the floppy disk guard inactive             '
	db      CR,LF,'u   - uninstall the floppy disk guard; FSecret must be'
	db      CR,LF,'      the last handler for interrupt 13h'
	db      CR,LF,'rest of list - output this text.',CR,LF
	db      CR,LF,'First call of the program always means installation.'
	db      CR,LF,'Call this program without parameters to determine its '
	db            'current state.', CR,LF,EndMsg
OverMsg db      CR,LF,'Program FSecret is not last handler of interrupt 13h.'
	db      CR,LF,'Deinstallation denied. Please deinstall program manually'
	db      CR,LF,EndMsg
UnInMsg db      CR,LF,'Program FSecret uninstalled.',EndMsg     
_text   ends
	end     Start
