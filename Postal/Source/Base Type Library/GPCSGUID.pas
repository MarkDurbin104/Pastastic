unit GPCSGUID;

interface

uses
   Classes,Windows,SysUtils,ActiveX,ComObj,GPCSBase_TLB,Registry,MethodNameU,PackStrListU,FileCtrl,UserManager_TLB;
 //UManager_TLB;

type
  TCoCreateInstanceExProc = function (const clsid: TCLSID;
    unkOuter: IUnknown; dwClsCtx: Longint; ServerInfo: PCoServerInfo;
    dwCount: Longint; rgmqResults: PMultiQIArray): HResult stdcall;

const
   DaysUntil_010198 = 35796;
   MAX_USERNAME_LEN = 100;
   
   BUTTON_UP              = $41;
   BUTTON_DOWN            = $42;
   BUTTON_TOGGLE          = $44;
   BUTTON_ENABLED         = $A0;
   BUTTON_DISABLED        = $80;
   BUTTON_ENABLED_UP      = $E1;
   BUTTON_ENABLED_DOWN    = $E2;
   BUTTON_ENABLED_TOGGLE  = $E4;
   BUTTON_DISABLED_UP     = $C1;
   BUTTON_DISABLED_DOWN   = $C2;
   BUTTON_DISABLED_TOGGLE = $C4;

const
   Class_GPCSErrorHandler  :TGUID = '{9D67CA66-CE9C-11D1-8A92-080000223037}';
   Class_GPCSCompLoad      :TGUID = '{9D67CA67-CE9C-11D1-8A92-080000223037}';
   Class_GPCSCompMan       :TGUID = '{9D67CA68-CE9C-11D1-8A92-080000223037}';
   Class_GPCSTransactionLog:TGUID = '{9D67CA69-CE9C-11D1-8A92-080000223037}';
   Class_OCRDevice         :TGUID = '{9D67CA6A-CE9C-11D1-8A92-080000223037}';
   Class_SerialDevice      :TGUID = '{9D67CA6B-CE9C-11D1-8A92-080000223037}';
   Class_ReceiptDevice     :TGUID = '{9D67CA6C-CE9C-11D1-8A92-080000223037}';
   Class_ScaleDevice       :TGUID = '{9D67CA6D-CE9C-11D1-8A92-080000223037}';
   Class_LabelDevice       :TGUID = '{9D67CA6E-CE9C-11D1-8A92-080000223037}';
   Class_PassBookDevice    :TGUID = '{9D67CA6F-CE9C-11D1-8A92-080000223037}';
   Class_CustDispDevice    :TGUID = '{9D67CA70-CE9C-11D1-8A92-080000223037}';
   Class_GPCSPictureServer :TGUID = '{9D67CA71-CE9C-11D1-8A92-080000223037}';
   Class_CounterDevice     :TGUID = '{9D67CA72-CE9C-11D1-8A92-080000223037}';
   Class_OfficeInfoDevice  :TGUID = '{9D67CA73-CE9C-11D1-8A92-080000223037}';
   Class_GPCSTrackedMail   :TGUID = '{9D67CA74-CE9C-11D1-8A92-080000223037}';
   Class_ExtBarCodeDevice  :TGUID = '{9D67CA75-CE9C-11D1-8A92-080000223037}';
   Class_ExchangeRateServer:TGUID = '{9D67CA76-CE9C-11D1-8A92-080000223037}';
   Class_HotKeys           :TGUID = '{9D67CA77-CE9C-11D1-8A92-080000223037}';
   Class_Accounts          :TGUID = '{9D67CA78-CE9C-11D1-8A92-080000223037}';
   Class_SiteManager       :TGUID = '{9D67CA79-CE9C-11D1-8A92-080000223037}';
   Class_ParallelDevice    :TGUID = '{9D67CA7A-CE9C-11D1-8A92-080000223037}';
   Class_OvationDevice     :TGUID = '{9D67CA7B-CE9C-11D1-8A92-080000223037}';
   Class_HookUp            :TGUID = '{9D67CA7C-CE9C-11D1-8A92-080000223037}';
   Class_Stock             :TGUID = '{9D67CA7D-CE9C-11D1-8A92-080000223037}';
   Class_UIServer          :TGUID = '{9D67CA7E-CE9C-11D1-8A92-080000223037}';
   Class_GPCSTranslate     :TGUID = '{9D67CA7F-CE9C-11D1-8A92-080000223037}';
   Class_Messenger         :TGUID = '{9D67CA80-CE9C-11D1-8A92-080000223037}';
   Class_GPCSPeriod        :TGUID = '{9D67CA81-CE9C-11D1-8A92-080000223037}';
   Class_GPCSTableMonitor  :TGUID = '{9D67CA82-CE9C-11D1-8A92-080000223037}';
   Class_TanApplication    :TGUID = '{A4D7ED90-2B0F-11D3-96F9-DEE8E6C0AD37}';
   Class_BerApplication    :TGUID = '{44D9BEA0-8366-11D3-AA05-00A0CC3A61B2}';
   Class_PakApplication    :TGUID = '{7C5C83F0-2B0F-11D3-96F9-DEE8E6C0AD37}';
   Class_SauApplication    :TGUID = '{ABE2ED50-2B0E-11D3-96F9-DEE8E6C0AD37}';
   Class_BotApplication    :TGUID = '{38EC6ED4-BD79-40F0-BB95-BD840DED85BA}';
   Class_UgaApplication    :TGUID = '{A7137A01-7059-42E4-9BA2-E9D4C29B9B70}';
   Class_GerApplication    :TGUID = '{46BCD4E3-6F09-40E5-9FE6-538D0F5CA069}';
   Class_SwaApplication    :TGUID = '{CDF79A3D-1694-4487-9086-D19B22ED7B13}';
   Class_OmaApplication    :TGUID = '{695D2801-D968-4130-922F-22CE1ED79E44}';


