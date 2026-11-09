#include <stdio.h>
#include <conio.h>

int (*fptr[20])(void);

int printit(void);

main() {
	fptr[0]=getch;
	fptr[1]=printit;

	(*fptr[1])();
	(*fptr[0])();

	return(1);
}
int printit(void) {
	printf("Hello\n");
	return(1);
}