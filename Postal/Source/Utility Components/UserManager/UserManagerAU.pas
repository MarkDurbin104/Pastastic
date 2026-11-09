unit UserManagerAU;

interface

uses
  windows,
  Stringutil,
   ComObj,ActiveX,UserManager_TLB,
   classes, sysutils,
   GPCSErrorLine,GPCSErrorCode,GPCSGUID,PackStrListU ;


type
  //---------------------------------------------------------------------------
  // TServerInfoFlags are used to record which bits of server
  // information have been cached.  Only the Domain Name and
  // Server Type are handled so far...

   LPCWSTR = PWideChar;
   LPBYTE = ^Byte;
   PPointer = ^Pointer;

   TNetUserComponents = (
      uiPasswordAge,
      uiPriv,
      uiHomeDir,
      uiComment,
      uiFlags,
      uiScriptPath,
      uiAuthFlags,
      uiFullName,
      uiUsrComment,
      uiParms,
      uiWorkstations,
      uiLastLogon,
      uiLastLogoff,
      uiAcctExpires,
      uiMaxStorage,
      uiUnitsPerWeek,
      uiLogonHours,
      uiBadPWCount,
      uiNumLogons,
      uiLogonServer,
      uiCountryCode,
      uiCodepage,
      uiUserID,
      uiPrimaryGroupID,
      uiProfile,
      uiHomeDirDrive,
      uiPasswordExpired
   );

   TUserAccountType = (
      fltrDuplicate,        // Enumerates local user account data on a domain controller.
      fltrNormal,           // Enumerates global user account data on a computer.
      fltrProxy,            // ???
      fltrInterdomainTrust, // Enumerates domain trust account data on a domain controller.
      fltrWorkstationTrust, // Enumerates workstation or member server account data on a domain controller.
      fltrServerTrust       // Enumerates domain controller account data on a domain controller.
   );
   TUserAccountFilter = set of TUserAccountType;

   TUserManagerAuto = class(TAutoObject,INetUser)
   private
      function GetLevel20Info(wServer, wUser :WideString; UserData:TNetUserComponents):WideString;
      function UserAccountFilterToDWORD (filter : TUserAccountFilter) : Integer;
      function GetInfoBuffer (wServer, wUser: WideString; level : Integer) : pointer;
   public
      function GetPDC: WideString; safecall;
      function GetLocalGroups(const wServer: WideString): WideString; safecall;
      function GetGlobalGroups( const wServer: WideString): WideString; safecall;
      function GetUsers(const wServerName: WideString): WideString; safecall;
      function AddUser(const wServer, wUser, wDescription, wPassword: WideString): WordBool; safecall;
      function ChangePassword(const wServername, wUserName, wOldPassword, wNewPassword: WideString): WordBool; safecall;
      function GetComment(const wServer, wUser: WideString): WideString; safecall;
      function GetMemberLocalGroups(const wServer, wUser: WideString): WideString; safecall;
      function GetMemberGlobalGroups(const wServer, wUser: WideString): WideString; safecall;
      procedure AddMemberLocalGroups(const wServer, wUser, wGroups: WideString); safecall;
      procedure AddMemberGlobalGroups(const wServer, wUser, Groups: WideString); safecall;
      procedure SetPassword(const wServer, wUser,wPassword: WideString ); safecall;
      procedure AddLocalGroup( const wServer, wGroup: WideString ); safecall;
      function GetFullName(const wServer, wUser: WideString): WideString; safecall;
      procedure SetComment(const wServer, wUser, wComment: WideString); safecall;
      procedure SetMemberLocalGroups(const wServer, wUser, wGroups: WideString); safecall;
      procedure AddOrUpdateUser(const wServer, wUser, wFullName, wComment, wPassword, wGroups: WideString); safecall;
      function UserExists(const wServer, wUser: WideString) : WordBool; safecall;
      procedure SetFullName(const wServer, wUser, wFullName: WideString); safecall;
      procedure DelMemberLocalGroup(const wServer, wGroup, wUser: WideString); safecall;
      function  LocalGroupExists(wServer,wGroup:WideString):WordBool; safecall;
      function  IsMemberLocalGroup( wServer, wUser, wGroup: WideString ):WordBool; safecall ;
      procedure DeleteUser(const wServer, wUser: WideString); safecall;
   end ;

