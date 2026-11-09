;************************************************************************
;                                                                       *
;  Resident program of starting prescribed job                          *
;                                                                       *
;  Activated on pressing: Alt + "hot"key (K)                            *
;                                                                       *
;  Author: SOPIN  A.I.  VSU,  Voronezh                                  *
;                                                                       *
;                                                                       *
;  Call:  EXEC TSRPGM /PATH [/PARM /S /K=40]                            *                                                              *
;  -----                                                                *
;  PATH - path to job to be started, e.g.:  D:\SYST0\dserv.exe          *
;        (positional parameter, the rest are key parameters)            *
;                                                                       *
;  PARM - list of parameters to be passed                               *
;                                                                       *
;  S    - saving screen to be restored afterwards                       *
;                                                                       *
;  K=XX -hex code of "hot" key                                          *
;                                                                       *
;                                                                       *
;  Alt + Shift (Right)  -deinstallation of  driver                       *
;                                                                       *
;                                                                       *
;  Interrupts used:  INT 08h, INT 09h, INT 13h, INT 28h                 *
;                                                                       *
;                                                                       *
;                                                                       *
;************************************************************************
NAME     TSRPGM
;  Saving of registers to be used
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
;  Restoring registers been used
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
CODE     SEGMENT
         ASSUME CS:CODE,DS:CODE,ES:CODE
         ORG    100h                    ;  PSP
START:   jmp    BEGIN                   ;  jumping to loading of driver
;----------------------------------------------------------
STAC     DB     4096 dup (0)
ERR00    DB     '*** TSRPGM ***  DOS is active !!! ', 0
ERR01    DB     '*** TSRPGM ***  Invalid function number ! ', 0
ERR02    DB     '*** TSRPGM ***  File is not found !!!', 0
ERR03    DB     '*** TSRPGM ***  Path is not found !!!', 0
ERR04    DB     '*** TSRPGM ***  Too many files been opened !!!', 0
ERR05    DB     '*** TSRPGM ***  Access is not allowed !!!', 0
ERR06    DB     '*** TSRPGM ***  Error in logical number !!!', 0
ERR07    DB     '*** TSRPGM ***  Block of memory control is destroyed !!!', 0
ERR08    DB     '*** TSRPGM ***  Lack of memory !!!', 0
ERR09    DB     '*** TSRPGM ***  Error of memory block address !!!', 0
ERR10    DB     '*** TSRPGM ***  Wrong operating environment !!!', 0
ERR11    DB     '*** TSRPGM ***  Invalid format !!!', 0
TEXT0    DB     'Driver *** TSRPGM ***  is deinstalled !!!', 0
ADRERR   DW     ERR01, ERR02, ERR03, ERR04, ERR05, ERR06
         DW     ERR07, ERR08, ERR09, ERR10, ERR11
DOSFLG   LABEL  DWORD                   ;  address of DOS activity indicator
OFFFLG   DW     0                       ;  offset of activity indicator:   BX
SEGFLG   DW     0                       ;  segment address of activity indicator: ES
;
OLD09H   LABEL  DWORD                   ;  address of standart vector  INT 09H
OFF09H   DW     0                       ;  offset of standart   INT 09h
SEG09H   DW     0                       ;  segment address of  INT 09h
;
OLD13H   LABEL  DWORD                   ;  entry point of standart  INT13H
OFF13H   DW     0                       ;  address of old vector  INT13H
SEG13H   DW     0                       ;  segment address of old  INT13H
;
OLD28H   LABEL  DWORD                   ;  entry point of standart INT28H
OFF28H   DW     0                       ;  address of old vector  INT28H
SEG28H   DW     0                       ;  segment address of old  INT28H
;
SSKEEP   DW     0                       ;
SPKEEP   DW     0                       ;
OLDPSP   DW     0                       ;
PSP0     DW     0                       ;
DTANEW   DW     64 dup (0)
DTAADR   LABEL  DWORD
DTAOFF   DW     0
DTASEG   DW     0
VIDEO    DW     0                       ;  address of videobuffer
CURSX    DB     0                       ;  position of cursor
CURSY    DB     0                       ;  line of cursor
MODE     DB     0                       ;  display mode
FLAG0    DB     0                       ;  flag of starting a job
FLAG1    DB     0                       ;  flag of activity of a job
EOS      DB     0                       ;  indicator of end of ASCIIZ -string
DL0      DB     0                       ;  cursor set position
;
InBios   DB     0                       ;  activity flag of INT 13h (BIOS)
ALT0     DB     0                       ;  previous  Alt
SCAN0    DB     0                       ;  scan-code of key (after  Alt)
KEY0     DB     40h                     ;  -82 code of prescibed key (after Alt)
SAV      DB     0                       ;  -81 sceen saving flag
PARAM    DW     7 DUP (0)               ;  -80
PATH     DB     64 dup (0)              ;  -66 path for starting
PRES     DW     1234                    ;  -2  driver presence code

