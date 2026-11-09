		PAGE    80, 132
		TITLE	RAMTEST.ASM
COMMENT /**************************************************************

	Title:		RAMTEST.ASM

	Purpose:	Test System RAM
                        This version of the RAM test is different 
                        from the tests used on the UTILITY disk
                        in the following respects:

                        1) All memory is tested, rather than exiting
                           once an error is found.

                        2) If error is found, test returns a bit map
                           showing the bit locations that are bad,
                           as well as an indication of whether a parity
                           error was encountered or not.

	Author:		David G. Lawrence
			Ventura Micro Support

	Revision:	$Log:   Z:\CM\F\BPO\DVT\VCS\RAMTEST.ASV  $
   
      Rev 1.0   10 Dec 1990 10:20:44   PJE
   Initial revision.
   
      Rev 1.4   01 Nov 1988 11:33:26   CM
   Copyright (c) 1988 Unisys Corp.
   
      Rev 1.3   24 Oct 1988 10:57:28   PJE
   
   - Added function _byte_cmp() previously from mem_chk.asm.  This is the
     function used by test_1024() to check the memory patterns.  It also 
     sets the chip array accordingly.
   - Moved parity error check to _byte_cmp().
   - Removed functions _clear_parity() and _check_parity().
   
      Rev 1.2   14 Oct 1988  8:58:40   PJE
   
   Changed to byte-wise compare rather than word-wise compare in order 
   to better support bit error location.  Also, _test64k changed to
   _test32k to be consistent with the extended memory test.
   
      Rev 1.1   07 Oct 1988 19:00:14   PJE
   
   1) Added functions clear_parity() and check_parity() which the extended
      memory test uses to avail of the NMI handler in this file.
   2) added support to return bit map indicating erroneous bytes.
   
      Rev 1.0   26 Jul 1988 17:17:32   EAS
   Initial release for IRT Phase 3

**********************************************************************/
	.LFCOND					; List FALSE conditionals

	IF1
		%OUT	*** Starting Pass One ***
	ELSE
		%OUT	*** Starting Pass Two ***
	ENDIF


FALSE		EQU	0
TRUE		EQU	NOT FALSE

PORT_B		EQU	061H			; Read/Write diagnostic register
PORT_C		EQU	062H			; 8255 Port C Address

NMI_INT		EQU	2			; Non-maskable interrupt

RAM_PARITY_ON	EQU	11001111B		; AND mask for parity check enable on
RAM_PARITY_OFF	EQU	00110000B		; OR mask for parity check enable off
IO_CHECK	EQU	01000000B		; I/O Memory Check
PARITY_CHECK	EQU	10000000B		; Memory Parity Check


DOS_FUNCTION	EQU	21H			; DOS Function request
SET_VECTOR	EQU	25H			; DOS Set interrupt vector
GET_VECTOR	EQU	35H			; DOS Get interrupt vector


STACK_FRAME	STRUC	 			; Caller's stack frame

ORIGINAL_BP	DW	?			; [BP] pushed on stack
CALLERS_IP	DW	?			; Caller's return [IP]
CALLERS_CS	DW	?			; Caller's return [CS]
RAM_SEGMENT	DW	?			; Segment to test
CHIP_MAP        DD      ?                       ; address of chip map

STACK_FRAME	ENDS


_TEXT		SEGMENT BYTE PUBLIC 'CODE'
_TEXT		ENDS

_DATA		SEGMENT WORD PUBLIC 'DATA'
_DATA		ENDS

CONST		SEGMENT WORD PUBLIC 'CONST'
CONST		ENDS

_BSS		SEGMENT WORD PUBLIC 'BSS'
_BSS		ENDS


DGROUP		GROUP	CONST, _BSS, _DATA
		ASSUME	CS:_TEXT, DS:DGROUP, ES:DGROUP, SS:DGROUP


COMMENT /*********************************************************************

	The following SEGMENT has been placed on a paragraph boundary to 
	insure that DO_PARA is placed on a paragraph boundary.  This
	is a requirement to avoid DO_PARA modifying itself during memory 
	testing.  _test32K avoids calling DO_PARA for the memory required 
	by DO_PARA

*****************************************************************************/

RAMTEST_TEXT	SEGMENT PARA PUBLIC 'CODE'
		PUBLIC _restore_nmi, _steal_nmi, _test32K

RAMTEST_START	=	$

ORG_NMI		LABEL	DWORD			; Original NMI vector
NMI_OFFSET	DW	?
NMI_SEGMENT	DW	?

PARITY_ERROR	DB	FALSE			; NMI occurred

