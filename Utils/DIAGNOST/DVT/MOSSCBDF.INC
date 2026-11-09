COMMENT !***************************************************************************

	Title:		MOSSCBDF.INC

	Purpose:	System Control Block Definitions
                        This file supplied by The Software Link
			
			
 
	Author:	    	The Software Link


	Release	    Date	Pgmr 	Description

        $Log:   Z:\CM\F\BPO\DVT\VCS\MOSSCBDF.INV  $
*  
*     Rev 1.0   10 Dec 1990 11:49:18   PJE
*  Initial revision.
*  
*     Rev 1.2   01 Nov 1988 12:21:24   CM
*  Copyright (c) 1988 Unisys Corp.
*  
*     Rev 1.1   01 Nov 1988 12:05:30   CM
*  Copyright (c) 1988 Unisys Corp.
*  
*     Rev 1.0   26 Jul 1988 14:14:22   HGM
*  New file.
*  

*****************************************************************************!



scb	label	byte

public	scbtcbpf, scbtcbpl, scbbdbpf, scbbdbpl, scbgfbpf, scbgfbpl
public	scbdbbpf, scbdbbpl,scbcntxt, scbctxsz, scbslice
SCBTCBPF DW	0	; POINTER TO FIRST TASK CONTROL BLOCK
SCBTCBPL DW	0	; POINTER TO LAST TCB
SCBBDBPF DW	0	; POINTER TO FIRST BLOCK DEVICE BLOCK
SCBBDBPL DW	0	; POINTER TO LAST BDB
SCBGFBPF DW	0	; POINTER TO FIRST GLOBAL FILE BLOCK
SCBGFBPL DW	0	; POINTER TO LAST GFB
SCBDBBPF DW	0	; POINTER TO FIRST DISK BUFFER BLOCK
SCBDBBPL DW	0	; POINTER TO LAST (AND OLDEST) DBB
SCBCNTXT DW	0	; POINTER TO MASTER MEMORY CONTEXT
SCBSLICE DB	0	; Default # of time slices for each task

public scbtcbpc, scbtcbpv, scbtcbps, scbtcbvr
SCBTCBPC DW	0	; TCB POINTER OF CURRENT (CONTEXT) TASK
SCBTCBPV DW	0	; POINTER TO VISIBLE TCB (AT CONSOLE)
SCBTCBPS DW	0	; TCB POINTER OF "SWITCHED-IN" TASK
SCBTCBVR DW	0	; TCB POINTER OF "SWITHCED-IN" VIDEO (0 if none)

public	scbidq2, scbidq3, scbidq4, scbidq5, scbidq6, scbidq7
SCBIDQ2  DW	0	; ID of task that gets IRQ2s \
SCBIDQ3  DW	0	; ID of task that gets IRQ3s  \
SCBIDQ4  DW	0	; ID of task that gets IRQ4s   \  -1 if device
SCBIDQ5  DW	0	; ID of task that gets IRQ5s   /
SCBIDQ6  DW	0	; ID of task that gets IRQ6s  /
SCBIDQ7  DW	0	; ID of task that gets IRQ7s /

public scbvcuty, scbvcupo, scbauxtm, scbconsz, scbvidad, scbtcbn, scbversn
SCBVCUTY DW	0	; CURSOR TYPE OF VISIBLE TASK		     PAMCURTY
SCBVCUPO DW	0	; CURSOR ADDRESS OF VISIBLE TASK	     PAMCURSR
SCBAUXTM DW	40	; TIME AFTER AUXOFF FOR XOFF VALID	     GAUXTIM
SCBCONSZ DW	0	; NBR PARAGRAPHS FOR CONTEXT SAVEAREA	     CONPAGES
SCBVIDAD DW	0B800H	; SCREEN ADDRESS (B000 OR B800)	     SCREENAD
SCBTCBN  DW	0	; NUMBER OF TASKS
SCBVERSN DW	1403H	; DOS VERSION, 3.20 (not MOS version)

        DD      ?
;	include version.inc	; Just 2 DWs (used by all utilites)

public scbold05, scbold08, scbold09, scbold10, scbold14, scbold16, scbold17
SCBOLD05 DW	2 DUP(0)	; ORIGINAL PRINT-SCREEN VECTOR
SCBOLD08 DW	2 DUP(0)	; ORIGINAL TIMER (IRQ0) VECTOR
SCBOLD09 DW	2 DUP(0)	; ORIGINAL KEYBD (IRQ1) VECTOR
SCBOLD10 DW	2 DUP(0)	; ORIGINAL SCREEN   I/O VECTOR
SCBOLD14 DW	2 DUP(0)	; ORIGINAL SERIAL   I/O VECTOR
SCBOLD16 DW	2 DUP(0)	; ORIGINAL KEYBOARD I/O VECTOR
SCBOLD17 DW	2 DUP(0)	; ORIGINAL PARALLEL I/O VECTOR

