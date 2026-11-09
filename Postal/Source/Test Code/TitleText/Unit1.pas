unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
function ConvertToIdent(S:String):String;
var
   I:Integer;
   NextCap:Boolean;
begin
   NextCap:=True;
   Result:='';
   for I:=1 to Length(S) do
   begin
      if S[I] in [#32] then
      begin
        NextCap:=True;
      end
      else if NextCap then
      begin
         Result:=Result+UpCase(S[I]);
         NextCap:=False;
      end
      else            
      begin
         Result:=Result+LowerCase(S[I]);
      end;
   end;                 
end;
procedure TForm1.Button1Click(Sender: TObject);
var
  I:Integer;
begin
  for I:=0 to Memo1.Lines.Count-1 do
  begin
     Memo1.Lines[I]:=ConvertToIdent(Memo1.Lines[I]);
  end;
end;

end.
