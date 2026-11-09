unit TestFloppyFormatFU;

interface

uses
  CpyFile,
  Mask,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type

  TForm1 = class(TForm)
    CopyButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    ToEdit: TEdit;
    OutPutEdit: TEdit;
    Label3: TLabel;
    ListFilesMemo: TMemo;
    CopyFromFloppyButton: TButton;
    FromFloppytoEdit: TEdit;
    CopyFromFloppy1: TCopyFromFloppy;
    CopyIntoFloppy1: TCopyIntoFloppy;
    TBWrittenEdit: TEdit;
    TBWriteEdit: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    procedure CopyButtonClick(Sender: TObject);
    procedure CopyFromFloppyButtonClick(Sender: TObject);
    function CopyFromFloppy1InsertDisk(Text: String): Word;
    procedure CopyFromFloppy1GetReadyDevice;
    procedure CopyIntoFloppy1DiskNoRead;
    procedure CopyIntoFloppy1GetReadyDevice;
    function CopyIntoFloppy1InsertDisk(Txt: String): Word;
    function CopyIntoFloppy1InsertFormatDisk(Txt: String): Word;
    procedure CopyIntoFloppy1CopyFile(Sender: TCopyFile);
    procedure CopyFromFloppy1CopyFile(Sender: TCopyFile);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
{
function CopyFileToFloppy( FromFiles, ToDir : String ) : boolean ;
var
   CopyIntoFloppy : TCopyIntoFloppy ;
begin

  CopyIntoFloppy := TCopyIntoFloppy.Create( nil ) ;
  try
      CopyIntoFloppy.OutputDir  := ToDir ;
      CopyIntoFloppy.InputFileNames := FromFiles ;

      result := CopyIntoFloppy.StartCopying ;

   finally
      CopyIntoFloppy.Free ;
   end ;

end ;

function CopyFromToFloppy( FromFiles, ToDir : String ) : boolean ;
var
   CopyFromFloppy : TCopyFromFloppy ;
begin

  CopyFromFloppy := TCopyFromFloppy.Create( nil ) ;
  try
      CopyFromFloppy.OutputDir  := ToDir ;
      CopyFromFloppy.InputFileNames := FromFiles ;

      result := CopyFromFloppy.StartCopying ;

   finally
      CopyFromFloppy.Free ;
   end ;

end ;
}

procedure TForm1.CopyButtonClick(Sender: TObject);
begin
  CopyButton.Enabled := FALSE ;

  CopyIntoFloppy1.OutputDir := ToEdit.Text ;
  CopyIntoFloppy1.InputFileNames := ListFilesMemo.Lines.CommaText ;
  CopyIntoFloppy1.StartCopying ;

  OutPutEdit.Text := CopyIntoFloppy1.ErrorStatusStr ;

  CopyButton.Enabled := TRUE ;
end;

procedure TForm1.CopyFromFloppyButtonClick(Sender: TObject);
begin
  CopyFromFloppyButton.Enabled := FALSE ;

  CopyFromFloppy1.OutputDir := FromFloppytoEdit.Text ;
  CopyFromFloppy1.StartCopying ;
  OutPutEdit.Text := CopyIntoFloppy1.ErrorStatusStr ;

  CopyFromFloppyButton.Enabled := TRUE ;
end;


function TForm1.CopyFromFloppy1InsertDisk(Text: String): Word;
begin

   result := MessageDlg( 'From Floppy-> From the component "Insert floppy number ' + Text+'"',
                             mtConfirmation, [ mbOK, mbAbort ], 0 );

end;

procedure TForm1.CopyFromFloppy1GetReadyDevice;
begin
   ShowMessage( ' From Floppy-> From the component "Get ready floppy with BackUp files" ' );
end;

procedure TForm1.CopyIntoFloppy1DiskNoRead;
begin
   ShowMessage(' Into Floppy-> From the component," Enter another disk, this has not been read " ');
end;

procedure TForm1.CopyIntoFloppy1GetReadyDevice;
begin
   ShowMessage( ' Into Floppy-> From the component "Get ready floppy, It will be formated" ' );
end;

function TForm1.CopyIntoFloppy1InsertDisk(Txt: String): Word;
begin
         result := MessageDlg( ' From Floppy-> From the component " Insert floppy number ' + Txt+'"',
                             mtConfirmation, [ mbOK, mbAbort ], 0 );

end;

function TForm1.CopyIntoFloppy1InsertFormatDisk(Txt: String): Word;
begin
         result := MessageDlg( 'From Floppy-> From the component " Insert floppy disk number '+ Txt+', it will be formated "',
                                mtConfirmation, [ mbOK, mbAbort ], 0 );

end;

procedure TForm1.CopyIntoFloppy1CopyFile(Sender: TCopyFile);
begin
   TBWriteEdit.Text   := IntToStr( CopyIntoFloppy1.TotalBytes );
   TBWrittenEdit.Text := IntToStr( CopyIntoFloppy1.BytesWritten );
end;

procedure TForm1.CopyFromFloppy1CopyFile(Sender: TCopyFile);
begin
   TBWriteEdit.Text   := IntToStr( CopyIntoFloppy1.TotalBytes );
   TBWrittenEdit.Text := IntToStr( CopyIntoFloppy1.BytesWritten );
end;

end.
