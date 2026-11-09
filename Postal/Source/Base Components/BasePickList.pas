unit BasePickList;

interface

uses
  Classes,ComObj, ActiveX, SysUtils, GPCSBaseAU, GPCSBase_TLB,
  GPCSErrorLine,GPCSErrorCode,GPCSGUID,PackStrListU;
  
type
  TBasePickList = class(TGPCSAbstractPickList,IEventSink)
  private
     FCurrentColumn:Integer;
     FColumnNameList:TPackStringList;
  protected
    procedure Initialize; override;
    destructor Destroy; override;
    function GetResourceString(Index:Integer):String;            virtual; abstract;
    procedure Complete(const EventSource: IExecComponent);       virtual; safecall;
    procedure DesignComplete(const EventSource: IExecComponent); virtual; safecall;
    function Get_Name: WideString;                    override; 
    function Get_ProjectFiles: WideString;            override; 
    function Get_GUID: WideString;                    override; 
    function Get_ProgramID: WideString;               override; 
    function Get_RowCount: Integer;                              override;
    function Get_ColumnCount: Integer;                           override;
    function Get_ColumnName(Index: Integer): WideString;         override;
    function Get_Item(Index:Integer): WideString;                override;
    function Get_CurrentColumn: WideString;                      override;
    procedure Set_CurrentColumn(const Value: WideString);        override;
  public                                             
    function Get_Version: Integer;                               override;
    function Design(const Password:WideString;const EVSink:IDesignEventSink):WideString; override;
    procedure TerminateDesign;                                   override;
  end;                             
implementation


{TBasePickList}
function TBasePickList.Get_Name: WideString;
begin
   try
      Result:=GetResourceString(riName);
   except                                       
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBasePickList.Get_ProjectFiles: WideString;
begin
   try
      Result:=GetResourceString(riProjectFiles);
   except                               
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBasePickList.Get_GUID: WideString;
begin
   try
      Result:=GetResourceString(riGUID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
function TBasePickList.Get_ProgramID: WideString;   
begin
   try
      Result:=GetResourceString(riProgramID);
   except
      on E:Exception do RaiseException(EC_Product_TBaseProduct_Get_BarCode,E);
   end;
end;
procedure TBasePickList.Initialize;
var
   Index:Integer;
begin
   inherited Initialize;
   FCurrentColumn:=0;
   FColumnNameList:=TPackStringList.Create;
   if FColumnNameList <> nil then 
      for Index:=0 to Get_ColumnCount-1 do
         FColumnNameList.Add(Get_ColumnName(Index));
end;
destructor TBasePickList.Destroy;
begin
   if FColumnNameList <> nil then FColumnNameList.Free;
   inherited Destroy;
end;                    
function TBasePickList.Get_Version: Integer;
begin
   try
      Result:=StrToIntDef(GetResourceString(riVersion),1);
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
function TBasePickList.Design(const Password:WideString;const EVSink:IDesignEventSink):WideString; 
begin
   try
      Result:='';
   except
      on E:Exception do RaiseException(2,E);
   end;
end;
function TBasePickList.Get_RowCount: Integer;                      
begin
   try
      Result:=StrToIntDef(GetResourceString(riCount),1);
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
function TBasePickList.Get_ColumnCount: Integer;                   
begin
   try
      Result:=StrToIntDef(GetResourceString(riColumnCount),1);
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
function TBasePickList.Get_ColumnName(Index: Integer): WideString; 
begin
   try
      Result:=GetResourceString(riColumnName+Index);
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
function TBasePickList.Get_Item(Index:Integer): WideString;        
begin
   try
      Result:=GetResourceString(riDimensionBase+(Get_RowCount*FCurrentColumn)+Index);
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
function TBasePickList.Get_CurrentColumn: WideString;              
begin
   Result:='';
   try
      if (FColumnNameList <> nil) and (FCurrentColumn < FColumnNameList.Count) then 
         Result:=FColumnNameList[FCurrentColumn];
   except
      on E:Exception do RaiseException(1,E);
   end;
end;
procedure TBasePickList.Set_CurrentColumn(const Value: WideString);
begin
   try
      if (FColumnNameList <> nil) then 
      begin
         FCurrentColumn:=FColumnNameList.IndexOf(Value);
         if FCurrentColumn < 0 then
            FCurrentColumn:=0;
      end;
   except
      on E:Exception do RaiseException(1,E);
   end;
end;

procedure TBasePickList.TerminateDesign;           
begin
   try
     // do something
   except
      on E:Exception do RaiseException(3,E);
   end;
end;
procedure TBasePickList.Complete(const EventSource: IExecComponent);
begin
end;      
procedure TBasePickList.DesignComplete(const EventSource: IExecComponent);
begin
end;

end.

