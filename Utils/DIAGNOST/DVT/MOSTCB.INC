COMMENT !***************************************************************************

	Title:		MOSTCB.INC

	Purpose:	Task Control Block Definitions
                        This file supplied by The Software Link
			
			
 
	Author:	    	The Software Link


	Release	    Date	Pgmr 	Description

        $Log:   Z:\CM\F\BPO\DVT\VCS\MOSTCB.INV  $
*  
*     Rev 1.0   10 Dec 1990 11:51:14   PJE
*  Initial revision.
*  
*     Rev 1.2   01 Nov 1988 12:21:30   CM
*  Copyright (c) 1988 Unisys Corp.
*  
*     Rev 1.1   01 Nov 1988 12:05:36   CM
*  Copyright (c) 1988 Unisys Corp.
*  
*     Rev 1.0   26 Jul 1988 14:12:12   HGM
*  Added new file.
*  

*****************************************************************************!


;-------------------------- TCB PREFIX ------------------------------;
TCBSTART LABEL BYTE
         DB     0        ; RESERVED
TCBTYPE  DB     0        ; 'T' TO INDICATE TCB
         DB     6 DUP(0) ; RESERVED
TCBTCBPN DW     0        ; POINTER TO NEXT TCB
TCBTCBPP DW     0        ; POINTER TO PREVIOUS TCB
         DB     4 DUP(0) ; RESERVED

;------------------------ GENERAL TASK DATA -------------------------;

; ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - !

; The offset within the TCB of TCBID and TCBCNADR is hard coded into
; the file MOXMEM.ASM so any changes to this file which would affect
; these offsets must include a corresponding change in MOXMEM.ASM

TCBID    DW     0       ; TASK ID (Task0 = 0, Task1 = 1, ETC.) 
TCBNCADR DW     0       ; Native context save address

; ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - ! - !

TCBBEGAD DW     0       ; PARTITION START ADDRESS
TCBENDAD DW     0       ; PARTITION END ADDRESS

TCBPRI   DB     2       ; TASK PRIORITY
TCBSLICE DB     1       ; TIME SLICE (CLOCK TICKS) FOR PARTITION

TCBWAIT  DB     0       ; BIT 0 - 1 IF WAITING
                        ; BIT 1 - 1 WHEN WAIT HAS BEEN RESOLVED
                        ; BIT 2 - CALL POLLER OR NOT
                        ; BIT 3 - 1 IF VIDRAM CALLED during suspention
                        ; BIT 4   UNDEFINED
                        ; BIT 5      "
                        ; BIT 6      "
                        ; BIT 7      "
TCBSTAT  DB     0       ; INDICATES WHAT THE TASK IS WAITING ON

TCBPOLL  DD     0       ; ADDRESS OF POLLING ROUTINE TO RESOLVE WAIT
                        ;   RETURNS AL = 0 IF WAIT CONDITION RESOLVED ELSE
                        ;   STATUS      1 - FOR KEY - KEY INPUT
                        ;               2 - FOR SERIAL INPUT
                        ;               3 - FOR TIMER
                        ;               4 - TO ACCESS A FILE
                        ;               5 - TO LOCK A RECORD
                        ;               6 - FOR KEY - STATUS LOOPER
                        ;               7 - TO PRINT A CHAR

TCBERRCOD DB    0       ; REAL ERROR CODE RETURNED FROM LAST MOS FN

TCBPRGNM DB     11 DUP(0) ; program name for mos.com's map display
                          ; NOTE:  also used in MOSITASK to hold
                        ; the entry parameter's ds:si which point
                        ; to the startup batch file string

;------------------------- KEYBOARD DATA ----------------------------;

TCBIBASE DW     200H    ; base address for keyboard input buffer
TCBIBSIZ DW     128     ; INPUT  BUFFER SIZE IN BYTES

TCBLOOP  DB     0       ; IF BIT 1 IS SET, DIS MODE
TCBKSHFT DB     0       ; CURRENT STATE OF KB SHIFTS AND TOGGLES
TCBSWPRS DB     'N'     ; NOT USED - LEFT IN TO PRESERVE OTHER OFFSETS
         DB     0       ; FILLER

