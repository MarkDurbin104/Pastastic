;************************************************************************
;  Program TSR00 ( Chapter 11 )
;                                                                       *
;  TSR-program for output of the hot key codes in line 1
;
;  Execution by pressing:  Shift (R) + hot key (1-9)    
;
;  Author: A.I.SOPIN  VGU,  Voronezh  1992                Version 1.0   *
;
;  Interrupt INT 09h is used                                             
;                                                                       *
;************************************************************************
NAME     TSR00
;  Saving the registers to be used
PUSHR    MACRO  REGLST
	 IFB    <REGLST>
	 push   ax
	 push   bx
	 push   cx
	 push   dx
	 push   si
	 push   di
	 push   ds
	 push   es
	 push   bp
	 ENDIF
	 IRP    REG,<REGLST>
	 push   REG
	 ENDM
	 ENDM
;  Restoring the registers been used
POPR     MACRO  REGLST
	 IFB    <REGLST>
	 pop    bp
	 pop    es
	 pop    ds
	 pop    di
	 pop    si
	 pop    dx
	 pop    cx
	 pop    bx
	 pop    ax
	 ENDIF
	 IRP    REG,<REGLST>
	 pop    REG
	 ENDM
	 ENDM
;----------------------------------------------------------
CODE     SEGMENT 'CODE'
	 ASSUME CS:CODE,DS:CODE,ES:CODE
;----------------------------------------------------------
OLD09H   LABEL  DWORD                   ;  old vector INT 09h address
OFF09H   DW     0                       ;  offset of standart INT 09h 
SEG09H   DW     0                       ;  segment address of INT 09h
TXT0     DB     ' Shift + '
KeyCode db      'X'
TXT0E   db      ' keystroke has been pressed !!!    '
CursCX  dw      ?
CursDX  dw      ?
PRES     DW     1234                    ;  signature  of program's presence
;----------------------------------------------------------
;  New handler of interrupt INT 09h
;  
;  Key combinations: Shift (R) + 1 - 9 are treated
;
;  On pressing them the text output to the cursor position is performed
;
;----------------------------------------------------------
INT09H   PROC   FAR                  ;  ne interrupt INT 09h handler
	 cli                         ;  disable interrupts
	 PUSHR                       ;
	 mov    ax,40h               ;  keyboard data
	 mov    ES,ax                ; segment address for BIOS
	 mov    ch,ES:[17h]          ; state of register keys
	 in     al,60h               ;  obtain  the scan code
;  Testing for hot key being pressed (keys Shift + 1- 9)
	 and    ch,01h               ;  clearing of unnecessary flags
	 cmp    ch,01h               ;  previous Shift ?
	 jne    RET09                ;
	 sub    al,1                 ;  transform ASCII into a number
	 jng    RET09                ;  key  <  F1    
	 cmp    al,9                 ;
	 jg     RET09                ;  key >  F9
;  Editing the code of a hot key
	 or     al,30h               ;  obtain ASCII-code
	 mov    CS:KeyCode,al        ;  pass the code of a key
;  Hot key output and delay for 1.5 seconds
	 mov    ax,cs                ;
	 mov    ds,ax                ;  data segment in code segmen
	 mov    ah,0Fh               ;  function 0Fh - get video mode
	 int    10h                  ; BIOS video service call
	 mov    ah,03h
	 int    10h                  ; BIOS video service call
	 mov    CursCX,cx
	 mov    CursDX,dx
	 mov    bl,0
	 mov    cx,LengthOf TXT0+LengthOf TXT0E
	 mov    ah,0Eh
	 lea    si,0
OutMsg:  mov    al,TXT0[si]
	int     10h                  ; BIOS video service call
	inc     si
	loop    OutMsg   
	 mov    cx,25                ;  delay for  1.5 seconds
	 Call   DELAY                ;  generation of delay
	 mov    ah,02h
	 mov    cx,CursCX
	 mov    dx,CursDX
	 int    10h                  ; BIOS video service call
	 pushf                       ;  flag register for IRET (from INT 09h)
	 Call   CS:OLD09H            ;  call the old handler for INT 09h
	 mov    cx,LengthOf TXT0+LengthOf TXT0E
	 mov    al,' '
	 mov    ah,0Ah
	 int    10h
