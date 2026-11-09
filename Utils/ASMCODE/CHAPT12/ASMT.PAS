Program Asmt ;
Uses Pasasm ;
Var Rdkey: Byte ; IndSpec: Boolean ;
Begin
Writeln ('                    Turbo Pascal - MASM interfacing' ) ;
Writeln ; Writeln ('Press the ESC key to exit or any other to continue ' ) ;
Writeln ;
Repeat
   Writeln ; Write ( 'Enter character ' );
   RdKey := GetScan(':', IndSpec) ;
   Write (' (', RdKey, '), the indicator of a special key is  "',
          IndSpec, '".' );
Until RdKey = 27 ;
End.