;----------------------------------------------------------
;
;  New  handler  for INT09h
;
;  Alt + F6            -starting subordinate job
;
;  Alt + Shift (Right) -driver deinstallation
;
;
;
;----------------------------------------------------------
INT09H   PROC   FAR                  ;  new handler for  INT 09h
         cli                         ;  disable interrupts
         PUSHR                       ;
         mov    ax,40h               ;  keyboard data
         mov    ES,ax                ;  segment address for BIOS
         mov    ch,ES:[17h]          ;  register keys state
         and    ch,09h               ;  clear bits out of interest
         mov    CS:ALT0,ch           ;
         in     al,60h               ;  getting scan-code
         mov    CS:SCAN0,al          ;  saving scan-code
;  Check for driver deinstallation (Alt + Shift (Right))
         mov    cl,ES:[17h]          ;  register keys state byte
         and    cl,09h               ;  clear bits out of interest
         or     cl,ch                ;
         cmp    cl,09h               ;  Alt + Shift (right) ?
         jne    AltF6                ;
         pushf                       ;  flag register for  IRET (from INT 09H)
         Call   CS:OLD09H            ;  call of old handler for INT 09H
         Call   DEINST               ;  driver deinstallation
         POPR                        ;  restore registers
         sti                         ;  enable interrupts
         IRET                        ;  exit interrupt handling
;  Check of starting of a prescribed job ("hot" key Alt + KEY0)
AltF6:   and    ch,08h               ;  clear flags out of interest
         cmp    ch,08h               ;  previous  Alt ?
         jne    RET09                ;
         mov    al,CS:KEY0           ;  "hot" key code
         cmp    CS:SCAN0,al          ;  Alt + KEY0 - indicator of job started
         jne    RET09                ;
         cmp    CS:FLAG1,1           ;  job is active
         je     RET09                ;
;  Handling "hot" key code -starting a job
         mov    CS:FLAG0,1           ;  indicator of job started
         in     al,61h               ;  keyboard control port
         or     al,80h               ;  permisson bit
         out    61h,al               ;  send affirmation
         and    al,7Fh               ;  clear affirmation bit
         out    61h,al               ;  send to port  B
         mov    al,20h               ;  mask for 8259A chip
         out    20h,al               ;  affirmation of interrupt handling
         POPR                        ;  restore registers
         sti                         ;  enable interrupts
         IRET                        ;  exit interrupt handling
;  Restoring registers end exit
RET09:   pushf                       ;  flag register for  IRET (from INT 09H)
         Call   CS:OLD09H            ;  call old handler for  INT 09H
         POPR                        ;  restore registers
         sti                         ;  enable interrupts
         IRET                        ;  exit interrupt handling
INT09H   ENDP

;----------------------------------------------------------
;
;  Procedure for starting of a prescribed job (on Alt + KEY0)
;
;  Timer interrupt INT 08H is used
;
;
;----------------------------------------------------------
INT08H  PROC    FAR
        cli                             ;  disable interrupts
        cmp     CS:FLAG0,1              ;  job started ?
        jne     OLD08                   ;  no
        cmp     CS:FLAG1,1              ;  job active ?
        je      OLD08                   ;  wait for finish
        cmp     CS:InBios,1             ;  exchange with disk ?
        je      OLD08                   ;   wait for finish
        PUSHR   <es,bx>                 ;
        LES     bx,CS:DOSFLG            ;  address of DOS activity flag
        cmp     byte ptr ES:[bx],0      ;  DOS not active ?
        POPR    <bx,es>                 ;
        jnz     OLD08                   ;   wait for finish
;  Constructing stack for starting a job (on IRET from  INT 08h)
        PUSHR                           ;  registers of interrupted job
        pushf                           ;  flags register for IRET (INT 08h)
        push    cs                      ;  segment address for exit
        lea     cx,ACTIV                ;  address of program for starting job
        push    cx                      ;  put onto stack for  IRET
OLD08:  DB      0EAh                    ;  code of  JMP FAR ...  instruction
OLD08H  LABEL   DWORD                   ;  entry point of standard INT08H
OFF08H  DW      0                       ;  address of old vector  INT08H
SEG08H  DW      0                       ;  segment address of old  INT08H
INT08H  ENDP


;----------------------------------------------------------
;
;  Activating the resident program (on Alt + F6)
;
;  Dynamic start of prescribed job
;
;
;----------------------------------------------------------
ACTIV   PROC    FAR
        cli
        mov     CS:SSKEEP,SS      ;  save SS register
        mov     CS:SPKEEP,SP      ;  save SP register
        mov     ax,cs             ;
        mov     SS,ax             ;  segment of new stack
        lea     SP,STAC+4096      ;  switch to interior stack
        Call    SAVESCR           ;  save screen
        mov     ah,2fh            ;  read address of current DTA
        int     21h               ;
        cli
        mov     CS:DTASEG,es      ;
        mov     CS:DTAOFF,bx      ;  save  DTA address
