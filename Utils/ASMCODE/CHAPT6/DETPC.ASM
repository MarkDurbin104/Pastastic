
;
;       Program DetPC ( Chapter 6 )
;
page 55,132
.model large

HiBios  segment at 0F000h
         org            0FFFEh
PcType  db      ?               ; Computer idenifier
HiBios  ends

.code
        assume es:HiBios        ; ES wil be used for accessing ROM BIOS area
Begin:  mov     ax,@data        ; load segment address of DATA segement
        mov     ds,ax           ; DS points to DATA segment
        mov     ax,HiBios       ; load segment address or ROM BIOS data
        mov     es,ax           ; ES points to ROM BIOS segment
        mov     cx,Ltable       ; Load length of table to be searched
        mov     dl,PcType       ; Extract the type from BIOS area

Search: mov     bx,cx           ; Address of current table element
        cmp     dl,TypeTbl[bx-1] ;Compare type and element of table
        je      EndSear         ; If found, stop searching
        loop    Search          ; Test next element of table

EndSear:mov     al,cl           ; number element found passed as return code
        mov     ah,4Ch          ; DOS service 4H - terminate process
        int     21h             ; DOS service call
.data                           ;

;       Table of microprocessors' types

        db      0               ;  0 - Uknown type
TypeTbl db      0F8h            ;  1 - IBM PS/2 model 80
        db      0F9h            ;  2 - IBM PC Convertible
        db      0FAh            ;  3 - IBM PS/2 Model 30
        db      0FBh            ;  4 - PC XT Ext keyboard, 3.5" drives
        db      0FCh            ;  5 - PC-AT or PS/2 Models 50,60
        db      0FDh            ;  6 - IBM PC-JR
        db      0FEh            ;  7 - PC-XT
        db      0FFh            ;  8 - IBM PC
        db      09Ah            ;  9 - Compaq XT / Compaq Plus
        db      030h            ; 10 - Sperry PC
        db      02Dh            ; 11 - Compaq PC / Compaq Deskpro
Ltable  equ     $-TypeTbl
        end     begin
