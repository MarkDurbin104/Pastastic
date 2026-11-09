unit SourceSafeTypeLib_TLB;

{ This file contains pascal declarations imported from a type library.
  This file will be written during each import or refresh of the type
  library editor.  Changes to this file will be discarded during the
  refresh process. }

{ Microsoft SourceSafe 6.0 Type Library }
{ Version 5.1 }

{ Conversion log:
  Warning: 'Type' is a reserved word. IVSSItemOld.Type changed to Type_
  Warning: 'Label' is a reserved word. IVSSItemOld.Label changed to Label_
  Warning: 'Label' is a reserved word. Parameter 'Label' in IVSSItemOld.Label_ changed to 'Label_'
  Warning: 'Label' is a reserved word. IVSSVersionOld.Label changed to Label_
  Warning: 'var' is a reserved word. Parameter 'var' in IVSSEventsOld.BeforeEvent changed to 'var_'
  Warning: 'var' is a reserved word. Parameter 'var' in IVSSEventsOld.AfterEvent changed to 'var_'
  Warning: 'var' is a reserved word. Parameter 'var' in IVSSEvents.BeforeEvent changed to 'var_'
  Warning: 'var' is a reserved word. Parameter 'var' in IVSSEvents.AfterEvent changed to 'var_'
 }

interface

uses Windows, ActiveX, Classes, Graphics, OleCtrls, StdVCL;

const
  LIBID_SourceSafeTypeLib: TGUID = '{783CD4E0-9D54-11CF-B8EE-00608CC9A71F}';

const

{ SourceSafe operation flags }

{ VSSFlags }

  VSSFLAG_USERRONO = 1;
  VSSFLAG_USERROYES = 2;
  VSSFLAG_TIMENOW = 4;
  VSSFLAG_TIMEMOD = 8;
  VSSFLAG_TIMEUPD = 12;
  VSSFLAG_EOLCR = 16;
  VSSFLAG_EOLLF = 32;
  VSSFLAG_EOLCRLF = 48;
  VSSFLAG_REPASK = 64;
  VSSFLAG_REPREPLACE = 128;
  VSSFLAG_REPSKIP = 192;
  VSSFLAG_REPMERGE = 256;
  VSSFLAG_CMPFULL = 512;
  VSSFLAG_CMPTIME = 1024;
  VSSFLAG_CMPCHKSUM = 1536;
  VSSFLAG_CMPFAIL = 2048;
  VSSFLAG_RECURSNO = 4096;
  VSSFLAG_RECURSYES = 8192;
  VSSFLAG_FORCEDIRNO = 16384;
  VSSFLAG_FORCEDIRYES = 32768;
  VSSFLAG_KEEPNO = 65536;
  VSSFLAG_KEEPYES = 131072;
  VSSFLAG_DELNO = 262144;
  VSSFLAG_DELYES = 524288;
  VSSFLAG_DELNOREPLACE = 786432;
  VSSFLAG_BINTEST = 1048576;
  VSSFLAG_BINBINARY = 2097152;
  VSSFLAG_BINTEXT = 3145728;
  VSSFLAG_DELTAYES = 4194304;
  VSSFLAG_DELTANO = 8388608;
  VSSFLAG_UPDASK = 16777216;
  VSSFLAG_UPDUPDATE = 33554432;
  VSSFLAG_UPDUNCH = 50331648;
  VSSFLAG_GETYES = 67108864;
  VSSFLAG_GETNO = 134217728;
  VSSFLAG_CHKEXCLUSIVEYES = 268435456;
  VSSFLAG_CHKEXCLUSIVENO = 536870912;
  VSSFLAG_HISTIGNOREFILES = 1073741824;

{ SourceSafe file checkout status }

{ VSSFileStatus }

  VSSFILE_NOTCHECKEDOUT = 0;
  VSSFILE_CHECKEDOUT = 1;
  VSSFILE_CHECKEDOUT_ME = 2;

{ SourceSafe item type }

{ VSSItemType }

  VSSITEM_PROJECT = 0;
  VSSITEM_FILE = 1;

{ SourceSafe rights values }

{ VSSRights }

  VSSRIGHTS_READ = 1;
  VSSRIGHTS_CHKUPD = 2;
  VSSRIGHTS_ADDRENREM = 4;
  VSSRIGHTS_DESTROY = 8;
  VSSRIGHTS_ALL = 15;
  VSSRIGHTS_INHERITED = 16;

