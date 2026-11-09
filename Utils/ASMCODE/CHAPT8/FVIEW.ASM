;
;       Program FView ( Chapter 8 )
;
	page    55,132
;**********************************************************************
;
;  The file browsing program.  Version  3.3
;  Last update:   16/04/93 10:49
;
;  Author: A.I.Sopin,   VSU,   Voronezh,  Russia  
;
;  Usage:  FVIEW [path]filename
;
;  Keys used:
;
;  "PgDn"           - scroll by one screen down
;
;  "PgUp"           - scroll by one screen up
;
;  "Home"           - first screen
;
;  "End"            - last screen
;
;  ""              - scroll by one line down
;
;  ""              - scroll by one line up
;
;  "->"              - scroll by one position to the right
;
;  "<-"              - scroll by one position to the left
;
;  "Ctrl" + "Home"  - to the beginning of the line 
;
;  "Esc"            - finish working and return to MS-DOS
;
;  23 lines of file are shown on the screen
;
;  The MS-DOS disk service (Interrupt 21h) is used
;
;**********************************************************************
	NAME FVIEW
;**********************************************************
;   MACRO  Definitions
;**********************************************************
SetCurs MACRO   Row,Column
	mov     ah,2                    ;  function 02h - set cursor
	xor     bh,bh                   ;  video page 0
	mov     dh,&Row                 ;  ROW
	mov     dl,&Column              ;  COLUMN
	int     10h                     ;  BIOS video service
	ENDM
;  Clear screen and set color
SetCol  MACRO   Row,Column,Leng,Attrib
	mov     al,&Column              ;  initial position for output
	SetCurs Row,al                  ;
	mov     al," "                  ;  AL - character for output
	mov     bl,&Attrib              ;  BL - attribute
	mov     ah,9                    ;  output character and attribute
	xor     bh,bh                   ;  video page 0 is used
	mov     cx,&Leng                ;  number of charcacters to be output
	int     10h                     ;  BIOS video service
	ENDM
;  Output string onto the screen
OutStr  MACRO   String,Row,Column,Leng
	SetCurs &Row,&Column            ;
	lea     si,&String              ;  DS:SI - address of string for output
	mov     cx,&Leng                ;  maximum length of string
	Call    PUTSTR                  ;  output string
	SetCurs 25,80                   ;
	ENDM
;-----------------------------------------------------------------------
STAC     SEGMENT STACK
	 DW      16 dup (?)
LSTAC    EQU     $
STAC     ENDS
;-----------------------------------------------------------------------
DATA     SEGMENT  PARA PUBLIC 'DATA'
ES0      DW     0                 ;  segment address for  PSP
;  Characteristic of the block read
AMEM     LABEL  DWORD             ;  offset + segment address for LDS
OFFMEM   DW     0                 ;  buffer start addres (offset)
SEGMEM   DW     0                 ;  segment address of memory received
SEGSTR   DW     0                 ;  segment address of buffers string
HANDLE   DW     0                 ;  handle value for file to be processed
DX0      DW     0                 ;  high part of file length
AX0      DW     0                 ;  low  part of file length
CXL      DW     0                 ;  offset of last block from file start (high)
DXL      DW     0                 ;  offset of last block from file start (low)
CXF      DW     0                 ;  offset of screen from file start (high)
DXF      DW     0                 ;  offset of screen from file start (low)
ABLOK    DW     0                 ;  address of current byte in filke
Count    DW     0                 ;  length of block read (rest)
DXB      DW     0                 ;  offset of screen beginning in file
LENG0    DW     0                 ;  length of part of previous block
				  ;  on current screen
LENGF    DW     0                 ;  length of file part on screen
NREC     DW     0                 ;  number of records preceeding first shown
;  Characteristics of screen buffer
ASTR     DW     0                 ;  address of character in string
LMOV     DW     0                 ;  length of string in buffer
ABUF     DW     0                 ;  address of beginning of string BUF0
NSTR     DW     0                 ;  number of filled strings in buffer
DRL0     DW     0                 ;  value of screen shift to the right
ERROP    DW     0                 ;  ERROP > 0 -Error on open
ERR0     DW     0                 ;  error flag (for GetMem); error if not 0
VIDSEG   DW     0                 ;  segment address of video buffer
CGA      DB     0                 ;  CGA indicator, is 1 when CGA active
NB       DB     1                 ;  number of blocks on screen (1 or 2)
EOD      DB     0                 ;  EOD = 1 -EndOfFile indicator
W        label  byte
KbdASCII DB     0
KbdScan  DB     0                                         
VMODE    DB     0                 ;  Original video mode
;  Texts of information lines on screen and error messages
STR1     DB     " PATH: "
PATH     DB     64 dup (0)
STR25    DB     " Use Keys: PgDn, PgUp, Home, End, "
	 DB     24, 44, 32, 25, 44, 32, 26, 44, 32, 27, 44
	 DB     " Ctrl+Home,  Esc -Exit", 0
ERR00    DB     ' Not enough  memory !!! (press  Enter) ',0
ERR01    DB     ' File not found !!! (press  Enter) ',0
ERR02    DB     ' Data error !!! (Press  Enter) ',0
DATA     ENDS
;-----------------------------------------------------------------------
_TEXT   SEGMENT PARA PUBLIC 'CODE'
	ASSUME  CS:_TEXT, DS:DATA, SS:STAC
;-------------------------------------------------------------------
START:  mov     bx,DS             ;  PSP  segment address
	mov     ax,DATA           ;  data segment basing
	mov     ds,ax             ;  DS points to DATA segment
	mov     ax,STAC           ;  address of STACK segment
	mov     SS,ax             ;  switch to internal satck
	mov     SP,word ptr LSTAC ;  stack size in bytes
	mov     ES0,bx            ;  PSP  segment address
;  Determining and save the current video mode
	mov     ah,0Fh            ;  function 0Fh - get video mode
	int     10h               ;  BIOS video service call
	mov     VMODE,al          ;  save current video mode
