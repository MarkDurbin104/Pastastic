;********************************************************************
;
;  Program DServ ( Chapter 9 )
;
;  Diskette processing system ( OS independent)
;
;  Author:  Sopin A.I., Voronegh, 1990 --- 1993.      Version 3.0
;  ------                                             22/04/93 11:39
;
;  Floppy disks sectors reading/writing
;
;  The BIOS disk service (interrupt 13h) is used
;
;  Information is output onto the screen in two pages of 256 bytes each
;
;********************************************************************
.model large
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
;  Call screen clearing subroutine and set up the screen color
CLR     MACRO  M$,N$,C$
	mov    ch,M$
	mov    dh,N$
	mov    ah,C$
	Call   Color
	ENDM
;
DIAM0   MACRO   TEXT$,OP$,M$,N$,U$,V$
	mov     TOFF,offset TEXT$    ;  address of text string
	mov     OP,OP$               ;  operation mode
	mov     M,M$                 ;  start line for output
	mov     bx,N$                ;
	mov     N,bx                 ;  last line for output
	mov     U,U$                 ;  don't move cursor
	mov     bx,V$                ;
	mov     V,bx                 ;
	lea     bx,PARM              ;
	push    bx                   ;  address of parameters list for DIAM00
	Call    DIAM00               ;
	ENDM
;
DIAM1   MACRO   TEXT$,OP$,M$,N$,U$,V$
	mov     TOFF,offset TEXT$    ;  address of text string
	mov     OP,OP$               ;  operation mode
	mov     M,M$                 ;  start line for output
	mov     bx,N$                ;
	mov     N,bx                 ;  last line for output
	mov     U,U$                 ;  don't move cursor
	mov     bx,V$                ;
	mov     V,bx                 ;
	lea     bx,PARM              ;
	push    bx                   ;  address of parameters list for DIAM00
	Call    DIAM01               ;
	ENDM
;
;  Clear the output buffer (filling with blanks)
SPACE   MACRO   TXT$,L$
	mov     ax,ds
	mov     es,ax
	lea     di,TXT$
	mov     cx,L$
	cld
	mov     al,' '
	rep     stosb
	ENDM
;  Output number in hexadecimal representation
HEX     MACRO   L$                       ;
	Local   H1                       ;
	mov     cx,L$                    ;  number of bytes
H1:     mov     al,[si]                  ;
	Call    HEXSYM                   ;  convert: HEX ---> SYM
	mov     DS:[di],ax               ;
	add     di,2                     ;
	inc     si                       ;
	loop    H1                       ;
	ENDM
;----------------------------------------------------------
.STACK   256
.DATA
;
TEXT0    db  ' Disk scanning needed?         ?  (Y / N )        ',0
TEXT1    db  ' Diskette parameters:      Cylinders: ??     Heads: 00    '
	 db  'Sectors: ?? ',0
TEXT2    db  ' Reading/modifying disk sectors        '
	 db  ' A.I.Sopin,  VSU  Voronezh  1991   ',0
TEXT3    db  '    Drive: A     ',0
TEXT4    db  '    Drive: A      Total:   Cylinders: xx     Heads: 00    '
	 db  'Sectors: xx ',0
TEXT5    db  '                Address:    Cylinder: 00      Head: 00    '
	 db  ' Sector: 01 ',0
Ltext5   EQU $-TEXT5-2
TEXT6    db  ' Error while reading sector!  AH=xx  CC=xx  HH=xx  SS=xx '
	 db  ' ( press Enter  )    ',0
TEXT7    db  ' Wrong diskette parameters specified - respecify.       ',0
;
TEXT8    DB  ' Attention!  Disk is being scanned.  Please wait.      ',0
TEXT9    db  ' Error while writing sector!  AH=xx  CC=xx  HH=xx  SS=xx '
	 db  ' ( press Enter  )    ',0
I1       DB     53,1             ;  length =53, offset =1
	 DB     0,74h            ;  red letters on grey background
	 DW     0
;
I2       DB     77,0             ;  length =77, offset =0
	 DB     0,74h            ;  red letters on grey background
	 DW     0
;
TXT0     db  'Displacement ----------------- Hex codes -------------------'
	 db  '     ASCII value    ',0
