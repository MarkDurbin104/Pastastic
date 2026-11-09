(*
  OleDrop version 1.01
  Copyright (C) 1999 by Sylvain Frere
  e-mail: fbrother@club-internet.fr

  Description :
    Accept drop from shell in any TWinControl

  version 1.01
    Add UnRegisterAndFree to fix problem with BeforeDestroy, _Addref and
    RevokeDragDrop

  version 1.00
    Original release for outbar component.
*)
unit oledrop;
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Activex, Dialogs;

type
  ToleDragObject = class(TDragObject)
  private
    dataObj  : IDataObject;
    Fkeys    : longint;
    FDown    : boolean;
    FList    : TStringlist;

    function  GetFileList:TStringList;
  public
    constructor create;
    destructor destroy; override;
    property Keys : longint read Fkeys;
    property FileList : TStringList read GetFileList;
  end;

  IWCDropTarget = class(TInterfacedObject, IDropTarget)
  private
    FOwner    : TWinControl;
    Fhandle   : HWND;
    FdragObj  : ToleDragObject;
    FTarget   : Pointer;
  public
    { IDropTarget }
    function DragEnter(const dataObj: IDataObject; grfKeyState: Longint;
      pt: TPoint; var dwEffect: Longint): HResult; stdcall;
    function DragOver(grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;
    function DragLeave: HResult; stdcall;
    function Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint;
      var dwEffect: Longint): HResult; stdcall;

    constructor create(aOwner:TWinControl);
    destructor destroy; override;
    procedure UnRegisterAndFree;
  end;

implementation
Type
  PDropFiles = ^TDropFiles;
  TDropFiles = record
    pfiles : DWORD;
    pt     : TPOINT;
    fNC    : BOOL;
    fWide  : BOOL;
  end;
{------------------------------------------------------------------------------}
// Copy of the control unit DragMessage function
function DragMessage(Handle: HWND; Msg: TDragMessage; Source: TDragObject; Target: Pointer; const Pos: TPoint): Longint;
var DragRec: TDragRec;
begin
  Result := 0;
  if Handle <> 0 then
  begin
    DragRec.Pos := Pos;
    DragRec.Target := Target;
    DragRec.Source := Source;
    Result := SendMessage(Handle, CM_DRAG, Longint(Msg), Longint(@DragRec));
  end;
end;
{------------------------------------------------------------------------------}
constructor TOleDragObject.create;
begin
  Inherited create;
  FList := TStringList.Create;
end;
destructor TOleDragObject.destroy;
begin
  FList.Free;
  Inherited destroy;
end;
function TOleDragObject.GetFileList:TStringList;
var mdm:TStgMedium; pz:pchar; pdf:PDropFiles;  fmt : TFormatEtc;
begin
  Result := FList;
  if (FDown)or(Not assigned(dataobj)) then exit;
  FList.clear;
  fillchar(fmt,sizeof(fmt),0);
  fmt.cfFormat := CF_HDROP; fmt.tymed := TYMED_HGLOBAL; fmt.lindex := -1;
  if dataobj.GetData(fmt,mdm)<>S_OK then
     raise Exception.Create('IDataObject.GetData failed');
  try
  if mdm.tymed = TYMED_HGLOBAL then
    begin
      pdf := GlobalLock(mdm.HGlobal);
      pz  := pchar(pdf); Inc(pz,pdf^.pFiles);
      while (pz[0]<>#0) do
        begin
          FList.Add(strPas(pz));
          Inc(pz,1+strlen(pz));
        end;
      GlobalUnlock(mdm.HGlobal);
    end;
  finally
  if Assigned(mdm.unkForRelease) then
     Iunknown(mdm.unkForRelease)._Release;
  FDown  := TRUE;
  end;
end;
{------------------------------------------------------------------------------}

constructor IWCDropTarget.create(aOwner:TWinControl);
var rslt:HResult; obj:IDropTarget;
begin
  Inherited create;
  FOwner  := AOwner;
  FHandle := aOwner.Handle;
  if not GetInterface(Iunknown,obj) then
     raise Exception.Create('GetInterface failed');

  Rslt := RegisterDragDrop(FHandle,obj as IDroptarget);
  case Rslt of
    S_OK : ;
    DRAGDROP_E_INVALIDHWND       : raise Exception.Create('RegisterDragDrop failed, invalide hwnd ');
    DRAGDROP_E_ALREADYREGISTERED : raise Exception.Create('RegisterDragDrop failed, already registered');
    E_OUTOFMEMORY                : raise Exception.Create('RegisterDragDrop failed, out of memory');
    E_INVALIDARG                 : raise Exception.Create('RegisterDragDrop failed, invalid arg');
    CO_E_NOTINITIALIZED          : raise Exception.Create('RegisterDragDrop failed, coInitialize had not been called');
    else                           raise Exception.Create('RegisterDragDrop failed, unknown error code '+IntToStr(rslt and $7FFFFFFF));
  end;
end;

destructor IWCDropTarget.destroy;
begin
  Inherited destroy;
end;

procedure IWCDropTarget.UnRegisterAndFree;
begin
  // Call to RevokeDragDrop set RefCount to zero and call Destroy !
  if FHandle<>0 then begin RevokeDragDrop(FHandle); FHandle:=0; end;
end;

function IWCDropTarget.DragEnter(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult;
begin
  // TDragState = (dsDragEnter, dsDragLeave, dsDragMove);
  // TDragMessage = (dmDragEnter, dmDragLeave, dmDragMove, dmDragDrop, dmDragCancel,dmFindTarget);

  FDragobj := ToleDragObject.Create; Fdragobj.dataObj := dataObj; Fdragobj.Fkeys := grfKeyState;
  FTarget  := pointer(DragMessage(FHandle,dmFindTarget,FDragObj,NIL,pt));

  if DragMessage(FHandle,dmDragEnter,Fdragobj,FTarget,pt)<>0
     then dwEffect := DROPEFFECT_COPY
     else dwEffect := DROPEFFECT_NONE;

  Result := S_OK;
end;
function IWCDropTarget.DragOver(grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult;
begin
  Fdragobj.Fkeys := grfKeyState;
  FTarget := pointer(DragMessage(FHandle,dmFindTarget,FDragObj,NIL,pt));

  if DragMessage(FHandle,dmDragMove,Fdragobj,Ftarget,pt)<>0
     then dwEffect := DROPEFFECT_COPY
     else dwEffect := DROPEFFECT_NONE;

  Result := S_OK;
end;
function IWCDropTarget.DragLeave: HResult;
var pt:TPoint;
begin
  DragMessage(FHandle,dmDragCancel,Fdragobj,FTarget,pt);

  if Assigned(FDragObj) then begin Fdragobj.Free; Fdragobj := NIL; end;
  Result := S_OK;
end;
function IWCDropTarget.Drop(const dataObj: IDataObject; grfKeyState: Longint; pt: TPoint; var dwEffect: Longint): HResult;
begin
  Fdragobj.Fkeys := grfKeyState;
  if DragMessage(FHandle,dmDragDrop,Fdragobj,FTarget,pt)<>0
     then dwEffect := DROPEFFECT_COPY
     else dwEffect := DROPEFFECT_NONE;

  if Assigned(FDragObj) then begin Fdragobj.Free; Fdragobj := NIL; end;
  Result := S_OK;
end;

initialization
  oleInitialize(NIL);
finalization
  oleUnInitialize;
end.

