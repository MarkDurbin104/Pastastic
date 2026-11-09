;****************************************************************
;  Program PrinLow ( Chapter 10 )
;
;  The program for outputting text string onto the printer
;
;  Author: A.I.Sopin, Voronezh, Russia,  1991
;
;  The LPT registers programming is used
;
;****************************************************************
;----------------------------------------------------------
.MODEL SMALL
.STACK
.DATA
CR       EQU    13      ;  Carriage Return   
LF       EQU    10      ;  Line  Feed
LPT1     DW     0
MSG1     DB     ' Output string onto the printer (low-level technique) '
	 DB     CR, LF
LMSG1    EQU    $-MSG1
MSG2     DB     13,10, 'Error while outputting the string !!!',13,10,'$'
MSG3     DB     13,10, 'Printer not ready !!!',13,10,'$'
MSG4     DB     13,10, 'Error during printer initialisation !!!',13,10,'$'
;----------------------------------------------------------
.CODE
.startup
;--- Check the printer status register
	 mov    ax,40h          ;  segment address of BIOS data area
	 mov    ES,ax           ;  ES points to BIOS data area
	 mov    dx,ES:[8]       ;  address of LPT1 port into DX
	 mov    LPT1,dx         ;  store LPT1 address into memory
	 inc    dx              ;  address of printer status register into DX
	 in     al,dx           ;  get printer status
	 jmp    $+2             ;  this is needed for fast PC
	 test   al,80h
	 jnz    Init            ;
	 lea    dx,MSG3         ;  addres of error message into DS:DX
	 jmp    Text            ;  output error message and exit
;--- Initialise the printer port
Init:    mov    dx,LPT1         ;  address of LPT1 port into DX
	 add    dx,2            ;  address of control register
	 mov    al,0Ch          ;  value 0Ch is initial code
	 out    dx,al           ;  initialisation
	 mov    cx,3000         ;  number of dummy cycles for delay
	 loop   $               ;  empty cycle (delay)
	 mov    al,08h          ;  value for initialisation completion
	 out    dx,al           ;  complete initialisation
;----------------------------------------------------------
;--- Send the ASCII - string onto the printer
Print:   mov    cx,LMSG1        ;  length of string to be output
	 lea    si,MSG1         ;  DS:SI - address of string
	 cld                    ;  direction - forward!
;  send a character onto printer
Next:    lodsb                  ;  load character into AL
	 mov    dx,LPT1         ;  address of LPT1 port into DX
	 out    dx,al           ;  send one character onto printer
	 inc    dx              ;
	 inc    dx              ;  address of control register
	 mov    al,0Dh          ;  value for strobe impulse  
	 out    dx,al           ;  send strobe 
	 dec    al              ;  normal state of register 
	 out    dx,al           ;  switch strobe off
;  Testing result of the operation     
	 dec    dx              ;  state register address 
	 in     al,dx           ;  read state register
	 test   al,08h          ;  printer error ?
	 jz     Error           ;  output error message
;  Waiting for release of printer
Wait0:   in     al,dx           ;  read status register
	 test   al,80h          ;  is printer busy?
	 jz     Wait0           ;  if so, wait
	 loop   Next            ;  if not, process next character
	 jmp    Exit            ;  exit program
Error:   lea    dx,MSG2         ;  address of error message into DS:DX
;----------------------------------------------------------
;--- Exit at successful finish of printing or at error
Text:    mov    ah,9            ;  function 09h - output text string
	 int    21h             ;  DOS service call
Exit:    mov    ax,4C00h        ;  Return Code = 0
	 int    21h             ;  Return to  MS-DOS
	 END
