#define START_C
#include <dos.h>
#include <stdarg.h> 
#include <process.h>
#include <stdio.h>
		 
#include "types.h"
#include "mouse.h"

void msecall(void);

INT main(INT argc,CHAR *argv[])
{
	if (argc<2) {
		printf("Needs system arg");
		return(1);
	}
	else
	{
		spawnl(P_WAIT, "d:\\bc4\\bin\\td.exe", "d:\\bc4\\bin\\td.exe", "d:\\tompad\\gpad16.exe", /*"d:\\tompad\\gpad16.exe",*/ *argv[1], msecall, NULL);
		return (0);
	}
}

void msecall(void)
{
	printf ("In real mode");
}