TXT25    db  ' PgDn -next  , PgUp -prev , Esc -exit , F3  -edit sector '
	 db  ', Enter -disk address', 0
Ltxt25   EQU $-TXT25
I25      DB     80,0              ;  length of field =80
	 DB     0,1Eh             ;  feature + yellow letters on blue 
	 DW     0                 ;  end of list  I
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
CC0      db     0                       ;  cylinder number (0...79)
HH0      db     0                       ;  head number  (0  or 1)
SS0      db     0                       ;  sector number  (1...15)
Disk     db     0                       ;  drive number (0-A, 1-B...)
Count3   db     0                       ;  counter of attemts to read 
NCC0     db     0                       ;  maximum cylinder number (0 --- 79)
NHH0     db     0                       ;  maximum head number   (0 --- 1)
NSS0     db     0                       ;  maximum sector number  (1 --- 15)
VV       dw     0                       ;  cursor position: CCHHSS
NN       dw     0                       ;  line for output=6 (disk addres)
MOD0     DB     0                       ;  indicates that CCHHSS was modified
REG      DB     0                       ;  video mode
;
;  List of parameters for subroutines DIAM00 and DIAM01
	 EVEN
PARM     LABEL  WORD                    ; parameter list (address in stack)
OP       dw     0                       ; operation code
M        dw     0                       ; number of first line
N        dw     0                       ; number of last line
TOFF     dw     0                       ; offset of text string
L        dw     80                      ; length of text string
U        dw     0                       ; row of cursor position  (1---25)
V        dw     0                       ; column of cursor position (1---80)
Q        dw     0                       ; accepted row of cursor
S        dw     0                       ; accepted column of cursor
W        dw  2 dup (0)                  ; code of interrupt key
IOFF     dw     0                       ; address of screen parameters
I        dw     80
	 db     0, 07h
;----------------------------------------------------------
.CODE
.Startup
	mov     ah,0Fh                  ;
	int     10h                     ;  read current video mode
	mov     REG,al                  ;  save video mode
	mov     IOFF,0                  ;  format list isn't used
	CLR     1,24,07h                ;
	CLR     25,25,1Eh               ;  yellow letters on blue
	mov     IOFF,offset I25         ;
	DIAM0   TXT25,1,25,25,0,0       ;  output prompt string
	mov     IOFF,0                  ;
;  Output the header and ask for drive letter
Addres: DIAM0   TEXT2,1,2,2,0,0         ;
	DIAM0   TEXT3,3,4,-4,4,12       ;
	and     TEXT3+11,0DFh           ;  force uppercase
	mov     al,0                    ;  default drive A
	cmp     TEXT3+11,'A'
	je      M1                      ;  check for ESC pressed
	mov     al,1                    ;  use drive B
	cmp     TEXT3+11,'B'            ;
	jne     Addres                  ;  invalid drive letter specified
M1:     mov     Disk,al                 ;  drive number
	cmp     byte ptr W,1bh          ;  Esc ?
	jne     ScanD                   ;  ask for disk scanning
	jmp     Exit                    ;
;----------------------------------------------------------
;  Ask for disk scanning to determine the diskette characterisics
ScanD:  DIAM0   TEXT0,3,5,-5,5,32       ;
	and     TEXT0+31,0DFh           ;  force uppercase
	cmp     byte ptr W,1bh          ;  Esc ?
	jne     CodeS                   ;
	jmp     Addres                  ;
CodeS:  cmp     TEXT0+31,'Y'            ;  scanning required?
	je      Ready                   ;
	cmp     TEXT0+31,'N'            ;  scanning not required?
	jne     ScanD                   ;  bad reply - ask again
	Call    PARMDSK                 ;
	jmp     Diskadr                 ;
;  Check for drive ready
Ready:  mov     CC0,0                   ;  cylinder number
	mov     HH0,0                   ;  head number (0---1)
	mov     SS0,1                   ;  sector number (1---8)
	Call    SECTOR                  ;  read sector (3 attempts)
	jnc     Attent                  ;  reading successful
	jmp     Error1                  ;  error message
;  Output message about disk scanning (line 5)
Attent: mov     IOFF,offset I1          ;  address of format list
	DIAM0   TEXT8,1,5,-5,0,0        ;
	mov     IOFF,0                  ;  format list isn't used
