
page 55,132
;
;       PROGRAM DosVer ( Chapter 6 )
;
;       15 Jan 1992
;
;       This is a sample of DOS service usage.  This program
;       gets the Dos version number and sets the return code
;       equal  to  this  value.   You can use this result in
;       BAT-files with the help of ErrorLevel function.  You
;       can get either the major or minor part of the number.
;       To get the major part of the number, pass the letter
;       H to  the  program  as  a  parameter  by  typing the
;       following command line
;
;       DosVer H
;
;       The return code will be equal to the majnor part  of
;       the  number  of your DOS version (for example if you
;       are  using  MS-DOS  3.31  the  result  will  be  3).
;       Passing  the  parameter L to the program you can get
;       the  minor part  of  your DOS  version  number ( for
;       example if you are using MS-DOS 3.31 the result will
;       be 31).
;
.model  tiny               ; This is needed for COM- files
.code                      ; This starts the CODE segment
        org     100h       ; This is needed for COM- files
begin:  
        mov     bx,0       ; Clear the offset register
        mov     bl,byte ptr cs:80h      ; Read the parameters length
        mov     dl,byte ptr cs:[bx]+80h ; Read the last symbol
                                        ;    of parameter string
        and     dl,0DFh    ; UpCase the letter in DL
        mov     ah,30h     ; DOS service 30h - get the DOS version
        int     21h        ;    AH - minor part, AL - major part
        cmp     dl,'L'     ; Check if the minor part required
        jne     finish     ;   If not, leave the major part in AL
        mov     al,ah      ;   If yes, move the minor part into AL
Finish: mov     ah,4Ch     ; DOS service 4Ch - terminate program
        int     21h        ;    AL - the return code
        end     begin      ; The running starts from the label BEGIN
