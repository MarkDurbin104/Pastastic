;
;       Program ScrBlank ( Chapter 11 )
;
	page    55,132
;
;       This program installs additional handlers for following interrupts:
;       09h - keyboard
;       1Ch - timer
;       10h - video
;       33h - mouse
;       2Fh - multiplex handler
;
;       New function 193 (0C1h) is added to interrupt 2Fh 
;       This function has following subfunctions:
;       00 - installation check
;       01 - activates the driver
;       02 - deactivates the driver
;       03 - report the driver state; returns the state in AH (1 - on, 2 - off)
;       04 - switch border blinking On/Off
;       To call new function put its number into the AH register, 
;       the subfunction number into AL and call interrupt 1Ch
;
NewFunc equ     0E0h
TSRId   equ     193
CheckIn equ     0                       ; subfunction "check installation"
SwOn    equ     1                       ; subfunction "turn program on"
SwOff   equ     2                       ; subfunction "turn program off"
RepSt   equ     3                       ; subfunction "report status"
RestPal equ     4
BordSw  equ     5
InAct   equ     0                       ; this value indicates "INACTIVE"
Act     equ     13h                     ; this value indicate "ACTIVE"
BlinkB  equ     1
MaxTick equ     5460                    ; 5460 ticks = 5 minutes

_Text   segment para public 'CODE'
	assume  cs:_Text,ds:nothing,es:nothing
;====================  Resident data =====================================
	org     90h                     ;=== COM - variant
	jmp     Start                   ;=== COM - Variant
ActInd  db      Act                     ; activity indicator; if 0 - inactive
NumTick dw      0                       ; number of timer ticks since last key
NumTk1  dw      0
BlankId db      0                       ; screen blank indicator; if 0 - not blankedA
Blanked equ     13h                     ; signature "screen is blanked"
BIOSSeg dw      40h                     ; segment address of BIOS data area
ComSeg  dw      0                       ; segment addres of resident part (CS)
IndStat db      0
Within  equ     13                      ; sign of using INT 10 from ScrBlank
ZerPal  db      16 dup (0), 0           ; zero value for palette registers
CurPal  db      0,1,2,3,4,5,14h,7,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,0
Border  db      0
DefBord db      0
BlinkId db      0
PresEGA db      0
;===    save area for registers
AX09    dw      0
BX09    dw      0
CX09    dw      0
DX09    dw      0
ES09    dw      0
FLAG09  db      0
AX1C    dw      0
BX1C    dw      0
CX1C    dw      0
DX1C    dw      0
ES1C    dw      0
FLAG1C  db      0

	org     100h                    ;=== COM - Variant
Addr100:jmp     start                   ;=== COM - Variant
;=====================  Resident code ====================================

RestScr proc    near
	cmp     PresEGA,0               ; is EGA/VGA present?
	jnz     REGAVGA                 ; if so, use EGA/VGA BIOS functions
;===    Restore screen for CGA/MDA/Hercules
	mov     es,BIOSSeg              ; BIOS data accessable through ES       
	mov     al,es:[65h]             ; get current content of mode register 
	or      al,08h                  ; set bit "video enable"
	mov     es:[65h],al             ; put changed content of mode register
	mov     dx,3B8h                 ; address of video port - MDA/Hercules
	out     dx,al                   ; set mode register to "beam on"
	mov     dl,0D8h                 ; low part of address - CGA
	out     dx,al                   ; set mode register to "beam on"
	mov     IndStat,Within          ; set indicator "Within Scrblank"
	mov     ax,0B00h                ; function 0Bh - Set Border/Palette
	mov     bh,0                    ; subfunction 00h - Set Border Color
	mov     bl,DefBord              ; BL - default border color
	int     10h                     ; BIOS video service call
	mov     IndStat,0               ; clear indicator "Within ScrBlank"     
	jmp     ExRest                  ; exit from additional handler
;===    Restore screen for EGA/VGA
REGAVGA:mov     ax,1002h                ; function "set all palette registers"
	mov     es,ComSeg               ; ES points to current segment
	mov     dx,offset CurPal        ; address of 17 defualt palette
	mov     IndStat,Within          ; set indicator "Within Scrblank"
	int     10h                     ; BIOS video service call
	mov     IndStat,0               ; clear indicator "Within ScrBlank"     
