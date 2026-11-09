;
;       Program CursOn ( Chapter 8 )
;
	page    55,132
.model small
.code
	org     100h            ; This is needed for COM-files
;===    Block 1: Get equipment information      
Begin:                          ; The program starts here
	int     11h             ; BIOS service - get equipment information
	and     al,30h          ; Emphasize bits 4,5 - display mode
	cmp     al,30h          ; Bits 4 and 5 are set - Monochrome
	je      Mono            ; Process monochrome display
;===    Block 2: Enable CGA cursor emulation    
;       mov     ah,11h          ; Function 11h - Character set service
;       mov     al,0            ; Allow cursor emulation
;       mov     bl,34h          ; Subfunction 34h - Cursor emulation
;       int     10h             ; BIOS video service
	mov     cx,0607h        ; CGA cursor locates within lines 6 - 7
	jmp     SetCur
;===    Block 3: Set cursor parameters - monochrome mode
Mono:   mov     cx,0B0Dh        ; MDA/HGC cursor locates within lines 13 - 14
;       Block 4: Set cursor parameters - color mode     
SetCur: mov     ax,40h          ; Segment address of BIOS data area
	mov     es,ax           ; ES will point to the BIOS data area
;       mov     al,es:49h       ; AL - current video mode for some buggy BIOS 
;       mov     bh,es:62h       ; BH contains the number of active video page
	mov     ah,01h          ; Function 01 - Set cursor type
	int     10h             ; BIOS video service call
;===    Block 5: Exit program   
ExProg: mov     ax,4C00h        ; Function 4Ch - terminate process, exit code 0
	int     21h             ; DOS service call
	end     Begin 