BAD_BITS        DW      0                       ; bit map of errors
                                                ; high byte <- parity
                                                ; low byte  <- 8 bit mem

DO_PARA1_SEG	DW	?			; Location of test routine

PATTERN		DB	00000000B               ; bit patterns for byte cmp
		DB	11111111B
		DB	10000000B
		DB	01000000B
		DB	00100000B
		DB	00010000B
		DB	00001000B
		DB	00000100B
		DB	00000010B
		DB	00000001B

MAX_PATTERN	EQU	($ - OFFSET PATTERN)

bank            dw      ?                       ; bank number for current test

		PAGE
COMMENT /*********************************************************************

	Procedure:	NMI_HANDLER

	Purpose:	Handle parity interrupts during memory testing

	Entry:		No significant registers

	Exit:		All registers preserved

*****************************************************************************/

NMI_HANDLER	PROC	FAR
		ASSUME	CS:RAMTEST_TEXT, DS:NOTHING, ES:NOTHING

		PUSH	AX			; Save register

		IN 	AL, PORT_C
		JMP	$ + 2			; 80286 port settle time
		TEST	AL, PARITY_CHECK + IO_CHECK
		JZ	NMI_EXIT

		MOV	AL, 00000000B		; Disable NMI's
		OUT	0A0H, AL
		JMP	$ + 2			; 80286 port settle time

		IN	AL, PORT_B		; Toggle parity check enable bits
		JMP	$ + 2			; 80286 port settle time

		OR	AL, RAM_PARITY_OFF
		OUT	PORT_B, AL
		JMP	$ + 2			; 80286 port settle time

		AND	AL, RAM_PARITY_ON
		OUT	PORT_B, AL
		JMP	$ + 2			; 80286 port settle time

		MOV	AL, 10000000B		; Re-enable NMI's
		OUT	0A0H, AL

		MOV	PARITY_ERROR, TRUE	; Indicate parity error

                MOV     AX, 0100H               ; parity error bit
                OR      BAD_BITS, AX

NMI_EXIT:
		POP	AX			; Restore register

		IRET

NMI_HANDLER	ENDP


		PAGE
COMMENT /*********************************************************************

	Procedure:	_steal_nmi

	Purpose:	Install handler to detect parity errors

	Entry:		No significant registers

	Exit:		All registers preserved

*****************************************************************************/

_steal_nmi	PROC	FAR
		ASSUME	CS:RAMTEST_TEXT, DS:DGROUP, ES:NOTHING

		PUSH	AX	      		; Save registers
		PUSH	BX
		PUSH	DX

		PUSH	DS
		PUSH	ES

		MOV	AX, CS 			; SET [DS] TO [CS]
		MOV	DS, AX
	ASSUME	DS:RAMTEST_TEXT

		MOV	AH, GET_VECTOR		; Get original NMI vector
		MOV	AL, NMI_INT
		INT	DOS_FUNCTION
	ASSUME	ES:NOTHING

		MOV	NMI_SEGMENT, ES		; Save original vector
		MOV	NMI_OFFSET, BX

		MOV	AH, SET_VECTOR		; Install NMI handler
		MOV	AL, NMI_INT
		MOV	DX, OFFSET NMI_HANDLER
		INT	DOS_FUNCTION

		POP	ES			; Restore registers
		POP	DS
	ASSUME	DS:DGROUP, ES:NOTHING

		POP	DX
		POP	BX
		POP	AX

		RET

_steal_nmi	ENDP


		PAGE
COMMENT /*********************************************************************

	Procedure:	_restore_nmi

	Purpose:	Replace original NMI handler

	Entry:		No significant registers

	Exit:		All registers preserved

*****************************************************************************/

_restore_nmi	PROC	FAR
		ASSUME	CS:RAMTEST_TEXT, DS:DGROUP, ES:NOTHING

		PUSH	AX			; Save registers
		PUSH	DX

		PUSH	DS

		LDS	DX, ORG_NMI   		; Get original NMI vector
	ASSUME	DS:NOTHING

		MOV	AH, SET_VECTOR		; Restore original vector
		MOV	AL, NMI_INT
		INT	DOS_FUNCTION

		POP	DS			; Restore registers
	ASSUME	DS:RAMTEST_TEXT

		POP	DX
		POP	AX

		RET

_restore_nmi	ENDP

		PAGE
COMMENT /*********************************************************************

	The following ORG is used to insure that DO_PARA is placed on
	a paragraph boundary.  This is a requirement to avoid DO_PARA
	modifying itself during memory testing.  _test32K avoids calling
	DO_PARA for the memory required by DO_PARA

*****************************************************************************/

	IF	($ - OFFSET RAMTEST_START) MOD 16
		ORG	$ + (16 - (($ - OFFSET RAMTEST_START) MOD 16))
	ENDIF

