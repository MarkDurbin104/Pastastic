       PAGE 79, 132
COMMENT /***************************************************************

    File:           4080.inc

    Purpose:        include file for use with M80.COM and C40.COM

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

    $Log:   F:\BPO\DVT\VCS\4080.INV  $
*  
*     Rev 1.1   14 Dec 1990 12:05:10   PJE
*  Fixed comment header problem.
*  
*     Rev 1.0   10 Dec 1990 13:24:28   PJE
*  Initial revision.

***********************************************************************/

;======== macros

xout	macro	p1, p2
	mov	dx,p1
	mov	al,p2
	out	dx,al
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


