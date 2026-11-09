;********************************************************************
;
;  Program DServ ( Chapter 9 )  
;
;  System for treatment of disks written under any operating system.
;
;  Author  A.I.Sopin, Voronezh, 1990 --- 1991, Version 1.2
;
;  Program for reading-modifying a sector of hard disk
;
;  Using:  DSERV7                          
;
;  Interrupt used:  INT  25h and 26h (DOS)
;
;  Information is shown in the screen (two pages, each of 256 bytes) 

;********************************************************************
NAME     DSERV7
EXTRN    DIAM00 : FAR, DIAM01 : FAR, CLEAR : FAR, DELAY : FAR, COLOR : FAR
EXTRN    MOVE : FAR, HEXSYM : FAR, SYMIN4 : FAR, INSYM4 : FAR, SYMHEX : FAR
;
;  Save registers used
PUSHR   MACRO   REGLST
	IFB     <REGLST>
	push    ax
	push    bx
	push    cx
	push    dx
	push    si
	push    di
	push    ds
	push    es
	push    bp
	ENDIF
	IRP     REG,<REGLST>
	push    REG
	ENDM
	ENDM
;  Restore register used
POPR    MACRO   REGLST
	IFB     <REGLST>
	pop     bp
	pop     es
	pop     ds
	pop     di
	pop     si
	pop     dx
	pop     cx
	pop     bx
	pop     ax
	ENDIF
	IRP     REG,<REGLST>
	pop     REG
	ENDM
	ENDM
;  Call the procedure for the screen clearing and the color setting
CLR     MACRO  M$,N$,C$
	mov    ch,M$
	mov    dh,N$
	mov    ah,C$
	Call   Color
	ENDM
;
DIAM0   MACRO   TEXT$,OP$,M$,N$,U$,V$
	mov     TOFF,offset TEXT$    ; address of the string
	mov     OP,OP$               ; work mode
	mov     M,M$                 ; first line for output
	mov     bx,N$                ;
	mov     N,bx                 ; last string for output
	mov     bx,U$                ;
	mov     U,bx                 ;
	mov     bx,V$                ;
	mov     V,bx                 ;
	lea     bx,PARM              ;
	push    bx                   ;  address of parameters vector for DIAM
	Call    DIAM00               ;
	ENDM
;
DIAM1   MACRO   TEXT$,OP$,M$,N$,U$,V$   
	mov     TOFF,offset TEXT$    ;  the text string address
	mov     OP,OP$               ;  working mode
	mov     M,M$                 ;  first string for output
	mov     bx,N$                ;
	mov     N,bx                 ;  last string for output
	mov     bx,U$                ;
	mov     U,bx                 ;
	mov     bx,V$                ;
	mov     V,bx                 ;
	lea     bx,PARM              ;
	push    bx                   ;  sector address for output by DIAM00
	Call    DIAM01               ;
	ENDM
;
;  Preliminary clearing of output buffer (passing blanks)
SPACE   MACRO   TXT$,L$
	mov     ax,ds
	mov     es,ax
	lea     di,TXT$
	mov     cx,L$
	cld
	mov     al,' '
	rep     stosb
	ENDM
; Output a number in hexadecimal form
HEX     MACRO   L$                       ;
	Local   H1                       ;
	mov     cx,L$                    ;  number of bytes
H1:     mov     al,[si]                  ;
	Call    HEXSYM                   ;  converting HEX to SYM
	mov     DS:[di],ax               ;
	add     di,2                     ;
	inc     si                       ;
	loop    H1                       ;
	ENDM
;----------------------------------------------------------
STAC     SEGMENT STACK
	 db      256 dup (?)
STAC     ENDS
;----------------------------------------------------------
DATA     SEGMENT
TEXT0    db  ' Disk  X  is not found !!!   (Repeat input) ',0
TEXT2    db  ' Reading-modifying a sector of hard disk.     '
	 db  ' A.I.Sopin, Voronezh, 1992 ',0
