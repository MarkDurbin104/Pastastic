/* Example of Function Nesting in High C
   compile: HC386 LIST31.C */

#include <stdio.h>

main()
  {
  /* nested function */
  void sayhello()
    {
    printf("Hello\n");
    }
  sayhello();   /* references local sayhello() */
  external();
  }

void sayhello()
  {
  printf("Howdy!\n");
  }

external()
  {
  sayhello();  /* references global sayhello(); */
  }
