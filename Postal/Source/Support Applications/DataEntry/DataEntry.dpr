program DataEntry;

uses
	Dialogs,
  Forms,
  DataEntryMainF in 'DataEntryMainF.pas' {DataEntryMainForm},
  DataEntryTableF in 'DataEntryTableF.pas' {DataEntryTableForm},
  DataEntryDM in 'DataEntryDM.pas' {DataEntryDataModule: TDataModule},
  DataEntryFormF in 'DataEntryFormF.pas' {DataEntryFormForm},
  DataControlPaletteF in 'DataControlPaletteF.pas' {ControlPaletteForm},
  DragLabelU in 'DragLabelU.pas',
  ComponentUtil in '..\Common\ComponentUtil.pas',
  Graphics in 'D:\borland\Delphi3\Source\Vcl\GRAPHICS.PAS',
  DBCompressImageU in 'DBCompressImageU.pas',
  DataEntryProblemF in 'DataEntryProblemF.pas' {DataEntryProblemForm},
  TwainF in '..\..\Packages\Twain\TwainF.pas' {TwainForm},
  NavOrderF in 'NavOrderF.pas' {NavOrderForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TDataEntryMainForm, DataEntryMainForm);
  Application.CreateForm(TDataEntryDataModule, DataEntryDataModule);
  Application.CreateForm(TDataEntryTableForm, DataEntryTableForm);
  Application.CreateForm(TControlPaletteForm, ControlPaletteForm);
  Application.CreateForm(TDataEntryProblemForm, DataEntryProblemForm);
  Application.CreateForm(TTwainForm, TwainForm);
  Application.CreateForm(TNavOrderForm, NavOrderForm);
  Application.Run;
end.
