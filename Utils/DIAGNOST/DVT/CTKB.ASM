       PAGE 60, 132
       TITLE 
COMMENT /***************************************************************

    File:           ctkb.asm

    Purpose:        Keyboard Driver for ECCO+ Counter Terminal Keyboard

    Author:         Paul Encarnacion
                    Unisys, EISG, Postal Programs
                    5151 Camino Ruiz
                    Camarillo, CA 93010
                    (805)987-6811 Ext.4154

    Date of Origin: 11-18-1990

    Copyright (c) 1990  Unisys Corporation

    $Log:   Z:\CM\F\BPO\DVT\VCS\CTKB.ASV  $
   
      Rev 1.1   07 Jan 1991  9:59:32   PJE
   
   Added MCR code - swipe card and read tracks.  Semi-functional now.
   Needs a bit more debugging.
   
   
      Rev 1.0   14 Dec 1990 11:15:36   PJE
   Additional code added to support buzzer and MCR.
   The MCR code is still not functional in this revision.
   
      Rev A.0   10 Dec 1990 10:59:42   PJE
   Initial revision.

***********************************************************************/
;
;       Macros
;

popff		macro				;; Use instead of POPF
		local	A, B
		jmp	B
A:              
		iret
B:
		push	cs
		call	A
		endm

BUFF_SIZE       EQU     128                     ; size of track buffer

;
;       Structures
;

REQ_HDR		STRUC				; Request Header
HDR_LENGTH	DB	?			; Length of request header and data
UNIT		DB	?			; Not used for printer
COMMAND		DB	?			; Command (Function)
STATUS		DW	?			; Status information
		DB	8 DUP (?)		; Reserved for DOS
REQ_HDR		ENDS

INIT_HDR	STRUC
		DB	(SIZE REQ_HDR) DUP (?)
UNIT_COUNT	DB	?			; Not used for printer
END_OFFSET	DW	?			; Ending address of resident code
END_SEGMENT	DW	?			
BPB_PTR		DD	?			; Not used for printer
DRIVE_LETTER	DB	?			; Not used for printer
INIT_HDR	ENDS


MEDIA_HDR	STRUC
		DB	(SIZE REQ_HDR) DUP (?)
MEDIA_BYTE	DB	?			; Not used for printer
RETURN		DB	?			; Not used for printer
VOLUME_ID	DD	?			; Not used for printer
MEDIA_HDR	ENDS


BUILD_BPB_HDR	STRUC
		DB	(SIZE REQ_HDR) DUP (?)
BUILD_MEDIA	DB	?			; Not used for printer
BUILD_XFR_ADR	DD	?			; Not used for printer
BPB_TABLE	DD	?			; Not used for printer
BUILD_BPB_HDR	ENDS


IO_HDR		STRUC
		DB	(SIZE REQ_HDR) DUP (?)
IO_MEDIA	DB	?			; Media descriptor byte
XFR_ADR		DD	?			; Transfer address(buffer address)
XFR_COUNT	DW	?			; Byte/Sector count
SECTOR		DW	?			; Not used for printer
OLD_VOLUME_ID	DD	?			; For DOS 3.00,3.10 and 3.20
IO_HDR		ENDS


INPUT_NW_HDR	STRUC
		DB	(SIZE REQ_HDR) DUP (?)
INPUT_BYTE	DB	?			; Not used for printer
INPUT_NW_HDR	ENDS

IOCTL_PKT       struc
IO_COMMAND      dw      ?               ; IOCTL command
IO_STATUS       dw      ?               ; command status
IO_BUFFER       db      128 DUP (?)     ; application buffer
IOCTL_PKT       ends


DEV_DONE        EQU     0100H                   ; done flag in status word
DEV_BUSY        EQU     0200H                   ; device is busy status code
DEV_ERROR       EQU     8000H                   ; error flag in status word

; -----	Device Driver Return Status Error Codes

WRITE_PROTECT	EQU	0			; Write protect violation
UNKNOWN_UNIT	EQU	1			; Unknown unit
DEV_NOT_READY   EQU     2			; Device not Ready
UNKNOWN_CMD     EQU     3			; Unknown command
CRC_ERROR	EQU	4			; CRC error
BAD_LENGTH	EQU	5			; Bad drive request structure length
SEEK_ERROR	EQU	6			; Seek error
UNKNOWN_MEDIA	EQU	7			; Unknown media
SECTOR_NOT_FND	EQU	8			; Sector not found
OUT_OF_PAPER    EQU     9			; Printer out of paper
WRITE_FAULT	EQU	10			; Write fault
READ_FAULT	EQU	11			; Read fault
GENERAL_FAILURE	EQU	12			; General failure
INVALID_DSK_CHG	EQU	15			; Invalid disk change

DOSINT          EQU     21h                     ; DOS services
MOSINT          EQU     0D4h                    ; PC-MOS Extended services

TRUE	        equ   1
FALSE	        equ   0

ACK_MASK        equ     10h                     ; Ack bit in kb_flag_2
RESEND_MASK     equ     20h                     ; Resend bit in kb_flag_2
KB_ERROR        equ     80h                     ; Keyboard transmit error

KB_DATA_PORT    equ     60h                     ; port for keyboard data
KB_CMDS_PORT    equ     64h                     ; port for keyboard commands
KB_STAT_PORT    equ     64h                     ; port for keyboard status

OUTPUT_FULL     equ     01h                     ; KB status, output buffer full
INPUT_FULL      equ     02h                     ; KB status, input buffer full

BREAK_CODE	equ	80h			; Signals a key to int9
BREAK_BIT	equ	07Fh
HANDSHAKE_ON	equ	80h			; Keyboard on
HANDSHAKE_OFF	equ	07Fh			; Keyboard off
UNDEF_KEY	equ	-1			; Value of undefined key in lookup table

SHIFT_KEY       equ     42                      ; left shift key
KEYPAD_00       equ     6A00h                   ; keycode of 00

; kb_flag bit masks

SHIFT_MASK      equ     02h                     ; set when left shift depressed

; kb_flag_1 bit masks

HOLD_STATE      equ     08h                     ; set when in pause state
SCROLL_SHIFT    equ     10h                     ; set when Scroll Lock key depressed
NUM_SHIFT       equ     20h                     ; set when the Num Lock key depressed
CAPS_SHIFT      equ     40h                     ; set when the Caps Lock key depressed
NULL_SHIFT	equ	00h			; Place holder for table

;       commands to the keyboard

BUZZER_CMD      equ     0F9h                    ; buzzer command
SWIPE_CMD       equ     0FBh                    ; swipe command
TRACK1_CMD      equ     0F0h                    ; read track 1 info
TRACK2_CMD      equ     0F1h                    ; read track 2 info
TRACK3_CMD      equ     0F2h                    ; read track 3 info
TYPE_CMD        equ     0F3h                    ; set typematic rate

;       responses from the keyboard

KB_OK           equ     0AAh                    ; Response from self-diagnostics
KB_ACK          equ     0FAh                    ; Keyboard ACK code
KB_NAK          equ     0F7h                    ; Keyboard NAK code
KB_RESEND       equ     0FEh                    ; Keyboard RESEND code
KB_OVER_RUN     equ     0FFh                    ; Over run scan code


