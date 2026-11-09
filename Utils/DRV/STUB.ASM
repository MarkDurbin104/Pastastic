INCLUDE         \BC\LIB\STARTUP\RULES.ASI
NAME    STUB
_TEXT   SEGMENT BYTE PUBLIC 'CODE'
PubSym@         DGROUP@, <dw    ?>, __PASCAL__
_TEXT   ENDS
_DATA   SEGMENT WORD PUBLIC 'DATA'
_DATA   ENDS
_BSS    SEGMENT WORD PUBLIC 'BSS'
_BSS    ENDS
_CVTSEG         SEGMENT
PubSym@         _RealCvtVector, <label  word>,  __CDECL__
                ENDS

DGROUP  GROUP _DATA,_BSS,_CVTSEG



        .286

_TEXT   SEGMENT
        ASSUME CS:_TEXT,DS:NOTHING

extrn       __setupio:near
extrn       DRVENTRY:near

        ORG 0

        DW      -1,-1
        DW      1000000000000000B
        DW      STRAT
        DW      INTER
        DB      'STUBCODE'

REQPTR  DW      0,0
SSSAVE  DW      0
SPSAVE  DW      0
STAK    DB      100 DUP('STACK')
STAKTOP EQU     $

STRAT   PROC    FAR
        MOV     REQPTR,BX
        MOV     REQPTR+2,ES
        RETF
STRAT   ENDP

INTER   PROC    FAR
        PUSHF
        CLD
        MOV     SSSAVE,SS
        MOV     SPSAVE,SP
        CLI
        PUSH    CS
        POP     SS
        MOV     SP,OFFSET STAKTOP
        STI

        PUSHA
        PUSH    DS
        PUSH    ES

        MOV     AX,CS
        ADD     AX,SEG _DATA
	MOV     DS,AX

	PUSH REQPTR+2
	PUSH REQPTR
	
        CALL    DRVENTRY
        
        POP     ES
        POP     DS
        POPA

        CLI
        MOV     SS,SSSAVE
        MOV     SP,SPSAVE
        POPF
        RET
INTER   ENDP

_TEXT   ENDS
        END