;  Save old process (address of PSP of interrupted program)
        mov     ah,62h            ;
        int     21h               ;  GetProcess
        mov     CS:OLDPSP,bx      ;  PSP  of interrupted process
        cli
        mov     ax,cs             ;
        mov     ds,ax             ;
        lea     dx,CS:DTANEW      ;  DS:DX  -address of new  DTA
        mov     ah,1ah            ;
        int     21h               ;  set new  DTA
        cli
        mov     bx,CS:PSP0        ;  address of PSP of resident program
        mov     ah,50h            ;
        int     21h               ;  SetProcess
;  Dynamic start of job
        mov     CS:FLAG0,0        ;  clear flag of starting a job
        mov     CS:FLAG1,1        ;  job activity flag
        cli
        mov     ax,cs             ;
        mov     ds,ax             ;  segment address of path and name of file
        mov     es,ax             ;  EX-  segment address of data
        lea     bx,PARAM          ;  BX -offset of parameters address
        lea     dx,PATH           ;  offset of path and name of file
        mov     ah,4Bh            ;  code of function that starts subroutine
        xor     al,al             ;  AL =0 -start subroutine
        int     21h               ;  EXEC - execution
        mov     bx,ax             ;  termination code of  EXEC
        mov     CS:FLAG1,0        ;  clear job activity flag
        jnc     Exit0             ;  normal termination
;  Determination of error type and message output (CF =1)
        mov     ax,cs             ;
        mov     ds,ax             ;  segment address of path and name of file
        dec     bx                ;
        shl     bx,1              ;  *2
        lea     bx,ADRERR [bx]    ;  address of element of addresses table
        mov     bx,[bx]           ;  address mof message
        Call    ERROR             ;  output error message
;  Restore old process (address of PSP  of interrupted program)
Exit0:  Call    RESTSCR           ;  restore screen
        cli                       ;
        mov     bx,CS:OLDPSP      ;  PSP  of interrupted process
        mov     ah,50h            ;
        int     21h               ;  SetProcess
        cli                       ;
        lds     dx,CS:DTAADR      ;  address of  DTA of interrupted program
        mov     ah,1Ah            ;
        int     21h               ;  return  DTA  of interrupted program
        mov     SS,CS:SSKEEP      ;  restore  SS register
        mov     SP,CS:SPKEEP      ;  restore  SP register
        POPR                      ;  registers of interrupted job
        IRET                      ;  return to point of interrupt
ACTIV   ENDP

;----------------------------------------------------------
;
;  Procedure for handling  INT 13h (disk exchange) interrupt
;
;
;----------------------------------------------------------
INT13H  PROC    FAR
        mov     CS:InBios,1             ;  disk activity flag
        pushf                           ;  flags register for  IRET (INT 13H)
        Call    CS:OLD13H               ;  call old handler for INT 13H
        mov     CS:InBios,0             ;  disk is not active
        IRET                            ;
INT13H  ENDP

;----------------------------------------------------------
;
;  Procedure for handling  INT 28h interrupt
;
;
;----------------------------------------------------------
INT28H  PROC    FAR
        pushf                        ;  flags register for  IRET (INT 28h)
        Call    CS:OLD28H            ;  call old handler for  INT 28H
        cli                          ;  disable all interrupts
;  Check the "hot" key pressing
        cmp     CS:FLAG0,1           ;  job started ?
        jne     RET28                ;
        cmp     CS:FLAG1,1           ;  job active ?
        je      RET28                ;  wait for termination
        cmp     CS:InBios,1          ;  disk exchange ?
        je      RET28                ;  wait for termination
        PUSHR   <es,bx>              ;
        LES     bx,CS:DOSFLG         ;  address of  DOS activity flag
        cmp     byte ptr ES:[bx],0   ;  DOS  not active ?
        POPR    <bx,es>              ;
        jnz     RET28                ;  wait for termination
;  Constructing stack for starting a job (on IRET from  INT 28h)
        PUSHR                        ;  registers of interrupted job
        pushf                        ;  flags register for IRET (INT 28h)
        push    cs                   ;  segment address for exit
        lea     cx,ACTIV             ;  address of program for starting job
        push    cx                   ;  put onto stack for  IRET
        IRET                         ;
;  Restoring registers and exit
RET28:  sti                          ;  enable all interrupts
        IRET                         ;
INT28H  ENDP

;-----------------------------------------------------------
;
;  Subroutine for error message output
;
;  BX  -address of start of a text string
;
;
;
;-----------------------------------------------------------
ERROR   PROC    NEAR
        PUSHR                     ;  save registers
        mov     bp,80             ;  characters count
        mov     dh,24             ;  line of output =25
        mov     dl,0              ;  column of output =1
        Call    PUTSTR            ;  output message
        mov     di,1000           ;  signal frequency  1000 h
        mov     bx,25             ;  time of signal  0.25 seconds
        Call    SOUND             ;  output sound signal
        mov     cx,20             ;  time of delay (in ticks)
        Call    DELAY             ;  generate delay
        POPR                      ;  restore registers
        RETN                      ;
ERROR   ENDP