;----------------------------------------------------------
;  Scanning the diskette to dtermine CC, HH, SS
;  Determining the number of cyilinders CC
ScanCC: mov     CC0,0                   ;  cylinder number
	mov     HH0,0                   ;  head number (0---1)
	mov     SS0,1                   ;  sector number (0---8)
CyclCC: Call    SECTOR                  ;  read sector (3 attempts)
	jc      ScanHH                  ;  sector hasn't been read
	inc     CC0                     ;  to next cylinder
	jmp     short CyclCC            ;
;  Determining the number of heads HH
ScanHH: mov     al,CC0
	dec     al                      ;  extra cylinder was read
	mov     NCC0,al                 ;  maximum  cylinder number
	mov     NHH0,0                  ;  maximum head number =0 (one side)
	mov     TEXT4+53,'1'            ;  head number =0 (one side)
	mov     CC0,0                   ;  cylinder number =0
	mov     HH0,1                   ;  head number  = 1 (second side)
	mov     SS0,1                   ;  sector number   =1
	Call    SECTOR                  ;  read sector (3 attempts)
	jc      ScanSS                  ;  sector hasn't been read
	mov     TEXT4+53,'2'            ;  second side (head =1)
	mov     NHH0,1                  ;  maximum head number =1 (two sides)
;  Determining the number of sectors  SS
ScanSS: mov     CC0,0                   ;  cylinder number =0
	mov     HH0,0                   ;  head number  = 1 (first side)
	mov     SS0,1                   ;  sector number   =1
CyclSS: Call    SECTOR                  ;  read sector (3 attempts)
	jc      Diskparm                ;  next sector hasn't been read
	inc     SS0                     ;  to next cylinder
	jmp     short CyclSS            ;
;----------------------------------------------------------
;  Output characteristics of disk read  (CC/HH/SS)
DiskParm:
	CLR     5,24,07h                ;  clear lines  5 --- 24
	mov     al,SS0                  ;
	dec     al                      ;  next number was specified
	mov     NSS0,al                 ;  maximum  sector number
	lea     bp,TEXT4+67             ;  target for edited value
	Call    INTSYM                  ;  convert number of setors
	mov     al,NCC0                 ;  maximum  cylinder number
	inc     al                      ;  cylinders are counted from 0
	lea     bp,TEXT4+38             ;  target for edited value
	Call    INTSYM                  ;  convert number of cylinders
	DIAM0   TEXT4,1,4,-4,0,0        ;
;----------------------------------------------------------
;  Ask for cylinder number CC and input that number
Diskadr:mov     VV,39                   ;
GetCC:  DIAM0   TEXT5,3,5,-5,5,VV       ;
	cmp     byte ptr W+1,49h        ;  PgUp ?
	je      JmpAdr                  ;  to preceeding parameter
	cmp     byte ptr W,1Bh          ;  Esc ?
	jne     ConvCC                  ;
JmpAdr: jmp     Addres                  ;
;  Convert the number of the cylinder  CC
ConvCC: lea     bp,TEXT5+38             ;
	mov     si,2                    ;  counter of source characters
	Call    SYMIN4                  ;  convert SYM --- INT
	mov     CC0,al                  ;
	jnc     ConvHH                  ;
	DIAM0   TEXT7,1,6,-6,0,0        ;  output error message
	jmp     Diskadr                 ;  repeat input
;  Ask for the head number HH  (0 or 1) and input that number
ConvHH: mov     al,CC0                  ;
	lea     bp,TEXT5+38             ;  target for edited value  CC
	Call    INTSYM                  ;  convert INT ---> SYM
	DIAM0   TEXT5,3,5,-5,5,53       ;
	cmp     byte ptr W+1,49h        ;  PgUp ?
	je      JmpC                    ;
	cmp     byte ptr W,1bh          ;  Esc ?
	jne     ConvH                   ;
JmpC:   jmp     Diskadr                 ;  repeat asking for CC
;  Convert the head number HH  (0 or 1)
ConvH:  lea     bp,TEXT5+52             ;
	mov     si,2                    ;  counter of source characters
	Call    SYMIN4                  ;  convert SYM --- INT
	mov     HH0,al                  ;
	jc      Goerr                   ;
	cmp     al,1                    ;  head number > 1 requested?
	jng     ConvSS                  ;
	DIAM0   TEXT7,1,6,-6,0,0        ;  output error message
