
Page 60,132
;.sall
;
;                        Program   FIRST
;                        อออออออออออออออ
;                           Chapter 1
;
;                    Voronezh, 20 September 91
;                    ฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
;
;          This  is  a  sample  of  assembler  program.   It
;          represents a simplest calculator one can imagine.
;          This  calculator is designed so simple for better
;          understanding.  It can just only add two  numbers
;          and  result  can't  be greater than 255.  You can
;          use the executable module FIRST.EXE or  run  this
;          program  under  CodeView  debugger.  Probably you
;          can meet some  commands  which  seem  to  be  not
;          completely  clear  even if you are an experienced
;          user.  Don't worry about them.  All the  commands
;          will be explained in later chapters.
;
;
.model SMALL                    ; This defines memory model
;.xlist                          ; On first pass
	include maclib.inc      ;   open macro library
;.list
;
;อออออออออออออออ  C O D E   S E G M E N T   อออออออออออออออ
;
.code                           ; This starts the CODE segment
				;
Begin:                          ; This is the beginning
				;   of program instructions
				;
	mov     bx,0            ; Clear BX register
				;
	InpInt  bx              ; Input the first operand
				;
	mov     cx,bx           ; Save it in CX register
				;
	InpInt  bx              ; Input the second operand
				;
	add     bl,cl           ; Add operands. Note: it is
				;   a main command for this
				;      program.
				;
	OutInt  bx              ; Put result on screen
				;
Finish:                         ; This starts the block that
				;   ends the program
				;
	mov     ax,4C00h        ; AH contains the code 4Ch
				;   This is a DOS function
				;   number, AL register
				;   contains return code 00.
	int     21h             ; Dos service call

.data                           ; This starts the DATA segment
.stack                          ; This starts the STACK segment
				;
	end     Begin           ; This is the end of the
				;   program. The executing
				;   will start from the
				;   label "Begin".
