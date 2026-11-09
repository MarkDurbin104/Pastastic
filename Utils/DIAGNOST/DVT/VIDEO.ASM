       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           video.asm

    Purpose:        video support functions

    Author:         Paul Encarnacion
                    Unisys, EISG, Postal Programs
                    5151 Camino Ruiz
                    Camarillo, CA 93010
                    (805)987-6811 

    Date of Origin: 12-5-1990

    Copyright (c) 1990  Unisys Corporation

    $Log:   Z:\CM\F\BPO\DVT\VCS\VIDEO.ASV  $
   
      Rev 1.1   07 Jan 1991 13:41:10   AJW
   Many changes.
   
      Rev 1.0   10 Dec 1990 10:57:02   PJE
   Initial revision.

***********************************************************************/
;.MODEL LARGE


;======== macros

xout	macro	p1, p2
	mov	dx, p1
	mov	al, p2
	out	dx, al
	jmp	$+2
	endm


;======== addressability for bios data table

bios	segment at 0

	org	10h
bioequip db	?
       
	org     49h
biomode	db      ?

	org     63h
biocrtc	dw      ?

bios	ends


;======== addressability for mos's tcb

tcb	segment at 0

	org	34h
tcbmode	db	?

	org	51h
tcbomode db	?

	org	53h
tcbvram db	?

	org	124h
tcbcmode db	?

	org	(5d0h + 17h)
dcaddr	dw	?
dcpscr	dw	?

	org	76eh
tcbstation db	?

	org	770h
tcbvidad dw	?

	org	809h
tcbequip db	?

tcb	ends


VIDEO_TEXT      SEGMENT	WORD	PUBLIC	'CODE'
	        ASSUME	cs:VIDEO_TEXT, ds:nothing, es:nothing, ss:nothing

;- ISMOS ---------------------------------------------------------------
; entry parms:	none
; exit parms:	nz flag if the OS is MOS
;		zr flag if not
;
; NOTES: Verify that this program is running under the PC-MOS
; operating system before MOS specific system calls are made.
;-----------------------------------------------------------------------

ismos   proc    near

	push	ax
	push	bx
	push	cx
	push	dx
	mov	ax, 3000h
	mov	bx, ax		; set ax == bx == cx == dx 
	mov	cx, ax		; to read the MOS version #
	mov	dx, ax
	int	21h
	push	ax
	mov	ax, 3099h	; now insure ax is different 
	int	21h		; to read the DOS version #
	pop	bx
	cmp	bx, ax		; if bx != ax then MOS
	pop	dx		; if bx == ax then not
	pop	cx
	pop	bx
	pop	ax
	ret
ismos   endp

COMMENT /***************************************************************
*
*   Procedure:  _c40
*
*   Purpose:    sets magic combo card to cga 40 columns
*
*   Arguments:  none
*
*   Returns:    none
*
***********************************************************************/

        PUBLIC  _c40
_c40	PROC	far
	ASSUME	cs:VIDEO_TEXT, ds:VIDEO_TEXT, es:nothing

        push    bp
	mov     bp, sp
        push    ds
        push    es
	push	ax
	push	bx
	push	cx

	jmp	c40begin

; data list used to update the bios data area beginning at 40:49

c40data label byte
	db	03h		; 40:49 - mode
	db	50h,  00h	; 40:4a - columns
	db	00h,  10h	; 40:4c - length
	db	00h,  00h	; 40:4e - start
	db	00h,  00h	; 40:50 - cursor pos
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	0bh,  0ah	; 40:60 - cursor mode
	db	00h		; 40:62 - active page
	db	0d4h, 03h	; 40:63 - crtc address
	db	28h		; 40:65 - mode
	db	00h		; 40:66 - palette
len_c40data     equ     $-c40data


;======================== MAIN CODE ========================

