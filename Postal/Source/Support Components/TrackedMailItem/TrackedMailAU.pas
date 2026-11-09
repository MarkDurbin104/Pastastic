{  Module          
   Unit            
   Copyright(c)    
   Author          
   Description     
                   
                   
                   
                   
   Modifications   
                   
________________________________________________________________________________}

unit TrackedMailAU;

interface

uses
  Windows,Classes,SysUtils,ComObj,GPCSBase_TLB,TrackedMailFU,GPCSGUID,GPCSBaseAU,GPCSErrorLine,GPCSErrorCode,
  DatabaseServer_TLB,Dialogs,Registry;
  
type
  TTrackedItem = class(TObject)
  private
     FUser:String;
     FOffice:Integer;
     FWorkstation:Integer;
     FTrackingNo:String;
     FWeight:Integer;
     FDestination:String;
     FValue:Currency;
     FInfo:String;
     FDate:TDateTime;
  public
    procedure SetValues(User:String;Office,Workstation:Integer;TrackingNo:String;Weight:Integer;Destination:String;Value:Currency;Info:String;Date:TDateTime);
    function AsString:String;
    function Log(DatabaseServerAuto:IDatabaseServerAuto):Integer;
    property User       :String read FUser        write FUser       ;
    property Office     :Integer read FOffice      write FOffice     ;
    property Workstation:Integer read FWorkstation write FWorkstation;
  end;
  TTrackedMail = class(TMailItemLog)
  protected
    procedure AddItem(const TrackingNumber: WideString; Weight: Integer;
      const Destination: WideString; Value: Currency; const Info: WideString); override;
    function List: WideString; override;
    procedure WriteToStore; override;
    procedure ClearLog; override;
  end;

implementation

uses ComServ2;
{TrackedItem}
procedure TTrackedItem.SetValues(User:String;Office,Workstation:Integer;TrackingNo:String;Weight:Integer;Destination:String;Value:Currency;Info:String;Date:TDateTime);
begin
   FUser       :=User       ;
   FOffice     :=Office     ;
   FWorkstation:=Workstation;
   FTrackingNo :=TrackingNo ;
   FWeight     :=Weight     ;
   FDestination:=Destination;
   FValue      :=Value      ;
   FInfo       :=Info       ;
   FDate       :=Date       ;
end;
function TTrackedItem.AsString:String;
begin
   Result:='"'+FUser+'",'+
           '"'+IntToStr     (FOffice     )+'",'+
           '"'+IntToStr     (FWorkstation)+'",'+
           '"'+              FTrackingNo  +'",'+
           '"'+IntToStr     (FWeight     )+'",'+
           '"'+              FDestination +'",'+
           '"'+CurrToStr    (FValue      )+'",'+
           '"'+              FInfo        +'",'+
           '"'+DateTimeToStr(FDate       )+'"';
end;       
function TTrackedItem.Log(DatabaseServerAuto:IDatabaseServerAuto):Integer;
begin
   Result:=-1;
   if DatabaseServerAuto <> nil then
      Result:=DatabaseServerAuto.CustRecd(FTrackingNo,FDate,FWeight,FValue,FDestination,FInfo);
end;

{TTrackedMail}
procedure TTrackedMail.AddItem(const TrackingNumber:WideString;Weight:Integer;const Destination:WideString;Value:Currency;const Info:WideString);
var
   TI:TTrackedItem;
begin
   TI:=TTrackedItem.Create;
   TI.SetValues(Get_User,Get_Office,Get_Workstation,TrackingNumber,Weight,Destination,Value,Info,Now);
   MainForm.TMList.Items.AddObject(TrackingNumber,TI);
end;
function TTrackedMail.List:WideString;
var
   SL:TStringList;
   I:Integer;
begin
   try
      SL:=TStringList.Create;
      for I:=0 to MainForm.TMList.Items.Count-1 do 
      begin
         SL.Add(TTrackedItem(MainForm.TMList.Items.Objects[I]).AsString);
      end;
      Result:=SL.CommaText;
   except
      on E:Exception do RaiseException($1000,E);
   end;
end;     
procedure TTrackedMail.ClearLog;
var
   I:Integer;
begin
   try
      for I:=0 to MainForm.TMList.Items.Count-1 do 
         TTrackedItem(MainForm.TMList.Items.Objects[I]).Free;
      MainForm.TMList.Items.Clear;
   except
      on E:Exception do RaiseException($1001,E);
   end;
end;
procedure TTrackedMail.WriteToStore;
var
   I:Integer;
   DatabaseServerAuto:IDatabaseServerAuto;
   TI:TTrackedItem;
   ServerName:String;
begin
   if (MainForm = nil) or (MainForm.TMList.Items.Count = 0) then Exit;
   try
      with TRegistry.Create do
      begin
         RootKey:=HKEY_LOCAL_MACHINE;
         if OpenKey('Software\PSL\GPCS',False) then
         begin
            ServerName:=ReadString('ServerName');
            CloseKey;
         end;
         Free;
      end;
      
      TI:=TTrackedItem(MainForm.TMList.Items.Objects[0]);
   
      DatabaseServerAuto:=CoDatabaseServerAuto.CreateRemote(ServerName);
      DatabaseServerAuto.Person     :=TI.User;
      DatabaseServerAuto.Site       :=IntToStr(TI.Office     );
      DatabaseServerAuto.Workstation:=IntToStr(TI.Workstation);
      for I:=0 to MainForm.TMList.Items.Count-1 do 
      begin
         case TTrackedItem(MainForm.TMList.Items.Objects[I]).Log(DatabaseServerAuto) of
            osDatabaseError    : RaiseError(osDatabaseError   ,1,1,'osDatabaseError   '); 
            osNotFound         : RaiseError(osNotFound        ,1,1,'osNotFound        '); 
            osInvalidOperation : RaiseError(osInvalidOperation,1,1,'osInvalidOperation'); 
            osInvalidSite      : RaiseError(osInvalidSite     ,1,1,'osInvalidSite     '); 
            osInvalidId        : RaiseError(osInvalidId       ,1,1,'osInvalidId       '); 
            osUnexpected       : RaiseError(osUnexpected      ,1,1,'osUnexpected      '); 
         end;         
      end;
      ClearLog;
      DatabaseServerAuto:=nil;
   except
      on E:Exception do RaiseError(1,1,1,'Exception in WriteToStore '+E.Message);
   end;
end;       
initialization
  TGPCSCompFactory.Create(ComServer,TTrackedMail,Class_GPCSTrackedMail,
                          'Support.TrackedMail','GPCS Tracked Mail Log',
                          ciMultiInstance);
end.
