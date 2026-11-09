unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Menus, ComCtrls, OleCtrls, Buttons, isp3;

type
  TForm1 = class(TForm)
    HTML1: THTML;
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    Panel1: TPanel;
    Bevel1: TBevel;
    URLs: TComboBox;
    GoButton: TSpeedButton;
    View1: TMenuItem;
    DocumentSource1: TMenuItem;
    CancelBtn: TSpeedButton;
    Label1: TLabel;
    procedure Exit1Click(Sender: TObject);
    procedure GoButtonClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure DocumentSource1Click(Sender: TObject);
    procedure CancelBtnClick(Sender: TObject);
    procedure HTML1BeginRetrieval(Sender: TObject);
    procedure HTML1EndRetrieval(Sender: TObject);
    procedure URLsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses DocSrc;

{$R *.DFM}

procedure TForm1.Exit1Click(Sender: TObject);
begin
  Close;
end;

procedure TForm1.GoButtonClick(Sender: TObject);
begin
  if URLs.Items.IndexOf(URLs.Text) = -1 then
    URLs.Items.Add(URLs.Text);
  HTML1.RequestDoc(URLs.text);
  Statusbar1.Panels[0].Text := HTML1.RequestURL;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
  HTML1.AboutBox;
end;

procedure TForm1.DocumentSource1Click(Sender: TObject);
begin
  with DocSourceFrm do
  begin
    Show;
    Memo1.Lines.Clear;
    Memo1.Lines.Add(HTML1.SourceText);
    Memo1.SelStart := 0;
    SendMessage(Memo1.Handle, EM_ScrollCaret, 0, 0);
  end;
end;

procedure TForm1.CancelBtnClick(Sender: TObject);
begin
  HTML1.Cancel('test');
  CancelBtn.Enabled := False;
end;

procedure TForm1.HTML1BeginRetrieval(Sender: TObject);
begin
  CancelBtn.Enabled := True;
end;

procedure TForm1.HTML1EndRetrieval(Sender: TObject);
begin
  CancelBtn.Enabled := False;
end;

procedure TForm1.URLsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_Return then
    GoButtonClick(nil);
end;

end.