const

{ Component class GUIDs }
  Class_VSSItem: TGUID = '{783CD4E3-9D54-11CF-B8EE-00608CC9A71F}';
  Class_VSSVersion: TGUID = '{783CD4EC-9D54-11CF-B8EE-00608CC9A71F}';
  Class_VSSCheckout: TGUID = '{2A0DE0E0-2E9F-11D0-9236-00AA00A1EB95}';
  Class_VSSDatabase: TGUID = '{783CD4E4-9D54-11CF-B8EE-00608CC9A71F}';
  Class_VSSUser: TGUID = '{2A0DE0E5-2E9F-11D0-9236-00AA00A1EB95}';
  Class_VSSApp: TGUID = '{2A0DE0E1-2E9F-11D0-9236-00AA00A1EB95}';

type

{ Forward declarations: Interfaces }
  IVSSItemOld = interface;
  IVSSItemOldDisp = dispinterface;
  IVSSItem = interface;
  IVSSItemDisp = dispinterface;
  IVSSVersions = interface;
  IVSSVersionsDisp = dispinterface;
  IVSSVersionOld = interface;
  IVSSVersionOldDisp = dispinterface;
  IVSSVersion = interface;
  IVSSVersionDisp = dispinterface;
  IVSSItems = interface;
  IVSSItemsDisp = dispinterface;
  IVSSCheckouts = interface;
  IVSSCheckoutsDisp = dispinterface;
  IVSSCheckout = interface;
  IVSSCheckoutDisp = dispinterface;
  IVSSDatabaseOld = interface;
  IVSSDatabaseOldDisp = dispinterface;
  IVSSDatabase = interface;
  IVSSDatabaseDisp = dispinterface;
  IVSSUser = interface;
  IVSSUserDisp = dispinterface;
  IVSSUsers = interface;
  IVSSUsersDisp = dispinterface;
  IVSSEventsOld = interface;
  IVSSEvents = interface;
  IVSS = interface;
  IVSSDisp = dispinterface;
  IVSSEventHandler = interface;

{ Forward declarations: CoClasses }
  VSSDatabase = IVSSDatabase;

{ Forward declarations: Enums }
  VSSFlags = TOleEnum;
  VSSFileStatus = TOleEnum;
  VSSItemType = TOleEnum;
  VSSRights = TOleEnum;

{ SourceSafe item interface }

  IVSSItemOld = interface(IDispatch)
    ['{783CD4E1-9D54-11CF-B8EE-00608CC9A71F}']
    function Get_Spec: WideString; safecall;
    function Get_Binary: WordBool; safecall;
    procedure Set_Binary(Value: WordBool); safecall;
    function Get_Deleted: WordBool; safecall;
    procedure Set_Deleted(Value: WordBool); safecall;
    function Get_Type_: SYSINT; safecall;
    function Get_LocalSpec: WideString; safecall;
    procedure Set_LocalSpec(const Value: WideString); safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    function Get_Parent: IVSSItem; safecall;
    function Get_VersionNumber: Integer; safecall;
    function Get_Items(IncludeDeleted: WordBool): IVSSItems; safecall;
    procedure Get(var Local: WideString; iFlags: Integer); safecall;
    procedure Checkout(const Comment, Local: WideString; iFlags: Integer); safecall;
    procedure Checkin(const Comment, Local: WideString; iFlags: Integer); safecall;
    procedure UndoCheckout(const Local: WideString; iFlags: Integer); safecall;
    function Get_IsCheckedOut: Integer; safecall;
    function Get_Checkouts: IVSSCheckouts; safecall;
    function Get_IsDifferent(const Local: WideString): WordBool; safecall;
    function Add(const Local, Comment: WideString; iFlags: Integer): IVSSItem; safecall;
    function NewSubproject(const Name, Comment: WideString): IVSSItem; safecall;
    procedure Share(const pIItem: IVSSItem; const Comment: WideString; iFlags: Integer); safecall;
    procedure Destroy; safecall;
    procedure Move(const pINewParent: IVSSItem); safecall;
    procedure Label_(const Label_, Comment: WideString); safecall;
    function Get_Versions(iFlags: Integer): IVSSVersions; safecall;
    function Get_Version(Version: OleVariant): IVSSItem; safecall;
    property Spec: WideString read Get_Spec;
    property Binary: WordBool read Get_Binary write Set_Binary;
    property Deleted: WordBool read Get_Deleted write Set_Deleted;
    property Type_: SYSINT read Get_Type_;
    property LocalSpec: WideString read Get_LocalSpec write Set_LocalSpec;
    property Name: WideString read Get_Name write Set_Name;
    property Parent: IVSSItem read Get_Parent;
    property VersionNumber: Integer read Get_VersionNumber;
    property Items[IncludeDeleted: WordBool]: IVSSItems read Get_Items;
    property IsCheckedOut: Integer read Get_IsCheckedOut;
    property Checkouts: IVSSCheckouts read Get_Checkouts;
    property IsDifferent[const Local: WideString]: WordBool read Get_IsDifferent;
    property Versions[iFlags: Integer]: IVSSVersions read Get_Versions;
    property Version[Version: OleVariant]: IVSSItem read Get_Version;
  end;

