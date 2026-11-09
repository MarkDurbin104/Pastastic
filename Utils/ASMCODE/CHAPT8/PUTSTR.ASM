;-----------------------------------------------------------
;
;  Program PutStr ( Chapter 8 )
;
;  Procedure for an ASCIIZ-string onto the screen
;
;  Author:  A.I.Sopin      VSU,     Voronezh, 1992
;
;  Input parameters:
;
;  DS:SI -address of the start of a text string
;
;  CX - counter of characters been written (<= 80)
;
;  Otherwise the string length is assumed when the zero byte is reached
;
;  AH - attribute of a character being written
;
;  DX - address for outputting a string
;
;  DH - starting line  (0 --- 24)
;
;  DL - starting column (0 --- 79)
;
;  External procedures being used: 
;
;  VIDTYP - determining of video adapter type and segment address
;
;  WRCHAR - writing of character + attribute into video buffer
;-----------------------------------------------------------

EXTRN   VIDTYP : FAR, WRCHAR : FAR

.MODEL  SMALL
.CODE
PUTSTR  PROC    FAR
        PUBLIC  PUTSTR
        push    bx                      ;  save video page number
        push    cx                      ;  save length counter
        push    dx                      ;  save output address
        push    si                      ;  save output address
        push    bp                      ;  save output address
        push    es                      ;  save output address
;  Determining the video adapter type and thesegment address
        push    ax                      ;
        push    cx                      ;  save counter-delimiter
        push    dx                      ;  save line-column
        Call    VIDTYP                  ;  determining video adapter type
        mov     bl,al                   ;  video adapter type
        mov     es,dx                   ;  video buffer address
        pop     dx                      ;  restore line-column
        pop     cx                      ;  restore delimiter
        pop     ax                      ;
;  Cycle on reading one character of the string and writing to video buffer
Cycle:  lodsb                           ;  pass a character 
        and     al,al                   ;  is the end of the string reached ?
        jz      Exit                    ;  don't output 0 !!!
        mov     bp,cx                   ;  save counter
        mov     cx,1                    ;  output one character
        Call    WRCHAR                  ;  write character at the address: DH, DL
        mov     cx,bp                   ;  restore counter
        inc     dl                      ;  modify column of output
        loop    Cycle                   ;  to the start of the cycle
;  Restoring the registers and exit
Exit:   pop     es                      ;
        pop     bp                      ;
        pop     si                      ;
        pop     dx                      ;  restore address for output
        pop     cx                      ;  restore length counter
        pop     bx                      ;  restore address of line
        RETF
PUTSTR  ENDP
        END
