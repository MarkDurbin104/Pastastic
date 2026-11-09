.386
.model flat,c

.data

extrn  ticks:dword
extrn  dataseg:word
extrn  oldhandler:fword

.code

handler proc far
   public handler

   push ds
   push eax
   mov  ds,cs:[dataseg]
   mov  eax,[ticks]
   inc  eax
   mov  [ticks],eax
   pop  eax
   pop  ds

   jmp  cs:fword ptr [oldhandler]

handler endp

end