implementation

uses
   ComServ,
   lmcons,lmglobal, lmaccess;//, unitNTException ;//, NetUser;

var
   NIL_HANDLE : Integer absolute 0;

function TUserManagerAuto.UserExists(const wServer, wUser: WideString) : WordBool;
begin
  With TStringObject.Create(GetUsers(wServer)) do
  begin
    try
      Result := (Strings.IndexOf(wUser) <> -1);
    finally
      Free;
    end;
  end;
end;

//----------------------------------------------------------------------------

function TUserManagerAuto.GetInfoBuffer (wServer, wuser: WideString ; level : Integer) : pointer;
begin
   try
      NetUserGetInfo (PWideChar (wServer), PWideChar (wUser), level, result);
   except
      on E:Exception do
         RaiseGUIDError('{D97481E4-CA44-4849-93F3-C14FB2BA664A}', E.MEssage);
   end ;

end;

//----------------------------------------------------------------------------

function TUserManagerAuto.GetLevel20Info( wServer, wUser: WideString; UserData:TNetUserComponents ):WideString;
var
   buffer : pointer;
begin
  Result := '';
  if UserExists(wServer, wUser) then
  begin
     Buffer := GetInfoBuffer( wServer, wUser, 20);
     with PUSER_INFO_20 (buffer)^ do
     try
       Case UserData of
         uiComment     : Result :=  PWideChar (usri20_comment);
         uiFullName    : Result :=  PWideChar (usri20_full_name);
       end;  //case
     finally
       NetAPIBufferFree (buffer)
     end;
  end;
end;

//----------------------------------------------------------------------------

function TUserManagerAuto.UserAccountFilterToDWORD (filter : TUserAccountFilter) : Integer;
begin
   result := 0;
   if fltrDuplicate in filter then result := result or FILTER_TEMP_DUPLICATE_ACCOUNT;
   if fltrNormal in filter then result := result or FILTER_NORMAL_ACCOUNT;
   if fltrProxy in filter then result := result or FILTER_PROXY_ACCOUNT;
   if fltrInterdomainTrust in filter then result := result or FILTER_INTERDOMAIN_TRUST_ACCOUNT;
   if fltrWorkstationTrust in filter then result := result or FILTER_WORKSTATION_TRUST_ACCOUNT;
   if fltrServerTrust in filter then result := result or FILTER_SERVER_TRUST_ACCOUNT
end;

//----------------------------------------------------------------------------

function TUserManagerAuto.GetPDC :WideString;
var
//   Temp:String;
   tempStr : LPCWSTR;
   retval:pointer;
begin
   result:='';
   try
      //if NetGetDCName(NIL,PWideChar(Temp),retVal) = NERR_Success THEN
      if NetGetDCName(NIL,NIL,retVal) = NERR_Success THEN
      begin
         tempStr:=@retVal^;
         result:=WideChartoString(tempStr);
         NetApiBufferFree(retVal)
      end;
   except
      on E:Exception do
         RaiseGUIDError('{4277F07C-1FDE-4A09-B40E-13EE3127B2CA}', E.MEssage);
   end ;

end;

//var
//  temp    : ARRAY[0..255] OF WideChar;
//  tempStr : LPCWSTR;
//  retVal  : LPBYTE;
//begin
//
//
//   result:='';
//   try
//
//      if NetGetDCName(nil,nil,retVal) = NERR_Success then
//      begin
//         tempStr:=@retVal^;
//         result:=WideChartoString(tempStr);
//         NetApiBufferFree(retVal);
//         FStatus := nmsOk ;
//      end ;
//
//   except
//
//       on e : exception do
//       begin
//         GPCSErrorLine.RaiseException($809, E);
//         HandleStatusError( e.message );
//       end ;
//   end ;





//----------------------------------------------------------------------------

function TUserManagerAuto.GetUsers( Const wServerName :WideString ):WideString;
var
   rv : NetAPIStatus;
   buffer : pointer;
   i, entriesRead, totalEntries : Integer;
   p : PUSER_INFO_0;
   List : TStringList ;
