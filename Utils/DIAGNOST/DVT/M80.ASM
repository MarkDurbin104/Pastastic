       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           m80.asm

    Purpose:        Puts 3-in-1 video card in monochrome mode,
                    and informs the PC-MOS kernel of the 
                    change in the video mode.

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

    $Log:   F:\BPO\DVT\VCS\M80.ASV  $
   
      Rev 1.1   14 Dec 1990 12:03:18   PJE
   Changes slashes to dashes.
   
      Rev 1.0   10 Dec 1990 13:23:16   PJE
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
	db	07h		; 40:49 - mode
	db	50h,00h		; 40:4a - columns
	db	00h,40h		; 40:4c - length
	db	00h,00h		; 40:4e - start
	db	00h,00h		; 40:50 - cursor pos
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	00h,00h
	db	0ch,0bh		; 40:60 - cursor mode
	db	00h		; 40:62 - active page
	db	0b4h,03h	; 40:63 - crtc address
	db	29h		; 40:65 - mode
	db	30h		; 40:66 - palette
len_data        equ     $-BIOSdata

include ismos.inc		; function to test for pc-mos

;======================== MAIN CODE ========================

	assume	cs:code, ds:code, es:code, ss:code
begin:
        xout    03d8h,0                 ; disable cga video
        xout    03b8h,0                 ; disable mono video
	xout    03dfh,8			; unlock 3da
        xout    03bfh,8			; unlock 3ba
	xout    03dah,3			; set to mono mode
        xout    03bah,3			; set to mono mode
	mov	ax,40h
	mov	es,ax			; update equipment flags
	assume	es:bios
	or	byte ptr [bioequip],00110000b
        mov     di,49h
        mov     si,offset BIOSdata	; update bios data area
        mov     cx,len_data
        rep     movsb
        xout    03d9h,0                 ; color select register
        xout    03ddh,0                 ; plantronic register
        xout    03b8h,29h               ; mode register
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
	mov	al,7			; update tcb vars from bios data
	mov	[biomode],al
	mov	[tcbmode],al
	mov	[tcbomode],al
	mov	[tcbcmode],al
	mov	ax,[biocrtc]
	mov	[dcaddr],ax
	mov	ax,0b000h
	mov	[dcpscr],ax
	mov	[tcbvidad],ax
	mov	[tcbstation],0		; 0 for mono
	mov	al,[bioequip]
	mov	[tcbequip],al
	and	[tcbvram],10011111b	; clear graphics and color bits
	or	[tcbvram],00010000b	; set hercules bit
notmos:
	mov	ax,0007h		; set to 80 x 25 mono
	int	10h
	mov	ax,4c00h
	int	21h

start	endp
code	ends
	end	start

