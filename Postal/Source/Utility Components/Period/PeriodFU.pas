unit PeriodFU;

interface

uses
  GPCSErrorLine,
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls,Grids, ComCtrls,GPCSGUID,PackStrListU, DBTables,GPCSBase_TLB;

type
  TUserPeriod = class(TObject)
     Name:String;
//     CurrentPeriod:Integer;
//     LastPeriod:Integer;
     State:esState;
//     HadEndOfDay:Boolean;
  end;
  TUserPeriodList = class(TObject)
  private
    FList:TStringList;
  public
    constructor Create;
    destructor Destroy; override;
//    function GetCurrentPeriod(User:String;var NewUser:Boolean):Integer;
//    function GetLastPeriod(User:String;var NewUser:Boolean):Integer;
    function GetState(User:String;var NewUser:Boolean):esState;
//    function GetHadEndOfDay(User:String;var NewUser:Boolean):Boolean;
//    procedure SetCurrentPeriod(User:String;Value:Integer);
//    procedure SetLastPeriod(User:String;Value:Integer);
    procedure SetState(User:String;Value:esState);
//    procedure SetHadEndOfDay(User:String;Value:Boolean);
    procedure Delete(User:String);
    property List:TStringList read FList write FList;
  end;
  TPeriodForm = class(TForm)
    PageControl: TPageControl;
    LogTabSheet: TTabSheet;
    LogMemo: TMemo;
    PSLDatabase: TDatabase;
    TabSheet1: TTabSheet;
    Button1: TButton;
    Edit1: TEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    procedure AppExcept(Sender: TObject; E: Exception) ;
  public
    UserList:TUserPeriodList;
  end;

var
  PeriodForm: TPeriodForm;

implementation

{$R *.DFM}

uses
  PeriodAU,
   ComServ2;
{TUserPeriodList}
constructor TUserPeriodList.Create;
begin
   inherited Create;
   FList:=TStringList.Create;
end;
destructor TUserPeriodList.Destroy;
var
   I:Integer;
begin
   for I:=0 to FList.Count-1 do
   begin
      if FList.Objects[I] <> nil then
      begin
         TUserPeriod(FList.Objects[I]).Free;
         FList.Objects[I]:=nil;
      end;
   end;
   FList.Free;
   inherited Destroy;
end;
procedure TUserPeriodList.Delete(User:String);
var
   Index:Integer;
begin
   Index:=FList.IndexOf(User);
   if Index <> -1 then
   begin
      TUserPeriod(FList.Objects[Index]).Free;
      FList.Objects[Index]:=nil;
      FList.Delete(Index);
   end;
end;

{function TUserPeriodList.GetCurrentPeriod(User:String;var NewUser:Boolean):Integer;
var
   Index:Integer;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      Result:=-1;
      NewUser:=True;
   end
   else
   begin
      Result:=TUserPeriod(FList.Objects[Index]).CurrentPeriod;
      NewUser:=False;
   end;
end;
function TUserPeriodList.GetLastPeriod(User:String;var NewUser:Boolean):Integer;
var
   Index:Integer;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      Result:=-1;
      NewUser:=True;
   end
   else
   begin
      Result:=TUserPeriod(FList.Objects[Index]).LastPeriod;
      NewUser:=False;
   end;
end; }
function TUserPeriodList.GetState(User:String;var NewUser:Boolean):esState;
var
   Index:Integer;
const
   DateOfLastGet:Integer = 0;
begin
   if DateOfLastGet <> Trunc(Now) then
   begin
      DateOfLastGet:=Trunc(Now);
      while FList.Count > 0 do
      begin
         if FList.Objects[0] <> nil then
         begin
            TUserPeriod(FList.Objects[0]).Free;
            FList.Objects[0]:=nil;
         end;
         FList.Delete(0);
      end;
   end;
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      Result:=-1;
      NewUser:=True;
   end
   else
   begin
      Result:=TUserPeriod(FList.Objects[Index]).State;
      NewUser:=False;
   end;