function CreateMessenger:IMessenger;
function CreateRemoteMessenger(const MachineName:String):IMessenger;
function CreateAccounts:IAccounts;
function CreateRemoteAccounts(const MachineName:String):IAccounts;
function CreateExchangeRateServer:IExchangeRateServer;
function CreateRemoteExchangeRateServer(const MachineName:String):IExchangeRateServer;
function CreateHotKeys:IHotKeys;
function CreateRemoteHotKeys(const MachineName:String):IHotKeys;
function CreateErrorHandler:IErrorHandler;
function CreateRemoteErrorHandler(const MachineName:String):IErrorHandler;
function CreateCompLoad:ICompLoad;
function CreateRemoteCompLoad(const MachineName:String):ICompLoad;
function CreateCompMan:ICompMan;
function CreateRemoteCompMan(const MachineName:String):ICompMan;
function CreateTransactionLog:ITransactionLog;
function CreateRemoteTransactionLog(const MachineName:String):ITransactionLog;
function CreatePeriod:IPeriod;
function CreateRemotePeriod(const MachineName:String):IPeriod;
function CreateTableMonitor:ITableMonitor;
function CreateRemoteTableMonitor(const MachineName:String):ITableMonitor;


function CreateOCRDevice     :IDevice;
function CreateSerialDevice  :IDevice;
function CreateReceiptDevice :IDevice;
function CreateScaleDevice   :IDevice;
function CreateLabelDevice   :IDevice;
function CreatePassBookDevice:IDevice;
function CreateCustDispDevice:IDevice;
function CreateRemoteOCRDevice     (const MachineName:String):IDevice;
function CreateRemoteSerialDevice  (const MachineName:String):IDevice;
function CreateRemoteReceiptDevice (const MachineName:String):IDevice;
function CreateRemoteScaleDevice   (const MachineName:String):IDevice;
function CreateRemoteLabelDevice   (const MachineName:String):IDevice;
function CreateRemotePassBookDevice(const MachineName:String):IDevice;
function CreateRemoteCustDispDevice(const MachineName:String):IDevice;

function CreatePictureServer:IPictureServer;
function CreateRemotePictureServer(const MachineName:String):IPictureServer;

function CreateCounterDevice :IDevice;
function CreateRemoteCounterDevice (const MachineName:String):IDevice;

function CreateOfficeInfoDevice :IDevice;
function CreateRemoteOfficeInfoDevice (const MachineName:String):IDevice;

function CreateTrackedMailLog :IMailItemLog;
function CreateRemoteTrackedMailLog (const MachineName:String):IMailItemLog;

function CreateExtBarCodeDevice :IDevice;
function CreateRemoteExtBarCodeDevice (const MachineName:String):IDevice;
function CreateSiteManager :ISiteManager;
function CreateRemoteSiteManager (const MachineName:String):ISiteManager;
function CreateActualRemoteSiteManager (const MachineName:String):ISiteManager;

function ReportPreviewOnly:Boolean;
function GetLocalMachineName:String;
function GetUserLoginName:String;
function GetGPCSRegNames(Key,DefaultResult:String):String;
function GetGPCSRegValues(Key,DefaultResult:String):String;
procedure SetGPCSRegNames(Key,Values:String);
function GetGPCSRegString(Key,Name,DefaultResult:String):String;
procedure SetGPCSRegString(Key,Name,Value:String);
function GetGPCSKeyNames(Key:String):String;
function GetPSLRegNames(Key,DefaultResult:String):String;
function GetPSLRegValues(Key,DefaultResult:String):String;
procedure SetPSLRegNames(Key,Values:String);
function GetPSLRegString(Key,Name,DefaultResult:String):String;
procedure SetPSLRegString(Key,Name,Value:String);
function GetPSLNamesValues(Key:String):String;
procedure SetPSLNamesValues(Key,Value:String);
function GetPSLKeyNames(Key:String):String;
function CreateActualRemoteComObject(const MachineName:WideString;const ClassID:TGUID):IUnknown;
function ApplicationRootPath:String;
procedure DeleteCountryExchange(Value:String);

function CreateParallelDevice  :IDevice;
function CreateRemoteParallelDevice(const MachineName:String):IDevice;

function CreateHookUp:IHookUp;
function CreateRemoteHookUp(const MachineName:String):IHookUp;
function CreateStock:IStock;
function CreateRemoteStock(const MachineName:String):IStock;
function CreateTranslator:ITranslate;
function CreateRemoteTranslator(const MachineName:String):ITranslate;

function GrammesSymbol:String;
function ToSymbol:String;
function GenerateGUID:String;

procedure GlobalExceptionEvent(Sender: TObject; E: Exception);
function GetTodayasPeriod:Integer;
function StrToCurrDef(Value:String;Default:Currency):Currency;
procedure EraseKey(Root:HKEY;KeyName:String);
procedure EraseValue(Root:HKEY;KeyName,Value:String);
function GetExchangeNames:String;
function GetExchangeRate(Name:String):Currency;
function ApplyRounding(Value:Currency):Currency;
procedure UpdateLocalList(ListName,ListData,ListGroup:String);
function GetLocalList(ListName,ListGroup:String):String;
function  NeedStartOfDay( UserGroup: String  ):Boolean;
function GetUserNumber(UserName:String):Integer;
procedure SetUsersBroadCast( UsersInfo:String ) ;
function GetGPCSUserGroup( ServerName, User :String; NetManager:INetUser ) :String;
procedure Shutdown;
procedure ReStart;
procedure PowerOff;
procedure LogOff;