;-------------------------- VIDEO DATA ------------------------------;

TCBMODE  DB     ?       ; Current video mode
TCBPAGE  DB     ?       ; Current video page
TCBCOLS  DB     ?       ; Number of text columns per screen
TCBROWS  DB     ?       ; Number of text rows per screen
TCBSCLN  DW     ?       ; Length of video buffers
TCBPGLN  DW     ?       ; Page length
TCBPGST  DW     ?       ; Page start address in video ram
TCBCPOS  DW     8 DUP(?) ; Cursor positions for the 4 screen pages
TCBCTYP  DW     ?       ; Current cursor type
TCBPAL   DB     ?       ; Current pallette setting
TCBOMODE DB     0       ; VIDEO MODE ORIGINALLY ASSIGNED PARTITION
TCBWINPO DB     0       ; TOP CRT ROW NUMBER: 0 OR 1
TCBVRAM  DB     ?       ; BIT 0 = 1 IF VIDRAM ACTIVE
                        ; BIT 7 = 1 IF THIS TCBCONDD IS MASTER CONSOLE

;TCBVIDW1 DW    0       ; ADDRESS OF VIDEO WORKAREA 1
TCBVIDH1 DW     0       ; HANDLE OF VIDEO SAVE AREA
TCBVIDP1 DW     0       ; PAGE COUNT OF VIDEO SAVE AREA
TCBVIDW2 DW     0       ; ADDRESS OF VIDEO WORKAREA 2 (VIDRAM)

;-------------------------- FILE I/O DATA ---------------------------;

TCBTFBPF DW     0       ; POINTER TO FIRST TASK FILE BLOCK
TCBCDBPF DW     0       ; POINTER TO FIRST CURRENT DIRECTORY BLOCK
TCBCDBPC DW     0       ; POINTER TO CDB FOR CURRENT DRIVE
TCBNDRIV DB     0       ; NUMBER OF DRIVES
TCBCDRIV DB     0        ; CURRENT DRIVE (0=A, 1=B, ETC.)
TCBDTA   DW     2 DUP(0) ; DTA ADDRESS
TCBPSP   DW     0        ; PSP OF CURRENT PROCESS FOR TASK
TCBOLDMBPF  DW     0     ;JSM 11/17/87 Pointer to 1st memory block prefix
;JSM 11/17/87 TCBMBPF  DW     0       ; Pointer to 1st memory block prefix
TCBVFLG  DB     0       ; NZ IF VERIFY SET ON FOR THIS TASK
TCBBRK   DB     0       ; NZ If BREAK set on for this task
TCBNTRY  DW     3       ; NUMBER OF RETRIES FOR SHARE AND LOCK VIOLATIONS
TCBTTRY  DW     19      ; TICKS BETWEEN RETRIES FOR SHARE AND LOCK VIOLATIONS

;-------------------------- PRINTER DATA ----------------------------;

TCBAUXBT DB     00010000B ; FLAGS FOR REMOTE PRINTER:
                          ; BIT 0 - LPT1 TO REMOTE
                          ; BIT 1 - LPT2 TO REMOTE
                          ; BIT 2 - LPT3 TO REMOTE
                          ; BIT 3 - ESC TO PRINTER IS PENDING
                          ; BIT 4 - XON/XOFF PROTOCOL
                          ; BIT 5 - ETX/ACK  PROTOCOL
                          ; BIT 6 - WAITING FOR ACK OR XON
                          ; BIT 7 - TRANSPARENT PRINT MODE IS ACTIVE
TCBAUXCT DB     64      ; DYNAMIC COUNT FOR ETX/ACK
TCBSPLTM DW     0       ; TIMER VALUE FOR SPOOLER CLOSE
TCBSPOOL DW     0       ; Segment address of spooler data for task
TCBLPTXL DB     3 DUP (0) ; printer redirection flags
                          ; 0        = No Redirection
                          ; 1  - 24  = Com Port to redirect to
                          ; 81 - 83  = Printer Port to redirect to
         DB     0       ; FILLER

