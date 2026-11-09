;**********************************************************************
;
;  Program DosCom ( Chapter 12 )
; 
;  Screen input/output interactive system for PC.  Version 1.4
;
;  Input MS DOS command processing
;
;  Author:  I.A.Sopin  Voronegh, 1991.
;
;  Specified in C program as
;
;   int near  DOSCOM (char near *Comand)
;
;  Parameter:
;
;  char near  *Comand  - ASCIIZ string containg the DOS command to be executed
;
;  Parameters are passed by reference thriogh the stack.
;
;
;
;
;**********************************************************************
	.MODEL  SMALL, C
	PUBLIC  DOSCOM
	.CODE

DOSCOM  PROC    NEAR C uses BX CX DX SI DI DS ES, AddrStr: word
;
;----------------------------------------------------------
;  Receive parameters from the PARM list:
	mov     si,AddrStr
;----------------------------------------------------------
;  Define the command length and pass its text contents
	xor     bx,bx                   ;  clear length counter
	mov     ax,cs                   ;
	mov     es,ax                   ;
	lea     di,COMAND+1             ;  output buffer address
	mov     cx,129                  ;  loop counter
M0:     lodsb                           ;
	and     al,al                   ;  end of MS DOS command text?
	jz      M1                      ;  execute the command
	stosb                           ;  move DS:SI ---> ES:DI
	inc     bx                      ;  process the next character; inc length counter
	loop    M0                      ;  goto the loop beginning
	mov     ax,-1                   ;  error code
	jmp     Exit                    ;  exit on error
;----------------------------------------------------------
;  MS DOS command execution (int 2Eh)
M1:     mov     byte ptr ES:[di],0dh    ;  move CR code to the output buffer
	mov     CS:COMAND,bl            ;  store the command length
	mov     CS:SSKEEP,SS            ;  save SS register
	mov     CS:SPKEEP,SP            ;  save SP register
	mov     ax,cs                   ;
	mov     ds,ax                   ;  file path string segment address
	lea     si,COMAND               ;  SI:= file path string offset
	int     2eh                     ;  command execution
	mov     SS,CS:SSKEEP            ;  restore SS contents
	mov     SP,CS:SPKEEP            ;  restore SP contents
	xor     ax,ax                   ;
;----------------------------------------------------------
;  Pop registers and exit
Exit:   RET
;----------------------------------------------------------
;  Data in the code segment
SSKEEP  DW      0                       ;  Stack segment contents
SPKEEP  DW      0                       ;  SP contents
COMAND  DB      0                       ;  the command length
	DB      128  dup (?)            ;  the command text
DOSCOM  ENDP
	END