;  Free memory above the program end
	mov     SEGMEM,0          ;  no memory has been allocated
	mov     bx,ZSEG           ;  program end address
	mov     ax,es             ;  segment address of the program beginning
	sub     bx,ax             ;  memory size needed
	mov     ah,4Ah            ;  DOS function number
	int     21h               ;  free memory
	mov     ERR0,ax           ;  Error Code
	jnc     GetMem            ;  Memory reallocated!
	lea     dx,ERR00          ;  address of error message
	jmp     TypErr
;  Allocate the maximum memory area for the buffer
GetMem: mov     bx,0FFFh          ;  request memory area of the maximum size
	mov     ah,48h            ;  DOS function number
	int     21h               ;  DOS service call
	jnc     Norm              ;  jump if successful
	int     21h               ;  BX = size of largest available block!
	jnc     Norm              ;  jump if memory allocated
	lea     dx,ERR00          ;  address of error message
	jmp     TypErr            ;  otherwise output error message
;-------------------------------------------------------------------
Norm:   mov     SEGMEM,ax         ;  AX:0 -segment address of allocated
	xor     ah,ah             ;  function 0 - set video mode
	mov     al,03             ;  80x25  Text
	int     10h               ;  BIOS video service call
;  Parsing the file name in command line
	mov     ERROP,1           ;  Error on Open
	mov     es,ES0            ;  PSP segment address
	mov     si,81h            ;  address of command line tail
	xor     ch,ch             ;  clear high part
	mov     cl,ES:[80h]       ;  CX - length of command string
	and     cx,cx             ;  no parameters?
	jnz     GetPath           ;  parameters specified
	jmp     ErrMsg            ;  output error message
;-------------------------------------------------------------------
;  Skip blanks before file name
GetPath:cmp     byte ptr ES:[si]," " ;  blank?
	ja      M1                   ;  no, take character
	inc     si                   ;  to next character
	loop    GetPath              ;  repeat cycle
	jmp     ErrMsg               ;  Put Error Message
;  Checking wheter the root directory or disk letter specified
M1:     lea     di,PATH              ;  target for full file name
	cmp     word ptr ES:[si]+1,"\:" ;  root directory?
	je      M7                   ;  full path specified!
	cmp     byte ptr ES:[si]+1,":"  ;  disk letter specified?
	jne     M2                   ;  create full path
;  Pass drive letter and determine current directory on that drive
	mov     dl,ES:[si]           ;  drive letter from command line
	and     dl,0DFh              ;  uppercase
	mov     PATH,dl              ;  put drive letter
	sub     dl,40h               ;  0 - current, 1 -A ....
	add     si,2                 ;  address of file name in command line
	sub     cx,2                 ;  length of command line tail
	jmp     short M3             ;  put current directory and file name
;  Create full path (drive letter and direxctory name)
M2:     mov     ah,19h               ;  Get default Disk Number
	int     21h                  ;  DOS service call
	add     al,41h               ;  drive letter
	mov     PATH,al              ;  store drive letter
	xor     dl,dl                ;  DL = 0 - default drive
;  Determining the current directory
M3:     mov     word ptr PATH+1,'\:' ;  
	push    si                   ;  address of file name in command line
	lea     si,PATH+3            ;  DS:SI point to path string
	mov     ah,47h               ;  Get Current Directory
	int     21h                  ;  DOS service call
	push    cx                   ;  length of name in command line
	mov     cx,64                ;  max ength of name 
;  Determining end of the directory name read
M4:     cmp     byte ptr DS:[si]," " ;  end of name(ASCIIZ) ?
	jna     M5                   ;
	inc     si                   ;  to next character
	loop    M4                   ;
;  Insert  "\"  before file name
M5:     cmp     byte ptr DS:[si]-1,"\"  ;  backslash already present?
	je      M6                   ;  yes, do nothing
	mov     byte ptr DS:[si],"\" ;  put "\" before file name
	inc     si                   ;  address of file name in PATH
M6:     mov     di,si                ;  destination
	pop     cx                   ;  length of command line tail
	pop     si                   ;  source (address of command line tail)
;  Copy filke name from command line
M7:     mov     ds,ES0               ;  PSP segment address
	mov     ax,DATA              ;  data segment
	mov     es,ax                ;  ES points to data segment
	cld                          ;  rigth direction
	rep     movsb                ;  copy file name from command line
	mov     byte ptr ES:[di],0   ;  0 at end of string
;-----------------------------------------------------------------------
;  Open the file required for reading
Open:   mov     ax,DATA              ;  address of data segment
	mov     ds,ax                ;  DS points to data segment
	xor     al,al                ;  Read File
	lea     dx,PATH              ;  DS:DX - address of path string
	mov     ah,3Dh               ;  Function 3Dh - Open File
	int     21h                  ;  DOS service call
	jnc     Fsize                ;  O'K !
;  Output message "File not found" and exit
ErrMsg: mov     ax,DATA              ;  data segment basing
	mov     ds,ax                ;
	lea     dx,ERR01             ;  address of error message
	jmp     TypErr               ;  otherwise output error message
;  Determining length of file
FSize:  mov     HANDLE,ax         ;  store value of file handle
	mov     ERROP,0           ;  Sucsesful Open
	mov     bx,HANDLE         ;  
	mov     ax,4202h          ;  AL = 2 - position to the end of file
	xor     cx,cx             ;  high part of offset
	xor     dx,dx             ;  low part of offset
	int     21h               ;  DOS service call
	mov     AX0,ax            ;  low part of file length
	mov     DX0,dx            ;  high part of file length
;  Position for readinfg from the beginning of the file
	mov     bx,HANDLE         ;  
	mov     ax,4200h          ;  AL =0 - count from file beginning
	xor     cx,cx             ;  high part of offset
	xor     dx,dx             ;  low part of offset
	int     21h               ;  DOS service call