; DEBUGGING

; -----	ASCII Equates

LF		EQU	10		; Ascii Line Feed char
CR		EQU	13		; Ascii Carriage Return	char
NULL            EQU     00h             ; End of copyright message string

; ----- DOS Functions

PRINT_STRING	EQU	9
DOS_INT		EQU	21H



; MACRO to display debugging statements

display         MACRO   msg
                local   skip
                local   msg_adr
                local   print_it

                push    ax
                push    cx
                push    dx
                push    bx

                pushf
                push    es
                push    ds

                push    cs
                pop     ds

                jmp     skip
msg_adr         db      msg, CR, LF, '$'

skip:
                cli
                mov     dx, offset cs:msg_adr

                ; Allow for printing $xxxx$ type strings

                cmp     byte ptr cs:msg_adr, '$'
                jne     print_it
                inc     dx                      ; skip over initial char
print_it:
                mov     ah, PRINT_STRING
                int     DOS_INT

                sti

                pop     ds
                pop     es
                popf
                pop     bx
                pop     dx 
                pop     cx
                pop     ax
                ENDM


; DEBUGGING


TCB	segment at 0
.XLIST
	include	mostcb.inc                      ; include file written by MOS
.LIST
TCB	ends

SCBX	segment at 0
.XLIST
	assume cs:SCBX
	include mosscbdf.inc                    ; include file written by MOS
.LIST
SCBX	ends

BIOS_DATA       SEGMENT AT 40h

                org     17h

kb_flags        db      (?)                     ; Contains current shift key status
kb_flags_1      db      (?)                     ; 2nd byte of keyboard shift status
alt_input       db      (?)                     ; Alt/Keypad values accumulated here
buffer_head     dw      (?)                     ; Kybd buffer head pointer
buffer_tail     dw      (?)                     ; Kybd buffer tail pointer
kb_buffer       dw      16 dup(?)               ; room for 16 entries

                org     71h

bios_break      db      (?)                     ; Set to 80h when break key hit
reset_flag      dw      (?)                     ; Set to 1234h if keyboard reset underway

                org     80h

buffer_start    dw      (?)                     ; set by BIOS to offset of kb_buffer
buffer_end      dw      (?)                     ; set by BIOS to offset of kb_buffer

                org     97h

kb_flag_2       db      (?)                     ; extra keyboard flags for AT

BIOS_DATA       ENDS



;****************************************************************************
;       
;   --- Device Driver Header ---  keyboard character device is $CT_KBD$
;
;****************************************************************************
code	segment	para
	assume	cs:code, ds:nothing, es:nothing, ss:nothing

        public  strategy
        public  interrupt

begin:
	dd	-1                      ; required -1
	dw	0C000h		        ; this is a character device, IOCTL supported
	dw	offset strategy 	; pointer to strategy routine
	dw	offset interrupt	; pointer to interrupt routine
	db	'$CT_KBD$'              ; Device Name

                PAGE		
;****************************************************************************
;       
;   Static Data Area --- Maintained within the code segment
;
;****************************************************************************

COMMENT /*********************************************************************

	Table:		DISPATCH_TBL

	Purpose:	dispatch based on command

	Note:		If function = -1, function not implemented

*****************************************************************************/

DISPATCH_TBL	DW      init         	        ;  0  init command
                DW      -1                      ;  1  media check
                DW      -1                      ;  2  build BPB
                DW      -1                      ;  3  IOCTL
                DW      -1                      ;  4  input
                DW      -1                      ;  5  non-destructive input
                DW      -1                      ;  6  input status
                DW      -1                      ;  7  input flush
                DW      -1        	       	;  8  output (write)
                DW      -1                	;  9  output with verify
                DW      -1            	   	; 10  output status
                DW      -1                	; 11  output flush
                DW      ioctl_output            ; 12  IOCTL output
                DW      do_nothing              ; 13  open
                DW      do_nothing              ; 14  close
                DW      -1                      ; 15  removable media

MAX_COMMAND	= ($ - OFFSET DISPATCH_TBL) / 2
        

REQUEST   	LABEL	DWORD			; Pointer to request header
REQ_HDR_OFFSET		DW      ?                     	
REQ_HDR_SEGMENT	DW	?

current_task    db      0       ; number of the current task 

mcr_buffer      db      (BUFF_SIZE) DUP (0)     ; buffer

                page
COMMENT |*********************************************************************

	Table:          SCANCODE Translation Table

	Purpose:        Used to Translate KEYCODE to MCR code

        Note:           When a code comes over the keyboard interface
                        from the MCR to the keyboard controller, it will
                        be translated to the IBM PC keycode.  This table
                        then converts it back to the original code.

                        This table was constructed from data in the IBM
                        AT Tech Ref, pp. 1-45,46 and from source code
                        for the KBDTEST program from Singular.

*****************************************************************************|
mcr_table       label   byte
                db      0feh,076h,016h,01eh,026h,025h,02eh,036h,03dh,03eh,046h,045h,04eh,055h,066h,00dh
                db      015h,01dh,024h,02dh,02ch,035h,03ch,043h,044h,04dh,054h,05bh,05ah,014h,01ch,01bh
                db      023h,02bh,034h,033h,03bh,042h,04bh,04ch,052h,00eh,012h,05dh,01ah,022h,021h,02ah
                db      032h,031h,03ah,041h,049h,04ah,059h,07ch,011h,029h,058h,005h,006h,004h,00ch,003h
                db      00bh,002h,00ah,001h,009h,077h,07eh,06ch,075h,07dh,07bh,06bh,073h,074h,079h,069h
                db      072h,07ah,070h,071h,07fh,060h,061h,078h,007h,00fh,017h,01fh,027h,02fh,037h,03fh
                db      047h,04fh,056h,05eh,008h,010h,018h,020h,028h,030h,038h,040h,048h,050h,057h,06fh
                db      013h,019h,039h,051h,053h,05ch,05fh,062h,063h,064h,065h,067h,068h,06ah,06dh,06eh
                db      080h,081h,082h,083h,084h,085h,086h,087h,088h,089h,08ah,08bh,08ch,08dh,08eh,08fh
                db      090h,091h,092h,093h,094h,095h,096h,097h,098h,099h,09ah,09bh,09ch,09dh,09eh,09fh
                db      0a0h,0a1h,0a2h,0a3h,0a4h,0a5h,0a6h,0a7h,0a8h,0a9h,0aah,0abh,0ach,0adh,0aeh,0afh
                db      0b0h,0b1h,0b2h,0b3h,0b4h,0b5h,0b6h,0b7h,0b8h,0b9h,0bah,0bbh,0bch,0bdh,0beh,0bfh
                db      0c0h,0c1h,0c2h,0c3h,0c4h,0c5h,0c6h,0c7h,0c8h,0c9h,0cah,0cbh,0cch,0cdh,0ceh,0cfh
                db      0d0h,0d1h,0d2h,0d3h,0d4h,0d5h,0d6h,0d7h,0d8h,0d9h,0dah,0dbh,0dch,0ddh,0deh,0dfh
                db      0e0h,0e1h,0e2h,0e3h,0e4h,0e5h,0e6h,0e7h,0e8h,0e9h,0eah,0ebh,0ech,0edh,0eeh,0efh
                db      0f0h,0f1h,0f2h,0f3h,0f4h,0f5h,0f6h,0f7h,0f8h,0f9h,0fah,0fbh,0fch,0fdh,0feh,000h
