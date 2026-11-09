unit SourceFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TSourceForm = class(TForm)
    Memo1: TMemo;
    Panel1: TPanel;
    Button2: TButton;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    LineNo:Integer;
  end;

var
  SourceForm: TSourceForm;

implementation

{$R *.DFM}

procedure TSourceForm.FormShow(Sender: TObject);
begin
   Timer1.Enabled:=True;
end;

procedure TSourceForm.Timer1Timer(Sender: TObject);
var
  I,J,K:Integer;
begin
   Timer1.Enabled:=False;
   if LineNo > 0 then
   begin
      Memo1.SetFocus;
      Memo1.SelStart:=0;
      Memo1.SelLength:=1;  // move to top of window
      J:=0;
      for I:=0 to LineNo-2 do
         J:=J+Length(SourceForm.Memo1.Lines[I])+2;
      K:=0;
      
      for I:=LineNo-2 to LineNo+10 do
         K:=K+Length(SourceForm.Memo1.Lines[I])+2;
      Memo1.SetFocus;
      Memo1.SelStart:=K+J; // move to 12 lines passed error line
      Memo1.SelLength:=20; 
      // move to line                  
      Memo1.SelStart:=J+Length(Memo1.Lines[LineNo-1]);
      Memo1.SelLength:=0-Length(Memo1.Lines[LineNo-1]); 
   end;
end;

end.
