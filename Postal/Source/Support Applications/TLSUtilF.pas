unit TLSUtilF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, FileCtrl, Grids, Outline, DirOutln, ExtCtrls;

type
  TTLSUtilForm = class(TForm)
    TLSListBox: TListBox;
    ButtonPanel: TPanel;
    FileListBox: TFileListBox;
    ButtonGroupBox: TGroupBox;
    AnalyseButton: TButton;
    DrivePanel: TPanel;
    DriveComboBox1: TDriveComboBox;
    DirectoryPanel: TPanel;
    DirectoryListBox: TDirectoryListBox;
    procedure AnalyseButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    { Private declarations }
    procedure FreeLibraries;
  public
    { Public declarations }
  end;

var
  TLSUtilForm: TTLSUtilForm;

implementation

{$R *.DFM}

procedure TTLSUtilForm.FreeLibraries;
begin
  While TLSListBox.Items.Count > 0 do
  begin
    If TLSListBox.Items.Objects[0] <> nil then
      FreeLibrary(Integer(TLSListBox.Items.Objects[0]));
    TLSListBox.Items.Delete(0);
  end;
end;

procedure TTLSUtilForm.AnalyseButtonClick(Sender: TObject);
var
  AHandle:THandle;
  PreTLSIndex, PostTLSIndex :  Integer;
begin
  FreeLibraries;
  FileListBox.ItemIndex := 0;
  Repeat
    PreTLSIndex := TLSAlloc;
    TLSFree(PreTLSIndex);
    AHandle := LoadLibrary(PChar(FileListBox.Items[TLSListBox.Items.Count]));
    PostTLSIndex := TLSAlloc;
    TLSFree(PostTLSIndex);
    TLSListBox.ItemIndex := TLSListBox.Items.AddObject(IntToStr(PostTLSIndex-PreTLSIndex) + ' - ' + FileListBox.Items[TLSListBox.Items.Count],
                                                      TObject(AHandle) );
  Until TLSListBox.Items.Count = FileListBox.Items.Count;
end;

procedure TTLSUtilForm.FormCreate(Sender: TObject);
begin
  FileListBox.Directory := 'c:\bermuda\binary';
end;

procedure TTLSUtilForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  FreeLibraries;
end;

end.