COMMENT |*********************************************************************

                End of  SCANCODE Translation Table

*****************************************************************************|

                page
COMMENT |*********************************************************************

	Table:          SCANCODE Lookup Tables

	Purpose:        Used to Translate SCANCODE to KEYCODE

	Note:           Contained in code segment so code is ROMABLE

	The 'make' scan codes transmitted from the keyboard are used as 
	indexes into these tables.   The tables are defined below in their 
	order of precedence, highest first.  A value of (-1) within a 
	lookup table means that the key has no direct translation and 
	should not be inserted into the keyboard buffer.

*****************************************************************************|
IFNDEF CODES
.XLIST
ENDIF
shift_table     label	word
                db        -1,   -1     ;  00
                db      000h, 05Dh     ;  01    Esc      /LOCK (shift F10)
                db       '1', 002h     ;  02    !/1      /1
                db       '2', 003h     ;  03    @/2      /2
                db       '3', 004h     ;  04    #/33     /3
                db       '4', 005h     ;  05    $/4      /4
                db       '5', 006h     ;  06    %/5      /5
                db       '6', 007h     ;  07    ^/6      /6
                db       '7', 008h     ;  08    &/7      /7
                db       '8', 009h     ;  09    */8      /8
                db       '9', 00Ah     ;  0A    (/9      /9
                db       '0', 00Bh     ;  0B    )/0      /0
                db       '-', 00Ch     ;  0C    _/-     -/MVL V10
                db       '=', 00Dh     ;  0D    +/=     =/DNS dep ord
                db      008h, 00Eh     ;  0E    BS       /DEL
                db       'ª', 00Fh     ;  0F    Tab     ª/BVP
                db       'Q', 010h     ;  10    Q       Q/Enqry
                db       'W', 011h     ;  11    W       W/Local 1
                db       'E', 012h     ;  12    E       E/blank
                db       'R', 013h     ;  13    R       R/blank
                db       'T', 014h     ;  14    T       T/Travel cheq
                db       'Y', 015h     ;  15    Y       Y/blank
                db       'U', 016h     ;  16    U       U/blank
                db       'I', 017h     ;  17    I       I/blank
                db       'O', 018h     ;  18    O       O/Other post
                db       'P', 019h     ;  19    P       P/Philatelic
                db       '[', 01Ah     ;  1A    {/[     [/blank
                db       ']', 01Bh     ;  1B    }/]     ]/BT stamp redm
                db      00Dh, 01Ch     ;  1C    Enter   =/ENTER
                db      000h, 06Ch     ;  1D    Ctrl     /RECPT
                db       'A', 01Eh     ;  1E    A       A/Local 2
                db       'S', 01Fh     ;  1F    S       S/Home help
                db       'D', 020h     ;  20    D       D/Other saving stamp
                db       'F', 021h     ;  21    F       F/TV saving stamp
                db       'G', 022h     ;  22    G       G/BT saving stamp
                db       'H', 023h     ;  23    h       H/blank
                db       'J', 024h     ;  24    J       J/Disc whole stamp
                db       'K', 025h     ;  25    K       K/Stamp book vend
                db       'L', 026h     ;  26    L       L/Stamp book other
                db       ';', 027h     ;  27    :/;     ;/TV stamp redm
                db       "'", 028h     ;  28    '       '/P&A other
                db       '`', 029h     ;  29    ~/`     `/BED
                db        -1,   -1     ;  2A    LtShft  SHIFT
                db       '\', 02Bh     ;  2B    |/\     \/BT recpt
                db       'Z', 02Ch     ;  2C    Z       Z/Local 3
                db       'X', 02Dh     ;  2D    X       X/NIS high
                db       'C', 02Eh     ;  2E    C       C/NIS other
                db       'V', 02Fh     ;  2F    V       V/TV licnce
                db       'B', 030h     ;  30    B       B/Phone card
                db       'N', 031h     ;  31    N       N/Postal order
                db       'M', 032h     ;  32    M       M/Post stamp
                db       ',', 033h     ;  33    </,     ,/2nd stamp
                db       '.', 034h     ;  34    >/.     ./1st stamp
                db       '/', 035h     ;  35    ?//     //DNS dep other
                db       '*', 036h     ;  36    RtShft  */blank
                db        -1,   -1     ;  37    PrtSc/*
                db      000h, 06Dh     ;  38    Alt      /CALC
                db       ' ', 039h     ;  39    SPACE    /SPACE
                db      000h, 03Ah     ;  3A    CapsLck  /blank
                db      000h, 06Eh     ;  3B    F1       /HELP
                db       '+', 03Ch     ;  3C    F2      +/MVL V11
                db      000h, 06Fh     ;  3D    F3       /CE/VOID
                db      000h, 070h     ;  3E    F4       /DISCOUNT
                db      000h, 071h     ;  3F    F5       /PLU
                db      000h, 072h     ;  40    F6      -/SAME CUST
                db      000h, 073h     ;  41    F7      +/END CUST
                db       '#', 042h     ;  42    F8      #/blank
                db       '@', 043h     ;  43    F9      @/Milk P&A 
                db      000h, 03Dh     ;  44    F10      /Milk Giro (F3)
                db      000h, 045h     ;  45    NumLck   /VOUCH
                db      000h, 046h     ;  46    Scroll   /GIRO TRANSFER
                db      000h, 047h     ;  47    home/7   /PART CHEQ
                db      000h, 049h     ;  48    Up/8    PAGE/Up
                db      000h, 069h     ;  49    PgUp/9   /PART CASH
                db      000h, 04Ah     ;  4A    pad -    /P&A 13
                db      000h, 00Fh     ;  4B    Left/4  TAB/Left
                db        -1,   -1     ;  4C    pad 5
                db      009h, 00Fh     ;  4D    Right/6 TAB/Right
                db      000h, 04Eh     ;  4E    pad +    /blank
                db      000h, 04Fh     ;  4F    End/1   x/CHEQ
                db      000h, 051h     ;  50    Down/2  PAGE/Down
                db      000h, 04Ch     ;  51    PgDn/3  ö/CASH
                db      000h, 06Ah     ;  52    Ins/0    /00
                db       'ù', 053h     ;  53    Del/ù    /ù (ascii 249)
                db       '{', 054h     ;  54            {/blank
                db       '}', 055h     ;  55            }/DNS wdl ord
                db       ':', 056h     ;  56            :/DNS wdl other
                db       '~', 057h     ;  57            ~/Other banks cheq
                db      0B3h, 058h     ;  58            ³/blank
                db       '|', 059h     ;  59            |/blank
                db       '<', 05Ah     ;  5A            </Other stamp redm
                db       '>', 05Bh     ;  5B            >/P&A 14
                db      000h, 05Ch     ;  5C             /Green Giro
                db      000h, 06Bh     ;  5D             /blank (used by LOCK)
                db       '!', 05Eh     ;  5E            !/Comm charg
                db       '"', 05Fh     ;  5F            "/Giro trans-cash
                db       'œ', 060h     ;  60            œ/Giro vouch
                db       '$', 061h     ;  61            $/Giro dep
                db       '^', 062h     ;  62            ^/Giro dep other
                db       '&', 063h     ;  63            &/blank
                db       '(', 064h     ;  64            (/Giro wdl
                db       ')', 065h     ;  65            )/Giro wdl other
                db       '_', 066h     ;  66            _/blank
                db       '?', 067h     ;  67            ?/P&A 5
                db       '%', 068h     ;  68            %/P&A 11
                db        -1,   -1     ;  69
                db        -1,   -1     ;  6A
                db        -1,   -1     ;  6B
                db        -1,   -1     ;  6C
                db        -1,   -1     ;  6D
                db        -1,   -1     ;  6E
                db        -1,   -1     ;  6F
                db        -1,   -1     ;  70
                db        -1,   -1     ;  71
                db        -1,   -1     ;  72
                db        -1,   -1     ;  73
                db        -1,   -1     ;  74
                db        -1,   -1     ;  75
                db        -1,   -1     ;  76
                db        -1,   -1     ;  77
                db        -1,   -1     ;  78
                db        -1,   -1     ;  79
                db        -1,   -1     ;  7A
                db        -1,   -1     ;  7B
                db        -1,   -1     ;  7C
                db        -1,   -1     ;  7D
                db        -1,   -1     ;  7E
                db        -1,   -1     ;  7F


normal_table    label	word
                db        -1,   -1     ;  00
                db      000h, 044h     ;  01    Esc      /EXIT (F10)
                db       '1', 002h     ;  02    !/1      /1
                db       '2', 003h     ;  03    @/2      /2
                db       '3', 004h     ;  04    #/33     /3
                db       '4', 005h     ;  05    $/4      /4
                db       '5', 006h     ;  06    %/5      /5
                db       '6', 007h     ;  07    ^/6      /6
                db       '7', 008h     ;  08    &/7      /7
                db       '8', 009h     ;  09    */8      /8
                db       '9', 00Ah     ;  0A    (/9      /9
                db       '0', 00Bh     ;  0B    )/0      /0
                db       '-', 00Ch     ;  0C    _/-     -/MVL V10
                db       '=', 00Dh     ;  0D    +/=     =/DNS dep ord
                db      008h, 00Eh     ;  0E    BS       /DEL
                db       'ª', 00Fh     ;  0F    Tab     ª/BVP
                db       'q', 010h     ;  10    Q       q/Enqry
                db       'w', 011h     ;  11    W       w/Local 1
                db       'e', 012h     ;  12    E       e/blank
                db       'r', 013h     ;  13    R       r/blank
                db       't', 014h     ;  14    T       t/Travel cheq
                db       'y', 015h     ;  15    Y       y/blank
                db       'u', 016h     ;  16    U       u/blank
                db       'i', 017h     ;  17    I       i/blank
                db       'o', 018h     ;  18    O       o/Other post
                db       'p', 019h     ;  19    P       p/Philatelic
                db       '[', 01Ah     ;  1A    {/[     [/blank
                db       ']', 01Bh     ;  1B    }/]     ]/BT stamp redm
                db      00Dh, 01Ch     ;  1C    Enter   =/ENTER
                db      000h, 01Dh     ;  1D    Ctrl     /RECPT
                db       'a', 01Eh     ;  1E    A       a/Local 2
                db       's', 01Fh     ;  1F    S       s/Home help
                db       'd', 020h     ;  20    D       d/Other saving stamp
                db       'f', 021h     ;  21    F       f/TV saving stamp
                db       'g', 022h     ;  22    G       g/BT saving stamp
                db       'h', 023h     ;  23    h       h/blank
                db       'j', 024h     ;  24    J       j/Disc whole stamp
                db       'k', 025h     ;  25    K       k/Stamp book vend
                db       'l', 026h     ;  26    L       l/Stamp book other
                db       ';', 027h     ;  27    :/;     ;/TV stamp redm
                db       "'", 028h     ;  28    '       '/P&A other
                db       '`', 029h     ;  29    ~/`     `/BED
                db        -1,   -1     ;  2A    LtShft  SHIFT
                db       '\', 02Bh     ;  2B    |/\     \/BT recpt
                db       'z', 02Ch     ;  2C    Z       z/Local 3
                db       'x', 02Dh     ;  2D    X       x/NIS high
                db       'c', 02Eh     ;  2E    C       c/NIS other
                db       'v', 02Fh     ;  2F    V       v/TV licnce
                db       'b', 030h     ;  30    B       b/Phone card
                db       'n', 031h     ;  31    N       n/Postal order
                db       'm', 032h     ;  32    M       m/Post stamp
                db       ',', 033h     ;  33    </,     ,/2nd stamp
                db       '.', 034h     ;  34    >/.     ./1st stamp
                db       '/', 035h     ;  35    ?//     //DNS dep other
                db       '*', 036h     ;  36    RtShft  */blank
                db        -1,   -1     ;  37    PrtSc/*
                db      000h, 038h     ;  38    Alt      /CALC
                db       ' ', 039h     ;  39    SPACE    /SPACE
                db      000h, 03Ah     ;  3A    CapsLck  /blank
                db      000h, 03Bh     ;  3B    F1       /HELP
                db       '+', 03Ch     ;  3C    F2      +/MVL V11
                db      01Bh, 001h     ;  3D    F3       /CE/VOID (Esc)
                db      000h, 03Eh     ;  3E    F4       /DISCOUNT
                db      000h, 03Fh     ;  3F    F5       /PLU
                db      000h, 072h     ;  40    F6      -/SAME CUST
                db      000h, 073h     ;  41    F7      +/END CUST
                db       '#', 042h     ;  42    F8      #/blank
                db       '@', 043h     ;  43    F9      @/Milk P&A 
                db      000h, 03Dh     ;  44    F10      /Milk Giro (F3)
                db      000h, 045h     ;  45    NumLck   /VOUCH
                db      000h, 046h     ;  46    Scroll   /GIRO TRANSFER
                db      000h, 047h     ;  47    home/7   /PART CHEQ
                db      000h, 048h     ;  48    Up/8    PAGE/Up
                db      000h, 069h     ;  49    PgUp/9   /PART CASH
                db      000h, 04Ah     ;  4A    pad -    /P&A 13
                db      000h, 04Bh     ;  4B    Left/4  TAB/Left
                db        -1,   -1     ;  4C    pad 5
                db      000h, 04Dh     ;  4D    Right/6 TAB/Right
                db      000h, 04Eh     ;  4E    pad +    /blank
                db      000h, 04Fh     ;  4F    End/1   x/CHEQ
                db      000h, 050h     ;  50    Down/2  PAGE/Down
                db      000h, 04Ch     ;  51    PgDn/3  ö/CASH
                db      000h, 06Ah     ;  52    Ins/0    /00
                db       'ù', 053h     ;  53    Del/.    /ù (ascii 249)
                db       '{', 054h     ;  54            {/blank
                db       '}', 055h     ;  55            }/DNS wdl ord
                db       ':', 056h     ;  56            :/DNS wdl other
                db       '~', 057h     ;  57            ~/Other banks cheq
                db      0B3h, 058h     ;  58            ³/blank
                db       '|', 059h     ;  59            |/blank
                db       '<', 05Ah     ;  5A            </Other stamp redm
                db       '>', 05Bh     ;  5B            >/P&A 14
                db      000h, 05Ch     ;  5C             /Green Giro
                db      000h, 06Bh     ;  5D             /blank (used by LOCK)
                db       '!', 05Eh     ;  5E            !/Comm charg
                db       '"', 05Fh     ;  5F            "/Giro trans-cash
                db       'œ', 060h     ;  60            œ/Giro vouch
                db       '$', 061h     ;  61            $/Giro dep
                db       '^', 062h     ;  62            ^/Giro dep other
                db       '&', 063h     ;  63            &/blank
                db       '(', 064h     ;  64            (/Giro wdl
                db       ')', 065h     ;  65            )/Giro wdl other
                db       '_', 066h     ;  66            _/blank
                db       '?', 067h     ;  67            ?/P&A 5
                db       '%', 068h     ;  68            %/P&A 11
                db        -1,   -1     ;  69
                db        -1,   -1     ;  6A
                db        -1,   -1     ;  6B
                db        -1,   -1     ;  6C
                db        -1,   -1     ;  6D
                db        -1,   -1     ;  6E
                db        -1,   -1     ;  6F
                db        -1,   -1     ;  70
                db        -1,   -1     ;  71
                db        -1,   -1     ;  72
                db        -1,   -1     ;  73
                db        -1,   -1     ;  74
                db        -1,   -1     ;  75
                db        -1,   -1     ;  76
                db        -1,   -1     ;  77
                db        -1,   -1     ;  78
                db        -1,   -1     ;  79
                db        -1,   -1     ;  7A
                db        -1,   -1     ;  7B
                db        -1,   -1     ;  7C
                db        -1,   -1     ;  7D
                db        -1,   -1     ;  7E
                db        -1,   -1     ;  7F
IFNDEF CODES
.LIST
ENDIF
                PAGE
COMMENT /*********************************************************************

	Procedure:	STRATEGY

	Purpose:	Store pointer to request header

	Entry:		[ES]:[BX] = Pointer to request header

	Exit:		All registers preserved

*****************************************************************************/