ExRest: ret                             ; exit from procedure
RestScr endp

BlnkScr proc    near
;===    Blank the screen        
	mov     BlankId,Blanked         ; set blank indicator
	mov     NumTick,0               ; clear ticks counter
	mov     Border,0                ; border will be black (first in chain)
	mov     NumTk1,0                ; clear counter for border blinking
	cmp     PresEGA,0               ; EGA/VGA adapter present?
	jnz     BEGAVGA                 ; if so, process EGA/VGA
;---    Blank the screen for CGA/MDA/Hercules
	mov     es,BIOSSeg              ; BIOS data accessable through ES 
	mov     al,es:[65h]             ; get current content of mode register
	and     al,not 08h              ; clear bit "video enable"
	mov     es:[65h],al             ; put changed content of mode register
	mov     dh,3                    ; high part of video port address
	mov     dl,0B8h                 ; low part of address - MDA/HERCULES
	out     dx,al                   ; set mode register to "beam off"
	mov     dl,0D8h                 ; low part of address - CGA
	out     dx,al                   ; set mode register to "beam off"
	jmp     ExBln
;---    Blank the screen for EGA/VGA    
BEGAVGA:mov     ax,1002h                ; function "set all palette registers"
	mov     es,ComSeg               ; ES points to current segment
	mov     dx,offset ZerPal        ; address of 17 zero values into ES:DX 
	mov     IndStat,Within          ; set indicator "Within Scrblank"       
	int     10h                     ; BIOS video service call
	mov     IndStat,0               ; clear indicator "Within ScrBlank"     
ExBln:  ret
BlnkScr endp

BliBord proc    near
;===    is it time to change the border color?
	inc     NumTk1                  ; number of ticks before changing border
	cmp     NumTk1,91               ; have 5 seconds gone?
	jl      ExBord                  ; if not, exit from handler
;===    test whether blinking border is requested
	cmp     BlinkId,BlinkB          ; blinking requested
	jne     ExBord                  ; if not, exit from handler
;===    prepare the new color value     
	mov     NumTk1,0                ; clear counter of ticks for border
	inc     Border                  ; next color of border
	and     Border,03h              ; only colors 0-3 valid (CGA compatible)
;===    set the new border color 
	mov     ax,0B00h                ; function 0Bh - "Set Palette/Border"           
	mov     bh,0                    ; subfunction 00h - Set Border Color
	mov     bl,Border               ; BL - border color     
	mov     IndStat,Within          ; set indicator "Within Scrblank"
	cmp     PresEga,0               ; EGA/VGA present?      
	jnz     BliEGA
	int     10h                     ; BIOS video service call
	jmp     ClStat
;===    make border blinking on EGA/VGA 
BliEGA: xchg    bh,bl                   ; Border Color into BH, zero into BL 
	mov     ah,10h                  ; function 10h - Get/Set Palette
	mov     al,01h                  ; subfunction 01h - Set Border Color
	int     10h                     ; BIOS video service call
ClStat: mov     IndStat,0               ; clear indicator "Within ScrBlank"     
ExBord: ret                             ; exit from procedure
BliBord endp    

NewMous proc    near
;===    save AX and flags
	mov     AX33,ax                 ; save original value of AX register 
	lahf                            ; original flags into AH register
	mov     Flag33,ah               ; save original flags
	mov     ax,AX33                 ; restore original value of AX register 
;===    check function of mouse handler 
	cmp     al,0Bh                  ; read motion counters?
	je      CallMou                 ; if so, call original handler
	cmp     al,04h                  ; position cursor?
	je      CallMou                 ; if so, call original handler  
	cmp     al,03h                  ; read mouse state?
	jne     ToOldM                  ; if not, to old handler
;===    call original handler   
CallMou:pushf
	call    dword ptr StdMous       ; call standard handler
;===    check whether buttons state and mouse location changed since last call  
	mov     ax,AX33                 ; restore original value of AX register         
TstBX:  cmp     bx,PrevBX               ; buttons state changed?
	jne     RestS                   ; to saving current position and state
