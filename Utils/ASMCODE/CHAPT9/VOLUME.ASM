;
;       Program Volume ( Chapter 9 )
;
	page    55,132
;**************************************************************************
;                                                                         *
;  VOLUME - Reading/modifying the disk label                              *
;                                                                         *
;  Author: A.I.Sopin,  VSU   1992,    Version 1.4                         *
;                                                   03-03-92 03:32pm      *
;**************************************************************************
.MODEL SMALL
EXTRN    DIAM00 : FAR, DIAM01 : FAR, COLOR : FAR , INSYM4 : FAR
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
;  Restore registers used
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
;
DIAM0   MACRO   TEXT$,OP$,M$,N$,U$,V$
	mov     TOFF,offset TEXT$    ;  address of text string
	mov     OP,OP$               ;  working mode
	mov     bx,M$                ;
	mov     M,bx                 ;  first line for output
	mov     bx,N$                ;
	mov     N,bx                 ;  last line for output
	mov     bx,U$                ;  cursor line or buffer address
	mov     U,bx                 ;
	mov     bx,V$                ;
	mov     V,bx                 ;
	mov     L,80                 ;
	lea     bx,PARM              ;
	push    bx                   ;  address of parameter list
	Call    DIAM00               ;
	ENDM
;  Call subroutine for screen cleaning and color setting
CLR     MACRO  M$,N$,C$
	mov    ch, &M$
	mov    dh, &N$
	mov    ah, &C$
	Call   Color
	ENDM
;----------------------------------------------------------
.STACK
;----------------------------------------------------------
.DATA   
MODE0   DB     0                       ;  screen mode
DISK0   DB     0                       ;  screen mode
TEXT0   DB     ' Reading/modifying the disk label             Version 1.4 ',0
TEXT1   DB     '   Drive : A  (Esc - exit) ', 0
TEXT2   DB     ' Disk label:  XXXXXXXXXXX  (PgUp - write modified label)  ',0
TEXT3   DB     ' New label written. Press Enter  ', 0
TEXT4   DB     ' Start sector:    =XXXXX ', 0
ERR1    DB     ' Error reading disk label.   ',0
ERR2    DB     ' Error writing disk label.   ',0
ERR3    DB     ' The disk has no label. Press F2 to create new one',0
SECTOR  DB      512 dup (0)
CX0     DW      0
SI0     DW      0
;  Parameter list for subroutines   DIAM00, DIAM01
	EVEN
PARM    LABEL  WORD                    ; parameter list (address in stack)
OP      dw     0                       ; operation code
M       dw     0                       ; number of first line
N       dw     0                       ; number of last line
TOFF    dw     0                       ; offset of text string
L       dw     80                      ; length of text string
U       dw     0                       ; cursor line  (1---25)
V       dw     0                       ; cursor column (1---80)
Q       dw     0                       ; accepted cursor line
S       dw     0                       ; accepted cursor location
W       db 4 dup (0)                   ; interrupt key code
IOFF    dw     0                       ; address of screen parameters list
;----------------------------------------------------------
.CODE
.Startup
	mov     ah,0Fh                  ;  function 0Fh - get video mode
	int     10h                     ;  BIOS video service call
	mov     MODE0,al                ;  save original video mode
	mov     ah,19h                  ;  function 19h - get current drive 
	int     21h                     ;  MS-DOS service call
	mov     DISK0,al                ;  drive number
	CLR     1,25,07h                ;  clear screen
	DIAM0   TEXT0,1,2,2,0,0
;----------------------------------------------------------
;  Ask for disk drive (line 3)
MAIN:   CLR     3,25,07h                ;  clear screen
	mov     ax,@DATA                ;  address of data segment
	mov     ds,ax                   ;
	DIAM0   TEXT1,3,3,-3,3,12
	cmp     W+1,1                   ;  Esc key?
	jne     M0
	jmp     Exit                    ;  entry
M0:     mov     al,TEXT1+11             ;
	and     al,0DFh                 ;  force uppercase
	cmp     al,'A'                  ;  drive A ?
	jb      MAIN                    ;  error
	cmp     al,'Z'                  ;  drive  Z ?
	ja      MAIN                    ;  error
	sub     al,41h                  ;  0 -A, 1 -B, 2 -C ...
	mov     CS:Disk,al              ;  save drive number
	mov     ah,0Eh                  ;  function 0Eh - set drive
	int     21h                     ;  DOS service call
;----------------------------------------------------------
;  Determining disk parameters  (Disk Info)
DosInfo:mov     ah,30h                  ;
	int     21h                     ;  MS-DOS  Version
	mov     dl,al                   ;  save version
	mov     ah,52h                  ;  DosInfo
	int     21h                     ;  ES:(BX-2)  -pDiskInfo
	LDS     bx,ES:[bx]              ;  DS:BX  -pFirstDrive
	mov     cx,26                   ;  number of performances of cycle
