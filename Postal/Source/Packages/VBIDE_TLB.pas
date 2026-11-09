unit VBIDE_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Microsoft Visual Basic for Applications Extensibility 5.3 }
{ Version 5.3 }

{ Conversion log:
  Warning: 'Property' is a reserved word. Property changed to Property_
  Warning: 'Type' is a reserved word. Window.Type changed to Type_
  Warning: 'Type' is a reserved word. _VBProject.Type changed to Type_
  Warning: 'Type' is a reserved word. Parameter 'Type' in _VBProjects.Add changed to 'Type_'
  Warning: 'Type' is a reserved word. _VBComponent_Old.Type changed to Type_
  Warning: 'Object' is a reserved word. Property_.Object changed to Object_
  Warning: 'Object' is a reserved word. AddIn.Object changed to Object_
  Warning: 'String' is a reserved word. Parameter 'String' in _CodeModule.AddFromString changed to 'String_'
  Warning: 'String' is a reserved word. Parameter 'String' in _CodeModule.InsertLines changed to 'String_'
  Warning: 'String' is a reserved word. Parameter 'String' in _CodeModule.ReplaceLine changed to 'String_'
  Warning: 'Type' is a reserved word. Reference.Type changed to Type_
 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL, Office_TLB;

const
  LIBID_VBIDE: TGUID = '{0002E157-0000-0000-C000-000000000046}';

const

{ vbextFileTypes }

  vbextFileTypeForm = 0;
  vbextFileTypeModule = 1;
  vbextFileTypeClass = 2;
  vbextFileTypeProject = 3;
  vbextFileTypeExe = 4;
  vbextFileTypeFrx = 5;
  vbextFileTypeRes = 6;
  vbextFileTypeUserControl = 7;
  vbextFileTypePropertyPage = 8;
  vbextFileTypeDocObject = 9;
  vbextFileTypeBinary = 10;
  vbextFileTypeGroupProject = 11;
  vbextFileTypeDesigners = 12;

{ vbext_WindowType }

  vbext_wt_CodeWindow = 0;
  vbext_wt_Designer = 1;
  vbext_wt_Browser = 2;
  vbext_wt_Watch = 3;
  vbext_wt_Locals = 4;
  vbext_wt_Immediate = 5;
  vbext_wt_ProjectWindow = 6;
  vbext_wt_PropertyWindow = 7;
  vbext_wt_Find = 8;
  vbext_wt_FindReplace = 9;
  vbext_wt_Toolbox = 10;
  vbext_wt_LinkedWindowFrame = 11;
  vbext_wt_MainWindow = 12;
  vbext_wt_ToolWindow = 15;

{ vbext_WindowState }

  vbext_ws_Normal = 0;
  vbext_ws_Minimize = 1;
  vbext_ws_Maximize = 2;

{ vbext_ProjectType }

  vbext_pt_HostProject = 100;
  vbext_pt_StandAlone = 101;

{ vbext_ProjectProtection }

  vbext_pp_none = 0;
  vbext_pp_locked = 1;

{ vbext_VBAMode }

  vbext_vm_Run = 0;
  vbext_vm_Break = 1;
  vbext_vm_Design = 2;

{ vbext_ComponentType }

  vbext_ct_StdModule = 1;
  vbext_ct_ClassModule = 2;
  vbext_ct_MSForm = 3;
  vbext_ct_ActiveXDesigner = 11;
  vbext_ct_Document = 100;

{ vbext_ProcKind }

  vbext_pk_Proc = 0;
  vbext_pk_Let = 1;
  vbext_pk_Set = 2;
  vbext_pk_Get = 3;

{ vbext_CodePaneview }

  vbext_cv_ProcedureView = 0;
  vbext_cv_FullModuleView = 1;

{ vbext_RefKind }

  vbext_rk_TypeLib = 0;
  vbext_rk_Project = 1;

const

{ Component class GUIDs }
  Class_Windows: TGUID = '{0002E185-0000-0000-C000-000000000046}';
  Class_LinkedWindows: TGUID = '{0002E187-0000-0000-C000-000000000046}';
  Class_ReferencesEvents: TGUID = '{0002E119-0000-0000-C000-000000000046}';
  Class_CommandBarEvents: TGUID = '{0002E132-0000-0000-C000-000000000046}';
  Class_ProjectTemplate: TGUID = '{32CDF9E0-1602-11CE-BFDC-08002B2B8CDA}';
  Class_VBProject: TGUID = '{0002E169-0000-0000-C000-000000000046}';
  Class_VBProjects: TGUID = '{0002E101-0000-0000-C000-000000000046}';
  Class_Components: TGUID = '{BE39F3D6-1B13-11D0-887F-00A0C90F2744}';
  Class_VBComponents: TGUID = '{BE39F3D7-1B13-11D0-887F-00A0C90F2744}';
  Class_Component: TGUID = '{BE39F3D8-1B13-11D0-887F-00A0C90F2744}';
  Class_VBComponent: TGUID = '{BE39F3DA-1B13-11D0-887F-00A0C90F2744}';
  Class_Properties: TGUID = '{0002E18B-0000-0000-C000-000000000046}';
  Class_Addins: TGUID = '{DA936B63-AC8B-11D1-B6E5-00A0C90F2744}';
  Class_CodeModule: TGUID = '{0002E170-0000-0000-C000-000000000046}';
  Class_CodePanes: TGUID = '{0002E174-0000-0000-C000-000000000046}';
  Class_CodePane: TGUID = '{0002E178-0000-0000-C000-000000000046}';
  Class_References: TGUID = '{0002E17C-0000-0000-C000-000000000046}';

type

{ Forward declarations: Interfaces }
  Application = interface;
  ApplicationDisp = dispinterface;
  VBE = interface;
  VBEDisp = dispinterface;
  Window = interface;
  WindowDisp = dispinterface;
  _Windows_old = interface;
  _Windows_oldDisp = dispinterface;
  _Windows = interface;
  _WindowsDisp = dispinterface;
  _LinkedWindows = interface;
  _LinkedWindowsDisp = dispinterface;
  Events = interface;
  EventsDisp = dispinterface;
  _VBProjectsEvents = interface;
  _dispVBProjectsEvents = dispinterface;
  _VBComponentsEvents = interface;
  _dispVBComponentsEvents = dispinterface;
  _ReferencesEvents = interface;
  _dispReferencesEvents = dispinterface;
  _CommandBarControlEvents = interface;
  _dispCommandBarControlEvents = dispinterface;
  _ProjectTemplate = interface;
  _ProjectTemplateDisp = dispinterface;
  _VBProject_Old = interface;
  _VBProject_OldDisp = dispinterface;
  _VBProject = interface;
  _VBProjectDisp = dispinterface;
  _VBProjects_Old = interface;
  _VBProjects_OldDisp = dispinterface;
  _VBProjects = interface;
  _VBProjectsDisp = dispinterface;
  SelectedComponents = interface;
  SelectedComponentsDisp = dispinterface;
  _Components = interface;
  _ComponentsDisp = dispinterface;
  _VBComponents_Old = interface;
  _VBComponents_OldDisp = dispinterface;
  _VBComponents = interface;
  _VBComponentsDisp = dispinterface;
  _Component = interface;
  _ComponentDisp = dispinterface;
  _VBComponent_Old = interface;
  _VBComponent_OldDisp = dispinterface;
  _VBComponent = interface;
  _VBComponentDisp = dispinterface;
  Property_ = interface;
  Property_Disp = dispinterface;
  _Properties = interface;
  _PropertiesDisp = dispinterface;
  _AddIns = interface;
  _AddInsDisp = dispinterface;
  AddIn = interface;
  AddInDisp = dispinterface;
  _CodeModule = interface;
  _CodeModuleDisp = dispinterface;
  _CodePanes = interface;
  _CodePanesDisp = dispinterface;
  _CodePane = interface;
  _CodePaneDisp = dispinterface;
  _References = interface;
  _ReferencesDisp = dispinterface;
  Reference = interface;
  ReferenceDisp = dispinterface;
  _dispReferences_Events = dispinterface;

{ Forward declarations: CoClasses }
  Windows = _Windows;
  LinkedWindows = _LinkedWindows;
  ReferencesEvents = _ReferencesEvents;
  CommandBarEvents = _CommandBarControlEvents;
  ProjectTemplate = _ProjectTemplate;
  VBProject = _VBProject;
  VBProjects = _VBProjects;
  Components = _Components;
  VBComponents = _VBComponents;
  Component = _Component;
  VBComponent = _VBComponent;
  Properties = _Properties;
  Addins = _AddIns;
  CodeModule = _CodeModule;
  CodePanes = _CodePanes;
  CodePane = _CodePane;
  References = _References;

{ Forward declarations: Enums }
  vbextFileTypes = TOleEnum;
  vbext_WindowType = TOleEnum;
  vbext_WindowState = TOleEnum;
  vbext_ProjectType = TOleEnum;
  vbext_ProjectProtection = TOleEnum;
  vbext_VBAMode = TOleEnum;
  vbext_ComponentType = TOleEnum;
  vbext_ProcKind = TOleEnum;
  vbext_CodePaneview = TOleEnum;
  vbext_RefKind = TOleEnum;

  Application = interface(IDispatch)
    ['{0002E158-0000-0000-C000-000000000046}']
    function Get_Version: WideString; safecall;
    property Version: WideString read Get_Version;
  end;

{ DispInterface declaration for Dual Interface Application }

  ApplicationDisp = dispinterface
    ['{0002E158-0000-0000-C000-000000000046}']
    property Version: WideString readonly dispid 100;
  end;

  VBE = interface(Application)
    ['{0002E166-0000-0000-C000-000000000046}']
    function Get_VBProjects: VBProjects; safecall;
    function Get_CommandBars: _CommandBars; safecall;
    function Get_CodePanes: CodePanes; safecall;
    function Get_Windows: Windows; safecall;
    function Get_Events: Events; safecall;
    function Get_ActiveVBProject: VBProject; safecall;
    procedure Set_ActiveVBProject(var Value: VBProject); safecall;
    function Get_SelectedVBComponent: VBComponent; safecall;
    function Get_MainWindow: Window; safecall;
    function Get_ActiveWindow: Window; safecall;
    function Get_ActiveCodePane: CodePane; safecall;
    procedure Set_ActiveCodePane(var Value: CodePane); safecall;
    function Get_Addins: Addins; safecall;
    property VBProjects: VBProjects read Get_VBProjects;
    property CommandBars: _CommandBars read Get_CommandBars;
    property CodePanes: CodePanes read Get_CodePanes;
    property Windows: Windows read Get_Windows;
    property Events: Events read Get_Events;
    property ActiveVBProject: VBProject read Get_ActiveVBProject write Set_ActiveVBProject;
    property SelectedVBComponent: VBComponent read Get_SelectedVBComponent;
    property MainWindow: Window read Get_MainWindow;
    property ActiveWindow: Window read Get_ActiveWindow;
    property ActiveCodePane: CodePane read Get_ActiveCodePane write Set_ActiveCodePane;
    property Addins: Addins read Get_Addins;
  end;

{ DispInterface declaration for Dual Interface VBE }

  VBEDisp = dispinterface
    ['{0002E166-0000-0000-C000-000000000046}']
    property Version: WideString readonly dispid 100;
    property VBProjects: VBProjects readonly dispid 107;
    property CommandBars: _CommandBars readonly dispid 108;
    property CodePanes: CodePanes readonly dispid 109;
    property Windows: Windows readonly dispid 110;
    property Events: Events readonly dispid 111;
    property ActiveVBProject: VBProject dispid 201;
    property SelectedVBComponent: VBComponent readonly dispid 202;
    property MainWindow: Window readonly dispid 204;
    property ActiveWindow: Window readonly dispid 205;
    property ActiveCodePane: CodePane dispid 206;
    property Addins: Addins readonly dispid 209;
  end;

  Window = interface(IDispatch)
    ['{0002E16B-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Collection: Windows; safecall;
    procedure Close; safecall;
    function Get_Caption: WideString; safecall;
    function Get_Visible: WordBool; safecall;
    procedure Set_Visible(Value: WordBool); safecall;
    function Get_Left: Integer; safecall;
    procedure Set_Left(Value: Integer); safecall;
    function Get_Top: Integer; safecall;
    procedure Set_Top(Value: Integer); safecall;
    function Get_Width: Integer; safecall;
    procedure Set_Width(Value: Integer); safecall;
    function Get_Height: Integer; safecall;
    procedure Set_Height(Value: Integer); safecall;
    function Get_WindowState: vbext_WindowState; safecall;
    procedure Set_WindowState(Value: vbext_WindowState); safecall;
    procedure SetFocus; safecall;
    function Get_Type_: vbext_WindowType; safecall;
    procedure SetKind(eKind: vbext_WindowType); safecall;
    function Get_LinkedWindows: LinkedWindows; safecall;
    function Get_LinkedWindowFrame: Window; safecall;
    procedure Detach; safecall;
    procedure Attach(lWindowHandle: Integer); safecall;
    function Get_HWnd: Integer; safecall;
    property VBE: VBE read Get_VBE;
    property Collection: Windows read Get_Collection;
    property Caption: WideString read Get_Caption;
    property Visible: WordBool read Get_Visible write Set_Visible;
    property Left: Integer read Get_Left write Set_Left;
    property Top: Integer read Get_Top write Set_Top;
    property Width: Integer read Get_Width write Set_Width;
    property Height: Integer read Get_Height write Set_Height;
    property WindowState: vbext_WindowState read Get_WindowState write Set_WindowState;
    property Type_: vbext_WindowType read Get_Type_;
    property LinkedWindows: LinkedWindows read Get_LinkedWindows;
    property LinkedWindowFrame: Window read Get_LinkedWindowFrame;
    property HWnd: Integer read Get_HWnd;
  end;

{ DispInterface declaration for Dual Interface Window }

  WindowDisp = dispinterface
    ['{0002E16B-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Collection: Windows readonly dispid 2;
    procedure Close; dispid 99;
    property Caption: WideString readonly dispid 100;
    property Visible: WordBool dispid 106;
    property Left: Integer dispid 101;
    property Top: Integer dispid 103;
    property Width: Integer dispid 105;
    property Height: Integer dispid 107;
    property WindowState: vbext_WindowState dispid 109;
    procedure SetFocus; dispid 111;
    property Type_: vbext_WindowType readonly dispid 112;
    property LinkedWindows: LinkedWindows readonly dispid 116;
    property LinkedWindowFrame: Window readonly dispid 117;
    property HWnd: Integer readonly dispid 120;
  end;

  _Windows_old = interface(IDispatch)
    ['{0002E16A-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Parent: Application; safecall;
    function Item(index: OleVariant): Window; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property VBE: VBE read Get_VBE;
    property Parent: Application read Get_Parent;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface _Windows_old }

  _Windows_oldDisp = dispinterface
    ['{0002E16A-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Parent: Application readonly dispid 2;
    function Item(index: OleVariant): Window; dispid 0;
    property Count: Integer readonly dispid 201;
  end;

  _Windows = interface(_Windows_old)
    ['{F57B7ED0-D8AB-11D1-85DF-00C04F98F42C}']
    function CreateToolWindow(const AddInInst: AddIn; const ProgId, Caption, GuidPosition: WideString; var DocObj: IDispatch): Window; safecall;
  end;

{ DispInterface declaration for Dual Interface _Windows }

  _WindowsDisp = dispinterface
    ['{F57B7ED0-D8AB-11D1-85DF-00C04F98F42C}']
    property VBE: VBE readonly dispid 1;
    property Parent: Application readonly dispid 2;
    function Item(index: OleVariant): Window; dispid 0;
    property Count: Integer readonly dispid 201;
    function CreateToolWindow(const AddInInst: AddIn; const ProgId, Caption, GuidPosition: WideString; var DocObj: IDispatch): Window; dispid 300;
  end;

  _LinkedWindows = interface(IDispatch)
    ['{0002E16C-0000-0000-C000-000000000046}']
    function Get_VBE: VBE; safecall;
    function Get_Parent: Window; safecall;
    function Item(index: OleVariant): Window; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const Window: Window); safecall;
    procedure Add(const Window: Window); safecall;
    property VBE: VBE read Get_VBE;
    property Parent: Window read Get_Parent;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface _LinkedWindows }

  _LinkedWindowsDisp = dispinterface
    ['{0002E16C-0000-0000-C000-000000000046}']
    property VBE: VBE readonly dispid 1;
    property Parent: Window readonly dispid 2;
    function Item(index: OleVariant): Window; dispid 0;
    property Count: Integer readonly dispid 201;
    procedure Remove(const Window: Window); dispid 202;
    procedure Add(const Window: Window); dispid 203;
  end;

  Events = interface(IDispatch)
    ['{0002E167-0000-0000-C000-000000000046}']
    function Get_ReferencesEvents(const VBProject: VBProject): ReferencesEvents; safecall;
    function Get_CommandBarEvents(CommandBarControl: IDispatch): CommandBarEvents; safecall;
    property ReferencesEvents[const VBProject: VBProject]: ReferencesEvents read Get_ReferencesEvents;
    property CommandBarEvents[CommandBarControl: IDispatch]: CommandBarEvents read Get_CommandBarEvents;
  end;

{ DispInterface declaration for Dual Interface Events }

  EventsDisp = dispinterface
    ['{0002E167-0000-0000-C000-000000000046}']
    property ReferencesEvents[const VBProject: VBProject]: ReferencesEvents readonly dispid 202;
    property CommandBarEvents[CommandBarControl: IDispatch]: CommandBarEvents readonly dispid 205;
  end;

  _VBProjectsEvents = interface(IUnknown)
    ['{0002E113-0000-0000-C000-000000000046}']
  end;

  _dispVBProjectsEvents = dispinterface
    ['{0002E103-0000-0000-C000-000000000046}']
    procedure ItemAdded(const VBProject: VBProject); dispid 1;
    procedure ItemRemoved(const VBProject: VBProject); dispid 2;
    procedure ItemRenamed(const VBProject: VBProject; const OldName: WideString); dispid 3;
    procedure ItemActivated(const VBProject: VBProject); dispid 4;
  end;

  _VBComponentsEvents = interface(IUnknown)
    ['{0002E115-0000-0000-C000-000000000046}']
  end;

  _dispVBComponentsEvents = dispinterface
    ['{0002E116-0000-0000-C000-000000000046}']
    procedure ItemAdded(const VBComponent: VBComponent); dispid 1;
    procedure ItemRemoved(const VBComponent: VBComponent); dispid 2;
    procedure ItemRenamed(const VBComponent: VBComponent; const OldName: WideString); dispid 3;
    procedure ItemSelected(const VBComponent: VBComponent); dispid 4;
    procedure ItemActivated(const VBComponent: VBComponent); dispid 5;
    procedure ItemReloaded(const VBComponent: VBComponent); dispid 6;
  end;

  _ReferencesEvents = interface(IUnknown)
    ['{0002E11A-0000-0000-C000-000000000046}']
  end;

  _dispReferencesEvents = dispinterface
    ['{0002E118-0000-0000-C000-000000000046}']
    procedure ItemAdded(const Reference: Reference); dispid 1;
    procedure ItemRemoved(const Reference: Reference); dispid 2;
  end;

  _CommandBarControlEvents = interface(IUnknown)
    ['{0002E130-0000-0000-C000-000000000046}']
  end;

  _dispCommandBarControlEvents = dispinterface
    ['{0002E131-0000-0000-C000-000000000046}']
    procedure Click(CommandBarControl: IDispatch; var handled, CancelDefault: WordBool); dispid 1;
  end;

  _ProjectTemplate = interface(IDispatch)
    ['{0002E159-0000-0000-C000-000000000046}']
    function Get_Application: Application; safecall;
    function Get_Parent: Application; safecall;
    property Application: Application read Get_Application;
    property Parent: Application read Get_Parent;
  end;

{ DispInterface declaration for Dual Interface _ProjectTemplate }

  _ProjectTemplateDisp = dispinterface
    ['{0002E159-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 1;
    property Parent: Application readonly dispid 2;
  end;

  _VBProject_Old = interface(_ProjectTemplate)
    ['{0002E160-0000-0000-C000-000000000046}']
    function Get_HelpFile: WideString; safecall;
    procedure Set_HelpFile(const Value: WideString); safecall;
    function Get_HelpContextID: Integer; safecall;
    procedure Set_HelpContextID(Value: Integer); safecall;
    function Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function Get_Mode: vbext_VBAMode; safecall;
    function Get_References: References; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: VBProjects; safecall;
    function Get_Protection: vbext_ProjectProtection; safecall;
    function Get_Saved: WordBool; safecall;
    function Get_VBComponents: VBComponents; safecall;
    property HelpFile: WideString read Get_HelpFile write Set_HelpFile;
    property HelpContextID: Integer read Get_HelpContextID write Set_HelpContextID;
    property Description: WideString read Get_Description write Set_Description;
    property Mode: vbext_VBAMode read Get_Mode;
    property References: References read Get_References;
    property Name: WideString read Get_Name write Set_Name;
    property VBE: VBE read Get_VBE;
    property Collection: VBProjects read Get_Collection;
    property Protection: vbext_ProjectProtection read Get_Protection;
    property Saved: WordBool read Get_Saved;
    property VBComponents: VBComponents read Get_VBComponents;
  end;

{ DispInterface declaration for Dual Interface _VBProject_Old }

  _VBProject_OldDisp = dispinterface
    ['{0002E160-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 1;
    property Parent: Application readonly dispid 2;
    property HelpFile: WideString dispid 116;
    property HelpContextID: Integer dispid 117;
    property Description: WideString dispid 118;
    property Mode: vbext_VBAMode readonly dispid 119;
    property References: References readonly dispid 120;
    property Name: WideString dispid 121;
    property VBE: VBE readonly dispid 122;
    property Collection: VBProjects readonly dispid 123;
    property Protection: vbext_ProjectProtection readonly dispid 131;
    property Saved: WordBool readonly dispid 133;
    property VBComponents: VBComponents readonly dispid 135;
  end;

  _VBProject = interface(_VBProject_Old)
    ['{EEE00915-E393-11D1-BB03-00C04FB6C4A6}']
    procedure SaveAs(const FileName: WideString); safecall;
    procedure MakeCompiledFile; safecall;
    function Get_Type_: vbext_ProjectType; safecall;
    function Get_FileName: WideString; safecall;
    function Get_BuildFileName: WideString; safecall;
    procedure Set_BuildFileName(const Value: WideString); safecall;
    property Type_: vbext_ProjectType read Get_Type_;
    property FileName: WideString read Get_FileName;
    property BuildFileName: WideString read Get_BuildFileName write Set_BuildFileName;
  end;

{ DispInterface declaration for Dual Interface _VBProject }

  _VBProjectDisp = dispinterface
    ['{EEE00915-E393-11D1-BB03-00C04FB6C4A6}']
    property Application: Application readonly dispid 1;
    property Parent: Application readonly dispid 2;
    property HelpFile: WideString dispid 116;
    property HelpContextID: Integer dispid 117;
    property Description: WideString dispid 118;
    property Mode: vbext_VBAMode readonly dispid 119;
    property References: References readonly dispid 120;
    property Name: WideString dispid 121;
    property VBE: VBE readonly dispid 122;
    property Collection: VBProjects readonly dispid 123;
    property Protection: vbext_ProjectProtection readonly dispid 131;
    property Saved: WordBool readonly dispid 133;
    property VBComponents: VBComponents readonly dispid 135;
    procedure SaveAs(const FileName: WideString); dispid 138;
    procedure MakeCompiledFile; dispid 139;
    property Type_: vbext_ProjectType readonly dispid 140;
    property FileName: WideString readonly dispid 141;
    property BuildFileName: WideString dispid 142;
  end;

  _VBProjects_Old = interface(IDispatch)
    ['{0002E165-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBProject; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Parent: VBE; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property VBE: VBE read Get_VBE;
    property Parent: VBE read Get_Parent;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface _VBProjects_Old }

  _VBProjects_OldDisp = dispinterface
    ['{0002E165-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBProject; dispid 0;
    property VBE: VBE readonly dispid 20;
    property Parent: VBE readonly dispid 2;
    property Count: Integer readonly dispid 10;
  end;

  _VBProjects = interface(_VBProjects_Old)
    ['{EEE00919-E393-11D1-BB03-00C04FB6C4A6}']
    function Add(Type_: vbext_ProjectType): VBProject; safecall;
    procedure Remove(const lpc: VBProject); safecall;
    function Open(const bstrPath: WideString): VBProject; safecall;
  end;

{ DispInterface declaration for Dual Interface _VBProjects }

  _VBProjectsDisp = dispinterface
    ['{EEE00919-E393-11D1-BB03-00C04FB6C4A6}']
    function Item(index: OleVariant): VBProject; dispid 0;
    property VBE: VBE readonly dispid 20;
    property Parent: VBE readonly dispid 2;
    property Count: Integer readonly dispid 10;
    function Add(Type_: vbext_ProjectType): VBProject; dispid 137;
    procedure Remove(const lpc: VBProject); dispid 138;
    function Open(const bstrPath: WideString): VBProject; dispid 139;
  end;

  SelectedComponents = interface(IDispatch)
    ['{BE39F3D4-1B13-11D0-887F-00A0C90F2744}']
    function Item(index: SYSINT): Component; safecall;
    function Get_Application: Application; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    property Application: Application read Get_Application;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface SelectedComponents }

  SelectedComponentsDisp = dispinterface
    ['{BE39F3D4-1B13-11D0-887F-00A0C90F2744}']
    function Item(index: SYSINT): Component; dispid 0;
    property Application: Application readonly dispid 1;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
  end;

  _Components = interface(IDispatch)
    ['{0002E161-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Component; safecall;
    function Get_Application: Application; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const Component: Component); safecall;
    function Add(ComponentType: vbext_ComponentType): Component; safecall;
    function Import(const FileName: WideString): Component; safecall;
    function Get_VBE: VBE; safecall;
    property Application: Application read Get_Application;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

{ DispInterface declaration for Dual Interface _Components }

  _ComponentsDisp = dispinterface
    ['{0002E161-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Component; dispid 0;
    property Application: Application readonly dispid 1;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    procedure Remove(const Component: Component); dispid 11;
    function Add(ComponentType: vbext_ComponentType): Component; dispid 12;
    function Import(const FileName: WideString): Component; dispid 13;
    property VBE: VBE readonly dispid 20;
  end;

  _VBComponents_Old = interface(IDispatch)
    ['{0002E162-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBComponent; safecall;
    function Get_Parent: VBProject; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Remove(const VBComponent: VBComponent); safecall;
    function Add(ComponentType: vbext_ComponentType): VBComponent; safecall;
    function Import(const FileName: WideString): VBComponent; safecall;
    function Get_VBE: VBE; safecall;
    property Parent: VBProject read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

{ DispInterface declaration for Dual Interface _VBComponents_Old }

  _VBComponents_OldDisp = dispinterface
    ['{0002E162-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): VBComponent; dispid 0;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    procedure Remove(const VBComponent: VBComponent); dispid 11;
    function Add(ComponentType: vbext_ComponentType): VBComponent; dispid 12;
    function Import(const FileName: WideString): VBComponent; dispid 13;
    property VBE: VBE readonly dispid 20;
  end;

  _VBComponents = interface(_VBComponents_Old)
    ['{EEE0091C-E393-11D1-BB03-00C04FB6C4A6}']
    function AddCustom(const ProgId: WideString): VBComponent; safecall;
    function AddMTDesigner(index: Integer): VBComponent; safecall;
  end;

{ DispInterface declaration for Dual Interface _VBComponents }

  _VBComponentsDisp = dispinterface
    ['{EEE0091C-E393-11D1-BB03-00C04FB6C4A6}']
    function Item(index: OleVariant): VBComponent; dispid 0;
    property Parent: VBProject readonly dispid 2;
    property Count: Integer readonly dispid 10;
    procedure Remove(const VBComponent: VBComponent); dispid 11;
    function Add(ComponentType: vbext_ComponentType): VBComponent; dispid 12;
    function Import(const FileName: WideString): VBComponent; dispid 13;
    property VBE: VBE readonly dispid 20;
    function AddCustom(const ProgId: WideString): VBComponent; dispid 25;
    function AddMTDesigner(index: Integer): VBComponent; dispid 26;
  end;

  _Component = interface(IDispatch)
    ['{0002E163-0000-0000-C000-000000000046}']
    function Get_Application: Application; safecall;
    function Get_Parent: Components; safecall;
    function Get_IsDirty: WordBool; safecall;
    procedure Set_IsDirty(Value: WordBool); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    property Application: Application read Get_Application;
    property Parent: Components read Get_Parent;
    property IsDirty: WordBool read Get_IsDirty write Set_IsDirty;
    property Name: WideString read Get_Name write Set_Name;
  end;

{ DispInterface declaration for Dual Interface _Component }

  _ComponentDisp = dispinterface
    ['{0002E163-0000-0000-C000-000000000046}']
    property Application: Application readonly dispid 1;
    property Parent: Components readonly dispid 2;
    property IsDirty: WordBool dispid 10;
    property Name: WideString dispid 48;
  end;

  _VBComponent_Old = interface(IDispatch)
    ['{0002E164-0000-0000-C000-000000000046}']
    function Get_Saved: WordBool; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Designer: IDispatch; safecall;
    function Get_CodeModule: CodeModule; safecall;
    function Get_Type_: vbext_ComponentType; safecall;
    procedure Export(const FileName: WideString); safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: VBComponents; safecall;
    function Get_HasOpenDesigner: WordBool; safecall;
    function Get_Properties: Properties; safecall;
    function DesignerWindow: Window; safecall;
    procedure Activate; safecall;
    property Saved: WordBool read Get_Saved;
    property Name: WideString read Get_Name write Set_Name;
    property Designer: IDispatch read Get_Designer;
    property CodeModule: CodeModule read Get_CodeModule;
    property Type_: vbext_ComponentType read Get_Type_;
    property VBE: VBE read Get_VBE;
    property Collection: VBComponents read Get_Collection;
    property HasOpenDesigner: WordBool read Get_HasOpenDesigner;
    property Properties: Properties read Get_Properties;
  end;

{ DispInterface declaration for Dual Interface _VBComponent_Old }

  _VBComponent_OldDisp = dispinterface
    ['{0002E164-0000-0000-C000-000000000046}']
    property Saved: WordBool readonly dispid 10;
    property Name: WideString dispid 48;
    property Designer: IDispatch readonly dispid 49;
    property CodeModule: CodeModule readonly dispid 50;
    property Type_: vbext_ComponentType readonly dispid 51;
    procedure Export(const FileName: WideString); dispid 52;
    property VBE: VBE readonly dispid 53;
    property Collection: VBComponents readonly dispid 54;
    property HasOpenDesigner: WordBool readonly dispid 55;
    property Properties: Properties readonly dispid 56;
    function DesignerWindow: Window; dispid 57;
    procedure Activate; dispid 60;
  end;

  _VBComponent = interface(_VBComponent_Old)
    ['{EEE00921-E393-11D1-BB03-00C04FB6C4A6}']
    function Get_DesignerID: WideString; safecall;
    property DesignerID: WideString read Get_DesignerID;
  end;

{ DispInterface declaration for Dual Interface _VBComponent }

  _VBComponentDisp = dispinterface
    ['{EEE00921-E393-11D1-BB03-00C04FB6C4A6}']
    property Saved: WordBool readonly dispid 10;
    property Name: WideString dispid 48;
    property Designer: IDispatch readonly dispid 49;
    property CodeModule: CodeModule readonly dispid 50;
    property Type_: vbext_ComponentType readonly dispid 51;
    procedure Export(const FileName: WideString); dispid 52;
    property VBE: VBE readonly dispid 53;
    property Collection: VBComponents readonly dispid 54;
    property HasOpenDesigner: WordBool readonly dispid 55;
    property Properties: Properties readonly dispid 56;
    function DesignerWindow: Window; dispid 57;
    procedure Activate; dispid 60;
    property DesignerID: WideString readonly dispid 64;
  end;

  Property_ = interface(IDispatch)
    ['{0002E18C-0000-0000-C000-000000000046}']
    function Get_Value: OleVariant; safecall;
    procedure Set_Value(Value: OleVariant); safecall;
    function Get_IndexedValue(Index1, Index2, Index3, Index4: OleVariant): OleVariant; safecall;
    procedure Set_IndexedValue(Index1, Index2, Index3, Index4: OleVariant; Value: OleVariant); safecall;
    function Get_NumIndices: Smallint; safecall;
    function Get_Application: Application; safecall;
    function Get_Parent: Properties; safecall;
    function Get_Name: WideString; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: Properties; safecall;
    function Get_Object_: IUnknown; safecall;
    procedure Set_Object_(var Value: IUnknown); safecall;
    property Value: OleVariant read Get_Value write Set_Value;
    property IndexedValue[Index1, Index2, Index3, Index4: OleVariant]: OleVariant read Get_IndexedValue write Set_IndexedValue;
    property NumIndices: Smallint read Get_NumIndices;
    property Application: Application read Get_Application;
    property Parent: Properties read Get_Parent;
    property Name: WideString read Get_Name;
    property VBE: VBE read Get_VBE;
    property Collection: Properties read Get_Collection;
    property Object_: IUnknown read Get_Object_ write Set_Object_;
  end;

{ DispInterface declaration for Dual Interface Property_ }

  Property_Disp = dispinterface
    ['{0002E18C-0000-0000-C000-000000000046}']
    property Value: OleVariant dispid 0;
    property IndexedValue[Index1, Index2, Index3, Index4: OleVariant]: OleVariant dispid 3;
    property NumIndices: Smallint readonly dispid 4;
    property Application: Application readonly dispid 1;
    property Parent: Properties readonly dispid 2;
    property Name: WideString readonly dispid 40;
    property VBE: VBE readonly dispid 41;
    property Collection: Properties readonly dispid 42;
    property Object_: IUnknown dispid 45;
  end;

  _Properties = interface(IDispatch)
    ['{0002E188-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Property_; safecall;
    function Get_Application: Application; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function Get_VBE: VBE; safecall;
    property Application: Application read Get_Application;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
    property VBE: VBE read Get_VBE;
  end;

{ DispInterface declaration for Dual Interface _Properties }

  _PropertiesDisp = dispinterface
    ['{0002E188-0000-0000-C000-000000000046}']
    function Item(index: OleVariant): Property_; dispid 0;
    property Application: Application readonly dispid 1;
    property Parent: IDispatch readonly dispid 2;
    property Count: Integer readonly dispid 40;
    property VBE: VBE readonly dispid 10;
  end;

  _AddIns = interface(IDispatch)
    ['{DA936B62-AC8B-11D1-B6E5-00A0C90F2744}']
    function Item(index: OleVariant): AddIn; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Parent: IDispatch; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    procedure Update; safecall;
    property VBE: VBE read Get_VBE;
    property Parent: IDispatch read Get_Parent;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface _AddIns }

  _AddInsDisp = dispinterface
    ['{DA936B62-AC8B-11D1-B6E5-00A0C90F2744}']
    function Item(index: OleVariant): AddIn; dispid 0;
    property VBE: VBE readonly dispid 1;
    property Parent: IDispatch readonly dispid 2;
    property Count: Integer readonly dispid 40;
    procedure Update; dispid 41;
  end;

  AddIn = interface(IDispatch)
    ['{DA936B64-AC8B-11D1-B6E5-00A0C90F2744}']
    function Get_Description: WideString; safecall;
    procedure Set_Description(const Value: WideString); safecall;
    function Get_VBE: VBE; safecall;
    function Get_Collection: Addins; safecall;
    function Get_ProgId: WideString; safecall;
    function Get_Guid: WideString; safecall;
    function Get_Connect: WordBool; safecall;
    procedure Set_Connect(Value: WordBool); safecall;
    function Get_Object_: IDispatch; safecall;
    procedure Set_Object_(Value: IDispatch); safecall;
    property Description: WideString read Get_Description write Set_Description;
    property VBE: VBE read Get_VBE;
    property Collection: Addins read Get_Collection;
    property ProgId: WideString read Get_ProgId;
    property Guid: WideString read Get_Guid;
    property Connect: WordBool read Get_Connect write Set_Connect;
    property Object_: IDispatch read Get_Object_ write Set_Object_;
  end;

{ DispInterface declaration for Dual Interface AddIn }

  AddInDisp = dispinterface
    ['{DA936B64-AC8B-11D1-B6E5-00A0C90F2744}']
    property Description: WideString dispid 0;
    property VBE: VBE readonly dispid 1;
    property Collection: Addins readonly dispid 2;
    property ProgId: WideString readonly dispid 3;
    property Guid: WideString readonly dispid 4;
    property Connect: WordBool dispid 6;
    property Object_: IDispatch dispid 7;
  end;

  _CodeModule = interface(IDispatch)
    ['{0002E16E-0000-0000-C000-000000000046}']
    function Get_Parent: VBComponent; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure AddFromString(const String_: WideString); safecall;
    procedure AddFromFile(const FileName: WideString); safecall;
    function Get_Lines(StartLine, Count: Integer): WideString; safecall;
    function Get_CountOfLines: Integer; safecall;
    procedure InsertLines(Line: Integer; const String_: WideString); safecall;
    procedure DeleteLines(StartLine, Count: Integer); safecall;
    procedure ReplaceLine(Line: Integer; const String_: WideString); safecall;
    function Get_ProcStartLine(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcCountLines(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcBodyLine(const ProcName: WideString; ProcKind: vbext_ProcKind): Integer; safecall;
    function Get_ProcOfLine(Line: Integer; out ProcKind: vbext_ProcKind): WideString; safecall;
    function Get_CountOfDeclarationLines: Integer; safecall;
    function CreateEventProc(const EventName, ObjectName: WideString): Integer; safecall;
    function Find(const Target: WideString; var StartLine, StartColumn, EndLine, EndColumn: Integer; WholeWord, MatchCase, PatternSearch: WordBool): WordBool; safecall;
    function Get_CodePane: CodePane; safecall;
    property Parent: VBComponent read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Name: WideString read Get_Name write Set_Name;
    property Lines[StartLine, Count: Integer]: WideString read Get_Lines;
    property CountOfLines: Integer read Get_CountOfLines;
    property ProcStartLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcStartLine;
    property ProcCountLines[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcCountLines;
    property ProcBodyLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer read Get_ProcBodyLine;
    property ProcOfLine[Line: Integer; out ProcKind: vbext_ProcKind]: WideString read Get_ProcOfLine;
    property CountOfDeclarationLines: Integer read Get_CountOfDeclarationLines;
    property CodePane: CodePane read Get_CodePane;
  end;

{ DispInterface declaration for Dual Interface _CodeModule }

  _CodeModuleDisp = dispinterface
    ['{0002E16E-0000-0000-C000-000000000046}']
    property Parent: VBComponent readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Name: WideString dispid 0;
    procedure AddFromString(const String_: WideString); dispid 1610743812;
    procedure AddFromFile(const FileName: WideString); dispid 1610743813;
    property Lines[StartLine, Count: Integer]: WideString readonly dispid 1610743814;
    property CountOfLines: Integer readonly dispid 1610743815;
    procedure InsertLines(Line: Integer; const String_: WideString); dispid 1610743816;
    procedure DeleteLines(StartLine, Count: Integer); dispid 1610743817;
    procedure ReplaceLine(Line: Integer; const String_: WideString); dispid 1610743818;
    property ProcStartLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743819;
    property ProcCountLines[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743820;
    property ProcBodyLine[const ProcName: WideString; ProcKind: vbext_ProcKind]: Integer readonly dispid 1610743821;
    property ProcOfLine[Line: Integer; out ProcKind: vbext_ProcKind]: WideString readonly dispid 1610743822;
    property CountOfDeclarationLines: Integer readonly dispid 1610743823;
    function CreateEventProc(const EventName, ObjectName: WideString): Integer; dispid 1610743824;
    function Find(const Target: WideString; var StartLine, StartColumn, EndLine, EndColumn: Integer; WholeWord, MatchCase, PatternSearch: WordBool): WordBool; dispid 1610743825;
    property CodePane: CodePane readonly dispid 1610743826;
  end;

  _CodePanes = interface(IDispatch)
    ['{0002E172-0000-0000-C000-000000000046}']
    function Get_Parent: VBE; safecall;
    function Get_VBE: VBE; safecall;
    function Item(index: OleVariant): CodePane; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function Get_Current: CodePane; safecall;
    procedure Set_Current(const Value: CodePane); safecall;
    property Parent: VBE read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Count: Integer read Get_Count;
    property Current: CodePane read Get_Current write Set_Current;
  end;

{ DispInterface declaration for Dual Interface _CodePanes }

  _CodePanesDisp = dispinterface
    ['{0002E172-0000-0000-C000-000000000046}']
    property Parent: VBE readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    function Item(index: OleVariant): CodePane; dispid 0;
    property Count: Integer readonly dispid 1610743811;
    function _NewEnum: IUnknown; dispid -4;
    property Current: CodePane dispid 1610743813;
  end;

  _CodePane = interface(IDispatch)
    ['{0002E176-0000-0000-C000-000000000046}']
    function Get_Collection: CodePanes; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Window: Window; safecall;
    procedure GetSelection(out StartLine, StartColumn, EndLine, EndColumn: Integer); safecall;
    procedure SetSelection(StartLine, StartColumn, EndLine, EndColumn: Integer); safecall;
    function Get_TopLine: Integer; safecall;
    procedure Set_TopLine(Value: Integer); safecall;
    function Get_CountOfVisibleLines: Integer; safecall;
    function Get_CodeModule: CodeModule; safecall;
    procedure Show; safecall;
    function Get_CodePaneView: vbext_CodePaneview; safecall;
    property Collection: CodePanes read Get_Collection;
    property VBE: VBE read Get_VBE;
    property Window: Window read Get_Window;
    property TopLine: Integer read Get_TopLine write Set_TopLine;
    property CountOfVisibleLines: Integer read Get_CountOfVisibleLines;
    property CodeModule: CodeModule read Get_CodeModule;
    property CodePaneView: vbext_CodePaneview read Get_CodePaneView;
  end;

{ DispInterface declaration for Dual Interface _CodePane }

  _CodePaneDisp = dispinterface
    ['{0002E176-0000-0000-C000-000000000046}']
    property Collection: CodePanes readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Window: Window readonly dispid 1610743810;
    procedure GetSelection(out StartLine, StartColumn, EndLine, EndColumn: Integer); dispid 1610743811;
    procedure SetSelection(StartLine, StartColumn, EndLine, EndColumn: Integer); dispid 1610743812;
    property TopLine: Integer dispid 1610743813;
    property CountOfVisibleLines: Integer readonly dispid 1610743815;
    property CodeModule: CodeModule readonly dispid 1610743816;
    procedure Show; dispid 1610743817;
    property CodePaneView: vbext_CodePaneview readonly dispid 1610743818;
  end;

  _References = interface(IDispatch)
    ['{0002E17A-0000-0000-C000-000000000046}']
    function Get_Parent: VBProject; safecall;
    function Get_VBE: VBE; safecall;
    function Item(index: OleVariant): Reference; safecall;
    function Get_Count: Integer; safecall;
    function _NewEnum: IUnknown; safecall;
    function AddFromGuid(const Guid: WideString; Major, Minor: Integer): Reference; safecall;
    function AddFromFile(const FileName: WideString): Reference; safecall;
    procedure Remove(const Reference: Reference); safecall;
    property Parent: VBProject read Get_Parent;
    property VBE: VBE read Get_VBE;
    property Count: Integer read Get_Count;
  end;

{ DispInterface declaration for Dual Interface _References }

  _ReferencesDisp = dispinterface
    ['{0002E17A-0000-0000-C000-000000000046}']
    property Parent: VBProject readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    function Item(index: OleVariant): Reference; dispid 0;
    property Count: Integer readonly dispid 1610743811;
    function _NewEnum: IUnknown; dispid -4;
    function AddFromGuid(const Guid: WideString; Major, Minor: Integer): Reference; dispid 1610743813;
    function AddFromFile(const FileName: WideString): Reference; dispid 1610743814;
    procedure Remove(const Reference: Reference); dispid 1610743815;
  end;

  Reference = interface(IDispatch)
    ['{0002E17E-0000-0000-C000-000000000046}']
    function Get_Collection: References; safecall;
    function Get_VBE: VBE; safecall;
    function Get_Name: WideString; safecall;
    function Get_Guid: WideString; safecall;
    function Get_Major: Integer; safecall;
    function Get_Minor: Integer; safecall;
    function Get_FullPath: WideString; safecall;
    function Get_BuiltIn: WordBool; safecall;
    function Get_IsBroken: WordBool; safecall;
    function Get_Type_: vbext_RefKind; safecall;
    function Get_Description: WideString; safecall;
    property Collection: References read Get_Collection;
    property VBE: VBE read Get_VBE;
    property Name: WideString read Get_Name;
    property Guid: WideString read Get_Guid;
    property Major: Integer read Get_Major;
    property Minor: Integer read Get_Minor;
    property FullPath: WideString read Get_FullPath;
    property BuiltIn: WordBool read Get_BuiltIn;
    property IsBroken: WordBool read Get_IsBroken;
    property Type_: vbext_RefKind read Get_Type_;
    property Description: WideString read Get_Description;
  end;

{ DispInterface declaration for Dual Interface Reference }

  ReferenceDisp = dispinterface
    ['{0002E17E-0000-0000-C000-000000000046}']
    property Collection: References readonly dispid 1610743808;
    property VBE: VBE readonly dispid 1610743809;
    property Name: WideString readonly dispid 1610743810;
    property Guid: WideString readonly dispid 1610743811;
    property Major: Integer readonly dispid 1610743812;
    property Minor: Integer readonly dispid 1610743813;
    property FullPath: WideString readonly dispid 1610743814;
    property BuiltIn: WordBool readonly dispid 1610743815;
    property IsBroken: WordBool readonly dispid 1610743816;
    property Type_: vbext_RefKind readonly dispid 1610743817;
    property Description: WideString readonly dispid 1610743818;
  end;

  _dispReferences_Events = dispinterface
    ['{CDDE3804-2064-11CF-867F-00AA005FF34A}']
    procedure ItemAdded(const Reference: Reference); dispid 0;
    procedure ItemRemoved(const Reference: Reference); dispid 1;
  end;

  CoWindows = class
    class function Create: _Windows;
    class function CreateRemote(const MachineName: string): _Windows;
  end;

  CoLinkedWindows = class
    class function Create: _LinkedWindows;
    class function CreateRemote(const MachineName: string): _LinkedWindows;
  end;

  CoReferencesEvents = class
    class function Create: _ReferencesEvents;
    class function CreateRemote(const MachineName: string): _ReferencesEvents;
  end;

  CoCommandBarEvents = class
    class function Create: _CommandBarControlEvents;
    class function CreateRemote(const MachineName: string): _CommandBarControlEvents;
  end;

  CoProjectTemplate = class
    class function Create: _ProjectTemplate;
    class function CreateRemote(const MachineName: string): _ProjectTemplate;
  end;

  CoVBProject = class
    class function Create: _VBProject;
    class function CreateRemote(const MachineName: string): _VBProject;
  end;

  CoVBProjects = class
    class function Create: _VBProjects;
    class function CreateRemote(const MachineName: string): _VBProjects;
  end;

  CoComponents = class
    class function Create: _Components;
    class function CreateRemote(const MachineName: string): _Components;
  end;

  CoVBComponents = class
    class function Create: _VBComponents;
    class function CreateRemote(const MachineName: string): _VBComponents;
  end;

  CoComponent = class
    class function Create: _Component;
    class function CreateRemote(const MachineName: string): _Component;
  end;

  CoVBComponent = class
    class function Create: _VBComponent;
    class function CreateRemote(const MachineName: string): _VBComponent;
  end;

  CoProperties = class
    class function Create: _Properties;
    class function CreateRemote(const MachineName: string): _Properties;
  end;

  CoAddins = class
    class function Create: _AddIns;
    class function CreateRemote(const MachineName: string): _AddIns;
  end;

  CoCodeModule = class
    class function Create: _CodeModule;
    class function CreateRemote(const MachineName: string): _CodeModule;
  end;

  CoCodePanes = class
    class function Create: _CodePanes;
    class function CreateRemote(const MachineName: string): _CodePanes;
  end;

  CoCodePane = class
    class function Create: _CodePane;
    class function CreateRemote(const MachineName: string): _CodePane;
  end;

  CoReferences = class
    class function Create: _References;
    class function CreateRemote(const MachineName: string): _References;
  end;



implementation

uses ComObj;

class function CoWindows.Create: _Windows;
begin
  Result := CreateComObject(Class_Windows) as _Windows;
end;

class function CoWindows.CreateRemote(const MachineName: string): _Windows;
begin
  Result := CreateRemoteComObject(MachineName, Class_Windows) as _Windows;
end;

class function CoLinkedWindows.Create: _LinkedWindows;
begin
  Result := CreateComObject(Class_LinkedWindows) as _LinkedWindows;
end;

class function CoLinkedWindows.CreateRemote(const MachineName: string): _LinkedWindows;
begin
  Result := CreateRemoteComObject(MachineName, Class_LinkedWindows) as _LinkedWindows;
end;

class function CoReferencesEvents.Create: _ReferencesEvents;
begin
  Result := CreateComObject(Class_ReferencesEvents) as _ReferencesEvents;
end;

class function CoReferencesEvents.CreateRemote(const MachineName: string): _ReferencesEvents;
begin
  Result := CreateRemoteComObject(MachineName, Class_ReferencesEvents) as _ReferencesEvents;
end;

class function CoCommandBarEvents.Create: _CommandBarControlEvents;
begin
  Result := CreateComObject(Class_CommandBarEvents) as _CommandBarControlEvents;
end;

class function CoCommandBarEvents.CreateRemote(const MachineName: string): _CommandBarControlEvents;
begin
  Result := CreateRemoteComObject(MachineName, Class_CommandBarEvents) as _CommandBarControlEvents;
end;

class function CoProjectTemplate.Create: _ProjectTemplate;
begin
  Result := CreateComObject(Class_ProjectTemplate) as _ProjectTemplate;
end;

class function CoProjectTemplate.CreateRemote(const MachineName: string): _ProjectTemplate;
begin
  Result := CreateRemoteComObject(MachineName, Class_ProjectTemplate) as _ProjectTemplate;
end;

class function CoVBProject.Create: _VBProject;
begin
  Result := CreateComObject(Class_VBProject) as _VBProject;
end;

class function CoVBProject.CreateRemote(const MachineName: string): _VBProject;
begin
  Result := CreateRemoteComObject(MachineName, Class_VBProject) as _VBProject;
end;

class function CoVBProjects.Create: _VBProjects;
begin
  Result := CreateComObject(Class_VBProjects) as _VBProjects;
end;

class function CoVBProjects.CreateRemote(const MachineName: string): _VBProjects;
begin
  Result := CreateRemoteComObject(MachineName, Class_VBProjects) as _VBProjects;
end;

class function CoComponents.Create: _Components;
begin
  Result := CreateComObject(Class_Components) as _Components;
end;

class function CoComponents.CreateRemote(const MachineName: string): _Components;
begin
  Result := CreateRemoteComObject(MachineName, Class_Components) as _Components;
end;

class function CoVBComponents.Create: _VBComponents;
begin
  Result := CreateComObject(Class_VBComponents) as _VBComponents;
end;

class function CoVBComponents.CreateRemote(const MachineName: string): _VBComponents;
begin
  Result := CreateRemoteComObject(MachineName, Class_VBComponents) as _VBComponents;
end;

class function CoComponent.Create: _Component;
begin
  Result := CreateComObject(Class_Component) as _Component;
end;

class function CoComponent.CreateRemote(const MachineName: string): _Component;
begin
  Result := CreateRemoteComObject(MachineName, Class_Component) as _Component;
end;

class function CoVBComponent.Create: _VBComponent;
begin
  Result := CreateComObject(Class_VBComponent) as _VBComponent;
end;

class function CoVBComponent.CreateRemote(const MachineName: string): _VBComponent;
begin
  Result := CreateRemoteComObject(MachineName, Class_VBComponent) as _VBComponent;
end;

class function CoProperties.Create: _Properties;
begin
  Result := CreateComObject(Class_Properties) as _Properties;
end;

class function CoProperties.CreateRemote(const MachineName: string): _Properties;
begin
  Result := CreateRemoteComObject(MachineName, Class_Properties) as _Properties;
end;

class function CoAddins.Create: _AddIns;
begin
  Result := CreateComObject(Class_Addins) as _AddIns;
end;

class function CoAddins.CreateRemote(const MachineName: string): _AddIns;
begin
  Result := CreateRemoteComObject(MachineName, Class_Addins) as _AddIns;
end;

class function CoCodeModule.Create: _CodeModule;
begin
  Result := CreateComObject(Class_CodeModule) as _CodeModule;
end;

class function CoCodeModule.CreateRemote(const MachineName: string): _CodeModule;
begin
  Result := CreateRemoteComObject(MachineName, Class_CodeModule) as _CodeModule;
end;

class function CoCodePanes.Create: _CodePanes;
begin
  Result := CreateComObject(Class_CodePanes) as _CodePanes;
end;

class function CoCodePanes.CreateRemote(const MachineName: string): _CodePanes;
begin
  Result := CreateRemoteComObject(MachineName, Class_CodePanes) as _CodePanes;
end;

class function CoCodePane.Create: _CodePane;
begin
  Result := CreateComObject(Class_CodePane) as _CodePane;
end;

class function CoCodePane.CreateRemote(const MachineName: string): _CodePane;
begin
  Result := CreateRemoteComObject(MachineName, Class_CodePane) as _CodePane;
end;

class function CoReferences.Create: _References;
begin
  Result := CreateComObject(Class_References) as _References;
end;

class function CoReferences.CreateRemote(const MachineName: string): _References;
begin
  Result := CreateRemoteComObject(MachineName, Class_References) as _References;
end;


end.
