unit psfu;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm3 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
     function GetSpeed:Integer;
  end;

var
  Form3: TForm3;

implementation

{$R *.DFM}
function TForm3.GetSpeed:Integer;
var
   S:TStringList;
begin
   S:=TStringList.Create;
   try
      S.LoadFromFile('PrintSpd.Dat');
      Result:=StrToIntDef(S.Strings[0],8);
      S.Free;
   except
      Result:=8;
   end;                        
end;                        
procedure TForm3.FormCreate(Sender: TObject);
begin
   Edit1.Text:=IntToStr(GetSpeed);
end;

procedure TForm3.Button1Click(Sender: TObject);
var
   S:TStringList;
   I:Integer;
begin
   I:=StrToIntDef(Edit1.Text,-1);
   if (I < 2) or (I > 8) then 
   begin
      I:=GetSpeed;
      Edit1.Text:=IntToStr(I);
      Exit;
   end;
   
   S:=TStringList.Create;
   try
      S.Add(Edit1.Text);
      S.SaveToFile('PrintSpd.Dat');
      S.Free;
   except
      ;
   end;                        
   ModalResult:=mrOK;
end;

end.
 