{ DispInterface declaration for Dual Interface IVSSItemOld }

  IVSSItemOldDisp = dispinterface
    ['{783CD4E1-9D54-11CF-B8EE-00608CC9A71F}']
    property Spec: WideString readonly dispid 1;
    property Binary: WordBool dispid 2;
    property Deleted: WordBool dispid 3;
    property Type_: SYSINT readonly dispid 4;
    property LocalSpec: WideString dispid 5;
    property Name: WideString dispid 6;
    property Parent: IVSSItem readonly dispid 7;
    property VersionNumber: Integer readonly dispid 8;
    property Items[IncludeDeleted: WordBool]: IVSSItems readonly dispid 9;
    procedure Get(var Local: WideString; iFlags: Integer); dispid 10;
    procedure Checkout(const Comment, Local: WideString; iFlags: Integer); dispid 11;
    procedure Checkin(const Comment, Local: WideString; iFlags: Integer); dispid 12;
    procedure UndoCheckout(const Local: WideString; iFlags: Integer); dispid 13;
    property IsCheckedOut: Integer readonly dispid 14;
    property Checkouts: IVSSCheckouts readonly dispid 15;
    property IsDifferent[const Local: WideString]: WordBool readonly dispid 16;
    function Add(const Local, Comment: WideString; iFlags: Integer): IVSSItem; dispid 17;
    function NewSubproject(const Name, Comment: WideString): IVSSItem; dispid 18;
    procedure Share(const pIItem: IVSSItem; const Comment: WideString; iFlags: Integer); dispid 19;
    procedure Destroy; dispid 20;
    procedure Move(const pINewParent: IVSSItem); dispid 21;
    procedure Label_(const Label_, Comment: WideString); dispid 22;
    property Versions[iFlags: Integer]: IVSSVersions readonly dispid 23;
    property Version[Version: OleVariant]: IVSSItem readonly dispid 24;
  end;

{ SourceSafe item interface }

  IVSSItem = interface(IVSSItemOld)
    ['{2A0DE0E7-2E9F-11D0-9236-00AA00A1EB95}']
    function Get_Links: IVSSItems; safecall;
    function Branch(const Comment: WideString; iFlags: Integer): IVSSItem; safecall;
    property Links: IVSSItems read Get_Links;
  end;

{ DispInterface declaration for Dual Interface IVSSItem }

  IVSSItemDisp = dispinterface
    ['{2A0DE0E7-2E9F-11D0-9236-00AA00A1EB95}']
    property Spec: WideString readonly dispid 1;
    property Binary: WordBool dispid 2;
    property Deleted: WordBool dispid 3;
    property Type_: SYSINT readonly dispid 4;
    property LocalSpec: WideString dispid 5;
    property Name: WideString dispid 6;
    property Parent: IVSSItem readonly dispid 7;
    property VersionNumber: Integer readonly dispid 8;
    property Items[IncludeDeleted: WordBool]: IVSSItems readonly dispid 9;
    procedure Get(var Local: WideString; iFlags: Integer); dispid 10;
    procedure Checkout(const Comment, Local: WideString; iFlags: Integer); dispid 11;
    procedure Checkin(const Comment, Local: WideString; iFlags: Integer); dispid 12;
    procedure UndoCheckout(const Local: WideString; iFlags: Integer); dispid 13;
    property IsCheckedOut: Integer readonly dispid 14;
    property Checkouts: IVSSCheckouts readonly dispid 15;
    property IsDifferent[const Local: WideString]: WordBool readonly dispid 16;
    function Add(const Local, Comment: WideString; iFlags: Integer): IVSSItem; dispid 17;
    function NewSubproject(const Name, Comment: WideString): IVSSItem; dispid 18;
    procedure Share(const pIItem: IVSSItem; const Comment: WideString; iFlags: Integer); dispid 19;
    procedure Destroy; dispid 20;
    procedure Move(const pINewParent: IVSSItem); dispid 21;
    procedure Label_(const Label_, Comment: WideString); dispid 22;
    property Versions[iFlags: Integer]: IVSSVersions readonly dispid 23;
    property Version[Version: OleVariant]: IVSSItem readonly dispid 24;
    property Links: IVSSItems readonly dispid 25;
    function Branch(const Comment: WideString; iFlags: Integer): IVSSItem; dispid 26;
  end;

