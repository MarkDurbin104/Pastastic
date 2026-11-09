unit ImpersonateU;

interface

uses
  windows,Stringutil,ComObj,ActiveX,UserManager_TLB,
   classes, sysutils,
   GPCSErrorLine,GPCSErrorCode,GPCSGUID,PackStrListU ;
   
function CreateUserAndLogin(UserName,Password:String):Integer;
procedure LogoffAndDeleteUser(UserName:String);
                           
implementation

uses
   ComServ,
   lmcons,lmglobal, lmaccess;//, unitNTException ;//, NetUser;

procedure  AddMemberLocalGroups( const wServer, wUser, wGroups : WideString ) ;
var
  sid : PSid;
  peUse : SID_NAME_USE;
  sidLen, domainNameLen : DWORD;
  domainName : array [0..DNLEN] of char;
  MemberServer:string;
  info : LOCALGROUP_MEMBERS_INFO_0 ;
  i : integer ;
  list:TStringList;
  User,Groups:String;
  wGroup:WideString ;
begin

   User:=wUser;
   Groups:=wGroups;

   list := Tstringlist.create ;
   list.CommaText := Groups;
   MemberServer:=wServer ;
   for i := 0 to list.count-1 do
   begin

      wGroup:=list[i];
      sidLen := 65536;
      domainNameLen := DNLEN + 1;

      GetMem (sid, sidLen);
      try
         try
           if (LookupAccountName (PChar (MemberServer), PChar (User), sid, sidLen, domainName, domainNameLen, peUse)) then
           begin
             info.lgrmi0_sid := sid ;
                NetLocalGroupAddMembers (PWideChar (wServer), PWideChar (wGroup),0,@info, 1);
           end ;
         finally
           FreeMem (sid)
         end
      except
      on e : exception do
         RaiseGUIDError('{B3F57CEF-8DA9-4EEC-9C48-7C21EC104EDE}', E.MEssage);
      end ;
   end ;
   list.Free ;

end;

procedure DeleteUser(const wServer, wUser: WideString);
begin

  try
    NetUserDel (PWideChar (wServer), PWideChar (wUser) );
  except
    on e : exception do
    RaiseGUIDError('{6F6C4B9C-F469-44E9-A0B9-7D07D8EF92D2}', E.MEssage);
  end;

end ;
function AddUser(const wServer,wUser,wDescription,wPassword:WideString):WordBool;
var
  details : USER_INFO_1;
  parmErr : Integer;
  err : Integer;
begin
   result := False ;
   if wUser <> '' then
      try
         FillChar (details, sizeof (details), 0);
         details.usri1_priv := USER_PRIV_USER;
         details.usri1_name := PWideChar (wUser);
         details.usri1_password := PWideChar (wPassword);
         details.usri1_comment := PWideChar (wDescription);
         details.usri1_flags := UF_SCRIPT + UF_DONT_EXPIRE_PASSWD;

         err := NetUserAdd (PWideChar (wServer), 1, @details, parmErr);

         result := (err = NERR_Success);
      except
         on E:Exception do
            RaiseGUIDError('{AB07493A-A1A4-439C-909E-8840B973CAB8}', E.MEssage);
      end;
end;
procedure LogoffAndDeleteUser(UserName:String);
begin
   RevertToSelf;
   DeleteUser('',UserName);
end;
function CreateUserAndLogin(UserName,Password:String):Integer;
var
   UserToken:THandle;
begin
   Result:=0;
   RevertToSelf;
   
   DeleteUser('',UserName);
   AddUser('',UserName,'Corvus Service Internal Account',Password);
   AddMemberLocalGroups('',UserName,'Administrators,Users');
   
   Sleep(1000);
   
   LogonUser(PChar(UserName),PChar(''),PChar(Password),
             LOGON32_LOGON_INTERACTIVE,LOGON32_PROVIDER_DEFAULT,UserToken);
             
   if not ImpersonateLoggedOnUser(UserToken) then
      Result:=GetLastError;
end;                     
end.