STRATEGY	PROC	FAR
		ASSUME	CS:CODE, DS:NOTHING, ES:NOTHING

                MOV     REQ_HDR_OFFSET, BX	; Save offset
                MOV	REQ_HDR_SEGMENT, ES	; Save segment

                RET

STRATEGY	ENDP

		PAGE
COMMENT /*********************************************************************

	Procedure:	INTERRUPT

	Purpose:	Perform command in request header stored by STRATEGY

	Entry:		No significant registers

	Exit:		Status word in request header set appropriately

*****************************************************************************/

INTERRUPT	PROC	FAR
		ASSUME	CS:CODE, DS:NOTHING, ES:NOTHING 

		PUSHF
                PUSH    AX			; Save the state of the machine
                PUSH    BX
		PUSH	CX 
		PUSH	DX
                PUSH    SI
                PUSH    DI
                PUSH    DS
                PUSH    ES
                CLD

		MOV	AX, CS		       	; Set [DS] to CODE segment
		MOV	DS, AX
	ASSUME	DS:CODE

                LES     DI, REQUEST		; Get ptr to request header
	ASSUME	ES:NOTHING

		MOV	AX, UNKNOWN_CMD		; Default to bad command
		XOR	BH, BH			; Prep for table index
		MOV	BL, ES:[DI].COMMAND	; Get command
		CMP	BL, MAX_COMMAND	        ; Is this a legal function ?
		JA	INTERRUPT_EXIT		; No, exit now

		SHL	BX, 1			; Convert to index for word-wide table
		MOV	BX, DISPATCH_TBL[BX]	; Get address from DISPATCH Table
		CMP	BX, -1			; Is this function implemented ?
		JE	INTERRUPT_EXIT		; No, exit now

		CALL	BX			; Yes, go do function
