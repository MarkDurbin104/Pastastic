program CleanJunkMailList;

uses
  SysUtils,Classes;

{$R *.res}
var
   SL:TStringList;
   I:Integer;
begin
  SL:=TStringList.Create;
  SL.LoadFromFile('C:\Documents and Settings\Mark\My Documents\Junk Senders.txt');
  for I:=0 to SL.Count-1 do
    SL[I]:=Copy(SL[I],Pos( '@',SL[I]),Length(SL[I]));
  SL.Sort;
  SL.SaveToFile('C:\Documents and Settings\Mark\My Documents\Junk Senders Fixed.txt');
  SL.Free;
end.
