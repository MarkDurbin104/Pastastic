       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           ddi10.asm

    Purpose:        Device driver for 60Hz maintenance in
                    Monochrome or CGA emulation with 3-in-1
                    video card.  Hooks into Int 10h.

    Author:         Paul Encarnacion
                    Unisys, EISG, Postal Programs
                    5151 Camino Ruiz
                    Camarillo, CA 93010
                    (805)987-6811 

                    Made for Unisys by 
                    Martin Stitt, 
                    The Software Link, Inc.
                    09-26-90

    Date of Origin: 12-10-1990

    Copyright (c) 1990  Unisys Corporation

    $Log:   F:\BPO\DVT\VCS\DDI10.ASV  $
   
      Rev 1.1   14 Dec 1990 12:02:48   PJE
   Changed slashes to dashes.
   
      Rev 1.0   10 Dec 1990 13:20:10   PJE
   Initial revision.

***********************************************************************/
codeseg segment word public 'code'
        assume  cs:codeseg,ds:nothing,es:nothing,ss:nothing
	org     0H

        dd      -1
        dw      1000000000000000b       ; indicate a char device
        dw      strat
        dw      intr
        db      '_DDI10__'


hdr      dw     0,0		; request header
orig10   dd	0		; orig i10 vector to pass on to
v_orig10 dd	0		; orig i10 vector for vector table intercept
i_orig10 dd	0		; orig i10 vector for irq table intercept


strat:
        mov     cs:[hdr],bx
        mov     cs:[hdr+2],es
        retf

intr:
	push	ax
	push	bx
	push	cx
	push	dx
	push	si
	push	di
	push	bp
	push	ds
	push	es
	lds	bx,dword ptr [hdr]
	cmp	byte ptr [bx+2],0
	jne	not_init
        call    init
not_init:
	pop	es
	pop	ds
	pop	bp
	pop	di
	pop	si
	pop	dx
	pop	cx
	pop	bx
	pop	ax
	retf

; crtc list for cga 40 column mode - 60hz

c40_list label byte
	db	09h,0bh		; R9    - maximum scan line
	db	0ah,0ah		; R10   - cursor start
	db	0bh,0bh		; R11   - cursor end
c40_list_len	equ	($-c40_list)/2

; crtc list for mono 80 column mode - 60hz

m80_list label byte
	db	00h,5Fh		; R0    - horizontal total
	db	01h,50h		; R1    - horizontal displayed
	db	02h,51h		; R2    - horizontal sync position
	db	03h,05h		; R3    - horizontal sync pulse width
	db	04h,19h		; R4    - vertical total
	db	05h,04h		; R5    - vertical total adjust
	db	06h,19h		; R6    - vertical displayed      
	db	07h,19h		; R7    - vertical sync position 
	db	08h,00h		; R8    - interlace mode
	db	09h,0Bh		; R9    - maximum scan line
	db	0ah,04h		; R10   - cursor start
	db	0bh,0Ch		; R11   - cursor end
	db	0ch,00h		; R12   - n/a
	db	0dh,00h		; R13   - n/a
	db	0eh,00h		; R14   - n/a
	db	0fh,00h		; R15   - n/a
m80_list_len	equ	($-m80_list)/2


;======================================================================
; .func: list2crtc
;
; input:
;	si -> list
;	cx = number of list records
;	dx = starting port (3b4 for mono, 3d4 for cga)
;
; output:
;	si and cx crashed
;
; comments:
;
;======================================================================
list2crtc:
	push	ax
	push	ds
	mov	ax,cs
	mov	ds,ax
	cld
lcr1:
	lodsb
	out	dx,al
	jmp	$+2
	inc	dx
	lodsb
	out	dx,al
	jmp	$+2
	dec	dx
	loop	lcr1
	pop	ds
	pop	ax
	ret


;======================================================================
; .func: int10 
;
; input:
;	normal int10 entry values
;
; output:
;	normal int10 exit values
;
; comments:
;	actually there are two int10 entry points:
;	v_int10 for int10 vector interception
;	i_int10 for irq list interception (internal mos kenrel case)
;
;	for each case, the pass-on to the previous vector must be
;	done for that case.
;
;======================================================================
v_int10:
	cli
	push	ax
	mov	ax,word ptr cs:[v_orig10]	; setup for pass-on
	mov	word ptr cs:[orig10],ax		; for vector table case
	mov	ax,word ptr cs:[v_orig10+2]
	mov	word ptr cs:[orig10+2],ax
	pop	ax
	jmp	short i10common

i_int10:
	cli
	push	ax
	mov	ax,word ptr cs:[i_orig10]	; setup for pass-on
	mov	word ptr cs:[orig10],ax		; for irq list case
	mov	ax,word ptr cs:[i_orig10+2]
	mov	word ptr cs:[orig10+2],ax
	pop	ax

