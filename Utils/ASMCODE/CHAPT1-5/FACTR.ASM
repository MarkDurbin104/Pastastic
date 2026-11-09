.nolistmacro
Page 60,132
;
;                        Program   FACTR
;                        อออออออออออออออ
;                           Chapter 2
;
;                    Voronezh, 26 November  91
;                    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;          This  is  a  sample of an assembler program which
;          calculates the function called  n-factorial.   It
;          shows commands for organizing cycles and for data
;          examination.  To run the program enter the number
;          after  the  cursor  and then the separator symbol
;          (for example the factorial symbol "!").  To  exit
;          the program press the ENTER or ESC key instead of
;          the number.  You may meet commands  that  you  do
;          not   fully   uderstand   even   if  you  are  an
;          experienced user.  Don't worry about  them.   All
;          commands will be explained in later chapters.
;          will be explained in later chapters.
;
.model SMALL                    ; This defines memory model
        IF1                     ; On first pass
        include maclib.inc      ;   open macro library
        ENDIF                   ; End of macro including block
;
;อออออออออออออออ  C O D E   S E G M E N T   อออออออออออออออ
;
.code

Begin:                          ;
Next:                           ;
                                ;
        InpInt  cx              ; Input the number to compute
                                ;
        cmp     dl,0Dh          ; Check the ENTER key
        je      ExCycle           ; Exit if pressed
        cmp     dl,1Bh          ; Check the ESC key
        je      ExCycle           ; Exit if pressed
                                ;
        mov     ax,1            ; The initial value of factorial
        cmp     cx,1            ; Check the input value
        jl      Prtres          ; Skip the calculating if the
                                ;   number is less than 1
        mov     bx,0            ; Clear the work register
                                ;
Mult:                           ;
        mov     dx,0            ; Clear the high part of result
        inc     bx              ; Increase the work register
        mul     bx              ; The next result
        loop    Mult            ; Continue the cycle
                                ;
PrtRes:                         ;
                                ;
        OutInt  ax              ; Put result on screen
                                ;
        NewLine                 ; Move cursor to the next line
                                ;
        jmp     Next            ; Proceed next number
                                ;
ExCycle:                          ;= This label marks end of program
                                ;
        mov     ax,4C00h        ; AH register contains 4Ch code that is a
                                ;     DOS function number, AL register
                                ;     contains return code 00.
        int     21h             ; Dos service "Terminate program"
                                ;
.stack                          ; This line defines the STACK segment
        end     Begin

           This  is  a  sample of an assembler program which
           calculates the function called  n-factorial.   It
           shows commands for organizing cycles and for data
           examination.  To run the program enter the number
           after  the  cursor  and then the separator symbol
           (for example the factorial symbol "!").  To  exit
           the program press the ENTER or ESC key instead of
           the number.  You may meet commands  that  you  do
           not   fully   uderstand   even   if  you  are  an
           experienced user.  Don't worry about  them.   All
           commands will be explained in later chapters.