{ SourceSafe versions collection }

  IVSSVersions = interface(IDispatch)
    ['{783CD4E7-9D54-11CF-B8EE-00608CC9A71F}']
    function _NewEnum: IUnknown; safecall;
  end;

{ DispInterface declaration for Dual Interface IVSSVersions }

  IVSSVersionsDisp = dispinterface
    ['{783CD4E7-9D54-11CF-B8EE-00608CC9A71F}']
  end;

{ SourceSafe version information }

  IVSSVersionOld = interface(IDispatch)
    ['{783CD4E8-9D54-11CF-B8EE-00608CC9A71F}']
    function Get_Username: WideString; safecall;
    function Get_VersionNumber: Integer; safecall;
    function Get_Action: WideString; safecall;
    function Get_Date: TDateTime; safecall;
    function Get_Comment: WideString; safecall;
    function Get_Label_: WideString; safecall;
    function Get_VSSItem: IVSSItem; safecall;
    property Username: WideString read Get_Username;
    property VersionNumber: Integer read Get_VersionNumber;
    property Action: WideString read Get_Action;
    property Date: TDateTime read Get_Date;
    property Comment: WideString read Get_Comment;
    property Label_: WideString read Get_Label_;
    property VSSItem: IVSSItem read Get_VSSItem;
  end;

{ DispInterface declaration for Dual Interface IVSSVersionOld }

  IVSSVersionOldDisp = dispinterface
    ['{783CD4E8-9D54-11CF-B8EE-00608CC9A71F}']
    property Username: WideString readonly dispid 1;
    property VersionNumber: Integer readonly dispid 2;
    property Action: WideString readonly dispid 3;
    property Date: TDateTime readonly dispid 4;
    property Comment: WideString readonly dispid 5;
    property Label_: WideString readonly dispid 6;
    property VSSItem: IVSSItem readonly dispid 7;
  end;

{ SourceSafe version information }

  IVSSVersion = interface(IVSSVersionOld)
    ['{2A0DE0E9-2E9F-11D0-9236-00AA00A1EB95}']
    function Get_LabelComment: WideString; safecall;
    property LabelComment: WideString read Get_LabelComment;
  end;

{ DispInterface declaration for Dual Interface IVSSVersion }

  IVSSVersionDisp = dispinterface
    ['{2A0DE0E9-2E9F-11D0-9236-00AA00A1EB95}']
    property Username: WideString readonly dispid 1;
    property VersionNumber: Integer readonly dispid 2;
    property Action: WideString readonly dispid 3;
    property Date: TDateTime readonly dispid 4;
    property Comment: WideString readonly dispid 5;
    property Label_: WideString readonly dispid 6;
    property VSSItem: IVSSItem readonly dispid 7;
    property LabelComment: WideString readonly dispid 8;
  end;

{ SourceSafe items collection interface }

  IVSSItems = interface(IDispatch)
    ['{783CD4E5-9D54-11CF-B8EE-00608CC9A71F}']
    function Get_Count: Integer; safecall;
    function Get_Item(sItem: OleVariant): IVSSItem; safecall;
    function _NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property Item[sItem: OleVariant]: IVSSItem read Get_Item; default;
  end;

{ DispInterface declaration for Dual Interface IVSSItems }

  IVSSItemsDisp = dispinterface
    ['{783CD4E5-9D54-11CF-B8EE-00608CC9A71F}']
    property Count: Integer readonly dispid 1;
    property Item[sItem: OleVariant]: IVSSItem readonly dispid 0; default;
  end;

