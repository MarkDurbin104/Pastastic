library UDP;

uses
  SysUtils,
  Classes,IdUDPBase, IdUDPServer,IdSocketHandle;


type
   TCallBack = function (Data:PChar):Integer; cdecl;
   TUDPDLLClass = class
   public
      procedure IdUDPServer1UDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);
   end;

var
  DataReceived:TCallBack;
  PortNumber:Integer;
  IdUDPServer1: TIdUDPServer;
  UDPDLLClass:TUDPDLLClass;

procedure TUDPDLLClass.IdUDPServer1UDPRead(Sender: TObject; AData: TBytes; ABinding: TIdSocketHandle);
begin
  try
    DataReceived(PChar(AData));
  except
  end;
end;

function UDPStartup(onDataReceived:TCallBack;Port:Integer):Integer;
begin
  try
     Result:=1;
     DataReceived:=@onDataReceived;
     Result:=2;
     PortNumber:=Port;
     Result:=3;
     UDPDLLClass:=TUDPDLLClass.Create;
     Result:=4;
     IdUDPServer1:=TIdUDPServer.Create(nil);
     Result:=5;
     IdUDPServer1.BroadcastEnabled := True;
     Result:=6;
     IdUDPServer1.DefaultPort := PortNumber;
     Result:=7;
     IdUDPServer1.OnUDPRead := UDPDLLClass.IdUDPServer1UDPRead;
     Result:=8;
     IdUDPServer1.Active := True;
     Result:=9;
  except
//     Result:=0;
  end;
end;

function UDPSendData(Data:PChar):Integer;
begin
  try
     Result:=1;
     if IdUDPServer1.Active then
       IdUDPServer1.Broadcast(Data,PortNumber);
  except
     Result:=0;
  end;
end;
procedure UDPShutdown;
begin
  try
    IdUDPServer1.Active := False;
    IdUDPServer1.Free;
    UDPDLLClass.Free;
  except
  end;
end;

exports
   UDPStartup,UDPShutdown,UDPSendData;

begin
end.
