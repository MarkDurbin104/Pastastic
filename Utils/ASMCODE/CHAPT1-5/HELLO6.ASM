;   
;       Program Hello6 ( Chapter 5 )
;
TITLE    Hello Procedure Example Program
.MODEL   SMALL
.CODE
MAIN     PROC
Start:   
	 CALL DISPLAY_Hi
	 MOV  AX,4C00h
	 INT  21h
;--------------------------
; Procedure section
;--------------------------
Display_Hi   PROC          ; procedure displays string at
			   ; the data segment named Hi
	     MOV AX,@data          
	     MOV DS,AX
	     MOV DX,OFFSET Hi
	     MOV AH,9   
	     INT 21h
	     RET
Display_Hi   ENDP
;---------------------------
;   End of procedure section
;---------------------------
Main    ENDP 
.DATA
Hi      DB   "Hello!$"
.STACK
	END  MAIN
