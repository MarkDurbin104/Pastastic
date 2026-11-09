unit HookUpAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,Dialogs,DatabaseServer_TLB;
  
type
  THookUp = class(TGPCSHookUp)
     FAccounts:IAccounts;
     FCounters:IDevice;
     FDBServer:IDispatch;
     FTranslate:ITranslate;
  public         
     procedure Initialize; override;
     destructor Destroy; override;
  protected
     function  Get_Accounts:IAccounts; override;
     function  Get_Counters:IDevice; override;
     function  Get_DatabaseServer: IDispatch; override;
     function  Get_Translate:ITranslate; override;
     procedure KeepAwake; override;
     procedure ReleaseHooks; override;
  end;                  
  
implementation
uses
   ComServ2,HookUpFU;
   
procedure THookUp.Initialize;
begin
   inherited Initialize;
   try
      FDBServer:=CoDatabaseServerAuto.Create;;
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' DBServer Error in HookUp');
   end;
   try
      FAccounts:=CreateAccounts;
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Accounts Error in HookUp');
   end;
//   try
//      FCounters:=CreateCounterDevice;
//   except
//      on E:Exception do RaiseError($80,0,0,E.Message+' Counters Error in HookUp');
//   end;
   try
      FTranslate:=CreateTranslator;
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Translator Error in HookUp');
   end;
end;  
destructor THookUp.Destroy;
begin
   if FDBServer  <> nil then FDBServer :=nil;
//   if FCounters  <> nil then FCounters :=nil;
   if FAccounts  <> nil then FAccounts :=nil;
   if FTranslate <> nil then FTranslate:=nil;
   
   inherited Destroy;
end;
function THookUp.Get_Accounts:IAccounts;
begin
   try
      if FAccounts = nil then
         FAccounts:=CreateAccounts;
      Result:=FAccounts;
      HookForm.AccountsHooked.Checked:=True;
      HookForm.Edit1.Text:=IntToStr(StrToInt(HookForm.Edit1.Text)+1);
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Get_Accounts Error in HookUp');
   end;
end;
function THookUp.Get_Counters:IDevice;
begin
   try
//      if FCounters = nil then
//        FCounters:=CreateCounterDevice;
      Result:=FCounters;
      HookForm.CountersHooked.Checked:=True;               
      HookForm.Edit2.Text:=IntToStr(StrToInt(HookForm.Edit2.Text)+1);
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Get_Counters Error in HookUp');
   end;
end;
function THookUp.Get_Translate:ITranslate;
begin
   try
      if FTranslate = nil then
        FTranslate:=CreateTranslator;
      Result:=FTranslate;
      HookForm.TranslateHooked.Checked:=True;               
      HookForm.Edit5.Text:=IntToStr(StrToInt(HookForm.Edit5.Text)+1);
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Get_Translate Error in HookUp');
   end;
end;
function THookUp.Get_DatabaseServer: IDispatch;
begin
   try
      if FDBServer = nil then
        FDBServer:=CoDatabaseServerAuto.Create;;
      Result:=FDBServer;
      HookForm.DBServerHooked.Checked:=True;
      HookForm.Edit3.Text:=IntToStr(StrToInt(HookForm.Edit3.Text)+1);
   except
      on E:Exception do RaiseError($80,0,0,E.Message+' Get_DBServer Error in HookUp');
   end;
end;                                                    

procedure THookUp.KeepAwake;
begin
   HookForm.Edit4.Text:=IntToStr(StrToInt(HookForm.Edit4.Text)+1);
end;

procedure THookUp.ReleaseHooks;
begin
   if FDBServer <> nil then FDBServer:=nil;
   if FCounters <> nil then FCounters:=nil;
   if FAccounts <> nil then FAccounts:=nil;
   if FTranslate <> nil then FTranslate:=nil;
end;
    
initialization
  TGPCSCompFactory.Create(ComServer,THookUp,Class_HookUp,
                          'Support.HookUp','GPCS HookUp',
                          ciMultiInstance);
end.