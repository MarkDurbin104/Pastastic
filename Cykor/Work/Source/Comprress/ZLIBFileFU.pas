unit ZLIBFileFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,Compress,
  StdCtrls, FileCtrl;

type
  TForm1 = class(TForm)
    InFileListBox1: TFileListBox;
    InDirectoryListBox1: TDirectoryListBox;
    InDriveComboBox1: TDriveComboBox;
    Label1: TLabel;
    OutDriveComboBox2: TDriveComboBox;
    OutDirectoryListBox2: TDirectoryListBox;
    CompressButton: TButton;
    Label2: TLabel;
    procedure CompressButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.CompressButtonClick(Sender: TObject);
var
   I:Integer;
begin
     for I:=0 to InFileListBox1.Items.Count-1 do
     begin
          if InFileListBox1.selected[I] then
          begin
              TCompressor.CompressFile(InDirectoryListBox1.Directory+'\'+InFileListBox1.Items[I],OutDirectoryListBox2.Directory+'\'+ExtractFileName(InFileListBox1.Items[I])+'.zlib')
          end;
     end;
end;

end.
