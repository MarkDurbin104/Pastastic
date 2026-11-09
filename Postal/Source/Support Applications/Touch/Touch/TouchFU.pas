unit TouchFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, ComCtrls,GPCSGUID,DirectoryU;

type
  TForm1 = class(TForm)
    DateTimePicker1: TDateTimePicker;
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    Apply: TButton;
    CheckBox1: TCheckBox;
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
  FileList:TStringList;
implementation

{$R *.DFM}

procedure TouchFile(DateToApply:Integer;FileName:String);
var
   FS:TFileStream;
begin
  try
    FS:=TFileStream.Create(FileName,fmOpenWrite or fmShareDenyNone);
  except
    FS:=nil;
  end;
  if FS <> nil then
  begin
     FileSetDate(FS.Handle,DateToApply);
     FS.Free;
  end;
end;

procedure TouchDir(Path:String);
var
    SearchRec:TSearchRec;
    Res:Integer;
begin
   if Path[Length(Path)] <> '\' then Path:=Path+'\';
   Res:=FindFirst(Path+'*.*',$FFF,SearchRec);
   while Res = 0 do
   begin
      if (SearchRec.Name <> '.') and (SearchRec.Name <> '..') then
      begin

        if (SearchRec.Attr  and faDirectory) <> 0 then
        begin
           TouchDir(Path+SearchRec.Name);
        end
        else
        begin
           FileList.Add(Path+SearchRec.Name);
        end;
      end;
      Res:=FindNext(SearchRec);
   end;
   FindClose(SearchRec);
end;
procedure TForm1.ApplyClick(Sender: TObject);
var
   I:Integer;
   DateToApply:Integer;
begin
  DateTimePicker1.Time:=0;
  DateToApply:=DateTimeToFileDate(DateTimePicker1.Date);
  if CheckBox1.Checked then
  begin
    FileList:=TStringList.Create;
    TouchDir(FileListBox1.Directory);
    for I:=0 to FileList.Count-1 do
    begin
       TouchFile(DateToApply,FileList[I]);
    end;
    FileList.Free;
  end
  else
  begin
    for I:=0 to FileListBox1.Items.Count-1 do
    begin
       if FileListBox1.Selected[I] then
          TouchFile(DateToApply,FileListBox1.Directory+'\'+FileListBox1.Items[I]);
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
   DateTimePicker1.Date:=Now;
end;

procedure TForm1.FileListBox1Change(Sender: TObject);
begin
   if (FileListBox1.SelCount > 0) or CheckBox1.Checked then
      Apply.Enabled:=True
   else
      Apply.Enabled:=False;
end;

procedure TForm1.FileListBox1Click(Sender: TObject);
begin
   if (FileListBox1.SelCount > 0) or CheckBox1.Checked then
      Apply.Enabled:=True
   else
      Apply.Enabled:=False;
end;

end.