var
   CurrentMethodName:String;

procedure CurrentMethod(Value:String);

implementation

uses
   GPCSErrorLine,StringUtil;

procedure UpdateLocalList(ListName,ListData,ListGroup:String);
var
   SL:TPackStringList;
   SLOldList:TPackStringList;
   SLOptions:TStringList ;
   I,P:Integer;
   CustomerFilePath :String ;
   FStm:TFileStream;
begin
   // The existing format file
   // Listgroup with information  will be     EMS,CST^Custom PePe Lotas
   // Empty ListGroup             will be     Custom PePe Lotas

   CustomerFilePath := GetGPCSRegString('Customers','CustomerLstFile',ApplicationRootPath+'Lists');
   SL:=TPackStringList.Create;

   try
      if not FileExists(CustomerFilePath) then
      begin
         ForceDirectories(CustomerFilePath);
         FStm:=TFileStream.create( CustomerFilePath+'\'+ListName+'.lst',fmCreate	);
         FStm.Free;
      end;

      SL.PackText:=ListData;
      if ListGroup = '' then
      begin

         SL.SaveToFile(CustomerFilePath+'\'+ListName+'.lst');
      end
      else
      begin
         SLOldList :=TPackStringList.Create;
         SLOptions:=TStringList.Create ;
         if FileExists(CustomerFilePath+'\'+ListName+'.lst') then
         begin

            SLOldList.LoadFromFile(CustomerFilePath+'\'+ListName+'.lst');
            I := 0 ;
            // Delete the existing ones
            while I < SLOldList.Count do
            begin
               P := Pos('^',SLOldList[I]);
               SLOptions.CommaText:=Copy(SLOldList[I],1, P-1); // find the existing groups
               if SLOptions.IndexOf(ListGroup) >= 0 then
               begin
                  if SLOptions.Count=1 then
                     SLOldList.Delete(I)     // Remove it from the list
                  else
                  begin
                     SLOptions.Delete( SLOptions.IndexOf(ListGroup) ); // Delete the group list
                     SLOldList[I]:= SLOptions.CommaText+'^'+Copy(SLOldList[I],P+1,999);
                     Inc(I);
                  end ;
               end
               else
                  Inc(I);
            end ;

            // Add the new ones ( into the existing descriptions )
            for I := 0 to SLOldList.Count-1 do
            begin
               P := Pos('^',SLOldList[I]);
               if SL.IndexOf( Copy(SLOldList[I],P+1,999)) >= 0 then
               begin
                  SL.Delete(SL.IndexOf( Copy(SLOldList[I],P+1,999))); // remove it from the list
                  SLOptions.CommaText:=Copy(SLOldList[I],1, P-1); // Old Groups
                  SLOptions.Add( ListGroup );                    // Actual Groups
                  SLOldList[I]:= SLOptions.CommaText+'^'+Copy(SLOldList[I],P+1,999); // Description

               end ;
            end ;
            // Add the new ones (The description didn't exist before)
            for I := 0 to SL.Count -1 do
               SLOldList.Add( ListGroup + '^' + SL[I] );

            SLOldList.SaveToFile(CustomerFilePath+'\'+ListName+'.lst');

         end
         else
           RaiseGUIDError('{A8CD3D2C-A50E-4D31-916C-A49A8FBFADD0}','ListFile '+ApplicationRootPath+'Lists\'+ListName+'.lst NOT FOUND');

         SLOldList.Free ;
         SLOptions.Free ;
      end ;

   except
      on E:Exception do
         RaiseGUIDException('{DC7D6F31-4C7F-4280-87D3-28FEC7AD5789}',E);
   end;
   SL.Free;

end;
function GetLocalList(ListName,ListGroup:String):String;
var
   SLOptions:TStringList;
   SL:TPackStringList;
   SLGroup:TPackStringList;
   ListResult:TPackStringList;
   I,P:integer;
   CustomerFilePath:String;
begin
   SL:=TPackStringList.Create;
   SLOptions:=TStringList.Create;
   ListResult:=TPackStringList.Create;
   SLGroup:=TPackStringList.create;
   CustomerFilePath := GetGPCSRegString('Customers','CustomerLstFile',ApplicationRootPath+'Lists');
   try
      if not FileExists(CustomerFilePath) then
         ForceDirectories(CustomerFilePath);

      if FileExists(CustomerFilePath+'\'+ListName+'.lst') then
         SL.LoadFromFile(CustomerFilePath+'\'+ListName+'.lst')
      else
      begin
         RaiseGUIDError('{35C2B3BB-D4DE-449C-A873-66514B9DF084}','ListFile '+CustomerFilePath+'\'+ListName+'.lst NOT FOUND');
         SL.Add('No Companies Found!');
      end;

      if ( ListGroup = '' ) then
         ListResult.PackText:=SL.PackText
      else
      begin
         for I:=0 to SL.Count-1 do
         begin
            P := Pos('^',SL[I]);
            SLOptions.CommaText := (Copy(SL[I],1, P-1)) ;
            if SLOptions.IndexOf( ListGroup ) >= 0 then
               SLGroup.Add( Copy( SL[I], P+1, 999 ) );

         end ;
         ListResult.PackText:=SLGroup.PackText;
      end ;

      Result:=ListResult.PackText;
   except
      on E:Exception do
         RaiseGUIDException('{DC7D6F31-4C7F-4280-87D3-28FEC7AD5789}',E);
   end;
   SL.Free;
   ListResult.Free;
   SLGroup.free;
   SLOptions.Free;
end;

function ApplyRounding(Value:Currency):Currency;
var
  Rounding : Currency;
  RoundingType: String ;
begin
  { Round to the nearest Rounding setting }
  Rounding := StrToCurrDef(GetGPCSRegString('','Apply Rounding','0'),0);
  RoundingType:= GetGPCSRegString('','Rounding Type','Near');
  If Rounding <> 0 then
  begin
       Result := Round( Value * (1 / Rounding) ) * Rounding;
       if RoundingType='High' then
          if ( Result - Value) < 0 then // it rounded it down
            result := Round(Value);
  end
  else
    Result := Value;

  { Old calculation where Post Office was always better off if +ve or -ve value }
//   if Trunc(value*100) mod 5 <> 0 then
//     Result := Round(value*20+ 0.5)*0.05
//   else
//     Result := Value;
end;

procedure CurrentMethod(Value:String);
begin
   CurrentMethodName:=Value;
end;
function StrToCurrDef(Value:String;Default:Currency):Currency;
var
   S:String;
   I:Integer;
   HadDot:Boolean;
begin
	Result:=Default;
   HadDot:=False;
   S:=''; // Clean up string
   for I:=1 to Length(Value) do
   begin
      if Value[I] in ['0'..'9'] then
         S:=S+Value[I]
      else if (Value[I] = '.') and not HadDot then
      begin
         S:=S+Value[I];
         HadDot:=True;
      end
      else if (I = 1) and (Value[I] = '-') then
         S:=S+Value[I]
      else if Value[I] = 'E' then //scientific
      begin
        S := S + Copy(Value, I, Length(Value)-(I-1)); //add scientific suffix (eg 'E-13') to string
        Break;
      end;

   end;
   if S = '' then Exit;
{   try
      Result:=StrToCurr(S);
   except
   	  Result := default;
   end;
}
   if not TextToFloat(PChar(S),Result,fvCurrency) then
	   Result:=Default;

end;

function GetTodayasPeriod:Integer;
const
  FirstEntry:Boolean = True;
  HourFraction:TDateTime = 0;
var
   StartHour:Integer;
begin
   if FirstEntry then
   begin
      FirstEntry:=False;
      StartHour:=StrToIntDef(GetGPCSRegString('','Period Start Hour','0'),0);
      if (StartHour > 0) and (StartHour < 24) then
         HourFraction:=StartHour/24;
   end;
   Result:=Trunc(Now-HourFraction)-DaysUntil_010198;
end;
procedure GlobalExceptionEvent(Sender: TObject; E: Exception);
begin
   GPCSErrorLine.RaiseError(0,0,0,
      '('+Sender.ClassName+')('+GetMethodAtAddress(Sender.ClassType,ExceptAddr)+') at '+IntToHex(Integer(ExceptAddr),8)+' '+E.Message);
end;
function GetExchangeNames:String;
begin
   Result:=GetGPCSRegNames('ExchangeRates','');
end;
function GetExchangeRate(Name:String):Currency;
begin
   Result:=StrToCurrDef(GetGPCSRegString('ExchangeRates',Name,'1'),1);
end;

function CreateParallelDevice  :IDevice;
begin
  Result:=CreateComObject(Class_ParallelDevice) as IDevice;
end;

function CreateRemoteParallelDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ParallelDevice) as IDevice;
end;

function ReportPreviewOnly:Boolean;
begin
   if GetGPCSRegString('Reports','PreviewOnly','0') = '1' then
      Result:=True
   else
      Result:=False;
end;              
function CreateErrorHandler:IErrorHandler;
begin
  Result:=CreateComObject(Class_GPCSErrorHandler) as IErrorHandler;
end;
function CreateRemoteErrorHandler(const MachineName:String):IErrorHandler;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSErrorHandler) as IErrorHandler;
end;

function CreateCompLoad:ICompLoad;
begin
  Result:=CreateComObject(Class_GPCSCompLoad) as ICompLoad;
end;
function CreateRemoteCompLoad(const MachineName:String):ICompLoad;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSCompLoad) as ICompLoad;
end;

function CreateCompMan:ICompMan;
begin
  Result:=CreateComObject(Class_GPCSCompMan) as ICompMan;
end;
function CreateRemoteCompMan(const MachineName:String):ICompMan;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSCompMan) as ICompMan;
end;

function CreateTransactionLog:ITransactionLog;
begin
  Result:=CreateComObject(Class_GPCSTransactionLog) as ITransactionLog;
end;
function CreateRemoteTransactionLog(const MachineName:String):ITransactionLog;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSTransactionLog) as ITransactionLog;
end;

function CreatePeriod:IPeriod;
begin
  Result:=CreateComObject(Class_GPCSPeriod) as IPeriod;
end;
function CreateRemotePeriod(const MachineName:String):IPeriod;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSPeriod) as IPeriod;
end;


function CreateTableMonitor:ITableMonitor;
begin
  Result:=CreateComObject(Class_GPCSTableMonitor) as ITableMonitor;
end;
function CreateRemoteTableMonitor(const MachineName:String):ITableMonitor;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSTableMonitor) as ITableMonitor;
end;

function CreateOCRDevice     :IDevice;
begin
  Result:=CreateComObject(Class_OCRDevice) as IDevice;
end;
function CreateSerialDevice  :IDevice;
begin
  Result:=CreateComObject(Class_SerialDevice) as IDevice;
end;
function CreateReceiptDevice :IDevice;
begin
  Result:=CreateComObject(Class_ReceiptDevice) as IDevice;
end;
function CreateScaleDevice   :IDevice;
begin
  Result:=CreateComObject(Class_ScaleDevice) as IDevice;
end;
function CreateLabelDevice   :IDevice;
begin
  Result:=CreateComObject(Class_LabelDevice) as IDevice;
end;
function CreatePassBookDevice:IDevice;
begin
  Result:=CreateComObject(Class_PassBookDevice) as IDevice;
end;
function CreateCustDispDevice:IDevice;
begin
  Result:=CreateComObject(Class_CustDispDevice) as IDevice;
end;
function CreateRemoteOCRDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_OCRDevice) as IDevice;
end;
function CreateRemoteSerialDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_SerialDevice) as IDevice;
end;
function CreateRemoteReceiptDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ReceiptDevice) as IDevice;
end;
function CreateRemoteScaleDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ScaleDevice) as IDevice;
end;
function CreateRemoteLabelDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_LabelDevice) as IDevice;
end;
function CreateRemotePassBookDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_PassBookDevice) as IDevice;
end;
function CreateRemoteCustDispDevice(const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_CustDispDevice) as IDevice;
end;

