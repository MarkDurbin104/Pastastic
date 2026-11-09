unit GetFileListFU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,DirectoryU, StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}
procedure SaveList(Path:String);
var
  I:Integer;
  SL:TStringList;
begin
  SL:=TStringList.Create;
  FillFileList(Path,'*.*',true,SL);
  for I := 0 to SL.Count - 1 do
  begin
    SL[I]:=Copy(SL[I],Length(Path)+2,Length(SL[I]));
  end;
  for I := SL.Count-1 downto 0 do
  begin
    if (Copy(SL[I],1,4) = 'com\') or (SL[I]='F173715D.dat') then
      SL.delete(I);
  end;
  SL.SaveToFile(Path+'\F173715D.dat');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  SaveList('C:\Proiam\Source\VU.iT BA\BA Demo\bin-release');
end;

end.
