;
;       Program GetStr ( Chapter 7 )
;
	page    55,132
.model  small
.stack
.data
OutStr  db      0Dh,0Dh,'<<<=== The text read: ===>>>',0Dh,0Ah
StrBuf  db      32767 dup (?)           ; Buffer for string to be read
StrBufE label   byte
.code
.startup
IsOpen: mov     bx,ax                   ; Store handle code into BX
	mov     cx,StrBufE-StrBuf       ; Max number of symbols to be read
GetNext:mov     ah,3Fh                  ; Function 3Fh - Read File or Device
	lea     dx,StrBuf               ; DS:DX point to String Buffer
	int     21h                     ; DOS service call
	jnc     TstStr                  ; If NO CARRY - string is read
	mov     al,ah                   ; Set ErrorLevel to Read Error Code
	jmp     ExProg                  ; Exit the program
TstStr: cmp     ax,3                    ; Is there any characters apart CR,LF?
	jb      Compl                   ; If not, terminates the work
	mov     di,ax                   ; DI points at the end of text read
	mov     StrBuf[di],'$'          ; Append End Of Message for service 09h
	lea     dx,OutStr               ; DS:DX - address of text to be output
	mov     ah,09                   ; function 09h - output text string
	int     21h                     ; DOS service call
	jmp     GetNext                 ; Read next string
Compl:  mov     al,0                    ; Set ErrorLevel to 0
ExProg: mov     ah,4Ch                  ; Function 4Ch - terminate process
	int     21h                     ; DOS service call
	end
