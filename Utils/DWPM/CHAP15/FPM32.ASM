;##########################################################
;#                                                        #
;# File: FPM.ASM                                          #
;#                                                        #
;# 386 Floating point package by Al Williams              #
;#                                                        #
;##########################################################
.MODEL         SMALL,C


; enable 386 instructions
.386

.DATA

; Number format
FPM_NUM        STRUC
SIGN           DB     ?         ; 0 for + FF for -
SCALE          DB     ?         ; position of decimal point
NUM            DD     ?         ; unsigned magnitude
FPM_NUM        ENDS

IF MICROSOFT
FPM_RET        FPM_NUM   <>     ; static return value
ANSOFF         DW     OFFSET FPM_RET
ANSSEG         DW     @data
ENDIF

.CODE
; C  routines
PUBLIC         faddxy,fsubxy,fmulxy,fdivxy,bitscan

;************************************************
; Helper for C routines bitscan(dir,lword)
; if dir==0 do BSF on num
; if dir!=0 do BSR on num
; Returns index 1-32 or 0 if word was zero
bitscan        PROC
               ARG    DIR:WORD, LWORD:DWORD
               MOV    AX,DIR
               OR     AX,AX
               MOV    EAX,LWORD
               JZ     SHORT SCANFWD
               BSR    EAX,EAX
               JMP    SHORT BITSC0
SCANFWD:       BSF    EAX,EAX
BITSC0:        JNZ    SHORT BITSC1
               XOR    AX,AX
               RET
BITSC1:        INC    AX
               RET
bitscan        ENDP


;************************************************
; Adjust temp register @BX so that rightmost bit is 1
RADJ           PROC
; Find last set bit
               BSF    ECX,[BX].NUM
; If all zeros, jump to ZOUT
               JZ     SHORT ZOUT
; Shift right and adjust scale
               SHR    [BX].NUM,CL
               SUB    [BX].SCALE,CL
               RET
ZOUT:
               MOV    [BX].SCALE,0
               RET
RADJ           ENDP


;************************************************
; Adjust temp register @BX so leftmost bit is 1
LADJ           PROC
; Find first bit set
               BSR    ECX,[BX].NUM
; If all zero's goto zout (above in proc RADJ)
               JZ     ZOUT
; 31-Bit_index -> # places to shift
               MOV    CH,31
               SUB    CH,CL
               MOV    CL,CH
; Shift number and adjust scale
               SHL    [BX].NUM,CL
               ADD    [BX].SCALE,CL
               RET
LADJ           ENDP



;************************************************
; Add x+y
; FIXED faddxy(FIXED xarg,FIXED yarg)
; Note: Borland functions that return structure have
; "hidden" 1st argument that points to return
; value


faddxy         PROC   USES SI
IF MICROSOFT
               ARG    XARG:FPM_NUM,YARG:FPM_NUM
ELSE
               ARG    ANSOFF:WORD,ANSSEG:WORD,XARG:FPM_NUM,\
                      YARG:FPM_NUM
ENDIF
; Check for zero addition (x=0)
               MOV    EAX,XARG.NUM
               OR     EAX,EAX
               JNZ    SHORT YZA
               MOV    EAX,YARG.NUM
               MOV    CH,YARG.SIGN
               MOV    CL,YARG.SCALE
               JMP    DOADD3
; Check for y=0
YZA:           MOV    EAX,YARG.NUM
               OR     EAX,EAX
               JNZ    SHORT NZA
               MOV    EAX,XARG.NUM
               MOV    CH,XARG.SIGN
               MOV    CL,XARG.SCALE
               JMP    DOADD3
NZA:
               LEA    BX,YARG
               CALL   RADJ
               LEA    BX,XARG
               CALL   RADJ
; if eq then ok
               MOV    CL,XARG.SCALE
               MOV    CH,YARG.SCALE
               CMP    CL,CH
               JE     SHORT DOADD
; if xscale>yscale ...
               LEA    SI,YARG
               JG     SHORT PLUSADJY
               XCHG   CH,CL
               XCHG   BX,SI
PLUSADJY:
;    amt=xscale-yscale
               SUB    CL,CH
;    find top bit in y
               BSR    EAX,[SI].NUM
               MOV    CH,31
               SUB    CH,AL
               CMP    CH,CL
;    if 31-topbit>=amt shift y left by amt; yscale+=amt
               JL     SHORT PLUSELSE
               SHL    [SI].NUM,CL
               ADD    [SI].SCALE,CL
               JMP    SHORT DOADD
PLUSELSE:
;    else ...
;       shift y left by 31-topbit; yscale+=31-topbit
               XCHG   CH,CL
               SHL    [SI].NUM,CL
               ADD    [SI].SCALE,CL
               XCHG   CH,CL
               SUB    CL,CH
;       shift x right by amt-(31-topbit)
;       xscale-amt-(31-topbit)
               SHR    [BX].NUM,CL
               SUB    [BX].SCALE,CL
DOADD:
; Make certain bit 31 of each number is off and
; keep scales equal
               MOV    EAX,XARG.NUM
               MOV    EBX,YARG.NUM
               MOV    CL,XARG.SCALE

               MOV    EDX,EAX
               OR     EDX,EBX
               JNS    SHORT SETSIGN
               SHR    EAX,1
               SHR    EBX,1
               DEC    CL
SETSIGN:

               XOR    DH,DH        ; Set positive flag
               MOV    DL,XARG.SIGN
               OR     DL,DL
               JZ     SHORT DOADD1
               NEG    EAX
               INC    DH
DOADD1:        MOV    DL,YARG.SIGN
               OR     DL,DL
               JZ     SHORT DOADD2
               NEG    EBX
               INC    DH
