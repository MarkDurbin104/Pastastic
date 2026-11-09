/**
*
*		title:		 dvtprint.c
*
*		purpose:		perform commands in script file
*
*		author:			David G. Lawrence
*						Ventura Micro, Inc.
*						200 South 'A' Street, Suite 208
*						Oxnard, CA  93030
*						(805) 486-6686
*
*		Copyright (C) by Ventura Micro, Inc. 1990, as an unpublished
*		work.  All rights reserved.  Contains confidential information
*		and trade secrets proprietary to Ventura Micro, Inc.
*		Disassembly or decompilation prohibited.
*
*		$Log:   Z:\CM\F\BPO\DVT\VCS\DVTPRINT.C_V  $
*  
*     Rev 1.2   11 Jan 1991 17:59:16   AJW
*  Adapted to new DVT test versions called "Utility" and "Factory"
*  
*     Rev 1.1   03 Jan 1991 16:39:26   AJW
*  Extended Location test.
*  
*     Rev 1.0   10 Dec 1990 10:36:30   PJE
*  Initial revision.
*
*
**/

/**
*
*		Includes
*
**/

#include	<conio.h>
#include	<ctype.h>
#include	<dos.h>
#include	<fcntl.h>
#include	<io.h>
#include	<stdio.h>
#include	<stdlib.h>
#include	<string.h>
#include	<time.h>

//#include <vv_sys.h>                             /* Vermont Views header file */
#include "eccodefs.h"
#include "globals.h"
#include "dvtmsgs.h"
#include "bpokeys.h"

/**
*
*		Definitions
*
**/

//#define     FALSE			0         redefined in VV_SYS.H
//#define		TRUE			(!FALSE)  

// SUCCESS changed to X_SUCCESS - redefined in VV_SYS.H
#define		X_SUCCESS	0			// Script file processed successfully
#define		BAD_SCR_UP 	1			// Improper number of command line args
#define		BAD_OPEN		2			// Unable to open script file
#define		BAD_READ		3			// Error reading from script file

#define		QUIT			-1			// Exit script file processing

#define		BAUD_9600		0xE0	// Baud rate definitions
#define		BAUD_4800		0xC0
#define		BAUD_2400		0xA0
#define		BAUD_1200		0x80
#define		BAUD_600		   0x60
#define		BAUD_300		   0x40
#define		BAUD_150		   0x20
#define		BAUD_110		   0x00

#define		PARITY_NONE		0x00	// Parity definitions
#define		PARITY_ODD		0x08
#define		PARITY_EVEN		0x18

#define		STOP_1_BIT		0x00	// Stop bit definitions
#define		STOP_2_BITS		0x04

#define		LENGTH_7_BITS	0x02	// Length definitions
#define		LENGTH_8_BITS	0x03

#define		DEF_PORT		0
#define		DEF_RATE		BAUD_1200
#define		DEF_PARITY	PARITY_NONE
#define		DEF_LENGTH	LENGTH_8_BITS
#define		DEF_STOP		STOP_2_BITS

#define		DIM(a)			(sizeof(a) / sizeof(a[0]))

#define		VAR_WORD		0
#define		VAR_STRING	1
#define		VAR_DATE		2
#define		VAR_TIME		3

typedef		unsigned char	BYTE;
typedef		unsigned short	WORD;
typedef		unsigned long	DWORD;

typedef		unsigned short	BOOL;
//typedef		unsigned char	UCHAR;   redefined in Vermont Views


/**
*
*		Structures
*
**/

typedef struct cmd_entry {		// Commands
	UCHAR	*szCmd;					// ASCII description command
	int	(*pfnCmd)();			// Pointer to function processing command
} CMD_ENTRY;

typedef struct const_entry {	// Constants
	UCHAR *szConst;				// ASCII desciption of constant
	BYTE 	bConst;					// Constant value
} CONST_ENTRY;

typedef struct var_entry {		// Data variables
	UCHAR	*szVar;					// ASCII desciption of data
	WORD  wType;					// Type of data
	void	*pVar;					// Pointer to data storage
} VAR_ENTRY;

typedef struct access_entry { 	// Variable type manipulation
	void	*(*pfnGetPtr)(int);			// Get pointer to variable
	void	(*pfnSetVar)(int, void *);	// Set value of variable
	WORD	(*pfnGetWord)(int);			// Get word value of variable
	void	*(*pfnGetStr)(int);			// Get string representation
} ACCESS_ENTRY;