COMMENT /*********************************************************************

	Procedure:	DO_PARA1

	Purpose:	Test memory

	Entry:		ES:[DI] = Memory to check

	Exit:		All registers preserved

*****************************************************************************/

DO_PARA1	PROC	NEAR
		ASSUME	CS:RAMTEST_TEXT, DS:RAMTEST_TEXT, ES:NOTHING

		PUSH	AX			; Save registers
		PUSH	BX
		PUSH	CX
		PUSH	DX

		PUSH	SI
		PUSH	DI

		MOV	DX, 16			; Do paragraph (16 bytes)
next_byte1:
		MOV	CX, MAX_PATTERN		; Get number of patterns
		MOV	SI, OFFSET PATTERN	; Point to pattern table
		MOV	DI, 0
		MOV	bl, byte ptr ES:[DI]	; Save byte to test
		CLI				; Disable ints while mem modified
NEXT_PATTERN1:
		LODSB				; Get pattern
		MOV	byte ptr ES:[DI], al	; Write pattern in AL
		MOV	ah, byte ptr ES:[DI]		; Read pattern back to AH
		CMP	al, ah			; Read same byte as written ?
		LOOPE	NEXT_PATTERN1		; Loop if CMP and patterns left

		MOV	byte ptr ES:[DI], bl	; Replace byte tested
		STI				; Interrupts OK now

		JE	MEM_OK1			; Yes, same byte, continue

                XOR     AL, AH                  ; map the bad bits to AL
                XOR     AH, AH                  ; zero out AH
                OR      BAD_BITS, AX            ; store the bad bit map 

                push    cx
                push    bx                      ; save regs to be used
                push    di
                
                mov     bx, es
                cmp     bx, 7fffh               ; if es > 32k
                ja      bank_2_3                ;    bank 2 or 3
bank_0_1:
                and     di, 1                   ;    if di is odd
                jz      bank_1                  ;       bank 0
bank_0:
                mov     bank, 0
                jmp     check_bits              
bank_1:
                mov     bank, 1                 ;    else
                jmp     check_bits              ;       bank 1
bank_2_3:
                and     di, 1                   ;    if di is odd
                jz      bank_3                  ;       bank 2
bank_2:
                mov     bank, 2
                jmp     check_bits              
bank_3:
                mov     bank, 3                 ;    else
                jmp     check_bits              ;       bank 3

check_bits:
                push    ds
                push    si
                lds     si, [bp.CHIP_MAP]       ; load the address of the map
                
                ; get the offset into the chip map
                push    ax
                mov     ax, 9                   ; 9 chips per bank
                mul     bank                    ; ax = bank * ax
                mov     bank, ax                ; bank = ax
                pop     ax

                add     si, bank                ; ds:[si] points to correct bank

                mov     bx, ax                  ; bx = ax (error bit map)
                mov     cx, 8
bit_loop:
                shr     bx, 1                   ; shift bx right, bit into CY
                jnc     next_bit
                mov     byte ptr ds:[si], 1     ; set the chip bad indicator
                
next_bit:       
                inc     si
                loop    bit_loop                ; if more bits, test next          

                cmp     PARITY_ERROR, TRUE      ; has a parity error occurred?
                jne     check_end
                mov     byte ptr ds:[si], 1     ; set parity chip error 
                mov     PARITY_ERROR, FALSE     ; reset parity flag
check_end:
                pop     si
                pop     ds

                pop     di
                pop     bx                
                pop     cx

MEM_OK1:
		DEC	DX			; Any bytes left to check ?
		JZ	PARA_EXIT1		; No, exit
                JMP     next_byte1
PARA_EXIT1:

		POP	DI			; Restore registers
		POP	SI

		POP	DX
		POP	CX
		POP	BX
		POP	AX

		RET

DO_PARA1	ENDP


		PAGE
COMMENT /*********************************************************************

	The following ORG is used to insure that DO_PARA2 is placed on
	a paragraph boundary.  This is a requirement to avoid DO_PARA2
	modifying itself during memory testing.  _test32K avoids calling
	DO_PARA2 for the memory required by DO_PARA2

*****************************************************************************/

	IF	($ - OFFSET RAMTEST_START) MOD 16
		ORG	$ + (16 - (($ - OFFSET RAMTEST_START) MOD 16))
	ENDIF

LEN_DO_PARA	=	($ - OFFSET DO_PARA1)  / 16