DOADD2:
                                ; Assume positive sign in CH
               XOR    CH,CH
               ADD    EAX,EBX
               JNS    SHORT DOADD3
               OR     DH,DH
               JZ     SHORT DOADD3 ; Large positive number
               NEG    EAX
               NOT    CH
DOADD3:
               PUSH   DS
               LDS    BX,DWORD PTR ANSOFF
; Store sign, scale, and value
               MOV    [BX].SIGN,CH
               MOV    [BX].SCALE,CL
               MOV    [BX].NUM,EAX
               POP    DX
IF MICROSOFT
               MOV    AX,OFFSET FPM_RET
               MOV    DX,@data
ENDIF
               RET
faddxy         ENDP


;************************************************
; FIXED fsubxy(FIXED x,FIXED y)
fsubxy         PROC
               PUSH   BP
               MOV    BP,SP
; If X-0 then compute X+0
IF @CodeSize
IF MICROSOFT
XX             EQU 10
ELSE
XX             EQU 16
ENDIF
ELSE
IF MICROSOFT
XX             EQU 12
ELSE
XX             EQU 14
ENDIF
ENDIF
               MOV    EAX,[BP+XX].NUM
               OR     EAX,EAX
               JZ     SHORT SUBBY0
; else compute X+-1*Y
               NOT    [BP+XX].SIGN
SUBBY0:
               POP    BP
; Let + do the work
               JMP    faddxy
fsubxy         ENDP


;************************************************
; FIXED fmulxy(FIXED xarg,FIXED yarg)
; Note: Borland functions that return structure have
; "hidden" 1st argument that points to return
; value
fmulxy         PROC
IF MICROSOFT
               ARG    XARG:FPM_NUM,YARG:FPM_NUM
ELSE
               ARG    ANSOFF:WORD,ANSSEG:WORD,XARG:FPM_NUM,\
                      YARG:FPM_NUM
ENDIF
; Right adjust X
               LEA    BX,XARG
               CALL   RADJ
; Right adjust Y
               LEA    BX,YARG
               CALL   RADJ
; Check for X*0 or 0*Y
               MOV    EAX,XARG.NUM
               OR     EAX,EAX
               JZ     SHORT RETZM
               MOV    EBX,YARG.NUM
               OR     EBX,EBX
               JZ     SHORT RETZM
; Do it
               MUL    EBX
TSTZLP:
; Find bits in EDX (overflow of 32 bits)
               BSR    ECX,EDX
; If none, goto DXZ
               JZ     SHORT DXZ
; Shift bits to EAX and adjust scale
               INC    CL
               SHRD   EAX,EDX,CL
               SUB    XARG.SCALE,CL
DXZ:

               OR     EAX,EAX
               JNS    SHORT NOOF
; keep answer positive
               SHR    EAX,1
               DEC    XARG.SCALE
NOOF:
; store answer
               PUSH   ES
               LES    BX,DWORD PTR ANSOFF
               MOV    ES:[BX].NUM,EAX
; compute new scale
               MOV    AL,YARG.SCALE
               ADD    AL,XARG.SCALE
               MOV    ES:[BX].SCALE,AL
; compute new sign
               MOV    AL,YARG.SIGN
               XOR    AL,XARG.SIGN
               MOV    ES:[BX].SIGN,AL
               POP    ES
IF MICROSOFT
               MOV    AX,OFFSET FPM_RET
               MOV    DX,@data
ENDIF
               RET
; Jump here to return a zero
; shared by MUL & DIV
RETZM:         PUSH   ES
               LES    BX,DWORD PTR ANSOFF
               XOR    EAX,EAX
               MOV    ES:[BX].NUM,EAX
               MOV    ES:[BX].SCALE,AL
               MOV    ES:[BX].SIGN,AL
               POP    ES
IF MICROSOFT
               MOV    AX,OFFSET FPM_RET
               MOV    DX,@data
ENDIF
               RET
fmulxy         ENDP


;************************************************
; FIXED fdivxy(FIXED,FIXED)
; Note: Borland functions that return struct have a
; "hidden" 1st argument that points to return
; value
fdivxy         PROC
IF MICROSOFT
               ARG    XARG:FPM_NUM,YARG:FPM_NUM
ELSE
               ARG    ANSOFF:WORD,ANSSEG:WORD,XARG:FPM_NUM,\
                      YARG:FPM_NUM
ENDIF
; left adjust X
               LEA    BX,XARG
               CALL   LADJ
; right adjust Y
               LEA    BX,YARG
               CALL   RADJ
; check for divide by zero
               MOV    EAX,XARG.NUM
               OR     EAX,EAX
               JZ     RETZM
; check for divide by 1
               MOV    EBX,YARG.NUM
               CMP    EBX,1
; Don't divide by 1 -- besides if we rotated EDX:EAX left,
; / by 1 would result in overflow
               JZ     SHORT DODIV
; Shift X bits into EDX based on size of Y
               XOR    EDX,EDX
               BSR    ECX,EBX
               SHLD   EDX,EAX,CL
               SHL    EAX,CL
; Adjust scale
               ADD    XARG.SCALE,CL
               DIV    EBX
DODIV:
               PUSH   ES
               LES    BX,DWORD PTR ANSOFF
               MOV    ES:[BX].NUM,EAX
; Computer answer's scale
               MOV    AL,XARG.SCALE
               SUB    AL,YARG.SCALE
               MOV    ES:[BX].SCALE,AL
; Find answer's sign
               MOV    AL,YARG.SIGN
               XOR    AL,XARG.SIGN
               MOV    ES:[BX].SIGN,AL
               POP    ES
IF MICROSOFT
               MOV    AX,OFFSET FPM_RET
               MOV    DX,@data
ENDIF
               RET
fdivxy         ENDP

               END