;  Determining an offset of the last block from the biginning of the file
	mov     cx,32768          ;  divisor and multiplier
	mov     ax,AX0            ;
	mov     dx,DX0            ;
	div     cx                ;  AX - result, DX - remainder
	xor     dx,dx             ;  clear high part
	mul     cx                ;  AX - low part, DX - high part
	mov     CXL,dx            ;  high part of offset
	mov     DXL,ax            ;  low part of offset
	mov     DRL0,0            ;  clear shift counter
;-----------------------------------------------------------------------
;  Define screen attributes and output information strings
CLRSCR: Call    VIDTYP            ;  determine video adapter type
	SetCol  0,0,80,30h        ;  clear line 1
	SetCol  1,0,80*23,1Bh     ;  clear lines 2-24
	SetCol  24,0,80,30h       ;  clear line 25
	OutStr  STR1,0,0,80       ;  output first line (file name)
	OutStr  STR25,24,0,80     ;  output last line (Help)
;  Preparing parameters for passing file into video buffer
INIT0:  mov     CXF,0             ;  high part (screen beginning)
	mov     DXF,0             ;  low part (screen end)
INIT1:  mov     NSTR,23           ;  maximum number of screen lines
	mov     ABUF,160          ;  address of first byte of screen buffer
	mov     ASTR,0            ;  address of beginning of buffer string
	mov     LMOV,0            ;  length of buffer string created
	mov     KbdScan,0         ;  clear value of SCAN code read
	mov     ax,SEGMEM         ;  
	add     ax,800h           ;  number of paragraphs in file block
	mov     SEGSTR,ax         ;  new segment address
