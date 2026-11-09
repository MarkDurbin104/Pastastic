unit GetMACAddrU;

interface

uses
	MACAddrU;


function GetMACAddr : String;

implementation

function GetMACAddr : String;
begin
	With TMACAddress.Create do
  begin
  	try
    	Result := Address;
    finally
			Free;
    end;
  end

end;

end.
