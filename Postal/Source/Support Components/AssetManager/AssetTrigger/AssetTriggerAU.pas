unit AssetTriggerAU;

interface

uses
  Dialogs,
  Classes, SysUtils,GPCSErrorLine,
  ComObj, ActiveX, AssetManager_TLB;

const
  TriggerCode : WideString = '""';  //commatext


type
  TAssetTrigger = class(TAutoObject, IAssetTrigger)
  private
    ParamStringList : TStringList;

  protected
    procedure AddParam(const ParamName: WideString; ParamValue: OleVariant);
      safecall;
    destructor Destroy; override;
    procedure Initialize; override;
    function Param(ParamName : String) : OleVariant;
    function TriggerValue(Value: Double): Double; virtual; safecall;
      safecall;
    function Get_Code : WideString; safecall;
    function Get_TriggerCode: WideString; virtual;safecall;
  end;

  TParamObject = class
  public
    ParamValue : OleVariant;
  end;

  TAssetTriggerWrap = class
  public
    AssetTrigger : IAssetTrigger;
  end;

implementation


procedure TAssetTrigger.AddParam(const ParamName: WideString;
  ParamValue: OleVariant);
var
  ParamIndex : Integer;
  ParamObject : TParamObject;
begin
  With ParamStringList do
  begin
    ParamIndex := ParamStringList.IndexOf(ParamName);
    If ParamIndex < 0 then
    begin
      ParamObject := TParamObject.Create;
      ParamObject.ParamValue := ParamValue;
      ParamStringList.AddObject(ParamName, ParamObject);
    end
    else
    begin
      (Objects[ParamIndex] As TParamObject).ParamValue := ParamValue;
    end;
  end;
end;

destructor TAssetTrigger.Destroy;
begin
  try
    ParamStringList.Free;
  except
    On E : Exception do
      GPCSErrorLine.RaiseException(0,E);
  end;
  Inherited;
end;

procedure TAssetTrigger.Initialize;
begin
  Inherited;
  try
    ParamStringList := TStringList.Create;
  except
    On E : Exception do
      GPCSErrorLine.RaiseException(0,E);
  end;
end;

function TAssetTrigger.Param(ParamName : String) : OleVariant;
var
  ParamIndex : Integer;
begin
  ParamIndex := ParamStringList.IndexOf(ParamName);
  If ParamIndex <0 then
    Result := 0
  else
    Result := (ParamStringList.Objects[ParamIndex] As TParamObject).ParamValue;
end;

function TAssetTrigger.TriggerValue(Value: Double): Double;
begin
  try
    Result := {TriggerValue}0;
  except
    On E : Exception do
      GPCSErrorLine.RaiseException(0,E);
  end;
end;

function TAssetTrigger.Get_TriggerCode: WideString;
begin
  Result := TriggerCode;
end;

function TAssetTrigger.Get_Code: WideString;
begin
  Result := ClassName;
end;


end.