;-----------------------------------------------------------------------
;
;  Read the records of the input file (32768 bytes)
;
;-----------------------------------------------------------------------
READ:   Call    RDBLOK            ;  read block of file (up 32768 bytes
	jnc     EOF1              ;  End of file?
	lea     dx,ERR02          ;  yes - error 2 (data error)
	jmp     TypErr            ;  output error message
;  Check number of blocks on screen
EOF1:   mov     NB,1              ;  one block on screen
	cmp     KbdScan,50h       ;  SCAN -code   ?
	jne     M8                ;  ordinar processing
	cmp     NSTR,23           ;  second record (screen beginning) ?
	je      M9                ;  check for screen beginning
	jl      M10               ;  not screen beginning - two blocks
	mov     DXB,0             ;  if record is skipped, DXB = 0
	jmp     M11               ;  one block on screen !!!
;  If one block and screen beginning,  DXB=0
M8:     cmp     ABUF,160          ;  screen beginning ?
	jne     M10               ;  no !!!
M9:     cmp     ASTR,0            ;  beginning of first line?
	jnz     M10               ;  no, this isn't screen beginning !!!
	mov     DXB,0             ;  offset of screen beginning in block
	jmp     M11               ;
M10:    mov     NB,2              ;  two blocks on screen
	cmp     Count,0           ;  no bytes have been read?
	jnz     PUTSCR            ;
	mov     NB,1              ;  one block on screen !!!
;  If end of file, EOD =1
M11:    cmp     Count,0           ;  no bytes have been read?
	jnz     PUTSCR            ;
	mov     EOD,1             ;  set EndOfFile indicator
	jmp     Next              ;  yes, end of file
;-----------------------------------------------------------------------
;
;  Analyse the block read and create the buffer string
;
;-----------------------------------------------------------------------
PUTSCR: cmp     KbdScan,50h       ;  SCAN -code   ?
	jne     PUT1              ;  ordinar processing
	cmp     NSTR,23           ;  second record (screen beginning) ?
	jne     CHAR              ;  ordinar processing
	cmp     ASTR,0            ;  line beginning ?
	jnz     CHAR              ;  no
	jmp     short PUT2        ;  set characteristics of screen beginning
PUT1:   cmp     ABUF,160          ;  screen beginning ?
	jne     CHAR              ;  no
	cmp     ASTR,0            ;  beginning of first line ?
	jnz     CHAR              ;  no
PUT2:   mov     ax,Count          ;  rest of block read
	mov     LENG0,ax          ;  rest of previopus block on screen
	mov     LENGF,0           ;  length of file part for screen
;  Take and process the current byte from the file (BX)
CHAR:   mov     es,SEGMEM         ;  ES -segment address of block read
	mov     di,ABLOK          ;  source address (offset)
	mov     bx,ES:[DI]        ;  BL - number of current block read
	inc     ABLOK             ;  number of next block
	dec     Count             ;  length of rest of buffer
	mov     es,SEGSTR         ;  segment address of string buffer
	cmp     KbdScan,50h       ;  SCAN -code   ?
	jne     M12               ;  ordinary processing
;  Correction of file parameters for "" operation
	cmp     NSTR,1            ;  last line ?
	je      M12               ;  ordinary processing fur passing into buffer
	cmp     NSTR,24           ;  first line not to be sent?
	jne     M13               ;  ordinary processing
	inc     DXB               ;  modify offset of first line
	add     DXF,1             ;  offset from file biginning
	adc     CXF,0             ;  high part of offset
	jmp     short M14         ;  while length of file extent = 0
;  Clear buffer string befor filling the buffer
M12:    cmp     ASTR,0            ;  line biginning?
	jnz     M13               ;
	xor     di,di             ;  ES:[0] -address of line bigiining
	mov     cx,2000           ;  Count of words
	mov     ax,"  "           ;  Character is the Space
	cld                       ;  Clear Direction Flag
	rep     stosw             ;  Clear of Buffer
;  Processing control characters (Tab, LF, CR)
M13:    inc     LENGF             ;  length of file part on screen
M14:    cmp     bl,09h            ;  Tab ?
	je      HT0               ;
	cmp     bl,0Ah            ;  Line Feed?
	je      LF0               ;
	cmp     bl,0Dh            ;  Carriage Return ?
	je      CRR0              ;
;  Send text to the buffer string
	mov     di,ASTR           ;  ES:DI - address of byte in buffer string
	mov     ES:[DI],bl        ;  byte read (except control characters)
	inc     ASTR              ;  address of next byte in line
	inc     LMOV              ;  modify length of screen line
	jmp     Next              ;  check for line filled
;---
;  Processing of horizontal tabulation (Tab =09h)
HT0:    mov     ax,ASTR           ;  position of the next character
	mov     cl,3              ;  number of shifts for dividing by 8
	shr     ax,cl             ;
	inc     ax                ;  next position 
	mov     cl,3              ;  number of shifts for multiplying
	shl     ax,cl             ;  address of next character
	mov     LMOV,ax           ;  length of string-position of first char
	sub     ax,ASTR           ;  shift character to emulate Tab
	add     ASTR,ax           ;  new position of the character
	jmp     Next              ;  check for line filled
;---
;  Processing of Line Feed character  0Ah
LF0:    jmp     Next              ;  check for line filled
;---
;  Processing of Carriage Return character 0Dh 
CRR0:   cmp     KbdScan,50h       ;  SCAN -code   ?
	jne     CRR1              ;  ordinar processing
	cmp     NSTR,1            ;  last line ?
	jne     CRR3              ;  don't pass into video buffer!
CRR1:   mov     cx,LMOV           ;  length of line parsed
	sub     cx,DRL0           ;  length for passing (shifted)
	jg      CRR2              ;
	xor     bh,bh             ;  clear next character
;  Pass the string parsed int the video buffer
CRR2:   mov     di,ABUF           ;  target offset
	mov     si,DRL0           ;  take shift into account
	mov     es,VIDSEG         ;  segment address of video buffer
	mov     ds,SEGSTR         ;  segment address of buffer string
	mov     cx,80             ;  max length of string
	Call    VIDEO             ;  plase string into video buffer
;  Advance cycle parameters
	mov     ax,DATA           ;  data segment basing
	mov     ds,ax             ;  restore segment address
	add     ABUF,160          ;  address of new line
;  Check for the presence of the LF character after CR in last line
CRR3:   mov     LMOV,0            ;  length of buffer string
	mov     ASTR,0            ;  address of buffer string beginning
	dec     NSTR              ;  lines left in screen buffer
	cmp     NSTR,23           ;  don't pass thi8s line ?
	jne     CRR4              ;  ordinar processing ?
;  Process next LF character for line not being passed
	cmp     bh,0Ah            ;  Line Feed ?
	jne     Next              ;
	inc     DXB               ;  modify offset of first line
	add     DXF,1             ;  offset from file beginning
	adc     CXF,0             ;  high part of offset
	jmp     short CRR5        ;
CRR4:   cmp     NSTR,0            ;  all lines processed?
	jnz     Next              ;  not last line
	cmp     bh,0Ah            ;  Line Feed?
	jne     Next              ;
CRR5:   inc     ABLOK             ;  address of next byte
	inc     LENGF             ;  jump over LF character
	dec     Count             ;  length of block's rest
;-----------------------------------------------------------------------
;  Check whether the screen has been buffer villed
Next:   cmp     NSTR,0            ;  screen filled ?
	jz      GETKEY            ;  yes, output
	cmp     EOD,1             ;  end of file ?
	je      Next1             ;  output full screen
	cmp     Count,0           ;  all block processed?
	jz      JMP1              ;  yes, read next block
	jmp     PUTSCR            ;  continue to process current block
JMP1:   jmp     READ              ;  read next block
;  Clear the lower part of the last screen which isn't completely filled 
Next1:  xor     dx,dx             ;  high part of multiplier
	mov     ax,80             ;  multiplier
	mul     NSTR              ;  AX - number of character
	mov     cx,ax             ;
	mov     bx,24             ;  maximum number of lines
	sub     bx,NSTR           ;  BL - number of first line
	SetCol  bl,0,cx,1Bh       ;  clear lower lines
	SetCurs 25,80             ;  hide cursor
;-----------------------------------------------------------------------
;  Clear the keyboard buffer and wait for key pressed
GETKEY: mov     ASTR,0              ;  address of buffer string beginning
	mov     LMOV,0              ;  length of buffer string created
	mov     NSTR,23             ;  max number of lines on screen
	mov     ABUF,160            ;  address of first byte of video buffer
	cli                         ;  disable interrupts
	xor     ax,ax               ;  
	mov     ES,ax               ;  ES points to BIOS data segment
	mov     al,ES:[41Ah]        ;  address of keyboard buffer head
	mov     ES:[41Ch],al        ;  clear buffer (tail ptr = head ptr)
	sti                         ;  enable interrupts
	xor     ah,ah               ;  function 0 - Get Key
	int     16h                 ;  BIOS keyboard service
	mov     KbdASCII,al         ;  store ASCII character read
	mov     KbdScan,ah          ;  store SCAN code
;-----------------------------------------------------------------------
;
;  Process the code of a key pressed (Esc -Exit)
;
;-----------------------------------------------------------------------
Esc0:   cmp     KbdScan,1         ;  SCAN -code  Esc ?
	jne     PgDn              ;
	jmp     Exit              ;  Return to  MS-DOS
;-----------------------------------------------------------------------
;  PgDn - show the next screen
PgDn:   cmp     KbdScan,51h       ;  SCAN -code  PgDn ?
	jne     PgUp              ;
	cmp     EOD,1             ;  end of file ?
	jne     PgDn1             ;  not, create next screen in buffer
	jmp     GETKEY            ;  wait for next key stroke
PgDn1:  Call    NEXTSCR           ;  display next screen
	jmp     Next              ;  continue processing
;-----------------------------------------------------------------------
;  PgUp - show the previous screen
PgUp:   cmp     KbdScan,49h       ;  SCAN -code  PgUp ?
	je      PgUp1             ;
	jmp     Home              ;
;  Form parameters and display the previous screen
PgUp1:  mov     NREC,23           ;  number of lines read backwards
	Call    GOLOW             ;  back to one screen
	mov     NB,1              ;  one block on screen
	mov     EOD,0             ;  clear End IOf File indicator
	jmp     PUTSCR            ;  output screen
;-----------------------------------------------------------------------
;  Home - to the beginning of the file
Home:   cmp     KbdScan,47h       ;  SCAN -code  Home ?
	jne     End$              ;
	mov     bx,HANDLE         ;  value of file handle
	mov     ax,4200h          ;  AL = 0 - read file from the beginning
	xor     cx,cx             ;  high part of offset
	xor     dx,dx             ;  low part of offset 
	int     21h               ;  DOS service call
	jmp     INIT0             ;  to the file beginning
;-----------------------------------------------------------------------
;  End - show the last screen
End$:   cmp     KbdScan,4Fh       ;  SCAN -code  End ?
	jne     Right             ;
	mov     NB,1              ;  one block on screen
	mov     cx,CXL            ;  high part of offset
	mov     dx,DXL            ;  low part of offset
	mov     CXF,cx            ;  high part (screen beginning)
	mov     DXF,dx            ;  low part (screen beginning)
	Call    POSIT             ;  read block of file
;  Output last lines of the last block
	mov     EOD,0             ;  clear EndOfFile indicator
	mov     DI,ax             ;  DI - address of last byte + 1
	mov     ES,SEGMEM         ;  ES - segment address of block
	mov     cx,23             ;  number of lines on last screen
	Call    BKREC             ;  find lines
	jnc     End1              ;  lines found!
	xor     dx,dx             ;  accept address of block beginning
;  Set up parameters for processing the last line
End1:   sub     Count,dx          ;  length of rest of last block
	mov     ABLOK,dx          ;  address of line for processing
	mov     DXB,dx            ;  offset from block beginning
	add     DXF,dx            ;  offset of last line (high)
	adc     CXF,0             ;  offset of last line (low)
	jmp     PUTSCR            ;  output list line
;-----------------------------------------------------------------------
;  --->  shift the screen to the right by one position
Right:  cmp     KbdScan,4Dh  ;  SCAN -code  ---> ?
	jne     Left              ;
	inc     DRL0              ;  increase right shift counter
	jmp     Repeat0           ;  repeat screen output
;-----------------------------------------------------------------------
;  <---  shift the screen to the left by one position
Left:   cmp     KbdScan,4Bh       ;  SCAN -code  <--- ?
	jne     Low0              ;
	dec     DRL0              ;  decrease right shift counter
	jnl     RpLeft            ;
	mov     DRL0,0            ;  clear shift counter (left position)
RpLeft: jmp     Repeat0           ;  repeat screen output
;-----------------------------------------------------------------------
;   - shift the screen content by one position upwards
Low0:   cmp     KbdScan,48h       ;  SCAN -code   ?
	je      Low1              ;  
	jmp     short High0       ;  
;  Prepare parameters and display the previous line  (AX = LENGR)
Low1:   mov     NREC,1            ;  number of lines processed
	Call    GOLOW             ;  back by one line
	mov     NB,1              ;  one block on screen
	mov     EOD,0             ;  clear EndOfFile indicator
	mov     NSTR,1            ;  output first line only
;  Screen scrolling downwards by one line
	mov     si,3678           ;  source offset (end of line 22)
	mov     di,3838           ;  target offset (end of line 23)
	mov     ES,VIDSEG         ;  target segment (video buffer)
	mov     DS,VIDSEG         ;  source segment (video buffer)
	mov     cx,22*80          ;  number of words to be scrolled (22lines)
	std                       ;  scroll down
	Call    SCROLL            ;  functional subroutine call
	cld                       ;  Clear Direction Flag
	mov     ax,DATA           ;  DS points to data segment
	mov     ds,ax             ;  restore segment address
	jmp     PUTSCR            ;  output screen 
;-----------------------------------------------------------------------
;   - scroll the screen content down by one line
High0:  cmp     KbdScan,50h       ;  SCAN -code   ?
	jne     CtrHom            ;
	cmp     EOD,1             ;  end of file ?
	jne     High1             ;  form next screen
	jmp     GETKEY            ;  repeat screen output
;  Check whether the next screen is out of file (for "")
High1:  mov     dx,CXF            ;  previous offset (high)
	mov     ax,DXF            ;  previous offset (low))
	add     ax,LENGF          ;  low part of new offset
	adc     dx,0              ;  high part of new offset
	cmp     dx,DX0            ;  offset > length of file ?
	ja      High2             ;  yes, output screen
	jb      High3             ;  high part < length
	cmp     ax,AX0            ;  offset > length of file ?
	jb      High3             ;
