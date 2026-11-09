{  Module          Corvus Site Manager
   Unit            OLE Automation
   Copyright(c)    Postal Solutions Limited 1996..1998
   Author          MJD
   Description     
   Modifications   
                              Original Release
________________________________________________________________________________}

unit SiteManagerAU;

interface

uses
  Windows,SysUtils,Classes,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode;
  
type
  TSiteManager = class(TGPCSComponent,ISiteManager)
  private
    procedure CreatePath(Path:String);
    procedure SetShutdownPrivilege;
    procedure RegisterFile(FileName:String);
    procedure UnRegisterFile(FileName:String);
  protected
    function ApplyUpdate(UpdateType:SMUpdateType;const FromMachineData:WideString):WordBool; virtual; safecall;
    function CopyFile(const FromMachine,FromPath,FromFile,ToMachine,ToPath,ToFile:WideString):WordBool; virtual; safecall;
    function CurrentVersion:WideString; virtual; safecall;
    function ShutDownGPCS:WordBool; virtual; safecall; 
    function StartUpGPCS:WordBool; virtual; safecall;
    function WhosHere:WideString; virtual; safecall;
    procedure LogOffMachine; virtual; safecall;
    procedure ReLoadComponents(const ProgIDs:WideString); virtual; safecall;
    procedure ShutDownMachine; virtual; safecall;
    function GetLocalFile(const Path,Name:WideString;var DateTime:TDateTime):OleVariant; virtual; safecall;
    function SetLocalFile(const Path,Name:WideString;DateTime:TDateTime;Value:OleVariant):WordBool; virtual; safecall;
  public
    procedure Initialize; override;
    destructor Destroy; override;
  end;

implementation

uses ComServ2,SiteManagerFU; // for Class Factory

{===============================================================================
  Class        TSiteManager
  Method       Destroy
  Description  
  Params       None.
  Result       None.
________________________________________________________________________________}
destructor TSiteManager.Destroy;
begin
   inherited Destroy;
end;
procedure TSiteManager.Initialize;
begin
   inherited Initialize;
end;

function TSiteManager.ApplyUpdate(UpdateType:SMUpdateType;const FromMachineData:WideString):WordBool;
var
   SL:TStringList;
   WhosHereList:TStringList;
   CopyData:TStringList;
   I,J:Integer;
   RemoteConnection:ISiteManager;
   FromMachine:String;