begin

   List := TStringList.Create ;

   rv := NetUserEnum (PWideChar (wServerName), 0, UserAccountFilterToDWORD ([ fltrNormal ]), buffer, MAX_PREFERRED_LENGTH,
                      entriesRead, totalEntries, NIL_HANDLE);
   try
      if rv = NERR_Success then
         try
            p := PUSER_INFO_0 (buffer);
            for i := 0 to entriesRead - 1 do
            begin
               list.Add (p^.usri0_name);
               Inc (p)
            end
         finally
           NetAPIBufferFree (buffer)
         end ;
         //else raise ENTException.Create (rv);
   except
    on E:Exception do
        RaiseGUIDError('{5506AD61-B054-4851-9B55-BDBCA1AB648C}', E.MEssage);

   end ;

   result := List.CommaText ;
   List.Free ;
end;

//----------------------------------------------------------------------------

function TUserManagerAuto.GetLocalGroups(const wServer:WideString ):WideString;
var
   rv, i, entriesRead, totalEntries : Integer;
   buffer : pointer;
   p : PLOCALGROUP_INFO_0;
   List:TStringList;
begin
   List:=TStringList.Create;
   list.Clear;
   Result :='';
   try
      rv := NetLocalGroupEnum (PWideChar (wServer), 0, buffer, MAX_PREFERRED_LENGTH,
                               entriesRead, totalEntries, NIL_HANDLE);

      if rv = NERR_Success then
      try
        p := PLOCALGROUP_INFO_0 (buffer);
        for i := 0 to entriesRead - 1 do
        begin
          list.Add (p^.lgrpi0_name);
          Inc (p) ;
        end ;
       Result := List.CommaText ;
      finally
        NetApiBufferFree (buffer);
        List.Free;
      end;
      //else  raise ENTException.Create (rv);
    except
       on E:Exception do
          RaiseGUIDError('{5506AD61-B054-4851-9B55-BDBCA1AB648C}', E.MEssage);

    end;

end;

//----------------------------------------------------------------------------
function  TUserManagerAuto.LocalGroupExists(wServer,wGroup:WideString):WordBool; safecall;
var
   SL:TStringList ;
begin
   SL:=TStringList.Create;
   SL.CommaText := GetLocalGroups( wServer );
   result := ( SL.IndexOf( wGroup ) >=0 );
   SL.Free;
end ;
//----------------------------------------------------------------------------

function TUserManagerAuto.GetGlobalGroups (const wServer:WideString):WideString;
var
  rv, i, entriesRead, totalEntries : Integer;
  buffer : pointer;
  p : PGROUP_INFO_0;
  List:TstringList;
begin
  List:=TstringList.Create;
  list.Clear;
  result:='';
  try
     rv := NetGroupEnum (PWideChar (wServer), 0, buffer, MAX_PREFERRED_LENGTH,
                         entriesRead, totalEntries, NIL_HANDLE);

     if rv = NERR_Success then
     try
       p := PGROUP_INFO_0 (buffer);
       if (entriesRead <> 1) or (p^.grpi0_name <> 'None') then
         for i := 0 to entriesRead - 1 do
         begin
           list.Add (p^.grpi0_name);
           Inc (p)
         end ;
       result:=List.CommaText;
     finally
       NetApiBufferFree (buffer);
       List.Free;
     end
     //else raise ENTException.Create (rv);
   except
      on E:Exception do
         RaiseGUIDError('{B438B694-EE73-4327-ABB4-D7DA59D96E79}', E.MEssage);
   end;

end;

//----------------------------------------------------------------------------

function  TUserManagerAuto.AddUser( const wServer, wUser, wDescription, wPassword:WideString ):WordBool;
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
            RaiseGUIDError('{1B47A83F-CD3E-4350-A28F-A688DAAAA376}', E.MEssage);
      end;

end;

//----------------------------------------------------------------------------

function  TUserManagerAuto.GetComment(const wServer, wUser:WideString) : WideString;
begin
  result := '' ;
  try
     if (wUser <> '') and UserExists(wServer, wUser) then
     begin
        result := GetLevel20Info(wServer, wUser, uiComment);
     end ;
  except
     on E:Exception do
        RaiseGUIDError('{001D9C18-46F6-413F-96A2-A945FB1F325A}', E.MEssage);
  end ;