/**
*
*		Externals
*
**/

										// Main functions
int printer_test(void);

										// Command functions
static int DoCLS(UCHAR *szLine);
static int DoDisplay(UCHAR *szLine);
static int DoGotoXY(UCHAR *szLine);
static int DoInput(UCHAR *szLine);
static int DoMode(UCHAR *szLine);
static int DoOutput(UCHAR *szLine);
static int DoPause(UCHAR *szLine);
static int DoRemark(UCHAR *szLine);
static int DoStatus(UCHAR *szLine);
static int DoQuit(UCHAR *szLine);

									// Data manipulation routines

static WORD *GetWordPtr(int iIndex);
static UCHAR *GetStrPtr(int iIndex);
static struct dosdate_t *GetDatePtr(int iIndex);
static struct dostime_t *GetTimePtr(int iIndex);

static void SetWord(int iIndex, WORD *wWord);
static void SetStr(int iIndex, UCHAR *pStr);
static void SetDate(int iIndex, struct dosdate_t *pDate);
static void SetTime(int iIndex, struct dostime_t *pTime);

static WORD GetWord(int iIndex);
static WORD GetNULL(int iIndex);

static UCHAR *GetWordStr(int iIndex);
static UCHAR *GetStr(int iIndex);
static UCHAR *GetDateStr(int iIndex);
static UCHAR *GetTimeStr(int iIndex);


/**
*
*		Global Data
*
**/

extern WINDOWPTR wnp;
static UCHAR pScriptName[] = "PRINTER.TST";
static UCHAR szTokens[]    = " ,\n\t";

CMD_ENTRY Commands[] = {
	{	"CLS", 			DoCLS		},
	{	"DISPLAY",		DoDisplay	},
	{	"GOTOXY",		DoGotoXY	},
	{	"INPUT",		   DoInput		},
	{	"MODE",			DoMode		},
	{	"OUTPUT",		DoOutput	},
	{	"PAUSE",		   DoPause		},
	{	"STATUS",		DoStatus	},
	{	"#",			   DoRemark	},
	{	"QUIT",			DoQuit		}
};

CONST_ENTRY Constants[] = {
	{  	"E",			PARITY_EVEN	},
	{  	"N",			PARITY_NONE	},
	{  	"O",			PARITY_ODD	},
	{  	"9600",			BAUD_9600	},
	{  	"4800",			BAUD_4800	},
	{  	"2400",			BAUD_2400	},
	{  	"1200",			BAUD_1200	},
	{  	"600",			BAUD_600	},
	{  	"300",			BAUD_300	},
	{  	"150",			BAUD_150	},
	{  	"110",			BAUD_110	},
	{	"<BEL>",		'\a'		},
	{	"<BS>",			'\b'		},
	{	"<CR>",			'\r'		},
	{	"<ESC>",		'\x01B'		},
	{	"<HT>",			'\t'		},
	{	"<LF>",			'\n'		},
	{	"<NUL>",		'\0'		},
	{	"<SUB>",		'\x01A'		},
	{	"<VT>",			'\v'		},
	{	"<FF>",			'\f'		},
};

static WORD wData;							// DATA data
static WORD wKey;							// KEY data
static WORD wStatus;						// STATUS data

static struct dosdate_t CurDate;			// Current date
static struct dostime_t CurTime;			// Current time

VAR_ENTRY Variables[] = {
	{	"DATA",			VAR_WORD, 		&wData		},
	{	"DATE",			VAR_DATE,		&CurDate	},
	{	"KEY",			VAR_WORD,		&wKey		},
	{	"STATUS",		VAR_WORD,		&wStatus	},
	{	"TIME",			VAR_TIME,		&CurTime	},
};

ACCESS_ENTRY Access[] = {
	{GetWordPtr,	SetWord,	GetWord,	GetWordStr},	// VAR_WORD
	{GetStrPtr,		SetStr,		GetNULL,	GetStr},   		// VAR_STRING
	{GetDatePtr,	SetDate,	GetNULL,	GetDateStr},	// VAR_DATE
	{GetTimePtr,	SetTime,	GetNULL,	GetTimeStr},	// VAR_TIME
};


/**
*
*		function:		GetWordPtr()
*
*		purpose:		Get pointer to word variable
*
*		arguments:		int iIndex = index to variable in Variables table
*
*		returns:		pointer to word
*
**/