TstCX:  cmp     cx,PrevCX               ; X coordinate changed?
	jne     RestS                   ; to saving current position and state
TstDX:  cmp     dx,PrevDX               ; Y coordinate changed?
	jne     RestS                   ; to saving current position and state
	jmp     ToOldM                  ; to original mouse handler
;===    restore AX and flags and exit from the handler  
Exit33: mov     ah,FLAG09               ; original flags int AH register
	sahf                            ; restore original flags
	mov     ax,AX33                 ; restore original value of AX register
	mov     NumTick,0               ; mouse active - clear ticks counter    
	iret                            ; exit from handler
;===    save buttons state and mouse location for next use      
RestS:  mov     PrevBX,bx               ; save current buttons state
	mov     PrevCX,cx               ; save current X coordinate
	mov     PrevDX,dx               ; save current Y coordinate
;===    check   if screen is blanked and restore it if mouse is active
ProcM:  cmp     BlankId,Blanked         ; is screen blanked?
	jne     Exit33                  ; if not - nothing to do
	mov     BlankId,0               ; clear blank indicator 
	mov     NumTick,0               ; mouse active - clear ticks counter
;---    save register used      
	mov     BX33,bx                 ; save original value of BX register 
	mov     CX33,cx                 ; save original value of CX register 
	mov     DX33,dx                 ; save original value of DX register 
	mov     ES33,es                 ; save original value of ES register 
	call    RestScr 
;---    restore registers               
	mov     es,ES33                 ; restore original value of ES register 
	mov     dx,DX33                 ; restore original value of DX register 
	mov     cx,CX33                 ; restore original value of CX register 
	mov     bx,BX33                 ; restore original value of BX register 
	jmp     Exit33
;===    pass the control to the standard handler of the interrupt 33h   
ToOldM: mov     ah,FLAG09               ; original flags int AH register
	sahf                            ; restore original flags
	mov     ax,AX33                 ; restore original value of AX register 
	jmp     dword ptr StdMous
StdMous dw      ?,?
OldOffM equ     StdMous[0]              ; here will be ofsset
OldSegM equ     StdMous[2]              ; here will be segment
Flag33  db      ?
AX33    dw      ?
BX33    dw      ?
CX33    dw      ?
DX33    dw      ?
ES33    dw      ?
PrevBX  dw      0
PrevCX  dw      0
PrevDX  dw      0
NewMous endp

NewInt9 proc    near                    ; additional handler for interrupt 09h
	mov     AX09,ax                 ; save original value of AX register 
	lahf                            ; original flags into AH register
	mov     FLAG09,ah               ; save original flags
	mov     NumTick,0               ; key pressed - clear ticks counter
	cmp     BlankId,Blanked         ; is screen blanked?
	jne     ToOld9                  ; if not - nothing to do
	mov     BlankId,0               ; clear blank indicator
;===    Save register used      
	mov     BX09,bx                 ; save original value of BX register 
	mov     CX09,cx                 ; save original value of CX register 
	mov     DX09,dx                 ; save original value of DX register 
	mov     ES09,es                 ; save original value of ES register 
	call    RestScr 
;===    Read a key from keyboard and ignore this keystroke
GetKey: in      al,60h                  ; read key code
	in      al,61h                  ; read port B of PIC
	or      al,80h                  ; set bit 7 to 1
	out     61h,al                  ; send this value inti port B
	jmp     $+2                     ; wait for some time on fast PCs
	and     al,not 80h              ; clear bit 7 
	out     61h,al                  ; send into port B
	mov     al,20h                  ; signal "end of interrupt processing" 
	out     20h,al                  ; send to Interrupt Controller
;===    restore registers               
	mov     ah,FLAG09               ; original flags int AH register
	sahf                            ; restore original flags
	mov     es,ES09                 ; restore original value of ES register 
	mov     dx,DX09                 ; restore original value of DX register 
	mov     cx,CX09                 ; restore original value of CX register 
	mov     bx,BX09                 ; restore original value of BX register 
	mov     ax,AX09                 ; restore original value of AX register 
	iret
;===    Pass the control to the standard handler of the interrupt 09h   
ToOld9: mov     ah,FLAG09               ; original flags int AH register
	sahf                            ; restore original flags
	mov     ax,AX09                 ; restore original value of AX register         
	db      0EAh                    ; this is code for JMP FAR