COMMENT /*********************************************************************

	Procedure:	DO_PARA2

	Purpose:	Test memory

	Entry:		ES:[DI] = Memory to check

	Exit:		All registers preserved

*****************************************************************************/

DO_PARA2	PROC	NEAR
		ASSUME	CS:RAMTEST_TEXT, DS:RAMTEST_TEXT, ES:NOTHING

		PUSH	AX			; Save registers
		PUSH	BX
		PUSH	CX
		PUSH	DX

		PUSH	SI
		PUSH	DI

		MOV	DX, 16			; Do paragraph (16 bytes)
next_byte2:
		MOV	CX, MAX_PATTERN		; Get number of patterns
		MOV	SI, OFFSET PATTERN	; Point to pattern table
		MOV	DI, 0
		MOV	bl, byte ptr ES:[DI]	; Save byte to test
		CLI				; Disable ints while mem modified
NEXT_PATTERN2:
		LODSB				; Get pattern
		MOV	byte ptr ES:[DI], al	; Write pattern in AL
		MOV	ah, byte ptr ES:[DI]	; Read pattern back to AH
		CMP	al, ah			; Read same byte as written ?
		LOOPE	NEXT_PATTERN2		; Loop if CMP and patterns left

		MOV	byte ptr ES:[DI], bl	; Replace byte tested
		STI				; Interrupts OK now

		JE	MEM_OK2			; Yes, same byte, continue

                XOR     AL, AH                  ; map the bad bits to AL
                XOR     AH, AH                  ; zero out AH
                OR      BAD_BITS, AX            ; store the bad bit map 

                push    cx
                push    bx                      ; save regs to be used
                push    di
                
                mov     bx, es
                cmp     bx, 7fffh               ; if es > 32k
                ja      bank_2_3b                ;    bank 2 or 3
bank_0_1b:
                and     di, 1                   ;    if di is odd
                jz      bank_1b                  ;       bank 0
bank_0b:
                mov     bank, 0
                jmp     check_bitsb              
bank_1b:
                mov     bank, 1                 ;    else
                jmp     check_bitsb              ;       bank 1
bank_2_3b:
                and     di, 1                   ;    if di is odd
                jz      bank_3b                  ;       bank 2
bank_2b:
                mov     bank, 2
                jmp     check_bitsb              
bank_3b:
                mov     bank, 3                 ;    else
                jmp     check_bitsb              ;       bank 3

check_bitsb:
                push    ds
                push    si
                lds     si, [bp.CHIP_MAP]       ; load the address of the map
                
                ; get the offset into the chip map
                push    ax
                mov     ax, 9                   ; 9 chips per bank
                mul     bank                    ; ax = bank * ax
                mov     bank, ax                ; bank = ax
                pop     ax

                add     si, bank                ; ds:[si] points to correct bank

                mov     bx, ax                  ; bx = ax (error bit map)
                mov     cx, 8
bit_loopb:
                shr     bx, 1                   ; shift bx right, bit into CY
                jnc     next_bitb
                mov     byte ptr ds:[si], 1     ; set the chip bad indicator
                
next_bitb:       
                inc     si
                loop    bit_loopb                ; if more bits, test next          

                cmp     PARITY_ERROR, TRUE      ; has a parity error occurred?
                jne     check_endb
                mov     byte ptr ds:[si], 1     ; set parity chip error 
                mov     PARITY_ERROR, FALSE
check_endb:
                pop     si
                pop     ds

                pop     di
                pop     bx                
                pop     cx

MEM_OK2:
		DEC	DX			; Any bytes left to check ?
		JZ	PARA_EXIT2		; No, exit
                JMP     next_byte2
PARA_EXIT2:
		POP	DI			; Restore registers
		POP	SI

		POP	DX
		POP	CX
		POP	BX
		POP	AX

		RET

DO_PARA2	ENDP

		PAGE
COMMENT /*********************************************************************

	Procedure:	_test32K

	Purpose:	Test 32K of system RAM

	Entry:		Absolute 32K RAM segment to test

	Exit:		
                        [AX] = Result
                           0 = No errors
                           
                        If errors found AX contains following bit map:

                               0 76543210 <- n
                        0000000P XXXXXXXX

                        P = 1 if parity error encountered
                          = 0 if no parity error

                        X = 1 if bit n was different from pattern bit
                          = 0 if no difference from compared pattern

	WARNING:	NMI handler should be replaced prior to memory
			 testing to avoid parity errors crashing system.
			Use _steal_nmi before and _restore_nmi after
			 testing memory.

	if ((test_seg < code_seg) && ((code_seg - test_seg) < 2048))
		DO_PARA is in  middle or end of test_seg 
	else if ((test_seg - code_seg) < 2048)
		DO_PARA is in beginning test_seg
	else
		DO_PARA is not in test_seg

*****************************************************************************/