;  Read disk info block for next disks
M10:    mov     al,[bx]                 ;  drive number (0 -A, 1 -B)
	cmp     al,CS:Disk              ;  disk found ?
	je      M13                     ;
	add     bx,24                   ;  address of next block (or 0FFFFh)
	cmp     dl,4                    ;  DOS version <  4.0 ?
	jl      M11                     ;
	inc     bx                      ;  for DOS 4.0 and higher offset is 25
M11:    LDS     bx,[bx]                 ;  address of next block
	cmp     bx,0FFFFh               ;  end of chain?
	je      M12                     ;
	loop    M10                     ;  to cycle beginning
M12:    jmp     MAIN                    ;  error in path string
;----------------------------------------------------------
;  Calculating sector number from cluster number
M13:    mov     al,[bx]+4               ;  sectors per cluster - 1
	inc     al                      ;
	cbw                             ;
	mov     CS:SecClus,ax           ;  sectors per cluster
	mov     cx,4                    ;  elements in sector
	shl     ax,cl                   ;
	mov     CS:Clus32,ax            ;  directory entries per cluster
	mov     ax,[bx]+6               ;  SecRes
	mov     CS:SecRes,ax            ;  reserve sectors
	mov     al,[bx]+8               ;
	mov     CS:Fats,al              ;  number of  FATs
	mov     ax,[bx]+9               ;  MaxDir
	mov     CS:MaxDir,ax            ;  entries in root directory
	mov     ax,[bx]+11              ;  SecData
	mov     CS:SecData,ax           ;  start sector of data area
	mov     al,[bx]+15              ;  SecFat
	cbw                             ;
	mov     CS:SecFat,ax            ;  sectors per FAT
	mov     ax,[bx]+16              ;  SecDir (VER =3.xx)
	cmp     dl,4                    ;  DOS version <  4.0 ?
	jl      M14                     ;
	mov     ax,[bx]+17              ;  SecDir (VER =4.01, 5.00)
M14:    mov     CS:SecDir,ax            ;  start sector of root directory
	mov     CS:SEC,ax               ;  start sector of root directory
;  Output message about start sector (line =4)
	mov     dx,@DATA                ;
	mov     ds,dx                   ;  DS:BP - output buffer
	lea     bp,TEXT4+19             ;  address of buffer for editing
	xor     dx,dx                   ;  clear high part
	mov     si,5                    ;  number of digits
	Call    INSYM4                  ;  number in DX:AX
	DIAM0   TEXT4,1,4,-4,0,0
;----------------------------------------------------------
;  Read sectors of root directory
	mov     ax,CS:MaxDir            ;  entries in root directory
	mov     cl,4                    ;
	shr     ax,cl                   ;  sectors in directory
	mov     CX0,ax                  ;
M20:    Call    READ                    ;  read sector
	lea     si,SECTOR               ;  address of first sector
	mov     cx,16                   ;  entries per sectors
;  Cycle for processing directory entries in sector read
M21:    mov     SI0,si                  ;  save address of entry
	mov     ax,[si]                 ;
	and     ax,ax                   ;  empty entry ?
	jz      M23                     ;
	cmp     ax,0F600h               ;  empty entry ?  (Pctools)
	je      M23                     ;
	mov     al,[si]+11              ;  file attribute
	and     al,08h                  ;
	cmp     al,08h                  ;  label read ?
	jne     M22                     ;
	jmp     M25                     ;  label found
M22:    add     si,32                   ;  address of next entry
	loop    M21                     ;  to next cycle performance
	inc     CS:SEC                  ;  modify number sector
	dec     CX0                     ;  sectors left
	jg      M20                     ;  read next sector
;  Output message "label not found"
M23:    DIAM0   ERR3,2,5,-5,0,0
	cmp     W+1,1                   ;  Esc key?
	jne     M24                     ;
	jmp     MAIN                    ;  exit
M24:    cmp     W+1,3Ch                 ;  F2 - create label ?
	jne     M23                     ;
;  Ask for creating a new label (line 6)
	DIAM0   TEXT2,3,6,-6,6,15
	cmp     W+1,1                   ;  Esc key?
	jne     M27                     ;
	jmp     MAIN                    ;  exit
;  Output label read  (DS:SI - address of directory entry)
M25:    mov     cx,13                   ;  length of label
	mov     ax,@DATA                ;
	mov     es,ax                   ;  ES points to data segment
	lea     di,TEXT2+14             ;  target address
	cld                             ;  right direction
	mov     al,' '                  ;  space character
	rep     stosb                   ;  clear label area
	mov     cx,11                   ;  length of label
	lea     di,TEXT2+14             ;  target address
	rep     movsb                   ;  send label