public scbmmhan, scbmmptr, scbmmsub, scbmmfea, scbmmfe2
public scbmmgrn, scbmmmod, scbmmerr, scbmm6ad, scbmmscb
SCBMMHAN DW	0	; MEMMAN DEVICE HANDLE
SCBMMPTR DD	0	; POINTER TO DEVICE DATA
SCBMMMOD DD	00H	; MEMMAN modes  bit 7 - video management on
			;		bit 6 thru 0 undefined

; Note: The order of the following areas must be maintained as is
; 14 words total

SCBMMSUB DD	0	;1 Pointer to MEMMAN entry point
SCBMMFE2 DB     0	;2 More feature flags (all undefined)
SCBMMFEA DB	0	;3 Feature flags: bit  7 - All memory manageable
			;				(like video & page 0)
			;		       6 - I/O trapping available
			;		       5 - write protection available
			;		       4 - context switching available
			;		       3 thru 0 undefined
SCBMMGRN DB  4 dup (0)	;4 Page granularity (usually 4k, others are 16k & 64k)
	 DB  8 dup (0)	;5 Reserved (actually invalid memory specs)
SCBMMERR DW	0	;6 INT 6 error codes
SCBMM6AD DW	0,0	;7 INT 6 address info
SCBMMSCB DW	0,0	;8 SCB address set by MOS for MEMMAN driver

public scbemmsz, scbemmfm, scbems, scbmmfg
SCBEMMSZ DW	0	; EMM register page size
SCBEMMFM DW	0	; EMM page frame segment address
SCBEMS	 DB	'N'	; Flag to indicate EMS present
SCBMMFG  DB	'N'	; MEMMAN used flag


public scbaltf1, scbspltm, scblowpr, scbvmode
SCBALTF1 DB	104	; KEYBOARD CODE FOR ALT-F1
SCBSPLTM DB	180	; NBR TIMER TICKS BEFORE SPOOL CLOSE
SCBLOWPR DB	0	; LOWEST SELECTABLE PRIORITY (0 OR 1)
SCBVMODE DB	0	; SCREEN MODE OF VISIBLE TASK

public scbswmm, scbsw87, scbswali, scbswaf9, scbhpadr, scbhpsiz, scbbufsz
public scbshell, scbcntry, scbcursz, scbcurad, scbavsiz, scbdrivs, scbnoswt
public scbinirq, scbin08, scb13buf
SCBSWMM  DB	'N'	; IF MEMORY MGT AVAILABLE		     MEMMAN
SCBSW87  DB	'N'	; IF 8087 OR 80287 REGS TO BE SAVED	     ML8087
SCBSWALI DB	'N'	; "MIR ALI" WORKSTATIONS USED		     DREPUSED
SCBSWAF9 DB	'N'	; WAS PREV KEYSTROKE ALT-F9		     ALTF9SW
SCBINIRQ DB	0	; <>0 if user IRQ routine active
SCBIN08	 DB	0	; <>0 If within a timer (IRQ 0) call

SCBHPADR DW	0	; Heap segment address
SCBHPSIZ DW	1000H	; Heap size in paragraphs (default 64K)
SCBBUFSZ DW	512	; Disk buffer size
SCB13BUF DW	0	; Address of INT 13 disk buffer

SCBSHELL DB	'A:\COMMAND.COM',0		; default is boot:\command.com
	 DB	(SCBSHELL+64+3+1+12)-$ DUP(0)	; LEAVING ROOM FOR A 64-BYTE
				; PATH (INCLUDING THE NULL) + DRIVE:\ +
				;   TRAILING \ + 12-CHAR FILE NAME
SCBCNTRY DW	001	; Country type
SCBCURSZ DW	0ffffH	; Used in MOSHEMAN
SCBCURAD DW	0	; Used in MOSHEMAN
SCBAVSIZ DW	0	; Used in MOSHEMAN
SCBDRIVS DB	0	; # active drive units
SCBNOSWT DB	0,0	; MOS no switch flag (Like DOS critical flag)
			; To be set if no task switch is to occur
			; A 0 byte follows since some apps check the word
public	 scbtskfg
SCBTSKFG DB	0	; Task selection flags
			;  bit 0=1 if No higher priority task needs service
			;  bit 1 thru 7 unused
public scbdrvr
public scbstdin, scbstdout, scbstdnul, scbstdclk, scbstdprn, scbstdaux
SCBDRVR   DD	-1		     ; -> to first device driver in list
SCBSTDIN  DD	0
SCBSTDOUT DD	0
SCBSTDNUL DD	0
SCBSTDCLK DD	0
SCBSTDPRN DD	0
SCBSTDAUX DD	0

public scbdbblen, scbdebug, scbdbprt, scbvrwait, scbmastv, scbkey

