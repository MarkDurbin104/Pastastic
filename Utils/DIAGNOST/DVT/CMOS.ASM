       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           cmos.asm

    Purpose:        CMOS support functions

    Author:         Paul Encarnacion
                    Unisys, EISG, Postal Programs
                    5151 Camino Ruiz
                    Camarillo, CA 93010
                    (805)987-6811 

    Date of Origin: 1-7-1991

    Copyright (c) 1990  Unisys Corporation

    $Log:   Z:\CM\F\BPO\DVT\VCS\CMOS.ASV  $
   
      Rev 1.0   07 Jan 1991 18:35:12   PJE
   Initial revision.

***********************************************************************/


                page
comment /*********************************************************************

	procedure:	_get_cmos

	purpose:	Read 1 byte from CMOS RAM
	
	exit:	[ah] = 0, [al] = CMOS data

*****************************************************************************/
code		segment	'code'
		assume	cs:code

		public	_get_cmos
		public	_put_cmos

CMOS_ARG	equ	[bp+6]		; Passed argument of data byte
CMOS_VAL	equ	[bp+8]		; Passed argument of value byte
CMOS_ADDR	equ	[70H]		; CMOS RAM address register
CMOS_DATA	equ	[71H]		; CMOS RAM data register

_get_cmos	proc	far
		push	bp		; Save registers
		mov	bp,sp
		push	dx

		cli			; Clear interrupt flag
		mov	dx,CMOS_ADDR	; Set LSH CMOS RAM address reg. = 70H
		mov	al,CMOS_ARG	; Get passed argument of CMOS RAM addr.
		out	dx,al		; Set pointer to CMOS RAM address
                jmp     $+2             ; port settle time
		inc	dx		; Set pointer to CMOS RAM data
		in	al,dx		; Read CMOS RAM data
                jmp     $+2             ; port settle time
		sti			; Set interrupt flag
		mov	ah,0		; Return [AH] = 0

		pop	dx		; Restore registers
		pop	bp
		ret

_get_cmos	endp

_put_cmos	proc	far
		push	bp		; Save registers
		mov	bp,sp
		push	dx

		cli			; Clear interrupt flag
		mov	dx,CMOS_ADDR	; Set LSH CMOS RAM address reg. = 70H
		mov	al,CMOS_ARG	; Get passed argument of CMOS RAM addr.
		out	dx,al		; Set pointer to CMOS RAM address
                jmp     $+2             ; port settle time
		inc	dx		; Set pointer to CMOS RAM data
		mov	al,CMOS_VAL	; Get passed argument of CMOS RAM addr.
		out	dx,al		; Set pointer to CMOS RAM address
                jmp     $+2             ; port settle time
		sti			; Set interrupt flag
		mov	ah,0		; Return [AH] = 0

		pop	dx		; Restore registers
		pop	bp
		ret

_put_cmos	endp

code		ends

		end