OldOff9 dw      0                       ; here will be ofsset
OldSeg9 dw      0                       ; here will be segment
NewInt9 endp

NewInt10        proc
	pushf                           ; push original flag onto stack
	cmp     IndStat,Within          ; INT 10 requested from ScrBlank?
	je      ToOld10                 ; if so, go to standard handler
	cmp     ah,10h                  ; palette/border servicing?
	jne     ToOld10                 ; if not, to old handler
	cmp     al,00h                  ; Set Palette Register function?
	jne     Not00h                  ; if not - check other function
	mov     al,bh                   ; save original color value
	mov     bh,0                    ; BX contains number of register
	mov     CurPal[bx],al           ; change color value in paleete 
	mov     bh,al                   ; restore original color value
	mov     al,0                    ; restore value 00 for AL register
	jmp     ToOld10                 ; to original handler of INT 10h
Not00h: cmp     al,01h                  ; Set Border Color function?
	jne     Not01h                  ; if not - check for other function
	mov     CurPal[16],bh           ; save changed border color
	jmp     ToOld10                 ; if not, to old handler
Not01h: cmp     al,02h                  ; Set Entire Palette Function
	jne     Not02h                  ; if not - check other function
	mov     CX10,cx                 ; save CX register
	mov     cx,17                   ; CX will be cycle counter
	mov     BX10,bx                 ; save BX register
	mov     bx,0                    ; BX - number of source register
	mov     DI10,di                 ; save DI register
	mov     di,dx                   ; offset of new pallete (ES:DX) into DX
CopyPal:mov     al,es:[di]              ; copy one paleete register into AL
	mov     CurPal[bx],al           ; save it for screen restoring 
	inc     bx                      ; advance target (palette for restoring)
	inc     di                      ; advance source (palette to be set now)
	loop    CopyPal                 ; next step (17 times)
	mov     cx,CX10                 ; restore CX
	mov     bx,BX10                 ; restore CX
	mov     di,DI10                 ; restore DI
	mov     al,02h                  ; restore AL
	jmp     ToOld10                 ; to old handler        
Not02h: cmp     ah,0Bh                  ; Set Palette/Border function (CGA)?
	jne     Not0Bh                  ; if not - check other function
	cmp     bh,0                    ; Set Border Color subfunction?
	jne     Not0Bh                  ; if not, check for other functions
	mov     CurPal[16],bl           ; save changed border color (EGA/VGA)
	mov     DefBord,bl              ; save changed border color (CGA)
	jmp     ToOld10                 ; to old handler
Not0Bh: 
ToOld10:popf
	db      0EAh                    ; this is code for JMP FAR
OldO10  dw      0                       ; here will be ofsset
OldS10  dw      0                       ; here will be segment
BX10    dw      ?
CX10    dw      ?
DI10    dw      ?
NewInt10        endp
;===
Handler proc    near                    ; additional handler for interrupt 1Ch
	mov     AX1C,ax                 ; save original value of AX register 
	lahf                            ; original flags into AH register       
	mov     FLAG1C,ah               ; save original flags
	mov     ax,AX1C                 ; restore original value of AX register
	cmp     ActInd,Act              ; is activity indicator set?
	jne     ToOld1C                 ; if not, pass control to old handler
;===    Check whether the screen is already blanked
Process:mov     BX1C,bx                 ; save original value of BX register 
	mov     CX1C,cx                 ; save original value of CX register 
	mov     DX1C,dx                 ; save original value of DX register 
	mov     ES1C,es                 ; save original value of ES register 
	cmp     BlankId,Blanked         ; is screen blanked?
	jne     ChkTime                 ; if not, check whether time has gone
	call    BliBord                 ; show blinking border
	jmp     Rest1C
;===    Has the time gone?
ChkTime:inc     NumTick                 ; increase ticks counter
	cmp     NumTick,MaxTick         ; is it time to blank screen
	jl      Rest1C                  ; if not, procced to standard handler
	call    BlnkScr
