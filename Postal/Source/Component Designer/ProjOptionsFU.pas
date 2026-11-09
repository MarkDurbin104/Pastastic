unit ProjOptionsFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TProjOptions = class(TForm)
    Label1: TLabel;
    ProjectName: TEdit;
    OK: TButton;
    Cancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ProjOptions: TProjOptions;

implementation

{$R *.DFM}

end.