Goerr:  jmp     ConvHH                  ;  output error message
;  Ask for sector number SS and input that number
ConvSS: DIAM0   TEXT5,3,5,-5,5,68       ;
	cmp     byte ptr W+1,49h        ;  PgUp ?
	je      JmpH                    ;
	cmp     byte ptr W,0Dh          ;  Enter ?
	je      ConvS                   ;
	cmp     byte ptr W,1Bh          ;  Esc ?
	jne     ConvS                   ;
JmpD:   jmp     Diskadr                 ;  ask for cylinder number again
JmpH:   jmp     ConvHH                  ;  ask for head number again
;  Convert sector number SS
ConvS:  lea     bp,TEXT5+67             ;
	mov     si,2                    ;  counter of source characters
	Call    SYMIN4                  ;  convert SYM --- INT
	mov     SS0,al                  ;
	mov     Count3,3                ;  counter of attempts to read
	jnc     Rdsect                  ;
	DIAM0   TEXT7,1,6,-6,0,0        ;  output error message
	jmp     ConvSS                  ;  repeat parameters input 
;----------------------------------------------------------
;  Read the sector (512 bytes) with the number required
Rdsect: Call    SECTOR                  ;  read sevtor required
	jnc     P1                      ;  sector is read succesfully
	lea     si,BUFER                ;  source
	lea     di,TEXT5                ;  target
	mov     cx,Ltext5               ;  length of data transferred
	Call    MOVE                    ;  transfer string of addresses
	jmp     Error1                  ;
;----------------------------------------------------------
;  Output sector content onto the screen (lines  5---22)
;  Editing and output the first page ( 256  bytes)
P1:     lea     si,RDBUF                ;  source data
	lea     bp,Disp1                ;
	Call    SCREEN                  ;  output first 256 bytes
	mov     BUFER+5,'1'             ;  page number
	DIAM1   BUFER,3,5,22,5,39       ;  output buffer onto screen
	lea     si,BUFER                ;  source
	lea     di,TEXT5                ;  target
	mov     cx,Ltext5               ;  length of data transferred
	Call    MOVE                    ;  transfer string of addresses
	lea     di,RDBUF                ;  target data
	Call    MODSECT                 ;  checking for sector modification
	cmp     MOD0,1                  ;  address was modified
	jne     MOD1                    ;
	jmp     Rdsect                  ;  output new sector
MOD1:   Call    MODCHS                  ;  process changed values of CC, HH, SS
	Call    TABUL                   ;  changing disk address
;  Process keys: Esc, PgDn, PgUp
Esc1:   cmp     byte ptr W,1Bh          ;  Esc ?
	je      JmpBeg                  ;
	cmp     byte ptr W+1,51h        ;  PgDn ?
	je      P2                      ;  output second part of sector
	cmp     byte ptr W+1,49h        ;  PgUp ?
	jne     P2                      ;
	Call    Back                    ;  read backwards
	jmp     Rdsect                  ;  read sector again
JmpBeg: jmp     Diskadr
;  Editing and output second page (last 256 bytes)
P2:     lea     si,RDBUF+256            ;  source data
	lea     bp,Disp2                ;
	Call    SCREEN                  ;  output last 256 bytes
	mov     BUFER+5,'2'             ;  page number
	DIAM1   BUFER,3,5,22,5,39       ;  output buffer onto screen
	lea     si,BUFER                ;  source
	lea     di,TEXT5                ;  target
	mov     cx,Ltext5               ;  length of data transferred
	Call    MOVE                    ;  transfer string of addresses
	lea     di,RDBUF                ;  target data
	Call    MODSECT                 ;  check for sector mofifying
	cmp     MOD0,1                  ;  sector was modified?
	jne     MOD2                    ;
	jmp     Rdsect                  ;  output new sector
MOD2:   Call    MODCHS                  ;  process changed values of CC, HH, SS
	Call    TABUL                   ;  change disk address