;===    Restore registers       
Rest1C: mov     es,ES1C                 ; restore original value of ES register 
	mov     dx,DX1C                 ; restore original value of DX register
	mov     cx,CX1C                 ; restore original value of CX register
	mov     bx,BX1C                 ; restore original value of BX register
;===    Pass the control to the standard handler of the interrupt 1Ch   
ToOld1C:mov     ah,FLAG1C               ; original flags into AH register
	sahf                            ; restore original flags
	mov     ax,AX1C                 ; restore original value of AX register
	db      0EAh                    ; this is code for JMP FAR
OldOffC dw      0                       ; here will be ofsset
OldSegC dw      0                       ; here will be segment
Handler endp

MulHand proc    near                    ; NEW MULTIPLEX HANDLER
	pushf                           ; push original flags
	cmp     ah,TSRId                ; is user function specified?
	jne     ToOld2F                 ; if not - to old handler
	cmp     bx,AddSign              ; does BX contain additional signature
	jne     ToOld2F                 ; if not - caller isn't ScrBlank
	cmp     al,CheckIn              ; Installation Check?
	jne     Other1                  ; if not - check for other function
	mov     al,0FFh                 ; standard convention for Presence
	mov     bx,PresSign             ; presence signature into BX
Other1: cmp     al,SwOn                 ; function "Switch ON?"
	jne     Other2                  ; if not, continue testing
	mov     ActInd,Act              ; set indicator to ACTIVE (ON)
	jmp     Exit2F                  ; to exit from handler
Other2: cmp     al,SwOff                ; function "Switch OFF"?
	jne     Other3                  ; if not, continue testing      
	mov     ActInd,InAct            ; set indicator to INACTIVE (OFF)
	jmp     Exit2F                  ; to exit from handler
Other3: cmp     al,RepSt                ; function "Report state"?
	jne     Other4                  ; if not, continue testing      
	mov     ah,ActInd               ; set indicator to INACTIVE (OFF)
	jmp     Exit2F                  ; to exit from handler
Other4: cmp     al,BordSw               ; function "Toggle Border Blinking"
	jne     Other5                  ; if not, continue testing      
	xor     BlinkId,BlinkB          ; toggle blinking indicator
	mov     ah,BlinkId              ; return new blinking state
	jmp     Exit2F                  ; to exit from handler
Other5: 
Exit2F: popf
	iret
ToOld2F:popf
JMPto2F:jmp     dword ptr Old2Fh
Old2Fh  dw      ?,?
OldmulO equ     Old2Fh[+0]
OldMulS equ     Old2Fh[+2]
MulHand endp

AddSign dw      1951
PresSign dw     7654    
;===    Installation part of the program
BegInst label   byte                    ; This is start of installation part
ParmInd db      0
PspAddr dw      ?
RetCode db      0
InvPCod equ     16
HelpCod equ     5
DefPal  db      0,1,2,3,4,5,14h,7,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh,0
;===    Set segment register
Start:  mov     ah,51h                  ; get PSP address (undocumented)
	int     21h                     ; DOS service call
	mov     PspAddr,bx              ; save segment address of PSP
	mov     ComSeg,cs               ; save address of command segment
	mov     sp,0F000h               ; set stack to command segment's top
	mov     es,PspAddr              ; ES points to PSP
	mov     ds,ComSeg               ; DS = CS - data and code are the same 
;===    Check whether the program is already installed
	mov     ah,TSRId                ; user subfunction of multiplex handler
	mov     al,CheckIn              ; AL - installation check
	mov     bx,AddSign              ; BX - additional signature
	int     2Fh                     ; multiplex handler call
	cmp     al,0FFh                 ; common convention satisfied:
	jne     InsSta                  ; if not - start installation
	cmp     bx,PresSign             ; does BX contain presence signature?
	jne     InsSta                  ; if not - start installation
	jmp     Already                 ; otherwise program is already installed
;===    The process of installation starts here 
;===    Free the environment memory block
InsSta: mov     es,es:[2Ch]             ; address of environment block into ES 
	mov     ah,49h                  ; function 49h - free memory block
	int     21h                     ; DOS service call