INTERRUPT_EXIT:
                ; result of call is in AX

                LES	DI, REQUEST		; Get ptr to request header
	ASSUME	ES:NOTHING

                MOV     ES:[DI].STATUS, AX	; Set status

		POP	ES			; Restore registers
		POP	DS
	ASSUME	DS:NOTHING, ES:NOTHING

		POP	DI
		POP	SI
		POP	DX
		POP	CX
		POP	BX
		POP	AX
		popff
		RET
INTERRUPT	ENDP

COMMENT /***************************************************************
*
*   Procedure:  ismos
*
*   Purpose:    determines if the operating system is PC-MOS
*
*   Arguments:  none
*
*   Returns:    Z flag set if MOS, NZ if not MOS
*
***********************************************************************/
ismos   proc    near
	push	ax
	push	bx
	push	cx
	push	dx
	mov	ax,3000h
	mov	bx,ax		; set ax == bx == cx == dx 
	mov	cx,ax		; to read the MOS version #
	mov	dx,ax
	int	DOSINT
	push	ax
	mov	ax,3099h	; now insure ax is different 
	int	DOSINT		; to read the DOS version #
	pop	bx
	cmp	bx,ax		; if bx != ax then MOS
	pop	dx		; if bx == ax then not
	pop	cx
	pop	bx
	pop	ax
	ret
ismos   endp

COMMENT /***************************************************************
*
*   Procedure:  do_nothing
*
*   Purpose:    simply complete command
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
do_nothing      proc    near
                assume cs:CODE, ds:nothing, es:nothing

                mov     AX, DEV_DONE
                ret

do_nothing      endp

		PAGE
COMMENT /*********************************************************************

	Table:		IOCTL_TBL

	Purpose:	Dispatch IOCTL functions

*****************************************************************************/

IOCTL_TBL	DW     sound_buzzer    ; 0  
                DW     -1 ; set_typematic   ; 1
                DW     swipe_card      ; 2
                DW     read_track_1    ; 3
                DW     read_track_2    ; 4
                DW     read_track_3    ; 5

MAX_IOCTL_CMD	= ($ - OFFSET IOCTL_TBL) / 2

