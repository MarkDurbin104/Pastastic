unit RASDialU;

interface

uses Classes, ExtCtrls, SysUtils, Windows, Messages, ShellApi, Ras,Dialogs ;

type
   TRasDialFunc = procedure(unMsg:DWORD;RasConnState:TRASCONNSTATE;dwError:DWORD); stdcall;
   TRASConnection = Class( TObject )
   private
      FRasDialFunc:TRasDialFunc;
      aRasConn     :array [0..10] of TRASCONN;
      nRasConnCount:DWORD;
      hRasConn     :THRASCONN ;
   public
      procedure Disconnect;
      procedure GetActiveConn;
      procedure Dial(PhoneNumber,UserName,Password:String);
      function  GetActiveConnHandle(szName : String): THRASCONN ;
      function  CheckConnection : String ;
      function ConnectionStatus(var ErrorCode:Integer):TRASCONNSTATE;
      function IPAddress:String;
      property  OnRasDialFunc : TRasDialFunc read FRasDialFunc write FRasDialFunc;

      constructor Create ;
      Destructor  Destroy; override ;
   end ;

implementation



// -----------------------------------------------------------------------------
Constructor TRASConnection.Create ;
begin
end ;

// -----------------------------------------------------------------------------
Destructor TRASConnection.Destroy ;
begin
   Disconnect;
   inherited destroy;
end;

// -----------------------------------------------------------------------------
procedure TRASConnection.Dial( PhoneNumber, UserName, Password : String);
var
    rdParams : TRASDIALPARAMS;
begin
    FillChar(rdParams, SizeOf(rdParams), 0);
    rdParams.dwSize:= SizeOf(TRASDIALPARAMS);

    strCopy(rdParams.szPhoneNumber,PChar(PhoneNumber));
    strCopy(rdParams.szUserName   ,PChar(UserName)   );
    strCopy(rdParams.szPassword   ,PChar(Password)   );
    //strCopy(rdParams.szEntryName, PChar(EntryName));
    //rdParams.szPhoneNumber[0]    := #0;
    rdParams.szCallbackNumber[0] := #0;
    rdParams.szDomain            := '';

    hRasConn := 0;;
    RasDialA(nil,nil,@rdParams,0,@FRasDialFunc,@hRasConn);
end;
function TRASConnection.IPAddress:String;
var
    proj_buf : TRASPPPIP;
    cb:Integer;
begin
   if hRasConn = 0 then Exit;
   Result:='';
   cb:=sizeof(proj_buf);
   proj_buf.dwSize:=cb;
   if (RasGetProjectionInfoA(hRasConn,RASP_PppIp,Pointer(@proj_buf),@cb) = 0) then
      Result:=proj_buf.szIpAddress;
end;

// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
procedure TRASConnection.Disconnect;
begin
    if hRasConn <> 0 then begin
        RasHangUpA(hRasConn);
        hRasConn:=0;
    end;
end;

// -----------------------------------------------------------------------------
procedure TRASConnection.GetActiveConn;
var
    dwRet    : DWORD;
    nCB      : DWORD;
    Buf      : array [0..255] of Char;
begin
    aRasConn[0].dwSize := SizeOf(aRasConn[0]);
    nCB   := SizeOf(aRasConn);
    dwRet := RasEnumConnectionsA(@aRasConn, @nCB, @nRasConnCount);
    if dwRet <> 0 then begin
        RasGetErrorStringA(dwRet, @Buf[0], SizeOf(Buf));
//        LogMessage(Buf);
    end;
end;

// -----------------------------------------------------------------------------
function TRASConnection.GetActiveConnHandle(szName : String): THRASCONN ;
var
    I : Integer;
begin
    GetActiveConn;
    if nRasConnCount > 0 then begin
        for I := 0 to nRasConnCount - 1 do begin
            if StrIComp(PChar(szName), aRasConn[I].szEntryName) = 0 then begin
                Result := aRasConn[I].hRasConn;
                Exit;
            end;
        end;
    end;
    Result := 0;
end;

function TRASConnection.ConnectionStatus(var ErrorCode:Integer):TRASCONNSTATE;
var
    RasConnStatus:TRASCONNSTATUS;
begin
    Result:=RASCS_Disconnected;
    ErrorCode:=0;
    if hRasConn = 0 then Exit;

    FillChar(RasConnStatus,SizeOf(RasConnStatus),0);
    RasConnStatus.dwSize:=SizeOf(RasConnStatus);
    ErrorCode:=RasGetConnectStatusA(hRasConn,@RasConnStatus);
    if ErrorCode = ERROR_INVALID_HANDLE then
    begin
        Disconnect;
        Exit;
    end ;
    Result:=RasConnStatus.RasConnState;
end;
// -----------------------------------------------------------------------------
function TRASConnection.CheckConnection : String ;
var
    RasConnStatus : TRASCONNSTATUS;
    Status        : DWORD;
    Buf           : array [0..255] of Char;
begin

    Result := 'OK ' ;
    if hRasConn = 0 then
        Exit;

    FillChar(RasConnStatus, SizeOf(RasConnStatus), 0);
    RasConnStatus.dwSize := SizeOf(RasConnStatus);
    Status := RasGetConnectStatusA(hRasConn, @RasConnStatus);
    if Status = ERROR_INVALID_HANDLE then
    begin
        result := 'Connection closed' ;
        Disconnect ;
        Exit;
    end ;

    if Status <> 0 then
    begin
        Buf := '';
        RasGetErrorStringA(Status, @Buf[0], SizeOf(Buf));
        result := 'Error #' + IntToStr(Status) + ' : ' + Buf ;
    end;

end ;

end.