static WORD *GetWordPtr(int iIndex)

{
	return((WORD *)Variables[iIndex].pVar);
}


/**
*
*		function:		GetStrPtr()
*
*		purpose:		Get pointer to string variable
*
*		arguments:		int iIndex = index to variable in Variables table
*
*		returns:		pointer to string
*
**/

static UCHAR *GetStrPtr(int iIndex)

{
	return((UCHAR *)Variables[iIndex].pVar);
}


/**
*
*		function:		GetDatePtr()
*
*		purpose:		Get pointer to date variable
*
*		arguments:		int iIndex = index to variable in Variables table
*
*		returns:		pointer to date
*
**/

static struct dosdate_t *GetDatePtr(int iIndex)

{
	return((struct dosdate_t *)Variables[iIndex].pVar);
}


/**
*
*		function:		GetTimePtr()
*
*		purpose:		Get pointer to time variable
*
*		arguments:		int iIndex = index to variable in Variables table
*
*		returns:		pointer to time
*
**/

static struct dostime_t *GetTimePtr(int iIndex)

{
	return((struct dostime_t *)Variables[iIndex].pVar);
}


/**
*
*		function:		SetWord
*
*		purpose:		Set word variable
*
*		arguments:		int iIndex = index of variable in Variables
*						WORD *pWord = pointer to word value
*
*		returns:		nothing
*
**/

void SetWord(int iIndex, WORD *pWord)

{
	*(WORD *)Variables[iIndex].pVar = *pWord;
}


/**
*
*		function:		SetStr
*
*		purpose:		Set string variable
*
*		arguments:		int iIndex = index of variable in Variables
*						UCHAR *pStr = pointer to string
*
*		returns:		nothing
*
**/

void SetStr(int iIndex, UCHAR *pStr)

{
	strcpy((UCHAR *)Variables[iIndex].pVar, pStr);
}


/**
*
*		function:		SetDate
*
*		purpose:		Set date variable
*
*		arguments:		int iIndex = index of variable in Variables
*						struct dosdate_t *pDate = pointer to date structure
*
*		returns:		nothing
*
**/

void SetDate(int iIndex, struct dosdate_t *pDate)

{
	*(struct dosdate_t *)Variables[iIndex].pVar = *pDate;
}


/**
*
*		function:		SetTime
*
*		purpose:		Set Tiee variable
*
*		arguments:		int iIndex = index of variable in Variables
*						struct dostime_t *pTime = pointer to Time structure
*
*		returns:		nothing
*
**/

void SetTime(int iIndex, struct dostime_t *pTime)

{
	*(struct dostime_t *)Variables[iIndex].pVar = *pTime;
}


/**
*
*		function:		GetWord()
*
*		purpose:		Retrieve word type data
*
*		arguments:		index into variable array
*
*		returns:		word 
*
**/

static WORD GetWord(int iIndex)

{
	return (*(WORD *)(Variables[iIndex].pVar));
}


/**
*
*		function:		GetNULL()
*
*		purpose:		Placeholder for variables which don't support GetWord
*
*		arguments:		index into variable array
*
*		returns:		0
*
**/

static WORD GetNULL(int iIndex)

{
	return (0);
}


/**
*
*		function:		GetWordStr()
*
*		purpose:		Return word variable as string
*
*		arguments:		index into variable array
*
*		returns:		pointer to static string
*
**/

static UCHAR *GetWordStr(int iIndex)

{
	static UCHAR szStr[5];

	sprintf(szStr, "%04X", *(WORD *)(Variables[iIndex].pVar));
	return(szStr);
}


/**
*
*		function:		GetStr()
*
*		purpose:		Return pointer to string variable
*
*		arguments:		index into variable array
*
*		returns:		pointer to static string
*
**/

static UCHAR *GetStr(int iIndex)

{
	return((UCHAR *)Variables[iIndex].pVar);
}


/**
*
*		function:		GetDateStr()
*
*		purpose:		Return pointer to string containing current date
*
*		arguments:		index into variables tables
*
*		returns:		pointer to static date string
*
**/

static UCHAR *GetDateStr(int iIndex)

{
	struct dosdate_t *date;
	static UCHAR szCurDate[9];

	date = (struct dosdate_t *)Variables[iIndex].pVar;

	_dos_getdate(date);
	sprintf(szCurDate, "%02d-%02d-%02d",
							date->month, date->day, date->year - 1900);

	return (szCurDate);
}


