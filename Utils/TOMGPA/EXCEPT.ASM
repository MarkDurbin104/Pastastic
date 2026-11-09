; EXCEPT.ASM
; Author : Tom Barton           12 Sept 1995
; Based upon information on exception handlers obtained from
; the Borland support conference on Compuserve. See DPMXCP.ZIP

.286p
locals  @@
.model  large

extrn   _dobeep : far
extrn   PXEXIT  : far

; The PMRegs structure
PMRegs STRUC
_edi    dd      ?
_esi    dd      ?
_ebp    dd      ?
_res1   dd      ?
_ebx    dd      ?
_edx    dd      ?
_ecx    dd      ?
_eax    dd      ?
_flags  dw      ?
_es     dw      ?
_ds     dw      ?
_fs     dw      ?
_gs     dw      ?
_ip     dw      ?
_cs     dw      ?
_sp     dw      ?
_ss     dw      ?
ENDS

dataseg

exceptMsg          db      'GPA has handled the exception', 13, 10, 0
exceptPXExitMsg    db      'PXExit call succeeded', 13, 10, 0
_oldexceptionerror dd    0
public _oldexceptionerror

; Flag to prevent an endless loop of exceptions.  If non-zero when
; checked, a subsequent exception is routed to the original handler.
inExceptionHandler dw	0

codeseg

DataSel     dw      @data               ; Our data segment selector

; Not required at the moment
;_killer proc   far
;public  _killer
;; This function just causes a GPF to occur. The stack frame is:
;;       Ret CS
;;       Ret IP
;        xor     ax,ax
;        mov     es,ax
;        mov     ax,word ptr es:[exceptMsg]  ; causes an exception
;        retf
;endp

_exceptionerrorhandler proc
public  _exceptionerrorhandler
; This function is the Exception 0D (GPF) handler we will use.
; It outputs an information message (into error.log) and 
; attempts to shut down the Paradox engine.

; The stack frame is (all entries 16-bit):
;       SS              +14
;       SP              +12
;       flags           +10
;       CS              +8
;       IP              +6
;       ErrorCode       +4
;       Ret CS          +2
;       Ret IP          +0
;
; print a message to show we handled the exception
        push    es
        push    ds
        pusha
        mov     bp,sp

    	mov     ds, cs:[DataSel]    ; Point to the application's data segment.
                                    ; We arrive here on the server's locked
                                    ; stack so there is no need to switch stacks.

        ; Call the old handler if the exception handler has caused an exception.
        cmp     inExceptionHandler, 0
        jne     short OldHandler

        inc     inExceptionHandler

        mov     bx,offset exceptMsg
@@1:    mov     dl,byte ptr [bx]
        or      dl,dl
        jz      @@2
        mov     ah,2
        int     21h
        inc     bx
        jmp     short @@1
@@2:
; now call the Paradox shutdown routine
        call    far ptr PXEXIT
        or      ax,ax
        jnz     @@4                             ; ax clear for success
        mov     bx,offset exceptPXExitMsg       ; output message
@@3:    mov     dl,byte ptr [bx]
        or      dl,dl
        jz      @@4
        mov     ah,2
        int     21h
        inc     bx
        jmp     short @@3
@@4:
        dec     inExceptionHandler

OldHandler:
; restore registers and chain to old handler
        popa                        ; Restore the original register values.
        pop     ds
        pop     es

        push    ax                  ; create stack position for return address
        push    ax

        push    bp                  ; Save BP and get the base stack pointer.
        mov     bp, sp

        push    ds                  ; Save these for the original handler.
        push    ax
        push    bx

        mov     ds, cs:[DataSel]    ; Need our DS once again.

        mov     bx,offset _oldexceptionerror
        mov     ax, word ptr [bx + 2]   ; Create a "return" address.
        mov     word ptr [bp + 4], ax
        mov     ax, word ptr [bx]
        mov     word ptr [bp + 2], ax

        pop     bx                  ; Pop the saved values.
        pop     ax
        pop     ds
        pop     bp

        retf                        ; Jump to the original vector.
endp

end
;-----------------------------------------------------------------
; End of file EXCEPT.ASM