end;

//----------------------------------------------------------------------------

function TUserManagerAuto.GetFullName(const wServer, wUser: WideString): WideString;
begin
  result := '' ;
  try
     if (wUser <> '') and UserExists(wServer, wUser) then
     begin
        result := GetLevel20Info(wServer, wUser, uiFullName);
     end ;
  except
     on E:Exception do
        RaiseGUIDError('{001D9C18-46F6-413F-96A2-A945FB1F325A}', E.MEssage);
  end ;
end;

procedure TUserManagerAuto.SetFullName(const wServer, wUser, wFullName: WideString);
var
  info  : USER_INFO_1011;
  err   : integer;
begin
  try
    info.usri1011_full_name := PWideChar( wFullName );
    //NetUserSetInfo( PWideChar( wServer ), PWideChar( wUser ), 1003, @info,err )
    NetUserSetInfo( PWideChar( wServer ), PWideChar( wUser ), 1011, @info,err )
  except
    on e : exception do
      RaiseGUIDError('{83AFAD1D-6EA0-462B-BA6C-56AB14CFA292}', E.MEssage);
  end;
end;

//----------------------------------------------------------------------------

function  TUserManagerAuto.ChangePassword(const wServername, wUserName,wOldPassword, wNewPassword: WideString): WordBool;
begin
   result:=False;

   try
      result := ( NetUserChangePassword ( PWideChar (wServerName),
                                          PWideChar (wUserName),
                                          PWideChar (woldPassword),
                                          PWideChar (wNewPassword)
                                        )
                  =  NERR_Success );
   except
      on e : exception do
         RaiseGUIDError('{604973EA-96A1-4A30-A4DB-410F1C7C6540}', E.MEssage);
   end ;

end ;

//----------------------------------------------------------------------------

function  TUserManagerAuto.GetMemberLocalGroups(const wServer, wUser:WideString ):WideString;
var
   buffer : pointer;
   p : PLOCALGROUP_USERS_INFO_0;
   rv, i, entriesRead, totalEntries : Integer;
   List:TStringList;
begin
   Result := '' ;
   if wUser <> '' then
   begin

      List := TStringList.Create;
      list.Clear;

      try

         if (wUser<>'') and UserExists(wServer, wUser) then
         begin
            rv := NetUserGetLocalGroups (PWideChar (wServer), PWideChar (wUser), 0, 0, buffer, MAX_PREFERRED_LENGTH, entriesRead, totalEntries);
            if rv = NERR_Success then
            try
               p := PLOCALGROUP_USERS_INFO_0 (buffer);
               for i := 0 to entriesRead - 1 do
               begin
                  list.Add (p^.lgrui0_name);
                  Inc (p)
               end ;
               result:= List.CommaText;
            finally
                NetAPIBufferFree (buffer);
                List.Free;
            end;
         end ;
      except
          on e : exception do
             RaiseGUIDError('{8D31A933-DEED-4CA1-83B4-B7951FA0D228}', E.MEssage);
      end ;
   end ;
end;

//----------------------------------------------------------------------------
function TUserManagerAuto.IsMemberLocalGroup( wServer, wUser, wGroup: WideString ):WordBool; safecall ;
var
   SL:TStringList ;
begin
   SL:=TStringList.Create;
   SL.CommaText := GetMemberLocalGroups( wServer, wUser );
   result := ( SL.IndexOf( wGroup ) >=0 );
   SL.Free;
end ;

//----------------------------------------------------------------------------

function  TUserManagerAuto.GetMemberGlobalGroups ( const wServer, wUser:WideString ):WideString;
var
  buffer : pointer;
  p : PGROUP_USERS_INFO_0;
  rv, i, entriesRead, totalEntries : Integer;
  List:TStringList ;
