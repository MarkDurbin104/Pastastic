unit GetOfficeNumberF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, GPCSGUID, CRC32 ;

type
  TForm1 = class(TForm)
    DisplayButton: TButton;
    OfficeNumberEdit: TEdit;
    SetButton: TButton;
    Button3: TButton;
    procedure DisplayButtonClick(Sender: TObject);
    procedure SetButtonClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.DisplayButtonClick(Sender: TObject);
begin
   OfficeNumberEdit.Text :='Start Reading';
   OfficeNumberEdit.Text :=IntToHex(CalcCCITTCRC(GetGPCSRegValues('OfficeInfo','')),8);
end;

procedure TForm1.SetButtonClick(Sender: TObject);
var
   CompStr:String;
begin
   CompStr:=IntToHex(CalcCCITTCRC(GetGPCSRegValues('OfficeInfo','')),8);
   OfficeNumberEdit.Text := CompStr;
   SetGPCSRegString('','OfficeInfo',CompStr);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   SetGPCSRegString('','OfficeInfo','');
   OfficeNumberEdit.Text := '';
end;

end.