;------------------- NON-PUBLICIZED TASK STUFF ----------------------;

TCBCLASS DB     0                   ; CLASS FOR THIS TASK
TCBUSER  DB     4 DUP(0)            ; 4-BYTE USER ID FOR THIS TASK
TCBCDFT  DB     0                   ; DEFAULT FILE CREATE CLASS FOR THIS TASK
TCBCMAP  DB    (26*2+7)/8 DUP(0aaH) ; CLASS PERMISSION MAP FOR THIS TASK

; TWO BITS PER CLASS ('A'-'Z')
; VALUE                 PARTITION               DIR/FILE
; 0 - ACCESS DENIED     NO ACCESS               NO ACCESS
; 1 - EXECUTE ONLY      VIEW ONLY               EXECUTE ONLY
; 2 - READ              ABOVE                   ABOVE+READ
; 3 - WRITE             ABOVE+SUPPLY KEYS       ABOVE+WRITE+CREATE+DEL+REN

         EVEN
TCBCTXP  DW     0       ; Pointer to context savearea (0 if memory mgt)

TCBSP    DW     0 ; TCB:TCBSTACK ; SAVES STACK POINTER
TCBSTKP  DW     0 ; TCBSTACK        ; (top of current stack)
TCBSVSP  DW     0       ; save area for MOS's SP when switch to user's stack
                        ; to process their interuppt intercept chain

TCBLAGCNT DD    0       ; last timer count when any application intercepts for
                        ; int08 or int1c were processed

TCBMMHDL DW     4 DUP (0)       ; Task MEMMAN handle for memory space (up to 4)
TCBMMPGS DW     4 DUP (0)       ; # of pages for corresponding memory handle
TCBVMHDL DW     2 DUP (0)       ; Task MEMMAN handle for video space (up to 2)
TCBVMPGS DW     2 DUP (0)       ; # of pages for corresponding video handle

TCBEMS   DW     0       ; If EMS present = segment address for save area
TCB87SAV DW     0       ; If 8087 present = segment address of save area

TCBPRITM DW     0       ; TIMER LOW BITS WHEN TASK LAST SELECTED

TCBTSKAX DW     0       ; Save space for task selection logic timer check
TCBTSKCX DW     0       ; "     "       "
TCBWTAX  DW     0       ; Save space for timed wait logic timer check
TCBWTCX  DW     0       ; "     "       "

TCBWINFO dw     0       ; segment pointer to wait information block

TCBWTFLG DB     0       ; Timer wrap around flag =1 if LSW of timer wraps to 0
                        ; Bit 0 = task selection logic
                        ; Bit 1 = spooler logic (has own save space)
                        ; Bit 2 = timed wait logic
                        ; Bit 3 = general wait logic
                        ; Bit 4 = DIS mode time out in mosi16 fun 01

TCBCAMON DB     0       ; BIT 0 = CARRIER MONITOR SWITCH

TCBBASEG DW     0       ; BASIC SEGMENT FROM 0:510

TCBERRVOL DD    0       ; VOLUME ID IF APPROPRIATE TO MOS ERROR
TCBRETC   DW    0       ; Return code used by fun 4C, 31, and 4D