/**
*
*		function:		GetTimeStr()
*
*		purpose:		Return pointer to string containing time variable
*
*		arguments:		index into variables tables
*
*		returns:		pointer to static time string
*
**/

UCHAR *GetTimeStr(int iIndex)

{
	struct dostime_t *time;
	static UCHAR szCurTime[9];
	UCHAR szAMPM[3];
	WORD wHour, wMinute;

	time = (struct dostime_t *)Variables[iIndex].pVar;
	_dos_gettime(time);

	wHour = time->hour;
	wMinute = time->minute;

	if (wHour >= 12) {
		wHour -= 12;
		strcpy(szAMPM, "PM");
	} else {
		strcpy(szAMPM, "AM");
	}
	if (wHour == 0)
		wHour = 12;

	sprintf(szCurTime, "%02d:%02d %s", wHour, wMinute, szAMPM);

	return (szCurTime);
}


/**
*
*		function:		LookupCmd()
*
*		purpose:		Return index of command in command table
*
*		arguments:		UCHAR *szCmd = Pointer to possible command
*
*		returns:		int index into command table, -1 if not found
*
**/

static int LookupCmd(UCHAR *szCmd)

{
	int i;
	int iIndex;

	// Shift lowercase to upper for string compare

	strupr(szCmd);

	// Attempt to find command

	for (i = 0, iIndex = -1; (i < DIM(Commands)) && (iIndex == -1); i++)
		if (strcmp(szCmd, Commands[i].szCmd) == 0)
			iIndex = i;

	// Return result of search, -1 if command not found

	return (iIndex);
}


/**
*
*		function:		LookupConst()
*
*		purpose:		Return index of constant in constant table
*
*		arguments:		UCHAR *szConst = Pointer to possible constant
*
*		returns:		int index into constant table, -1 if not found
*
**/

static int LookupConst(UCHAR *szConst)

{
	int i;
	int iIndex;

	// Shift lowercase to upper for string compare

	strupr(szConst);

	// Attempt to find constant

	for (i = 0, iIndex = -1; (i < DIM(Constants)) && (iIndex == -1); i++)
		if (strcmp(szConst, Constants[i].szConst) == 0)
			iIndex = i;

	// Return result of search, -1 if command not found

	return (iIndex);
}


/**
*
*		function:		LookupVar()
*
*		purpose:		Return index of variable in variable table
*
*		arguments:		UCHAR *szVar = Pointer to possible variable
*
*		returns:		int index into variable table, -1 if not found
*
**/

static int LookupVar(UCHAR *szVar)

{
	int i;
	int iIndex;

	// Shift lowercase to upper for string compare

	strupr(szVar);

	// Attempt to find variable

	for (i = 0, iIndex = -1; (i < DIM(Variables)) && (iIndex == -1); i++)
		if (strcmp(szVar, Variables[i].szVar) == 0)
			iIndex = i;

	// Return result of search, -1 if command not found

	return (iIndex);
}


/**
*
*		function:		XlatChar
*
*		purpose:		Translate character
*
*		arguments:		UCHAR *pChar = pointer to char to possible translate
*
*		returns:		new pointer to char
*
**/

UCHAR *XlatChar(UCHAR *pChar)

{
	UCHAR cChar;
	UCHAR *szEnd;
	UCHAR *pXlatStr;
	UCHAR *pXlat;
	UCHAR *pRet;
	int i;
	int iLen;
	unsigned int iRet;

	pRet = pChar;			// Default to return same string

	if (szEnd = strchr(pChar, '>')) {

		iLen = (szEnd - pChar) + 1;
		if (pXlatStr = calloc(iLen + 1, sizeof(UCHAR))) {
			strncpy(pXlatStr, pChar, iLen);
			strupr(pXlatStr);

			if (isdigit(pXlatStr[1]) && (iLen > 2)) {	// Number to convert ?
				pXlat = &pXlatStr[1];
				pXlat[iLen - 2] = '\0';				// Remove '>'
				iRet = 0;							// Clear return value
				switch (pXlat[iLen - 3]) {
					case 'B':
						pXlatStr[iLen - 2] = '\0';
						while (cChar = *pXlat) {
							if (isdigit(cChar)) {
								iRet <<= 1;
								iRet += cChar == '1' ? 1 : 0;
								pXlat++;
							} else
								*pXlat = '\0';
						}
						break;
					case 'H':
						pXlatStr[iLen - 2] = '\0';
						while (cChar = *pXlat) {
							if (isxdigit(cChar)) {
								iRet *= 16;
								iRet += cChar <= '9' ? cChar - '0' : (cChar - 'A') + 10;
							 	pXlat++;
							} else
								*pXlat = '\0';
						}
						break;
					default:
						iRet = atoi(pXlat);
						break;
				}
				pRet = szEnd;
				*pRet = (UCHAR)iRet;
			} else {
				if ((i = LookupConst(pXlatStr)) != -1 ) {
					pRet = szEnd;
					*pRet = Constants[i].bConst;
				}
			}
			free(pXlatStr);
		}
	}
	return (pRet);
}


