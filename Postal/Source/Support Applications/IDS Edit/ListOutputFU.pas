unit ListOutputFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls,PackStrListU,StdCtrls;

type
  TListOutput = class(TForm)
    List: TMemo;
  public
    procedure PutOn(Panel:TPanel);
  end;

var
  ListOutput: TListOutput;

implementation

{$R *.DFM}

procedure TListOutput.PutOn(Panel:TPanel);
begin
   Parent:=Panel;
   if Panel = nil then
      BorderStyle:=bsSizeable
   else
   begin
      BorderStyle:=bsNone;
      Align:=alClient;
   end;
   Show;
end;
end.
