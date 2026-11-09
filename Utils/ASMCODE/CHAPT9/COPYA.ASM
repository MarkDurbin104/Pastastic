;**********************************************************
;  Program CopyA ( Chapter 9 )
;
;  The program for fast files copying 
;
;  Author: A.I.Sopin, Voronezh University  1990 - 1993 
;
;  MS-DOS disk service  (INT 21h) is used
;
;  To exit program press the ESC key
;
;**********************************************************
;   MACRO  Definitions
;**********************************************************
; 1. Push common registers onto the stack:
;**********************************************************
PUSHR    MACRO
	 push   ax
	 push   bx
	 push   cx
	 push   dx
	 push   bp
	 push   ds
	 push   es
	 push   si
	 push   di
	 ENDM
;**********************************************************
; 2. Pop common registers from the stack:
;**********************************************************
POPR     MACRO
	 pop    di
	 pop    si
	 pop    es
	 pop    ds
	 pop    bp
	 pop    dx
	 pop    cx
	 pop    bx
	 pop    ax
	 ENDM
;********************************************************** 
; 3. Calling video library (DIAMS)
;********************************************************** 
DIAM    MACRO   OP$,M$,N$,U$,V$
	mov     TOFF,bx
	mov     OP,OP$
	mov     bx,M$
	mov     M,bx
	mov     bx,N$
	mov     N,bx
	mov     bx,U$
	mov     U,bx
	mov     bx,V$
	mov     V,bx
	lea     bx,PARM
	push    bx
	Call    far ptr DIAM00
	mov     bx,TOFF
	ENDM
;******************************************
EXTRN    DIAM00 : FAR, DIAM01 : FAR, CLEAR : FAR, BINASC : FAR
EXTRN    ADD32 : FAR, ERRCOD : FAR
;
;-----------------------------------------------------------------------
STAC     SEGMENT STACK
	 DB      512 dup (?)
STAC     ENDS
;-----------------------------------------------------------------------
;
;-----------------------------------------------------------------------
DATA     SEGMENT  PARA PUBLIC 'DATA'
TEXT0    db     ' Press ESC to terminate the program',0
TEXT1    db     ' Input file name  =                                 ',0
TEXT2    db     ' Output file name =                                 ',0
TEXT3    db     ' File has been processed.  Time = hh/mm/ss/0.tt.'
	 db     '  Press any key',0
	 dw     20 dup ('  ')
HH0      EQU    TEXT3+34
MM0      EQU    TEXT3+37
SS0      EQU    TEXT3+40
TT0      EQU    TEXT3+45
;
HRS      DB     0
MINS     DB     0
SECS     DB     0
HSECS    DB     0
CX2      dw     0
DX2      dw     0
BUFFER   db     12 dup (0)        ; buffer used for conversion: AX ---> ASCII
	 EVEN
PARM     LABEL  WORD              ; parameters vector (its address is in
				  ; the stack)
OP       dw     0                 ; instruction code
M        dw     0                 ; number of the first string
N        dw     0                 ; number of the last string
TOFF     dw     0                 ; text string offset
L        dw     80                ; length of the text string
U        dw     0                 ; string where the cursor is set (1---25)
V        dw     0                 ; position where the cursor is set (1---80)
Q        dw     0                 ; cursor row accepted 
S        dw     0                 ; cursor column accepted 
W        dw 2 dup (0)             ; interrupt key code
IOFF     dw     0                 ; the address of the screen format vector
				  ; (or 0)
I        dw     80
	 db     0, 07h
;
PATH1    DB     68 dup (0)        ;
PATH2    DB     68 dup (0)        ;
ERR0     DW     0                 ; error flag; error if not 0
ERRTXT   DB     80 dup (0)        ; error messages buffer
AERRTXT  DD     ERRTXT
ATTN     DB     ' Attention!  - File is being processed. Please wait. ',0
LATT     EQU    $-ATTN
;
I1       DW     1
	 DB     0,07h
	 DW     LATT
	 DB     0,74h
	 DW     38
	 DB     0,07h
	 DW     0
;
TERM     DB     0                 ;
OP0      DB     0                 ;
OP1      DB     0                 ;
OP2      DB     0                 ;
IO       DB     0                 ;  IO =0 - input file
HANDLE0  DW     0                 ;
HANDLE1  DW     0                 ;
HANDLE2  DW     0                 ;
ADRPAT   DW     0                 ;
AMEM     LABEL  DWORD             ;  offset + segment address for LDS
DX0      DW     0                 ;  offset to be loadedinto DX
ADRMEM   DW     0                 ;  segment address of memory received
Leng     dw     0
Count1   dw     0                 ;  file length couner(the most significant
				  ;  part)