function CreatePictureServer:IPictureServer;
begin
  Result:=CreateComObject(Class_GPCSPictureServer) as IPictureServer;
end;
function CreateRemotePictureServer(const MachineName:String):IPictureServer;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSPictureServer) as IPictureServer;
end;

function CreateCounterDevice :IDevice;
begin
  Result:=CreateComObject(Class_CounterDevice) as IDevice;
end;
function CreateRemoteCounterDevice (const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_CounterDevice) as IDevice;
end;

function CreateOfficeInfoDevice :IDevice;
begin
  Result:=CreateComObject(Class_OfficeInfoDevice) as IDevice;
end;
function CreateRemoteOfficeInfoDevice (const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_OfficeInfoDevice) as IDevice;
end;
function CreateTrackedMailLog :IMailItemLog;
begin
  Result:=CreateComObject(Class_GPCSTrackedMail) as IMailItemLog;
end;
function CreateRemoteTrackedMailLog (const MachineName:String):IMailItemLog;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSTrackedMail) as IMailItemLog;
end;

function CreateExtBarCodeDevice :IDevice;
begin
  Result:=CreateComObject(Class_ExtBarCodeDevice) as IDevice;
end;
function CreateRemoteExtBarCodeDevice (const MachineName:String):IDevice;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ExtBarCodeDevice) as IDevice;
end;
function CreateExchangeRateServer:IExchangeRateServer;
begin
  Result:=CreateComObject(Class_ExchangeRateServer) as IExchangeRateServer;
