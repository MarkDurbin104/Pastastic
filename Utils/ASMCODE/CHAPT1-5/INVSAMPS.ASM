;
;       Program InvSamps
;
.model  small
.stack
.data
Msg1    db      'Message 1',0Dh,0Ah,'$'
Msg2    db      'Message 2',0Dh,0Ah,'$'
.code
ProcOut proc    near PASCAL, MsgAddr:ptr byte    
        mov     dx,MsgAddr              ; take address of parameter
        mov     ah,09h                  ; function 09 - output string
        int     21h                     ; DOS service call
        ret                             ; return to caller
ProcOut endp
.startup
        invoke  ProcOut,addr Msg1
        invoke  ProcOut,addr Msg2
.exit   0
        end
