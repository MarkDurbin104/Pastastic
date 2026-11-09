       PAGE 79, 132
       TITLE 
COMMENT /***************************************************************

    File:           keyboard.asm

    Purpose:        keyboard utilities

                        get_key
                        get_key_status

    Author:         Paul Encarnacion
                    Unisys, EISG, Postal Programs
                    5151 Camino Ruiz
                    Camarillo, CA 93010
                    (805)987-6811 

    Date of Origin: 12-5-1990

    Copyright (c) 1990  Unisys Corporation

    $Log:   Z:\CM\F\BPO\DVT\VCS\KEYBOARD.ASV  $
   
      Rev 1.0   10 Dec 1990 10:46:22   PJE
   Initial revision.

***********************************************************************/
.MODEL LARGE
.CODE

	IF1
		%OUT	*** Starting Pass One ***
	ELSE
		%OUT	*** Starting Pass Two ***
	ENDIF

KEYBOARD_INT	EQU	16H
FALSE		EQU	0
TRUE		EQU	NOT FALSE

		PUBLIC _get_key, _get_key_status

		PAGE
COMMENT /*********************************************************************

	Procedure:	_get_key

	Purpose:	Get key from keyboard buffer

	Entry:		No significant registers

	Exit:		[AX] = key code

*****************************************************************************/
_get_key	PROC	FAR

		PUSH	BP
		MOV	BP, SP
		PUSH	DI
		PUSH	SI

		MOV	AH, 10h
		INT	KEYBOARD_INT

		POP	SI
		POP	DI
		MOV	SP, BP
		POP	BP

		RET

_get_key	ENDP


		PAGE
COMMENT /*********************************************************************

	Procedure:	_get_key_status

	Purpose:	See if a key is available in keyboard buffer

	Entry:		No significant registers

	Exit:		[AX] = status
			If status = 0, no key available
			else, status = key code

*****************************************************************************/

_get_key_status	PROC	FAR

		PUSH	BP
		MOV	BP, SP
		PUSH	DI
		PUSH	SI

		MOV	AH, 11h
		INT	KEYBOARD_INT
		JNZ	EXIT

		XOR	AX, AX
EXIT:
		POP	SI
		POP	DI
		MOV	SP, BP
		POP	BP

		RET

_get_key_status	ENDP

		END

