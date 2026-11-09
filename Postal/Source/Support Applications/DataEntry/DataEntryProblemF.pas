unit DataEntryProblemF;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls;

type
  TDataEntryProblemForm = class(TForm)
    BottomPanel	: TPanel;
    RightPanel	: TPanel;
    CloseButton	: TButton;
    ClientPanel: TPanel;
    ProblemMemo: TMemo;
    procedure CloseButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DataEntryProblemForm: TDataEntryProblemForm;

implementation

{$R *.DFM}

procedure TDataEntryProblemForm.CloseButtonClick(Sender: TObject);
begin
	Close;
end;

end.