COMMENT /*********************************************************************

	Procedure:	ioctl_output

	Purpose:	Send device control packet to device

	Entry:		[ES]:[DI] = Ptr to request header
			REQ_HDR.

	Exit:		[AX] = Status

			

*****************************************************************************/
ioctl_output    PROC	NEAR
		ASSUME	CS:CODE, DS:CODE, ES:NOTHING

		PUSH	DS

		LDS	SI, ES:[DI].XFR_ADR	; Point to control string
	ASSUME	DS:NOTHING

		LODSW				; Get printer command
		POP	DS
	ASSUME	DS:CODE

		MOV	BX, AX
		CMP	BX, MAX_IOCTL_CMD	; Legal command ?
		MOV	AX, UNKNOWN_CMD		; Default to No
		JA	ioctl_exit   	        ; No, exit now

		SHL	BX, 1			; Index into word-wide table
		MOV	BX, IOCTL_TBL[BX]	; Get address of proper routine

		CALL	BX			; Yes, do function

ioctl_exit:
		RET

ioctl_output    ENDP

COMMENT /***************************************************************
*
*   Procedure:  flush_keyboard
*
*   Purpose:    flushes keyboard interface of any pending keys
*
*   Arguments:  
*
*   Returns:    
*
***********************************************************************/
flush_keyboard  proc     near
                assume  cs:CODE, ds:nothing, es:nothing

                push    ax
fk_00:
                in      al, KB_STAT_PORT
                test    al, OUTPUT_FULL         ; check output buffer
                jz      fk_01                   ; if none, go on
                in      al, KB_DATA_PORT
                jmp     fk_00

fk_01:                
                pop     ax
                ret

flush_keyboard  endp

;****************************************************************************
;
;       Function:  swipe_card 
;
;       Purpose:   send keyboard command to wait for card swipe
;
;       Entry:     none
;
;       Exit:      none
;
;****************************************************************************
swipe_card      proc near
                assume cs:code, ds:nothing, es:nothing

                cli                     ; disable interrupts while in MCR mode

                call    flush_keyboard  ; make sure no garbage

                mov     al, SWIPE_CMD   ; send card swipe command
                mov     ah, KB_DATA_PORT
                call    raw_send_kb

                ; get initial response back first
                ; don't care what it is - must be an ACK

                call    raw_read_kb

                ; wait for swipe or key
                call    raw_read_kb

                sti                             ; restore interrupts

		lds	si, es:[di].XFR_ADR	; Point to control string
                assume  ds:nothing

                cmp     al, KB_ACK
                je      swipe_was_good

                mov     ds:[si].IO_STATUS, 0    ; swipe not good
                jmp     short swipe_stat

swipe_was_good:
                mov     ds:[si].IO_STATUS, 1    ; swipe was ok

swipe_stat:
                mov     ax, DEV_DONE
                ret

swipe_card      endp

;****************************************************************************
;
;       Function:  sound_buzzer
;
;       Purpose:   send keyboard command to sound the buzzer
;
;       Entry:     none
;
;       Exit:      AX <- status
;
;****************************************************************************
sound_buzzer    proc near
                assume cs:code, ds:nothing, es:nothing

                mov     al, BUZZER_CMD  ; send buzzer command
                mov     ah, KB_DATA_PORT
                call    send_keyboard
                mov     ax, DEV_DONE
                ret

sound_buzzer    endp

IF 0
COMMENT /***************************************************************
*
*   Procedure:  enable_xlate
*
*   Purpose:    enables scancode translation
*
*   Arguments:  
*
*   Returns:    CY set on error, clear if ok
*
***********************************************************************/
enable_xlate    proc    near
                assume  cs:code, ds:nothing, es:nothing

                push    ax

                mov     ah, KB_CMDS_PORT        ; keyboard command
                mov     al, 60h                 ; write contlr cmd byte
                call    send_keyboard
                jc      enable_error

                mov     ah, KB_DATA_PORT        ; set ctrlr data
                mov     al, 41h                 ; enable translation
                call    send_keyboard
                jc      enable_error

                clc
                jmp     short enable_exit

enable_error:
                stc
enable_exit:
                ret

enable_xlate    endp

COMMENT /***************************************************************
*
*   Procedure:  disable_xlate
*
*   Purpose:    disables scancode translation
*
*   Arguments:  
*
*   Returns:    CY set on error, clear if ok
*
***********************************************************************/
disable_xlate    proc    near
                assume  cs:code, ds:nothing, es:nothing

                push    ax

                mov     ah, KB_CMDS_PORT        ; keyboard command
                mov     al, 60h                 ; write contlr cmd byte
                call    send_keyboard
                jc      disable_error

                mov     ah, KB_DATA_PORT        ; set ctrlr data
                mov     al, DOSINT              ; disable translation
                call    send_keyboard
                jc      disable_error

                clc
                jmp     short disable_exit

disable_error:
                stc
disable_exit:
                ret

disable_xlate    endp
ENDIF

;****************************************************************************
;
;       Function:  read_track_1
;
;       Purpose:   send keyboard command to read an MCR track buffer
;
;       Entry:     none
;
;       Exit:      none
;
;****************************************************************************
read_track_1    proc near
                assume cs:code, ds:nothing, es:nothing
        
                mov     al, TRACK1_CMD
                call    read_track
                ret

read_track_1    endp

;****************************************************************************
;
;       Function:  read_track_2
;
;       Purpose:   send keyboard command to read an MCR track buffer
;
;       Entry:     none
;
;       Exit:      none
;
;****************************************************************************
read_track_2    proc near
                assume cs:code, ds:nothing, es:nothing
        
                mov     al, TRACK2_CMD
                call    read_track
                ret

read_track_2    endp

;****************************************************************************
;
;       Function:  read_track_3
;
;       Purpose:   send keyboard command to read an MCR track buffer
;
;       Entry:     none
;
;       Exit:      none
;
;****************************************************************************
read_track_3    proc near
                assume cs:code, ds:nothing, es:nothing
        
                mov     al, TRACK3_CMD
                call    read_track
                ret

read_track_3    endp

;****************************************************************************
;
;       Function:  read_track
;
;       Purpose:   send keyboard command to read an MCR track buffer
;
;       Entry:     AL <- command for read track no.
;
;       Exit:      AX <- status
;
;****************************************************************************
read_track      proc near
                assume cs:code, ds:nothing, es:nothing

                cli                             ; disable interrupts
                push    ax                      ; save command in AL

                call    flush_keyboard          ; test
read_00:
                in      al, KB_STAT_PORT        ; get status
                test    al, INPUT_FULL          ; check input buffer full
                jnz     read_00                 ; wait till empty

                pop     ax
                mov     ah, KB_DATA_PORT        ; command already in AL
                call    raw_send_kb             ; send the command
                call    raw_read_kb             ; read the response back
                cmp     al, KB_ACK              ; starting ACK expected
                jne     read_bad

                push    bx                      ; save bx for use as index
                xor     bx, bx

read_01:
                call    raw_read_kb
                cmp     al, KB_ACK              ; see if terminator
                je      read_02                 ; done if terminator

                push    di                      ; use for index of mcr_table
                mov     di, ax
                and     di, 0ffh                ; form index
                mov     al, byte ptr cs:mcr_table[di]    ; translate
IFDEF dlm
                call    PRCHAR
ENDIF
                pop     di

                mov     cs:mcr_buffer[bx], al   ; store the character
                inc     bx                      ; increment index
                cmp     bx, BUFF_SIZE           ; check for overflow
                jbe     read_01                 ; loop for next char

                ; buffer full

