unit ErrorFormFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls,SavePosFormU;

type
  TErrorForm = class(TSavePosForm)
    Errors: TMemo;
  public
     procedure PutOn(Panel:TPanel);
  end;

var
  ErrorForm: TErrorForm;

implementation

{$R *.DFM}

procedure TErrorForm.PutOn(Panel:TPanel);
begin
   Parent:=Panel;
   if Panel <> nil then
   begin
      BorderStyle:=bsNone;
      Align:=alClient;
   end
   else
   begin
      BorderStyle:=bsSizeable;
   end;
   Show;
end;

end.