High2:  jmp     GETKEY            ;  repeat screen output
;  Scroll the screen content upward by one line
High3:  mov     NSTR,24           ;  number of lines to be processed
	mov     ABUF,23*160       ;  output into line 23
	mov     si,320            ;  source offset (beginning of line 2)
	mov     di,160            ;  target offset (beginning of line 1)
	mov     ES,VIDSEG         ;  target segment
	mov     DS,VIDSEG         ;  source segment
	mov     cx,22*80          ;  number of words shifted
	cld                       ;  Clear Direct Flag
	Call    SCROLL            ;  screen scrolling subroutine call
	mov     ax,DATA           ;  data segment basing
	mov     ds,ax             ;  restore segment address
	jmp     short Repeat0     ;  position to screen beginning
;-----------------------------------------------------------------------
;  Ctrl + Home - display the left part of lines (beginning)
CtrHom: cmp     KbdScan,77h  ;  Ctrl + Home ?
	jne     AnyKey            ;
	mov     DRL0,0            ;  clear shift counter
	jmp     short Repeat0     ;  position to screen beginning
AnyKey: jmp     GETKEY            ;  repeat screen ouputting
;-----------------------------------------------------------------------
;  Repeating of the active screen outputting
Repeat0: mov    EOD,0             ;  clear EndOfFile indicator
	 cmp    NB,2              ;  two blocks on screen ?
	 jne    REP01             ;  no, one block
	 mov    cx,CXF            ;  high part of offset
	 mov    dx,DXF            ;  low part of offset