read_02:
                ; flush what's left if any
                call    flush_keyboard

                sti                             ; restore interrupts

                push    ds
                push    si

                lds     si, es:[di].XFR_ADR
                assume  ds:nothing

                ; transfer buffer - set bytes read

                mov     word ptr ds:[si].IO_STATUS, bx ; good read

                ; set ES:[DI] to point to user buffer

                push    ds
                pop     es                      ; set ES to DS
                assume  es:nothing
                mov     di, si                  
                add     di, 4                   ; point to user buff

                ; set DS:[SI] to point to mcr_buffer

                push    cs
                pop     ds
                assume  ds:CODE
                mov     si, offset mcr_buffer

                ; set byte count

                push    cx                      ; save cx for count
                mov     cx, bx

                cld
                rep     movsb                   ; transfer the data
     
                pop     cx                      ; restore cx
                pop     si
                pop     ds
                assume  ds:nothing
                pop     bx
                jmp     read_stat

read_bad:
                push    ds
                push    si
                lds     si, es:[di].XFR_ADR
                assume  ds:nothing
                mov     word ptr ds:[si].IO_STATUS, 0   ; error reading card
                pop     si
                pop     ds

read_stat:
                mov     ax, DEV_DONE
                ret

read_track      endp

COMMENT /***************************************************************
*
*   Procedure:  raw_read_kb
*                    
*   Purpose:    reads a byte from the keyboard
*
*   Arguments:  none
*
*   Returns:    [al] <- byte read -- no timeout
*
***********************************************************************/
raw_read_kb     proc    near
                assume cs:code, ds:nothing, es:nothing        

                ; wait for output buffer full

                push    ax

rr_1:
                in      al, KB_STAT_PORT
                test    al, OUTPUT_FULL
                jz      rr_1

                pop     ax
                in      al, KB_DATA_PORT        ; read the byte

;IFDEF dlm
;                call    PRCHAR
;ENDIF

                ret

raw_read_kb     endp


COMMENT /***************************************************************
*
*   Procedure:  raw_send_kb
*
*   Purpose:    sends a byte to the keyboard without waiting for
*               an ACK or RESEND
*
*   Arguments:  [al] <- byte to transmit
*               [ah] <- port
*
*   Returns:    none
*
***********************************************************************/
raw_send_kb     proc    near
                assume cs:code, ds:nothing, es:nothing        

                ; wait for input buffer empty

                push    dx
                push    cx
                push    ax

                xor     cx, cx          ; timeout countdown
rs_1:
                in      al, KB_STAT_PORT
                test    al, INPUT_FULL
                loopnz  rs_1

                pop     ax
                xor     dx, dx
                mov     dl, ah          ; port address
                out     dx, al          ; send the byte
                jmp     $+2             ; port settle

                pop     cx
                pop     dx

                ret

raw_send_kb     endp


;****************************************************************************
;       
;       Function:  send_keyboard
;
;       Purpose:   send a byte of cmd/data to keyboard, wait for ACK,
;                  retries are handled by the caller
;
;       Entry:     [AL] contains byte to xmit
;                  [AH] contains port, 60h for data, 64h for commands
;
;       Exit:      CY set if error, clear if successful
;       
;****************************************************************************
kb_dest         db      ?

send_keyboard   proc near
                assume cs:code, ds:nothing, es:nothing        

        push    es
        push    bx
        push    cx
        push    dx
        mov     bl, 3           ; retries --- handled by caller now
        mov     bh, al          ; temp save byte so can use AL

        mov     cs:kb_dest, ah  ; command or data port

        mov     ax, BIOS_DATA
        mov     es, ax

        assume es:BIOS_DATA

sk_0:
        cli     
        and     kb_flag_2, not (ACK_MASK + RESEND_MASK) ; clear flag bits          

        ; wait for input buffer empty

        xor     cx, cx          ; timeout countdown
sk_1:
        in      al, KB_STAT_PORT
        test    al, INPUT_FULL
        loopnz  sk_1

        ; get byte back and output thru specified port

        xor     dx, dx
        mov     dl, cs:kb_dest  ; put port address in DX

        mov     al, bh
        out     dx, al
        sti

        xor     cx, cx          ; timeout countdown

sk_2:
        test    kb_flag_2, ACK_MASK + RESEND_MASK
        jnz     sk_4
        loop    sk_2

        ; timeout if falls to here

sk_3:
        dec     bl              ; dec retry count, try again
        jne     sk_0
        or      kb_flag_2, KB_ERROR

        stc                     ; set carry for error exit
        jmp     short sk_exit

sk_4:   test    kb_flag_2, ACK_MASK
        jz      sk_3
        clc                     ; clear carry for good exit

sk_exit:
        pop     dx
        pop     cx
        pop     bx
        pop     es      
        ret

send_keyboard   endp

;****************************************************************************
;       
;       Function:  process_key
;
;       Purpose:   called directly by MOS to xlate each key code for a task
;
;       Entry:     DS - points to TCB base
;                  ES - points to SCB base
;                  AL - scan code received
;               
;       Exit:      if dx = 0
;                       if ax = -1  --> do nothing, buffer nothing
;                       else (ax != -1)
;                               bx = -1  --> buffer ax, [AH] must be zero (note)
;                               bx != -1 --> buffer bx, then buffer ax
;                  else  (dx != 0)
;                       dx = 1  --> invoke a print screen
;                       dx = 2  --> invoke a control break
;
;                       note: to cause a task switch, set dx = 0, bx = -1, ah = 0,
;                             then set al to the task number to change to 
;
;****************************************************************************
process_key     proc far
                assume cs:code, ds:TCB, es:nothing

IFDEF dlm
                call    PRCHAR
ENDIF

                mov     ah, al                  ; save key in AH

                ; see if key is the shift key

                push    cs			; Set [ES] = [CS]
                pop     es

                assume  es:code

                and     al, BREAK_BIT           ; Eliminate possible break bit
		cmp	al, SHIFT_KEY   	; Do we have a match ?
		je	shift_match		; Yes, go process it.

		mov	al, ah			; Restore AL and continue. 
                jmp     p_19                    ; No, not a shift key
                                                ; so run thru xlate function
	
shift_match:	mov	al, ah			; Restore AL and continue. 

p_1:                
                mov     cl, SHIFT_MASK          ; [CL] = Shift key mask

                test    al, BREAK_CODE          ; Break shift code
                jnz     p_10			; Yes, continue 
                           
                ; come here if shift-make code, CL = mask, AL = key

                or      TCBKTGGL, cl            ; Yes, indicate key depressed
                                                ; task copy of kb_flags

                jmp     short p_21              ; Exit

p_10:           
		; come here if shift-break code, CL = mask, AL = key
                ; indicate key no longer depressed, then exit

                not     cl                      ; Create reset 'and' mask
                and     TCBKTGGL, cl            ; kb_flags
                jmp     short p_21              ; Exit

