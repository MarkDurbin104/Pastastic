;
; Program Flags ( Chapter 2 ) 
;
Page 60,132
.model small
.code
Begin:
;
;       PART 1 The effects on ZERO FLAG
;       ===============================
;
        sub     ax,ax        ; Clear AX - Zero equals ZR
        add     ax,1         ; Zero flag becomes NZ
        add     ax,0FFFFh    ; Zero flag becomes ZR
        add     ax,1         ; Zero flag becomes NZ again
;
;       PART 2 The effects on SIGN FLAG
;       ===============================
;
        sub     ax,ax        ; Sign flag must be PL
        sub     ax,1         ; Sign flag becomes NG
        add     ax,2         ; Sign flag becomes PL
;
;     PART 3 The effects on CARRY FLAG (CF)
;     =====================================
;
        sub     ax,ax        ; Clear AX - CF must be NC
        mov     ax,0FFFFh    ; Carry flag is not affected
        add     ax,1         ; Carry flag becomes CY
        add     ax,0         ; Carry flag becomes NC
        sub     ax,1         ; Carry flag becomes CY
;
;       PART 4 The effects on AUXILLARY CARRY FLAG
;       ==========================================
;
        sub     ax,ax        ; Auxillary Carry gets NA
        mov     ax,8         ; Flag is not affected
        add     ax,8         ; Auxillary Carry gets AC
        add     ax,0         ; Auxillary Carry gets NA
        sub     ax,1         ; Auxillary Carry gets AC
;
;       PART 5 The effects on OVERFLOW FLAG
;       ===================================
;
        sub     ax,ax        ; Overflow flag must be NV
;                            ;
;       Addition
;                            ;
        mov     al,128       ; Overflow flag is not affected
        add     al,128       ; Overflow flag becomes OV
;
;       Subtraction
;
        sub     ax,ax        ; Overflow flag becomes NV
        add     ax,8000h     ; Flag is not affected
        sub     ax,7FFFh     ; Overflow flag becomes OV
;
;       Multiplication
;
        sub     ax,ax        ; Overflow flag must be NO
        mov     al,16        ; The first factor into AL
        mov     bx,16        ; The second factor into BL (BH=0)
        mul     bl           ; Product=256 in AX, Overflow flag is OV,
                             ;   Carry flag = CY
;
;       PART 6 The effects on PARITY FLAG
;       =================================
;
        sub     ax,ax        ; Parity flag must be PE
        add     ax,1         ; Parity flag becomes PO
        add     ax,10h       ; Parity flag becomes PE
        add     ax,0100h     ; Parity flag unchanged
;
;       PART 7 Finishing the program
;       ============================
;
        mov     ax,4C00h     ; AH - Dos service number,
                             ; Al - Return code
        int     21h          ; Dos service call
.data
.stack
        end begin
