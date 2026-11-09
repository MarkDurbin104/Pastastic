unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,TEAU;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Button1: TButton;
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
begin
   Edit2.Text:=TTEAEncryptor.EncodeString(Edit1.Text,'HelloHappyPeople');
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
   Edit2.Text:=TTEAEncryptor.DecodeString(
                 TTEAEncryptor.EncodeString(Edit1.Text,'HelloHappyPeople'),
                 'HelloHappyPeople');
end;

end.
 
