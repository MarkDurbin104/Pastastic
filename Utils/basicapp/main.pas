unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Buttons, ExtCtrls;

type
  TMainForm = class(TForm)
    ToolBar: TPanel;
    StatusPanel: TPanel;
    MainPanel: TPanel;
    Status1: TPanel;
    Status2: TPanel;
    Status3: TPanel;
    OpenButton: TSpeedButton;
    CloseButton: TSpeedButton;
    NewButton: TSpeedButton;
    SaveButton: TSpeedButton;
    CutButton: TSpeedButton;
    CopyButton: TSpeedButton;
    PasteButton: TSpeedButton;
    UndoButton: TSpeedButton;
    RedoButton: TSpeedButton;
    PrintButton: TSpeedButton;
    PPreviewButton: TSpeedButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.DFM}

end.
 