;===    Test whether EGA/VGA are present        
	mov     PresEGA,10h
	mov     bl,10h                  ; 10h - get EGA/VGA configuration 
	mov     ah,12h                  ; function 12h - get/set information
	int     10h                     ; BIOS video service call
	xor     PresEGA,bl              ; if EGA/VGA present PresEGA <> 0
;===    set internal variables for resident part
	mov     es,PspAddr              ; ES points to start of PSP
	mov     ActInd,Act              ; program is ON immediately after start
	mov     NumTick,0               ; clear counter for screen blanking
	mov     NumTk1,0                ; clear counter for border colors play
	mov     BlankId,0               ; screen isn't blanked
	mov     IndStat,0               ; INT 10h isn't called from within TSR 
	mov     BlinkId,BlinkB          ; border blinking is ON
	mov     Border,0                ; initial border is black
	mov     DefBord,0               ; default border is black
	mov     cx,17                   ; CX will be cycle counter
	mov     bx,0                    ; BX will be index
AssPal: mov     al,DefPal[bx]           ; read one value for palette register
	mov     ZerPal[bx],0            ; clear one register of default palette
	mov     CurPal[bx],al           ; load one register for current palette 
	inc     bx                      ; advance index to process next value
	loop    AssPal                  ; next step (17 times)
	
;===    Output initial message  
Install:mov     ah,09                   ; function 09 - text string output
	lea     dx,BegMsg               ; DX - address of message
	int     21h                     ; DOS service call
;===    Install handler for multiplex interrupt 2Fh
	mov     ax,352Fh                ; get interrupt vector 2Fh
	int     21h                     ; DOS service call
	mov     OldMulO,bx              ; save offsett of old handler for 1Ch
	mov     OldMulS,es              ; save segment of old handler for 1Ch
	mov     dx,offset MulHand       ; offset of new Multiplex Handler
	mov     ah,25h                  ; function 25h - set interrupt vector
	int     21h                     ; DOS service call
;===    Install handler for BIOS interrupt 09h (keyboard)
	mov     ax,3509h                ; get interrupt vector 09h
	int     21h                     ; DOS service call
	mov     cs:OldOff9,bx           ; save offsett of old handler for 09h
	mov     cs:OldSeg9,es           ; save segment of old handler for 09h
	mov     ah,25h                  ; function 25h - set interrupt vector
	mov     dx,offset NewInt9       ; address of new INT 09 handler
	int     21h                     ; DOS service call
;===    Install handler for BIOS interrupt 1Ch (timer)  
	mov     ax,351Ch                ; get interrupt vector 1Ch
	int     21h                     ; DOS service call
	mov     cs:OldOffC,bx           ; save offsett of old handler for 1Ch
	mov     cs:OldSegC,es           ; save segment of old handler for 1Ch
	mov     ah,25h                  ; function 25h - set interrupt vector   
	mov     dx,offset Handler       ; address of handler
	int     21h                     ; DOS service call
;===    Install handler for BIOS interrupt 10h (video)  
	mov     ax,3510h                ; get interrupt vector 10h
	int     21h                     ; DOS service call
	mov     cs:OldO10,bx            ; save offsett of old handler for 10h
	mov     cs:OldS10,es            ; save segment of old handler for 10h
	mov     ah,25h                  ; function 25h - set interrupt vector   
	mov     dx,offset NewInt10      ; address of new INT 09 handler
	int     21h                     ; DOS service call
;===    Install handler for interrupt 33h (mouse)       
	mov     ax,3533h                ; get interrupt vector 33h
	int     21h                     ; DOS service call
	mov     cs:OldOffM,bx           ; save offsett of old handler for 33h
	mov     cs:OldSegM,es           ; save segment of old handler for 33h
	mov     ah,25h                  ; function 25h - set interrupt vector   
	mov     dx,offset NewMous       ; address of new INT 33 handler
	int     21h                     ; DOS service call
;===    output the message "program is installed"
	lea     dx,Loaded               ; DX - address of message
	mov     ah,09h                  ; function 09 - output string
	int     21h                     ; DOS service call
;===    Calculate the size of the resident part and exit the program    
	lea     dx,BegInst      
	add     dx,110h                 ; PSP length plus 16 byte (insurance) 
	mov     cx,4                    ; set counter for shift
	shr     dx,cl                   ; 4 bits to the right - divide by 16
	mov     ax,3100h                ; 31h - terminate and state resident
	int     21h                     ; DOS service call
