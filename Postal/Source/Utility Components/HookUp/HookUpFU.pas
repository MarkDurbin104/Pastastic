unit HookUpFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  THookForm = class(TForm)
    AccountsHooked: TCheckBox;
    CountersHooked: TCheckBox;
    DBServerHooked: TCheckBox;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Bevel1: TBevel;
    Label1: TLabel;
    TranslateHooked: TCheckBox;
    Edit5: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  HookForm: THookForm;

implementation

{$R *.DFM}

end.
