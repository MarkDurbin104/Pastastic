unit nsUtil;

interface

procedure NS_MEMCPY(dst: Pointer; const src: Pointer; size: Longword); register;

implementation

procedure NS_MEMCPY(dst: Pointer; const src: Pointer; size: Longword); register;
asm
  push edi
  push esi
  pushf

  mov edi, dst
  mov esi, src
  mov ecx, size
  mov eax, ecx
  and eax, 3
  shr ecx, 2
  cld

  test ecx, ecx
  jz @@no_dword

  rep movsd

@@no_dword:
  mov ecx, eax
  test ecx, ecx
  jz @@no_byte

  rep movsb

@@no_byte:
  popf
  pop esi
  pop edi
end;

end.