TEXT3    db  ' Disk drive= C',0
Ltext3   EQU $-TEXT3-2  
TEXT5    db  ' Sector= 00000',0
Ltext5   EQU $-TEXT5-2
;
TEXT6    db  ' Error while reading the sector !  AH='
TEXT6AX  db  'xx  SEC='
TEXT6SEC db  'xxxxx   (Press ENTER)             ',0
TEXT7    db  ' Error while inputting sector address (repeat input)     ',0
TEXT8    db  ' Error while writing sector!  AH='
TEXT8AX  db  'xx  SEC='
TEXT8SEC db  'xxxxx   (Press ENTER)                    ',0
;
I2       DB     80,0             ;  length =80, offset =0
	 DB     0,74h            ;  background -grey, characters -red
	 DW     0
;
TXT0     db  'Displacement ----------------- Hex codes -------------------'
	 db  '     ASCII value    ',0
TXT25    db  ' PgDn -forward, PgUp -back, Esc -exit, F3  -edit, F1 '
	 db  '-change panel        '
Ltxt25   EQU $-TXT25
I25      DB     80,0              ;  length =80, offset =0
	 DB     0,1Eh             ;  background -grey, characters -red
	 DW     0                 ;  end of vector  I
;
Disp1    db  '0000(0000)','0016(0010)','0032(0020)','0048(0030)'
	 db  '0064(0040)','0080(0050)','0096(0060)','0112(0070)'
	 db  '0128(0080)','0144(0090)','0160(00A0)','0176(00B0)'
	 db  '0192(00C0)','0208(00D0)','0224(00E0)','0240(00F0)'
Disp2    db  '0256(0100)','0272(0110)','0288(0120)','0304(0130)'
	 db  '0320(0140)','0336(0150)','0352(0160)','0368(0170)'
	 db  '0384(0180)','0400(0190)','0416(01A0)','0432(01B0)'
	 db  '0448(01C0)','0464(01D0)','0480(01E0)','0496(01F0)'
;
BUFER    db     2000 dup (0)            ;
RDBUF    db     512  dup (0)            ;
ADRBUF   dw     0                       ;
;  Parameter list for sector reading (disk >32M)
TRPACK   LABEL  DWORD                   ;
SECNUM   DD     0                       ;  logical sector number
NUMSEC   DW     1                       ;  number of sectors to be read
ADDRA    DD     RDBUF                   ;  address of reading buffer
SEC      DW     0                       ;  sector number  (0...65535)
;
VER      DW     0                       ;  AL -version, AH -subversion
Disk     db     0                       ;  drive address (0-A, 1-B...)
NCC0     DW     0                       ;  max cylynder number (0 ...)
NHH0     DB     0                       ;  max head number   (0 ...)
NSS0     DB     0                       ;  max sector number  (1 ...)
VV       dw     0                       ;  cursor setting position: CCHHSS
NN       dw     0                       ;  first output line =6 (disk address)
MOD0     DB     0                       ;  modification sign  CCHHSS
REG      DB     0                       ;  current video mode
DISK0    DB     0                       ;  current disk drive
;
;  List of parameters for procedures   DIAM00, DIAM01
	 EVEN
PARM     LABEL  WORD                    ; parameter vector (address in stack)
OP       dw     0                       ; operation code
M        dw     0                       ; number of starting row
N        dw     0                       ; number of final row
TOFF     dw     0                       ; offset of string
L        dw     80                      ; length of text string
U        dw     0                       ; row for cursor positioning (1-25)
V        dw     0                       ; column for cursor positioning (1-80)
Q        dw     0                       ; accepted row of cursor
S        dw     0                       ; accepted column of cursor
W        dw  2 dup (0)                  ; code of interrupt key
IOFF     dw     0                       ;  screen format vector address (or 0)
I        dw     80
	 db     0, 07h
DATA     ENDS
;----------------------------------------------------------
CODE    SEGMENT 'CODE'
	ASSUME CS:CODE,DS:DATA,SS:STAC