begin       
   if FromMachineData = '' then Exit;
   SL:=TStringList.Create;
   SL.CommaText:=FromMachineData;
   CopyData:=TStringList.Create;
   FromMachine:=SL[0];
   SL.Delete(0);
   if FromMachine = 'New Update' then
   begin
      for I:=0 to SL.Count-1 do
      begin
         CopyData.CommaText:=SL[I]; 
         CopyData[0]:=GetLocalMachineName; // From Machine
         CopyData[3]:=GetLocalMachineName; // To Machine
         if CopyData[6] = 'Register' then
         begin
            UnRegisterFile(CopyData[4]+'\'+CopyData[5]);
            CopyFile(CopyData[0],CopyData[1],CopyData[2],CopyData[3],CopyData[4],CopyData[5]);
            RegisterFile(CopyData[4]+'\'+CopyData[5]);
         end
         else
         begin
            CopyFile(CopyData[0],CopyData[1],CopyData[2],CopyData[3],CopyData[4],CopyData[5]);
         end;
         CopyData[1]:=CopyData[4]        ; // From Path := To Path
         CopyData[3]:=GetLocalMachineName; // To Machine
         SL[I]:=CopyData.CommaText;
      end;
      WhosHereList:=TStringList.Create;
      WhosHereList.Assign(SiteManagerForm.WhosHereLB.Items);
      for J:=0 to WhosHereList.Count-1 do
      begin
         if WhosHereList[J] <> GetLocalMachineName then
         begin
            for I:=0 to SL.Count-1 do
            begin
               CopyData.CommaText:=SL[I];
               CopyData[3]:=WhosHereList[J]; // To Machine
               SL[I]:=CopyData.CommaText;
            end;
            RemoteConnection:=CreateActualRemoteSiteManager(WhosHereList[J]);
            RemoteConnection.ApplyUpdate(UpdateType,SL.CommaText);
            RemoteConnection:=nil;
         end;
      end;
      WhosHereList.Free;
   end
   else
   begin
//    LogOffMachine;
      for I:=0 to SL.Count-1 do
      begin
         CopyData.CommaText:=SL[I];
         if CopyData[6] = 'Register' then
         begin
            UnRegisterFile(CopyData[4]+'\'+CopyData[5]);
            CopyFile(CopyData[0],CopyData[1],CopyData[2],CopyData[3],CopyData[4],CopyData[5]);
            RegisterFile(CopyData[4]+'\'+CopyData[5]);
         end
         else
         begin
            CopyFile(CopyData[0],CopyData[1],CopyData[2],CopyData[3],CopyData[4],CopyData[5]);
         end;
      end;
   end;
   CopyData.Free;
   SL.Free;
//   case UpdateType of
//      smuFileUpdate      :
//      smuRegistryUpdate  :
//      smuRegisterFiles   :
//      smuUnRegisterFiles :
//      smuReRegisterFiles :
//      smuReplaceSelf     :
//   end;
   Result:=True;
end;       
function TSiteManager.CopyFile(const FromMachine,FromPath,FromFile,ToMachine,ToPath,ToFile:WideString):WordBool;
var
  RemoteConnection:ISiteManager;
  FileDateTime:TDateTime;
  FileData:OleVariant;
begin
   Result:=False;
   if FromMachine = GetLocalMachineName then
   begin
      try
         if ToMachine = GetLocalMachineName then
            RemoteConnection:=CreateSiteManager
         else
            RemoteConnection:=CreateActualRemoteSiteManager(ToMachine);
         if RemoteConnection <> nil then
         begin
            FileData:=GetLocalFile(FromPath,FromFile,FileDateTime);
            if VarIsEmpty(FileData) then Exit;
            if RemoteConnection.SetLocalFile(ToPath,ToFile,FileDateTime,FileData) then
               Result:=True;
         end;
         RemoteConnection:=nil;
      except
         Exit;
      end;
   end
   else if ToMachine = GetLocalMachineName then
   begin
      try
         RemoteConnection:=CreateActualRemoteSiteManager(ToMachine);
         if RemoteConnection <> nil then
         begin
            FileData:=RemoteConnection.GetLocalFile(FromPath,FromFile,FileDateTime);
            if VarIsEmpty(FileData) then Exit;
            if SetLocalFile(ToPath,ToFile,FileDateTime,FileData) then
               Result:=True;
         end;
         RemoteConnection:=nil;
      except
         Exit;
      end;
   end
   else
   begin
      try
         RemoteConnection:=CreateActualRemoteSiteManager(FromMachine);
         if RemoteConnection <> nil then
            Result:=RemoteConnection.CopyFile(FromMachine,FromPath,FromFile,ToMachine,ToPath,ToFile);
         RemoteConnection:=nil;
      except
         Exit;
      end;
   end;
end;            
function TSiteManager.CurrentVersion:WideString;
begin
   Result:='0';
   if SiteManagerForm <> nil then
      Result:=IntToStr(SiteManagerForm.DGram.Version);
      
end;
function TSiteManager.ShutDownGPCS:WordBool;
begin
   Result:=True;
end;
function TSiteManager.StartUpGPCS:WordBool;
begin
   Result:=True;
end;
function TSiteManager.WhosHere:WideString;
begin
   Result:='';
   if SiteManagerForm <> nil then
      Result:=SiteManagerForm.WhosHereLB.Items.CommaText;
end;
procedure TSiteManager.LogOffMachine; 
begin
   SetShutdownPrivilege;
   ExitWindowsEx(EWX_FORCE or EWX_LOGOFF,0);
end;
procedure TSiteManager.ReLoadComponents(const ProgIDs:WideString);
begin
   ;
end;
procedure TSiteManager.ShutDownMachine;
begin
   SetShutdownPrivilege;
   ExitWindowsEx(EWX_FORCE or EWX_POWEROFF or EWX_SHUTDOWN,0);
end;
function TSiteManager.GetLocalFile(const Path,Name:WideString;var DateTime: TDateTime):OleVariant;
var
 FileStream:TFileStream;
 Data: PChar;
 FileName:String;
begin
   Result:=UnAssigned;
   if Path[Length(Path)] = '\' then 
      FileName:=Path+Name 
   else 
      FileName:=Path+'\'+Name;

   
   FileStream:=TFileStream.Create(FileName,fmOpenRead or fmShareDenyNone);
   try
      DateTime:=FileDateToDateTime(FileGetDate(FileStream.Handle));
      FileStream.Position:=0;
      Result := VarArrayCreate([0, FileStream.Size-1], varByte);
      Data := VarArrayLock(Result);
      try
         FileStream.Read(Data^, FileStream.Size+1);
      except
         ; // File Read Error
      end;
      VarArrayUnlock(Result);
   except
      ; // File Open Error
   end;
   FileStream.Free;
end;
function TSiteManager.SetLocalFile(const Path,Name:WideString;DateTime:TDateTime;Value:OleVariant):WordBool;
var
 FileStream:TFileStream;
 Data: PChar;
 FileName:String;
 Size:Integer;
begin
   Result:=False;
   CreatePath(Path);
   if Path[Length(Path)] = '\' then 
      FileName:=Path+Name 
   else 
      FileName:=Path+'\'+Name;
   try                            
      DeleteFile(FileName);
      FileStream:=TFileStream.Create(FileName,fmCreate or fmShareDenyNone);
   except
      // Error in File Create
      Exit;
   end;
   try
      FileStream.Position:=0;
      Size:=VarArrayHighBound(Value,1)+1;
      Data := VarArrayLock(Value);
      try
         FileStream.Write(Data^, Size);
      except
         VarArrayUnlock(Value);
         FileStream.Free;
         Exit; // File Write Error
      end;
      VarArrayUnlock(Value);
   except
      FileStream.Free;
      Exit; // File Open Error
   end;
   
   if FileSetDate(FileStream.Handle,DateTimeToFileDate(DateTime)) <> 0 then
      Exit;
   FileStream.Free;
   Result:=True;
end;            
procedure TSiteManager.CreatePath(Path:String);
var
   I:Integer;
begin
   if Path[Length(Path)] <> '\' then Path:=Path+'\';
   for I:=1 to Length(Path) do 
      if Path[I] = '\' then 
         CreateDirectory(PChar(Copy(Path,1,I-1)),nil);

end;
procedure TSiteManager.SetShutdownPrivilege;
var
   ProcHandle:THandle;
   TokHandle:THandle;
   TmpLUID:TLargeInteger;
   TokPriv:TTokenPrivileges;
   TokNew:TTokenPrivileges;
   BufferNeeded:Integer;
begin
   ProcHandle:=GetCurrentProcess;
   OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
   LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
   TokPriv.PrivilegeCount:=1;
   TokPriv.Privileges[0].LUID:=TmpLUID;
   TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
   AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;                  
procedure TSiteManager.RegisterFile(FileName:String);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
begin
   if FileName = ''  then Exit;
   if StrUpper(PChar(Copy(FileName,Length(FileName)-2,3))) = 'EXE' then
   begin
      try
         if FileName <> ParamStr(0) then
            WinExec(PChar(FileName+' /RegServer'),SW_SHOW);
      except
         ; // ShowMessage(FileName+' /RegServer - Failed');
      end; 
   end
   else
   begin
      HModule:=LoadLibrary(PChar(FileName));
      if HModule <> 0 then
      begin
         try
            if GetProcAddress(HModule,'DllRegisterServer') <> nil then
            begin
               UnRegFunc:=GetProcAddress(HModule,'DllRegisterServer');
               UnRegFunc;
            end
            else
            begin
               ; // ShowMessage(FileName+' DllRegisterServer - Failed');
            end;
         except
            ; // ShowMessage(FileName+' DllRegisterServer - Failed');
         end;
         FreeLibrary(HModule);
      end
      else
      begin
         ; // ShowMessage('LoadLibrary('+FileName+') - Failed');
      end;
   end;                         
end;
procedure TSiteManager.UnRegisterFile(FileName:String);
type
  TRegUnRegFunc = procedure;
var
   HModule:THandle;
   UnRegFunc:TRegUnRegFunc;
begin
   if FileName = '' then Exit;
   if Copy(FileName,Length(FileName)-2,3) = 'EXE' then
   begin
      try
         if FileName <> ParamStr(0) then
            WinExec(PChar(FileName+' /UnRegServer'),SW_HIDE);
      except
         ; // ShowMessage(FileName+' /UnRegServer - Failed');
      end;
   end
   else
   begin
      HModule:=LoadLibrary(PChar(FileName));
      if HModule <> 0 then
      begin
         try
            if GetProcAddress(HModule,'DllUnregisterServer') <> nil then
            begin
               UnRegFunc:=GetProcAddress(HModule,'DllUnregisterServer');
               UnRegFunc;
            end;
         except
            ; // ShowMessage(FileName+' DllUnregisterServer - Failed');
         end;
         FreeLibrary(HModule);
      end;                         
   end;                         
end;
    
initialization
  TGPCSCompFactory.Create(ComServer,TSiteManager,Class_SiteManager,
                          'Support.SiteMan','GPCS Site Manager',
                          ciMultiInstance);
end.
