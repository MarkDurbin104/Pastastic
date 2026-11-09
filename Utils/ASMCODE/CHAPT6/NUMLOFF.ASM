
page 60,132
;
;                  PROGRAM NumlOff
;                     Chapter 6
;
;              30 Nov 1991, Voronezh
;
;       This is  a  sample  of  BIOS  data  usage.   This
;       program turns off the NumLock state.  It is known
;       that the extended  AT  keyboard  held the NumLock
;       state after DOS  had finished loading.  Executing
;       this  programt  you  may  turn  the  NumLock  off
;       without any  key  pressing.  Sometimes it  may be
;       useful  to  include the  following line  in  your
;       AUTOEXEC.BAT file:
;
;       NumLOff
;
;       If you decide  to do this, include the executable
;       module   of   this   program   (NumlOff.COM    or
;       NumlOff.EXE)  in any directory that is availiable
;       during the DOS loading process.
;
.model tiny                             ; The TINY memory model
					; is needed to build
					; the COM- program

BiosData        segment at 40h          ; BIOS data definition
	org     17h                     ; Keyboard flags from address 0417h
KbdSt1  db      ?                       ; Keyboard_status byte 1
KbdSt2  db      ?                       ; Keyboard_status byte 2
BiosData        ends                    ; End of BIOS data

.code                                   ; CODE segment starts here
begin:
	assume  es:BiosData             ; BIOS data area will be accessed
					;   through register ES
	mov     ax,BiosData             ; Load address of BIOS data segment
	mov     es,ax                   ;    into AX and copy it into ES
	and     KbdSt1,0DFh             ; Clear the NUMLOCK status (bit 5)

	mov     ax,4C00h                ; Set the exit code 0
	int     21h                     ; and return to DOS

	end     begin