end;
{function TUserPeriodList.GetHadEndOfDay(User:String;var NewUser:Boolean):Boolean;
var
   Index:Integer;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      Result:=False;
      NewUser:=True;
   end
   else
   begin
      Result:=TUserPeriod(FList.Objects[Index]).HadEndOfDay;
      NewUser:=False;
   end;
end;
procedure TUserPeriodList.SetCurrentPeriod(User:String;Value:Integer);
var
   Index:Integer;
   UserPeriod:TUserPeriod;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      UserPeriod:=TUserPeriod.Create;
      UserPeriod.Name         :=User;
      UserPeriod.CurrentPeriod:=Value;
      UserPeriod.LastPeriod   :=-1;
      UserPeriod.State        :=-1;
      UserPeriod.HadEndOfDay  :=False;
      FList.AddObject(User,UserPeriod);
   end
   else
   begin
      TUserPeriod(FList.Objects[Index]).CurrentPeriod:=Value;
   end;
end;
procedure TUserPeriodList.SetLastPeriod(User:String;Value:Integer);
var
   Index:Integer;
   UserPeriod:TUserPeriod;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      UserPeriod:=TUserPeriod.Create;
      UserPeriod.Name         :=User;
      UserPeriod.CurrentPeriod:=-1;
      UserPeriod.LastPeriod   :=Value;
      UserPeriod.State        :=-1;
      UserPeriod.HadEndOfDay  :=False;
      FList.AddObject(User,UserPeriod);
   end
   else
   begin
      TUserPeriod(FList.Objects[Index]).LastPeriod:=Value;
   end;
end; }
procedure TUserPeriodList.SetState(User:String;Value:esState);
var
   Index:Integer;
   UserPeriod:TUserPeriod;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      UserPeriod:=TUserPeriod.Create;
      UserPeriod.Name         :=User;
//      UserPeriod.CurrentPeriod:=-1;
//      UserPeriod.LastPeriod   :=-1;
      UserPeriod.State        :=Value;
//      UserPeriod.HadEndOfDay  :=False;
      FList.AddObject(User,UserPeriod);
   end
   else
   begin
      TUserPeriod(FList.Objects[Index]).State:=Value;
   end;
end;
{procedure TUserPeriodList.SetHadEndOfDay(User:String;Value:Boolean);
var
   Index:Integer;
   UserPeriod:TUserPeriod;
begin
   Index:=FList.IndexOf(User);
   if Index = -1 then
   begin
      UserPeriod:=TUserPeriod.Create;
      UserPeriod.Name         :=User;
      UserPeriod.CurrentPeriod:=-1;
      UserPeriod.LastPeriod   :=-1;
      UserPeriod.State        :=-1;
      UserPeriod.HadEndOfDay  :=Value;
      FList.AddObject(User,UserPeriod);
   end
   else
   begin
      TUserPeriod(FList.Objects[Index]).HadEndOfDay:=Value;
   end;
end; }

procedure TPeriodForm.AppExcept(Sender: TObject; E: Exception) ;
begin
  LogEvent(E.Message);
  RaiseGUIDException('{3A0127E6-F086-4E8C-A598-1C1D0EBBA010}', E);  // Error in Period
end;


procedure TPeriodForm.FormCreate(Sender: TObject);
begin
  Application.OnException := AppExcept;
  UserList:=TUserPeriodList.Create;
  PSLDataBase.Params.Add('USER NAME=' + GetGPCSRegString('','UserName','psl'));
  PSLDataBase.Params.Add('PASSWORD='  + GetGPCSRegString('','Password','suvroc'));
end;

procedure TPeriodForm.FormDestroy(Sender: TObject);
begin
   UserList.Free;
end;

procedure TPeriodForm.Button1Click(Sender: TObject);
var
   TxnLog:ITransactionLog;
begin
   TxnLog:=CreateTransactionLog;
   if TxnLog <> nil then
   begin
      TxnLog.User:=Edit1.Text;
      TxnLog.Office:=StrToIntDef(GetGPCSRegString('OfficeInfo','Office ID','3211'),3211);
      TxnLog.WriteTransaction( '*CancelEOD',0,0,0,0,0,'','','','');
      TxnLog:=nil;
   end;
end;    

end.