;-----------------------------------------------------------
;
;  Subroutine for screen output of text
;
;  BX  -address of text string start
;
;  BP  -characters counter
;
;  DH  -starting line of cursor  (0 --- 24)
;
;  DL  -starting column of cursor (0 --- 79)
;
;
;  On achieving  0  remained part of string is cleared
;
;
;
;
;-----------------------------------------------------------
PUTSTR  PROC    NEAR
        mov     byte ptr CS:EOS,0       ;  clear End Of String flag
Cycle1: push    bx                      ;  save address of character
        xor     bh,bh                   ;  screen N  0
        mov     ah,2                    ;  function of cursor setting
        int     10h                     ;  set cursor
        pop     bx                      ;  restore address of character
        mov     al,[bx]                 ;
        cmp     byte ptr CS:EOS,0       ;  is end of string achieved ?
        jz      Zero                    ;
        mov     al,' '                  ;  transmitt space
        jmp     short  Putsym           ;
;  Check for End Of String (character =0)
Zero:   and     al,al                   ;  End Of String ?
        jnz     Putsym                  ;
        mov     CS:DL0,dl               ;  position for cursor setting
        mov     byte ptr CS:EOS,1       ;  End Of Sring is found
Putsym: mov     ah,07h                  ;  grey characters on dark background
        Call    WRCHAR                  ;  write character to the cursor position
        inc     bx                      ;  modify address of text
        inc     dl                      ;  modify cursor position
        dec     bp                      ;  counter of rest of characters
        jg      Cycle1                  ;  to the start of cycle
;  Set cursor to the end of the output line
        xor     bh,bh                   ;  screen # 0
        mov     ah,2                    ;  function for cursor setting
        mov     dl,CS:DL0               ;  position for cursor setting
        int     10h                     ;  set cursor
        RETN
PUTSTR  ENDP

;-----------------------------------------------------------
;
;  Subroutine for writing character to cursor position
;
;  AL  -character being written
;
;  AH  -required attribute
;
;
;-----------------------------------------------------------
WRCHAR  PROC    NEAR
        push    bx                ;
        mov     bx,ax             ;  save character + attribute
        mov     al,dh             ;  multiplier - line of cursor
        mov     cl,160            ;  multiplier =160
        mul     cl                ;  calculate offset of video buffer
        xor     cx,cx             ;
        mov     cl,dl             ;  to add cursor column
        sal     cx,1              ;  *2
        add     ax,cx             ;  offset is calculated
;  Writing one character + attribute to video buuffer
        mov     di,ax             ;
        mov     ax,CS:VIDEO       ;  segment address of video buffer
        mov     ES,ax             ;
        mov     ES:[DI],bx        ;  move character + attribute
        add     DI,2              ;
        pop     bx
        RETN
WRCHAR  ENDP

;-----------------------------------------------------------
;
;  Subroutine for generating of delay (in ticks)
;
;  CX  -time of delay
;
;
;-----------------------------------------------------------
DELAY   PROC    NEAR
        PUSHR   <ax,dx,es>
        mov     ax,40h               ;
        mov     ES,ax                ;  segment address of BIOS area
        sti                          ;  enable interrupts
T0:     mov     dx,ES:[6Ch]          ;  starting time (in ticks)
T1:     cmp     dx,ES:[6Ch]          ;  has time  gone ?
        je      T1                   ;  no !!!
        loop    T0                   ;
        POPR    <es,dx,ax>
        RETN
DELAY   ENDP

;----------------------------------------------------------
;
;  Subroutine for outputting sound of a given tone
;
;  Frequency   -  di register (from  21  to  65535  h)
;
;  Duration -  bx register (in hundredths of second)
;
;
;
;----------------------------------------------------------
SOUND    PROC   NEAR
         PUSHR
         mov    al,0B6h           ;  write timer mode
         out    43h,al            ;  write to control register
         mov    dx,14h            ;  high part of divisor
         mov    ax,4F38h          ;  DX:AX = 1331000
         div    di                ;  1331000/frequency
         out    42h,al            ;  write low part
         mov    al,ah             ;
         out    42h,al            ;  write high part
         in     al,61h            ;  read port B
         mov    ah,al             ;  remember state of port B
         or     al,3              ;  resolution of timer and sound
         out    61h,al            ;
;  Generation of delay in hundredth of second (value in   BX)
Waitr:   mov    cx,2801           ;  duration 0.01 s
         loop   $                 ;  delay  0.01 s
         dec    bx                ;  has time gone ?
         jnz    Waitr             ;  no
         mov    al,ah             ;
         out    61h,al            ;  restore state of port B
         POPR                     ;
         RETN                     ;
SOUND    ENDP

;----------------------------------------------------------
;
;  Procedure for saving the state of screen
;
;
;----------------------------------------------------------
SAVESCR PROC    NEAR
        cmp     byte ptr CS:SAV,0 ;  to save creen or not ?
        jz      ExitS             ;
        PUSHR                     ;
        mov     ah,0Fh            ;  function for reading current mode
        int     10h               ;  determine current mode
        mov     CS:MODE,al        ;  sceen mode is read
        mov     ah,3              ;  read cursor position
        xor     bh,bh             ;  page number
        int     10h               ;
        mov     CS:CURSY,dh       ;  cursor line
        mov     CS:CURSX,dl       ;  cursor column
