;
;       Program Hello2 ( Chapter 3 )
;
TITLE    Hello2 Example Program 2 ; title is not necessary
.MODEL   SMALL                    ; declare memory model
.CODE                             ; declare code segment
Start:   MOV     AX,@Data         ; copy address of data
         MOV     DS,AX            ; segment into DS
         LEA     DX,Hello
         MOV     AH,09h           ; define DOS function number
         INT     21h              ; call DOS function to display
         MOV     AH,4Ch           ; define DOS function to exit
         MOV     AL,00h           ; with code zero
         INT     21h              ; exit to DOS

.DATA                             ; declare data segment
 Hello   DB      'Hello!$'        ; define string to be displayed
.STACK                            ; declare stack segment
         END     Start