/**
*
*		function:		GetPort()
*
*		purpose:		translate port name to port number
*
*		arguments:		pointer to port string
*
*		returns:		port number, 0 ... 3,  -1 if error
*
**/

WORD GetPort(UCHAR *pszPort)

{
	WORD wPort;
	strupr(pszPort);

	if (pszPort[0] != '\0') {

		if ((strncmp(pszPort, "COM", 3) == 0) && (strlen(pszPort) > 3)) {
			wPort = (pszPort[3] - '0') - 1;
			if ((wPort < 0) || (wPort > 3))
				wPort = -1;
		} else
			wPort = -1;
	} else
		wPort = DEF_PORT;

	return (wPort);
		
}


/**
*
*		function:		GetRate()
*
*		purpose:		translate rate to bit map for init
*
*		arguments:		pointer to rate
*
*		returns:		rate bit definition or -1 if invalid rate
*
**/

BYTE GetRate(UCHAR *pszRate)

{
	int i;
	BYTE bRate;

	if (*pszRate == '\0')

		bRate = DEF_RATE;

	else {

		if ((i = LookupConst(pszRate)) != - 1)
			bRate = Constants[i].bConst;
		else
			bRate = -1;
	}


	// Return result of search, -1 if rate not found

	return (bRate);
}


/**
*
*		function:		GetParity()
*
*		purpose:		translate parity to bit map for init
*
*		arguments:		pointer to parity
*
*		returns:		parity bit definition or -1 if invalid parity
*
**/

BYTE GetParity(UCHAR *pszParity)

{
	int i;
	BYTE bParity;

	if (*pszParity == '\0')
		bParity = DEF_PARITY;
	else {

		if ((i = LookupConst(pszParity)) != - 1)
			bParity = Constants[i].bConst;
		else
			bParity = -1;
	}

	// Return result of search, -1 if rate not found

	return (bParity);

}


/**
*
*		function:		GetStop()
*
*		purpose:		translate stop to bit map for init
*
*		arguments:		pointer to stop
*
*		returns:		stop bit definition or -1 if invalid stop
*
**/

BYTE GetStop(UCHAR *pszStop)

{
	int i;
	BYTE bStop;

	if (*pszStop == '\0')
		bStop = DEF_STOP;
	else {
		switch (*pszStop) {
			case '1':
				bStop = STOP_1_BIT;
				break;

			case '2':
				bStop = STOP_2_BITS;
				break;

			default:
				bStop = -1;
		}
	}
	return (bStop);
}


/**
*
*		function:		GetLength()
*
*		purpose:		translate length to bit map for init
*
*		arguments:		pointer to length
*
*		returns:		length bit definition or -1 if invalid length
*
**/

BYTE GetLength(UCHAR *pszLength)

{
	int i;
	BYTE bLength;

	if (*pszLength == '\0')
		bLength = DEF_LENGTH;
	else {
		switch (*pszLength) {
			case '7':
				bLength = LENGTH_7_BITS;
				break;

			case '8':
				bLength = LENGTH_8_BITS;
				break;

			default:
				bLength = -1;
		}
	}
	return (bLength);
}


/**
*
*		function:		DoCLS()
*
*		purpose:		Clear screen
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoCLS(UCHAR *szLine)

{
/*	BYTE bAttr;
	BYTE bMaxRows;
	BYTE bNumCols;
	BYTE bPage;
	union REGS inregs, outregs;

	bMaxRows = *((BYTE far *)(0x0484L));	 /= Get maximum row and number of cols
	bNumCols = *((BYTE far *)(0x044AL));

	inregs.h.ah = 0x0f;						/= Get current page
	int86(0x10, &inregs, &outregs);
	bPage = outregs.h.bh;

	inregs.h.ah = 8;						/= Get current attribute
	inregs.h.bh = bPage;
	int86(0x10, &inregs, &outregs);
	bAttr = outregs.h.ah;

	inregs.h.ah = 6;						/= Clear screen
	inregs.h.al = 0;
	inregs.h.bh = bAttr;
	inregs.h.ch = 0;
	inregs.h.cl = 0;
	inregs.h.dh = bMaxRows;
	inregs.h.dl = bNumCols - 1;
	int86(0x10, &inregs, &outregs);
*/
   wn_clr(wnp);
   return (X_SUCCESS);

}


