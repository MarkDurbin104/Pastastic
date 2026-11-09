unit FindTextFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  DirectoryU, StdCtrls;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
var
   FList:TStringList;
   I:Integer;
   FileSL:TStringList;
begin
   FileSL:=TStringList.Create;
   FList:=TStringList.Create;
   FillFileList(Edit2.Text,'*.pas;*.dpr',True,FList);
   for I:=0 to FList.Count-1 do
   begin
      Label1.Caption:=FList[I];
      Label1.Repaint;
      FileSL.LoadFromFile(FList[I]);
      if Pos(Edit1.Text,FileSL.Text) > 0 then
         Memo1.Lines.Add(FList[I]);
   end;
   Label1.Caption:='Complete';
   FList.Free;             
   FileSL.Free;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  List:TStringList;
  I:Integer;
begin
   Button2.Enabled:=False;
   try
      List:=TStringList.Create;
      FillFileList(Edit2.Text,'*.*',True,List);
      for I:=0 to List.Count-1 do
         if Pos(Edit1.Text,ExtractFileName(List[I])) > 0 then 
            Memo1.Lines.Add(List[I]);
      List.Free;
   finally
      Button2.Enabled:=True;
   end;
end;

end.
