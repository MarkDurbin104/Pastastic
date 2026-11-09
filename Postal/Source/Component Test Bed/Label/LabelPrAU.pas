unit LabelPrAU;

interface

uses
  Windows,Graphics,Classes,SysUtils,ComObj,GPCSBase_TLB,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  ExtCtrls,Registry,ActiveX,Dialogs;
  
const
   LabelPrWidth  = 44;
  CompStr='$%+ -./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
   
type
  TLabelPrDevice = class(TGPCSDevice,IDevice,IDeviceEventSink)
    NameStr  :String;
    WeightStr:String;
    FeeStr   :String;
    ZipStr   :String;
    FHeader      : String;
    FTitle       : String;
    FOfficeData1 : String;
    FOfficeData2 : String;
    FThankYou    : String;
    FTotal       : String;
    FLogoFile    : String;
    FUser        : Integer;
    FOffice      : Integer;
    FValue       : Integer;
    FFee         : Integer;
    FZip         : Integer;
    FWorkstation : Integer;
    FIdent        : String;
    FWUser        : String;
    FWOffice      : String;
    FWValue       : String;
    FWFee         : String;
    FWZip         : String;
    FWWorkstation : String;
    FDeviceEventSink:IDeviceEventSink;
    FCLSID:String;
  protected
    procedure PrintLabel(Code,Weight,Value,Zip,Clerk,Position,Office:String);
    function  GetDeviceEntry(Name:String):String;
  public  
    procedure SetEventSink(const EventSink: IDeviceEventSink);                          override;
    function  WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool; override;
    function  ReadDevice(var Data: WideString;var Len: Integer):WordBool;                  override;
    function  GetStatus: WideString;                                                    override;
    function  TakeControl: WordBool;                                                    override;
    procedure ReleaseControl;                                                           override;
    procedure Trigger(const Data: WideString);                                          safecall;
    procedure ControlReleased;                                                          safecall;
  end;                  
  
implementation
uses
   ComServ2,LabelPrFU;
   
procedure TLabelPrDevice.SetEventSink(const EventSink: IDeviceEventSink);
begin
   FDeviceEventSink:=EventSink;
end;
function TLabelPrDevice.GetDeviceEntry(Name:String):String;
var
   Registry:TRegistry;
   SL:TStringList;
begin
   SL:=TStringList.Create;
   Registry:=TRegistry.Create;
   with Registry do
   begin
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\PSL\GPCS\DeviceSetup\'+Name,False) then
      begin
         SL.Add(ReadString('PortNumber'));
         SL.Add(ReadString('BaudRate'  ));
         SL.Add(ReadString('DataBits'  ));
         SL.Add(ReadString('Parity'    ));
         SL.Add(ReadString('StopBits'  ));
         SL.Add(ReadString('InTimeOut' ));
         SL.Add(ReadString('OutTimeOut'));
         Result:=SL.CommaText;
         FLogoFile:=ReadString('LogoFileName');
         if FLogoFile = '' then
           FLogoFile:='LogoBW.bmp';
      end                       
      else
      begin
         Result:='1,9600,8,N,1,500,500';
         FLogoFile:='LogoBW.bmp';
      end;
      CloseKey;
      Free;
   end;
   Sl.Free;
end;
procedure TLabelPrDevice.PrintLabel(Code,Weight,Value,Zip,Clerk,Position,Office:String);
var
   guid:TGUID;
   GUIDstr:Array[0..50] of WideChar;
begin
   if CoCreateGuid(guid) = S_OK then
     StringFromGUID2(guid,GUIDstr,50);
   FCLSID:=WideCharToString(GUIDstr);
   Form1.PrintLabel(Code,Weight,Zip,Value,DateTimeToStr(Now),Clerk,Position,Office);
   Form1.NEdit.Text:=NameStr  ;
   Form1.WEdit.Text:=WeightStr;
   Form1.FEdit.Text:=FeeStr   ;
   Form1.ZEdit.Text:=ZipStr   ;
end;
function Pad(Str:String;Len:Integer):String;
begin
   Result:=Str;
   while Length(Result) < Len do Result:=' '+Result;
end;
function TLabelPrDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
   SL:TStringList;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        NameStr  :='MAGYAR POSTA';
                        WeightStr:='Weight';
                        FeeStr   :='Fee   ';
                        ZipStr   :='Zip   ';
//                        Form1.Caption:=GetDeviceEntry('Label');
                        Result:=True;       
                      end;
      dcRawData    : begin
//                        FSerialDevice.WriteDevice(dcRawData,Data,0);
                        Result:=True;
                     end;
      dcShutdown   : begin
                        FDeviceEventSink:=nil;
                        Result:=True;
                     end;
      dcLine1Data  : begin 
                        SL:=TStringList.Create;
                        SL.CommaText:=Data;
                        PrintLabel(SL[0],Pad(SL[1],5),Pad(SL[2],5),Pad(SL[3],4),Pad(SL[4],3),Pad(SL[5],2),Pad(SL[6],5));
                        SL.Free;
                     end;
      dcLine2Data  : begin 
                        SL:=TStringList.Create;
                        SL.CommaText:=Data;
                        NameStr  :=SL[0];
                        WeightStr:=SL[1];
                        FeeStr   :=SL[2];
                        ZipStr   :=SL[3];
                        SL.Free;
                     end;
      dcLine3Data  : Result:=True;
      dcLine4Data  : Result:=True;
      dcLine5Data  : Result:=True;
      dcList1Data  : Result:=True;
      dcList2Data  : Result:=True;
      dcList3Data  : Result:=True;
      dcList4Data  : Result:=True;
      dcList5Data  : Result:=True;                  
      else Result:=False;
   end;                            
end;              
function TLabelPrDevice.ReadDevice(var Data: WideString;var Len: Integer):WordBool;
begin
   Result:=True;
end;
function TLabelPrDevice.GetStatus: WideString;
begin
   Result:=FCLSID;
end;
function TLabelPrDevice.TakeControl: WordBool; 
begin
   Result:=False;
end;
procedure TLabelPrDevice.ReleaseControl;       
begin
end;
procedure TLabelPrDevice.Trigger(const Data: WideString);
begin
end;
procedure TLabelPrDevice.ControlReleased;
begin
end;
initialization
  TGPCSCompFactory.Create(ComServer,TLabelPrDevice,Class_LabelDevice,
                          'Device.Label','GPCS Label Printing Device',
                          ciMultiInstance);
end.