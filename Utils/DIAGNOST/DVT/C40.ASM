       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           c40.asm

    Purpose:        Puts 3-in-1 card in 40 col CGA emulation and
                    informs PC-MOS kernel of the video change.

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

    $Log:   F:\BPO\DVT\VCS\C40.ASV  $
   
      Rev 1.1   14 Dec 1990 12:04:14   PJE
   Changed slashes to dashes.
   
      Rev 1.0   10 Dec 1990 13:21:48   PJE
   Initial revision.

***********************************************************************/
include	4080.inc		; macros and data definitions

code	segment	para	public	'code'
	assume	cs:code, ds:nothing, es:nothing, ss:nothing
	org	0100H
start	proc	near
	jmp	begin

; data list used to update the bios data area beginning at 40:49

BIOSdata label byte
	db	03h		; 40:49 - mode
	db	50h,00h		; 40:4a - columns
	db	00h,10h		; 40:4c - length
	db	00h,00h		; 40:4e - start
	db	00h,00h		; 40:50 - cursor pos
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	0bh,0ah		; 40:60 - cursor mode
	db	00h		; 40:62 - active page
	db	0d4h,03h	; 40:63 - crtc address
	db	28h		; 40:65 - mode
	db	00h		; 40:66 - palette
len_data        equ     $-BIOSdata

include ismos.inc		; function to test for pc-mos

;======================== MAIN CODE ========================

	assume	cs:code, ds:code, es:code, ss:code
begin:
        xout    03d8h,0                 ; disable cga video
        xout    03b8h,0                 ; disable mono video
	xout    03dfh,8			; unlock 3da
        xout    03bfh,8			; unlock 3ba
	xout    03dah,2			; set to color mode
        xout    03bah,2			; set to color mode
	mov	ax,40h
	mov	es,ax			; update equipment flags
	assume	es:bios
	and	byte ptr [bioequip],not 00110000b
	or	byte ptr [bioequip],00100000b
        mov     di,49h
        mov     si,offset BIOSdata	; update bios data area
        mov     cx,len_data
        rep     movsb
        xout    03d9h,0                 ; color select register
        xout    03ddh,0                 ; plantronic register
        xout    03d8h,28h               ; mode register
        xout    03dfh,0h                ; Lock port 3DAh
	call	ismos
	jz	notmos			; if running under mos
	mov	ah,4
	mov	bx,0			; get tcb segment
	int	0d4h
	assume	es:tcb
	mov	ax,40h
	mov	ds,ax
	assume	ds:bios
	mov	al,3			; update tcb vars from bios data
	mov	[biomode],al
	mov	[tcbmode],al
	mov	[tcbomode],al
	mov	[tcbcmode],al
	mov	ax,[biocrtc]
	mov	[dcaddr],ax
	mov	ax,0b800h
	mov	[dcpscr],ax
	mov	[tcbvidad],ax
	mov	[tcbstation],1		; 1 for cga
	mov	al,[bioequip]
	mov	[tcbequip],al
	and	[tcbvram],11101111b	; clear hercules bit
	or	[tcbvram],01100000b	; set graphics and color bits
notmos:
	mov	ax,0001h		; set to 40 x 25 cga
	int	10h
	mov	ax,4c00h
	int	21h

start	endp
code	ends
	end	start