Start:  mov     ax,DATA                 ;  address of data segment into AX
	mov     ds,ax                   ;
	mov     ah,30h                  ;  read the MS-DOS version
	int     21h                     ;
	mov     VER,ax                  ;  AL - version, AH - subversion
	mov     ah,0Fh                  ;
	int     10h                     ;  read display mode
	mov     REG,al                  ;  save display mode
	mov     IOFF,0                  ;  format vector is not used
	CLR     1,25,07h                ;
	mov     ah,19h                  ;  determine the current drive
	int     21h                     ;  DOS service call
	mov     DISK0,al                ;  store the current drive number
;  Output the headline and get the disk drive (rows  2---4)
Addres: DIAM0   TEXT2,1,2,2,0,0         ;
	DIAM0   TEXT3,3,4,-4,4,14       ;
	and     TEXT3+Ltext3,0DFh       ;  force CapsLock
	cmp     byte ptr W,1bh          ;  is ESC pressed
	jne     LogDisk                 ;
	jmp     Exit                    ;
;  Set the logical disk drive
LogDisk:DIAM0   TEXT3,1,4,-4,4,Ltext3+1 ;
	mov     dl,TEXT3+Ltext3         ;
	sub     dl,41h                  ;  0 -A, 1 -B, 2 -C,...
	mov     Disk,dl                 ;  save disk number
	mov     ah,0Eh                  ;  function 0Eh - set default drive
;----------------------------------------------------------
;  Request and input of logical sector number  SEC
Diskadr:DIAM0   TEXT5,3,5,-5,5,10       ;
	cmp     byte ptr W+1,49h        ;  PgUp ?
	je      JmpAdr                  ;  return to preceeding parameter
	cmp     byte ptr W,1bh          ;  Esc ?
	jne     ConvSEC                 ;
JmpAdr: jmp     Addres                  ;
;  Converting the sector address  SEC
ConvSEC:lea     bp,TEXT5+Ltext5-4
	mov     si,5                    ;  source characters counter
	Call    SYMIN4                  ;  convertion string to integer
	mov     SEC,ax                  ;
	jnc     Rdsect                  ;
	DIAM0   TEXT7,1,6,-6,0,0        ;  output error message
	jmp     Diskadr                 ;  repeat input
;----------------------------------------------------------
;  Read a sector (512 bytes) at the address requested
Rdsect: Call    SECTOR                  ;  read sector requested
	jnc     Str25                   ;  sector has been read succesfully
	Call    HEXSYM                  ;  convert code to characters
	mov     word ptr TEXT6AX,ax     ;  store return code
	mov     ax,SEC                  ;
	lea     bp,TEXT6SEC             ;  target for editing
	Call    INTSYM                  ;  convert integer to characters
	DIAM0   TEXT6,2,6,-6,0,0        ;  output a message
	mov     IOFF,0                  ;
	CLR     5,25,07h                ;  clear screen
	jmp     Addres                  ;  repeat disk address input
Str25:  mov     IOFF,offset I25         ;
	DIAM1   TXT25,1,25,25,0,0       ;  output prompt
	mov     IOFF,0                  ;
;----------------------------------------------------------
;  Output sector contents in the screen (rows  5---22)
;  Editing and outputting the first page (first 256 bytes)
;----------------------------------------------------------
P1:     lea     si,RDBUF                ;  source
	lea     bp,Disp1                ;
	Call    SCREEN                  ;  output first 256 bytes
	mov     BUFER+5,'1'             ;  page number
	DIAM1   BUFER,3,5,22,5,39       ;  output buffer onto the screen
	lea     di,RDBUF                ;  target
	Call    MODSECT                 ;
	cmp     MOD0,1                  ;  was address modifyied ?
	jne     NEW1                    ;
	jmp     Rdsect                  ;  output modified sector
NEW1:   Call    NEWSEC                  ;  change sector number
	cmp     MOD0,1                  ;  was address modified?
	jne     Esc1                    ;
	jmp     Rdsect                  ;  output modified sector
;  Processing keys: Esc, PgDn, PgUp, Enter
Esc1:   cmp     byte ptr W,1bh          ;  Esc ?
	je      JmpBeg                  ;
	cmp     byte ptr W+1,51h        ;  PgDn ?
	je      P2                      ;  output second part of sector
	cmp     byte ptr W+1,49h        ;  PgUp ?
	jne     P2                      ;
	cmp     SEC,0                   ;  sector number 0 ?
	jz      MOD1                    ;
	dec     SEC                     ;  backward reading
