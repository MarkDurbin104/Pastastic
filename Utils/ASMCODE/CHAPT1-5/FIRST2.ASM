;
;       Program First2
;
.MODEL   SMALL
.CODE
         INCLUDE  MACLIB.INC
Begin:   MOV      BX,0
         InpInt   BX                           
         MOV      CX,BX
         InpInt   BX
         PUSH     CX       ; place first argument onto stack
         PUSH     BX       ; place second argument onto stack
         CALL   AddShow
Finish:  MOV      AX,4C00h
         INT      21h         
;--------------------------
;   Procedure section
;--------------------------
AddShow  PROC              ; adds summands and  display results 
         PUSH     BP       ; Save BP
         MOV      BP,SP    ;       
         MOV      CX,[BP+6]
         MOV      BX,[BP+4]
         ADD      BX,CX
         OutInt   BX
         POP      BP
         RET      4
AddShow  ENDP
;---------------------------
;End of Procedure Section
;---------------------------
.DATA
.STACK
         END      Begin
