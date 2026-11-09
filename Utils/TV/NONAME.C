#include <stdio.h>
#include <conio.h>
int (*fptr)(void);

int printit(void);

main() {
	fptr=getch;
	(*fptr)();
	fptr=printit;
	(*fptr)();
	return(1);
}
int printit(void) {
	printf("Hello\n");
	return(1);
}