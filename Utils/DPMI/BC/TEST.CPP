// self-modifying code example
//
// compile with "BCC32 -WX test selfmod.asm"
//
#include <stdio.h>

extern "C" long test_function( void );  // defined in selfmod.asm

int main(void) {
  long x;
  x = test_function();
  printf(" x = %ld\n",x);
  return 0;
}
