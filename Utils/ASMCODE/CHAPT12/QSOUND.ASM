;
;       Program QSound ( Chapter 12 )
;
	page    55,132
.model  medium,BASIC
;===    This generates the statement PROTO for MASM 6 or PUBLIC for others
	IFDEF ??VERSION
public  QSound  
	ELSEIF @version EQ 600
QSound  PROTO    BASIC freq: PTR WORD, durat: PTR WORD
	ELSE
public  QSound
	ENDIF   
;===    Data segments   
.data                   
Nticks  dw      0                       ; number of ticks for delaying
;===    Code segment
.code
QSound  PROC    BASIC uses ax bx cx dx es di, freq: PTR WORD,
		durat: PTR WORD
;===    accept the parameter DURAT (sound duration)
	mov     ax,5000                 ; default value for DURAT is 5 seconds
	mov     bx,durat                ; address of DURAT into ES:BX
	mov     bx,[bx]                 ; value of DURAT into BX register
	cmp     bx,0                    ; compare DURAT to 0
	je      Accept                  ; skip illegal value of DURAT
	cmp     ax,5000                 ; compare DURAT to 5000
	jg      Accept                  ; skip illegal value of DURAT
	mov     ax,bx                   ; load DURAT into AX
;===    convert DURAT value into timer ticks ( Tics = Msecs * 91 / 5000)
Accept: mov     Nticks,ax               ; save value of DURAT in memory
;===    modify the latch of the timer channel 0 (10 times faster)       
	mov     al,00110110b
	out     43h,al
	mov     ax,1193                 ; latch value - 1/10 of generator freq.
	out     40h,al                  ; send low byte of latch value
	mov     al,ah                   ; prepare for sending high byte 
	out     40h,al                  ; send high byte of latch value
;===    accept the parameter FREQ (sound frequency)
	mov     bx,freq                 ; address of frequency into ES:BX
	mov     di,[bx]                 ; value of frequency into DI
	cmp     di,0                    ; is zero frequency reqested?
	jg      Sound                   ; if not, generate sound
;===    zero frequency - disable sound  
	in      al,61h                  ; read speaker port content
	and     al, not 00000011b       ; set bits 0 and 1 of port 61h to 1     
	out     61h,al                  ; turn speaker off
	jmp     ToTicks                 ; wait for time defined by DURAT
;===    program channel 2 of Programmable Timer for sound generation    
Sound:  mov     al,10110110b            ; channel 2, write lsb/msb,
	out     43h,al                  ;   operation mode 3, binary
	mov     dx,12h                  ; store 12 34DCh (1 193 180) into
	mov     ax,34dch                ;    DX:AX for DIV command (divident)
	div     di                      ; obtain frequency divisor
	out     42h,al                  ; send low byte of divisor
	mov     al,ah                   ; prepare for sending high byte
	out     42h,al                  ; send high byte of divisor
;===    turn the sound on       
	in      al,61h                  ; read speaker port content
	or      al,00000011b            ; set bits 0 and 1 of port 61h to 1
	out     61h,al                  ; turn speaker on
;===    get current time (the number of ticks since midnight)
ToTicks:mov     ax,40h                  ; address of BIOS data segment into AX 
	mov     es,ax                   ; ES will point to BIOS data segment
;===    calculate the moment of turning the sound off           
	mov     bx,es:[6Ch]             ; low part of ticks number into BX
	add     bx,Nticks               ; add DURAT to that low part value
	mov     dx,es:[6Eh]             ; save high part of ticks number
;===    wait for the obtained number of ticks defined by the DURAT parameter    
Delay:  cmp     es:[6Eh],dx             ; has high part of time counter changed?
	jne     IsTime                  ; if so, suppose that time has gone
	cmp     es:[6Ch],bx             ; has time gone?        
	jb      Delay                   ; if not, continue to wait
;==     turn the speaker off    
IsTime: in      al,61h                  ; read speaker port contens
	and     al, not 00000011b       ; set bits 0 and 1 of port 61h to 1     
	out     61h,al                  ; turn speaker off
;===    restore the latch of the timer channel 0 (default value is 0FFFFh)
	mov     al,00110110b
	out     43h,al
	mov     al,0FFh                 ; this is low byte of value 65535
	out     40h,al                  ; send low byte of latch value (65535)
	out     40h,al                  ; send high byte of latch value (65535)
;===    return to caller                
	ret
QSound  endp
	end