;  Read previous block (high part of screen)
	 mov    DXB,0             ;  DXB =0 -clear block offset
	 Call   POSIT             ;  read block
	 jmp    PUTSCR            ;  repeat screen outputting
;  Return to the screen beginning (block has already been read)
REP01:   mov    ax,DXB            ;  offset of first line on screen
	 mov    ABLOK,ax          ;  address of first byte on screen
	 mov    cx,LENG0          ;  full length of block
	 mov    Count,cx          ;  rest of block read
	 jmp    PUTSCR            ;  repeat screen output
;-----------------------------------------------------------------------
;  Output file processing error message (error code is in the AX register)
TypErr:  mov    ax,DATA           ;  address of data segment
	 mov    ds,ax             ;  DX:=data segment address
	 mov    si,dx             ;  DS:SI - message strings
	 SetCurs 3,0              ;  cursor to line 3 for outputting message
	 mov    cx,80             ;  number of characters
	 Call   PUTSTR            ;  output string onto screen
	 SetCurs 25,80            ;  hide cursor
	 mov    dl,07h            ;  Bell
	 mov    ah,2              ;  Put Character
	 int    21h               ;  DOS service call
	 xor    ah,ah             ;  function 0 - Get Key
	 int    16h               ;  BIOS keyboard service call
;-------------------------------------------------------------------
;  Terminate program and exit to DOS
Exit:   cmp     ERROP,0           ;  Sucsesful Open ?
	jnz     Free              ;  file wasn't open!
	mov     ah,3Eh            ;  Function 3Eh -Close File
	mov     bx,HANDLE         ;  BX - value of file handle
	int     21h               ;  DOS service call
Free:   Call    FREEMAIN          ;  free the memory buffer allocate
	mov     al,VMODE          ;  remember video mode on entry
	xor     ah,ah             ;  function 0 - set video mode
	int     10h               ;  BIOS video service
	mov     ax,0C00h          ;  Clear Keyboard Buffer
	int     21h               ;  DOS service call
	mov     ax,4C00h          ;  function 4Ch - terminate process
	int     21h               ;  DOS service call
;-----------------------------------------------------------------------
;
;  Functional subroutines used
;
;-----------------------------------------------------------------------
;***********************************************************
;
;  Subroutine for outputting an ASCIIZ string onto the screen
;
;  DS:[SI] - address of string beginning (is output at the cursor position)
;
;  CX      - length of the string to be output (maximum 80 bytes)
;
;  Attention! Before using this subroutine set the cursor location
;
;***********************************************************
PUTSTR   PROC   NEAR
	 cld                    ;  Clear Direct flag
	 xor    bh,bh           ;  video page 0 
	 mov    ah,0Eh          ;  function 0Eh - output in teletype mode
PUTS1:   lodsb                  ;  load a byte from the string
	 and    al,al           ;  end of line?
	 jz     PUTS2           ;  yes, return to caller
	 int    10h             ;  BIOS video service
	 loop   PUTS1           ;  next performance of cycle
PUTS2:   RETN                   ;  Exit
PUTSTR   ENDP
;***********************************************************
;
;  Free the memory buffer allocated
;
;***********************************************************
FREEMAIN PROC   NEAR
	 mov    ax,SEGMEM         ;  memory segment address
	 and    ax,ax             ;  memory allocated ?
	 jnz    Fremem            ;  yes !!!
	 jmp    short Freret      ;
Fremem:  mov    ERR0,0            ;  clear error code
	 mov    es,ax             ;  memory segment address
	 mov    ah,49h            ;  free memory function code
	 int    21h               ;  DOS service call
	 jnc    Freret            ;
	 lea    dx,ERR00          ;  free memory error code
	 jmp    TypErr            ;  error message output
Freret:  RETN
FREEMAIN ENDP
;***********************************************************
;
;  Determining the type of the video adapter
;
;  CGA = 1 - the CGA card is used
;
;  VIDSEG -segment address of the video buffer
;
;***********************************************************
VIDTYP  PROC    NEAR
	mov     VIDSEG,0B000h       ;  address of video buffer for MDA
	mov     CGA,0               ;  clear CGA indicator
	mov     ax,40h              ;  segment address of BIOS data area
	mov     ES,ax               ;  ES points to BIOS data area
	mov     al,ES:[10h]         ;  read equipment list
	and     al,30h              ;  clear unused bits
	cmp     al,30h              ;  MDA card ?
	je      VIDRET              ;  yes !
;  Find an active color card:  EGA (VGA)
	mov     VIDSEG,0B800h           ;  address of color adapter buffer
	mov     CGA,1                   ;  set CGA indicator
	cmp     byte ptr ES:[87h],0     ;  EGA present?
	jz      VIDRET                  ;  EGA  not installed
	test    byte ptr ES:[87h],08h   ;  EGA  active?
	jnz     VIDRET                  ;  bit 3 = 1 - EGA  not active
	mov     CGA,0                   ;  clear CGA indicator
VIDRET: RETN                            ;  Exit
VIDTYP  ENDP
;***********************************************************
;
;  Subroutine for writing a string into the video buffer
;
;  DS:[SI] - address of the string to be output
;
;  ES:[DI] - address of the string in the video buffer
;
;  CX      - max length of the output string (usually 80 bytes)
;
;***********************************************************
VIDEO   PROC    NEAR
	cld                       ;  Clear Direct flag
	cmp     CGA,1             ;  CGA card?
	jne     Cycle3            ;  no, don't check for retrace
;  Wait for retrace
Cycle0: mov     dx,3DAh           ;  video state register (CGA)
Cycle1: in      al,dx             ;  read state register
	test    al,1              ;  retrace?
	jnz     Cycle1            ;  yes, wait for finish
;  Check whether it is possible to write into video buffer
Cycle2: in      al,dx             ;  read state register
	test    al,1              ;  rerace (writing allowed)?
	jz      Cycle2            ;  no, check again
	lodsb                     ;  take next character from string
	stosb                     ;  output character into video buffer
	inc     di                ;  skip attribute in video buffer
	loop    Cycle0            ;  next step of outward cycle
	RETN                      ;  Return to caller
