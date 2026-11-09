/***********************************************************************
*
*   File:           vmkbmcr.c
*
*   Purpose:        VM interface to ECCO+ KB, MCR
*
*   Author:         Paul Encarnacion
*                   Unisys, EISG, Postal Programs
*                   5151 Camino Ruiz
*                   Camarillo, CA 93010
*                   (805)987-6811 
*
*   Date of Origin: 12-11-1990
*
*   Copyright (c) 1990  Unisys Corporation
*
*   $Log:   Z:\CM\F\BPO\DVT\VCS\VMKBMCR.C_V  $
*  
*     Rev 1.2   11 Jan 1991 17:48:38   AJW
*  New completly rebuilt version.
*  
*     Rev 1.1   07 Jan 1991 14:53:56   PJE
*  Added function to decode MCR data into ANSI characters, and modified
*  functions for readtrack and swipe.
*  
*  
*     Rev 1.0   13 Dec 1990 16:34:28   PJE
*  
***********************************************************************/
#include <dos.h>
#include <stdio.h>
#include <fcntl.h>
#include <memory.h>
#include <bios.h>

#define DEVICE          "$CT_KBD$"

#define  CMD_BUZZER     0
#define  CMD_TYPEMATIC  1
#define  CMD_SWIPE      2
#define  CMD_READ_1     3
#define  CMD_READ_2     4
#define  CMD_READ_3     5

#define  NAK            0xfe
#define  ACK            0xfa
#define  TERMINATOR     0xfa
#define  BEEP	        0xf9
#define  READCARD       0xfb
#define  TRACK1         0xf0
#define  TRACK2         0xf1
#define  TRACK3         0xf2

struct ioctl_packet {
    int command;
    int status;
    char buffer[128];
};

/*
    Track 1 Alphanumeric character set (ANSI/ISO Standards)
    6 bits plus odd parity
    (the MCR strips parity and pads the upper two bits with zero)
*/
static char track_1_chars[] = {
    ' ','!','"','#','$','%','&','/','(',')','*','+','\'','-','.','/',
    '0','1','2','3','4','5','6','7','8','9',':',';','<','=','>','?',
    '@','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O',
    'P','Q','R','S','T','U','V','W','X','Y','Z','[','\\',']','^','-'
};

/*
    Track 2 and 3 character set (ANSI/ISO Standards)
    BCD 4-bit character set plus parity
    (the MCR strips parity and pads the upper 4 bits with zero)
    note that A-F codes will not be used to represent data
*/
static char track_23_chars[] = {
    '0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'
};

static unsigned char mcrcode[256] = {
0xfe,0x76,0x16,0x1e,0x26,0x25,0x2e,0x36,0x3d,0x3e,0x46,0x45,0x4e,0x55,0x66,0x0d,
0x15,0x1d,0x24,0x2d,0x2c,0x35,0x3c,0x43,0x44,0x4d,0x54,0x5b,0x5a,0x14,0x1c,0x1b,
0x23,0x2b,0x34,0x33,0x3b,0x42,0x4b,0x4c,0x52,0x0e,0x12,0x5d,0x1a,0x22,0x21,0x2a,
0x32,0x31,0x3a,0x41,0x49,0x4a,0x59,0x7c,0x11,0x29,0x58,0x05,0x06,0x04,0x0c,0x03,
0x0b,0x02,0x0a,0x01,0x09,0x77,0x7e,0x6c,0x75,0x7d,0x7b,0x6b,0x73,0x74,0x79,0x69,
0x72,0x7a,0x70,0x71,0x7f,0x60,0x61,0x78,0x07,0x0f,0x17,0x1f,0x27,0x2f,0x37,0x3f,
0x47,0x4f,0x56,0x5e,0x08,0x10,0x18,0x20,0x28,0x30,0x38,0x40,0x48,0x50,0x57,0x6f,
0x13,0x19,0x39,0x51,0x53,0x5c,0x5f,0x62,0x63,0x64,0x65,0x67,0x68,0x6a,0x6d,0x6e,
0x80,0x81,0x82,0x83,0x84,0x85,0x86,0x87,0x88,0x89,0x8a,0x8b,0x8c,0x8d,0x8e,0x8f,
0x90,0x91,0x92,0x93,0x94,0x95,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,0x9d,0x9e,0x9f,
0xa0,0xa1,0xa2,0xa3,0xa4,0xa5,0xa6,0xa7,0xa8,0xa9,0xaa,0xab,0xac,0xad,0xae,0xaf,
0xb0,0xb1,0xb2,0xb3,0xb4,0xb5,0xb6,0xb7,0xb8,0xb9,0xba,0xbb,0xbc,0xbd,0xbe,0xbf,
0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0xcb,0xcc,0xcd,0xce,0xcf,
0xd0,0xd1,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf,
0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0xed,0xee,0xef,
0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,0xf6,0xf7,0xf8,0xf9,0xfa,0xfb,0xfc,0xfd,0xfe,0x00
};


static void keyflush(void);

