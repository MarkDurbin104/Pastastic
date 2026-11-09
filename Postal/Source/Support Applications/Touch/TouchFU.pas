unit TouchFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComCtrls,GPCSGUID;

type
  TForm1 = class(TForm)
    DateTimePicker1: TDateTimePicker;
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Apply: TButton;
    procedure ApplyClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FileListBox1Change(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.ApplyClick(Sender: TObject);
var
   I:Integer;
   DateToApply:Integer;
   FS:TFileStream;
begin
  for I:=0 to FileListBox1.Items.Count-1 do
  begin
     DateTimePicker1.Time:=0;
     DateToApply:=DateTimeToFileDate(DateTimePicker1.Date);
     if FileListBox1.Selected[I] then
     begin
        try
          FS:=TFileStream.Create(FileListBox1.Directory+'\'+FileListBox1.Items[I],fmOpenWrite or fmShareDenyNone);
        except
          FS:=nil;
        end;
        if FS <> nil then
        begin
           FileSetDate(FS.Handle,DateToApply);
           FS.Free;
        end;
     end;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
   Path:String;
begin
   Path:=GetPSLRegString('Update','Source Path','');
   if Path = '' then Exit;
   DriveComboBox1.Drive:=Path[1];
   DirectoryListBox1.Directory:=Path;
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
begin
   if FileListBox1.SelCount > 0 then
      Apply.Enabled:=True
   else
      Apply.Enabled:=False;
end;

procedure TForm1.FileListBox1Click(Sender: TObject);
begin
   if FileListBox1.SelCount > 0 then
      Apply.Enabled:=True
   else
      Apply.Enabled:=False;
end;

end.
