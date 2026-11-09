;**********************************************************************
;
;  Program Blink ( Chapter 8 )
;
;  Dialog INPUT/OUTPUT system for PC's screen.             Version  1.1
;
;  Subroutine for switching screen blinking/intensity attribute
;
;  Author: A.I.Sopin   Voronezh, Russia   1990 --- 1992
;  ------
;
;  Call from Assembler programs:
;
;       Call BLINK
;
;  Parameters passed through the AL registers:
;
;  AL  = 0 - intensity mode  (highlighted background)
;
;  AL  = 1 - blinking mode   (dark background - DOS default mode)
;
;  External subroutines required:
;  VidTyp
;
;**********************************************************************

EXTRN   VIDTYP : FAR

.MODEL  SMALL
.CODE
BLINK   PROC    FAR
        PUBLIC  BLINK
        push    ax
        push    bx
        push    cx
        push    dx
        push    es
;----------------------------------------------------------
;  The monitor type determining (MDA, CGA, EGA, ...)
        mov     ch,al                   ;  Read input parameter
        push    cx                      ;  Next call will destroy AX, BX, CX
        Call    VIDTYP                  ;  Determining adapter type.
                                        ;    result in AL
        pop     cx                      ;  Restore input parameter (CX)
        cmp     al,1                    ;  Is it CGA ?
        jl      Exit                    ;  If MDA/HGC - exit
        je      CGA                     ;  Process CGA
;  Toggle blinking for EGA and VGA adapters (INT 10h, AH=10h)
EGA:    mov     ah,10h                  ;  Function 10h
        mov     al,3                    ;  Subfunction 03 - toggle intensity
        xor     bl,bl                   ;  BL = 0 - intensity
        and     ch,ch                   ;  Check input parameter
        jz      Int10h                  ;  If 0 - call BIOS video service
        mov     bl,1                    ;  BL = 1 - blinking
Int10h: int     10h                     ;  BIOS video service call
        jmp     short Exit              ;  Leave the profgram
;  Toggle blinking for CGA using hardware
CGA:    xor     ax,ax                   ;
        mov     es,ax                   ;  0:[465h] - BIOS  Video Data Area
        mov     al,es:[465h]            ;  This is the previosly Video Mode
        or      al,20h                  ;  This constant stands for BLINKING
        cmp     ch,1                    ;  Check input parameter
        je      Out3D8                  ;  If 1 perform output into the port
        and     al,0DFh                 ;  This constant stands for INTENSITY
Out3D8: mov     dx,3D8h                 ;  Port 3D8h -
        out     dx,al                   ;  Toggle intensity mode
;----------------------------------------------------------
;  Restore registers and exit
Exit:   pop     es
        pop     dx
        pop     cx
        pop     bx
        pop     ax
        RETF
BLINK   ENDP
        END