end;
function CreateRemoteExchangeRateServer(const MachineName:String):IExchangeRateServer;
begin
  Result:=CreateRemoteComObject(MachineName,Class_ExchangeRateServer) as IExchangeRateServer;
end;
function CreateHotKeys:IHotKeys;
begin
  Result:=CreateComObject(Class_HotKeys) as IHotKeys;
end;
function CreateRemoteHotKeys(const MachineName:String):IHotKeys;
begin
  Result:=CreateRemoteComObject(MachineName,Class_HotKeys) as IHotKeys;
end;
function CreateAccounts:IAccounts;
begin
  Result:=CreateComObject(Class_Accounts) as IAccounts;
end;
function CreateRemoteAccounts(const MachineName:String):IAccounts;
begin
  Result:=CreateRemoteComObject(MachineName,Class_Accounts) as IAccounts;
end;
function CreateSiteManager :ISiteManager;
begin
  Result:=CreateComObject(Class_SiteManager) as ISiteManager;
end;
function CreateRemoteSiteManager (const MachineName:String):ISiteManager;
begin
  Result:=CreateRemoteComObject(MachineName,Class_SiteManager) as ISiteManager;
end;
function CreateActualRemoteSiteManager(const MachineName:String):ISiteManager;
begin
  Result:=CreateActualRemoteComObject(MachineName,Class_SiteManager) as ISiteManager;
end;

function CreateHookUp:IHookUp;
begin
  Result:=CreateComObject(Class_HookUp) as IHookUp;
end;
function CreateRemoteHookUp(const MachineName:String):IHookUp;
begin
  Result:=CreateRemoteComObject(MachineName,Class_HookUp) as IHookUp;
end;
function CreateStock:IStock;
begin
  Result:=CreateComObject(Class_Stock) as IStock;
end;
function CreateRemoteStock(const MachineName:String):IStock;
begin
  Result:=CreateRemoteComObject(MachineName,Class_Stock) as IStock;
end;
function CreateTranslator:ITranslate;
begin
  Result:=CreateComObject(Class_GPCSTranslate) as ITranslate;
end;
function CreateRemoteTranslator(const MachineName:String):ITranslate;
begin
  Result:=CreateRemoteComObject(MachineName,Class_GPCSTranslate) as ITranslate;
end;
function CreateMessenger:IMessenger;
begin
  Result:=CreateComObject(Class_Messenger) as IMessenger;
end;
function CreateRemoteMessenger(const MachineName:String):IMessenger;
begin
  Result:=CreateActualRemoteComObject(MachineName,Class_Messenger) as IMessenger;
end;

function GetUserLoginName:String;
var
   Length:DWord;
begin
   Length:=MAX_USERNAME_LEN+1;
   SetLength(Result,Length);
   GetUserName(PChar(Result),Length);
   // Length returned includes the nul terminator !
   SetLength(Result,Length-1);
