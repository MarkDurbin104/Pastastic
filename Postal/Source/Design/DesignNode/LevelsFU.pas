unit LevelsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TLevelsForm = class(TForm)
    TypeCB: TComboBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Min: TEdit;
    Nom: TEdit;
    Max: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  LevelsForm: TLevelsForm;

implementation

{$R *.DFM}

end.
