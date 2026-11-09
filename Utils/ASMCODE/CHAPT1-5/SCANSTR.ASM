;
;       Program ScanStr
;
.model tiny
.stack
.data
StrSc   byte    'ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
.code
	include maclib.inc
.startup
	lea     di,StrSc
	mov     cx,LengthOf StrSc
	mov     dx,cx
	cld
	mov al,es:[82h]
repne   scasb
	NewLine
	.IF ZERO?
	OutMsg  'Character found the position '
	sub     dx,cx
	add     dx,40h
	OutInt  dx
	.ELSE
	OutMsg 'Character not found'
	.ENDIF
	Newline 
	.exit   0
	end