end;
function GetLocalMachineName:String;
var
   Length:DWord;
begin
   Length:=MAX_COMPUTERNAME_LENGTH+1;
   SetLength(Result,Length);
   GetComputerName(PChar(Result),Length);
   // Length returned does not include the nul terminator !
   SetLength(Result,Length); 
   Result:='\\'+Result;
end;
function GetGPCSRegString(Key,Name,DefaultResult:String):String;
begin
   Result:=GetPSLRegString('GPCS\'+Key,Name,DefaultResult);
end;
function GetPSLRegString(Key,Name,DefaultResult:String):String;
begin
   Result:=DefaultResult;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\'+Key,False) then
         begin
            Result:=ReadString(Name);
            CloseKey;
         end;
         if Result = '' then
         begin
            Result:=DefaultResult;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;
function GetGPCSRegNames(Key,DefaultResult:String):String;
begin
   Result:=GetPSLRegNames('GPCS\'+Key,DefaultResult);
end;
function GetGPCSKeyNames(Key:String):String;
begin
   Result:=GetPSLKeyNames('GPCS\'+Key);
end;
function GetPSLKeyNames(Key:String):String;
var                              
   SL:TPackStringList;
begin
   Result:='';
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\'+Key,False) then
         begin
            SL:=TPackStringList.Create;
            GetKeyNames(SL);
            Result:=SL.CommaText;
            CloseKey;
            SL.Free;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;
function GetPSLRegNames(Key,DefaultResult:String):String;
var                              
   SL:TPackStringList;
begin
   Result:=DefaultResult;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\'+Key,False) then
         begin
            SL:=TPackStringList.Create;
            GetValueNames(SL);
            Result:=SL.CommaText;
            CloseKey;
            SL.Free;
         end;
         if Result = '' then
         begin
            Result:=DefaultResult;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;
function GetGPCSRegValues(Key,DefaultResult:String):String;
begin
   Result:=GetPSLRegValues('GPCS\'+Key,DefaultResult);
end;
procedure SetPSLNamesValues(Key,Value:String);
var
   SL:TPackStringList;
   LSL:TPackStringList;
   I:Integer;
begin
   SL:=TPackStringList.Create;
   LSL:=TPackStringList.Create;
   SL.PackText:=Value;   
   for I:=0 to SL.Count-1 do
   begin
      LSL.PackText:=SL[I];
      if LSL.Count > 2 then
      begin
         if LSL[0] = 'V' then
            SetPSLRegString(Key,LSL[1],LSL[2])
         else if LSL[0] = 'K' then
            SetPSLNamesValues(LSL[1],LSL[2]);
      end;
   end;
   LSL.Free;
   SL.Free;
end;
function GetPSLNamesValues(Key:String):String;
var                              
   RSL:TPackStringList;
   SL:TPackStringList;
   LSL:TPackStringList;
   I:Integer;
begin
   RSL:=TPackStringList.Create;
   SL:=TPackStringList.Create;
   SL.CommaText:=GetPSLRegNames(Key,'');   
   LSL:=TPackStringList.Create;
   for I:=0 to SL.Count-1 do
   begin
      LSL.Clear;
      LSL.Add('V');
      LSL.Add(SL[I]);  
      LSL.Add(GetPSLRegString(Key,SL[I],''));
      RSL.Add(LSL.PackText);
   end;
   SL.CommaText:=GetPSLKeyNames(Key);   
   LSL:=TPackStringList.Create;
   for I:=0 to SL.Count-1 do
   begin
      LSL.Clear;
      LSL.Add('K');
      LSL.Add(Key+'\'+SL[I]);  
      LSL.Add(GetPSLNamesValues(Key+'\'+SL[I]));
      RSL.Add(LSL.PackText);
   end;
   LSL.Free;
   SL.Free;
   Result:=RSL.PackText;
   RSL.Free; 
end;
function GetPSLRegValues(Key,DefaultResult:String):String;
var                               
   SL:TPackStringList;
   SL1:TPackStringList;
   I:Integer;
begin
   Result:=DefaultResult;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\'+Key,False) then
         begin
            SL:=TPackStringList.Create;
            SL1:=TPackStringList.Create;
            GetValueNames(SL);
            for I:=0 to SL.Count-1 do
            begin
               SL1.Add(ReadString(SL[I]))
            end;
            Result:=SL1.CommaText;
            CloseKey;
            SL.Free;
            SL1.Free;
         end;
         if Result = '' then
         begin
            Result:=DefaultResult;
         end;
         Free;
      end;
   except
     // Log Error 
   end;
end;
procedure EraseKey(Root:HKEY;KeyName:String);
var
   I:Integer;
   SL:TPackStringList;
begin
   SL:=TPackStringList.Create;
   with TRegistry.Create do
   begin
      RootKey:=Root;
      if OpenKey(KeyName,False) then
      begin
         if HasSubKeys then
         begin
            GetKeyNames(SL);
            CloseKey;
            for I:=0 to SL.Count-1 do
               EraseKey(Root,KeyName+'\'+SL[I]);
         end
         else
         begin
            CloseKey;
         end;
      end;
      DeleteKey(KeyName);
      Free;
   end;
   SL.Free;
end;
procedure EraseValue(Root:HKEY;KeyName,Value:String);
begin
   with TRegistry.Create do
   begin
      RootKey:=Root;
      if OpenKey(KeyName,False) then
         DeleteValue(Value);
      Free;
   end;
end;

procedure SetGPCSRegNames(Key,Values:String);
begin
   SetPSLRegNames('GPCS\'+Key,Values);
end;
procedure SetPSLRegNames(Key,Values:String);
var
   SL:TPackStringList;
   I:Integer;
begin
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         SL:=TPackStringList.Create;
         if OpenKey('Software\PSL\'+Key,False) then
         begin
            GetValueNames(SL);
            for I:=0 to SL.Count-1 do
               DeleteValue(SL[I]);
            CloseKey;
         end;
         if OpenKey('Software\PSL\'+Key,True) then
         begin
            SL.CommaText:=Values;
            for I:=0 to SL.Count-1 do
               WriteString(SL[I],'');
            CloseKey;
         end;       
         SL.Free;
         Free;
      end;
   except
     // Log Error 
   end;
end;
procedure SetGPCSRegString(Key,Name,Value:String);
begin
   SetPSLRegString('GPCS\'+Key,Name,Value);
end;
procedure SetPSLRegString(Key,Name,Value:String);
var      
    SL:TStringList;
begin
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\'+Key,True) then
         begin
            WriteString(Name,Value);
            CloseKey;
         end;
         Free;
      end;
   except
      On E : Exception do
        RaiseGUIDException('{450C5573-CD99-4158-AF23-FC63DD5FF3DF}'+'-'+Key+'-'+Name+'-'+Value, E);
   end;
   if GetPSLRegString(Key,Name,'') <> Value then
   begin
      try
         SL:=TStringList.Create;
         SL.Add('REGEDIT4');
         SL.Add('');
         SL.Add('[HKEY_LOCAL_MACHINE\Software\PSL\'+Key+']');
         SL.Add('"'+Name+'"="'+Replace(Value,'\','\\')+'"');
         SL.SaveToFile('C:\Temp.reg');
         SL.Free;
         WinExec(PChar('RegEdit /s C:\Temp.reg'),SW_HIDE);
      except
         on e:Exception do GPCSErrorLine.RaiseError(0,0,0,'Write to [HKEY_LOCAL_MACHINE\Software\PSL\'+Key+' Failed - '+E.Message);
      end;
   end;
end;

function CreateActualRemoteComObject(const MachineName:WideString;const ClassID:TGUID):IUnknown;
const
  CoCreateInstanceEx: TCoCreateInstanceExProc = nil;
var
  MQI: TMultiQI;
  Ole32: HModule;
  ServerInfo: TCoServerInfo;
  IID_IUnknown: TGuid;
begin
  if MachineName = GetLocalMachineName then
  begin
     Result:=CreateComObject(ClassID);
     Exit;
  end;
  if @CoCreateInstanceEx = nil then
  begin
    Ole32 := GetModuleHandle('ole32.dll');
    Win32Check(Ole32 > HINSTANCE_ERROR);
    @CoCreateInstanceEx := GetProcAddress(Ole32, 'CoCreateInstanceEx');
    if @CoCreateInstanceEx = nil then
       // Error Code;
  end;
  FillChar(ServerInfo, sizeof(ServerInfo), 0);
  ServerInfo.pwszName := PWideChar(MachineName);
  IID_IUnknown := IUnknown;
  MQI.IID := @IID_IUnknown;
  MQI.itf := nil;
  MQI.hr := 0;
  OleCheck(CoCreateInstanceEx(ClassID, nil,
    CLSCTX_REMOTE_SERVER,
    @ServerInfo, 1, @MQI));
  OleCheck(MQI.HR);
  Result := MQI.itf;
end;
function ApplicationRootPath:String;
begin
   Result:=ExtractFilePath(ParamStr(0));
end;
procedure DeleteCountryExchange(Value:String);
begin
   EraseValue( HKEY_LOCAL_MACHINE, 'Software\PSL\GPCS\ExchangeRates',Value );
end ;

function GrammesSymbol:String;
begin
   Result:=GetGPCSRegString('','Grammes Symbol','g');
end;

function ToSymbol:String;
begin
   Result:=GetGPCSRegString('','To Symbol','-----');
end;

function GenerateGUID:String;
var
  GUID:TGUID;
  GUIDstr:Array [0..50] of WideChar;
begin
   if CoCreateGuid(GUID) = S_OK then
      StringFromGUID2(GUID,GUIDstr,50);
   Result:=WideCharToString(GUIDstr);
end;

function NeedStartOfDay( UserGroup: String  ):Boolean;
var
   Registry:TRegistry ;
   SL : TStringList ;
   I,N : Integer ;
begin
   result := false ;
   I := Pos( '.', UserGroup );
   if I > 0 then
      UserGroup := UpperCase( Copy( UserGroup, I+1, Length(UserGroup)-I ) );

   Registry:=TRegistry.Create;
   SL:= TStringList.Create ;
   try
      with Registry do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('\SOFTWARE\PSL\GPCS\System Parameters\Auto StartOfDay',True) then
         begin
            GetValueNames( SL );
            for n := 0 to Sl.Count -1 do
            begin
               SL[n]:= UpperCase( SL[n] );
            end ;
            result := ( SL.IndexOf( UserGroup ) >= 0 );
         end;

      end;
    finally
       SL.Free;
       Registry.Free;      
    end;

end ;
function GetUserNumber(UserName:String):Integer;
var
   SL:TPackStringList;
   NetManager:INetUser     ;
const
   UseLocalMachine:Boolean = False;
   ServerName:String = '';
   UserList:TStringList = nil;
begin
   if GetGPCSRegString('','Primary Domain Controller','') = 'None' then
       UseLocalMachine:=True;
   if UserList = nil then UserList:=TStringList.Create;
   if UserName ='*DestroyList' then
   begin
      Result:=0;
      UserList.Free;
      UserList:=nil;
      Exit;
   end;
   if UserName = '' then UserName:=GetUserLoginName;
   if UserList.IndexOf(UserName) <> -1 then
   begin
      Result:=Integer(UserList.Objects[UserList.IndexOf(UserName)]);
      Exit;
   end;
   Result:=0;
   NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;

   SL:=TPackStringList.Create;
   try
      if not UseLocalMachine then
      begin
          try
             ServerName:=NetManager.GetPDC;
          except
          end;
      end;
      if ServerName = '' then
      begin
         UseLocalMachine:=True;
         ServerName:=GetLocalMachineName;
         Result:=StrToIntDef(NetManager.GetComment(ServerName,UserName),0);
         UserList.AddObject(UserName,TObject(Result));
      end
      else
      begin
         SL.CommaText:=NetManager.GetMemberGlobalGroups( ServerName,UserName);
         Result:=StrToIntDef(NetManager.GetComment(ServerName,UserName),0);
         UserList.AddObject(UserName,TObject(Result));
      end;
   except
   end;
   NetManager:=nil;
end;

procedure SetUsersBroadCast( UsersInfo:String ) ;
var
   SL:TPackStringList;
   SLRecord:TPackStringList;
   SLLocal:TPackStringList;
   NetManager:INetUser ;
   i :integer ;
   UserGroup:String;
   ComputerName :string;
begin

   SL:=TPackStringList.Create;
   SLRecord:=TPackStringList.Create;
   SLLocal:=TPackStringList.Create;
   ComputerName := GetLocalMachineName ;
   NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;
   try
      SL.CommaText := UsersInfo ;

      if NetManager.GetPDC <> ComputerName then
      begin
         for i := 0 to SL.Count -1 do
         begin
            SLRecord.CommaText := SL[i];
            //SLRecord[0] Name
            //SLRecord[1] GPCSGroup
            if not NetManager.UserExists(ComputerName, SLRecord[0] ) then
            // do something  Add Users
            else
            begin
               UserGroup:= GetGPCSUserGroup( ComputerName, SLRecord[0], NetManager );
               if UserGroup = '' then  // It has to be in a different computer
                 NetManager.AddMemberLocalGroups( ComputerName, SLRecord[0], SLRecord[1]);
            end;

         end ;

         SLLocal.CommaText := NetManager.GetUsers(ComputerName);
         for i := 0 to SLLocal.Count -1 do
         begin
            if SL.IndexOf( SLLocal[i] ) < 0 then
            begin
               //NetManager.AddOrUpdateUser(ComputerName, SLLocal[i], '', '^Delete', '', '');
               //showmessage( 'User to delete ' + SLLocal[i]);
            end;

         end ;

      end ;
   finally
      SL.Free;
      SLLocal.Free;
      SLRecord.Free;
      NetManager:=nil;
   end;
end ;

function GetGPCSUserGroup( ServerName, User :String; NetManager:INetUser ) :String;
var
   CreateNetManager:Boolean;
   J:integer;
   List:TStringList;
   PDC :String;
begin

   result := '';
   CreateNetManager:= False;
   if NetManager=nil then
   begin
      CreateNetManager:=True;
      NetManager:=CreateOleObject('UserManager.NetUser') as INetUser;
   end ;
   PDC:=NetManager.GetPDC ;

   List:=TStringList.create;
   if ServerName = PDC then
      List.CommaText := NetManager.GetMemberGlobalGroups(ServerName, User)
   else
      List.CommaText := NetManager.GetMemberLocalGroups(ServerName, User);


   J := 0 ;
   while (j <=List.Count-1 ) and (result='') do
   begin
     if Copy( List[j],1, 5 )='GPCS_' then
        result := List[j]
     else
        Inc(j);
   end ;


   List.Free;

   if CreateNetManager then
   begin
      NetManager:=nil;
   end ;

end ;
procedure SetShutdownPrivilege;
var
  ProcHandle:THandle;
  TokHandle:THandle;
  TmpLUID:TLargeInteger;
  TokPriv:TTokenPrivileges;
  TokNew:TTokenPrivileges;
  BufferNeeded:DWord;
begin
  ProcHandle:=GetCurrentProcess;
  OpenProcessToken(ProcHandle,TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,TokHandle);
  LookupPrivilegeValue('','SeShutdownPrivilege',TmpLUID);
  TokPriv.PrivilegeCount:=1;
  TokPriv.Privileges[0].LUID:=TmpLUID;
  TokPriv.Privileges[0].Attributes:=SE_PRIVILEGE_ENABLED;
  AdjustTokenPrivileges(TokHandle,False,TokPriv,Sizeof(TokNew),TokNew,BufferNeeded);
end;
procedure Shutdown;
begin
  Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
  SetShutdownPrivilege;
  ExitWindowsEx(EWX_FORCE or EWX_SHUTDOWN,0);
end;
procedure ReStart;
begin
  Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
  SetShutdownPrivilege;
  ExitWindowsEx(EWX_FORCE or EWX_REBOOT,0);
end;
procedure PowerOff;
begin
  Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
  SetShutdownPrivilege;
  ExitWindowsEx(EWX_FORCE or EWX_POWEROFF,0);
end;
procedure LogOff;
begin
   Sleep(1+StrToIntDef(GetGPCSRegString('','Pre-Shutdown Delay In Seconds','0'),0)*1000);
   SetShutdownPrivilege;
   ExitWindowsEx(EWX_FORCE or EWX_LOGOFF,0);
end;

end.