;  Process keys: Esc, PgDn, PgUp
Esc2:   cmp     byte ptr W,1Bh          ;  Esc ?
	je      JmpBeg                  ;  back to beginning
	cmp     byte ptr W+1,49h        ;  PgUp ?
	jne     PgDn2                   ;
	jmp     P1                      ;
PgDn2:  cmp     byte ptr W+1,51h        ;  PgDn ?
	je      Next2                   ;
	jmp     P2                      ;
Next2:  Call    NEXT                    ;
	jmp     Rdsect                  ;  to processing next sector
;----------------------------------------------------------
;  Finish of the program
Exit:    mov    ah,0                    ;  function 0 - set video mode
	 mov    al,REG                  ;  restore original video mode
	 int    10h                     ;  BIOS video service call
	 mov    ax,4C00h                ;  function 4Ch - terminate process
	 int    21h                     ;  MS-DOS service call
;----------------------------------------------------------
;
;  Read sector (512 bytes) with the address specified
;
;----------------------------------------------------------
SECTOR  PROC    NEAR
	mov     Count3,3                ;  counter of attempts to read
Read3:  xor     ah,ah                   ;  function 00h - reset controller
	int     13h                     ;  BIOS disk service call
	jc      RetS                    ;  exit if error (error code in AH)
	mov     ax,ds                   ;
	mov     es,ax                   ;  ES points to data segment
	lea     bx,RDBUF                ;  address of read buffer
	mov     ch,CC0                  ;  cylinder number
	mov     cl,SS0                  ;  sector number (1---8)
	mov     dh,HH0                  ;  head number (0---1)
	mov     dl,Disk                 ;  disk drive (0 -A, 1 -B...)
	mov     al,1                    ;  number of sectors to read 
	mov     ah,2                    ;  function 02h - read sectors
	int     13h                     ;  BIOS disk service call
	jnc     RetS                    ;  sector was read successfully
	dec     Count3                  ;  decrement counter of attempts
	jg      Read3                   ;  try to read sector again
RetS:   RET                             ;
SECTOR  ENDP
;  Output error message (error while reading sector in line 6)
Error1: mov     al,ah                   ;  error code
	Call    HEXSYM                  ;  convert HEX ---> SYM
	mov     word ptr TEXT6+33,ax    ;  transfer error code
	mov     al,CC0                  ;
	lea     bp,TEXT6+40             ;  target for edited value
	Call    INTSYM                  ;  convert INT ---> SYM
	mov     al,HH0                  ;
	lea     bp,TEXT6+47             ;  target for edited value
	Call    INTSYM                  ;  convert INT ---> SYM
	mov     al,SS0                  ;
	lea     bp,TEXT6+54             ;  target for edited value
	Call    INTSYM                  ;  convert INT ---> SYM
	mov     IOFF,offset I2          ;
	DIAM0   TEXT6,2,6,-6,0,0        ;  output message
	mov     IOFF,0                  ;
	CLR     5,24,07h                ;  clear screen
	jmp     Addres                  ;  ask for disk address again
;----------------------------------------------------------
;
;  Writing modified sector
;
;  Is performed when the cursor is within the data area
;
;  and the F3 key has been pressed
;
;  DI - address of sector buffer in data segment
;
;----------------------------------------------------------
MODSECT  PROC   NEAR
	 mov    MOD0,0                  ;  clear modification indicator
	 cmp    byte ptr W+1,3Dh        ;  F3 ?
	 jne    RetModS                 ;  no, exit
	 cmp    byte ptr Q,7            ;  cursor in data area ?
	 jl     RetModS                 ;  no, exit
	 cmp    byte ptr Q,22           ;  cursor in data area ?
	 jg     RetModS                 ;  no, exit
	 cmp    byte ptr S,14           ;  cursor in data area ?
	 jl     RetModS                 ;  no, exit
	 cmp    byte ptr S,72           ;  cursor in data area ?
	 jng    C0                      ;  yes
RetModS: RETN                           ;
;  Transfer modified data into the sector buffer
C0:      PUSHR                          ;
	 mov    MOD0,1                  ;  modification indicator
	 mov    ax,ds                   ;
	 mov    es,ax                   ;  ES points to data segment
	 lea    si,BUFER+173            ;  address of screen string beginning
	 mov    ADRBUF,si               ;  save address of string
	 mov    dx,16                   ;  number of lines output