TCBAPV0A DW     2 DUP(0) ; Application INT0A (IRQ2) (on AT's, int 71 -> int A)
TCBAPV0B DW     2 DUP(0) ; Application INT0B (IRQ3)
TCBAPV0C DW     2 DUP(0) ; Application INT0C (IRQ4)
TCBAPV0D DW     2 DUP(0) ; Application INT0D (IRQ5)
TCBAPV0E DW     2 DUP(0) ; Application INT0E (IRQ6)
TCBAPV0F DW     2 DUP(0) ; Application INT0F (IRQ7)
TCBAPV70 DW     2 DUP(0) ; Application INT70 (IRQ8)
TCBAPV71 DW     2 DUP(0) ; Application INT71 (IRQ9) (on AT's, int 71 -> int A)
TCBAPV72 DW     2 DUP(0) ; Application INT72 (IRQ10)
TCBAPV73 DW     2 DUP(0) ; Application INT73 (IRQ11)
TCBAPV74 DW     2 DUP(0) ; Application INT74 (IRQ12)
TCBAPV75 DW     2 DUP(0) ; Application INT75 (IRQ13)
TCBAPV76 DW     2 DUP(0) ; Application INT76 (IRQ14)
TCBAPV77 DW     2 DUP(0) ; Application INT77 (IRQ15)

;------------------- NON-PUBLICIZED KEYBOARD STUFF ------------------;

TCBKBCNT DB     0       ; TO OPTIMIZE TEST-KEYBOARD LOGIC
TCBKBFST DB     5       ; max fast int 16 calls in a row
TCBKBFCT DB     0       ; number of fast calls already
TCBKBMAX DB     8       ; max count for tcbkbcnt
TCBKBAX  DW     0       ; ax value for mosi16 fun 01 time out
TCBKBCX  DW     0       ; cx value for mosi16 fun 01 time out
TCBKBTCK DW     18      ; timer ticks for mosi16 fun 01 time out

TCBKEYRDY DD    0       ; -> KEYS IN BUFFER FLAG FOR THIS CONSOLE TERMINAL DD
TCBNXTDD  DW    0       ; -> NEXT PARTITION LOOKING AT PAM SCREEN
TCBSCRDD  DW    0       ; -> FIRST PARTITION ALSO LOOKING AT THIS SCREEN
TCBALTNUM DB    0,0     ; CURRENT ACCUMULATION OF ALT-NUM PAD KEYS
TCBKTGGL  DB    0       ; CURRENT SHIFT STATE OF TOGGLE KEYS
         DB     0       ; FILLER
TCBLASTKY DW    0       ; FOR ACCENT SHIFT CODE IN MOSINT16
TCBLSCAN  DB    0       ; remember last scan code (for key seq prefixes)
TCBALT999 DB    0       ; <> 0 if in partition access mode on numeric pad

TCBI9SEG DW     0       ; visual tcb for MOSINT09's call to DECODESCAN
TCBI9FLG db     0       ; as an entry data to DECODESCAN, this flag causes
                        ; the call to KEYCLASSCHK to be skipped (for MOSINT09)
                        ; as an output data from processing the int9 chain in
                        ; GETDDKEYS, this flag means MOSKEY should be called
TCBMOSKEY DB    0       ; used to pass the PAM # from decodescan to moskeys

TCBTRAPCD db    0       ; code to be used when 386 driver traps an in al,60
TCBPRT61 DB     20h     ; used in MOSINT06 to simulate I/O with port 61h
TCBFSAVR DB     'N'     ; short pass through flag for mossaver (mosint16)
         DB     0       ; FILLER

;-------------------- NON-PUBLICIZED VIDEO STUFF --------------------;

TCBVRTIM DW     0       ; SAVES TIMER VALUE FOR VIDRAM LOGIC
TCBPTMR  DW     ?       ; slice of last timer polling for this tcb
TCBCMODE DB     ?       ; CURRENT MODE FOR TERMINAL
TCBEGA   DB     0       ; EGA\VGA Video state control
                        ; bit 0 = 1 if in EGA or VGA mode 0 if not
                        ; bit 1 = 1 not-ok to state pam during getkeys
                        ;         0 ok to state-pam during getkeys 
                        ; bit 2 = 1 should be suspended because of state-pam
                        ;         0 task does not need to suspended
			; bit 3 = 1 if EGA system has only 64k on EGA card
			;         0 if EGA system has full 256k

;------------------- NON-PUBLICIZED PRINTER STUFF -------------------;

TCBSPSKP DB     'N'     ; Prevents recursion in spooler logic
         DB     0       ; FILLER
TCBPRNDX DW     0       ; Save space for DX register in INT 17 logic
TCBTOAX  DW     0       ; SAVE AX FOR INT17 TIMEOUT TESTING
TCBTOCX  DW     0         ; SAVE CX FOR INT17 TIMEOUT TESTING
TCBAUXTM DW     0       ; TIMER AT LAST AUXOFF, OR 0 IF INACTIVE

TCBSPLTP dw     40      ; timer for spooler close poll routine
TCBSPLTC dw     40      ; tick count for poll routine recycle

;----------------- MISCELLANEOUS NON-PUBLICIZED STUFF ---------------;

TCBLLSER DW     0       ; LANLINK SATELLITE SERIAL NUMBER

; The following data area is used by the CONsole device driver
; All of the labels start with TCB$
; This information is initialized in MOSITASK

TCB$HDR DW      2 DUP(0) ; Pointer to device header
TCB$CA  DB      7       ; Current attribute
TCB$ASI DB      'Y'     ; ANSI mode of operation (or not)
TCB$IQ  DB      0       ; Used to evaluate quotations
TCB$EF  DB      'N'     ; Flags pending ESC seqence
TCB$TCP DW      0       ; Temporary cursor position
TCB$KP  DB      'N'     ; Flaging extended key pressed
TCB$HB  DB      0       ; Holding buffer for extended key
TCB$ER  DW      0       ; Next routine to process ESC sequence
TCB$EBP DW      0         ; Buffer pointer for ESC sequences
TCB$EB  DB      60 DUP(0) ; ESC sequence buffer

; The following data area is used by the MOSDEVS device driver

TCBDEVHDR DW    2 dup(0)        ; Temporary header pointer
TCBDNUM   DB    0               ; device number
TCBPCNT   DB    0               ; number of printers installed

; The following data area is used by the MOSMIMAN cooking module
; All of the labels start with TCB%

TCBCONFG db     1bh     ; init for func 3f cooked mode
                        ; bit    meaning (if = 1)
                        ; ---   -------------------
                        ;  0    echo and expand tabs
                        ;  1    wait for a charactor
                        ;  2    return when requested bytes have been entered
                        ;       and return extended function key codes
                        ;  3    use 128 bytes as minimum buffer size
                        ;  4    act on control keys ^C, ^P, ^S

TCB%EBUF db     255 dup(0)      ; edit buffer (use for both 0a and 3f)

TCB%ECOL dw     0               ; edit column 1-128
TCB%BLEN dw     0               ; buffer length 0-127

;        MJS is to optimize the following field...

TCB%SB3F db     258 dup(0)      ; save buffer area for fun 3f
TOPSB3F  label  byte
         db     ?               ; for pericope

; NOTE: THE FOLLOWING DATA MUST STAY IN THIS ORDER

;        MJS is to optimize the following field...

TCB%SB0A db     512 dup(0)      ; save buffer area for fun 0a
TOPSB0A  label  byte
         db     ?               ; for pericope

TCB%RS0A dw     0               ; root size for 0a
TCB%RP0A dw     0               ; root pointer for 0a
TCB%CP0A dw     0               ; current pointer for 0a
TCB%RS3F dw     0               ; root size for 3f
TCB%RP3F dw     0               ; root pointer for 3f
TCB%CP3F dw     0               ; current pointer for 3f

; NOTE: THE DATA ABOVE MUST STAY IN THIS ORDER

TCB%DBUF db     8 dup(0)        ; buffer for DispChar
TCB%CBOT db     0               ; bottom line of cusor (12 MONO, 7 CGA)
TCB%STCL db     0               ; starting column
TCB%NSTLN db    0               ; starting line
TCB%LREF db     0               ; highest line for UpdStln
TCB%MAXC db     0               ; highest column
TCB%MAXL db     0               ; highest line
TCB%DLEN dw     0               ; length of display line
TCB%LTC dw      0               ; last tab expansion count (for dlen calcs)
TCB%TTC dw      0               ; total tab count
TCB%NMXB dw     0               ; max buffer length
TCB%STGC dw     0               ; staging counter for wrap detection calcs
TCB%INSF db     0               ; insert flag 0ffh = insert mode active
TCB%FLGS db     0               ; bit 1 = 1 last command was up arrow
                                ; bit 2 = 1 last command was down arrow
                                ; bit 4 = 1 echo to printer
                                ; bit 8 = 1 flag for call to DelUpd
                                ; bit 10 = 1 for add line feed code
                                ; bit 20 = 1 for ignore bit 4 (printer echo)
; End MOSMIMAN data

; The following data area is used by MOSINT21 to manage control-C

TCBBRKFG DB     0       ; bit 0=1 means a control-C was detected
                        ; bit 1=1 means ignore any control-C's detected
                        ; bit 2=1 getkeys uses to manage PAM key #0 / ctl-brk
                        ; bit 3=1 already in getkeys procedure
                        ; bit 4=1 process Ctrl-Num Lock

TCBNEST  DB     0       ; counter to manage control-C when re-entrant
TCBORGSP DW     0       ; save area for sp just before int 23
TCBSREG  DW     11 dup(0)       ; save area for original users registors
                                ; will need them if get an iret from int23

; End MOSINT21 data (for control-C)

; -> BELOW UNTIL ENDDDCON IS PASSED TO DDT'S
;    THE FIRST 5 WORDS MUST REMAIN THE SAME, THE LENGTH MUST REMAIN
;    AT LEAST XX BYTES

TCBCONDD DD     0       ; CONSOLE TERMINAL DD FOR THIS PARTITION
TCBDLOFS DW     0       ; OFS OF LOGICAL SCREEN
TCBDLSEG DW     0       ; SEG OF LOGICAL SCREEN
TCBDCOFS DW     0       ; CURSOR'S OFFSET WITHIN PAGE
TCBDCOL  DB     0       ; SCREEN COLS/ROW PASSED TO DDT
TCBPORT  DW     0       ; ASYNC PORT NUMBER, 0=NONE
TCBBAUD  DD     0         ; PHYSICAL BAUD RATE
         DB     19 DUP(0) ; This space is used by the DDTs for what ever they
                          ;  may require or need (cursor pos, colors, string
                          ;  space, attributes, etc...)

; ENDDDCON, Note: the order of the above table must remain as-is
;                 (by order of the fire marshal)

; following data used by mosddclk

TCBCHDR  dw     2 dup(0)        ; pointer to device header
TCBCDAY  dw     0               ; day counter

; end of clock driver data

TCBSAV24 DW     0       ; segment pointer to heap block where stack
                        ; is copied during an int 24h call (whew!)
TCBHDL24 DW     0       ; store 1st 2 handles here during int 24
TCBTPFRM DW     0       ; store bp here in mossaver (for toint24)

;       data for +except/+only list management

TCBPRESEG dw    0       ; first stage pointer for +EXCEPT/+ONLY
TCBACTSEG dw    0       ; second stage pointer for +EXCEPT/+ONLY


;--------------------- INTERRUPT CHAIN TABLES -----------------------;

TCBCHMAX EQU    5       ; maximum number of application chain table entries

;TCBFLGXX       last minute flag - referenced with offset -1, set if processing
;               an intercept chain and the ignoring of a re-assertion of a 
;               previous intercept causes an origin type 0 to occur when an
;               origin type 1 should be used.
;TCBCHTBxx label byte   ; CHAIN TABLE FORMAT
;
;       db      0       ; number of applications vectors
;
;       db      0       ; short cycle flag - used to determine if a chain of
;                       ; intercepts would pass on control to the BIOS
;
;       dd      0       ; copy of the next applications vector in the chain
;
;       dd      0       ; copy of the MOS vector to be used as a test 
;                       ; reference for the chkirq process
;
;       db      ((TCBCHMAX+1) * 10) dup(0)
;                       ; storage for table entries
;

        db      0       ; don't move this, its part of the table !!!!
TCBCHTB05 label byte
        db      10 dup(0)
        db      ((TCBCHMAX+1) * 10) dup(0)

        db      0       ; don't move this, its part of the table !!!!
TCBCHTB09 label byte
        db      10 dup(0)
        db      ((TCBCHMAX+1) * 10) dup(0)

        db      0       ; don't move this, its part of the table !!!!
TCBCHTB15 label byte
        db      10 dup(0)
        db      ((TCBCHMAX+1) * 10) dup(0)

        db      0       ; don't move this, its part of the table !!!!
TCBCHTB1B label byte
        db      10 dup(0)
        db      ((TCBCHMAX+1) * 10) dup(0)

	; MJS 11/30/87  removed int8 and int1c from chain table management
;        db      0       ; don't move this, its part of the table !!!!
;TCBCHTB08 label byte
;        db      10 dup(0)
;        db      ((TCBCHMAX+1) * 10) dup(0)
;        db      0       ; don't move this, its part of the table !!!!
;TCBCHTB1C label byte
;        db      10 dup(0)
;        db      ((TCBCHMAX+1) * 10) dup(0)


fillerx	db	142 dup(0)	; when need to add new vars - add here and 
				; deplete the count for fillerx


	; end MJS 11/30/87


        even

;-----ALL NEW ADDITIONS MUST BE MADE AFTER THIS POINT----------------;

TCBPRIPN DW     0       ; LINK TO NEXT TASK IN PRIORITY ORDER
TCBCNTXPT DW    0       ; when using MM, stores page number of context block
                        ; when no MM, stores segment of SMP context block
TCBT3x4   db    0       ; Trapped Crt controler index 3b4 or 3d4
TCBTCHIGH db    0       ; Trapped Crt Controler high pos 3b5 index 0e
TCBTCLOW  db    0       ; Trapped Crt Controler low pos 3b5 index 0f
TCBCOUNT  dw    0       ; Access Counter # of times switch in
TCBEXEC3D db    0       ; flag, set/reset by exec, causes openfile to adjust
                        ; to the current sharing/compatibility mode rather
                        ; than failing

;-----------Following changes are made after MOS 1.02 release--------;

TCBOPEN60   dd   0      ; Last open call ds:dx used by function 3dh
                        ; this call is used by function 60h RM-COBOL
TCBSTATE    DW   0      ; VGA (possiabily of EGA state area segment)
                        ; 0 means that state logic is not being use
TCBEGAPAL   DB   17 dup(0)  ; storage area for EGA\VGA palletes
TCBVIDEO    DB   0	; VMODE on system
			; Bit 0	- VMODE of MONO on system
			; Bit 1 - VMODE of CGA  on system
			; Bit 2 - VMODE of EGA  on system
			; Bit 3 - VMODE of VGA  on system
			; Bit 4 - VMODE of HG1  on system
			; Bit 5 - VMODE of HG2  on system
			; Bit 6	- 7 reserved

TCBATTEND DD	0	; timer value when suspended task was last attended
TCBIRQPN  DW	6 dup(0)	; table for irq2-7, next pointers in linked
				; lists of tasks which have an irq intercepts
TCBIRQSEC DB	0		; bit flags for irq2-7, when set, the corres-
				; ponding vector points to the 2nd handler
TCBWPEND  DB	0		; byte of bit flags for irq2-7, means to pop 
				; up window reporting an ambiguous irq.
TCBPAM	  DB	'Y'		; flag to indicate if paming is ok or not
TCBCRTIO  DB    'Y'		; crt control i/o trapping
				; 'Y' enabled
				; 'N' disable - output al to port dx
TCB03B8	  DB	08H		; last output to port 03b8
TCB03BF	  DB	00H		; last output to port 03bf
TCBTCCNT  DB    00H		; count of outs to 6845 cursor position regs
TCBSWFLG  DB    'N'		; Switch flag for getkeys
TCBSWITCH DB    00h		; Switch value for GetKeys
TCBBPCNT  DB	0	; COUNTER FOR MANAGING TASKS WHICH NEED BACKGROUND
			; PRINTING (E.G. WORDPERFECT)
TCBLSTTL  DW	0	; LAST VALUE OF LOW TIMER WORD FOR REFERENCE IN INT17
TCBCNT38  DW	0		; Depth counter for INT 38 replacement chain
TCBFAR38  DW    5 dup (0,0)	; INT 38 Replacement Chain Storage area
                                
TCBDIDKEY DB 	0		; bit map of last 8 slices (each bit 1 if
				;   int 16h get key called or if kb suspended)
TCB$WRAP  DB	'Y'		; FLAG TO INDICATE IF WRAPPING IS USE ANSI
TCBINMOS  DB    0,0		; Task Specific INMOS Flag for Resident progs
TCB28CNT  DW	0		; counter - makes suspend return to int16
				; periodically so int28 can be issued
TCB28FLG  DB	0		; used to determine if the counter is active
TCBEQUIP  DB    0		; Equipment flags on task boot up


; NOTE - ADD NEW VARS WHERE TCBCHTB08 AND TCBCHTB1C USED TO BE AND REDUCE
; THE ALLOCATION FOR FILLERX ACCORDINGLY    MJS 11/30/87
; NOTE - DON'T DO THIS UNTIL AFTER MOS 2.00 RELEASE     -  SAH 12/01/87

;------------------- DOS VARIABLE AREA ------------------------------;
;	This area contains variables which correspond, more or	     ;
;	less exactly, with the variable table to which DOS	     ;
;	int 21h function 52h returns a pointer.  These variables     ;
;	are needed specifically by code to support the IRMA 	     ;
;	software and the Mountain Bernoulli device driver.	     ;
;								     ;
;	This area added 11/17/87 by JSM				     ;
;--------------------------------------------------------------------;


TCBMBPF  DW     0       	; TB - 2 Pointer to 1st memory block prefix
TCBDPBPF DD	-1		; TB + 0 - base of DPB chain
	DB	0CH DUP (?)	; TB + 4 - TB + 0FH UNKNOWN TERRITORY
TCBSECSIZ DW	512		; TB + 10H SECTOR SIZE FOR DISK I/O
TCBDPBPO DD	?		; TB + 12H ANOTHER DPB POINTER?
	DB	0CH DUP (?)	; TB + 16H - TB + 21H UNKNOWN
TCBDDPF	DD	?		; TB + 22H POINTER TO FIRST DEVICE DRIVER
	DB	1CH DUP (?)	; TB + 26H - TB + 3FH UNKNOWN

;------------------------ RESERVED AREA -----------------------------;
;	This is the reserved area designed for patch and 	     ;
;	compatibility with future version of PC-MOS/386		     ;
;	This area is designed to be 64 bytes long and always         ;
;	remains right below the stack.  If you deside to add	     ;
;	items is this area, address them at the beginning of	     ;
;	this area and start going down to south to stack. On         ;
;	next release of MOS, all we do is address this items	     ;
;	as variables and float the area down.			     ;
;--------------------------------------------------------------------;

RESSIZ	EQU	64		; SIZE OF RESERVED AREA
TCBRES  DB	RESSIZ DUP(0)   

;----------------------------- STACK --------------------------------;
;       STACK MUST ALWAYS BE THE LAST ITEM IN THE TCB, THIS IS       ;
;       TO ALLOW FOR VARIABLE SIZE STACKS.                           ;
;--------------------------------------------------------------------;

STKSIZ    EQU   1500            ; SIZE OF EACH STACK
TCBMINSTK DB    STKSIZ DUP(0)
TCBSTACK  LABEL WORD            ; END OF STACK

;-------------------------- END OF TCB ------------------------------;

TCBLEN   EQU   $-TCBSTART

ddtrec	struc
	dd	?
logscr	dd	?
crsofs	dw	?
cols	db	?
port	dw	?
baud	dd	?
dcpherc db      ?               ; no hercules graphics (must be @ mcvars)
dcmode	db	?		; current physical mode
dcvmode db	?		; what was last set by MOS
dcpcrs	dw	?		;
dcpcol	db	?		;
dcaddr	dw	?		;
dcpscr	dw	?		;
dcpscrl dw	?		;
dcbios	db	?		;
dcsnow	db	?		;
ddtrec	ends