;  Read video buffer for saving
        mov     ax,CS:VIDEO       ;  address of video buffer
        mov     ds,ax             ;  move it to DS
        push    cs                ;
        pop     es                ;  output data segment
        xor     si,si             ;  address of start of video buffer
        lea     di,BUFER          ;  address of saving buffer
        cld                       ;  direction - forward !
        mov     cx,2000           ;  number of words
        rep     movsw             ;  read  2000  words of screen
        POPR                      ;
ExitS:  RETN
SAVESCR ENDP

;----------------------------------------------------------
;
;  Procedure for restoring screen state
;
;
;----------------------------------------------------------
RESTSCR PROC    NEAR
        cmp     byte ptr CS:SAV,0 ;  to restore screen or not ?
        jz      ExitR             ;
        PUSHR                     ;
        xor     ah,ah             ;  function for setting mode
        mov     al,CS:MODE        ;  read screen mode
        int     10h               ;  set screen mode
;  Restoring video buffer
        mov     ax,CS:VIDEO       ;  address of video buffer
        mov     es,ax             ;  address to ES
        push    cs                ;
        pop     ds                ;  original data segment
        lea     si,BUFER          ;  address of saving buffer
        xor     di,di             ;  address of start of video buffer
        cld                       ;  direction - forward !
        mov     cx,2000           ;  number of words
        rep     movsw             ;  restore  2000  words of screen
;  Restoring position of cursor
        mov     ah,2              ;  set cursor position
        xor     bh,bh             ;  number of page
        mov     dh,CS:CURSY       ;  cursor line
        mov     dl,CS:CURSX       ;  cursor column
        int     10h               ;
        POPR                      ;
ExitR:  RETN
RESTSCR ENDP

;----------------------------------------------------------
;
;
;  Procedure for deinstallation of  TSRPGM driver
;
;
;
;----------------------------------------------------------
DEINST  PROC    NEAR
        LES     bx,CS:DOSFLG            ;  address of DOS activity flag
        cmp     byte ptr ES:[bx],0      ;  is not DOS active ?
        jnz     RDINST                  ;  wait for termination
;
        Call    SAVESCR           ;  save screen
        cli                       ;  disable interrupts for time of substitution
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        lds     dx,OLD08H         ;  DS:DX -address of old vector
        mov     ax,2508H          ;  return old interrupt vector for INT 08H
        int     21h               ;
;
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        lds     dx,OLD09H         ;  DS:DX -address of old vector
        mov     ax,2509H          ;  return old interrupt vector for  INT 09H
        int     21h               ;
;
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        lds     dx,OLD13H         ;  DS:DX -address of old vector
        mov     ax,2513H          ;  return old interrupt vector for   INT 13H
        int     21h               ;
;
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        lds     dx,OLD28H         ;  DS:DX -address of old vector
        mov     ax,2528H          ;  return old interrupt vector for   INT 28H
        int     21h               ;
;  Output message about deinstallation of driver
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        lea     bx,TEXT0          ;  address of text
        mov     bp,80             ;  characters counter
        mov     dh,24             ;  line of output =25
        mov     dl,0              ;  column of output =1
        Call    PUTSTR            ;  output string of message
        mov     cx,15             ;  time of delay (in ticks)
        Call    DELAY             ;  generate delay
        Call    RESTSCR           ;  restore screen
;  Releasing memory occupied by driver
        mov     ax,cs             ;  data segment in code segment
        mov     ds,ax             ;
        mov     es,ax             ;
        mov     ah,49h            ;  FREEMAIN
        int     21h               ;  release memory
        sti                       ;  enable inerrupts
RDINST: RETN
DEINST  ENDP
;
BUFER   DB      4000 dup (0)      ;  buffer for  saving screen
;
;----------------------------------------------------------
;
;  Program for initial loading of  resident part of driver
;
;
;----------------------------------------------------------
;  Check for presence already loaded driver  TSRPGM
BEGIN:  mov     ax,3509h          ;  read address of current vector for INT 09h
        int     21h               ;  ES:BX  -address of vector
        mov     ax,es:[bx-2]      ;  driver presence code
        mov     LOD,0             ;  don't load driver
        cmp     ax,PRES0          ;  is driver in memory already ?
        je      M20               ;  yes, process parameters
        mov     LOD,1             ;  loading of driver is required
        mov     ax,cs             ;
        mov     ES,ax             ;
        lea     di,INT09H         ;  ES:DI -address of new vector  INT09H
        jmp     short M21
;  Processing command string (if present)
M20:    xor     di,di                   ;
        mov     ES,di                   ;  segment address =0
        les     di,ES:[24h]             ;  ES:DI  -address of old vector
M21:    mov     ADRINT,di               ;  address of start of vector for INT09H
        mov     bx,80h                  ;  address of length of parameters field
        mov     cl,[bx]                 ;  length of parameters field
        xor     ch,ch                   ;  CX -length of command string
        and     cl,cl                   ;  are parameters absent ?
        jz      NOPARM                  ;  they're absent !!!
        inc     bx                      ;
