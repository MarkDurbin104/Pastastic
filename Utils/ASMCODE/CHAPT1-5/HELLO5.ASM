;
;       Program Hello5 ( Chapter 5 )
;
.TITLE     Hello                             ;    title is not necessary
.MODEL     SMALL                             ;    declare memory model
.CODE                                        ;    declare code segment
MAIN       PROC
	   MOV    AX,@Data                   ;    copy address of data
	   MOV    DS,AX                      ;    segment into DS
	   LEA    DX,Hello
	   CALL   Display_DX                 ;     call procedure
	   MOV    AH,4Ch                     ;     define DOS function to exit
	   MOV    AL,00h                     ;     with code zero
	   INT    21h                        ;     exit to DOS
	    ;----------------------------!
	    ;     Procedure section      !
	    ;----------------------------!
Display_DX PROC                              ;     declare procedure Display__DX
	   MOV    AH,09h                     ;     define DOS function number
	   INT    21h                        ;     call DOS function to display
					     ;     "Hello!"
	   RET                               ;     return to MAIN
Display_DX ENDP                              ;     end of procedure
	    ;----------------------------!
	    ;End of procedure section    !
	    ;----------------------------!
MAIN       ENDP             
.DATA                                        ;     declare data segment
 Hello     DB        'Hello!$'               ;     define string to display
					     ;
.STACK                                       ;     Declare stack segment
	   DB        128    DUP      (?)     ;     reserve 128 bytes for stack
					     ;
	   END       MAIN                    ;     end of program
