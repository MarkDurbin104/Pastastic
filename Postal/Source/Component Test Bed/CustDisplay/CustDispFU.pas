unit CustDispFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,SavePosFormU;

type
  TCustomerDisplay = class(TSavePosForm)
    DisplayData: TMemo;
    procedure FormCreate(Sender: TObject);
  public
    procedure WriteLine(LineNo:Integer;Value:String);
    procedure Clear;
  end;

var
  CustomerDisplay: TCustomerDisplay;

implementation

{$R *.DFM}

procedure TCustomerDisplay.WriteLine(LineNo:Integer;Value:String);
begin
   while Length(Value) < 20 do Value:=Value+' ';
   DisplayData.Lines[LineNo]:=Copy(Value,1,20);
end;
procedure TCustomerDisplay.Clear;
begin
   DisplayData.Clear;
   DisplayData.Lines.Add('');
   DisplayData.Lines.Add('');
end;                        
    
procedure TCustomerDisplay.FormCreate(Sender: TObject);
begin
   Clear;
end;

end.
