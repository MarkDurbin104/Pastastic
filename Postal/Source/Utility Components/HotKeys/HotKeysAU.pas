unit HotKeysAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry;
  
type
  THotKeys = class(TBaseHotKeys,IHotKeys)
  protected
    FKeyList:TStringList;
  public                
     procedure Initialize; override;
     destructor Destroy; override;
     function ComponentToExecute(KeyStroke,ShiftState:Integer):WideString; override;
  end;                  
  
implementation
uses
   ComServ2;
procedure THotKeys.Initialize;
var
  I:Integer;
begin
   FKeyList:=TStringList.Create;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\GPCS\HotKeys',False) then
         begin
            GetValueNames(FKeyList);
            for I:=0 to FKeyList.Count-1 do
               FKeyList[I]:=FKeyList[I]+'='+ReadString(FKeyList[I]);
            CloseKey;
         end;
      end;
   except
   end;
   inherited Initialize;
end;
destructor THotKeys.Destroy;
begin
   FKeyList.Free;
   Inherited Destroy;
end;         
function THotKeys.ComponentToExecute(KeyStroke,ShiftState:Integer):WideString;
var
   KeyString:String;
   KSLen:Integer;
begin
   Result:='';
   KSLen:=100;
   SetLength(KeyString,KSLen);
   KSLen:=GetKeyNameText(KeyStroke,PChar(KeyString),KSLen);
   if KSLen = 0 then  Exit;
   SetLength(KeyString,KSLen);
   if (KeyString = 'Shift') or (KeyString = 'Ctrl') or (KeyString = 'Alt') then
      Exit;
   if (ShiftState and 1) <> 0 then KeyString:='Alt-'+KeyString;
   if (ShiftState and 2) <> 0 then KeyString:='Ctrl-'+KeyString;
   if (ShiftState and 4) <> 0 then KeyString:='Shift-'+KeyString;
   Result:=FKeyList.Values[KeyString];
end;
   
initialization
  TGPCSCompFactory.Create(ComServer,THotKeys,Class_HotKeys,
                          'Support.HotKeys','GPCS Hot Keys',
                          ciMultiInstance);
end.