{ SourceSafe checkouts collection interface }

  IVSSCheckouts = interface(IDispatch)
    ['{8903A770-F55F-11CF-9227-00AA00A1EB95}']
    function Get_Count: Integer; safecall;
    function Get_Item(sItem: OleVariant): IVSSCheckout; safecall;
    function _NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property Item[sItem: OleVariant]: IVSSCheckout read Get_Item; default;
  end;

{ DispInterface declaration for Dual Interface IVSSCheckouts }

  IVSSCheckoutsDisp = dispinterface
    ['{8903A770-F55F-11CF-9227-00AA00A1EB95}']
    property Count: Integer readonly dispid 1;
    property Item[sItem: OleVariant]: IVSSCheckout readonly dispid 0; default;
  end;

{ SourceSafe checkouts interface }

  IVSSCheckout = interface(IDispatch)
    ['{783CD4E6-9D54-11CF-B8EE-00608CC9A71F}']
    function Get_Username: WideString; safecall;
    function Get_Date: TDateTime; safecall;
    function Get_LocalSpec: WideString; safecall;
    function Get_Machine: WideString; safecall;
    function Get_Project: WideString; safecall;
    function Get_Comment: WideString; safecall;
    function Get_VersionNumber: Integer; safecall;
    property Username: WideString read Get_Username;
    property Date: TDateTime read Get_Date;
    property LocalSpec: WideString read Get_LocalSpec;
    property Machine: WideString read Get_Machine;
    property Project: WideString read Get_Project;
    property Comment: WideString read Get_Comment;
    property VersionNumber: Integer read Get_VersionNumber;
  end;

{ DispInterface declaration for Dual Interface IVSSCheckout }

  IVSSCheckoutDisp = dispinterface
    ['{783CD4E6-9D54-11CF-B8EE-00608CC9A71F}']
    property Username: WideString readonly dispid 1;
    property Date: TDateTime readonly dispid 2;
    property LocalSpec: WideString readonly dispid 3;
    property Machine: WideString readonly dispid 4;
    property Project: WideString readonly dispid 5;
    property Comment: WideString readonly dispid 6;
    property VersionNumber: Integer readonly dispid 7;
  end;

{ SourceSafe database object interface }

  IVSSDatabaseOld = interface(IDispatch)
    ['{783CD4E2-9D54-11CF-B8EE-00608CC9A71F}']
    procedure Open(const SrcSafeIni, Username, Password: WideString); safecall;
    function Get_SrcSafeIni: WideString; safecall;
    function Get_DatabaseName: WideString; safecall;
    function Get_Username: WideString; safecall;
    function Get_CurrentProject: WideString; safecall;
    procedure Set_CurrentProject(const Value: WideString); safecall;
    function Get_VSSItem(const Spec: WideString; Deleted: WordBool): IVSSItem; safecall;
    property SrcSafeIni: WideString read Get_SrcSafeIni;
    property DatabaseName: WideString read Get_DatabaseName;
    property Username: WideString read Get_Username;
    property CurrentProject: WideString read Get_CurrentProject write Set_CurrentProject;
    property VSSItem[const Spec: WideString; Deleted: WordBool]: IVSSItem read Get_VSSItem;
  end;

{ DispInterface declaration for Dual Interface IVSSDatabaseOld }

  IVSSDatabaseOldDisp = dispinterface
    ['{783CD4E2-9D54-11CF-B8EE-00608CC9A71F}']
    procedure Open(const SrcSafeIni, Username, Password: WideString); dispid 1;
    property SrcSafeIni: WideString readonly dispid 2;
    property DatabaseName: WideString readonly dispid 3;
    property Username: WideString readonly dispid 4;
    property CurrentProject: WideString dispid 5;
    property VSSItem[const Spec: WideString; Deleted: WordBool]: IVSSItem readonly dispid 6;
  end;