;  Non-CGA video card - direct writing always allowed
Cycle3: lodsb                     ;  take next character from string
	stosb                     ;  output character into video buffer
	inc     di                ;  skip attribute in video buffer
	loop    Cycle3            ;  next step of outward cycle
	RETN                      ;  Return to caller
VIDEO   ENDP
;***********************************************************
;
;  The procedure for screen scrolling
;
;  DS:[SI] - address of string to be output
;
;  ES:[DI] - address of the string in the video buffer
;
;  CX      - number of words to be scrolled
;
;  The Direction Flag is used to define the scrolling direction
;
;  CLD     - scroll upwards
;
;  STD     - scroll downwards
;
;***********************************************************
SCROLL  PROC    NEAR
	mov     bl,CGA            ;  take CGA indicator
	cmp     bl,1              ;  CGA card?
	jne     Cycle7            ;  no, don't check for retrace
;  Wait for retrace
Cycle4: mov     dx,3DAh           ;  video state register (CGA)
Cycle5: in      al,dx             ;  read state register
	test    al,1              ;  retrace?
	jnz     Cycle5            ;  yes, wait for finishing
;  Check whether it is possible to write into video buffer
Cycle6: in      al,dx             ;  read state register
	test    al,1              ;  rerace (writing allowed)?
	jz      Cycle6            ;  no, check again
	lodsw                     ;  take character and attribute
	stosw                     ;  output character and attribute
	loop    Cycle4            ;  next step of outward cycle
	RETN                      ;  return to caller
;  Non-CGA video card - direct writing always allowed
Cycle7: rep     movsw             ;  output character and attribute
	RETN                      ;  return to caller
SCROLL  ENDP
;***********************************************************
;
;  Procedure for reading a block of file (up  32768 bytes)
;
;  Length of block read is returned in the AX register
;
;  CF = 0 - operation comleted succesfully
;
;  CF = 1 - error while reading (error code in AX)
;
;***********************************************************
RDBLOK  PROC    NEAR
	mov     EOD,0             ;  clear EOF flag
	mov     ABLOK,0           ;  start address of read buffer
	mov     bx,HANDLE         ;  load file handle
	mov     cx,32768          ;  required length of block read
	lds     dx,AMEM           ;  load: DX=0, DS is the segment address
	mov     ah,3Fh            ;  function 3Fh - read file with handle
	int     21h               ;  DOS service call
	mov     dx,DATA           ;  data segment address
	mov     ds,dx             ;  restore the segment register
	mov     Count,ax          ;  actual length of block read
	RETN                      ;  Exit
RDBLOK  ENDP
;***********************************************************
;
;  Procedure for positionong and reading the block of file
;
;  The DX:CX registers - offset from the beginning of the file
;
;  The length of the block read is returned in the AX register
;
;  CF = 0 - successful finish
;
;  CF =1 - error reading file (error code in AX)
;
;***********************************************************
POSIT   PROC   NEAR
	mov     bx,HANDLE         ;  load file handle
	mov     ax,4200h          ;  AL = 0 - read from beginning of file
	int     21h               ;  DOS service call
	Call    RDBLOK            ;  read privious block
	mov     NB,1              ;  one block on screen!
	RETN                      ;  Exit
POSIT   ENDP
;***********************************************************
;
;  Procedure for calculating parameter for outputting the next screen 
;
;  CXF, DXF - offset of the current screen from the file beginning
;
;  DXB      - offset of the screen start from the block beginning
;
;  LENGF    - length of the file part currently shown
;
;  LENG0    - length of the rest of previous block on screen
;
;***********************************************************
NEXTSCR  PROC   NEAR
	 mov    cx,CXF            ;  previous offset (high)
	 mov    dx,DXF            ;  previous offset (low)
	 add    dx,LENGF          ;  low part of new offset
	 adc    cx,0              ;  high part of new offset
;  Check whether the next screen is out of file
	 cmp    cx,DX0            ;  offset > length of file ?
	 ja     NXT1              ;  out of file
	 jb     NTX2              ;  high part < length
	 cmp    dx,AX0            ;  offset > length of file ?
	 jb     NTX2              ;
NXT1:    add    sp,2              ;  adjust stack
	 jmp    GETKEY            ;  display screen
;  Check the number of blocks on the screen (1 or 2)
NTX2:    mov    CXF,cx            ;  new offset (high)
	 mov    DXF,dx            ;  new offset (low)
	 mov    ax,LENGF          ;  length of file part on screen
	 cmp    NB,2              ;  two blocks ?
	 jne    NXT3              ;  block has already been read
;  Change the screen containing two blocks
	 sub    ax,LENG0          ;  DXB = LENGF - LENG0
	 mov    DXB,ax            ;  new offset from block beginning
	 mov    ax,COUNT          ;  length of rest of current block
	 mov    LENG0,ax          ;  length of rest of previous block
	 mov    NB,1              ;  after screen changed one block is shown
	 RETN                     ;  return to caller
;  Change screen with one block present
NXT3:    add    DXB,ax            ;  DXB = DXB + LENGF
	 mov    ax,DXB            ;
	 mov    ABLOK,ax          ;  address of first byte on screen
	 RETN                     ;  return to caller
NEXTSCR  ENDP
;***********************************************************
;
;  Subroutine for reading file backwards
;
;  Is used when processing the PgUp and  "" keys
;
;  NREC      - number of lines read backwards
;
;  NREC = 1  for  "" key
;
;  NREC = 23 for  PgUp
;
;  Returned values:
;
;  DX = ABLOK  - address of first line to be displayed
;
;  CXF, DXF    - offset of the first line on the screen from the file beginning
;
;  DXB         - offset screen beginning from the block beginning
;
;  Count       - length of rest of file shown on the high part of the screen
;
;***********************************************************
GOLOW   PROC    NEAR
GOL1:   cmp     DXF,0             ;  file beginning? (low part)
	jnz     GOL2              ;
	cmp     CXF,0             ;  file beginning? (high part)
	jg      GOL2              ;
	add     sp,2              ;  adjust stack
	jmp     GETKEY            ;  repeat screen outputting 
