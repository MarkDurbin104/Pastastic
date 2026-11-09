;
;       Program CompStr ( Chapter 4 )
;
.model small
.stack
.data
StrBuf  db        80
ActLen  db        0
Str1    db        80 dup (' ')
Str2    byte      'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
.code
        include   maclib.inc
.startup
        push      ds
        pop       es
        NewLine
        Outmsg    'Enter alphabet characters: ABCD...  in capital letters:  '
        NewLine
        mov       ah,0Ah               ; function 0Ah - input string
        lea       dx,StrBuf            ; DS:DX - buffer address
        int       21h                  ; DOS service call
        .IF       ActLen < 1
        .exit     1
        .ENDIF
        lea       di,Str2              ; ES:DI point to string 2 (etalon)
        lea       si,Str1              ; DS:SI point to string 1 (enterd)
        mov       ch,0                 ; clear high byte of CX
        mov       cl,ActLen            ; CX contains actual length of string
        .IF       cx > LengthOf Str2
        mov       cx,LengthOf Str2
        .ENDIF
        NewLine
        OutMsg    'Entered text:   '
        OutBytes Str1,cx
        Newline
        OutMsg    'Compared with:  '
        OutBytes Str2,LengthOf Str2
        NewLine
        cld                            ; process strings from left to right
repe    cmpsb                          ; compare strings
        .IF ZERO?
                  OutMsg     'Right!'
        .ELSE
                  mov        al,ActLen
                  cbw
                  sub        ax,cx
                  OutMsg     'Character at position  '
                  OutInt     ax
                  OutMsg     ' is: "'
                  OutChar    [si-1]
                  OutMsg     '"; must be "'
                  OutChar    [di-1]
        .ENDIF
        Newline
.exit 0
        end
