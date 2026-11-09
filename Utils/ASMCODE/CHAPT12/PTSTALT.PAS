Program PTstAlt ;
Uses Crt, AsmLink ;
Begin
Writeln ; Writeln
('The demo program showing the link between Turbo Pascal and Assembler' ) ;
Writeln ( 'V.B.Maljugin,  1992,  Voronezh, Russia' ) ;
Writeln ; Writeln ('Determening the state of the ALT key on keyboard' ) ;
If TestAlt Then Writeln ('The Alt key is DOWN')
   Else Writeln ('Alt key is UP') ;
Writeln ('Press the ALT key and hold it for not less than 5 seconds') ;
Delay (5000) ;
If TestAlt Then Writeln ('The Alt key is DOWN')
   Else Writeln ('Alt key is UP') ;
Writeln ('Release the ALT key and press ENTER to finish the program');
Readln;
End.
