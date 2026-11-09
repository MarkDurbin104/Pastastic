unit Counter;

interface

type
   TCounter = class
   private
      FCounter : integer ;
   public
      procedure Reset ;
      function  AddNumber( Number : integer ) : integer ;
      function  Add : integer ;
      property  Value : integer read FCounter ;
      Constructor Create ;
   end ;
implementation

// -----------------------------------------------------------------------------
Constructor TCounter.Create ;
begin
   inherited Create ;
   FCounter := 0 ;
end ;
// -----------------------------------------------------------------------------
procedure TCounter.Reset ;
begin
   FCounter := 0 ;
end;
// -----------------------------------------------------------------------------
function TCounter.AddNumber( Number : integer ) : integer ;
begin
   Inc( FCounter, Number );
   result := FCounter ;
end;
// -----------------------------------------------------------------------------
function TCounter.Add : integer ;
begin
   Inc( FCounter );
   result := FCounter ;
end;

end.
 