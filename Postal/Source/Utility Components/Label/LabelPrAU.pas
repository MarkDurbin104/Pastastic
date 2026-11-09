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
    FSerialDevice:IDevice;
    FCLSID:String;
  protected
    procedure PrintLabel(Code,Weight,Value,Zip,Clerk,Position,Office:String);
    procedure DownloadFormat;
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
   ComServ2;
   
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
procedure TLabelPrDevice.DownloadFormat;
begin
   FSerialDevice.WriteDevice(dcRawData,'{F,1,A,R,M,730,800,"TRACK"|',0);

   FSerialDevice.WriteDevice(dcRawData,'B, 1,18,V,200,250,8,8,90,0,B,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 2,18,V,290,250,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 3,18,V,270,730,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 5,18,V,210,730,3,1,1,1,B,B,0,0,0|',0);

   FSerialDevice.WriteDevice(dcRawData,'C,270,580,3,1,1,1,B,B,0,0,"'+WeightStr+'",0|',0);
   FSerialDevice.WriteDevice(dcRawData,'C,210,580,3,1,1,1,B,B,0,0,"'+ZipStr+'",0|',0);

   FSerialDevice.WriteDevice(dcRawData,'B, 1,18,V,350,250,8,8,90,0,B,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 2,18,V,440,250,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 3,18,V,420,730,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 5,18,V,360,730,3,1,1,1,B,B,0,0,0|',0);

   FSerialDevice.WriteDevice(dcRawData,'C,420,580,3,1,1,1,B,B,0,0,"'+WeightStr+'",0|',0);
   FSerialDevice.WriteDevice(dcRawData,'C,360,580,3,1,1,1,B,B,0,0,"'+ZipStr+'",0|',0);

   FSerialDevice.WriteDevice(dcRawData,'B, 1,18,V,500,250,8,8,90,0,B,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 2,18,V,590,250,3,1,1,1,B,B,0,0,0|',0); 
   FSerialDevice.WriteDevice(dcRawData,'T, 3,18,V,570,730,3,1,1,1,B,B,0,0,0|',0); 
   FSerialDevice.WriteDevice(dcRawData,'T, 4,18,V,540,730,3,1,1,1,B,B,0,0,0|',0); 
   FSerialDevice.WriteDevice(dcRawData,'T, 5,18,V,510,730,3,1,1,1,B,B,0,0,0|',0); 

   FSerialDevice.WriteDevice(dcRawData,'C,570,580,3,1,1,1,B,B,0,0,"'+WeightStr+'",0|',0);
   FSerialDevice.WriteDevice(dcRawData,'C,540,580,3,1,1,1,B,B,0,0,"'+FeeStr+'",0|',0);
   FSerialDevice.WriteDevice(dcRawData,'C,510,580,3,1,1,1,B,B,0,0,"'+ZipStr+'",0|',0);

   FSerialDevice.WriteDevice(dcRawData,'C,100,200,3,3,1,1,B,B,0,0,"'+NameStr+'",0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 5,18,V,630,630,3,3,1,1,B,B,0,0,0|',0); 
   FSerialDevice.WriteDevice(dcRawData,'T, 6,19,V,110,600,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 7,19,V, 80,600,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'T, 8,40,V, 40,400,3,1,1,1,B,B,0,0,0|',0);
   FSerialDevice.WriteDevice(dcRawData,'}'+#13#10,0);
end;

procedure TLabelPrDevice.PrintLabel(Code,Weight,Value,Zip,Clerk,Position,Office:String);
var
  guid: TGUID;
  GUIDstr:Array [0..100] of WideChar;
begin
   if CoCreateGuid(guid) = S_OK then
     StringFromGUID2(guid,GUIDstr,50);
   FCLSID:=WideCharToString(GUIDstr);
   FSerialDevice.WriteDevice(dcRawData,'{',0);
   FSerialDevice.WriteDevice(dcRawData,'B,1,N,1|',0);

   FSerialDevice.WriteDevice(dcRawData,' 1,"'+Code+'"|',0);
   FSerialDevice.WriteDevice(dcRawData,' 2,"'+Code+'"|',0);
   FSerialDevice.WriteDevice(dcRawData,' 3,"'+Weight+'g"|',0);
   FSerialDevice.WriteDevice(dcRawData,' 4,"'+Value+' "|',0);
   FSerialDevice.WriteDevice(dcRawData,' 5," '+Zip+' "|',0);
   FSerialDevice.WriteDevice(dcRawData,' 6,"'+DateTimeToStr(Now)+'"|',0);
   FSerialDevice.WriteDevice(dcRawData,' 7,"'+Clerk+' '+Position+' '+Office+'"|',0);
   FSerialDevice.WriteDevice(dcRawData,' 8,"'+FCLSID+'"|',0);

   FSerialDevice.WriteDevice(dcRawData,'}'+#13#10,0);
end;
function Pad(Str:String;Len:Integer):String;
begin
   Result:=Str;
   while Length(Result) < Len do Result:=' '+Result;
end;
function TLabelPrDevice.WriteDevice(CommandType: DeviceCommand; const Data: WideString;Len:Integer):WordBool;
var
   SL:TStringList;
   S:String;
begin
   Result:=False;
   case CommandType of
      dcInitialise : begin
                        NameStr  :='MAGYAR POSTA';
                        WeightStr:='Weight';
                        FeeStr   :='Fee   ';
                        ZipStr   :='Zip   ';
                        FSerialDevice:=CreateSerialDevice;
                        if FSerialDevice <> nil then
                        begin
                           FSerialDevice.SetEventSink(Self);
                           S:=GetDeviceEntry('Label');
                           FSerialDevice.WriteDevice(dcInitialise,S,0);
                           if Len = 0 then
                              DownloadFormat;
                           Result:=True;       
                        end;                                                              
                      end;
      dcRawData    : begin
                        FSerialDevice.WriteDevice(dcRawData,Data,0);
                        Result:=True;
                     end;
      dcShutdown   : begin
                        FSerialDevice:=nil;
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
                        DownloadFormat;
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