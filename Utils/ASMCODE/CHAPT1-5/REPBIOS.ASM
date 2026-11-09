;
;       Program RepBios ( Chapter 4 )
;
.model  small
.stack
.data
TitMsg  byte      'Your computer has ROM BIOS version '
Vers    byte      64 dup (' ')
.code
.startup
        mov       DatSeg,ds            ; save DATA segment address
        mov       es,ROM_BIOS          ; ES points to ROM BIOS
        mov       di,0FFF5h            ; ES:DI point to BIOS date
        mov       cx,64                ; 64 character to search
        mov       al,0                 ; AL - character to search
repne   scasb                          ; find first match
        jnz       ExProg               ; NUL not found - exit
        mov       cx,di                ; DI -> character following NUL
        sub       cx,0FFF5h            ; CX now contains data length
        cmp       cx,9                 ; date must look like xx/xx/xx
        jb        ExProg               ; if not 9 characters, exit
        mov       bx,cx                ; BX contains position of NUL
        mov       ds,ROM_BIOS          ; DS points to ROM BIOS
        mov       es,DatSeg            ; ES points DATA segment
        lea       di,Vers              ; ES:DI point to Vers
        mov       si,0FFF5h            ; DS:SI point to BIOS date
rep     movsb                          ; copy BIOS date to Vers
        mov       ds,DatSeg            ; DS points to ROM BIOS
        mov       Vers[bx-1],'$'       ; append EndOf Message
        lea       dx,TitMsg            ; address of message for output
        mov       ah,09h               ; func. 09 - output text string
        int       21h                  ; DOS service call
ExProg:.exit      0
ROM_BIOS          dw         0F000h
Datseg  dw        0
        end
