unit DataEntryF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TDataEntryProblemForm = class(TForm)
    ProblemMemo: TMemo;
    BottomPanel: TPanel;
    RightPanel: TPanel;
    CloseButton: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataEntryProblemForm: TDataEntryProblemForm;

implementation

{$R *.DFM}

end.