Count2   dw     0                 ;  file length counter(the least
				  ;  significant part)
CTXT     db     ' Number of bytes processed =             ',0
ANUMB    DD     CTXT+29           ;  offset + segment address for LES
DATA     ENDS
;-----------------------------------------------------------------------
;
;-----------------------------------------------------------------------
_TEXT    SEGMENT PARA PUBLIC 'CODE'
	 ASSUME CS:_TEXT, DS:DATA, SS:STAC
START:
	 mov    ax,DATA           ;  data segment basing
	 mov    ds,ax
	 mov    ax,STAC
	 mov    SS,ax             ;  internal program stack will be used
	 mov    SP,512            ;  stack size in bytes
	 mov    ADRMEM,0          ;  no memory has been allocated
;  Free memory above the program end
	 mov    bx,ZSEG           ;  program end address
	 mov    ax,es             ;  segment address of the program beginning
	 sub    bx,ax             ;  memory size needed
	 mov    ah,4Ah            ;  DOS function number
	 int    21h               ;  free memory
	 mov    ERR0,ax
	 jnc    Getmem            ;  Memory reallocated!
	 jmp    TYPERR
;  Allocate the maximum memory area for the buffer
Getmem:  mov    ah,48h            ;  DOS function number
	 mov    bx,0FFFH          ;  request memory area of the maximum size
	 int    21h               ;
	 jnc    Norm              ;  jump if successful
	 int    21h               ;  BX = size of largest available block!
	 jnc    Norm              ;  jump if memory allocated
	 jmp    TYPERR            ;  otherwise output error message

Norm:    mov    ADRMEM,ax         ;  AX:0 -segment address of allocated
				  ;  memory block
	 mov    cl,4              ;  Leng will be equal to the size
	 sal    bx,cl             ;  of allocated memory
	 mov    leng,bx           ;  in bytes
;  Clear screen and output string =2
BEGIN:   mov    Count1,0          ;  clear file length
	 mov    Count2,0          ;  counters
	 mov    ch,1
	 mov    dh,24
	 Call   CLEAR             ;  screen clear
	 lea    bx,TEXT0          ;  message text address
	 DIAM   1,2,2,0,0         ;  prepare parameters for  DIAM00
				  ;  and call it
;  Ask input and output files' names
	 mov    OP1,0
	 mov    OP2,0
	 mov    IO,0              ;  input file flag (read)
	 mov    M,3               ;
	 mov    U,3               ;
	 mov    N,-3              ;
	 mov    V,20              ;
	 lea    ax,PATH1          ;
	 mov    ADRPAT,ax         ;
	 mov    bx,offset TEXT1   ;
	 Call   GETFILE           ;
	 cmp    term,1            ;
	 jne    par1              ;
	 jmp    Close1            ;
par1:    cmp    ERR0,0            ;
	 jz     movop1            ;
	 jmp    TYPERR            ;
movop1:  mov    ax,HANDLE0        ;
	 mov    HANDLE1,ax        ;
	 mov    al,OP0            ;
	 mov    OP1,al            ;
;  Ask and input the output file name
Input2:
	 mov    IO,1              ;  output file flag
	 mov    M,4               ;
	 mov    U,4               ;
	 mov    N,-4              ;
	 lea    ax,PATH2          ;
	 mov    ADRPAT,ax         ;
	 mov    bx,offset TEXT2   ;
	 Call   GETFILE           ;
	 cmp    TERM,1            ;  work terminated?
	 jne    par2              ;
	 jmp    Close1            ;
par2:    cmp    ERR0,0            ;
	 jz     movop2            ;
	 jmp    TYPERR            ;
movop2:  mov    ax,HANDLE0        ;
	 mov    HANDLE2,ax        ;
	 mov    al,OP0            ;
	 mov    OP2,al            ;
;  Output message about the file processing
	 lea    bx,I1
	 mov    IOFF,bx
	 lea    bx,ATTN
	 DIAM   1,5,-5,0,0        ;
;  Store the time value of file processing start
	 mov    ah,2CH            ;  get system time
	 int    21h
	 mov    HRS,ch            ;  hours
	 mov    MINS,cl           ;  minutes
	 mov    SECS,dh           ;  seconds
	 mov    HSECS,dl          ;  hundredths of seconds
;  Read the records of the input file (3072 bytes????)
READ:    mov    bx,HANDLE1        ;
	 mov    cx,16384          ;
	 lds    dx,AMEM           ;  load: DX=0, DS is the segment address
	 mov    ah,3Fh            ;  read function code
	 int    21h               ;
	 mov    dx,DATA           ;  data segment address
	 mov    ds,dx             ;  restore the segment register
	 jnc    eof1              ;
	 jmp    TYPERR            ;