MOD1:   jmp     Rdsect                  ;  repeat reading of sector
JmpBeg: jmp     Diskadr
;  Editing and outputting the second page (last 256 bytes)
P2:     lea     si,RDBUF+256            ;  source
	lea     bp,Disp2                ;
	Call    SCREEN                  ;  output last 256 bytes
	mov     BUFER+5,'2'             ;  page number
	DIAM1   BUFER,3,5,22,5,39       ;  output buffer into the screen
	lea     di,RDBUF+256            ;  target
	Call    MODSECT                 ;  
	cmp     MOD0,1                  ;  was sector modified
	jne     NEW2                    ;
	jmp     Rdsect                  ;  output modified sector
NEW2:   Call    NEWSEC                  ;  
	cmp     MOD0,1                  ;  was address modified
	jne     Esc2                    ;
	jmp     Rdsect                  ;  output modified sector
;  Processing keys: Esc, PgDn, PgUp, Enter
Esc2:   cmp     byte ptr W,1bh          ;  ESC key?
	je      JmpBeg                  ;  return to the beginning
	cmp     byte ptr W+1,49h        ;  PgUp ?
	jne     PgDn2                   ;
	jmp     P1                      ;
PgDn2:  cmp     byte ptr W+1,51h        ;  PgDn ?
	je      Next2                   ;
	jmp     P2                      ;
Next2:  inc     SEC                     ;
	jmp     Rdsect                  ;  process next sector
;----------------------------------------------------------
;  Complete work of the procedure
Exit:    mov    ah,0                    ;  set display mode
	 mov    al,REG                  ;  display mode been saved
	 int    10h                     ;  restore display mode
	 mov    ah,0Eh                  ;  set disk drive
	 mov    dl,DISK0                ;  current disk drive
	 int    21h                     ;  restore current disk drive
	 mov    ax,4c00h                ;  normal end of the program
	 int    21h                     ;  return to MS-DOS

;----------------------------------------------------------
;
;  Reading sector (512 bytes) at given address
;
;----------------------------------------------------------
SECTOR  PROC    NEAR
	mov     ax,VER                  ;  AL - version, AH - subversion
	cmp     al,4                    ;  DOS 4.0  and higher?
	jnl     NEWDOS                  ;
;  Read a sector of disk less than 32M
OLDDOS: mov     al,Disk                 ;  logical device number
	lea     bx,RDBUF                ;  reading buffer address:  DS:BX
	mov     cx,1                    ;  number of sectors to read (upto 8)
	mov     dx,SEC                  ;  sector number
	int     25h                     ;  read sector
	pop     cx                      ;  stack alignment
	RET                             ;
;  Read a sector of disk greater than 32M
NEWDOS: mov     al,Disk                 ;  logical device number
	lea     bx,TRPACK               ;  address of info buffer
	mov     cx,0FFFFh
	mov     dx,SEC                  ;  sector number (0 ...)
	mov     word ptr SECNUM,dx
	int     25h                     ;  read sector
	pop     cx                      ;  stack alignment
	RET                             ;
SECTOR  ENDP

;----------------------------------------------------------
;
;  Reading sector (512 bytes) at given address
;
;----------------------------------------------------------
WRSECT  PROC    NEAR
	mov     ax,VER                  ;  AL - version, AH - subversion
	cmp     al,4                    ;  DOS 4.0  and higher?
	jnl     GT32MB                  ;
;  Write a sector of disk less than 32M
	mov     al,Disk                 ;  logical device number
	lea     bx,RDBUF                ;  address of reading buffer:  DS:BX
	mov     cx,1                    ;  number of sectors
	mov     dx,SEC                  ;  sector number
	int     26h                     ;  write sector
	pop     cx                      ;  stack alignmrnt
	RET                             ;