{ SourceSafe database object interface }

  IVSSDatabase = interface(IVSSDatabaseOld)
    ['{2A0DE0E2-2E9F-11D0-9236-00AA00A1EB95}']
    function AddUser(const User, Password: WideString; ReadOnly: WordBool): IVSSUser; safecall;
    function Get_User(const Name: WideString): IVSSUser; safecall;
    function Get_Users: IVSSUsers; safecall;
    function Get_ProjectRightsEnabled: WordBool; safecall;
    procedure Set_ProjectRightsEnabled(Value: WordBool); safecall;
    function Get_DefaultProjectRights: Integer; safecall;
    procedure Set_DefaultProjectRights(Value: Integer); safecall;
    property User[const Name: WideString]: IVSSUser read Get_User;
    property Users: IVSSUsers read Get_Users;
    property ProjectRightsEnabled: WordBool read Get_ProjectRightsEnabled write Set_ProjectRightsEnabled;
    property DefaultProjectRights: Integer read Get_DefaultProjectRights write Set_DefaultProjectRights;
  end;

{ DispInterface declaration for Dual Interface IVSSDatabase }

  IVSSDatabaseDisp = dispinterface
    ['{2A0DE0E2-2E9F-11D0-9236-00AA00A1EB95}']
    procedure Open(const SrcSafeIni, Username, Password: WideString); dispid 1;
    property SrcSafeIni: WideString readonly dispid 2;
    property DatabaseName: WideString readonly dispid 3;
    property Username: WideString readonly dispid 4;
    property CurrentProject: WideString dispid 5;
    property VSSItem[const Spec: WideString; Deleted: WordBool]: IVSSItem readonly dispid 6;
    function AddUser(const User, Password: WideString; ReadOnly: WordBool): IVSSUser; dispid 7;
    property User[const Name: WideString]: IVSSUser readonly dispid 8;
    property Users: IVSSUsers readonly dispid 9;
    property ProjectRightsEnabled: WordBool dispid 10;
    property DefaultProjectRights: Integer dispid 11;
  end;

