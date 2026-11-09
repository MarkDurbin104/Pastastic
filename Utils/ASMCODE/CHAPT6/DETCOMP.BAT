@Echo off
Echo.
Echo The BAT-file %0 is intended for determining the type of your computer
Echo.
detpc
If ErrorLevel 1 GoTo More0
Echo Type 0: Your computer is not recognized
GoTo EndProc
:More0
If ErrorLevel 2 GoTo More1
Echo Type 1: Your computer is IBM PS/2 model 80
GoTo EndProc
:More1
If ErrorLevel 3 GoTo More2
Echo Type 2: Your computer is IBM PC Convertible
GoTo EndProc
:More2
If ErrorLevel 4 GoTo More3
Echo Type 3: Your computer is IBM PS/2 model 30
GoTo EndProc
:More3
If ErrorLevel 5 GoTo More4
Echo Type 4: Your computer is PC XT extended
GoTo EndProc
:More4
If ErrorLevel 6 GoTo More5
Echo Type 5: Your computer is IBM PC-AT or PS/2 model 50 or 60
GoTo EndProc
:More5
If ErrorLevel 7 GoTo More6
Echo Type 6: Your computer is IBM PC-JR
GoTo EndProc
:More6
If ErrorLevel 8 GoTo More7
Echo Type 7: Your computer is IBM PC-XT 
GoTo EndProc
:More7
If ErrorLevel 9 GoTo More8
Echo Type 8: Your computer is IBM PC
GoTo EndProc
:More8
If ErrorLevel 10 GoTo More9
Echo Type 9: Your computer is Compaq XT or Compaq Plus
GoTo EndProc
:More9
If ErrorLevel 11 GoTo More10
Echo Type 10: Your computer is Sperry PC
GoTo EndProc
:More10
If ErrorLevel 12 GoTo More11
Echo Type 11: Your computer is Compaq PC or Compaq Deskpro
GoTo EndProc
:More11
Echo Type 12 or higher: Your computer is not recognized
:EndProc
