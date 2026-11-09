unit trystamp;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
     V:Variant;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}
uses
   OleAuto;
   
procedure TForm1.Button1Click(Sender: TObject);
var
   F:Variant;
begin
   try
     V:=CreateOleObject('Product.1Stamp');
     V.RunForm('Form1');
     V.PLUCode:=20;
     Label1.Caption:=IntToStr(V.PLUCode);
     V.Show;
   except
      on E:Exception do
      begin
         Application.HandleException(E);
         ShowMessage('Error Running 1st Class Stamp');
      end;
   end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
   F:Variant;
begin
   try
     V:=CreateOleObject('Product.1Stamp');
     V.RunForm('Form2');
     V.PLUCode:=10;
     Label1.Caption:=IntToStr(V.PLUCode);
     V.Show;
   except
      on E:Exception do
      begin
         Application.HandleException(E);
         ShowMessage('Error Running 1st Class Stamp');
      end;
   end;
end;        

end.
 