;  Restoring the screen after the text output
	mov     ax,40h
	mov     ES,ax               ;  ES points to BIOS data segment
	mov     al,ES:[1Ah]         ;  address of keyboard buffer head
	mov     ES:[1Ch],al         ;  clear buffer (tail ptr = head ptr)
	jmp     ExHand
;  Restoring the registers and exit
RET09:   pushf                       ;  flag register for IRET (from INT 09h)
	 Call   CS:OLD09H            ;  call the old handler for INT 09h
ExHand:  POPR                        ;  restore the registers
	 sti                         ;  enable interrupts
	 IRET                        ;  exit from the interrupt handling
INT09H   ENDP
;-----------------------------------------------------------
;
;  Procedure for the delay generation
;  
;  CX  - time of delay (in       1/18 sec) 
;
;-----------------------------------------------------------
DELAY   PROC    NEAR
	PUSHR   <ax,dx,es>
	mov     ax,40h               ;
	mov     ES,ax                ;  segment address of BIOS area
	sti                          ;  enable interrupts
T0:     mov     dx,ES:[6Ch]          ;  initial time (in ticks)
T1:     cmp     dx,ES:[6Ch]          ;  has time passed ?
	je      T1                   ;  no !!!
	loop    T0                   ;
	POPR    <es,dx,ax>
	RETN
DELAY   ENDP
;----------------------------------------------------------
;
;  Program for the initial loading of the TSR-part of TSR00
;
;----------------------------------------------------------
;  Checking for the presence of the TSR00 driver been loaded before 
INSTALL:mov     ax,3509h          ;  read address of the current INT 09h vector
	int     21h               ;  ES:BX  - address of the vector been read
	mov     ax,cs             ;
	mov     ds,ax             ;  data segment in code segment
	mov     ax,CS:[bx-2]      ;  driver presence indicator
	cmp     ax,CS:PRES        ;  is driver already in memory ?
	jne     Modvec            ;  no, load th TSR-part
;  Output of message about the program loaded and exit
	lea     dx,LOAD1          ;  address of message
	mov     ah,9              ;  code for text output function
	int     21h               ;  output the driver-been-loaded-message
	mov     ax,4C01h          ;  Return Code
	int     21h               ;  Return to  MS-DOS
;----------------------------------------------------------
;  Modification of the keyboard interrupt INT 09h vector
Modvec: mov     ax,3509h          ;  read address of current vector INT 09h
	int     21h               ;  ES:BX  -address of the vector been read
	mov     CS:OFF09H,bx      ;  pass the address of the  old vector
	mov     CS:SEG09H,es      ;  pass the old segment address
	lea     dx,INT09H         ;  DS:DX -address of the new vector
	mov     ax,2509h          ;  introduce a new interrupt INT 09h vector
	int     21h               ;
;  Loading of the TSR-part of the program
	lea     dx,LOAD0          ;  message address
	mov     ah,9              ;  text output function code
	int     21h               ;  output the driver-been-loaded-message
	lea     dx,INSTALL        ;  the length of the TSR-part
	mov     cl,4              ;  4 shifts to the right (to divide by 16)
	shr     dx,cl             ;  the length of the TSR-part in paragraphs
	add     dx,20             ;  16  paragraphs for  PSP + 4
	mov     ax,3100h          ;  terminate-stay -resident
	int     21h               ;  KEEP
;----------------------------------------------------------
LOAD0   DB      10,13,'*** The TSR00 program  is loaded *** ',13,10
	DB      10,13,' To activate press:   '
	DB      10,13,'   Shift (R)  +  numeric key (1-9) $ ',13,10
LOAD1   DB      10,13,' The TSR00 program had been loaded $ ',13,10
CODE    ENDS
	END     INSTALL