;  Input new label for modification and writing (line 7)
M26:    DIAM0   TEXT2,3,6,-6,6,15
	cmp     W+1,1                   ;  Esc key?
	jne     M27                     ;
	jmp     MAIN                    ;  exit
M27:    cmp     W+1,49h                 ;  PgUp - write label ?
	je      M28                     ;
	jmp     MAIN                    ;
;  Write sector with the label modified onto disk
M28:    mov     ax,@DATA                 ;
	mov     es,ax                   ;  ES points to data segment
	mov     di,SI0                  ;  ES:DI - target address
	Call    VOLMOV                  ;  send label
	Call    WRITE                   ;  write logical sector
;  Write label in the  Boot-sector (offset 43)
	mov     CS:SEC,0                ;  Boot sector
	Call    READ                    ;  read sector
	lea     di,SECTOR+43            ;  target address
	Call    VOLMOV                  ;  send label
	Call    WRITE                   ;  write logical sector
	DIAM0   TEXT3,2,7,-7,0,0        ;  output message "label written"
	jmp     MAIN                    ;  perform program from beginning
;----------------------------------------------------------
;  Finish of the program's work
Exit:   xor     ah,ah                   ;  function 00h - set video mode
	mov     al,MODE0                ;  original video mode
	int     10h                     ;  BIOS video service call
	mov     dl,DISK0                ;  original disk drive
	mov     ah,0Eh                  ;  function 0Eh - set current drive
	int     21h                     ;  DOS swervice call
	mov     ax,4C00h                ;  function 4Ch - terminate process
	int     21h                     ;  DOS service call
;----------------------------------------------------------
;  Data in code segment
MaxDir  DW      0                       ;  Entries in root directory
NumClus DW      0                       ;  Cluster number
SecDir  DW      0                       ;  Start sector of root directory
SecData DW      0                       ;  Start sector of data area
SecRes  DW      0                       ;  Number of reserve sectors
SEC     DW      0                       ;  Logical sector number
SecClus DW      0                       ;  Sectors per cluster
SecFat  DW      0                       ;  sectors per FAT
Dirs    DW      0                       ;  Sectors in root directory
Fats    DB      0                       ;  Number of FAT
TypFat  DB      0                       ;  FAT type (12 or 16 bits)
Disk    DB      0                       ;  Drive number  0 -A, 1 -B, 2 -C...
Clus32  DW      0                       ;  Directory entries in cluster
;----------------------------------------------------------
;
;  Subroutine for sector reading  (INT  26h)
;
;  SEC   - number of logical sector
;
;  DS:BX - address of sector buffer
;
;  In case of an error the Carry Flag is set
;
;----------------------------------------------------------
READ    PROC    NEAR
	PUSHR   <bp,si,di>              ;  save registers
	lea     bx,SECTOR               ;  address of buffer for reading sector
	mov     ax,@DATA                ;
	mov     ds,ax                   ;  DS points to data segment
	mov     cx,1                    ;  number of sectors =1
	mov     al,CS:Disk              ;  drive number (0 -A, 1 -B...)
	mov     dx,CS:SEC               ;  sector number
	int     25h                     ;  read logical sector
	add     sp,2                    ;  adjust stack
	POPR    <di,si,bp>              ;  restore registers
	RETN
READ    ENDP
;----------------------------------------------------------
;
;  Subroutine for sector writing  (INT  26h)
;
;  SEC   - number of logical sector
;
;  DS:BX - address of sector buffer
;
;  In case of an error the Carry Flag is set
;
;----------------------------------------------------------
WRITE   PROC    NEAR
	lea     bx,SECTOR               ;  address of sector buffer
	mov     ax,@DATA                ;
	mov     ds,ax                   ;  DS points to data segment
	mov     cx,1                    ;  number of sectors =1
	mov     al,CS:Disk              ;  drive number (0 -A, 1 -B...)
	mov     dx,CS:SEC               ;  sector number
	int     26h                     ;  write logical sector
	pop     cx                      ;  adjust stack
	jc      ERROR                   ;  to error message
	RETN                            ;  normal exit
;  Output error message "label not written"
ERROR:  DIAM0   ERR2,2,7,-7,0,0         ;
	pop     cx                      ;  adjust stack
	jmp     MAIN                    ;
WRITE   ENDP
;----------------------------------------------------------
;
;  Subroutine for sending disk label
;
;  ES:DI - address where the label must be sent
;
;----------------------------------------------------------
VOLMOV  PROC    NEAR
	mov     cx,11                   ;  length of label
	mov     ax,@DATA                ;
	mov     ds,ax                   ;  DS points to data segment
	lea     si,TEXT2+14             ;  DS:SI - source
	cld                             ;  rigth direction
	rep     movsb                   ;  send label
	mov     byte ptr ES:[di],28h    ;  send attribute
	RETN
VOLMOV  ENDP
	END