i10common:
	cmp	ax,0000h		; decide which functions
	je	is_c40			; to take special action on
	cmp	ax,0001h
	je	is_c40
	cmp	ax,0007h
	je	is_m80
	cmp	ah,1
	je	is_curtyp
	jmp	dword ptr cs:[orig10]

; 60hz compensation for modes 0 and 1

is_c40:
        pushf
        cli     			; call original int10 handler
        call    dword ptr cs:[orig10]
	pushf
	push	cx
	push	dx
	push	si
	push	ax
	mov	al,8 
	mov	dx,3dfh			; have to temporarily activate
	out	dx,al 			; color adapter and color monitor 
	jmp	$+2
	mov	al,0
	mov	dx,3dah 
	out	dx,al 
	mov	cx,c40_list_len
	mov	dx,03d4h
	mov	si,offset c40_list	; update the crtc for 60hz
	call	list2crtc
	mov	al,2 
	mov	dx,3dah 		; back to color adapter, mono monitor
	out	dx,al 
	jmp	$+2
	mov	al,0 
	mov	dx,3dfh 
	out	dx,al 
	pop	ax
	jmp	short ismodexx

; 60hz compensation for mode 7

is_m80:
        pushf
        cli     			; call original int10 handler
        call    dword ptr cs:[orig10]
	pushf
	push	cx
	push	dx
	push	si

	mov	cx,m80_list_len
	mov	dx,03b4h		; update the crtc for 60hz
	mov	si,offset m80_list
	call	list2crtc
ismodexx:
	pop	si
	pop	dx
	pop	cx
	popf
	retf	2

; cursor type compensation

is_curtyp:
	push	ax
	push	es
	mov	ax,40h			; when in video modes 0 and 1
	mov	es,ax			; the 60hz emulation truncates
	assume	es:nothing		; scan lines 6 and 7
	cmp	byte ptr es:[49h],1
	pop	es			; therefore, any cursor types
	pop	ax			; with values of 6 or 7 won't
	ja	ch_ok			; work properly unmodified
	cmp	cl,5
	jna	cl_ok
	mov	cl,5
cl_ok:
	cmp	ch,5
	jna	ch_ok
	mov	ch,5
ch_ok:
	jmp	dword ptr cs:[orig10]


endres  label   byte
	nop

initmsg   db	13,10,'DDI10.SYS device driver',13,10,'$'
badlp_msg db	13,10,'bad list',13,10,'$'
badmos    db	13,10,'Improper MOS version',13,10,'$'

include ismos.inc		; function to test for pc-mos

init:
        push    ax
        push    bx
	push	dx
        push    si
        push    ds
        push    es
        push    cs
        pop     ds


        mov	dx,offset initmsg	; put up load message
	mov	ah,9
	int	21h
	call	ismos
	jz	notmos
	mov	ax,3000h
	mov	bx,ax			; set ax == bx == cx == dx 
	mov	cx,ax			; to read the MOS version #
	mov	dx,ax
	int	21h
	cmp	ax,0a04h		; must be 4.10
	je	goodver
	mov	dx,offset badmos
	mov	ah,9
	int	21h
	xor	ax,ax
	jmp	done_init
goodver:
	mov	bx,202eh		; offset of irqstart - hard coded
	mov	ax,40h
	mov	es,ax
	assume	es:nothing
	mov	es,es:[3fah]		; fetch grp segment
toplp:
	cmp	word ptr es:[bx],10h*4
	je	endlp			; search for int10 entry
	cmp	word ptr es:[bx],0ffffh
	je	badlp
	add	bx,12
	jmp	short toplp
badlp:
	mov	dx,offset badlp_msg
	mov	ah,9
	int	21h
	xor	ax,ax
	jmp	done_init
endlp:
	mov	ax,es:[bx+2]
	mov	word ptr [i_orig10],ax	; intercept int10 within mos's 
	mov	ax,es:[bx+4]		; internal irq list
	mov	word ptr [i_orig10+2],ax
	mov	word ptr es:[bx+2],offset i_int10
	mov	es:[bx+4],cs
notmos:
	xor	ax,ax			; establish interrupt handler
	mov	es,ax
	assume	es:nothing
	cli
	mov	ax,es:[10h*4]
	mov	word ptr [v_orig10],ax
	mov	ax,es:[10h*4+2]
	mov	word ptr [v_orig10+2],ax
	mov	word ptr es:[10h*4],offset v_int10
	mov	es:[10h*4+2],cs
	sti
	mov	ax,offset endres
done_init:
        les     bx,dword ptr cs:[hdr]	; return from init
        mov     word ptr es:[bx+14],ax	; set ending address of driver
        mov     es:[bx+16],cs
        mov     word ptr es:[bx+3],10H	; Return with 'done'
        pop     es
        pop     ds
        pop     si
	pop	dx
        pop     bx
        pop     ax
        ret

codeseg  ends
        end