;  Outward cycle (16 lines)
C1:      mov    cx,16                   ;  number of elements line
C2:      mov    ax,[si]                 ;  nested cycle starts here
	 Call   SYMHEX                  ;  convert:  SYM ---> HEX
	 mov    [di],al                 ;  transfer hexadecimal value
	 add    si,3                    ;  address of next two bytes
	 inc    di                      ;  address of next byte in sector
	 loop   C2                      ;  next step of nested cycle
;  Modify parameters of the outward cycle (to next line)
	 mov    si,ADRBUF               ;
	 add    si,80                   ;  address of next string
	 mov    ADRBUF,si               ;  save address of string
	 dec    dx                      ;  number of strings left
	 jnz    C1                      ;  to beginning of outward cycle
;  Writing the modified sector
	 mov    Count3,3                ;  counter of attempts to write
Write3:  xor    ah,ah                   ;  function 00h - reset controller
	 int    13h                     ;  BIOS disk service call
	 mov    ax,ds                   ;
	 mov    es,ax                   ;  ES points to data segment
	 lea    bx,RDBUF                ;  address of buffer for writing ES:BX
	 mov    ch,CC0                  ;  cylinder number
	 mov    cl,SS0                  ;  sector number (1---8)
	 mov    dh,HH0                  ;  head number (0---1)
	 mov    dl,Disk                 ;  disk drive (0 -A, 1 -B...)
	 mov    al,1                    ;  number of sectors to write
	 mov    ah,3                    ;  function 03h - write sectors
	 int    13h                     ;  BIOS disk service call
	 jnc    Retwr                   ;  sector has been written 
	 dec    Count3                  ;  decrease number of attempts
	 jg     Write3                  ;  try to write again
	 jmp    short Error2            ;  error while writing sector
Retwr:   POPR                           ;
	 RETN                           ;
;  Output message "error while writing sector" (line =6)
Error2:  mov    al,ah                   ;  error code
	 Call   HEXSYM                  ;  convert HEX ---> SYM
	 mov    word ptr TEXT9+33,ax    ;  transfer eror code
	 mov    al,CC0                  ;
	 lea    bp,TEXT9+40             ;  target for edited data
	 Call   INTSYM                  ;  convert INT ---> SYM
	 mov    al,HH0                  ;
	 lea    bp,TEXT9+47             ;  target for edited data
	 Call   INTSYM                  ;  convert INT ---> SYM
	 mov    al,SS0                  ;
	 lea    bp,TEXT9+54             ;  target for edited data
	 Call   INTSYM                  ;  convert INT ---> SYM
	 mov    IOFF,offset I2          ;
	 DIAM0  TEXT9,2,6,-6,0,0        ;  output message
	 mov    IOFF,0                  ;
	 CLR    6,6,07h                 ;  clear string
	 POPR                           ;
	 RETN                           ;
MODSECT  ENDP
;----------------------------------------------------------
;
;  To process the next sector
;
;----------------------------------------------------------
;  Increase the sector number by 1
NEXT    PROC    NEAR
	mov     al,SS0                  ;  preceeding sector number
	inc     al                      ;  number of next sector
	cmp     al,NSS0                 ;  to other side?
	jg      ModHH                   ;
	mov     SS0,al                  ;  transfer number of next sector
	jmp     RetM                    ;  to processing next sector
;  Increase the head number by 1
ModHH:  mov     SS0,1                   ;  first sector of next cylinder
	mov     al,HH0                  ;  number of head (side) processed
	inc     al                      ;  number of next head
	cmp     al,NHH0                 ;  to next cylinder?
	jg      ModCC                   ;
	mov     HH0,al                  ;  transfer number of next head
	jmp     RetM                    ;  to processing next sector
;  Increase the cylinder number by 1
ModCC:  mov     SS0,1                   ;  first sector of next cylinder
	mov     HH0,0                   ;  initial head number =1
	mov     al,CC0                  ;  number of preceeding cylinder
	inc     al                      ;  number of next cylinder
	cmp     al,NCC0                 ;  all cylinders processed ?
	jg      RetM                    ;  yes, not move
	mov     CC0,al                  ;  transfer number of next cylinder
