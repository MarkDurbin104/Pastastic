unit SourceFormFU;

interface

uses
  IDSParseFU,
  StringUtil,
  Clipbrd,
  SAvePosFormU,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TSourceForm = class(TSavePosForm)
    SourceMemo: TMemo;
    Panel1: TPanel;
    CancelButton: TButton;
    Button1: TButton;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SourceMemoDblClick(Sender: TObject);
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
  PrevSnippet, NextSnippet : String;

begin
   Timer1.Enabled:=False;
   if LineNo > 0 then
   begin
      SourceMemo.SetFocus;
      SourceMemo.SelStart:=0;
      SourceMemo.SelLength:=1;  // move to top of window
      J:=0;
      for I:=0 to LineNo-2 do
         J:=J+Length(SourceForm.SourceMemo.Lines[I])+2;
      K:=0;

      for I:=LineNo-2 to LineNo+10 do
         K:=K+Length(SourceForm.SourceMemo.Lines[I])+2;
      SourceMemo.SetFocus;
      SourceMemo.SelStart:=K+J; // move to 12 lines passed error line
      SourceMemo.SelLength:=20;
      // move to line
      SourceMemo.SelStart:=J+Length(SourceMemo.Lines[LineNo-1]);
      SourceMemo.SelLength:=0-Length(SourceMemo.Lines[LineNo-1]);
      CancelButton.SetFocus;

      //find a snippet name
      PrevSnippet :=
        DelimitedString(ReverseDelimitedString(LeftString(SourceMemo.Text, SourceMemo.SelStart),'{ Snippet : ', True),
                        '}', False);
      NextSnippet :=
        SubString(Copy(SourceMemo.Text, SourceMemo.SelStart, Length(SourceMemo.Text)),
                                '{ Snippet : ', '}');

      If Trim(PrevSnippet) = Trim(NextSnippet) then
        Caption := Caption
          + ' - Snippet : ' + PrevSnippet;
//          + ' - FileName : ' + MainForm.IDSDiag.Parser.Nodes.Snippets.GetItemByName(PrevSnippet).FileName;
      Clipboard.AsText := PrevSnippet;
  end;
end;

procedure TSourceForm.CancelButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSourceForm.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TSourceForm.SourceMemoDblClick(Sender: TObject);
begin
  Clipboard.AsText := SourceMemo.SelText;
end;

end.
