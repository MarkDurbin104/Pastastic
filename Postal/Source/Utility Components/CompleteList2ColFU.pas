unit CompleteList2ColFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Mask, Domain,BaseProduct;

type
  TProdForm = class(TForm)
    EnqPrompt: TLabel;
    EnqList: TDomainCombo;
  public
    function Validate:Boolean;
  end;

var
  ProdForm: TProdForm;

implementation

{$R *.DFM}

function TProdForm.Validate:Boolean;
begin
   Result:=True;
end;
end.          