p_19:
	        ; key is not a shift key - if 'break' code just ignore
                ; unless it is for a task change

                test    al, BREAK_CODE          ; Bit 7 set for break codes
                jnz     p_21

p_20:
	        ; the key is to be translated and placed in the buffer
                ; AL contains key

                call    translate_key           ; returns AX with code
                cmp     ax, KEYPAD_00           ; check if double 0
                je      p_200                   ; if so, send 2 ascii zeros
                mov     bx, -1
                jmp     short p_22

p_200:
                mov     al, '0'                 ; put ascii 0 in low byte
                mov     bx, ax                  ; copy to bx register
                jmp     short p_22              ; mos will send 2 codes
                                                
p_21:           
                mov     ax, -1
                mov     bx, ax

p_22:
                ; [AX] has key value
                xor     dx, dx                  ; required by MOS 
                call    update_bdata            ; maintain BIOS_DATA flags
                ret                             ; far

process_key     endp



COMMENT |*********************************************************************

	Procedure: 	UPDATE_BDATA

	Purpose: 	update the BIOS_DATA keyboard variables to reflect
                        their respective settings in the TCB

	Entry:		none
	Exit:		none

*****************************************************************************|
update_bdata    proc near
                assume cs:code, ds:TCB, es:code

                push    ax
                push    es
                mov     ax, BIOS_DATA
                mov     es, ax

                assume  es:BIOS_DATA

                mov     al, TCBKTGGL
                mov     es:kb_flags, al

                mov     al, TCBKSHFT
                mov     es:kb_flags_1, al

                pop     es
                pop     ax
                ret
update_bdata    endp

COMMENT |*********************************************************************

	Procedure: 	TRANSLATE_KEY

	Purpose: 	Translate scan code to key code based on shift state

	Entry:		[AL] = Scan code

	Exit:		[AX] = 16-bit code to insert into buffer

*****************************************************************************|
translate_key	PROC	NEAR
                assume cs:code, ds:TCB, es:code

tk_4:
                test    TCBKTGGL, SHIFT_MASK
                jz      tk_6
	               				; shift key is depressed
tk_5: 
                mov     si, offset shift_table
                jmp     short tk_9
tk_6:
                mov     si, offset normal_table ; no shift keys
tk_9:          
                mov     bl, al                  ; use the key to create an index
                xor     bh, bh                  ; in the BX register
                shl     bx, 1

tk_13:
                mov     ax, cs:[bx][si]         ; get the translation code
                                                ; undefined key if -1
tk_12:
                ret     

translate_key   endp

IFDEF dlm
		PAGE
COMMENT /*********************************************************************

	PROCEDURE:	PRCHAR

	PURPOSE:  	Print a character to LPT1:
			
	ENTRY:		[AL] = CHAR	

	EXIT:		None.

*****************************************************************************/
HEX_CHARS       db      '0123456789ABCDEF'

PRCHAR          PROC    NEAR
                
                push    ax
                push    dx
                push    cx
                push    di
                push    bx

;                cmp     al, 13                  ; is char a CR
;                je      print_it

;                cmp     al, 10                  ; is char an LF
;                je      print_it

;                cmp     al, '.'                 ; is it a period
;                je      print_it

                cmp     al, ' '                 ; below space
                jb      get_hex                 ; transform to hex

                cmp     al, '~'                 ; ~ or above,
                ja      get_hex                 ; print in hex

                jmp     print_it
get_hex:
                ; transform the character in al to hex

                mov     dx, 0
                mov     bl, al                  ; save char in bl
                mov     al, '['
                mov     ah, 0eh
                int     10h

                mov     cl, 4
                mov     al, bl                  ; get char in bl
                ror     ax, cl
                and     ax, 0fh                 ; mask in upper nibble
                mov     di, ax
                mov     al, cs:HEX_CHARS[di]       ; print upper nibble
                mov     ah, 0eh
                int     10h
 
                mov     al, bl                  ; save lower nibble in dh
                and     ax, 0fh                 ; mask out upper
                mov     di, ax
                mov     al, cs:HEX_CHARS[di]
                mov     ah, 0eh
                int     10h
                                
                mov     al, ']'                 ; bound the hex pair with
                mov     ah, 0eh                   ; square brackets.
                int     10h

                jmp     exit_pr

print_it:
                mov     dx, 0
                mov     ah, 0eh                 ; dos printer output
                int     10h

exit_pr:
                pop     bx
                pop     di
                pop     cx
                pop     dx
                pop     ax

                ret

PRCHAR          ENDP           

ENDIF

END_RESIDENT:

COMMENT /***************************************************************
*
*   Procedure:  init
*
*   Purpose:    device initialization routine - called on driver init
*
*   Entry:      ES:[DI] <- request header
*
*   Returns:    header information filled in
*
***********************************************************************/
init    proc    near
        assume  cs:CODE, ds:CODE, es:nothing

	jmp	init_1

msg1	 db     'ECCO+ CT Keyboard Driver (PC-MOS/386)   $'
msg2	 db     13,10,'Copyright (c) 1991 Unisys Corporation',13,10,10,'$'

rev     db      '$Revision:   1.1  $'

msg3    db      'Error: Driver valid for PC-MOS/386 only - not loaded'
        db      13,10,7,'$'

init_1:

        ; print sign on message

	mov	dx, offset msg1         ; driver title
	mov	ah, 9
	int	DOSINT
        mov	dx, offset rev          ; revision number
        inc     dx                      ; skip initial $ sign
	mov	ah, 9
	int	DOSINT
	mov	dx, offset msg2         ; copyright message
	mov	ah, 9
	int	DOSINT

        ; first of all, check if MOS is running

        call    ismos
        jz      notmos                  ; if not MOS, abort

        ; enable keyboard

        mov     ah, 60h                 ; keyboard data port
        mov     al, 0f4h                ; keyboard enable
        call    send_keyboard

        call    sound_buzzer            ; test interface

        ; get address of system control block
        ; and place translate function into placeholder for this driver

	mov	ah, 02          ; get scb
	int	MOSINT          ; PC-MOS call

        assume  es:SCBX

	mov	word ptr es:[bx + SCBSCANG], offset process_key
	mov	word ptr es:[bx + SCBSCANG + 2], cs

        ; compute last address used so can report back to MOS driver handler
        ; ds:dx

        LES     DI, REQUEST
        ASSUME  ES:NOTHING

        MOV     AX, OFFSET END_RESIDENT ; end of resident code
        MOV     ES:[DI.END_OFFSET], AX	; Return it to MOS
        MOV	AX, CS
        MOV     ES:[DI.END_SEGMENT], AX
        JMP     init_exit

notmos:
        les     di, REQUEST
        assume  es:nothing

        mov     es:[di.UNIT_COUNT], 0   ; no units
        mov     es:[di.END_OFFSET], 0   ; exit driver
        mov     ax, cs
        mov     es:[di.END_SEGMENT], ax

	mov	dx, offset msg3         ; driver error message
	mov	ah, 9
	int	DOSINT

init_exit:

        MOV     AX, DEV_DONE            ; indicate success

	ret	

init    endp

code	ends
	end     begin