/**
*
*		function:		DoDisplay()
*
*		purpose:		Write string to screen
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoDisplay(UCHAR *szLine)

{                      	
	int i;
	UCHAR *pChar;

	while (pChar = strtok(NULL, "\n")) {	// Get display argument

		if (*pChar == '"') {				// Quoted string ?
			pChar++;							// Yes, point to next char
			pChar = strtok(pChar, "\"");		// Tokenize on closing quote
		} else {								// No,
			pChar = strtok(pChar, " ,\n\t");	// Get this argument

			if ((i = LookupVar(pChar)) != -1)
				pChar = (*Access[Variables[i].wType].pfnGetStr)(i);
			else
				pChar = "";
		}

		// Output each char of string

		for (; *pChar; pChar++)	{
			if (*pChar == '<')
				pChar = XlatChar(pChar);
			v_ch(*pChar, wnp);
		}
	}

	return (X_SUCCESS);
}


/**
*
*		function:		DoGotoXY()
*
*		purpose:		Move cursor to XY position
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoGotoXY(UCHAR *szLine)

{
	BYTE bAttr;
	BYTE bCol;
	BYTE bMaxRows;
	BYTE bNumCols;
//	BYTE bPage;
	BYTE bRow;
	UCHAR *pszArg;
	union REGS inregs, outregs;

//	bMaxRows = *((BYTE far *)(0x0484L));		// Get maximum row and number of cols
//	bNumCols = *((BYTE far *)(0x044AL));

	bMaxRows = wn_rowq(wnp);		// Get maximum row and number of cols
	bNumCols = wn_colq(wnp);

//	inregs.h.ah = 0x0f;							// Get current page
// int86(0x10, &inregs, &outregs);
//	bPage = outregs.h.bh;

	if (pszArg = strtok(NULL, szTokens)) {		// Get row and column
		bCol = (BYTE)atoi(pszArg);
		if (bCol >= bNumCols)					// If not valid, use pszArg as flag
			pszArg = NULL;
		else if (pszArg = strtok(NULL, szTokens)) {
			bRow = (BYTE)atoi(pszArg);
			if (bRow > bMaxRows)
				pszArg = NULL;
		}
	}
	if (pszArg) {								// If row and column valid
//		inregs.h.ah = 2;						//  set cursor position
//		inregs.h.bh = bPage;
//		inregs.h.dh = bRow;
//		inregs.h.dl = bCol;
//		int86(0x10, &inregs, &outregs);
      cs_mv(bRow, bCol, wnp);          /* move cursor */  
   }

   cs_mv(1, 0, wnp);         /* move cursor */
   
	return (X_SUCCESS);

}