;  Write a sector of disk greater than 32M
GT32MB: mov     al,Disk                 ;  logical device number
	lea     bx,TRPACK               ;  address of info buffer
	mov     cx,0FFFFh
	mov     dx,SEC                  ;  sector number (0 ...)
	mov     word ptr SECNUM,dx
	int     26h                     ;  write sector
	pop     cx                      ;  stack alignment
	RET                             ;
WRSECT  ENDP

;----------------------------------------------------------
;
;  Procedure for display buffer forming (256 bytes)
;
;  SI  -address of source buffer of the sector been read
;
;  BP  -Displacement table address
;
;----------------------------------------------------------
SCREEN   PROC   NEAR
	 PUSHR                          ;  save all registers
	 PUSHR  <si,bp>                 ;
	 SPACE  BUFER,2000              ;  clear screen buffer
	 lea    si,TEXT5                ;  source
	 lea    di,BUFER+27             ;  target
	 mov    cx,Ltext5               ;  length
	 Call   MOVE                    ;  send row of addresses
	 mov    ax,SEC                  ;  sector address
	 lea    bp,BUFER+38             ;  target for editing
	 Call   INTSYM                  ;  convert integer to characters
;  Form headline (row =6)
	 lea    si,TXT0                 ;  source
	 lea    di,BUFER+80             ;  target
	 mov    cx,80                   ;  length
	 Call   MOVE                    ;  send headline
	 POPR   <bp,si>                 ;
	 lea    di,BUFER+160            ;  address of screen beginning
	 mov    ADRBUF,di               ;  save address of row beginning
	 mov    dx,16                   ;  nomber of row on screen
;  Outward loop on 16 rows of information
S0:      PUSHR  <si,di>                 ;
	 inc    di                      ;  target
	 mov    si,bp                   ;  source
	 mov    cx,10                   ;  length
	 Call   MOVE                    ;  send marking
	 POPR   <di,si>                 ;
	 mov    cx,16                   ;  number of characters in row
	 mov    bx,di                   ;  save address of row beginning
;  Inner loop on 16  characters in a row
S1:      mov    al,[si]                 ;  start of inner loop
	 Call   HEXSYM                  ;  converting HEX ---> SYM
	 mov    DS:[di+13],ax           ;  pass hexadecimal value
	 mov    al,[si]                 ;  ASCII character
	 cmp    al,1bh                  ;  Esc ?
	 ja     S2                      ;  if not, pass without processing
	 mov    al,20h                  ;  else replace with blank
S2:      mov    [bx+63],al              ;  pass  ASCII  character
	 add    di,3                    ;  address of next two bytes
	 inc    bx                      ;  address of next ASCII  character
	 inc    si                      ;  address of next byte in sector
	 loop   S1                      ;  next step of inner loop
;  Modify parameters of outward loop (pass to next row)
	 mov    di,ADRBUF               ;
	 add    di,80                   ;  address of next row
	 mov    ADRBUF,di               ;  save address of start of row
	 add    bp,10                   ;  address of next element
	 dec    dx                      ;  number of rows remained
	 jnz    S0                      ;  next step of outward loop
; Pass transformed addresses to  TEXT5 string
	 lea    si,BUFER+27             ;  source
	 lea    di,TEXT5                ;  target
	 mov    cx,Ltext5               ;  length
	 Call   MOVE                    ;  send string of addresses
	 POPR                           ;
	 RET                            ;
SCREEN   ENDP

;----------------------------------------------------------
;
;  The modification of a data sector
;
;  Is performed when the cursor is in the data area 
;
;  and the ENTER key is pressed
;
;  DS:DI - the address of the buffer in data segment
;
;----------------------------------------------------------
MODSECT PROC    NEAR
	mov     MOD0,0                  ;  clear modification indicator
	cmp     byte ptr W,0Dh          ;  is ENTER pressed?
	jne     RetModS                 ;  if not, exit
	cmp     byte ptr Q,7            ;  is cursor within data area?
	jl      RetModS                 ;  if not, exit
	cmp     byte ptr Q,22           ;  is cursor within data area?
	jg      RetModS                 ;  if not, exit
	cmp     byte ptr S,14           ;  is cursor within data area?
	jl      RetModS                 ;  if not, exit
	cmp     byte ptr S,72           ;  is cursor within data area?
	jng     C0                      ;  YES