_test32K	PROC	FAR
		ASSUME	CS:RAMTEST_TEXT, DS:DGROUP, ES:NOTHING, SS:NOTHING

		PUSH	BP			; Save original [BP]
		MOV	BP, SP			; Set pointer to stack frame

		PUSH	BX			; Save registers
		PUSH	CX
		PUSH	DX

		PUSH	SI
		PUSH	DI

		PUSH	DS
		PUSH	ES

		MOV	AX, CS			; Setup pointer to our data
		MOV	DS, AX
	ASSUME	DS:RAMTEST_TEXT

		MOV	PARITY_ERROR, FALSE	; Do initialization
                MOV     BAD_BITS, 0             ; reset bit map to no errors

		MOV	AX, CS			; Get location of DO_PARA
		MOV	BX, OFFSET DO_PARA1
		MOV	CL, 4
		SHR	BX, CL
		ADD	AX, BX

		MOV	DO_PARA1_SEG, AX	; Save location of DO_PARA1

		MOV	CX, 2048		; Number of paras in 32K

		MOV	AX, [BP.RAM_SEGMENT]	; Get segment to check
		MOV	ES, AX                  ; ES contains initial segment
                                                ; to test.
	ASSUME	ES:NOTHING

NEXT_PARA:
		CMP	DO_PARA1_SEG, AX	; Is test segment < do_para seg
		JA	DO_1			; Yes, use first routine

		SUB	AX, DO_PARA1_SEG	; Is it within LEN of test
		CMP	AX, LEN_DO_PARA
		JAE	DO_1			; No, use first routinue

		CALL	DO_PARA2		; Yes, use second routine
		JMP	SHORT NEXT_ES
DO_1:
		CALL	DO_PARA1
NEXT_ES:
		MOV	AX, ES			; Point to next segment to test
		INC	AX
		MOV	ES, AX
	ASSUME	ES:NOTHING

		LOOP	NEXT_PARA		; If any left, do another
                                                ; CX counts segments to test
                ; return resultant bit map of errors. If none, map = 0

                MOV     AX, BAD_BITS

TEST32K_EXIT:		
		POP	ES			; Restore registers
		POP	DS
	ASSUME	DS:DGROUP, ES:NOTHING

		POP	DI
		POP	SI

		POP	DX
		POP	CX
		POP	BX

		POP	BP		; Restore original [BP]

		RET

_test32K	ENDP

		PAGE
COMMENT /*********************************************************************

	Procedure:      byte_cmp  

	Purpose:        checks a block of memory for the integrity
                        of a specified bit pattern

	Entry:		No significant registers

	Exit:		All registers preserved

        Note:           called from C with the following synopsis:

                        int      byte_cmp ( ptr, pattern, byte_count);
                        char     *ptr;
                        char     pattern;
                        unsigned byte_count;

                        function returns an 8-bit bit map of the erroneous
                        bits in the tested byte.

                        if 0 => all compared ok 


*****************************************************************************/

                PUBLIC  _byte_cmp

_byte_cmp	PROC    FAR
                
                push    bp              ; save old bp
                mov     bp, sp          ; set stack framepointer

                push    es              ; save es
                push    di              ; save di

                les     di, [bp + 6]    ; load ptr to mem in es:di
                mov     ax, [bp + 10]   ; load the character to compare
                                        ; into AX (AL)
                
                mov     cx, [bp + 12]   ; compare number of bytes

                mov     BAD_BITS, 0     ; initialize the status word

cont_compare:

    repe        scasb                   ; compare bytes -- exit if diff

                cmp     cx, 0           ; see if all bytes passed
                jne     find_error      ; if not, find which bit was bad
                mov     ax, BAD_BITS    ; set return code
                                        
                jmp     exit_cmp

find_error:
                ; al contains proper pattern
                ; es:[di-1] contains byte with disagreeing pattern

                dec     di              ; point to the erroneous byte
                mov     ah, 0           ; zero out top byte
                xor     al, es:[di]     ; set differing bits
                or      BAD_BITS, ax    ; map bad bits into the status word     
                inc     di              ; restore byte pointer
                jmp     cont_compare    ; continue with the rest

exit_cmp:
                pop     di
                pop     es
                pop     bp

                ret
                
_byte_cmp	ENDP



RAMTEST_TEXT	ENDS

		END
