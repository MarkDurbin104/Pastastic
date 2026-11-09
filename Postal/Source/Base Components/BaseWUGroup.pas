unit BaseWUGroup;

interface

uses
  Classes,ComObj, ActiveX, SysUtils, GPCSBaseAU, GPCSBase_TLB,
  GPCSErrorLine,GPCSErrorCode,GPCSGUID,PackStrListU;
   
type
  TBaseWUGroup = class(TGPCSAbstractWUGroup)
  protected
    FMergeList:TPackStringList;
    function GetResourceString(Index:Integer):String; virtual; abstract;
  public
    destructor Destroy; override;
    function Get_Version: Integer;                    override;
    function Get_Name: WideString;                    override;
    function Get_ProjectFiles: WideString;            override; 
    function Get_GUID: WideString;                    override; 
    function Get_ProgramID: WideString;               override; 
    function Get_Count: Integer;                    override;
    function Get_Item(Index: Integer): WideString;  override;
    procedure ApplyGroup(const WUGroup: WideString);override;
  end;
implementation

function TBaseWUGroup.Get_Version: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riVersion),1);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseWUGroup.Get_Name: WideString;
begin
   try
      Result:=GetResourceString(riName);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseWUGroup.Get_ProjectFiles: WideString;
begin
   try
      Result:=GetResourceString(riProjectFiles);
   except                               
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseWUGroup.Get_GUID: WideString;
begin
   try
      Result:=GetResourceString(riGUID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBaseWUGroup.Get_ProgramID: WideString;   
begin
   try
      Result:=GetResourceString(riProgramID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
destructor TBaseWUGroup.Destroy;
begin
   if FMergeList <> nil then FMergeList.Free;
   FMergeList:=nil;
   inherited Destroy;
end;
function TBaseWUGroup.Get_Count: Integer;
begin
   try
      if FMergeList <> nil then 
         Result:=FMergeList.Count
      else
         Result:=StrToIntDef(GetResourceString(riCount),0);
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Count,E);
   end;
end;
function TBaseWUGroup.Get_Item(Index: Integer): WideString;
begin
   try
      if FMergeList <> nil then 
      begin
         if Index < FMergeList.Count then
            Result:=FMergeList[Index]
         else
            Result:='';
      end
      else
      begin
         Result:=GetResourceString(riItemBase+Index);
      end;
   except
      on E:Exception do RaiseException(EC_Group_TBaseGroup_Get_Item,E);
   end;
end;
procedure TBaseWUGroup.ApplyGroup(const WUGroup: WideString);
var
   SL:TPackStringList;
   CompMan:ICompMan;
   I:Integer;
   MergeGroup:IWUGroup;
begin
   if FMergeList <> nil then 
   begin
      FMergeList.Free;
      FMergeList:=nil;
   end;
   
   CompMan:=CreateCompMan;
   MergeGroup:=CompMan.LoadComponent(WUGroup) as IWUGroup;
   CompMan:=nil;
   
   if MergeGroup <> nil then
   begin
      SL:=TPackStringList.Create;
      for I:=0 to Get_Count-1 do SL.Add(Get_Item(I));
      
      FMergeList:=TPackStringList.Create;
      for I:=0 to MergeGroup.Count-1 do
      begin
        if SL.IndexOf(MergeGroup.Item[I]) <> -1 then
           FMergeList.Add(MergeGroup.Item[I]);
      end;
      SL.Free;
   end;
end;

end.
