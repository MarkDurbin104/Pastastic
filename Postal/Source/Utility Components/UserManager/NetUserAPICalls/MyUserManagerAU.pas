unit MyUserManagerAU;

interface

uses windows,classes, sysutils,
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

   TUserManager = class(TComponent)
   private
      function GetLevel20Info(wServer, wUser :WideString; UserData:TNetUserComponents):WideString;
      function UserAccountFilterToDWORD (filter : TUserAccountFilter) : Integer;
      function GetInfoBuffer (wServer, wUser: WideString; level : Integer) : pointer;
   public

      function  GetPDC :String ;
      function  GetLocalGroups( wServer:WideString ):String;
      function  GetGlobalGroups (wServer:WideString):String;
      function  GetUsers ( const wServerName : WideString ):String;
      function  AddUser( const wServer, wUser, wDescription, wPassword:WideString ):boolean;
      function  ChangePassword(const wServername, wUserName,wOldPassword, wNewPassword: WideString): boolean;
      function  GetComment(wServer, wUser:WideString) : string;
      function  GetMemberLocalGroups( wServer, wUser : WideString ) : string ;
      function  GetMemberGlobalGroups( wServer, wUser:WideString ):string;
      procedure AddMemberLocalGroups( Server, User, Groups : string );
      procedure AddMemberGlobalGroups( wServer, wUser: WideString; Groups:string );


   end ;

implementation

uses lmcons,lmglobal, lmaccess, lmserver, unitNTException, NetUser;

var
   NIL_HANDLE : Integer absolute 0;

//----------------------------------------------------------------------------

function TUserManager.GetInfoBuffer (wServer, wuser: WideString ; level : Integer) : pointer;
var
   rv : Integer;
begin
   rv := NetUserGetInfo (PWideChar (wServer), PWideChar (wUser), level, result);
   if rv <> NErr_Success then
      raise ENTException.Create (rv);
end;

//----------------------------------------------------------------------------

function TUserManager.GetLevel20Info( wServer, wUser: WideString; UserData:TNetUserComponents ):WideString;
var
   buffer : pointer;
begin

   buffer := GetInfoBuffer( wServer, wUser, 20);
   with PUSER_INFO_20 (buffer)^ do
   try
      if UserData = uiComment then  result :=  PWideChar (usri20_comment) ;
   finally
      NetAPIBufferFree (buffer)
   end
end;

//----------------------------------------------------------------------------

function TUserManager.UserAccountFilterToDWORD (filter : TUserAccountFilter) : Integer;
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

function TUserManager.GetPDC :String;
var
   Temp:String;
   tempStr : LPCWSTR;
   retval:pointer;
begin
   result:='';
   try
      if NetGetDCName(NIL,PWideChar(Temp),retVal) = NERR_Success THEN
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

//----------------------------------------------------------------------------

function TUserManager.GetUsers( Const wServerName :WideString ):String;
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

function TUserManager.GetLocalGroups( wServer:WideString ):String;
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

function TUserManager.GetGlobalGroups (wServer:WideString):String;
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

function  TUserManager.AddUser( const wServer, wUser, wDescription, wPassword:WideString ):boolean;
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

function  TUserManager.GetComment(wServer, wUser:WideString) : string;
begin
  result := '' ;
  try
     if wUser <> '' then
     begin
        result := GetLevel20Info(wServer, wUser, uiComment);
     end ;
  except
     on E:Exception do
        RaiseGUIDError('{001D9C18-46F6-413F-96A2-A945FB1F325A}', E.MEssage);
  end ;
end;

//----------------------------------------------------------------------------

function  TUserManager.ChangePassword(const wServername, wUserName,wOldPassword, wNewPassword: WideString): boolean;
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

function  TUserManager.GetMemberLocalGroups( wServer, wUser:WideString ):string;
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
      except
          on e : exception do
             RaiseGUIDError('{8D31A933-DEED-4CA1-83B4-B7951FA0D228}', E.MEssage);
      end ;
   end ;
end;

//----------------------------------------------------------------------------

function  TUserManager.GetMemberGlobalGroups ( wServer, wUser:WideString ):string;
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
     if wUser<>''then
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

//procedure TNetLocalGroup.AddMemberFrom (const id, memberServer : string);
procedure  TUserManager.AddMemberLocalGroups( Server, User, Groups : String ) ;
var
  sid : PSid;
  peUse : SID_NAME_USE;
  err : Integer;
  sidLen, domainNameLen : DWORD;
  domainName : array [0..DNLEN] of char;
  wServer, wGroup : WideString;
  memberServer:string;
  info : LOCALGROUP_MEMBERS_INFO_0 ;
  i : integer ;
  list:TStringList;
begin

   list := Tstringlist.create ;
   list.CommaText := Groups;
   memberServer:=Server ;//'\\TALLSERVER';
   wServer:=Server;
   for i := 0 to list.count-1 do
   begin

      wGroup:=list[i];

      sidLen := 65536;
      domainNameLen := DNLEN + 1;

      GetMem (sid, sidLen);
      try
        //if (LookupAccountName (PChar (memberServer), PChar (id), sid, sidLen, domainName, domainNameLen, peUse)) then
        if (LookupAccountName (PChar (memberServer), PChar (User), sid, sidLen, domainName, domainNameLen, peUse)) then
        begin
          //err := NetLocalGroupAddMember (PWideChar (wServer), PWideChar (wGroup), sid);

          info.lgrmi0_sid := sid ;
          err := NetLocalGroupAddMembers (PWideChar (wServer), PWideChar (wGroup),0,@info, 1);
          if err <> NERR_Success then
            raise ENTException.Create (err);
        end
        else raise ENTException.CreateLastError;
      finally
        FreeMem (sid)
      end

   end ;
   list.Free ;

end;


//function  TUserManager.AddMemberLocalGroups( Server, User, Groups : String ) : boolean ;
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

procedure  TUserManager.AddMemberGlobalGroups( wServer, wUser: WideString; Groups:String );
var
   List:TStringList;
   i : integer ;
   wGroup:WideString;
begin

   List:=TStringList.Create;
   list.commatext:=Groups;

   if list.count > 1 then
   begin

      for i := 0 to List.count-1 do
      begin
         wGroup:=List[i];
         NetGroupAddUser (PWideChar (wServer), PWideChar (wGroup), PWideChar (wUser));
      end ;

   end ;

end ;



end.
