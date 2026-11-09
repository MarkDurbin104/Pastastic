program ExtQuickRep;


// Last problem "Show the menu properties for a group of controls"

// Once there is a group with different controls,
// the property meny must show the inspector with the commont
// Properties as well as options to alling top, botton, left and right.
// More over the controls mush get the values.

// the problems is, the control in rbuttom down fill the compinspector
// and call the menu in the object ExtQRCommon.

// the information of grouping controls are in ExtHolObj
// and the control doesn´t have this information, provably it has to access through
// the parent class ???????



uses
  Forms,
  ExtQuickRepFU in 'ExtQuickRepFU.pas' {ExtQuickRepForm},
  ExtQRLabelAU in 'ExtQRLabelAU.pas',
  ExtQuickRepAU in 'ExtQuickRepAU.pas',
  InspectorFU in 'InspectorFU.pas' {InspectorForm},
  PaleteFU in 'PaleteFU.pas' {PanelForm},
  ExtRepConst in 'ExtRepConst.pas',
  ExtQRCommon in 'ExtQRCommon.pas',
  ExtQRShapeAU in 'ExtQRShapeAU.pas',
  ExtQRIMageAU in 'ExtQRIMageAU.pas',
  EditButton in 'EditButton.pas',
  ExtQRBandAU in 'ExtQRBandAU.pas',
  CompInspector in 'CompInspector.pas',
  ExtHoldObj in 'ExtHoldObj.pas',
  Counter in 'Counter.pas',
  ExtQRGroupAU in 'ExtQRGroupAU.pas',
  ExtQRDBText in 'ExtQRDBText.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TExtQuickRepForm, ExtQuickRepForm);
  Application.Run;
end.