RetM:   RETN
NEXT    ENDP
;----------------------------------------------------------
;
;   Reading disk sectors backwards
;
;----------------------------------------------------------
BACK     PROC   NEAR
;  decreasing sector number by 1
DecSS:   mov    al,SS0                  ;  sector number
	 dec    al                      ;  preceeding sector number
	 cmp    al,1                    ;  to preceeding cylinder?
	 jl     DecHH                   ;
	 mov    SS0,al                  ;  transfer preceeding sector number
	 jmp    Retb                    ;  to processing preceeding sector
;  decreasing head number by 1
DecHH:   mov    SS0,1                   ;  initial sector number =1
	 mov    al,HH0                  ;  number of current head
	 dec    al                      ;  number of preceeding head
	 jl     DecCC                   ;
	 mov    HH0,al                  ;  transfer number of preceeding head
	 jmp    Retb                    ;  to processing preceeding sector
;  decreasing cylinder number by 1
DecCC:   mov    SS0,1                   ;  first sector of preceeding cylinder
	 mov    HH0,0                   ;  initial head number =0
	 mov    al,CC0                  ;  number of current cylinder
	 dec    al                      ;  number of preceeding cylinder
	 jl     Retb                    ;
	 mov    CC0,al                  ;  transfer number of prec. cylinder
Retb:    RETN
BACK     ENDP
;----------------------------------------------------------
;
;  Subroutine for converting an integer number into character string
;
;  AL  - source number (is converted to a word)
;
;  BP  - address of output character string
;
;----------------------------------------------------------
INTSYM  PROC    NEAR
	cbw                             ;  convert byte to word
	xor     dx,dx                   ;  high part =0
	mov     si,2                    ;  number of character in result
	Call    INSYM4                  ;  convert integer
	cmp     byte ptr DS:[bp],' '    ;  suppressed zero present?
	jne     Retint                  ;
	mov     byte ptr DS:[bp],'0'    ;  put leading zero
Retint: RETN
INTSYM  ENDP
;----------------------------------------------------------
;
;  Subroutine for creating the display buffer (256 bytes)
;
;  SI  - address of sector buffer
;
;  BP  - address of Displacement Table
;
;----------------------------------------------------------
SCREEN   PROC   NEAR
	 PUSHR                          ;  save all registers
	 PUSHR  <si,bp>                 ;
	 SPACE  BUFER,2000              ;  clear screen buffer
	 lea    si,TEXT5                ;  source
	 lea    di,BUFER                ;  target
	 mov    cx,Ltext5               ;  length of data transferred
	 Call   MOVE                    ;  transfer string of addresses
;  Create disk addresses (line =5)
	 mov    al,CC0                  ;  address of cylinder
	 lea    bp,BUFER+38             ;  target for edited value
	 Call   INTSYM                  ;  convert INT --- SYM
	 mov    al,HH0                  ;  address of head
	 lea    bp,BUFER+52             ;  target for edited value
	 Call   INTSYM                  ;  convert INT --- SYM
	 mov    al,SS0                  ;  number of sector
	 lea    bp,BUFER+67             ;  target for edited value
	 Call   INTSYM                  ;  convert INT --- SYM
;  Create header (line 6)
	 lea    si,TXT0                 ;  source
	 lea    di,BUFER+80             ;  target
	 mov    cx,80                   ;  length of data transferred
	 Call   MOVE                    ;  transfer header
	 POPR   <bp,si>                 ;
	 lea    di,BUFER+160            ;  address of screen string beginning
	 mov    ADRBUF,di               ;  save address of string
	 mov    dx,16                   ;  number of lines on screen
;  Outward cycle (16 lines)
S0:      PUSHR  <si,di>                 ;
	 inc    di                      ;  target
	 mov    si,bp                   ;  source
	 mov    cx,10                   ;  length of data transferred
	 Call   MOVE                    ;  transfer margins
	 POPR   <di,si>                 ;
	 mov    cx,16                   ;  number of characters in line
	 mov    bx,di                   ;  save address of string
;  Nested cycle (16 bytes)
S1:      mov    al,[si]                 ;  start of nested cycle
	 Call   HEXSYM                  ;  convert: HEX ---> SYM
	 mov    DS:[di+13],ax           ;  transfer hexadecimal value
	 mov    al,[si]                 ;  ASCII character
	 cmp    al,1bh                  ;  Esc ?
	 jg     S2                      ;
	 mov    al,20h