SCBDBBLEN DW	?		; the length of a Disk Buffer Block (DBB)
SCBDEBUG  DW	0		; Debug options active
SCBDBPRT  DW	0		; Debug serial port
SCBVRWAIT DW	4		; how many ticks to wait between vidram checks
SCBMASTV  DW	0		; LOCATION OF MASTER VIDEO SAVE AREA
SCBKEY	  DD	0		; MASTER DECRYPTION KEY

public scbmosadr, mos1ad, scbusrf, scbhwcl, scblen, scbiop
MOS1AD	  DW	0		; Used as DWORD to call MOS from MOSFUTIL & Co
SCBMOSADR DW	0		; Segment address of MOS kernel

SCBUSRF   DB	'A:\$$USER.SYS',0	; boot:\$$USER.SYS is the default
	  DB	(SCBUSRF+64+3+1+12)-$ DUP(0)	; LEAVING ROOM FOR A 64-BYTE
				; PATH (INCLUDING THE NULL) + DRIVE:\ +
				;   TRAILING \ + 12-CHAR FILE NAME

SCBHWCL	DB	16 dup (0)	; occurrence counts for all 16 interrupts

SCBIOP	DB	256 dup(0)	; I/O protection permission map
				; Ports 0 7ffH (bit on causes INT 6 if port
				; accessed).

public scbfar21
SCBFAR21 DD     0		; far call to mosint21 (NOVELL)	

public scbcurcnt, scbcurwrp, scbsvfake, scbfakein, scbhldss, scbbuff
public scbmosend
SCBCURCNT DD	0		; storage for the timer tick count at 40:6c,6e
SCBCURWRP DB 	0		; stoarge for the timer wrap falg at 40:70
SCBSVFAKE DD	0		; storage for the timer tick count when get
				; an int08 while still in int08
SCBFAKEIN DB	0		; <> 0 when a fake count is in place
SCBHLDSS DW	0		; used to record ss in TSL
SCBBUFF   DW    5 DUP (0,0)     ; used to save freemem information
SCBMOSEND DW    0		; end segment above mos kernel

; following is a fake code fragment to convince sidekick that
;   this is a dos version it understands
; since scbnoswt is in grp, this fragment and flag must be in grp and thus
;   can't reflect the actual partition state as regards int 24h because
;   it can't be different for each partition - so it's always 0
fake24flg label byte
if 0
	db	0

	cmp	byte ptr fake24flg, 0
	jnz	$+5
	int	28h
else
        db      10 dup(0)
endif

	even		; SAH don't remove this line or utilities that
			; use the scb following this code will not
			; function correctly

;======== NOTE: ALL NEW ENTRIES MUST BE MADE AFTER THIS POINT ==========;

;public scbpripf, scbctxsz, scbscang, scbcin24, scbtcbvs, scbcpseg, scbvtype
;public scbcpsiz, scbfar38, scbvidpg, scbmastp

SCBPRIPF DW	0	; POINTER TO FIRST TCB IN PRIORITY ORDER
SCBCTXSZ DW	0	; MOSHEMAN SIZE FOR CONTEXT BLOCK
SCBSCANG DD	0	; vector for keyboard processing routine
SCBCIN24 DD     0	; vector to point to command processors INT 24 handler
SCBTCBVS DW	0	; TASK WHOSE VIDEO SAVE AREA IS SWITCHED IN
SCBCPSEG DW	0	; SEGMENT WHERE $$SHELL.SYS IS LOCATED
SCBVTYPE DB	0	; SET FROM THE VTYPE STATEMENT OF CONFIG.SYS
SCBCPSIZ DW	0	; # OF PARAGRAPHS FOR COMMAND PROCESSOR
SCBFAR38 DD	0	; vector to MOS's INT 38 routine

;*********************************************************************;
;		PC-MOS/386 Version 1.02 in production 08/24/87        ;
;*********************************************************************;

;public	scbhpalc, scbirqpf, scbegaio, scbioflg, scbinmos

SCBHPALC DW	0	; Latest Heap allocation (total)
SCBVIDPG DW     0	; how many pages to expose in SWREALRAM
SCBMASTP DW	0	; the maximum pages in the video save area SCBMASTV
SCBIRQPF DW	6 dup(0)	; table for irq2-7, root pointers to linked
				; lists of tasks which have irq intercepts
SCBEGAIO DB     'N'	; flag to indicate if EGA IO protection is on or off
SCBIOFLG DB     'N'	; flag to indicate if IO protection is on or off

SCBINMOS DB	0,0		; new INMOS flag for Sidekick support

;***************************************************************************
;	PC-MOS/386 Version 2.10 went into production
;***************************************************************************

public	scbtimer

SCBTIMER dw	0		; Tick counter for timeparm routine

;	Following Items are items which were inside MOS's codes segment and
;	are now inside of the SCB for future 286 version

public	scbboot, scbmsgseg

SCBBOOT	dw	0		; BOOT segment
SCBMSGSEG dw	0		; Message segment

SCBLEN	 EQU   $-scb

