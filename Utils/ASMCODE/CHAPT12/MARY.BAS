REM Program Mary ( Chapter 12 )

DECLARE SUB QSound (fr AS INTEGER, dur AS INTEGER)

DEFINT A - Z

FOR i = 1 TO 26
   durat = 500
   IF (i < 7) OR (i > 7 AND i < 10) OR (i > 10 AND i < 13) THEN durat = 250
   IF i > 13 THEN durat = 250
   IF i = 26 THEN durat = 1000
   READ freq
   Call QSound (freq, durat)
NEXT i
STOP
	
DATA 330, 294, 262, 294, 330, 330, 330, 294, 294, 294
DATA 330, 392, 392, 330, 294, 262, 294, 330, 330, 330, 330
DATA 294, 294, 330, 294, 262
END

