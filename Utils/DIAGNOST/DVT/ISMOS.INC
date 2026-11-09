       PAGE 79, 132
COMMENT /***************************************************************

    File:           ismos.inc

    Purpose:        include file to determine if OS is MOS

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

    $Log:   F:\BPO\DVT\VCS\ISMOS.INV  $
*  
*     Rev 1.1   14 Dec 1990 12:04:44   PJE
*  Fixed comment header problem.
*  
*     Rev 1.0   14 Dec 1990 11:56:06   PJE
*  Initial revision.

***********************************************************************/

;- ISMOS ---------------------------------------------------------------
; entry parms:	none
; exit parms:	nz flag if the OS is MOS
;		zr flag if not
;
; NOTES: Verify that this program is running under the PC-MOS
; operating system before MOS specific system calls are made.
;-----------------------------------------------------------------------
ismos:
	push	ax
	push	bx
	push	cx
	push	dx
	mov	ax,3000h
	mov	bx,ax		; set ax == bx == cx == dx 
	mov	cx,ax		; to read the MOS version #
	mov	dx,ax
	int	21h
	push	ax
	mov	ax,3099h	; now insure ax is different 
	int	21h		; to read the DOS version #
	pop	bx
	cmp	bx,ax		; if bx != ax then MOS
	pop	dx		; if bx == ax then not
	pop	cx
	pop	bx
	pop	ax
	ret