eof1:    cmp    ax,0              ;  no bytes have been read?
	 jnz    WRITE
	 jmp    Close1            ;  yes, end of file
;  Move the record received into the output file
WRITE:   mov    cx,ax             ;  CX:=the counter of bytes to be written
	 mov    dx,Count1         ;  the most significant part
				  ;  of the byte counter
	 mov    ax,Count2         ;  the least significant part
				  ;  of the byte counter
	 add    ax,cx             ;  double precision
	 adc    dx,0              ;  add operation
	 mov    Count1,dx         ;
	 mov    Count2,ax         ;
	 mov    bx,HANDLE2        ;
	 lds    dx,AMEM           ;  load: DX=0, DS is the segment address
	 mov    ah,40h            ;  write function code
	 int    21h               ;
	 mov    dx,DATA           ;  data segment address
	 mov    ds,dx             ;  restore the segment register
	 jnc    short READ        ;  jump to read the next record
	 mov    ERR0,ax           ;  store the result into error flag
;
;-----------------------------------------------------------------------
;  Output file processing error message (error code is in the AX register)
TYPERR:  mov    cx,40
	 les    DI,AERRTXT        ;
	 cld                      ;
	 xor    ax,ax             ;
	 rep    stosw
	 mov    ax,ERR0
	 les    DI,AERRTXT        ;
	 Call   ERRCOD            ;
	 cld                      ;
	 rep    movsb             ;  accept text for error message
;  Error message output
	 mov    ax,DATA
	 mov    ds,ax             ;  DX:=data segment address
	 lea    bx,ERRTXT         ;
	 mov    IOFF,0            ;
	 DIAM   3,4,-4,0,0        ;
;  Close input and output files
Close1:  mov    ERR0,0
	 cmp    OP1,0             ;  is the input file opened?
	 jz     Close2            ;  No!
	 mov    ah,3Eh            ;
	 mov    bx,HANDLE1        ;  input file pointer
	 int    21h               ;
	 mov    ERR0,ax
	 jnc    Close2            ;  jump if threr are no errors
	 jmp    TYPERR            ;  output close error message
Close2:  mov    ERR0,0
	 cmp    OP2,0             ;  is the input file opened?
	 jnz    cls2              ;  yes, close the file
	 cmp    term,1            ;  work terminated?
	 jne    jmpbeg
	 jmp    EOJ               ;
jmpbeg:  jmp    BEGIN             ;  go to input request and process the next file
cls2:    mov    ah,3Eh            ;  close function code
	 mov    bx,HANDLE2        ;  output file pointer
	 int    21h               ;
	 mov    ERR0,ax
	 jnc    gobeg             ;
	 jmp    TYPERR            ;  output close error message
gobeg:   cmp    term,1            ;  work terminated?
	 jne    Alltime
	 jmp    EOJ               ;
;
;-----------------------------------------------------------------------
;  Calculating the total time of file processing
Alltime:
	 mov    ah,2CH            ;  get system time
	 int    21h
	 sub    dl,HSECS
	 jnc    sub_secs
	 add    dl,100
	 dec    dh
sub_secs:
	 sub    dh,SECS
	 jnc    sub_mins
	 add    dh,60
	 dec    cl
sub_mins:
	 sub    cl,MINS
	 jnc    sub_hrs
	 add    cl,60
	 dec    ch
sub_hrs:
	 sub    ch,HRS
	 jnc    HHMMSSTT
	 add    ch,24
;  Calculating the number of hours/minutes (CH/CL)
HHMMSSTT:
	 xor    ax,ax
	 mov    al,ch
	 Call   DIGIT2
	 mov    word ptr HH0,bx
	 xor    ax,ax
	 mov    al,cl
	 Call   DIGIT2
	 mov    word ptr MM0,bx
;  Calculating the number of seconds/hundredth of seconds (DH/DL)
	 xor    ax,ax
	 mov    al,dh
	 Call   DIGIT2
	 mov    word ptr SS0,bx
	 xor    ax,ax
	 mov    al,dl
	 Call   DIGIT2
	 mov    word ptr TT0,bx
;  Output file processing time (string = 6)
	 mov    IOFF,0            ;
	 lea    bx,TEXT3
	 DIAM   1,6,6,0,0         ;
;  Convert the read bytes counter into ASCII:
	 lea    bx,BUFFER         ;  work buffer address (12 bytes)
	 xor    dx,dx             ;  the most significant part of the number
	 mov    dx,Count1
	 mov    ax,Count2
	 Call   BINASC            ;  conversion: BIN ---> ASCII
	 push   cx
	 les    di,ANUMB          ;  ES:DI:= target address
	 cld                      ;
	 mov    cx,6
	 mov    ax,'  '
	 rep    stosw
	 mov    si,bx
	 les    di,ANUMB
	 pop    cx
	 rep    movsb             ;