;===    Process situation "Resident part is already installed"
Already:
;===    Check whether parameters are present    
	mov     es,PspAddr              ; addres of PSP into ES
	cmp     byte ptr es:[80h],1     ; are there parameters? 
	jle     NoParm                  ; if not, skip parameters processing
;===    Skip separators "/", "-"  and blanks    
	mov     bx,80h                  ; BX - beginning of parameter string
TestSep:inc     bx                      ; BX points to next character 
	cmp     bl,byte ptr es:[80h]    ; end of parameter string?
	jge     NoParm                  ; if so - parameters not found  
	cmp     byte ptr es:[bx],'/'    ; is current character separator? 
	je      TestSep                 ; if so - try next character
	cmp     byte ptr es:[bx],'-'    ; is current character separator? 
	je      TestSep                 ; if so - try next character
	cmp     byte ptr es:[bx],' '    ; is current character blank?
	je      Testsep                 ; if so - try next character
;===    Separator found - process parameter string
FndSep: cmp     byte ptr es:[bx],'?'    ; question mark specified?
	je      Help                    ; if so, process "HELP"
	and     byte ptr es:[bx],0DFh   ; force first letter uppercase
	cmp     byte ptr es:[bx],'H'    ; is first letter 'H'?
	je      Help                    ; if so, process "HELP" 
	cmp     byte ptr es:[bx],'R'    ; is first letter 'R'?
	je      PalRest                 ; if so, process "Restore Palette" 
	cmp     byte ptr es:[bx],'B'    ; is first letter 'B'?
	je      SwBord                  ; if so, process "Switch Border Blink"
	cmp     byte ptr es:[bx],'O'    ; is first letter 'O'?
	jne     InvParm                 ; if not - missing or invalid parameter
	and     byte ptr es:[bx+1],0DFh ; force second letter uppercase
	cmp     byte ptr es:[bx+1],'N'  ; is second letter 'N'?
	je      FuncOn                  ; if so, process "ON"
	cmp     byte ptr es:[bx+1],'F'  ; is second letter 'F'?
	jne     InvParm                 ; if not - invalid parameter
	and     byte ptr es:[bx+2],0DFh ; force third letter uppercase
	cmp     byte ptr es:[bx+2],'F'  ; is third letter 'F'?
	jne     InvParm                 ; if not, process "INVALID PARMS"
;===    Function "Switch OFF"   
FuncOff:mov     al,SwOff                ; code for function "OFF" into AL
	lea     dx,MakeOff              ; DS:DX - addres of message "Turned OFF"
	mov     RetCode,SwOff           ; return code "SWITCHED OFF"
	jmp     CallMul                 ; to switch program state
;===    Function "Switch ON"
FuncOn: mov     al,SwOn                 ; subfunction "Turn ON"
	mov     RetCode,SwON            ; return code "SWITCHED ON"
	lea     dx,MakeOn               ; DS:DX - addres of message "Turned ON"
;===    Call multiplex handler (function code in AL)
CallMul:mov     ah,TSRId                ; AH - TSR's identifier
	mov     bx,AddSign              ; BX - additional signature
	int     2Fh                     ; call multiplex handler
;===    Print a message (address in DS:DX)      
PrnMsg: mov     ah,09h                  ; function 09 - output text string
	int     21h                     ; DOS service call
;===    Exit from program (return code in RetCode)      
ExitPrg:mov     ah,4Ch                  ; function 4Ch - terminate process
	mov     al,RetCode              ; al - return code (ErrorLevel)
	int     21h                     ; DOS service call
;===    Function :Switch Border Blinking"
SwBord: mov     al,BordSw               ; AL - subfunction "Toggle Blinking"
	mov     ah,TSRId                ; AH - TSR's identifier
	mov     bx,AddSign              ; BX - additional signature
	mov     dx,' N'                 ; set tail of message to "N "
	int     2Fh                     ; call multiplex handler        
	cmp     ah,BlinkB               ; is border blinking?
	je      BordDon                 ; if so, output correspondent message
	mov     dx,'FF'                 ; set tail of message to "FF"
