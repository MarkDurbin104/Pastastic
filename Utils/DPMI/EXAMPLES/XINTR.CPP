//
// (C) Copyright 1992 Qualitas, Inc.  All rights reserved.
//
// xintr.cpp - example usage of interrupt classes in DPMI class library
//

#include <iostream.h>
#include <iomanip.h>
#include <dos.h>
#include "dpmihost.h"
#include "dpmiint.h"

InterruptHandler* pTimerHandler;	// pointer to timer handler object
RealInterruptHandler* pKeyboardHandler; // pointer to keybd handler object

void click(void);
void speakerOn(uShort);
void speakerOff(void);

unsigned volatile nTicks=0;
unsigned volatile nKeys=0;

//
// This is the protected mode timer tick interrupt handler
//
void  tickHandler(dpmiRegs_t iFrame)
{
	pTimerHandler->callPrevious(iFrame);
	nTicks++;				// inc tick counter
	speakerOff();
}

//
// This is the real mode keyboard interrupt handler
//
void keybHandler(dpmiRegs_t iFrame)
{
	pKeyboardHandler->callPrevious(iFrame);

	nKeys++;		// inc key counter

	if (nKeys % 2)		// make a click every other interrupt
		click();
}

//
// Interrupt test.  This function creates a protected mode timer tick
// handler and a real mode keyboard interrupt handler.  The example
// counts the number of ticks and keystrokes that occur during the
// input of a string.
//
void TestInterrupts(void)
{
	char buf[256];

	// install protected mode timer tick handler
	pTimerHandler    = new InterruptHandler(8, tickHandler);

	// install real mode keyboard interrupt handler
	pKeyboardHandler = new RealInterruptHandler(9, keybHandler);

	cout << "Enter your name: ";
	nTicks = 0;
	nKeys = 0;
	cin >> buf;

	// unhook handlers
	delete pTimerHandler;
	delete pKeyboardHandler;
	speakerOff();

	cout << "It took you " << (nTicks*10)/182 << "." 
	     <<  ((nTicks*100)/182) % 10 << " seconds and " << nKeys/2 
	     << " keystrokes\n";
}

void main(void)
{
	DPMIhost dpmi;

	if (dpmi.getStatus() == DPMIok)
	{
		dpmi.enterProtectedMode();
		TestInterrupts();
	}
	else
		cout << "DPMI host not present\n";
}
	

void speakerOn(uShort freq)
{
	_asm in  al, 61h
	_asm test al, 3
	_asm jnz setF
	_asm or  al, 3
	_asm out 61h, al
setF:
	_asm mov dx, freq
	_asm mov al, 0b6h
	_asm out 43h, al
	_asm mov al, dl
	_asm out 42h, al
	_asm mov al, dh
	_asm out 42h, al
}

void speakerOff(void)
{
	_asm in  al, 61h
	_asm and al, 0fch
	_asm out 61h, al
}

void click(void)
{
	unsigned ticks = nTicks;

	ticks = nTicks;
	_asm sti

	while (ticks == nTicks)
		;
	speakerOn(0x9000);
}

