;***************************************************************
;  Program Sound ( Chapter 10 )
;
;  The program for outputting a sound of prescribed tone
;
;  Author: A.I.Sopin   Voronezh, Russia   1990 --- 1992
;  ------
;
;  Call from Assembler programs:
;
;       Call SOUND
;
;  Parameters passed through the registers:
;
;  Frequency    - DI register (from   21  to  65535  hertz)
;
;  Duration      -BX register (in hundredth of second)
;
;  Registers  AX, CX, DX, DS, ES, SI  are retained by the program 
;
;
;
;***************************************************************
PUBLIC   SOUND
CODE     SEGMENT
         ASSUME CS:CODE
SOUND    PROC   FAR
         push   ax
         push   cx
         push   dx
         push   ds
         push   es
         push   si
;-----------------------------------------------------------
         in     al,61h            ;  Read current port mode B (8255)
         mov    cl,al             ;  Save current mode
         or     al,3              ;  Switch on speaker and timer
         out    61h,al            ;
         mov    al,0B6h           ;  set for channel  2 (8253)
         out    43h,al            ;  command register  8253
         mov    dx,14h            ;
         mov    ax,4F38h          ;  divisor of frequency
         div    di                ;
         out    42h,al            ;  lower byte of frequency
         mov    al,ah             ;
         out    42h,al            ;  higher byte of frequency
;  Generation of sound delay 
         mov    ax,91             ;  multiplier  -  AX register !
         mul    bx                ;  AX =BX*91 (result in   DX:AX)
         mov    bx,500            ;  divisor, dividend in   DX:AX
         div    bx                ;  result in   AX, remainder in DX 
         mov    bx,ax             ;  save result
         mov    ah,0              ;  read time
         int    1Ah               ;
         add    dx,bx             ;
         mov    bx,dx             ;
Cycle:   int    1Ah               ;
         cmp    dx,bx             ;  Has time gone ?
         jne    Cycle             ;
         in     al,61h            ;  Read mode of port B (8255)
         mov    al,cl             ;  Previous mode 
         and    al,0FCh           ;
         out    61h,al            ;  Restore mode
;-----------------------------------------------------------
;  Restoring registers and exit
Exit:    pop    si                ;
         pop    es                ;
         pop    ds                ;
         pop    dx                ;
         pop    cx                ;
         pop    ax                ;
         RETF                     ; exit from subroutine
SOUND    ENDP
CODE     ENDS
         END