{ SourceSafe user object interface }

  IVSSUser = interface(IDispatch)
    ['{2A0DE0E3-2E9F-11D0-9236-00AA00A1EB95}']
    procedure Delete; safecall;
    function Get_Name: WideString; safecall;
    procedure Set_Name(const Value: WideString); safecall;
    procedure Set_Password(const Value: WideString); safecall;
    function Get_ReadOnly: WordBool; safecall;
    procedure Set_ReadOnly(Value: WordBool); safecall;
    function Get_ProjectRights(const Project: WideString): Integer; safecall;
    procedure Set_ProjectRights(const Project: WideString; Value: Integer); safecall;
    procedure RemoveProjectRights(const Project: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Password: WideString write Set_Password;
    property ReadOnly: WordBool read Get_ReadOnly write Set_ReadOnly;
    property ProjectRights[const Project: WideString]: Integer read Get_ProjectRights write Set_ProjectRights;
  end;

{ DispInterface declaration for Dual Interface IVSSUser }

  IVSSUserDisp = dispinterface
    ['{2A0DE0E3-2E9F-11D0-9236-00AA00A1EB95}']
    procedure Delete; dispid 1;
    property Name: WideString dispid 2;
    property Password: WideString writeonly dispid 3;
    property ReadOnly: WordBool dispid 4;
    property ProjectRights[const Project: WideString]: Integer dispid 5;
    procedure RemoveProjectRights(const Project: WideString); dispid 6;
  end;

{ SourceSafe users collection interface }

  IVSSUsers = interface(IDispatch)
    ['{2A0DE0E4-2E9F-11D0-9236-00AA00A1EB95}']
    function Get_Count: Integer; safecall;
    function Get_Item(sItem: OleVariant): IVSSUser; safecall;
    function _NewEnum: IUnknown; safecall;
    property Count: Integer read Get_Count;
    property Item[sItem: OleVariant]: IVSSUser read Get_Item; default;
  end;

{ DispInterface declaration for Dual Interface IVSSUsers }

  IVSSUsersDisp = dispinterface
    ['{2A0DE0E4-2E9F-11D0-9236-00AA00A1EB95}']
    property Count: Integer readonly dispid 1;
    property Item[sItem: OleVariant]: IVSSUser readonly dispid 0; default;
  end;

{ SourceSafe event interface }

  IVSSEventsOld = interface(IUnknown)
    ['{783CD4E9-9D54-11CF-B8EE-00608CC9A71F}']
    function BeforeAdd(const pIPrj: IVSSItem; const Local: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterAdd(const pIItem: IVSSItem; const Local: WideString): HResult; stdcall;
    function BeforeCheckout(const pIItem: IVSSItem; const Local: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterCheckout(const pIItem: IVSSItem; const Local: WideString): HResult; stdcall;
    function BeforeCheckin(const pIItem: IVSSItem; const Local: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterCheckin(const pIItem: IVSSItem; const Local: WideString): HResult; stdcall;
    function BeforeUndoCheckout(const pIItem: IVSSItem; const Local: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterUndoCheckout(const pIItem: IVSSItem; const Local: WideString): HResult; stdcall;
    function BeforeRename(const pIItem: IVSSItem; const NewName: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterRename(const pIItem: IVSSItem; const OldName: WideString): HResult; stdcall;
    function BeforeBranch(const pIItem: IVSSItem; out Retval: WordBool): HResult; stdcall;
    function AfterBranch(const pIItem: IVSSItem): HResult; stdcall;
    function BeforeEvent(iEvent: Integer; const pIItem: IVSSItem; const Str: WideString; var_: OleVariant; out Retval: WordBool): HResult; stdcall;
    function AfterEvent(iEvent: Integer; const pIItem: IVSSItem; const Str: WideString; var_: OleVariant): HResult; stdcall;
  end;

{ SourceSafe event interface }

  IVSSEvents = interface(IUnknown)
    ['{2A0DE0E8-2E9F-11D0-9236-00AA00A1EB95}']
    function BeforeAdd(const pIPrj: IVSSItem; const Local, Comment: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterAdd(const pIItem: IVSSItem; const Local, Comment: WideString): HResult; stdcall;
    function BeforeCheckout(const pIItem: IVSSItem; const Local, Comment: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterCheckout(const pIItem: IVSSItem; const Local, Comment: WideString): HResult; stdcall;
    function BeforeCheckin(const pIItem: IVSSItem; const Local, Comment: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterCheckin(const pIItem: IVSSItem; const Local, Comment: WideString): HResult; stdcall;
    function BeforeUndoCheckout(const pIItem: IVSSItem; const Local: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterUndoCheckout(const pIItem: IVSSItem; const Local: WideString): HResult; stdcall;
    function BeforeRename(const pIItem: IVSSItem; const NewName: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterRename(const pIItem: IVSSItem; const OldName: WideString): HResult; stdcall;
    function BeforeBranch(const pIItem: IVSSItem; const Comment: WideString; out Retval: WordBool): HResult; stdcall;
    function AfterBranch(const pIItem: IVSSItem; const Comment: WideString): HResult; stdcall;
    function BeginCommand(unused: Integer; out Retval: WordBool): HResult; stdcall;
    function EndCommand(unused: Integer): HResult; stdcall;
    function BeforeEvent(iEvent: Integer; const pIItem: IVSSItem; const Str: WideString; var_: OleVariant; out Retval: WordBool): HResult; stdcall;
    function AfterEvent(iEvent: Integer; const pIItem: IVSSItem; const Str: WideString; var_: OleVariant): HResult; stdcall;
  end;

{ SourceSafe application interface }

  IVSS = interface(IDispatch)
    ['{783CD4EB-9D54-11CF-B8EE-00608CC9A71F}']
    function Get_VSSDatabase: IVSSDatabase; safecall;
    property VSSDatabase: IVSSDatabase read Get_VSSDatabase;
  end;

{ DispInterface declaration for Dual Interface IVSS }

  IVSSDisp = dispinterface
    ['{783CD4EB-9D54-11CF-B8EE-00608CC9A71F}']
    property VSSDatabase: IVSSDatabase readonly dispid 1;
  end;

{ SourceSafe event interface }

  IVSSEventHandler = interface(IUnknown)
    ['{783CD4EA-9D54-11CF-B8EE-00608CC9A71F}']
    function Init(const pIVSS: IVSS): HResult; stdcall;
  end;

  CoVSSDatabase = class
    class function Create: IVSSDatabase;
    class function CreateRemote(const MachineName: string): IVSSDatabase;
  end;



implementation

uses ComObj;

class function CoVSSDatabase.Create: IVSSDatabase;
begin
  Result := CreateComObject(Class_VSSDatabase) as IVSSDatabase;
end;

class function CoVSSDatabase.CreateRemote(const MachineName: string): IVSSDatabase;
begin
  Result := CreateRemoteComObject(MachineName, Class_VSSDatabase) as IVSSDatabase;
end;


end.
