.386p
segment SELFMOD_DATA 'DATA' use32
assume cs:SELFMOD_DATA
;
;  long test_function(void)
;
;  example of self-modifying code.  The function should return the
;  value 42424242 if the self-modifying code works properly

_test_function proc
  public _test_function

  push   esi
  mov    esi,offset modify
  mov    dword ptr [esi+1],42424242   ; modify the "mov eax,0" instruction
  pop    esi
  jmp    $+2     ; flush the pre-fetch queue, otherwise the unmodified
                 ; instruction (which is already in the queue) will
                 ; be executed
modify:
  mov  eax,0
  ret
endp
ends
end
