unit InspectorFU;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  CompInspector;

type
  TInspectorForm = class(TForm)
    Inspector: TCompInspector;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  InspectorForm: TInspectorForm;

implementation

{$R *.DFM}

end.
