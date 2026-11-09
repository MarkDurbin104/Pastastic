;
;       Program Hello4 ( Chapter 3 )        
;        
	TITLE    Hello Example Program 3   ; title is not necessary
.model  tiny
.data
Hello   DB       'Hello!$'                 ; define string to display
.code
.startup
	LEA      DX,byte ptr Hello         ; DS:DX - effective address of string
	MOV      ah,09h                    ; function 09h - output text string
	INT      21h                       ; DOS service call
	MOV      ax,4C00h                  ; function 4Ch - terminate process
	INT      21h                       ; DOS service call
	END
