unit RasDialerFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,RASDialer,
  StdCtrls,Ras, ExtCtrls;

type
  TForm1 = class(TForm)
    Memo2: TMemo;
    Panel1: TPanel;
    Memo1: TMemo;
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
var
   RASDialer:TRasDialer;
   I,J:Integer;
   S:String;
begin
   RASDialer:=TRasDialer.Create;
   ListBox1.Items.CommaText:=RASDialer.GetPhoneBookEntries;
   if ListBox1.Items.Count > 0 then
   begin
      ListBox1.ItemIndex:=0;
      ListBox1Click(ListBox1);
   end;
   RASDialer.Free;
   Memo2.Clear;
   for I:=0 to 2000 do
   begin
      SetLength(S,512);
      ZeroMemory(PChar(S),512);
      RasGetErrorString(I,PChar(S),512);
      S:=StrPas(PChar(S));
      for J:=1 to Length(S) do if Integer(S[J]) < 32 then S[J]:=' ';
      if S <> '' then
         Memo2.Lines.Add(IntToStr(I)+' '+S);
   end;
   if ParamCount >= 1 then 
   begin
      if ListBox1.Items.IndexOf(ParamStr(1)) <> -1 then
      begin
         ListBox1.ItemIndex:=ListBox1.Items.IndexOf(ParamStr(1));
         ListBox1Click(ListBox1);
         Memo1.Lines.SaveToFile('C:\CorvusService\DialData.txt');
         Application.Terminate;
      end;
   end;
end;

procedure TForm1.ListBox1Click(Sender: TObject);
var
   RASDialer:TRasDialer;
   User,Pass,Phone,Domain:String;
begin
   if ListBox1.ItemIndex <> -1 then
   begin
      RASDialer:=TRasDialer.Create;
      RASDialer.GetEntry(ListBox1.Items[ListBox1.ItemIndex],User,Pass,Phone,Domain);
      RASDialer.Free;
      Memo1.Clear;
      Memo1.Lines.Add('U'+User  );
      Memo1.Lines.Add('P'+Pass  );
      Memo1.Lines.Add('T'+Phone );
      Memo1.Lines.Add('D'+Domain);
   end;
end;

end.