BordDon:mov     OnOff,dx                ; form either "ON" or "OFF" 
	mov     RetCode,BordSw          ; return code
	lea     dx,TogBor               ; address of message "Toggled"
	jmp     PrnMsg                  ; to print message and finish program   
	
;===    Process the situation "no parameter"    
NoParm: mov     al,RepSt                ; AL - subfunction "Report Status"
	mov     ah,TSRId                ; AH - function of INT 2Fh (identifier)
	mov     bx,AddSign              ; BX - additional signature     
	int     2Fh                     ; multiplex handler call
	lea     dx,MakeOff              ; DS:DX - addres of message "Turned OFF"
	mov     RetCode,SwOff           ; return code "SWITCHED OFF"
	cmp     ah,Act                  ; is code "Turned ON" returned? 
	jne     PrnMsg                  ; if not, exit; "OFF" will be output
	lea     dx,MakeOn               ; DS:DX - addres of message "Turned ON"
	mov     RetCode,SwOn            ; return code "SWITCHED ON"
	jmp     PrnMsg                  ; to print message and exit
;===    Restore Palette
Palrest:mov     ax,1002h                ; function "set all palette registers"
	mov     es,ComSeg               ; ES points to current segment
	mov     dx,offset DefPal        ; address of 17 defualt palette
	int     10h                     ; BIOS video service call
	lea     dx,PalMsg               ; DS:DX - address of message "Palette.."
	jmp     PrnMsg                  ; to print message and exit     
;===    Output help message     
Help:   lea     dx,BegMsg               ; DS:DX - address of initial message
	mov     RetCode,HelpCod         ; return code "HELP message output"     
Help2:  mov     ah,09h                  ; function 09 - output text string
	int     21h                     ; DOS service call
	lea     dx,ParmTxt              ; DS:DX - address of HELP message
	jmp     PrnMsg                  ; to print message and exit
;===    Process the situation "INVALID PARAMETERS"
InvParm:lea     dx,Invalid              ; DS:DX addres of message "Invalid"
	mov     RetCode,InvPCod         ; return code "Invalid Parameters"
	jmp     Help2                   ; to print message and exit
;===    Data for non-resident part of the program
CR      equ     0Ah
LF      equ     0Dh
EndMsg  equ     24h 
Invalid db      CR,LF,'Can not interprete parameters specified.'
	db      CR,LF,'The valid form of command line is:',CR,LF,EndMsg
PalMsg  db      CR,LF,'The default palette has been restored',CR,LF,EndMsg      
BegMsg  db      CR,LF,'The resident screen blanker     version 4.2     19.11.92'
	db      CR,LF,'Copyright (C) 1992 V.B.Maljugin,     Russia,    Voronezh'
	db   CR,CR,LF,'Puts out the screen when the keyboard is  5 minutes idle'        
	db      CR,LF,'The MDA/CGA/Hercules/EGA/MCGA/VGA adapters are supported'
CrLf    db      CR,LF,EndMsg
Loaded  db      CR,LF,'The screen blanker is installed successfully',CR,LF,EndMsg
MakeOn  db      CR,LF,'The screen blanker is now ACTIVE',CR,LF,EndMsg
MakeOff db      CR,LF,'The Screen blanker is now INACTIVE',CR,LF,EndMsg
TogBor  db      CR,LF,'The border blinking from now will be O'
OnOff   dw      2020h
	db      EndMsg    
HelpTxt db      CR,LF,CR,LF, 'Call: '
ParmTxt db      CR,LF,'ScrBlank [on | off | b | r | /? | /h | -? | -h] ',CR,LF
	db      CR,LF,'Parameters:                                           '
	db      CR,LF,'on  - make the screen blanker active                  '
	db      CR,LF,'off - make the screen blanker inactive                '
	db      CR,LF,'b   - toggle the border blinking                      '
	db      CR,LF,'r   - restore the default palette                     '
	db      CR,LF,'rest of list - output this text',CR,LF
	db      CR,LF,'Call this program without parameters to determine its '
	db            'current state.', CR,LF,EndMsg
_text   ends
	end     Addr100                 ; COM variant
;       end     Start