;  Processing parameters of command string
M22:    mov     al,[bx]                 ;  character from command string
        cmp     al,'/'                  ;  start of parameter ?
        je      M23                     ;
        inc     bx                      ;  address of next character
        loop    M22                     ;  to start of cycle
        jmp     ERPARM                  ;
;----------------------------------------------------------
;  Outputting message about absence of parameters and request for input
NOPARM: lea     dx,ERR1                 ;  parameters are absent
        mov     ax,cs                   ;  data segment in code segment
        mov     ds,ax                   ;
        mov     ah,9                    ;  code of text output function
        int     21h                     ;  output message
TASK2:  lea     dx,ERR2                 ;  parameters are absent
        mov     ax,cs                   ;  data segment in code segment
        mov     ds,ax                   ;
        mov     ah,9                    ;  code of text output function
        int     21h                     ;  output message
        lea     dx,ERR3                 ;  parameters are absent
        mov     ah,9                    ;  code of text output function
        int     21h                     ;  output message
        Call    INPUT                   ;  request for  parameters input
        mov     cl,LENG                 ;  length of field
        cmp     LENG,0                  ;  esmty input ?
        jna     Exit00                  ;  exit
        lea     bx,PARM                 ;  parametrs field from  PARM string
        cmp     byte ptr PARM,'/'       ;
        je      M23                     ;  continue work
        lea     bx,PARM-1               ;  parametrs field from  PARM string
        jmp     short M23               ;  path without "/"
Exit00: mov     ax,4c00h                ;  terminate program with 0 code
        int     21h                     ;  return to  MS-DOS
;  Output message on error in parameters
ERPARM: lea     dx,ERR4                 ;  error in parameters
        mov     ax,cs                   ;  data segment in code segment
        mov     ds,ax                   ;
        mov     ah,9                    ;  code of text output function
        int     21h                     ;  output message
        jmp     short TASK2             ;
;----------------------------------------------------------
;  Clearing the path of file being loaded
;  ES:DI  -address of entry point of   INT09H (in the program)
M23:    push    cx                      ;  counter for length of  PARM  field
        inc     bx                      ;
        mov     cx,64                   ;  length of path
        xor     al,al                   ;
        sub     di,66                   ;  address of start of PATH
        cld                             ;
        rep     stosb                   ;  clear  PATH (ES:DI)
        pop     cx                      ;
;  Passing from the PARM field the path for file being loaded (DS:BX)
        sub     di,64                   ;  address of start of   PATH
M24:    mov     al,[bx]                 ;  character of name from PARM (DS:BX)
        cmp     al,' '                  ;  end of name ?
        jna     M25                     ;
        stosb                           ;  pass character to  PATH
        inc     bx                      ;  address of next character from PARM
        loop    M24                     ;  to the start of the cycle
;  Search for parameter of video buffer saving:  /S (while loading only)
M25:    mov     BX0,bx                  ;  address of next character
        mov     CX0,cx                  ;  length of the rest of parameters field
        jcxz    M27                     ;  no additional parameters
        cmp     LOD,1                   ;  is loading required ?
        jne     M26                     ;  no, parameter can't be defined
        lea     si,PSAV                 ;  address of standard
        mov     dx,Lpsav                ;  length of standard
        Call    COMPAR                  ;  search for key parameter
        mov     di,ADRINT               ;  address of start of vector  INT09H
        mov     byte ptr ES:[di]-81,0   ;  clear screen saving flag
        jc      M26                     ;  parameter not found
        mov     byte ptr ES:[di]-81,1   ;  screen saving flag
;  Search for the prescribed "hot" key code: /K=KEY0   (Alt + KEY0)
M26:    mov     bx,BX0                  ;  address of next character after   PATH
        mov     cx,CX0                  ;  length of the rest of parameters field
        lea     si,PKEY                 ;  address of standard
        mov     dx,Lpkey                ;  length of standard
        Call    COMPAR                  ;  search for key parameter
        mov     di,ADRINT               ;  address of start of vector  INT09H
        mov     byte ptr ES:[di]-82,40h ;  F6 key code
        jc      M27                     ;  parameter not found
        mov     ax,[bx]                 ;  address of given key code
        Call    SYMHEX                  ;
        jc      M27                     ;  transformation error
        mov     ES:[di]-82,al           ;  prescribed "hot" key code
M27:
;  Output message onchanging parameters of driver
        cmp     LOD,1                   ;  is load required ?
        je      REGIM                   ;  yes, it is
        mov     di,1000                 ;  frequency  1000 h
        mov     bx,25                   ;  duration  0.25 s
        Call    SOUND                   ;  output sound signal
        lea     dx,LOAD1                ;
        mov     ah,9                    ;  code of text output function
        int     21h                     ;  output message
        mov     ax,4c00h                ;  terminate program with 0 code0
        int     21h                     ;  return to  MS-DOS