RetModS:RETN                            ;  if not, exit
;  Modification the sector buffer accordingly to the screen modified
;  (lines 7---22)
C0:     PUSHR                           ;
	mov     MOD0,1                  ;  modification indicator
	mov     ax,ds                   ;
	mov     es,ax                   ;  ES points to data segment
	lea     si,BUFER+173            ;  address of screen beginning
	mov     ADRBUF,si               ;  store address of string beginning
	mov     dx,16                   ;  number of lines on screen
; Process 16 lines
C1:     mov     cx,16                   ;  number of characters in line
C2:     mov     ax,[si]                 ;  start nested cycle
	Call    SYMHEX                  ;  convert characters to HEX
	mov     [di],al                 ;  store HEX value
	add     si,3                    ;  take next two bytes
	inc     di                      ;  next byte of sector
	loop    C2                      ;  next step of nested cycle
;  Process the next line (the outward cycle)
	mov     si,ADRBUF               ;
	add     si,80                   ;  address of next line
	mov     ADRBUF,si               ;  store address of line's beginning
	dec     dx                      ;  number of rest lines
	jnz     C1                      ;  next step of outward cycle
	mov     ax,ds                   ;
	mov     es,ax                   ;  ES points to data segment
	Call    WRSECT                  ;  write sector
	jc      ErrWr                   ;  if not successful - output message
	POPR                            ;
	RETN                            ;
;  Output an error message
ErrWr:  Call    HEXSYM                  ;  convert code to characters
	mov     word ptr TEXT8AX,ax     ;  store error code for output
	mov     ax,SEC                  ;
	lea     bp,TEXT8SEC             ;  target for editing
	Call    INTSYM                  ;  convert integer to character
	DIAM0   TEXT8,2,6,-6,0,0        ;  output message
	mov     IOFF,0                  ;
	CLR     5,25,07h                ;  clear screen
	POPR                            ;
	RETN                            ;
MODSECT ENDP

;----------------------------------------------------------
;
;   Procedure for processing address of sector given in string
;
;----------------------------------------------------------
NEWSEC   PROC   NEAR
	 mov    MOD0,0                  ;  clear modification indicator
	 lea    bp,BUFER+38             ;  sector number
	 mov    si,5                    ;  source characters counter
	 Call   SYMIN4                  ;  convert characters to integer
	 cmp    SEC,ax                  ;  sector number modified?
	 mov    SEC,ax                  ;  store new sector number
	 je     Retmod                  ;
	 mov    MOD0,1                  ;  set modification indicator
Retmod:  RET
NEWSEC   ENDP

;----------------------------------------------------------
;
;  The subroutine for converting an integer number into character string
;
;  AX  - the number to be converted
;
;  BP  - target addres of character string
;
;
;
;----------------------------------------------------------
INTSYM  PROC    NEAR
	xor     dx,dx                   ;  make high part zero
	mov     si,5                    ;  number of characters edited
	Call    INSYM4                  ;  place leading zero
	cmp     byte ptr DS:[bp],' '    ;  suppressed zero?
	ja      ZER2                    ;
	mov     byte ptr DS:[bp],'0'    ;  place leading zero
ZER2:   cmp     byte ptr DS:[bp]+1,' '  ;  suppressed zero?
	ja      ZER3                    ;
	mov     byte ptr DS:[bp]+1,'0'  ;  place leading zero
ZER3:   cmp     byte ptr DS:[bp]+2,' '  ;  suppressed zero?
	ja      ZER4                    ;
	mov     byte ptr DS:[bp]+2,'0'  ;  place leading zero
ZER4:   cmp     byte ptr DS:[bp]+3,' '  ;  suppressed zero?
	ja      Retint                  ;
	mov     byte ptr DS:[bp]+3,'0'  ;  place leading zero
Retint: RET
INTSYM  ENDP
CODE     ENDS
	 END    Start
