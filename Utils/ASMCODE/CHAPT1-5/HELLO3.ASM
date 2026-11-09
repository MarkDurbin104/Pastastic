;
;       Program Hello3 ( Chapter 3 )
;      
TITLE    Hello Example Program 3   ; title is not necessary
OurProg SEGMENT  PARA  'CODE'              ; declare code segment
	ORG      100h                      ; 100h bytes for PSP 
	ASSUME   CS:OurProg, DS:OurProg,   ; information on program
		 ES:OurProg, SS:OurProg    ; structure
Start:  JMP      Begin                     ; jump over data definition
Hello   DB       'Hello!$'                 ; define string to display
Begin:  LEA      DX,byte ptr Hello         ; DS:DX - effective address of string
	MOV      ah,09h                    ; function 09h - output text string
	INT      21h                       ; DOS service call
	MOV      ax,4C00h                  ; function 4Ch - terminate process
	INT      21h                       ; DOS service call
OurProg ENDS                               ; end of program segment
	END       Start