c40begin:
        xout    03d8h, 0                ; disable cga video
        xout    03b8h, 0                ; disable mono video
	xout    03dfh, 8		; unlock 3da
        xout    03bfh, 8		; unlock 3ba
	xout    03dah, 2		; set to color mode
        xout    03bah, 2		; set to color mode
	mov	ax, cs
	mov	ds, ax
	mov	ax, 40h
	mov	es, ax			; update equipment flags
	ASSUME	es:bios
	and	es:byte ptr [bioequip], 11001111b
	or	es:byte ptr [bioequip], 00010000b
        cld
        mov     di, 49h
        mov     si, offset c40data	; update bios data area
        mov     cx, len_c40data
        rep     movsb
        xout    03d9h, 0                ; color select register
        xout    03ddh, 0                ; plantronic register
        xout    03d8h, 28h              ; mode register
        xout    03dfh, 0h               ; Lock port 3DAh
	call	ismos
	jz	c40notmos		; if running under mos
	mov	ah, 4
	mov	bx, 0ffffh		; get current tcb segment
	int	0d4h
	ASSUME	es:tcb
	mov	ax, 40h
	mov	ds, ax
	ASSUME	ds:bios
	mov	al, 3			; update tcb vars from bios data
	mov	ds:byte ptr[biomode], al
	mov	es:byte ptr[tcbmode], al
	mov	es:byte ptr[tcbomode], al
	mov	es:byte ptr[tcbcmode], al
	mov	ax, ds:word ptr[biocrtc]
	mov	es:word ptr[dcaddr], ax
	mov	ax, 0b800h
	mov	es:word ptr[dcpscr], ax
	mov	es:word ptr[tcbvidad], ax
	mov	es:byte ptr[tcbstation], 1	; 1 for cga
	mov	al, ds:byte ptr[bioequip]
	mov	es:byte ptr[tcbequip], al
	and	es:byte ptr[tcbvram], 11101111b	; clear hercules bit
	or	es:byte ptr[tcbvram], 01100000b	; set graphics and color bits

c40notmos:
        mov     cx, sp
	mov	ax, 0001h		; set to 40 x 25 cga
	int	10h

        mov     sp, cx
	pop	cx
	pop	bx
	pop	ax
        pop     es
        pop     ds
        pop     bp
        ret

_c40	ENDP


COMMENT /***************************************************************
*
*   Procedure:  _m80
*
*   Purpose:    sets margic combo card to monochrome
*
*   Arguments:  none
*
*   Returns:    none
*
***********************************************************************/

        PUBLIC  _m80
_m80	PROC	far
	ASSUME	cs:VIDEO_TEXT, ds:VIDEO_TEXT, es:nothing

        push    bp
        mov     bp, sp
        push    ds
        push    es
	push	ax
	push	bx
	push	cx

	jmp	m80begin

; data list used to update the bios data area beginning at 40:49

m80data label byte
	db	07h		; 40:49 - mode
	db	50h,  00h	; 40:4a - columns
	db	00h,  40h	; 40:4c - length
	db	00h,  00h	; 40:4e - start
	db	00h,  00h	; 40:50 - cursor pos
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	00h,  00h
	db	0ch,  0bh	; 40:60 - cursor mode
	db	00h		; 40:62 - active page
	db	0b4h, 03h	; 40:63 - crtc address
	db	29h		; 40:65 - mode
	db	30h		; 40:66 - palette
len_m80data     equ     $-m80data

;======================== MAIN CODE ========================

m80begin:
        xout    03d8h, 0                ; disable cga video
        xout    03b8h, 0                ; disable mono video
	xout    03dfh, 8		; unlock 3da
        xout    03bfh, 8		; unlock 3ba
	xout    03dah, 3		; set to mono mode
        xout    03bah, 3		; set to mono mode
	mov	ax, cs
	mov	ds, ax
	mov	ax, 40h
	mov	es, ax			; update equipment flags
	ASSUME	es:bios
	or	es:byte ptr [bioequip], 00110000b
        cld
        mov     di, 49h
        mov     si, offset m80data	; update bios data area
        mov     cx, len_m80data
        rep     movsb
        xout    03d9h, 0                ; color select register
        xout    03ddh, 0                ; plantronic register
        xout    03b8h, 29h              ; mode register
        xout    03dfh, 0h               ; Lock port 3DAh
	call	ismos
	jz	m80notmos    		; if running under mos
	mov	ah, 4
	mov	bx, 0ffffh		; get current tcb segment
	int	0d4h
	ASSUME	es:tcb
	mov	ax, 40h
	mov	ds, ax
	ASSUME	ds:bios
	mov	al, 7			; update tcb vars from bios data
	mov	ds:byte ptr[biomode], al
	mov	es:byte ptr[tcbmode], al
	mov	es:byte ptr[tcbomode], al
	mov	es:byte ptr[tcbcmode], al
	mov	ax, ds:word ptr[biocrtc]
	mov	es:word ptr[dcaddr], ax
	mov	ax, 0b000h
	mov	es:word ptr[dcpscr], ax
	mov	es:word ptr[tcbvidad], ax
	mov	es:byte ptr[tcbstation], 0	; 0 for mono
	mov	al, ds:byte ptr[bioequip]
	mov	es:byte ptr[tcbequip], al
	and	es:byte ptr[tcbvram], 10011111b	; clear graphics and color bits
	or	es:byte ptr[tcbvram], 00010000b	; set hercules bit
m80notmos:
        mov     cx, sp
        mov	ax, 0007h		; set to 80 x 25 mono
	int	10h

        mov     sp, cx
	pop	cx
	pop	bx
	pop	ax
        pop     es
        pop     ds
        pop     bp
        ret

_m80	ENDP

VIDEO_TEXT      ENDS

	END
