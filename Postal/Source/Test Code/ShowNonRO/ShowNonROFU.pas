unit ShowNonROFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,DirectoryU;

type
  TForm1 = class(TForm)
    ListBox1: TListBox;
    procedure FormCreate(Sender: TObject);
  public
    procedure DirectoryOnFile(Name:String;Details:TSearchRec);
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.DirectoryOnFile(Name:String;Details:TSearchRec);
begin
   if (Details.Attr and faReadOnly) = 0 then
      ListBox1.Items.Add(Name)
end;
procedure TForm1.FormCreate(Sender: TObject);
var
   Dir:TDirectory;
begin
   Dir:=TDirectory.Create;
   Dir.Mask:='*.pas;*.dpr;*.dfm';
   Dir.OnFile:=DirectoryOnFile;
   Dir.RootPath:='E:\CorvusV3\Corvus\Source\';
   Dir.Free;
end;
end.
