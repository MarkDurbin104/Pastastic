;
;       Program CursOff ( Chapter 8 )
;
	page    55,132
.model small
.code
	org     100h
Begin:
;===    Read number of active video page from the BIOS data area
	mov     ax,0            ; Clear AX
	mov     es,ax           ; Prepare ES for accessing BIOS data area
	mov     bh,es:[462h]    ; Active video page into BH for next calls 
;===    Get parameters of cursor on the active video page
	mov     ah,03h          ; Function 03h - Get cursor parameters
	int     10h             ; BIOS video service
;===    Turn off the cursor on the active video page 
	mov     ah,01h          ; Function 01h - Set cursor parameters
	or      ch,30h          ; Set bit 4 and 5 of CH register to 1
	int     10h             ; BIOS video service call
;===    Exit program    
	mov     ax,4C00h        ; Function 4Ch - terminate process; exit code- 0
	int     21h             ; DOS service call
	end     Begin