/**
*
*		function:		DoInput()
*
*		purpose:		Get character from specified device
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoInput(UCHAR *szLine)

{
	int i;
	UCHAR *pszArg;
	WORD wPort;
	int iVar;
	union REGS inregs, outregs;

	if (pszArg = strtok(NULL, szTokens)) 			// Get specified port
		if ((wPort = GetPort(pszArg)) != -1)
			if (pszArg = strtok(NULL, szTokens))	// Get variable
				if ((iVar = LookupVar(pszArg)) != -1) {
					inregs.h.ah = 1;
					inregs.x.dx = wPort;
					int86(0x14, &inregs, &outregs);
					if (!(outregs.h.ah & 0x80))
					   (*Access[Variables[iVar].wType].pfnSetVar)(iVar, &inregs.x.ax);
				}

	return (X_SUCCESS);
}

/**
*
*		function:		DoPause()
*
*		purpose:		Wait for user input
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoPause(UCHAR *szLine)

{
	UCHAR *pszArg;
	WORD wWait;
	time_t StartTime;
	time_t CurrentTime;

	while (kbhit())					// Flush keyboard buffer
		getch();

	if (pszArg = strtok(NULL, szTokens)) {	// If arg
		wWait = atoi(pszArg);					// Get seconds to wait
		time(&StartTime);
		do {
			time(&CurrentTime);
		} while (((CurrentTime - StartTime) < wWait) && !kbhit());

	} else									// Else
		getch();								//  Wait for keystroke

	return (X_SUCCESS);
}


/**
*
*		function:		DoMode()
*
*		purpose:		Set communication port parameters
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoMode(UCHAR *szLine)

{
	int iRet;
	BOOL fSuccess;
	BYTE bRate;
	BYTE bParity;
	BYTE bStop;
	BYTE bLength;
	BYTE bInit;
	UCHAR *pszArg;
	WORD wPort;
	union REGS inregs, outregs;

	fSuccess = FALSE;			// Default to error

	wPort	= DEF_PORT;			// Set defaults
	bRate 	= DEF_RATE;
	bParity = DEF_PARITY;
	bStop 	= DEF_STOP;
	bLength = DEF_LENGTH;

	if (pszArg = strtok(NULL, szTokens)) // Get specified port
		if ((wPort = GetPort(pszArg)) != -1)
			if (pszArg = strtok(NULL, szTokens))  // Get specified rate
				if ((bRate = GetRate(pszArg)) != -1)
					if (pszArg = strtok(NULL, szTokens))  // Get specified rate
						if ((bParity |= GetParity(pszArg)) != -1)
							if (pszArg = strtok(NULL, szTokens))  // Get specified rate
								if ((bLength |= GetLength(pszArg)) != -1)
									if (pszArg = strtok(NULL, szTokens))  // Get specified rate
										if ((bStop |= GetStop(pszArg)) != -1)
											fSuccess = TRUE;

	if (fSuccess || !pszArg ) {
		inregs.h.ah = 0;
		inregs.h.al = bRate + bParity + bStop + bLength;
		inregs.x.dx = wPort;
		int86(0x14, &inregs, &outregs);
		iRet = X_SUCCESS;
	} else
		iRet = pszArg - szLine;

	return (iRet);
}


/**
*
*		function:		DoOutput()
*
*		purpose:		Write string to device
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoOutput(UCHAR *szLine)

{
	int i;
	UCHAR *pszPort;
	UCHAR *pChar;
	WORD wPort;
	union REGS inregs, outregs;

	if (pszPort = strtok(NULL, szTokens)) // Get specified port
		if ((wPort = GetPort(pszPort)) != -1)
			while (pChar = strtok(NULL, "\n")) {	// Get display argument

				if (*pChar == '"') {				// Quoted string ?
					pChar++;							// Yes, point to next char
					pChar = strtok(pChar, "\"");		// Tokenize on closing quote
				} else {								// No,
					pChar = strtok(pChar, " ,\n\t");	// Get this argument
					if ((i = LookupVar(pChar)) != -1)
						pChar = (*Access[Variables[i].wType].pfnGetStr)(i);
					else
						pChar = "";
				}

				// Output each char of string

				for (; *pChar; pChar++)	{
					if (*pChar == '<')
						pChar = XlatChar(pChar);

					inregs.h.ah = 1;
					inregs.h.al = *pChar;
					inregs.x.dx = wPort;
					int86(0x14, &inregs, &outregs);
					if (outregs.h.ah & 0x80)
						bell();
				}
			}
	return (X_SUCCESS);
}


/**
*
*		function:		DoRemark()
*
*		purpose:		Ignore Line
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoRemark(UCHAR *szLine)

{
	return(X_SUCCESS);
}

/**
*
*		function:		DoStatus()
*
*		purpose:		Report printer port status
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoStatus(UCHAR *szLine)

{
	int iRet;
	UCHAR *pszPort;
	WORD wPort;
	union REGS inregs, outregs;

	if (pszPort = strtok(NULL, szTokens)) {
		if ((wPort = GetPort(pszPort)) != -1) {
			inregs.h.ah = 3;
			inregs.x.dx = wPort;
			int86(0x14, &inregs, &outregs);
			v_printf(wnp, text[TXT_SPRN_12], wPort + 1, outregs.x.ax);
			iRet = X_SUCCESS;
		} else
			iRet = pszPort - szLine;
	} else
		iRet = 1;

	return (iRet);
}


/**
*
*		function:		DoQuit()
*
*		purpose:		End script file processing
*
*		arguments:		szLine = pointer to script line arguments
*
*		returns:		int, 0 if SUCCESS, -1 if QUIT or index into
*						  szLine of bad arguments
*
**/