;----------------------------------------------------------
;  Determining the segment address of video buffer
REGIM:   mov    ax,cs               ;
         mov    ds,ax               ;  data segment in code segment
         mov    VIDEO,0B000H        ;  address of video buffer for monochrom display
         mov    ax,40h              ;  segment address of  BIOS area
         mov    ES,ax               ;  ES -address of  BIOS data area
         mov    al,ES:[10h]         ;  read hardware list  0040 : 0010
         and    al,30h              ;  clear bits out of interest
         cmp    al,30h              ;  is it a monochrom display ?
         je     Modvec              ;  yes !
         mov    VIDEO,0B800H        ;  address of video buffer for color display
;  Get the address of DOS activity flag (int 34h)
MODVEC: mov     ah,34h            ;  Get the address of DOS activity flag
        int     21h               ;  address of flag in  ES:BX
        mov     SEGFLG,ES         ;
        mov     OFFFLG,BX         ;
        mov     PSP0,cs           ;
        cli                       ;  disable interrupts for the time of substitution
;  Reading and saving the old vector  INT08H
        mov     ax,3508h          ;  read  address of current vector INT 08h
        int     21h               ;  ES:BX  -address been read
        mov     OFF08H,bx         ;  pass address of old vector
        mov     SEG08H,es         ;  pass segment address of old vector
        lea     dx,INT08H         ;  DS:DX -address of new vector
        mov     ax,2508h          ;  activate new interrupt  INT 08h  vector
        int     21h               ;
;  Modify address of keyboard interrupt INT 09H vector
        mov     ax,3509h          ;  read  address of current vector  INT 09h
        int     21h               ;  ES:BX  -address been read
        mov     OFF09H,bx         ;  pass address of old vector
        mov     SEG09H,es         ;  pass segment address of old vector
        lea     dx,INT09H         ;  DS:DX -address of new vector
        mov     ax,2509h          ;  activate new interrupt  vector  INT 09h
        int     21h               ;
;  Reading and modyfying an old vector for interrupt 13h
        mov     ax,3513H          ;  read  address of current vector  INT 13H
        int     21h               ;  ES:BX  -address been read
        mov     OFF13H,bx         ;  pass address of old vector
        mov     SEG13H,es         ;  pass segment address of old vector
        lea     dx,INT13H         ;  DS:DX -address of new vector
        mov     ax,2513H          ;  activate new interrupt  vector   INT 13H
        int     21h               ;
;  Reading and modyfying an old vector for interrupt 28h
        mov     ax,3528h          ;  read  address of current vector  INT 28h
        int     21h               ;  ES:BX  -address been read
        mov     OFF28H,bx         ;  pass address of old vector
        mov     SEG28H,es         ;  pass segment address of old vector
        lea     dx,INT28H         ;  DS:DX -address of new vector
        mov     ax,2528h          ;  activate new interrupt  vector  INT 28h
        int     21h               ;
        sti                       ;  enable interrupts (substitutions have been performed)
;  Loading the resident part of the program
        lea     dx,LOAD0          ;  address of message
        mov     ah,9              ;  code of text output function
        int     21h               ;  output message on driver loading
        lea     dx,BEGIN          ;  length of resident part  (byte)
        cmp     SAV,1             ;  to save screen ?
        je      KEEP              ;
        lea     dx,BUFER          ;  length of resident part without  BUFER
KEEP:   mov     cl,4              ;
        shr     dx,cl             ;  length of resident part in paragraphs
        add     dx,20             ;  16  paragraphs for  PSP + 4
        mov     ax,3100h          ;  terminate and state resident
        int     21h               ;  KEEP

;----------------------------------------------------------
;
;
;  Procedure for parameters input (path of job to be started)
;
;  ES:DI  -address of INT09H  vector
;
;  CX     -lenth of string input (on exitting procedure)
;
;
;
;----------------------------------------------------------
INPUT   PROC    NEAR
        PUSHR
        PUSHR   <es,di>                 ;  ES:DI  -address  INT09H
        push    cs                      ;
        pop     es                      ;  data segment in code segment
        lea     di,LENG                 ;  address for start of clearing
        mov     cx,81                   ;  length of string being cleared
        xor     al,al                   ;  clearing character =0
        cld                             ;
        rep     stosb                   ;  clear string
        lea     dx,MAX                  ;  DS:DX -address of start of string
        mov     ah,0Ah                  ;  input string
        int     21h                     ;
;  Passing the input parameters to the  PARM field
        POPR    <di,es>                 ;  ES:DI  -address of INT09H
        sub     di,66                   ;  address of start of PATH
        xor     ch,ch                   ;  clear high part
        mov     cl,LENG                 ;  length of input information
        lea     si,PARM                 ;
        rep     movsb                   ;  pass the path been input
        mov     byte ptr es:[di],0      ;  end of path indicator
        POPR                            ;
        RETN                            ;  exit
INPUT   ENDP

