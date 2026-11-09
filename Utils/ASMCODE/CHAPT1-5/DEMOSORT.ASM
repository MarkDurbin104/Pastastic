;***********************************************************************
;
;  Program DemoSort ( Chapter 4 )
;
;  Array sorting: demo program
;
;  Author:  A.I.Sopin, Voronezh University. 1993
;
;***********************************************************************
        EXTRN   BSORT : FAR
        .MODEL  SMALL
        .STACK  100h
;----------------------------------------------------------
        .DATA
BELL    EQU     07      ;  sound signal
LF      EQU     10      ;  Line Feed
CR      EQU     13      ;  Carriage Return
TEXT0   DB      CR, LF, CR, LF, " String sorting: demo program."
        DB      "  Press any key to continue...", BELL, CR, LF, "$"
TEXT1   DB      CR, LF, " Outputting an original sequence: "
        DB      "  Press any key...", BELL, CR, LF, "$"
TEXT2   DB      CR, LF
ARRAY2  DB      "YYYYYYY EEEEEEE 1234567 ZZZZZZZ 0000000 QQQQQQQ "
        DB      "$"
TEXT3   DB      CR, LF, CR, LF,  " Increasing sequence. "
        DB      "  Press any key...", BELL, CR, LF, "$"
TEXT4   DB      CR, LF
ARRAY4  DB      "YYYYYYY EEEEEEE 1234567 ZZZZZZZ 0000000 QQQQQQQ ", "$"
TEXT5   DB      CR, LF, CR, LF,  " Decreasing sequence. "
        DB      "  Press any key...", BELL, CR, LF, "$"
ERTXT   DB      CR, LF, CR, LF,  " Sorting error.  "
        DB      "  Press any key...", BELL, CR, LF, "$"
VMODE   DB      0       ;  video mode saved
;----------------------------------------------------------
        .CODE
OutMsg  macro   Txt
        lea     dx,Txt                  ;  addres of message
        mov     ah,09h                  ;  function 09h - output text string
        int     21h                     ;  DOS  service call
        endm

WaitKey macro
        mov     ah,0                    ;  function 0 - wait for key pressed
        int     16h                     ;  BIOS keyboard service
   endm

;-------------------------------------------------------------------
.STARTUP
;  Output initial message
        OutMsg TEXT0                    ;  output initial message
        WaitKey
;
        OutMsg  TEXT1                   ;  output initial message
        OutMsg  TEXT2                   ;  output initial message
        WaitKey
;  Call subroutine BSORT - sorting array (increasing)
        mov     ax,0                    ;  AX = 0 for increasing sequence
        mov     cx,8                    ;  length of record
        mov     dx,6                    ;  number of records
        lea     si,ARRAY2               ;  DS:[SI] - address of array to be sorted
        Call    BSORT                   ;  perform sorting
        cmp     ax,0                    ;  normal return?
        jnz     ErSort                  ;  if not, output error message and exit
        OutMsg  TEXT3                   ;  output header
        OutMsg  ARRAY2                  ;  output array sorted
        WaitKey
;  Call subroutine BSORT - sorting array (decreasing)
        mov       ax,1                    ;  AX = 1 for decreasing sequence
        mov     cx,8                    ;  length of record
        mov     dx,6                    ;  number of records
        lea     si,ARRAY4               ;  DS:[SI] - address of array to be sorted
        Call    BSORT                   ;  perform sorting
        cmp     ax,0                    ;  normal return?
        jnz     ErSort                  ;  if not, output error message and exit
        OutMsg  TEXT5                   ;  output header
        OutMsg  ARRAY4                  ;  output array sorted
        WaitKey
;-------------------------------------------------------------------
;  Terminate program and exit to DOS
ExProgr:.exit          0
ErSort:      OutMsg    ERTXT
   .exit     1
        END