static int DoQuit(UCHAR *szLine)

{
	return(QUIT);
}


/**
*
*		function:		ProcessScript
*
*		purpose:		Process an open script file
*
*		arguments:		FILE *fp = pointer to file structure
*
*		returns:		int = DOS Batchfile ERRORLEVEL return code
*
**/

static int ProcessScript(FILE *fp)

{
	UCHAR szLine[81];				// Single line from script file
	UCHAR *pszCmd;
	int iCmdIndex;
	int iErrorLevel;
	int iLineNo;
	int iResult;
	BOOL fDone;

	fDone = FALSE;					// Default to not done

	// Process script file, one line at a time

	iLineNo = 0;

	while (fgets(szLine, sizeof(szLine) - 1, fp) && !fDone) {

		iLineNo++;

		// Parse command from line

		if (pszCmd = strtok(szLine, szTokens)) {

			// Lookup commands

			if ((iCmdIndex = LookupCmd(pszCmd)) != -1) {

				// Invoke command

				iResult = (*Commands[iCmdIndex].pfnCmd)(szLine);

				if (iResult == QUIT)
					fDone = TRUE;
				else if (iResult) {
					v_printf(wnp, "%s\n", szLine);
					memset(szLine, ' ', iResult + 1);
					szLine[iResult + 1] = '\0';
					strcat(szLine, text[TXT_SPRN_11]);
					v_printf(wnp, "%s\n", szLine);
				}

			} else
				v_printf(wnp, text[TXT_SPRN_10],	iLineNo,	pszCmd);

		}
	}

	if (fDone || feof(fp)) {
		v_st(text[TXT_SPRN_08], wnp);
		iErrorLevel = X_SUCCESS;
	} else {
		v_st(text[TXT_SPRN_09], wnp);
		iErrorLevel = BAD_READ;
	}

	return (iErrorLevel);
}


/**
*
*		function:	test_serialp()
*
*		purpose:		main function
*
*		returns:		ERRORLEVEL, 0 if successful, <> 0 if error
*
**/

int test_serialp(void)

{
   int     iErrorLevel;			// DOS Batchfile ERRORLEVEL value
   FILE    *fpScript;			// Pointer to script file structure
   int     key;
   STATUS  result;
   union REGS r;
   unsigned int *port=(unsigned int *)0x00400000L;


   iErrorLevel = X_SUCCESS;		// Default to success

   clear_all_windows();
   disp_title (menuopt[11]);
   disp_inst (NULL, NULL);
    
   if (Location == BOP || Location == PC) {
      result = SKIPPED;
   } else {
      v_stpl ( 1, 0, text[TXT_SPRN_01], wnp);
      cs_mv(2, 0, wnp);          /* move cursor */

	// Yes, attempt to open filename and process script
      *port=0x310;
      r.x.ax=0x0083;
      r.x.dx=0;
      int86(0x14,&r,&r);
      fprintf(stdaux,"v");
      r.h.ah=0x02;
      r.x.dx=0;
      int86(0x14,&r,&r);
      if (r.h.ah&0x80) {
         result = FAILED;
      }
      else {
      
   	   if (fpScript = fopen(pScriptName, "rt")) {
	   	   iErrorLevel = ProcessScript(fpScript);
		      fclose(fpScript);
   	   } else {
	   	   v_printf(wnp, text[TXT_SPRN_04], pScriptName);
		      iErrorLevel = BAD_OPEN;
   	   }
      
         if (iErrorLevel == X_SUCCESS) {
            key = disp_exit(text[TXT_SPRN_02], text[TXT_SPRN_03], 
               ENTER_MASK | VOID_MASK);
            if (key == ENTER_KEY) {
               result = PASSED;
            } else if (key == 0) {
               result = SKIPPED;
            } else {
               result = FAILED;
            }
         } else if (iErrorLevel == BAD_OPEN) {
            result = SKIPPED;
         } else {
            result = FAILED;
         }
      }
   }

   if (result == PASSED) 
	   v_st(text[TXT_SPRN_05], wnp);
   else if (result == FAILED)
	   v_st(text[TXT_SPRN_06], wnp);
//   else
//	   v_st(text[TXT_SPRN_07], wnp);
   delay_ticks(SHORT_DELAY);

   return (result);   
}