begin
  result:='';
  List:=TStringList.Create;
  list.Clear;
   try
     if (wUser<>'') and UserExists(wServer, wUser)then
     begin
       rv := NetUserGetGroups (PWideChar (wServer), PWideChar (wUser), 0, buffer, MAX_PREFERRED_LENGTH, entriesRead, totalEntries);
       if rv = NERR_Success then
       try
         p := PGROUP_USERS_INFO_0 (buffer);
         if (entriesRead <> 1) or (p^.grpui0_name <> 'None') then
           for i := 0 to entriesRead - 1 do
           begin
             list.Add (p^.grpui0_name);
             Inc (p)
           end ;
       Result:= List.CommaText;
       finally
         NetAPIBufferFree (buffer);
         List.Free ;
       end
       //else raise ENTException.Create (rv)
     end ;
   except
      on e : exception do
         RaiseGUIDError('{2C20599D-A2D9-4ED7-9FE0-9CBC276A4120}', E.MEssage);
   end ;


end;

//----------------------------------------------------------------------------

procedure  TUserManagerAuto.AddMemberLocalGroups( const wServer, wUser, wGroups : WideString ) ;
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
             if not IsMemberLocalGroup( wServer, wUser, wGroup ) then
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

procedure TUserManagerAuto.DelMemberLocalGroup(const wServer, wGroup, wUser: WideString);
var
  sid                   : PSid;
  sidLen, domainNameLen : DWORD;
  DomainName            : array [0..DNLEN] of char;
  info                  : LOCALGROUP_MEMBERS_INFO_0;
  SystemName, User      : String;
  peUse                 : SID_NAME_USE;
begin
  try
    SystemName := wServer;
    User       := wUser;

    domainNameLen := DNLEN + 1;
    sidLen := 65536;
    GetMem (sid, sidLen);
    try
      If LookUpAccountName(PChar(SystemName), PChar(User), sid, sidLen, DomainName, DomainNameLen, peUse) then
      begin
        info.lgrmi0_sid := sid;
        NetLocalGroupDelMembers(PWideChar(wServer), PWideChar (wGroup), 0, @info, 1);
      end;
    finally
      FreeMem(sid);
    end;
  except
    On E : Exception do
      RaiseGUIDException('{5000D027-5D68-45E2-8628-5AF6F32DA080}', E);
  end;
end;

//function  TUserManagerAuto.AddMemberLocalGroups( Server, User, Groups : String ) : boolean ;
//var
//   i:integer;
//   List:TStringList;
//   wServer :WideString;
//   wGroups :WideString;
//   wUserName:WideString ;
//   info : LOCALGROUP_MEMBERS_INFO_3 ;
//begin
//   Result := False ;
//
//   List:=TStringList.Create;
//   List.CommaText := Groups;
//
//   wServer := Server ;
//   if Copy( Server, 1, 2 )='\\' then Server := Copy( Server,3, 999 );
//
//   try
//
//      // goes throught every groups and add the users
//      for i := 0 to List.Count-1 do
//      begin
//
//            // Pick the group with the sitax  "server\user"
//            wGroups := List[i];
//            wUserName := Server+'\'+User ;
//
//            info.lgrmi3_domainandname := PWideChar( wUserName );
//            result :=(NetLocalGroupAddMembers(PWideChar(wServer),PWideChar(wGroups),3, @info,1) = NERR_Success);
//
//      end ;
//
//   List.Free;
//
//   except
//      on e : exception do
//         RaiseGUIDError('{AF8149BE-A43A-467C-B05E-417BF3F6421A}', E.MEssage);
//
//   end ;
//
//end;

//----------------------------------------------------------------------------

procedure  TUserManagerAuto.AddMemberGlobalGroups( const wServer, wUser, Groups:WideString );
var
   List:TStringList;
   i : integer ;
   wGroup:WideString;
begin

   List:=TStringList.Create;
   list.commatext:=Groups;
   try

      if list.count > 1 then
      begin

         for i := 0 to List.count-1 do
         begin
            wGroup:=List[i];
            NetGroupAddUser (PWideChar (wServer), PWideChar (wGroup), PWideChar (wUser));
         end ;
      end ;

   except
      on e : exception do
         RaiseGUIDError('{B3F57CEF-8DA9-4EEC-9C48-7C21EC104EDE}', E.MEssage);
   end ;

end ;

//----------------------------------------------------------------------------