static void keyflush(void)
{
	ticks(5);      // delay(250);
	while ((inp(0x64)&0x1) == 0x1) {
		(void)inp(0x60);
		ticks(1);  // delay(50);
	}
}

/***********************************************************************
*
*   Function:   decode_track
*
*   Purpose:    decodes a buffer of data into the proper codes
*
*   Arguments:  track number (0 = Track 1; 1 = Track 2;  2 = Track 3)
*               buffer to convert
*               length of buffer
*
*   Returns:    buffer modified with converted characters
*               return value = 1 if call was successful
*                            = 0 if parameters were invalid
*
***********************************************************************/
int decode_track (int track, char *buffer, int buflen)
{
    register int i;
    auto char *table;
    int upper_limit;

    switch (track)
    {
        case 0:
            table = track_1_chars;
            upper_limit = 64;
            break;
        case 1:
        case 2:
            table = track_23_chars;
            upper_limit = 16;
            break;
        default:
            return (0);
    }
    
    if (buffer == NULL) return (0);

    for (i = 0; i < buflen; i++)
    {
        if ((buffer[i] < 0) || (buffer[i] >= upper_limit))
            buffer[i] = '*';
        else
            buffer[i] = table[buffer[i]];
    }

    return (1);
}

/***********************************************************************
*
*   Function:   kbd_buzz
*
*   Purpose:    activates the keyboard buzzer
*
*   Arguments:  none
*
*   Returns:    1   if call was successful
*               0   if unable to access driver
*
***********************************************************************/
int kbd_buzz ()
{
    int fh;
    int result;

    result = 1;
    _disable();
	while ((inp(0x64)&0x2) == 0x2); // wait for input buffer empty
	outp(0x60, BEEP);
  	while ((inp(0x64)&0x1) == 0);   // wait for output buffer full
    inp(0x60);                      // get ACK back
	_enable();

    return (result);
}
int ticks(unsigned int ticks)
{
    union REGS regs;

    regs.x.ax=0x0703;
    regs.x.bx=ticks;
    int86(0xD4,&regs,&regs);

    if (regs.x.cflag) return(regs.x.ax);

    return(0);
}

/***********************************************************************
*
*   Function:   mcr_swipe
*
*   Purpose:    Instructs MCR to accept a card swipe
*
*   Arguments:  none
*
*   Returns:    1   if MCR detected a card swipe
*               0   if a key aborted the swipe opertion
*               -1  if unable to access the device
*
***********************************************************************/
int mcr_swipe ()
{
	unsigned char ch;
    int result;

    keyflush();
	_disable();

	while ((ch = (inp(0x64)) & 0x2) == 0x2);
	outp(0x60, READCARD);

	while ((ch = (inp(0x64)) & 0x1) == 0);
	ch = inp(0x60);
	while ((ch = (inp(0x64)) & 0x1) == 0);
	ch = inp(0x60);

	switch(ch) {
		case ACK :
			result = 1;
			break;
		case NAK :
			result = 0;
			break;
		default: 
			result = -1;
	}

    keyflush();
	_enable();
	delay_ticks(18);  // delay(1000);
    
    return (result);
}

/***********************************************************************
*
*   Function:   mcr_readtrack
*
*   Purpose:    instructs MCR to send data for track specified
*
*   Arguments:  int track       - track to read 0, 1 or 2
*               uchar *buffer   - buffer for data
*               int *count      - max characters to read / characters read
*
*   Returns:    1   if track was read properly
*               0   if no data or error reading track
*
*               buffer filled in
*               character count filled in
*
*   Note:       When calling this function, it is important to note
*   =====       that count should be initialized to the maximum
*               characters that the buffer can accommodate.
*
***********************************************************************/
int mcr_readtrack (int track, unsigned char *buffer, int *count)
{
    int    n,  result;
    unsigned char  ch;

    result = 0;
    keyflush();
    
    if ((track >= 0) && (track < 3))
    {
    	_disable();
		while ((ch = (inp(0x64)) & 0x2) == 0x2);
		outp(0x60, (unsigned char)(TRACK1 + track));

        while ((ch = (inp(0x64)) & 0x1) == 0);
		ch = inp(0x60);
		if (ch == NAK) {
			delay_ticks(1);  // delay(10);
			while ((ch = (inp(0x64)) & 0x1) == 0x1) ch = inp(0x60);
		}
        n = 0;
		switch(ch) {
			case ACK :
                do {
					while ((ch = (inp(0x64)) & 0x1) == 0);
					ch = mcrcode[inp(0x60)];
					if (ch != TERMINATOR)
					{
                        if (n < *count)
    					    buffer[n++] = ch;
					}
				} while (ch != TERMINATOR);

                while (_bios_keybrd(_KEYBRD_READY))
                    _bios_keybrd(_KEYBRD_READ);

                result = 1;
				break;
			case NAK :
				break;
			default:
                keyflush();
                break;
		}
        *count = n;
		_enable();
    }

    return (result);
}


