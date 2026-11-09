;
;       Program Calcul ( Chapter 5 )
;
Page 55,132
.NoListMacro
.SALL
;                                                                  
;      This is a sample of assembler program.  It represents  an   
;      arithmetic   calculator   that  can  proceed  with 16-bit   
;      unsigned integers.  This supercalculator can  fulfil  the   
;      four  arithmetic actions:  the addition, the subtraction,   
;      the multiplication and the division.  Each number must be   
;      less  than  256 (including result).  You should enter the   
;      first operand, then sign "+"  (plus),  "-"  (minus),  "*"   
;      (asterisk)  or  "/"  (slash), then the second operand and   
;      finally sign "="  (equal).   The  result  will  be  shown   
;      immedditelly!                                               
;
.model SMALL                    ; This line defines memory model
	IF1                     ; On first pass
	include maclib.inc      ;   open macro library
	ENDIF                   ; End of macro including block
	
.data                           ; This line defines the DATA segment
fir     dw      0
sec     dw      0
res     dw      0

.stack

.code

Begin:  mov     ax,@data        ; Load segment address for Data segment
	mov     ds,ax           ;    into DX register

	NewLine
	OutStr  'Enter number, sign, number, equal sign'
	OutStr  'To exit press ESC or ENTER'
	NewLine
	OutStr  'Example: 1951+41='
	NewLine 2

Next:   mov     ax,0            ; Clear AX register
				;
	InpInt  fir             ; Input first operand into AX register
				;
	cmp     dl,0Dh
	jne     TstEsc
JmpFin: jmp     Finish
TstEsc: cmp     dl,1Bh
	je      JmpFin

	mov     cl,dl           ; Save last symbol accepted
				;
	InpInt  sec             ; Input second operand into AX register
				;
	mov     ax,fir          ; Load the first operand into
				;    accumulator
	mov     dx,0
				;
TesMin: cmp     cl,'-'          ; Check the subtraction operation
				; If last symbol you have entered
	jne     TesMul          ;    is minus subtract operands
	jmp     Minus
				;
TesMul: cmp     cl,'*'          ; Check the multiplication operation
				; If last symbol you have entered
	jne     TesDiv          ;    is asterisk multiply operands
	jmp     Mult
				;
TesDiv: cmp     cl,'/'          ; Check the divide operation
				; If last symbol you have entered
	jne     TesPl           ;    is slash divide operands
	jmp     Divide
				;
TesPl:  cmp     cl,'+'          ; Check the addition operation
				; If last symbol you have entered
	je      Plus            ;    is plus add operands
				;
Plus:   add     ax,Sec          ; add operands
	jmp     PrtRes          ; to result output
				;
Minus:  sub     ax,Sec          ; subtract operands
	jmp     PrtRes          ; to result output
				;
Mult:   mul     Sec             ; multiply operands
	jmp     Prtres          ; to result output
				;
Divide: div     Sec             ; divide operands
	jmp     PrtRes          ; to result output
				;
PrtRes: mov     res,ax
	OutInt  res             ; Put result on screen
	NewLine

	jmp     Next            ; process next input string
				;
Finish: mov     ax,4C00h        ; function 4Ch- terminate process, 0- exit code
	int     21h             ; DOS service call

	end     Begin
