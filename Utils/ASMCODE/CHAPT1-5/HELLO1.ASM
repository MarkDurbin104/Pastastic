;        
;       Program Hello1 ( Chapter 3 )        
;        
        TITLE    Hello1 Example Program 1   ; title is not necessary
OurCode SEGMENT  PARA  PUBLIC  'CODE'      ; declare code segment
        ASSUME   CS:OurCode, DS:OurData, SS:OurStack 
Start:  MOV      AX,OurData                ; copy address of data
        MOV      DS,AX                     ; segment into DS
        LEA      DX,Hello                  ; address of message
        MOV      AH,09h                    ; DOS service "output text string"
        INT      21h                       ; DOS service call
        MOV      AH,4Ch                    ; DOS service "terminate process"
        MOV      AL,00h                    ; return code zero   
        INT      21h                       ; DOS service call
OurCode ENDS                               ; end of code segment

OurData SEGMENT  PARA PUBLIC 'DATA'        ; declare data segment
Hello   DB       'Hello!$'                 ; define string to display
OurData ENDS                               ; end of data segment

OurStack SEGMENT PARA STACK 'STACK'        ; declare stack segment
        DB       64 DUP (?)                ; reserve 64 bytes
OurStack ENDS                              ; end of stack segment

        END       Start                    ; end of program
