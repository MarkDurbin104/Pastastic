unit NetUserInfoU;

interface

uses
	Windows, SysUtils;

type
   NetAPIStatus = Integer;
   TUserInfo2 = record
      Name         : PWideChar;
      Password     : PWideChar;
      PasswordAge  : Integer;
      Priv         : Integer;
      HomeDir      : PWideChar;
      Comment      : PWideChar;
      Flags        : Integer;
      ScriptPath   : PWideChar;
      AuthFlags    : Integer;
      FullName     : PWideChar;
      UserComment   : PWideChar;
      Parms        : PWideChar;
      Workstations : PWideChar;
      LastLogon    : Integer;
      LastLogoff   : Integer;
      ActExpires   : Integer;
      MaxStorage   : Integer;
      UnitsPerWeek : Integer;
      LogonHours   : PChar;
      PadPwCount   : Integer;
      NumLogons    : Integer;
      LogonServer  : PWideChar;
      CountryCode  : Integer;
      CodePage     : Integer;
   end;
   PUserInfo2 = ^TUserInfo2;

   TNetUserInfo = class
   private
     NetApiBufferFree   :function(Buffer:Pointer) : NetAPIStatus; stdcall;
     NetGetDCName       :function(ServerName,DomainName:PWideChar;var Buffer:PWideChar): NetAPIStatus; stdcall;
     NetUserGetInfo     :function(ServerName,UserName:PWideChar;Level:Integer;var Buffer:PUserInfo2):NetAPIStatus; stdcall;
     Lib                :THandle;

       //property storage
     FLoginName    :WideString;
     FPassword     :WideString;
     FPasswordAge  :Integer;
     FPriv         :Integer;
     FHomeDir      :WideString;
     FComment      :WideString;
     FFlags        :Integer;
     FScriptPath   :WideString;
     FAuthFlags    :Integer;
     FFullName     :WideString;
     FUserComment  :WideString;
     FParms        :WideString;
     FWorkstations :WideString;
     FLastLogon    :Integer;
     FLastLogoff   :Integer;
     FActExpires   :Integer;
     FMaxStorage   :Integer;
     FUnitsPerWeek :Integer;
     FLogonHours   :WideString;
     FPadPWCount   :Integer;
     FNumLogons    :Integer;
     FLogonServer  :WideString;
     FCountryCode  :Integer;
     FCodePage     :Integer;
     procedure GetUserInfo(LoginName:WideString);
  public
     property LoginName     : WideString   read FLoginName;
     property Password      : WideString   read FPassword;
     property PasswordAge   : Integer      read FPasswordAge;
     property Priv          : Integer      read FPriv;
     property HomeDir       : WideString   read FHomeDir;
     property Comment       : WideString   read FComment;
     property Flags         : Integer      read FFlags;
     property ScriptPath    : WideString   read FScriptPath;
     property AuthFlags     : Integer      read FAuthFlags;
     property FullName      : WideString   read FFullName;
     property UserComment   : WideString   read FUserComment;
     property Parms         : WideString   read FParms;
     property Workstations  : WideString   read FWorkstations;
     property LastLogon     : Integer      read FLastLogon;
     property LastLogoff    : Integer      read FLastLogoff;
     property ActExpires    : Integer      read FActExpires;
     property MaxStorage    : Integer      read FMaxStorage;
     property UnitsPerWeek  : Integer      read FUnitsPerWeek;
     property LogonHours    : WideString   read FLogonHours;
     property PadPwCount    : Integer      read FPadPWCount;
     property NumLogons     : Integer      read FNumLogons;
     property LogonServer   : WideString   read FLogonServer;
     property CountryCode   : Integer      read FCountryCode;
     property CodePage      : Integer      read FCodePage;
     constructor Create(LoginName:String);
     destructor Destroy; override;
end;

implementation

const
	NErr_Success = 0;

constructor TNetUserInfo.Create(LoginName : String);
begin
   inherited Create;
   Lib:=LoadLibrary('netapi32');
   if Lib <> 0 then
   begin
      NetGetDCName     :=GetProcAddress(Lib,'NetGetDCName'     );
      if @NetGetDCName = nil then Exit;
      NetApiBufferFree :=GetProcAddress(Lib,'NetApiBufferFree' );
      if @NetApiBufferFree = nil then Exit;
      NetUserGetInfo   :=GetProcAddress(Lib,'NetUserGetInfo'   );
      if @NetUserGetInfo = nil then Exit;
      GetUserInfo(LoginName);
   end;
end;

destructor TNetUserInfo.Destroy;
begin
   if Lib <> 0 then FreeLibrary(Lib);
   Lib:=0;
   Inherited Destroy;
end;

procedure TNetUserInfo.GetUserInfo(LoginName:WideString);
var
   rv         :Integer;
   PServerName:PWideChar;
   ptrBuffer  :PUserInfo2;
   UserInfo   :TUserInfo2;
begin
   //get domain server name
   PServerName:=nil;
   rv:=NetGetDCName(Nil,'',PServerName);
   if rv <> NERR_Success then
      Exit;

   //get user info
   rv := NetUserGetInfo(PServerName,PWideChar(LoginName),2,ptrBuffer);
   if rv <> 0 then
      raise Exception.Create('Bad NetUserGetInfo');

   UserInfo:=ptrBuffer^;

   //update properties
   FLoginName   :=UserInfo.Name        ;
   FPassword    :=UserInfo.Password    ;
   FPasswordAge :=UserInfo.PasswordAge ;
   FPriv        :=UserInfo.Priv        ;
   FHomeDir     :=UserInfo.HomeDir     ;
   FComment     :=UserInfo.Comment     ;
   FFlags       :=UserInfo.Flags       ;
   FScriptPath  :=UserInfo.ScriptPath  ;
   FAuthFlags   :=UserInfo.AuthFlags   ;
   FFullName    :=UserInfo.FullName    ;
   FUserComment :=UserInfo.UserComment ;
   FParms       :=UserInfo.Parms       ;
   FWorkstations:=UserInfo.Workstations;
   FLastLogon   :=UserInfo.LastLogon   ;
   FLastLogoff  :=UserInfo.LastLogoff  ;
   FActExpires  :=UserInfo.ActExpires  ;
   FMaxStorage  :=UserInfo.MaxStorage  ;
   FUnitsPerWeek:=UserInfo.UnitsPerWeek;
   FLogonHours  :=UserInfo.LogonHours  ;
   FPadPWCount  :=UserInfo.PadPWCount  ;
   FNumLogons   :=UserInfo.NumLogons   ;
   FLogonServer :=UserInfo.LogonServer ;
   FCountryCode :=UserInfo.CountryCode ;
   FCodePage    :=UserInfo.CodePage    ;

   NetAPIBufferFree(PServerName);
   NetAPIBufferFree(ptrBuffer);
end;


end.