;----------------------------------------------------------
;
;
;  Procedure for search of a given key word in  PARM field
;
;  DS:BX  -address of start of parameters field on running
;
;  DS:SI  -address of standard (key word)
;
;  DX     -length of standard
;
;  CX     -length of field for parameter search
;
;  CF =1  -parameter is not found
;
;
;
;----------------------------------------------------------
COMPAR  PROC    NEAR
;  Reducing letters to capitals
M100:   mov     al,[bx]                 ;  character from  PARM field
        cmp     al,'a'                  ;  character < a ?
        jb      M101                    ;
        cmp     al,'z'                  ;  character > z ?
        ja      M101                    ;
        and     al,0DFh                 ;  reduce to capitals
;  Searching for coinsiding characters of parameter string and standard
M101:   cmp     [si],al                 ;  is character of standard found ?
        je      M102                    ;  compare next character
        inc     bx                      ;  address of nextcharacter from  PARM
        loop    M100                    ;  continue search
        jmp     short  Nocomp           ;  paramener not found
M102:   inc     si                      ;  address of next byte of standard
        inc     bx                      ;  address of next byte of   PARM
        dec     dx                      ;  length of rest of standard
        jz      Normal                  ;
        loop    M100                    ;  continue search
;  Exit on key parameter not found
Nocomp: stc                             ;  CF =1 - error indicator
        RETN                            ;  exit
;  Exit on key parameter  found
Normal: clc                             ;  clear carry flag
        RETN                            ;  exit
COMPAR  ENDP

;------------------------------------------------------------------------
;
;  Transforming two characters into byte   (ASCII ---> HEX)
;
;  Input:
;  -----
;  AH  -lower byte of a numeral (transformed into right nybble)
;  AL  -higher byte of a numeral (transformed into left nybble)
;
;  Output:
;  ------
;  AL  -output result (two nybbles for hex numerals)
;
;  CF =1 -transformation error code
;
;
;
;
;------------------------------------------------------------------------
;
SYMHEX  PROC    NEAR
        Call    TRANS             ;  transforming numeral from AL
        jc      ExitH             ;  exit on error
        shl     al,1              ;  shift nybble to the left  (higher part)
        shl     al,1              ;
        shl     al,1              ;
        shl     al,1              ;  left nybble  of result is in AL
        xchg    al,ah             ;  AL - higher byte for right nybble
        Call    TRANS             ;  transform character from  AL
        jc      ExitH             ;  exit on error
        or      al,ah             ;  merge right + left nybbles
        clc                       ;  normal transformation indicator
ExitH:  RETN                      ;  result in AL
SYMHEX  ENDP

;----------------------------------------------------------
;
;  Transforming a character into a hex
;
;  AL  -given character of hex numeral (ASCII -input)
;
;  AL  -transformed hex numeral (right nybble)
;
;
;
;----------------------------------------------------------
TRANS   PROC    NEAR
        cmp     al,30h            ;  character < 0 ?
        jl      ErrorH            ;  error
        cmp     al,39h            ;  character >  9 ?
        jg      Caps              ;  test for capitals A----F
        sub     al,30h            ;  subtract constant for ciphers
        jmp     short Eoc         ;
;  Transforming capitals    A----F
Caps:   cmp     al,41h            ;  character < A ?
        jl      ErrorH            ;  error
        cmp     al,46h            ;  character > F ?
        jg      Little            ;  test for small letters a --- f
        sub     al,37h            ;  subtract constant for small letters
        jmp     short Eoc         ;
;  Transforming small letters  a----f
Little: cmp     al,61h            ;  character < a ?
        jl      ErrorH            ;  error
        cmp     al,66h            ;  character > F ?
        jg      ErrorH            ;  error
        sub     al,57h            ;  subtract constant for small letters
; Transformation  peformed without errors
Eoc:    clc                       ;  clear carry flag
        RETN                      ;  normal exit
;  Error on character transformation error
ErrorH: stc                       ;  carry flag on error
        RETN
TRANS   ENDP

;----------------------------------------------------------
LOD     DB      0                 ;
PRES0   DW      1234              ;  driver presence code
ADRINT  DW      0                 ;  address of entry point of  INT09H vector
BX0     DW      0                 ;  address after path in PARM field
CX0     DW      0                 ;  length of rest of parameters field
PSAV    DB      '/S'              ;
Lpsav   EQU     $-PSAV
PKEY    DB      '/K='             ;
Lpkey   EQU     $-PKEY
LOAD0   DB      10,13,'Driver  *** TSRPGM ***  is loaded $ ',13,10
LOAD1   DB      10,13,'*** TSRPGM ***  Parameters are changed !!! $ ',13,10
ERR1    DB      10,13,'*** TSRPGM ***  Parameters are absent !!!$'
ERR2    DB      10,13,'                Alt + Shift (Right) -deinstallation$'
ERR3    DB      10,13,'Define:        /PATH [/S] [/K=KEY] ', 13, 10, '$'
ERR4    DB      10,13,'*** TSRPGM ***  Errors in parameters !!!$ '
        DB      13,10
MAX     DB      80                ;  maximum length of input string
LENG    DB      0                 ;  actual length of input string
PARM    DB      80 dup (0)        ;  information been input (without  CR)
CODE    ENDS
        END     START