S2:      mov    [bx+63],al              ;  transfer ASCII character
	 add    di,3                    ;  address of next pair of byte
	 inc    bx                      ;  address of next ASCII character
	 inc    si                      ;  address of byte in sector
	 loop   S1                      ;  to repeat of nested cycle
;  Modify parameters of the outward cycle (to the next line)
	 mov    di,ADRBUF               ;
	 add    di,80                   ;  address of next string
	 mov    ADRBUF,di               ;  save address of string
	 add    bp,10                   ;  address of next element
	 dec    dx                      ;  number of strings left
	 jnz    S0                      ;  to beginning of outward cycle
;  Put edited addresses into the string  TEXT5
	 lea    si,BUFER                ;  source
	 lea    di,TEXT5                ;  target
	 mov    cx,Ltext5               ;  length of data transferred
	 Call   MOVE                    ;  transfer string of addresses
	 POPR                           ;
	 RETN                           ;
SCREEN   ENDP
;----------------------------------------------------------
;
;  Change the disk address (the Enter key)
;
;----------------------------------------------------------
TABUL   PROC    NEAR
	cmp     byte ptr W,0Dh          ;  Enter ?
	je      SS39                    ;
	RETN
SS39:   pop     ax                      ;  restore stack
	cmp     S,39                    ;  cursor at cylinder position ?
	je      VV53                    ;  set at the head position and repeat
	cmp     S,41                    ;  cursor at cylinder position ?
	ja      SS53                    ;
VV53:   jmp     ConvHH                  ;  repeat output (cursor at  HH)
;  Check wheteher the cursor is located in head position (jump to sector)
SS53:   cmp     S,53                    ;  cursor at head position ?
	je      VV68                    ;
	cmp     S,54                    ;  cursor at head position ?
	jne     SS68                    ;
VV68:   jmp     ConvSS                  ;  repeat output (cursor at  SS)
SS68:   jmp     Diskadr                 ;  repeat output (cursor at  CC)
TABUL   ENDP
;----------------------------------------------------------
;
;   Subroutine for processing athe sector number
;
;----------------------------------------------------------
MODCHS   PROC   NEAR
	 lea    bp,BUFER+38             ;  value of cylinder number  CC
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 mov    CC0,al                  ;  new value of cylinder number
	 lea    bp,BUFER+52             ;  value of head number  HH
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 mov    HH0,al                  ;  new value of head number
	 lea    bp,BUFER+67             ;  value of sector number  SS
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 mov    SS0,al                  ;  new value of sector number
Retmod:  RET
MODCHS   ENDP
;----------------------------------------------------------
;
;   Ask for diskette parameters (CC, HH, SS)
;
;----------------------------------------------------------
PARMDSK  PROC   NEAR
InpCHS:  DIAM0  TEXT1,3,5,-5,5,39       ;
	 lea    bp,TEXT1+38             ;  value of cylinder number  CC
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 dec    al                      ;  cylinder number : 0 --- 80
	 mov    NCC0,al                 ;  maximum  cylinder number
	 jnc    InpHH                   ;
	 DIAM0  TEXT7,1,6,-6,0,0        ;  output error message
	 jmp    InpCHS                  ;  repeat input
;
InpHH:   DIAM0  TEXT1,3,5,-5,5,53       ;
	 lea    bp,TEXT1+52             ;  value of head number  HH
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 dec    al                      ;
	 mov    NHH0,al                 ;  maximum  head number
	 jnc    InpSS
	 DIAM0  TEXT7,1,6,-6,0,0        ;  output error message
	 jmp    InpHH                   ;  repeat input
;
InpSS:   DIAM0  TEXT1,3,5,-5,5,68       ;
	 lea    bp,TEXT1+67             ;  value of sector number  SS
	 mov    si,2                    ;  counter of source characters
	 Call   SYMIN4                  ;  convert SYM --- INT
	 mov    NSS0,al                 ;  maximum  sector number
	 jnc    RetCHS
	 DIAM0  TEXT7,1,6,-6,0,0        ;  output error message
	 jmp    InpSS                   ;  repeat input
RetCHS:  RET
PARMDSK  ENDP
	 END
