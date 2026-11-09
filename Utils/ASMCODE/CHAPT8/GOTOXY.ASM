;
;       Program GotoXY ( Chapter 8 )
;
page    55,132
;       
;       cursor moving program   version 1.2   26.05.1992
;       copyright (C) V.B.Maljugin  1992  Voronezh,  Russia
;       
.model SMALL                    ; this defines memory model
.stack
.data                           ; this starts DATA segment
factor  dw      0               ;
ten     dw      10              ;
X       db      0               ; number of ROW on screen
Y       db      0               ; number of COLUMN on screen
.code                           ; this starts CODE segment
;===    block0 - start the program
.startup
;===    block 1 - prepare to work
        mov     cx,0            ; clear cycle counter
        mov     cl,es:80h       ; set counter to parameter string length
        inc     cl              ; CX points to first character
        mov     ax,es           ; we can't process ES content directly
        add     ax,8h           ; ES now points to parameter string
        mov     es,ax           ; set new ES content
        mov     bx,0            ; BX points to start of parameter string
;===    block 2 - read an X coordinate from parameter string
        call    SkipBlank       ; skip blank characters
        call    ReadNext        ; read next number
        mov     X,al            ; store ROW number (X)
;===    block 3 - read a Y coordinate from parameter string
        call    SkipBlank       ; skip blank characters
        call    ReadNext        ; read next number
        mov     Y,al            ; store COLUMN number (Y)
;===    block 4 - check whether coordinates are non-zero
        add     al,X            ; add X and Y coordinates
        cmp     al,0            ; sum X+Y is 0 when both X and Y are 0
        je      Finish          ; if X and Y are 0 - exit
;===    block 5 - move cursor into a new position                   
        mov     ax,40h          ; segment address of BIOS data area
        mov     es,ax           ; ES points to BIOS data area
        mov     bh,es:62h       ; [462] - active video page number
        mov     dh,X            ; DH - ROW on screen
        mov     dl,Y            ; DL - COLUMN on screen
        mov     ah,2            ; function 02h - move cursor
        int     10h             ; BIOS video service
;===    block 6 - exit program
Finish:                         ;
        mov     ax,4C00h        ; function 4Ch - terminate process
        int     21h             ; Dos service call
;
;       =============  work procedures  =================
;
SkipBlank       proc    near
;       this procedure scans parameter string and skips blank characters
;       
;       parameters on entry:
;       BX - offset of current character
;       DL - a first digit character (if any) or last character of the string
;
GetS:   inc     bx              ; BX will point to next character
        mov     dl,es:[bx]      ; get current character into DL
        cmp     cx,bx           ; is that end of parameter string?
        jl      AllParm         ; if so - process the accepted values
        cmp     dl,30h          ; current character less than 0?
        jl      GetS            ; if so - get next character
        cmp     dl,39h          ; current character greater than 9?
        ja      GetS            ; if so - get next character
AllParm:
        ret
SkipBlank       endp

ReadNext        proc    near
;
;       this procedure reads a parameter from command line
;       and transfers it to numeric form
;
;       parameters on entry:
;       DL - current character
;       BX - offset of current character from beginning of string
;       CX - maximum number of characters in string (length of string)
;       ES - segment address of parameter string in PSP ( Seg PSP + 8 )
;
;       result will be returned in AL 
;
        mov     ax,0
ProcSym:
        cmp     dl,30h          ; current character less than 0?
        jl      EndNext         ; if so - stop the process
        cmp     dl,39h          ; current character greater than 9?
        ja      EndNext         ; if so - stop process
        sub     dl,30h          ; transform character into 8-bit integer
        mov     Factor,dx       ; store that integer
        mul     ten             ; multiply AX by 10
        add     ax,Factor       ; add current character (as integer)
        mov     dx,0            ; prepare DX for processing next character
        inc     bx              ; increase character's counter
        mov     dl,es:[bx]      ; read next character into DL
        cmp     bx,cx           ; is that end of parameter string?
        jl      ProcSym         ; if not - process current character
EndNext:                        ;
         ret
ReadNext        endp
        end