;  Check how many blocks are on the screen (1 or 2)
GOL2:   cmp     NB,2              ;  two blocks on screen?
	jne     GOL3              ;  no, one
	jmp     GOL7              ;  yes,two
GOL3:   xor     cx,cx             ;  clear LENGR + LENGF
	cmp     DXB,0             ;  block beginning
	jz      GOL4              ;  read previous block
;======
;  One block only is shown on the screen and  DXB > 0
	mov     ES,SEGMEM         ;  ES -segment address of block
	mov     di,DXB            ;  ES:DI - address of first line on screen
	mov     cx,NREC           ;  number of lines processed
	Call    BKREC             ;  find previous line
	mov     cx,ax             ;  AX = LRECL - length of line found
	jc      GOL4              ;  line not found
	add     cx,LENGF          ;  CX = LENGR + LENGF
	add     Count,cx          ;  new length of rest of block
	jmp     GOL8              ;  normal return
;  line to be displayed is on the juncture of blocks (or DXB = 0)
GOL4:   sub     DXF,cx            ;  address of block juncture (high)
	sbb     CXF,0             ;  address of block juncture (low)
	mov     cx,CXF            ;  high part of offset
	mov     dx,DXF            ;  low part of offset
	sub     dx,32768          ;  beginning of previous block (high)
	sbb     cx,0              ;  beginning of previous block (low)
	jl      GOL5              ;  previous block < 32768 bytes
;  Find first line to be shown on screen
	Call    POSIT             ;  read previous block
	mov     ES,SEGMEM         ;  ES - segment address of block
	mov     di,32767          ;  address of last byte in block
	mov     cx,NREC           ;  number of lines to find
	Call    BKREC             ;  find previous line
	sub     Count,dx          ;  length of rest of block
	jmp     short GOL8        ;  normal return
;  Previous block < 32768. Positioning to the beginning
GOL5:   xor     cx,cx             ;  high part of offset
	xor     dx,dx             ;  low part of offset
	Call    POSIT             ;  read previous block
	mov     ES,SEGMEM         ;  ES -segment address of block
	mov     di,DXF            ;  address of first line on screen
	mov     cx,NREC           ;  number of lines to find
	Call    BKREC             ;  find previous line
	jc      GOL6              ;  line not found
	sub     Count,dx          ;  length of rest of block
	jmp     short GOL8        ;  normal return
;  Line to be displayed is located at the start of file
GOL6:   xor     dx,dx             ;  address of first line
	mov     ABLOK,dx          ;  offset from block beginning
	mov     DXB,dx            ;  new offset of line displayed
	mov     DXF,dx            ;  low part of offset  = 0
	mov     CXF,dx            ;  high part of offset  = 0
	RETN                      ;  return to caller
;======
;  Two blocks on screen (NB = 2). Previous block has to be read
GOL7:   mov     cx,CXF            ;  high part of offset
	mov     dx,DXF            ;  low part of offset
	sub     dx,DXB            ;  start of previous block (high)
	sbb     cx,0              ;  start of previous (low)
	Call    POSIT             ;  read previous block
;  Find the line in previous block to be shown as the first line on the screen
	mov     ES,SEGMEM         ;  ES - segment address of block
	mov     di,DXB            ;  address of screen beginning
	mov     cx,NREC           ;  number of lines inserted
	Call    BKREC             ;  find previous line
	sub     Count,dx          ;  length of rest of block
;  Set up parameters for previous block and exit (AX -length of string
GOL8:   mov     ABLOK,dx          ;  offset from block beginning
	mov     DXB,dx            ;  new offset of line displayed
	sub     DXF,ax            ;  low part of offset
	sbb     CXF,0             ;  high part of offset
	RETN                      ;  return to caller
GOLOW   ENDP
;***********************************************************
;
;  Subroutine for reading the last but one line
;
;  The backwards parsing of the block is performed
;
;  On entry:  ES:DI  - address of last line beginning
;             CX     - the number of lines required
;
;  On return: ES:DX  - address of line found
;             AX     - length of lines found
;
;             CF =0  - all length found successfully
;
;             CF =1  - required nomber of lines not found
;                      in this case CX - number of lines not processed
;
;***********************************************************
BKREC   PROC    NEAR
	xor     ax,ax             ;  record length counter
BK0:    mov     dx,di             ;  save address
	dec     di                ;  address of last byte (possibly LF)
	jl      BK4               ;
;  Find the end of last line (the CR and LF pair)
BK1:    cmp     byte ptr ES:[DI],0Ah ;  LF ?
	jne     BK2               ;
	dec     di                ;  address of previous byte
	jl      BK4               ;
	inc     ax                ;  modify length counter
BK2:    cmp     byte ptr ES:[DI],0Dh ;  CR ?
	jne     BK3               ;
	dec     di                ;  address of privious byte
	jl      BK4               ;
	inc     ax                ;  modify length counter
;  Find last line (first LF from the last but one line)
BK3:    cmp     byte ptr ES:[DI],0Ah ;  LF ?
	je      BK4               ;
	dec     di                ;  address of previous byte
	jl      BK4               ;
	inc     ax                ;  modify length counter
	jmp     short BK3         ;  character found, continue cycle
;  Modify pthe cycle paramters and analizing rezults
BK4:    inc     di                ;  address of last line beginning
	jz      BK5               ;  beginning of file block
	loop    BK0               ;  continue lines detachment
	mov     dx,di             ;  address of first line on screen
	clc                       ;  CF = 0 - successful detachment
	RETN                      ;  return to caller
BK5:    stc                       ;  CF = 1 - requested lenes not found
	RETN                      ;  return to caller
BKREC   ENDP
_TEXT   ENDS
;-----------------------------------------------------------------------
ZSEG    SEGMENT  'ZERO'
ZSEG    ENDS
;-----------------------------------------------------------------------
	END    START