procedure  TUserManagerAuto.SetPassword( const wServer, wUser, wPassword: WideString );
var
  info:USER_INFO_1003;
  err:integer;
begin
  try
    info.usri1003_password := PWideChar( wPassWord );
    NetUserSetInfo( PWideChar( wServer ), PWideChar( wUser ), 1003, @info,err )
  except
    on e : exception do
      RaiseGUIDError('{47D10FE9-F822-4A62-BBA1-A27F950C165A}', E.MEssage);
  end ;
end ;

//----------------------------------------------------------------------------

procedure TUserManagerAuto.AddLocalGroup( const wServer, wGroup: WideString ); safecall;
var
  info:LOCALGROUP_INFO_0;
  err : integer ;
begin
  try
    info.lgrpi0_name := PWideChar( wGroup );
    NetLocalGroupAdd ( PWideChar( wServer ),0, @info, err) ;
  except
    on e : exception do
      RaiseGUIDError('{9F5DBA35-50FE-46DB-9E74-064D368EF3D0}', E.MEssage);
  end;
end;

procedure TUserManagerAuto.SetComment(const wServer, wUser, wComment: WideString); safecall;
var
  info  : USER_INFO_1007;
  err   : integer;
begin
  try
    info.usri1007_comment := PWideChar( wComment );
    NetUserSetInfo( PWideChar( wServer ), PWideChar( wUser ), 1007, @info,err )
  except
    on e : exception do
      RaiseGUIDError('{0FADBFC4-C83E-45BB-BF4A-638F0957B602}', E.MEssage);
  end;
end;

procedure TUserManagerAuto.SetMemberLocalGroups(const wServer, wUser, wGroups: WideString); safecall;
begin
end;


procedure TUserManagerAuto.AddOrUpdateUser(const wServer, wUser, wFullName, wComment, wPassword, wGroups: WideString); safecall;
var
  LocalGroups : TStringObject;
begin


   if wComment = '^Delete' then
      DeleteUser( wServer, wUser )
   else
   begin
      try
         //check already exists
         If not UserExists(wServer, wUser) then
         begin
           AddUser(wServer, wUser, wComment, wPassword);
         end
         else
         begin
           SetFullName( wServer, wUser, wFullName);
           SetComment(wServer, wUser, wComment);
           SetPassword(wServer, wUser, wPassword);
         end;

         //update GPCS groups
         LocalGroups := TStringObject.Create(GetMemberLocalGroups(wServer,wUser));
         try
           //remove from any GPCS groups
           While LocalGroups.Strings.Count > 0 do
           begin
             If LeftOf(Uppercase(LocalGroups.Strings[0]), 'GPCS') then
               DelMemberLocalGroup(wServer, LocalGroups.Strings[0], wUser);
               LocalGroups.Strings.Delete(0);
           end;

           //add local group
           LocalGroups.Value := wGroups;   //groups for user
           While LocalGroups.Strings.Count > 0 do  //ensure these local groups exist
           begin
             if not LocalGroupExists( wServer, LocalGroups.Strings[0] ) then
                AddLocalGroup(wServer, LocalGroups.Strings[0]);
             LocalGroups.Strings.Delete(0);
           end;
           //add to new groups
            AddMemberLocalGroups(wServer, wUser, wGroups);

         finally
           LocalGroups.Free;
         end;
      except
        On E : Exception do
           RaiseGUIDException('{68BC4A73-C46B-4181-B6B0-FFEF8DEEFB2E}', E);
      end;
   end;
end;

procedure TUserManagerAuto.DeleteUser(const wServer, wUser: WideString);
begin

  try
    NetUserDel (PWideChar (wServer), PWideChar (wUser) );
  except
    on e : exception do
    RaiseGUIDError('{0C7B8E47-BA05-41E9-90C0-E19CF9F74A34}', E.MEssage);
  end;

end ;


Initialization
  TAutoObjectFactory.Create(ComServer, TUserManagerAuto, Class_NetUser, ciMultiInstance);

  //TGPCSCompFactory.Create(ComServer,TUserManagerAuto,Class_GPCSTransactionLog,
  //                        'Support.UserManager','GPCS User Manager',
  //                        ciMultiInstance);

end.