;  Output the number of bytes processed (string =7)
	 mov    IOFF,0
	 lea    bx,CTXT
	 DIAM   2,7,-7,7,30
	 jmp    BEGIN             ;  go to input request and process
				  ;  the next file
;-------------------------------------------------------------------
;  Terminate the program:
EOJ:     Call   FREEMAIN          ;  free the memory buffer allocate
	 mov    ax,4C00h          ;  normal program termination
	 int    21h               ;  Return to  MS-DOS

;***********************************************************
;
;  Convert a two-digit number from
;
;  binary code into ASCII code
;
;
;***********************************************************
DIGIT2   PROC   NEAR
	 push   cx
	 push   dx
	 xor    dx,dx
	 lea    bx,BUFFER
	 Call   BINASC
	 lea    bx,BUFFER+10
	 cmp    byte ptr [bx],20h
	 jne    Timret
	 mov    byte ptr [bx],'0'
Timret:
	 mov    bx,word ptr [bx]
	 pop    dx
	 pop    cx
	 RETN
DIGIT2   ENDP
;
;***********************************************************
;
;  Free the memory buffer allocated
;
;***********************************************************
FREEMAIN PROC   NEAR
	 mov    ax,ADRMEM         ;  memory segment address
	 cmp    ax,0              ;  memory allocated ?
	 jnz    Fremem            ;  yes !!!
	 jmp    short freret      ;
Fremem:  mov    ERR0,0            ;  clear error code
	 mov    es,ax             ;  memory segment address
	 mov    ah,49h            ;  free memory function code
	 int    21h               ;  free memory
	 jnc    Freret            ;
	 mov    ERR0,ax           ;  free memory error code
	 jmp    TYPERR            ;  error message output
Freret:  RETN
FREEMAIN ENDP
;
;**********************************************************
;
;  Input the requested file name and open the file
;
;  bx     - text string address
;
;  ADRPAT - address of the string that contains the requested file path
;
;
;**********************************************************
GETFILE  PROC   NEAR
	 PUSHR
	 mov    ERR0,0            ; no errors detected yet
	 mov    IOFF,0            ;
	 DIAM   3,M,N,U,V         ; output string that requests file name
	 mov    ax,W
	 mov    term,0            ;
	 cmp    al,1Bh            ; ESC ?
	 jne    Movpath
	 mov    term,1            ; end of work flag
	 jmp    Ret01
;  Move the requested file name to the path string
Movpath: add    bx,V              ;  the address of symbol next to the cursor
	 mov    di,ADRPAT
	 mov    ax,ds
	 mov    es,ax
M1:      mov    cl,[bx-1]         ;  move the name character
	 mov    es:[di],cl        ;
	 cmp    cl,0
	 jz     Open2
	 cmp    cl,' '
	 je     Open2
	 cmp    cl,0Dh            ;  carriage return ?
	 je     Open2             ;
	 inc    di                ;
	 inc    bx                ;
	 jmp    short M1          ;  to the cycle beginning
;  Open the file requested and analyze the result
Open2:   mov    OP0,0             ;
	 mov    ah,3Dh            ;
	 mov    al,2              ; al:=access mode
	 mov    dx,ADRPAT         ; DX:=file name (and path) address
	 int    21h               ;
	 jc     ERROR             ;
	 mov    HANDLE0,ax        ; store the file handle
	 mov    OP0,1             ; open file flag
	 jmp    Ret00
;  Open file errors processing:
ERROR:   mov    ERR0,ax           ;  error code
	 cmp    ax,2              ;  file not found
	 jne    Ret01             ;  not found, output error message
cmpio:   cmp    IO,0              ;  input file?
	 jz     Ret01             ;  yes, output message
;  Create and open output file:
Create:  mov    ERR0,0            ;  clear error flag
	 lea    dx,PATH2          ;  DX:=output file path offset
	 mov    ah,3Ch            ;
	 mov    cx,0              ;  CX:=file attributes
	 int    21h               ;
	 mov    HANDLE0,ax        ;  access word (file handle)
	 jnc    ret00             ;
	 mov    ERR0,ax           ;  error code
	 jmp    short Ret01       ;
;  POP registers and exit
Ret00:   mov    OP0,1             ;
Ret01:   POPR
	 RETN
GETFILE  ENDP
_TEXT    ENDS
;
;-----------------------------------------------------------------------
ZSEG     SEGMENT  'ZERO'
ZSEG     ENDS
	 END    START
